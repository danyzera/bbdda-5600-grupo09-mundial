/*
    Universidad Nacional de La Matanza - Bases de Datos Aplicada (3641)
    Grupo: <completar integrantes>        Fecha: <completar>
    Objetivo: Importar las sedes del Mundial 2026 desde sedes_wikipedia.csv (scraping de Wikipedia,
              tabla "Venues" del articulo "2026 FIFA World Cup").
      - Upsert por nombre FIFA del estadio (el que va entre parentesis, ej. "Mexico City Stadium"),
        el mismo criterio que la importacion desde JSON, asi no se duplican sedes.
      - Pais, huso horario y coordenadas no estan en la fuente: se completan con una tabla de mapeo
        por ciudad sede (coordenadas aproximadas, verificar).
      - Importacion parcial: filas invalidas -> importacion_error; el resto se carga.
      - Usa torneo.sp_sede_alta / torneo.sp_sede_modificacion (Entrega 5). Sin cursor.
      - SQL dinamico solo para BULK INSERT (la ruta del archivo debe ser literal).
*/
USE MundialDB;
GO

CREATE OR ALTER PROCEDURE importacion.sp_importar_sedes_wikipedia
    @rutaCsv NVARCHAR(260) = N'C:\Temp\sedes_wikipedia.csv'
AS
BEGIN
    SET NOCOUNT ON;

    -- Nombres de pais tal como estan en torneo.pais (ajustar si difieren)
    DECLARE @paisUSA NVARCHAR(100) = N'Estados Unidos',
            @paisMEX NVARCHAR(100) = N'Mexico',
            @paisCAN NVARCHAR(100) = N'Canada';

    DECLARE @importacion_id INT, @sql NVARCHAR(MAX);
    DECLARE @total_leidos INT = 0, @ok INT = 0, @err INT = 0;

    INSERT INTO importacion.importacion_log (origen, tipo_fuente, archivo, fecha_inicio, estado)
    VALUES (N'Wikipedia - 2026 FIFA World Cup (venues)', 'CSV', @rutaCsv, SYSDATETIME(), 'EN_CURSO');
    SET @importacion_id = SCOPE_IDENTITY();

    BEGIN TRY
        -- 1. Staging: el CSV tiene campos entre comillas con comas ("Dallas (Arlington, Texas)")
        CREATE TABLE #stg (
            ciudad_raw    NVARCHAR(200),
            estadio_raw   NVARCHAR(300),
            partidos_raw  NVARCHAR(200),
            capacidad_raw NVARCHAR(50)
        );

        SET @sql = N'BULK INSERT #stg FROM ''' + REPLACE(@rutaCsv, '''', '''''')
                 + N''' WITH (FORMAT = ''CSV'', FIELDQUOTE = ''"'', FIRSTROW = 2, '
                 + N'ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
        EXEC sp_executesql @sql;

        -- 2. Mapeo por ciudad sede (dato que la fuente no trae)
        CREATE TABLE #mapa (
            ciudad NVARCHAR(100) PRIMARY KEY, pais_nombre NVARCHAR(100),
            huso VARCHAR(100), latitud DECIMAL(9,6), longitud DECIMAL(9,6)
        );
        INSERT INTO #mapa (ciudad, pais_nombre, huso, latitud, longitud) VALUES
            (N'Mexico City',            @paisMEX, 'Central Standard Time (Mexico)',  19.302900,  -99.150500),
            (N'Monterrey',              @paisMEX, 'Central Standard Time (Mexico)',  25.669400, -100.244600),
            (N'Guadalajara',            @paisMEX, 'Central Standard Time (Mexico)',  20.681700, -103.462700),
            (N'Toronto',                @paisCAN, 'Eastern Standard Time',           43.633200,  -79.418600),
            (N'Vancouver',              @paisCAN, 'Pacific Standard Time',           49.276800, -123.112000),
            (N'New York/New Jersey',    @paisUSA, 'Eastern Standard Time',           40.813500,  -74.074500),
            (N'Philadelphia',           @paisUSA, 'Eastern Standard Time',           39.900800,  -75.167500),
            (N'Atlanta',                @paisUSA, 'Eastern Standard Time',           33.755400,  -84.401000),
            (N'Miami',                  @paisUSA, 'Eastern Standard Time',           25.958000,  -80.238900),
            (N'Boston',                 @paisUSA, 'Eastern Standard Time',           42.090900,  -71.264300),
            (N'Dallas',                 @paisUSA, 'Central Standard Time',           32.747300,  -97.094500),
            (N'Houston',                @paisUSA, 'Central Standard Time',           29.684700,  -95.410700),
            (N'Kansas City',            @paisUSA, 'Central Standard Time',           39.048900,  -94.483900),
            (N'Los Angeles',            @paisUSA, 'Pacific Standard Time',           33.953500, -118.339200),
            (N'San Francisco Bay Area', @paisUSA, 'Pacific Standard Time',           37.403000, -121.970000),
            (N'Seattle',                @paisUSA, 'Pacific Standard Time',           47.595200, -122.331600);

        -- 3. Parseo set-based
        --    Estadio: "Estadio Azteca† (Mexico City Stadium)" -> clave = texto entre parentesis
        --    Ciudad:  "Dallas (Arlington, Texas)"             -> ciudad sede = texto antes del parentesis
        CREATE TABLE #import (
            id INT IDENTITY(1,1) PRIMARY KEY,
            fila INT, estadio NVARCHAR(100), ciudad NVARCHAR(100), capacidad INT,
            pais_id INT, huso VARCHAR(100), latitud DECIMAL(9,6), longitud DECIMAL(9,6)
        );

        ;WITH p AS (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS fila,   -- orden de lectura del archivo
                   LTRIM(RTRIM(REPLACE(REPLACE(s.estadio_raw, NCHAR(8224), N''), NCHAR(8225), N''))) AS est,
                   LTRIM(RTRIM(CASE WHEN CHARINDEX('(', s.ciudad_raw) > 0
                                    THEN LEFT(s.ciudad_raw, CHARINDEX('(', s.ciudad_raw) - 1)
                                    ELSE s.ciudad_raw END)) AS ciudad,
                   TRY_CAST(REPLACE(REPLACE(s.capacidad_raw, CHAR(13), ''), ',', '') AS DECIMAL(12,0)) AS capacidad
            FROM #stg s
        )
        INSERT INTO #import (fila, estadio, ciudad, capacidad, pais_id, huso, latitud, longitud)
        SELECT p.fila,
               CASE WHEN CHARINDEX('(', p.est) > 0 AND RIGHT(p.est, 1) = ')'
                    THEN LTRIM(RTRIM(SUBSTRING(p.est, CHARINDEX('(', p.est) + 1,
                                               LEN(p.est) - CHARINDEX('(', p.est) - 1))) END,
               p.ciudad, p.capacidad, pa.pais_id, m.huso, m.latitud, m.longitud
        FROM p
        LEFT JOIN #mapa m     ON m.ciudad = p.ciudad
        LEFT JOIN torneo.pais pa ON pa.nombre = m.pais_nombre;
        SET @total_leidos = @@ROWCOUNT;

        -- 4. Filas invalidas -> un solo mensaje por fila con todos los problemas
        INSERT INTO importacion.importacion_error (importacion_id, fila, detalle)
        SELECT @importacion_id, i.fila,
               CONCAT_WS(' | ',
                   CASE WHEN i.estadio   IS NULL THEN 'No se pudo obtener el nombre FIFA del estadio (falta texto entre parentesis)' END,
                   CASE WHEN i.capacidad IS NULL THEN 'Capacidad vacia o no numerica' END,
                   CASE WHEN i.huso      IS NULL THEN 'Ciudad sin mapeo de pais/huso: [' + ISNULL(i.ciudad, 'NULL') + ']' END,
                   CASE WHEN i.huso IS NOT NULL AND i.pais_id IS NULL THEN 'Pais del mapeo no encontrado en torneo.pais' END)
        FROM #import i
        WHERE i.estadio IS NULL OR i.capacidad IS NULL OR i.huso IS NULL OR i.pais_id IS NULL;
        SET @err = @@ROWCOUNT;

        DELETE FROM #import
        WHERE estadio IS NULL OR capacidad IS NULL OR huso IS NULL OR pais_id IS NULL;

        -- 5. Upsert fila a fila a traves de los SP de la Entrega 5
        DECLARE @i INT = 0, @fila INT, @paisId INT, @estadio NVARCHAR(100), @ciudad NVARCHAR(100),
                @cap INT, @huso VARCHAR(100), @lat DECIMAL(9,6), @lon DECIMAL(9,6), @sedeId INT;

        WHILE 1 = 1
        BEGIN
            SELECT TOP (1) @i = id, @fila = fila, @paisId = pais_id, @estadio = estadio, @ciudad = ciudad,
                           @cap = capacidad, @huso = huso, @lat = latitud, @lon = longitud
            FROM #import WHERE id > @i ORDER BY id;
            IF @@ROWCOUNT = 0 BREAK;

            BEGIN TRY
                SET @sedeId = NULL;
                -- ASUNCION: columnas sede_id y nombre_estadio en torneo.sede
                SELECT @sedeId = sede_id FROM torneo.sede WHERE nombre_estadio = @estadio;

                IF @sedeId IS NULL
                    EXEC torneo.sp_sede_alta
                         @paisId = @paisId, @nombreEstadio = @estadio, @ciudad = @ciudad,
                         @capacidad = @cap, @husoHorario = @huso,
                         @latitud = @lat, @longitud = @lon, @sedeId = @sedeId OUTPUT;
                ELSE
                    -- ASUNCION: nombre y parametros de tu SP de modificacion; ajustar si difieren
                    /*EXEC torneo.sp_sede_modificacion
                         @sedeId = @sedeId, @paisId = @paisId, @nombreEstadio = @estadio, @ciudad = @ciudad,
                         @capacidad = @cap, @husoHorario = @huso, @latitud = @lat, @longitud = @lon;*/

                SET @ok += 1;
            END TRY
            BEGIN CATCH
                INSERT INTO importacion.importacion_error (importacion_id, fila, detalle)
                VALUES (@importacion_id, @fila, N'Estadio [' + @estadio + N']: ' + ERROR_MESSAGE());
                SET @err += 1;
            END CATCH;
        END;

        UPDATE importacion.importacion_log
        SET fecha_fin = SYSDATETIME(),
            estado = CASE WHEN @ok = 0 THEN 'ERROR' WHEN @err > 0 THEN 'PARCIAL' ELSE 'OK' END,
            registros_leidos = @total_leidos, registros_ok = @ok, registros_error = @err
        WHERE importacion_id = @importacion_id;

        SELECT * FROM importacion.importacion_log   WHERE importacion_id = @importacion_id;
        SELECT * FROM importacion.importacion_error WHERE importacion_id = @importacion_id;
    END TRY
    BEGIN CATCH
        UPDATE importacion.importacion_log
        SET fecha_fin = SYSDATETIME(), estado = 'ERROR',
            registros_leidos = @total_leidos, registros_ok = @ok, registros_error = @err
        WHERE importacion_id = @importacion_id;
        THROW;
    END CATCH;
END;
GO

/* Prueba: correrlo dos veces; la segunda debe actualizar (no duplicar) -> 16 sedes en total
DELETE FROM torneo.sede;
DELETE FROM torneo.pais;
DELETE FROM arbitraje.arbitro;
   EXEC importacion.sp_importar_sedes_wikipedia @rutaCsv = N'C:\Temp\sedes_wikipedia.csv';
   SELECT COUNT(*) FROM torneo.sede;
    SELECT * FROM torneo.sede;
*/