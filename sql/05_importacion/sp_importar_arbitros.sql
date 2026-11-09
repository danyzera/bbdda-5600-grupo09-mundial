USE MundialDB;
GO

CREATE OR ALTER PROCEDURE importacion.sp_importar_arbitros
    @archivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @importacion_id INT;
    DECLARE @fecha_inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @total_leidos INT = 0, @registros_ok INT = 0;

    -- Staging igual a tu CSV referees.csv
    CREATE TABLE #StagingArbitro (
        key_id VARCHAR(MAX),
        referee_id VARCHAR(MAX),
        family_name VARCHAR(MAX),
        given_name VARCHAR(MAX),
        female VARCHAR(MAX),
        country_name VARCHAR(MAX),
        confederation_id VARCHAR(MAX),
        confederation_name VARCHAR(MAX),
        confederation_code VARCHAR(MAX),
        referee_wikipedia_link VARCHAR(MAX)
    );

    INSERT INTO importacion.importacion_log (origen, tipo_fuente, archivo, fecha_inicio, estado)
    VALUES ('Dataset Arbitros Github', 'CSV', @archivo, @fecha_inicio, 'EN_CURSO');
    SET @importacion_id = SCOPE_IDENTITY();

    BEGIN TRY
        -- 1. BULK que ya te funciona (el que viste con SINGLE_CLOB)
        DECLARE @sql NVARCHAR(MAX) = N'BULK INSERT #StagingArbitro FROM ''' + REPLACE(@archivo,'''','''''') + N''' WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''\n'', CODEPAGE=''65001'', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @total_leidos = @@ROWCOUNT;

        -- 2. INSERT MASIVO DE ARBITROS - SET BASED, SIN CURSOR
        -- Asume que torneo.pais YA está cargado
        INSERT INTO arbitraje.arbitro (nombre, pais_id, categoria)
        SELECT DISTINCT
            LTRIM(RTRIM(ISNULL(s.given_name,'') + ' ' + ISNULL(s.family_name,''))),
            p.pais_id,
            'FIFA'
        FROM #StagingArbitro s
        JOIN torneo.pais p ON p.nombre = LTRIM(RTRIM(s.country_name))
        WHERE LTRIM(RTRIM(ISNULL(s.given_name,'') + ' ' + ISNULL(s.family_name,''))) <> ''
          AND NOT EXISTS (
              SELECT 1 
              FROM arbitraje.arbitro a 
              WHERE a.nombre = LTRIM(RTRIM(ISNULL(s.given_name,'') + ' ' + ISNULL(s.family_name,'')))
                AND a.pais_id = p.pais_id
          );

        SET @registros_ok = @@ROWCOUNT;

        -- 3. Errores: paises del CSV que no están en torneo.pais
        INSERT INTO importacion.importacion_error (importacion_id, fila, detalle)
        SELECT @importacion_id, 0, 'Pais no encontrado en torneo.pais: [' + ISNULL(s.country_name,'NULL') + '] para arbitro ' + ISNULL(s.given_name,'') + ' ' + ISNULL(s.family_name,'')
        FROM #StagingArbitro s
        WHERE NOT EXISTS (SELECT 1 FROM torneo.pais p WHERE p.nombre = LTRIM(RTRIM(s.country_name)));

        UPDATE importacion.importacion_log
        SET fecha_fin = SYSDATETIME(),
            estado = CASE WHEN @registros_ok > 0 THEN 'OK' ELSE 'PARCIAL' END,
            registros_leidos = @total_leidos,
            registros_ok = @registros_ok,
            registros_error = @total_leidos - @registros_ok
        WHERE importacion_id = @importacion_id;

    END TRY
    BEGIN CATCH
        UPDATE importacion.importacion_log
        SET fecha_fin = SYSDATETIME(), estado = 'ERROR'
        WHERE importacion_id = @importacion_id;
        THROW;
    END CATCH;
END;
GO
EXEC master.dbo.xp_fileexist 'C:\Temp\referees.csv';
EXEC importacion.sp_importar_arbitros @archivo = 'C:\Temp\referees.csv';
SELECT * FROM torneo.pais;
SELECT COUNT(*) FROM arbitraje.arbitro;

-- Revisa el resumen general de la importación (registros leídos, OK y con error)
SELECT * FROM importacion.importacion_log;

-- Revisa si hubo filas con errores específicos y su detalle
SELECT * FROM importacion.importacion_error;

-- Revisa los árbitros ya cargados en la tabla definitiva
SELECT * FROM arbitraje.arbitro;