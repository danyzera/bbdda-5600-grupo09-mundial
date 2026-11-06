/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : sp_importar_plantillas_csv.sql
   Objetivo    : Importar selecciones, jugadores y convocatorias desde CSV (Set-Based).
   ============================================================================ */
CREATE OR ALTER PROCEDURE importacion.sp_importar_plantillas_csv
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
    VALUES ('Importación Plantillas', 'CSV', @archivo);

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY
        -- 1) Cargar CSV directo a una tabla cruda
        IF OBJECT_ID('tempdb..#raw_plantilla') IS NOT NULL DROP TABLE #raw_plantilla;
        CREATE TABLE #raw_plantilla (
            iso_pais CHAR(3),
            nombre_seleccion NVARCHAR(100),
            confederacion VARCHAR(10),
            grupo CHAR(1),
            nombre_jugador NVARCHAR(150),
            fecha_nacimiento DATE,
            posicion VARCHAR(10),
            club_origen NVARCHAR(100),
            dorsal TINYINT,
            fecha_convocatoria DATE
        );

        SET @sql = 'BULK INSERT #raw_plantilla FROM ''' + REPLACE(@archivo, '''', '''''') + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0D0A'', CODEPAGE = ''65001'');';
        EXEC (@sql);

        SELECT @leidos = COUNT(*) FROM #raw_plantilla;

        -- 2) Volcar a Staging resolviendo la clave foránea de País y aplicando pre-validaciones
        IF OBJECT_ID('tempdb..#stg_plantilla') IS NOT NULL DROP TABLE #stg_plantilla;
        CREATE TABLE #stg_plantilla (
            fila INT,
            iso_pais CHAR(3),
            pais_id INT,
            nombre_seleccion NVARCHAR(100),
            confederacion VARCHAR(10),
            grupo CHAR(1),
            nombre_jugador NVARCHAR(150),
            fecha_nacimiento DATE,
            posicion VARCHAR(10),
            club_origen NVARCHAR(100),
            dorsal TINYINT,
            fecha_convocatoria DATE,
            error_desc NVARCHAR(200)
        );

        INSERT INTO #stg_plantilla (fila, iso_pais, pais_id, nombre_seleccion, confederacion, grupo, nombre_jugador, fecha_nacimiento, posicion, club_origen, dorsal, fecha_convocatoria, error_desc)
        SELECT 
            ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
            r.iso_pais,
            p.pais_id,
            r.nombre_seleccion,
            r.confederacion,
            r.grupo,
            NULLIF(LTRIM(RTRIM(r.nombre_jugador)), ''),
            r.fecha_nacimiento,
            r.posicion,
            r.club_origen,
            r.dorsal,
            r.fecha_convocatoria,
            CASE 
                WHEN p.pais_id IS NULL THEN 'País no encontrado para ISO: ' + ISNULL(r.iso_pais, 'NULL')
                WHEN r.nombre_jugador IS NULL OR LTRIM(RTRIM(r.nombre_jugador)) = '' THEN 'Falta el nombre del jugador (obligatorio)'
                WHEN r.fecha_nacimiento IS NULL THEN 'Falta la fecha de nacimiento del jugador (obligatorio)'
                WHEN r.dorsal IS NULL THEN 'Falta el dorsal del jugador (obligatorio)'
                ELSE NULL 
            END
        FROM #raw_plantilla r
        LEFT JOIN torneo.pais p ON p.codigo_iso = r.iso_pais;

        -- 3) Grabar los errores de todos los registros inválidos juntos
        INSERT INTO importacion.importacion_error (importacion_id, detalle)
        SELECT @importacionId, CONCAT('Fila ', fila, ': ', error_desc)
        FROM #stg_plantilla
        WHERE error_desc IS NOT NULL;

        SET @errores = @@ROWCOUNT;

        -- 4) Limpiar el Staging para dejar solo los registros íntegros
        DELETE FROM #stg_plantilla WHERE error_desc IS NOT NULL;

        ;WITH deduplicados AS (
            SELECT ROW_NUMBER() OVER (PARTITION BY nombre_jugador, fecha_nacimiento ORDER BY fila DESC) AS rn
            FROM #stg_plantilla
        )
        DELETE FROM deduplicados WHERE rn > 1;

        -- 5) Bloque Transaccional: UPSERT en cascada (Selección -> Jugador -> Convocatoria) masivo
        BEGIN TRAN;

            -- 5.A) UPSERT SELECCIÓN
            UPDATE s
            SET s.nombre = stg.nombre_seleccion,
                s.confederacion = stg.confederacion,
                s.grupo = stg.grupo
            FROM torneo.seleccion s
            JOIN #stg_plantilla stg ON s.pais_id = stg.pais_id;

            INSERT INTO torneo.seleccion (pais_id, nombre, confederacion, grupo)
            SELECT DISTINCT stg.pais_id, stg.nombre_seleccion, stg.confederacion, stg.grupo
            FROM #stg_plantilla stg
            WHERE NOT EXISTS (
                SELECT 1 FROM torneo.seleccion s WHERE s.pais_id = stg.pais_id
            );

            -- 5.B) UPSERT JUGADOR
            UPDATE j
            SET j.posicion = stg.posicion,
                j.club_origen = stg.club_origen
            FROM torneo.jugador j
            JOIN #stg_plantilla stg ON j.nombre = stg.nombre_jugador AND j.fecha_nacimiento = stg.fecha_nacimiento;

            INSERT INTO torneo.jugador (nombre, fecha_nacimiento, posicion, club_origen)
            SELECT DISTINCT stg.nombre_jugador, stg.fecha_nacimiento, stg.posicion, stg.club_origen
            FROM #stg_plantilla stg
            WHERE NOT EXISTS (
                SELECT 1 FROM torneo.jugador j WHERE j.nombre = stg.nombre_jugador AND j.fecha_nacimiento = stg.fecha_nacimiento
            );

            -- 5.C) UPSERT CONVOCATORIA (Cruzando con los IDs reales generados)
            UPDATE c
            SET c.dorsal = stg.dorsal,
                c.fecha_convocatoria = stg.fecha_convocatoria
            FROM torneo.convocatoria c
            JOIN torneo.seleccion s ON c.seleccion_id = s.seleccion_id
            JOIN torneo.jugador j ON c.jugador_id = j.jugador_id
            JOIN #stg_plantilla stg 
              ON stg.pais_id = s.pais_id 
             AND stg.nombre_jugador = j.nombre 
             AND stg.fecha_nacimiento = j.fecha_nacimiento
            WHERE c.estado = 'VIGENTE';

            INSERT INTO torneo.convocatoria (seleccion_id, jugador_id, dorsal, fecha_convocatoria, estado)
            SELECT s.seleccion_id, j.jugador_id, stg.dorsal, stg.fecha_convocatoria, 'VIGENTE'
            FROM #stg_plantilla stg
            JOIN torneo.seleccion s ON s.pais_id = stg.pais_id
            JOIN torneo.jugador j ON j.nombre = stg.nombre_jugador AND j.fecha_nacimiento = stg.fecha_nacimiento
            WHERE NOT EXISTS (
                SELECT 1 FROM torneo.convocatoria c
                WHERE c.seleccion_id = s.seleccion_id 
                  AND c.jugador_id = j.jugador_id 
                  AND c.estado = 'VIGENTE'
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