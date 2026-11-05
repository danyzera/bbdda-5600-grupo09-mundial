
/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 22/10/2026
   Script      : 15_sp_tarjeta_registrar.sql
   Objetivo    : Registrar una tarjeta durante un partido. Reutiliza la función que
                 consulta el equipo en un minuto dado (el minuto de la tarjeta).
                 Evalúa una posible suspensión automática como poscondición.
   Código de error del SP: 53103, en concordancia con la nomenclatura.
   ============================================================================ */
USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;               
SET ANSI_NULLS ON;                      
GO

CREATE OR ALTER PROCEDURE torneo.sp_tarjeta_registrar
    @idPartido    INT,
    @idJugador    INT,
    @tipo         VARCHAR(8),
    @origenRoja   VARCHAR(15) = NULL,
    @minuto       SMALLINT,
    @motivo       NVARCHAR(200) = NULL,
    @idTarjeta    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @errores                NVARCHAR(MAX) = N'', 
            @saltoDeLinea           NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estadoPartido          VARCHAR(12), 
            @fechaPartido           DATE,
            @idSeleccion            INT;
    DECLARE @idRojaAutomatica       INT = NULL,
            @idSuspension           INT = NULL,
            @amarillasMismoPartido  INT = 0,
            @limiteAmarillas        INT = 0,
            @amarillasTotales       INT = 0,
            @idOrigenRoja           INT = NULL;
    DECLARE @motivoRoja             NVARCHAR(200) = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT  @estadoPartido = p.estado, 
                @fechaPartido = CAST(p.fecha_hora_utc AS DATE),
                @idSeleccion = s.seleccion_id
        FROM torneo.partido AS p WITH (UPDLOCK)
                JOIN torneo.formacion_partido AS fp ON fp.partido_id = p.partido_id
                JOIN torneo.alineacion_detalle AS ad ON ad.formacion_id = fp.formacion_id
                JOIN torneo.seleccion AS s ON s.seleccion_id = fp.seleccion_id
        WHERE p.partido_id = @idPartido
                AND ad.jugador_id = @idJugador;

        IF @estadoPartido IS NULL
            SET @errores += N'- El partido o la alineación del jugador no existen.' + @saltoDeLinea;
        ELSE IF @estadoPartido <> 'EN_CURSO'
            SET @errores += N'- Las tarjetas solo pueden registrarse en partidos EN_CURSO.' + @saltoDeLinea;

        IF @estadoPartido = 'EN_CURSO'
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM torneo.fn_obtener_alineacion_actual(@idPartido, @idSeleccion, @minuto) AS aact 
                WHERE aact.idJugador = @idJugador
            )
            BEGIN
                SET @errores += N'- El jugador no se encontraba físicamente en el campo en ese minuto.' + @saltoDeLinea;
            END
        END

        IF @errores <> N''
        BEGIN
            SET @errores = N'No se puede procesar el registro de la tarjeta:' + @saltoDeLinea + @errores;
            THROW 53103, @errores, 1;
        END;

        -- Inserción de la tarjeta en sí
        EXEC torneo.sp_tarjeta_alta
            @partidoId  = @idPartido,
            @jugadorId  = @idJugador,
            @tipo       = @tipo,
            @origenRoja = @origenRoja,
            @minuto     = @minuto,
            @motivo     = @motivo,
            @tarjetaId  = @idTarjeta OUTPUT;
        
        -- Si es amarilla, verificar doble amonestación en el mismo partido
        IF @tipo = 'AMARILLA'
        BEGIN
            SELECT @amarillasMismoPartido = COUNT(*) 
            FROM torneo.tarjeta 
            WHERE partido_id = @idPartido
                    AND jugador_id = @idJugador
                    AND tipo = 'AMARILLA';

            IF @amarillasMismoPartido = 2
            BEGIN
                EXEC torneo.sp_tarjeta_alta
                    @partidoId  = @idPartido,
                    @jugadorId  = @idJugador,
                    @tipo       = 'ROJA',
                    @origenRoja = 'DOBLE_AMARILLA',
                    @minuto     = @minuto,
                    @motivo     = N'Generación automática por doble amonestación',
                    @tarjetaId  = @idRojaAutomatica OUTPUT;
            END
        END

        -- Manejo de suspensión por roja (directa o automática)
        IF @tipo = 'ROJA' OR @idRojaAutomatica IS NOT NULL
        BEGIN
            SET @motivoRoja = CASE 
                WHEN @tipo = 'ROJA' THEN N'Expulsión por tarjeta roja directa en el partido'
                ELSE N'Expulsión por doble amonestación' 
            END;
            
            SET @idOrigenRoja = ISNULL(@idRojaAutomatica, @idTarjeta);

            EXEC torneo.sp_suspension_alta
                @jugadorId              = @idJugador,
                @tarjetaOrigenId        = @idOrigenRoja,
                @motivo                 = @motivoRoja,
                @fechaInicio            = @fechaPartido,
                @partidosSuspendidos    = 1, 
                @partidosCumplidos      = 0,
                @suspensionId           = @idSuspension OUTPUT;
        END
        -- Manejo de suspensión por acumulación parametrizable de amarillas
        ELSE IF @tipo = 'AMARILLA' AND @idRojaAutomatica IS NULL
        BEGIN
            SELECT @limiteAmarillas = valor 
            FROM torneo.parametro_reglamento 
            WHERE clave = 'AMARILLAS_PARA_SUSPENSION';

            SET @limiteAmarillas = ISNULL(@limiteAmarillas, 2); 

            -- Evitar división por cero
            IF NULLIF(@limiteAmarillas, 0) IS NOT NULL
            BEGIN
                -- Contar amarillas excluyendo las que terminaron en doble amarilla (y roja)
                SELECT @amarillasTotales = COUNT(*) 
                FROM torneo.tarjeta t1
                WHERE t1.jugador_id = @idJugador
                      AND t1.tipo = 'AMARILLA'
                      AND NOT EXISTS (
                          SELECT 1 FROM torneo.tarjeta t2
                          WHERE t2.partido_id = t1.partido_id 
                            AND t2.jugador_id = t1.jugador_id
                            AND t2.tipo = 'ROJA' 
                            AND t2.origen_roja = 'DOBLE_AMARILLA'
                      );

                IF (@amarillasTotales % @limiteAmarillas) = 0 
                BEGIN
                    EXEC torneo.sp_suspension_alta
                        @jugadorId              = @idJugador,
                        @tarjetaOrigenId        = @idTarjeta,
                        @motivo                 = N'Suspensión automática por acumulación de tarjetas',
                        @fechaInicio            = @fechaPartido,
                        @partidosSuspendidos    = 1,
                        @partidosCumplidos      = 0,
                        @suspensionId           = @idSuspension OUTPUT;
                END
            END
        END

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO