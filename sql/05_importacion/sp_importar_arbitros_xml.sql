/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : sp_importar_arbitros_xml.sql
   ============================================================================ */

CREATE OR ALTER PROCEDURE importacion.sp_importar_arbitros_xml
    @archivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @importacionId INT,
            @xml           XML,
            @sql           NVARCHAR(MAX),
            @leidos        INT,
            @errores       INT;

    INSERT INTO importacion.importacion_log (origen, tipo_fuente, archivo)
    VALUES ('Importación Arbitros', 'XML', @archivo);

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY

        -- 1) Leer el XML directo a una variable
        SET @sql = N'SELECT @x = CAST(BulkColumn AS XML)
                     FROM OPENROWSET(BULK ''' + REPLACE(@archivo, '''', '''''') + N''', SINGLE_BLOB) AS X;';

        EXEC sys.sp_executesql @sql, N'@x XML OUTPUT', @x = @xml OUTPUT;

        -- 2) Staging
        CREATE TABLE #stg_arbitro (
            fila      INT           NOT NULL,
            nombre    NVARCHAR(150) NULL,
            pais_iso  CHAR(3)       NULL,
            categoria VARCHAR(15)   NULL,
            pais_id   INT           NULL
        );

        INSERT INTO #stg_arbitro (fila, nombre, pais_iso, categoria, pais_id)
        SELECT
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS fila, -- FIX AQUÍ
            NULLIF(LTRIM(RTRIM(X.nombre)), ''),
            X.pais_iso,
            X.categoria,
            p.pais_id
        FROM (
            SELECT
                T.N.value('(nombre/text())[1]',    'NVARCHAR(150)')       AS nombre,
                T.N.value('(pais_iso/text())[1]',  'CHAR(3)')             AS pais_iso,
                T.N.value('(categoria/text())[1]', 'VARCHAR(15)')         AS categoria
            FROM @xml.nodes('/arbitros/arbitro') T(N)
        ) X
        LEFT JOIN torneo.pais p
               ON p.codigo_iso = X.pais_iso;

        SELECT @leidos = COUNT(*) FROM #stg_arbitro;

        -- 3) Errores de validación: todos juntos, un solo INSERT
        INSERT INTO importacion.importacion_error (importacion_id, detalle)
        SELECT
            @importacionId,
            CASE
                WHEN nombre IS NULL
                    THEN CONCAT('Fila ', fila, ': nombre vacío')
                ELSE CONCAT('Fila ', fila, ' (', nombre, '): no existe un país con código ISO: ',
                            ISNULL(pais_iso, 'NULL'))
            END
        FROM #stg_arbitro
        WHERE nombre IS NULL
           OR pais_id IS NULL;

        SET @errores = @@ROWCOUNT;

        DELETE FROM #stg_arbitro
        WHERE nombre IS NULL
           OR pais_id IS NULL;

        -- 4) Si el archivo repite un árbitro, queda la última aparición
        ;WITH d AS
        (
            SELECT ROW_NUMBER() OVER (PARTITION BY nombre, pais_id ORDER BY fila DESC) AS rn
            FROM #stg_arbitro
        )
        DELETE FROM d WHERE rn > 1;

        -- 5) Alta / modificación en bloque, dentro de una transacción
        BEGIN TRAN;

            UPDATE a
            SET    a.categoria = s.categoria
            FROM   arbitraje.arbitro a
            JOIN   #stg_arbitro s
                   ON s.nombre  = a.nombre
                  AND s.pais_id = a.pais_id;

            INSERT INTO arbitraje.arbitro (nombre, pais_id, categoria)
            SELECT s.nombre, s.pais_id, s.categoria
            FROM   #stg_arbitro s
            WHERE  NOT EXISTS (SELECT 1
                               FROM   arbitraje.arbitro a
                               WHERE  a.nombre  = s.nombre
                                 AND  a.pais_id = s.pais_id);

        COMMIT;

        -- 6) Un único UPDATE final al log
        UPDATE importacion.importacion_log
        SET registros_leidos = @leidos,
            registros_ok     = @leidos - @errores,
            registros_error  = @errores,
            estado           = CASE WHEN @errores = 0 THEN 'OK' ELSE 'PARCIAL' END,
            fecha_fin        = SYSDATETIME()
        WHERE importacion_id = @importacionId;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK;

        UPDATE importacion.importacion_log
        SET estado    = 'ERROR',
            fecha_fin = SYSDATETIME()
        WHERE importacion_id = @importacionId;

        THROW;

    END CATCH;
END;
GO