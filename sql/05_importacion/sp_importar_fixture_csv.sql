/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : sp_importar_fixture_csv.sql
   Objetivo    : Importar el fixture de partidos desde archivo CSV.
   ============================================================================ */
CREATE OR ALTER PROCEDURE importacion.sp_importar_fixture_csv
    @archivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @importacionId INT,
            @sql           NVARCHAR(MAX),
            @leidos        INT,
            @errores       INT;

    INSERT INTO importacion.importacion_log (origen, tipo_fuente, archivo)
    VALUES ('Importación Fixture', 'CSV', @archivo);

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY
        -- 1) Cargar CSV directo a una tabla cruda
        IF OBJECT_ID('tempdb..#raw_fixture') IS NOT NULL DROP TABLE #raw_fixture;
        CREATE TABLE #raw_fixture (
            fase VARCHAR(15),
            nombre_estadio NVARCHAR(100),
            iso_local CHAR(3),
            iso_visitante CHAR(3),
            fecha_hora_local DATETIME2(0)
        );

        SET @sql = 'BULK INSERT #raw_fixture FROM ''' + REPLACE(@archivo, '''', '''''') + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0D0A'', CODEPAGE = ''65001'');';
        EXEC (@sql);

        SELECT @leidos = COUNT(*) FROM #raw_fixture;

        -- 2) Volcar a Staging resolviendo claves foráneas y CALCULANDO EL UTC AL VUELO
        IF OBJECT_ID('tempdb..#stg_fixture') IS NOT NULL DROP TABLE #stg_fixture;
        CREATE TABLE #stg_fixture (
            fila INT,
            fase VARCHAR(15),
            fecha_hora_local DATETIME2(0),
            fecha_hora_utc DATETIME2(0), -- Nueva columna para el UTC calculado
            sede_id INT,
            local_id INT,
            visitante_id INT,
            error_desc NVARCHAR(200)
        );

        INSERT INTO #stg_fixture (fila, fase, fecha_hora_local, fecha_hora_utc, sede_id, local_id, visitante_id, error_desc)
        SELECT 
            ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
            r.fase,
            r.fecha_hora_local,
            
            -- CÁLCULO DEL UTC: Toma la hora local, le asigna el huso horario de la sede, y lo convierte a UTC.
            CASE 
                WHEN sd.huso_horario IS NOT NULL THEN 
                    CAST(r.fecha_hora_local AT TIME ZONE sd.huso_horario AT TIME ZONE 'UTC' AS DATETIME2(0))
                ELSE NULL 
            END,

            sd.sede_id,
            sl.seleccion_id,
            sv.seleccion_id,
            CASE 
                WHEN sd.sede_id IS NULL THEN 'Estadio no encontrado: ' + ISNULL(r.nombre_estadio, 'NULL')
                WHEN sl.seleccion_id IS NULL THEN 'Selección Local no encontrada para ISO: ' + ISNULL(r.iso_local, 'NULL')
                WHEN sv.seleccion_id IS NULL THEN 'Selección Visitante no encontrada para ISO: ' + ISNULL(r.iso_visitante, 'NULL')
                ELSE NULL 
            END
        FROM #raw_fixture r
        LEFT JOIN torneo.sede sd ON sd.nombre_estadio = r.nombre_estadio
        LEFT JOIN torneo.pais pl ON pl.codigo_iso = r.iso_local
        LEFT JOIN torneo.seleccion sl ON sl.pais_id = pl.pais_id
        LEFT JOIN torneo.pais pv ON pv.codigo_iso = r.iso_visitante
        LEFT JOIN torneo.seleccion sv ON sv.pais_id = pv.pais_id;

        -- 3) Grabar los errores de todos los registros inválidos juntos
        INSERT INTO importacion.importacion_error (importacion_id, detalle)
        SELECT @importacionId, CONCAT('Fila ', fila, ': ', error_desc)
        FROM #stg_fixture
        WHERE error_desc IS NOT NULL;

        SET @errores = @@ROWCOUNT;

        -- 4) Limpiar el Staging para dejar solo lo que está perfecto
        DELETE FROM #stg_fixture WHERE error_desc IS NOT NULL;

        -- 5) Bloque Transaccional: UPSERT (Modificación y Alta) en bloque
        BEGIN TRAN;

            -- MODIFICACIÓN (Actualiza sede, horario local y horario UTC si el partido ya existía)
            UPDATE p
            SET p.sede_id = s.sede_id,
                p.fecha_hora_local = s.fecha_hora_local,
                p.fecha_hora_utc = s.fecha_hora_utc
            FROM torneo.partido p
            JOIN #stg_fixture s
              ON p.fase = s.fase 
             AND p.seleccion_local_id = s.local_id 
             AND p.seleccion_visitante_id = s.visitante_id;

            -- ALTA (Inserta los partidos que no existen incluyendo el UTC)
            INSERT INTO torneo.partido (fase, sede_id, seleccion_local_id, seleccion_visitante_id, fecha_hora_local, fecha_hora_utc, estado)
            SELECT s.fase, s.sede_id, s.local_id, s.visitante_id, s.fecha_hora_local, s.fecha_hora_utc, 'PROGRAMADO'
            FROM #stg_fixture s
            WHERE NOT EXISTS (
                SELECT 1 FROM torneo.partido p
                WHERE p.fase = s.fase 
                  AND p.seleccion_local_id = s.local_id 
                  AND p.seleccion_visitante_id = s.visitante_id
            );

        COMMIT;

        -- 6) Actualizar el resumen del log
        UPDATE importacion.importacion_log
        SET registros_leidos = @leidos,
            registros_ok     = @leidos - @errores,
            registros_error  = @errores,
            estado           = CASE WHEN @errores = 0 THEN 'OK' ELSE 'PARCIAL' END,
            fecha_fin        = SYSDATETIME()
        WHERE importacion_id = @importacionId;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        UPDATE importacion.importacion_log 
        SET estado = 'ERROR', fecha_fin = SYSDATETIME() 
        WHERE importacion_id = @importacionId;

        THROW;
    END CATCH;
END;
GO