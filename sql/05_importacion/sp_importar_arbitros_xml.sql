/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : sp_importar_arbitros_xml.sql
   Objetivo    : Importar árbitros desde archivo XML.
   ============================================================================ */

CREATE OR ALTER PROCEDURE importacion.sp_importar_arbitros_xml
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
        'Importación Arbitros',
        'XML',
        @archivo
    );

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY

        DECLARE @xml XML;
        DECLARE @sqlXML NVARCHAR(MAX);

        IF OBJECT_ID('tempdb..#xml_tmp') IS NOT NULL
            DROP TABLE #xml_tmp;

        CREATE TABLE #xml_tmp
        (
            contenido XML
        );

        SET @sqlXML =
        '
        INSERT INTO #xml_tmp
        SELECT CAST(BulkColumn AS XML)
        FROM OPENROWSET
        (
            BULK ''' + @archivo + ''',
            SINGLE_BLOB
        ) AS X;
        ';

        EXEC (@sqlXML);

        SELECT @xml = contenido
        FROM #xml_tmp;

        IF OBJECT_ID('tempdb..#stg_arbitro') IS NOT NULL
            DROP TABLE #stg_arbitro;

        CREATE TABLE #stg_arbitro
        (
            nombre      NVARCHAR(150),
            pais_iso    CHAR(3),
            categoria   VARCHAR(15)
        );

        INSERT INTO #stg_arbitro
        (
            nombre,
            pais_iso,
            categoria
        )
        SELECT
            T.N.value('(nombre/text())[1]', 'NVARCHAR(150)'),
            T.N.value('(pais_iso/text())[1]', 'CHAR(3)'),
            T.N.value('(categoria/text())[1]', 'VARCHAR(15)')
        FROM @xml.nodes('/arbitros/arbitro') T(N);

        PRINT '=== CONTENIDO STAGING ===';

        SELECT *
        FROM #stg_arbitro;

        DECLARE
            @nombre NVARCHAR(150),
            @paisIso CHAR(3),
            @categoria VARCHAR(15);

        DECLARE c_arbitro CURSOR LOCAL FAST_FORWARD
        FOR
        SELECT
            nombre,
            pais_iso,
            categoria
        FROM #stg_arbitro;

        OPEN c_arbitro;

        FETCH NEXT FROM c_arbitro
        INTO
            @nombre,
            @paisIso,
            @categoria;

        WHILE @@FETCH_STATUS = 0
        BEGIN

            BEGIN TRY

                DECLARE
                    @paisId INT = NULL,
                    @arbitroId INT = NULL;

                SELECT
                    @paisId = pais_id
                FROM torneo.pais
                WHERE codigo_iso = @paisIso;

                -- Validación de país existente
                IF @paisId IS NULL
                BEGIN

                    INSERT INTO importacion.importacion_error
                    (
                        importacion_id,
                        detalle
                    )
                    VALUES
                    (
                        @importacionId,
                        'No existe un país con código ISO: ' + ISNULL(@paisIso,'NULL')
                    );

                    UPDATE importacion.importacion_log
                    SET
                        registros_leidos = registros_leidos + 1,
                        registros_error = registros_error + 1
                    WHERE importacion_id = @importacionId;

                    FETCH NEXT FROM c_arbitro
                    INTO
                        @nombre,
                        @paisIso,
                        @categoria;

                    CONTINUE;
                END;

                SELECT
                    @arbitroId = arbitro_id
                FROM arbitraje.arbitro
                WHERE nombre = @nombre
                  AND pais_id = @paisId;

                IF @arbitroId IS NULL
                BEGIN

                    EXEC arbitraje.sp_arbitro_alta
                        @nombre = @nombre,
                        @paisId = @paisId,
                        @categoria = @categoria,
                        @arbitroId = @arbitroId OUTPUT;

                END
                ELSE
                BEGIN

                    EXEC arbitraje.sp_arbitro_modificacion
                        @arbitroId = @arbitroId,
                        @nombre = @nombre,
                        @paisId = @paisId,
                        @categoria = @categoria;

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

            FETCH NEXT FROM c_arbitro
            INTO
                @nombre,
                @paisIso,
                @categoria;

        END;

        CLOSE c_arbitro;
        DEALLOCATE c_arbitro;

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