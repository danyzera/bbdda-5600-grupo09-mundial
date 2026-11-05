/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 22/10/2026
   Script      : 16_sp_cambio_registrar.sql
   Objetivo    : Registrar una sustitución durante un partido. Valida que el 
                 jugador saliente esté en cancha, el entrante sea suplente, y 
                 controla los límites reglamentarios de ventanas y cambios.
   Código de error del SP: 53104, en concordancia con la nomenclatura.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER PROCEDURE torneo.sp_cambio_registrar
    @idPartido        INT,
    @idSeleccion      INT,
    @idJugadorSale    INT,
    @idJugadorEntra   INT,
    @minuto           SMALLINT,
    @ventana          TINYINT,
    @motivo           VARCHAR(10),
    @idCambio         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @errores                NVARCHAR(MAX) = N'', 
            @saltoDeLinea           NCHAR(2) = CHAR(13) + CHAR(10);
            
    DECLARE @estadoPartido          VARCHAR(12),
            @localId                INT,
            @visitanteId            INT,
            @esSuplementario        BIT = 0;
            
    -- Variables para control de límites reglamentarios
    DECLARE @maxCambiosNormal       INT,
            @maxVentanasNormal      INT,
            @maxCambiosSup          INT,
            @maxVentanasSup         INT;
            
    DECLARE @cambiosRealizados      INT,
            @ventanasUsadas         INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Obtener estado del partido y selecciones (bloqueando el registro por concurrencia)
        SELECT  @estadoPartido = estado,
                @localId = seleccion_local_id,
                @visitanteId = seleccion_visitante_id
        FROM torneo.partido WITH (UPDLOCK)
        WHERE partido_id = @idPartido;

        IF @estadoPartido IS NULL
            SET @errores += N'- El partido no existe.' + @saltoDeLinea;
        ELSE IF @estadoPartido <> 'EN_CURSO'
            SET @errores += N'- Las sustituciones solo pueden registrarse en partidos EN_CURSO.' + @saltoDeLinea;

        IF @estadoPartido IS NOT NULL AND @idSeleccion NOT IN (@localId, @visitanteId)
            SET @errores += N'- La selección indicada no participa de este partido.' + @saltoDeLinea;

        IF @estadoPartido = 'EN_CURSO' AND @idSeleccion IN (@localId, @visitanteId)
        BEGIN
            -- 2. Validaciones sobre el jugador que ENTRA (debe ser suplente convocado y no haber ingresado antes)
            IF NOT EXISTS (
                SELECT 1 
                FROM torneo.alineacion_detalle ad
                JOIN torneo.formacion_partido fp ON fp.formacion_id = ad.formacion_id
                WHERE fp.partido_id = @idPartido 
                  AND fp.seleccion_id = @idSeleccion
                  AND ad.jugador_id = @idJugadorEntra 
                  AND ad.es_titular = 0
            )
                SET @errores += N'- El jugador que entra no pertenece al banco de suplentes de la formación.' + @saltoDeLinea;

            IF EXISTS (
                SELECT 1 
                FROM torneo.cambio 
                WHERE partido_id = @idPartido AND (jugador_entra_id = @idJugadorEntra OR jugador_sale_id = @idJugadorEntra)
            )
                SET @errores += N'- El jugador que entra ya ha participado en una sustitución previa.' + @saltoDeLinea;

            -- 3. Validaciones sobre el jugador que SALE (debe estar físicamente en cancha en ese minuto)
            IF NOT EXISTS (
                SELECT 1
                FROM torneo.fn_obtener_alineacion_actual(@idPartido, @idSeleccion, @minuto) 
                WHERE idJugador = @idJugadorSale
            )
                SET @errores += N'- El jugador que sale no se encontraba físicamente en la cancha en ese minuto.' + @saltoDeLinea;

            -- 4. Validaciones de Reglamento (Límites de cambios y ventanas)
            -- Se obtienen los parámetros o se asumen los estándares de la FIFA si no están cargados
            SELECT @maxCambiosNormal = valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_NORMAL';
            SELECT @maxVentanasNormal = valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_VENTANAS_NORMAL';
            SELECT @maxCambiosSup = valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_SUPLEMENTARIO';
            SELECT @maxVentanasSup = valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_VENTANAS_SUPLEMENTARIO';
            
            SET @maxCambiosNormal = ISNULL(@maxCambiosNormal, 5);
            SET @maxVentanasNormal = ISNULL(@maxVentanasNormal, 3);
            SET @maxCambiosSup = ISNULL(@maxCambiosSup, 6);
            SET @maxVentanasSup = ISNULL(@maxVentanasSup, 4);

            -- Determinar si estamos en tiempo suplementario
            IF @minuto > 90
                SET @esSuplementario = 1;

            -- Contar cambios totales de la selección en este partido
            SELECT @cambiosRealizados = COUNT(*) 
            FROM torneo.cambio 
            WHERE partido_id = @idPartido AND seleccion_id = @idSeleccion;

            IF @cambiosRealizados >= IIF(@esSuplementario = 1, @maxCambiosSup, @maxCambiosNormal)
                SET @errores += N'- Se ha alcanzado el límite máximo de sustituciones permitidas para la selección.' + @saltoDeLinea;

            -- Contar ventanas usadas (ignorando la ventana que se está informando ahora, si es que es un cambio múltiple)
            SELECT @ventanasUsadas = COUNT(DISTINCT ventana) 
            FROM torneo.cambio 
            WHERE partido_id = @idPartido AND seleccion_id = @idSeleccion;

            IF NOT EXISTS (SELECT 1 FROM torneo.cambio WHERE partido_id = @idPartido AND seleccion_id = @idSeleccion AND ventana = @ventana)
            BEGIN
                -- Es una ventana nueva, verificamos si supera el límite
                IF @ventanasUsadas >= IIF(@esSuplementario = 1, @maxVentanasSup, @maxVentanasNormal)
                    SET @errores += N'- Se ha alcanzado el límite máximo de ventanas de cambio permitidas.' + @saltoDeLinea;
            END

            IF @ventana > IIF(@esSuplementario = 1, @maxVentanasSup, @maxVentanasNormal)
                SET @errores += N'- El número de ventana especificado supera el máximo reglamentario para este tramo del partido.' + @saltoDeLinea;
        END

        IF @errores <> N''
        BEGIN
            SET @errores = N'No se pudo registrar la sustitución:' + @saltoDeLinea + @errores;
            THROW 53104, @errores, 1;
        END;

        -- 5. Inserción de la incidencia apoyándonos en el SP de Alta subyacente
        EXEC torneo.sp_cambio_alta
            @partidoId         = @idPartido,
            @seleccionId       = @idSeleccion,
            @jugadorSaleId     = @idJugadorSale,
            @jugadorEntraId    = @idJugadorEntra,
            @minuto            = @minuto,
            @ventana           = @ventana,
            @motivo            = @motivo,
            @esSuplementario   = @esSuplementario,
            @cambioId          = @idCambio OUTPUT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO