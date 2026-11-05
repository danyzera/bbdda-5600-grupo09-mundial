/* ============================================================================ 
  Script      : sp_importar_paises_csv.sql   
  Objetivo    : Importar países desde archivo CSV utilizando Upsert.   
  ============================================================================ */
CREATE OR ALTER PROCEDURE importacion.sp_importar_paises_csv
    @archivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @importacionId INT;

    INSERT INTO importacion.importacion_log    
    (
        origen,
        tipo_fuente,
        archivo
    )
    VALUES    
    (
        'Importación Países',
        'CSV',
        @archivo
    );

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY

        IF OBJECT_ID('tempdb..#stg_pais') IS NOT NULL
            DROP TABLE #stg_pais;

        CREATE TABLE #stg_pais        
        (
            nombre         NVARCHAR(100),
            continente     NVARCHAR(50),
            codigo_iso     CHAR(3),
            huso_horario   VARCHAR(100),
            pbi_per_capita DECIMAL(12,2),
            pbi_anio       SMALLINT
        );

        DECLARE @sql NVARCHAR(MAX);

        SET @sql =
        '        BULK INSERT #stg_pais        
                 FROM ''' + @archivo + '''        
                 WITH        
                 (            
                     FIRSTROW = 2,            
                     FIELDTERMINATOR = '','',            
                     ROWTERMINATOR = ''0x0D0A'',            
                     CODEPAGE = ''65001''        
                 );        
        ';

        EXEC (@sql);

        PRINT '=== CONTENIDO STAGING ===';

        SELECT
            nombre,
            continente,
            codigo_iso,
            huso_horario,
            pbi_per_capita,
            pbi_anio
        FROM #stg_pais;

        DECLARE
            @nombre NVARCHAR(100),
            @continente NVARCHAR(50),
            @codigoIso CHAR(3),
            @husoHorario VARCHAR(100),
            @pbi DECIMAL(12,2),
            @anio SMALLINT;

        DECLARE c CURSOR LOCAL FAST_FORWARD
        FOR
        SELECT
            nombre,
            continente,
            codigo_iso,
            huso_horario,
            pbi_per_capita,
            pbi_anio
        FROM #stg_pais;

        OPEN c;

        FETCH NEXT FROM c INTO
            @nombre,
            @continente,
            @codigoIso,
            @husoHorario,
            @pbi,
            @anio;

        WHILE @@FETCH_STATUS = 0
        BEGIN

            BEGIN TRY

                DECLARE @paisId INT;
                
                -- Limpieza de la variable en cada iteración
                SET @paisId = NULL;

                SELECT @paisId = pais_id
                FROM torneo.pais
                WHERE codigo_iso = @codigoIso;

                IF @paisId IS NULL
                BEGIN

                    EXEC torneo.sp_pais_alta                        
                        @nombre = @nombre,
                        @continente = @continente,
                        @codigoIso = @codigoIso,
                        @husoHorario = @husoHorario,
                        @pbiPerCapita = @pbi,
                        @pbiAnio = @anio,
                        @paisId = @paisId OUTPUT;

                END
                ELSE
                BEGIN

                    EXEC torneo.sp_pais_modificacion                        
                        @paisId = @paisId,
                        @nombre = @nombre,
                        @continente = @continente,
                        @codigoIso = @codigoIso,
                        @husoHorario = @husoHorario,
                        @pbiPerCapita = @pbi,
                        @pbiAnio = @anio;

                END;

                UPDATE importacion.importacion_log
                SET
                    registros_leidos = registros_leidos + 1,
                    registros_ok = registros_ok + 1
                WHERE importacion_id = @importacionId;

            END TRY
            BEGIN CATCH

                INSERT INTO importacion.importacion_error                
                (
                    importacion_id,
                    detalle
                )
                VALUES                
                (
                    @importacionId,
                    ERROR_MESSAGE()
                );

                UPDATE importacion.importacion_log
                SET
                    registros_leidos = registros_leidos + 1,
                    registros_error = registros_error + 1
                WHERE importacion_id = @importacionId;

            END CATCH;

            FETCH NEXT FROM c INTO
                @nombre,
                @continente,
                @codigoIso,
                @husoHorario,
                @pbi,
                @anio;

        END;

        CLOSE c;
        DEALLOCATE c;

        DECLARE @Errores INT;

        SELECT @Errores = registros_error
        FROM importacion.importacion_log
        WHERE importacion_id = @importacionId;

        UPDATE importacion.importacion_log
        SET
            estado =
                CASE
                    WHEN @Errores = 0 THEN 'OK'
                    ELSE 'PARCIAL'
                END,
            fecha_fin = SYSDATETIME()
        WHERE importacion_id = @importacionId;

    END TRY
    BEGIN CATCH

        UPDATE importacion.importacion_log
        SET
            estado = 'ERROR',
            fecha_fin = SYSDATETIME()
        WHERE importacion_id = @importacionId;

        THROW;

    END CATCH;
END;
GO