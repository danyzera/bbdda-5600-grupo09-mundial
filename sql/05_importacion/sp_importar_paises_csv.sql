/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : sp_importar_paises_csv.sql
   Objetivo    : Importar países desde archivo CSV utilizando Set-Based UPSERT.
   ============================================================================ */
CREATE OR ALTER PROCEDURE importacion.sp_importar_paises_csv
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
    VALUES ('Importación Países', 'CSV', @archivo);

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY
        -- 1) Cargar CSV directo a una tabla cruda
        IF OBJECT_ID('tempdb..#raw_pais') IS NOT NULL DROP TABLE #raw_pais;
        CREATE TABLE #raw_pais (
            nombre         NVARCHAR(100),
            continente     NVARCHAR(50),
            codigo_iso     CHAR(3),
            huso_horario   VARCHAR(100),
            pbi_per_capita DECIMAL(12,2),
            pbi_anio       SMALLINT
        );

        SET @sql = 'BULK INSERT #raw_pais FROM ''' + REPLACE(@archivo, '''', '''''') + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0D0A'', CODEPAGE = ''65001'');';
        EXEC (@sql);

        SELECT @leidos = COUNT(*) FROM #raw_pais;

        -- 2) Volcar a Staging aplicando pre-validaciones
        IF OBJECT_ID('tempdb..#stg_pais') IS NOT NULL DROP TABLE #stg_pais;
        CREATE TABLE #stg_pais (
            fila           INT,
            nombre         NVARCHAR(100),
            continente     NVARCHAR(50),
            codigo_iso     CHAR(3),
            huso_horario   VARCHAR(100),
            pbi_per_capita DECIMAL(12,2),
            pbi_anio       SMALLINT,
            error_desc     NVARCHAR(200)
        );

        INSERT INTO #stg_pais (fila, nombre, continente, codigo_iso, huso_horario, pbi_per_capita, pbi_anio, error_desc)
        SELECT 
            ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
            NULLIF(LTRIM(RTRIM(nombre)), ''),
            NULLIF(LTRIM(RTRIM(continente)), ''),
            NULLIF(LTRIM(RTRIM(codigo_iso)), ''),
            NULLIF(LTRIM(RTRIM(huso_horario)), ''),
            pbi_per_capita,
            pbi_anio,
            CASE 
                WHEN codigo_iso IS NULL OR LTRIM(RTRIM(codigo_iso)) = '' THEN 'Falta código ISO (obligatorio)'
                WHEN nombre IS NULL OR LTRIM(RTRIM(nombre)) = '' THEN 'Falta nombre del país (obligatorio)'
                ELSE NULL 
            END
        FROM #raw_pais;

        -- 3) Grabar los errores de todos los registros inválidos juntos
        INSERT INTO importacion.importacion_error (importacion_id, detalle)
        SELECT @importacionId, CONCAT('Fila ', fila, ': ', error_desc)
        FROM #stg_pais
        WHERE error_desc IS NOT NULL;

        SET @errores = @@ROWCOUNT;

        -- 4) Limpiar el Staging para dejar solo los registros íntegros
        DELETE FROM #stg_pais WHERE error_desc IS NOT NULL;

        -- (Opcional pero recomendado) Deduplicación defensiva por si el CSV trae el mismo ISO dos veces
        ;WITH deduplicados AS (
            SELECT ROW_NUMBER() OVER (PARTITION BY codigo_iso ORDER BY fila DESC) AS rn
            FROM #stg_pais
        )
        DELETE FROM deduplicados WHERE rn > 1;

        -- 5) Bloque Transaccional: UPSERT (Modificación y Alta) masivo sin cursores
        BEGIN TRAN;

            -- MODIFICACIÓN (Actualiza el país si el código ISO ya existe)
            UPDATE p
            SET p.nombre         = s.nombre,
                p.continente     = s.continente,
                p.huso_horario   = s.huso_horario,
                p.pbi_per_capita = s.pbi_per_capita,
                p.pbi_anio       = s.pbi_anio
            FROM torneo.pais p
            JOIN #stg_pais s ON p.codigo_iso = s.codigo_iso;

            -- ALTA (Inserta el país si el código ISO no existe)
            INSERT INTO torneo.pais (nombre, continente, codigo_iso, huso_horario, pbi_per_capita, pbi_anio)
            SELECT s.nombre, s.continente, s.codigo_iso, s.huso_horario, s.pbi_per_capita, s.pbi_anio
            FROM #stg_pais s
            WHERE NOT EXISTS (
                SELECT 1 FROM torneo.pais p
                WHERE p.codigo_iso = s.codigo_iso
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