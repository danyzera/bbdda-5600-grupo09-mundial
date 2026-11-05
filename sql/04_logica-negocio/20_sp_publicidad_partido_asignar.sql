/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 22/10/2026
   Script      : 20_sp_publicidad_partido_asignar.sql
   Objetivo    : Asigna inteligentemente 4 piezas publicitarias a un partido.
                 Utiliza un algoritmo de scoring basado en:
                 1. País origen de las selecciones (+1000 pts).
                 2. Prime Time (19 a 23 hs) en el mercado destino evaluado 
                    dinámicamente convirtiendo el UTC al huso del país (+500 pts).
                 3. Poder adquisitivo (PBI per cápita) como factor de desempate.
                 Delega el guardado al SP de Alta de publicidad.
   Código de error del SP: 53301
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER PROCEDURE publicidad.sp_publicidad_partido_asignar
    @idPartido INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @errores        NVARCHAR(MAX) = N'', 
            @saltoDeLinea   NCHAR(2) = CHAR(13) + CHAR(10);

    DECLARE @estadoPartido  VARCHAR(12),
            @fase           VARCHAR(15),
            @fechaUtc       DATETIME2(0),
            @paisLocal      INT,
            @paisVisitante  INT;

    -- Tabla en memoria para guardar las 4 piezas rankeadas
    DECLARE @PiezasRankeadas TABLE (
        orden       INT IDENTITY(1,1),
        pieza_id    INT
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Obtener datos del partido con bloqueo para evitar asignaciones concurrentes
        SELECT  @estadoPartido = p.estado,
                @fase          = p.fase,
                @fechaUtc      = p.fecha_hora_utc,
                @paisLocal     = sl.pais_id,
                @paisVisitante = sv.pais_id
        FROM torneo.partido p WITH (UPDLOCK)
        JOIN torneo.seleccion sl ON p.seleccion_local_id = sl.seleccion_id
        JOIN torneo.seleccion sv ON p.seleccion_visitante_id = sv.seleccion_id
        WHERE p.partido_id = @idPartido;

        -- Validaciones precondicionales
        IF @estadoPartido IS NULL
            SET @errores += N'- El partido especificado no existe.' + @saltoDeLinea;
        ELSE IF @estadoPartido <> 'PROGRAMADO'
            SET @errores += N'- Solo se puede asignar publicidad a partidos en estado PROGRAMADO.' + @saltoDeLinea;

        IF EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE partido_id = @idPartido)
            SET @errores += N'- Este partido ya tiene publicidad asignada.' + @saltoDeLinea;

        IF @errores <> N''
        BEGIN
            SET @errores = N'No se pudo procesar la asignación de publicidad:' + @saltoDeLinea + @errores;
            THROW 53301, @errores, 1;
        END

        -- 2. Algoritmo de Priorización (Scoring)
        -- Evaluamos TODAS las piezas activas en la fecha del partido y nos quedamos con las 4 mejores.
        INSERT INTO @PiezasRankeadas (pieza_id)
        SELECT TOP 4 
            pz.pieza_id
        FROM publicidad.pieza_publicitaria pz
        JOIN publicidad.campania c ON pz.campania_id = c.campania_id
        JOIN publicidad.pieza_pais pp ON pz.pieza_id = pp.pieza_id
        JOIN torneo.pais pa ON pp.pais_id = pa.pais_id
        WHERE CAST(@fechaUtc AS DATE) BETWEEN c.fecha_inicio AND c.fecha_fin
        GROUP BY pz.pieza_id
        ORDER BY 
            -- Se evalúa la pieza buscando su MEJOR mercado
            MAX(
                -- Criterio 1: Dirigido a los países que juegan (+1000)
                CASE WHEN pa.pais_id IN (@paisLocal, @paisVisitante) THEN 1000 ELSE 0 END 
                +
                -- Criterio 2: Prime Time (19 a 23 hs local del mercado) evaluado con AT TIME ZONE (+500)
                CASE WHEN DATEPART(HOUR, @fechaUtc AT TIME ZONE 'UTC' AT TIME ZONE pa.huso_horario) BETWEEN 19 AND 23 THEN 500 ELSE 0 END 
                +
                -- Criterio 3: PBI per cápita para los mercados más ricos
                ISNULL(pa.pbi_per_capita, 0) / 100.0
            ) DESC;

        -- Verificar que haya suficientes publicidades en el sistema
        IF (SELECT COUNT(*) FROM @PiezasRankeadas) < 4
        BEGIN
            SET @errores = N'No se pudo asignar publicidad: No hay al menos 4 piezas publicitarias con campañas activas en la fecha del partido.';
            THROW 53301, @errores, 1;
        END

        -- 3. Asignación a los 4 espacios mediante el SP de Alta
        DECLARE @i INT = 1;
        DECLARE @piezaIdActual INT, @tarifaIdActual INT, @importeActual DECIMAL(12,2), @monedaActual CHAR(3), @publicidadIdOutput INT;

        WHILE @i <= 4
        BEGIN
            SELECT @piezaIdActual = pieza_id FROM @PiezasRankeadas WHERE orden = @i;

            -- Buscar la tarifa vigente para esa fase y ese espacio publicitario
            SELECT  @tarifaIdActual = tarifa_id, 
                    @importeActual = importe, 
                    @monedaActual = moneda
            FROM publicidad.tarifa_publicidad
            WHERE fase = @fase AND espacio = @i;

            IF @tarifaIdActual IS NULL
            BEGIN
                SET @errores = N'Falta configurar la tarifa publicitaria para la fase ' + @fase + N' en el espacio ' + CAST(@i AS NVARCHAR);
                THROW 53301, @errores, 1;
            END

            EXEC publicidad.sp_publicidad_partido_alta
                @partidoId         = @idPartido,
                @piezaId           = @piezaIdActual,
                @tarifaId          = @tarifaIdActual,
                @momentoEmision    = @fechaUtc,
                @espacio           = @i,
                @importeFacturado  = @importeActual,
                @moneda            = @monedaActual,
                @publicidadId      = @publicidadIdOutput OUTPUT;

            SET @i = @i + 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO