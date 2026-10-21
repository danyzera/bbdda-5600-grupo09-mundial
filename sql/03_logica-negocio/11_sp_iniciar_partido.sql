/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 11_sp_iniciar_partido.sql
   Objetivo    : Procedimiento almacenado para dar comienzo a un partido.
                Con precondiciones, pasa un partido de estar PROGRAMADO
                A estar EN CURSO. Es condición necesaria que el partido esté
                EN CURSO para dar lugar a otros procedimientos de negocio
                como registrar un gol. El procedimiento, al integrar varias
                operaciones que representan una unidad lógica (dar comienzo
                al partido), hace uso del TCL disponible en SQL Server.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON; -- Exigencia de SQL Server para operatorias sobre índices filtrados
SET ANSI_NULLS ON; -- Ídem
GO -- El SP se va a almacenar, y luego ejecutar, con estos seteos

CREATE OR ALTER PROCEDURE torneo.sp_iniciar_partido
    @idPartido INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @saltoDeLinea NCHAR(2) = CHAR(13) + CHAR(10); -- CRLF. CHAR actúa de función
    DECLARE @estadoPartido VARCHAR(12),
            @idSede INT,
            @idLocal INT,
            @idVisitante INT,
            @fechaUtc DATETIME2(0),
            @fechaPartido DATE,
            @minimoSuplentes INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT  @estadoPartido = estado,
                @idSede = sede_id,
                @idLocal = seleccion_local_id,
                @idVisitante = seleccion_visitante_id,
                @fechaUtc = fecha_hora_utc,
                @fechaPartido = CAST(fecha_hora_local AS DATE)
        FROM torneo.partido
        WHERE partido_id = @idPartido;

        -- Precondiciones en general (no se puede iniciar un partido si...)

        IF @estadoPartido IS NULL
            SET @errores += N'- El partido no existe.' + @saltoDeLinea;
        IF @estadoPartido IS NOT NULL AND @estadoPartido <> 'PROGRAMADO'
            SET @errores += N'- El partido ya fue iniciado (estado actual: ' + @estadoPartido + N').' + @saltoDeLinea;

        IF @estadoPartido IS NOT NULL
        BEGIN
            IF (SELECT COUNT(*) FROM torneo.formacion_partido WHERE partido_id = @idPartido) <> 2
                SET @errores += N'- Alguna o ambas formaciones participantes no están cargadas en el sistema.' + @saltoDeLinea;

            IF EXISTS ( SELECT 1 FROM torneo.formacion_partido f
                        WHERE f.partido_id = @idPartido
                                AND (   SELECT COUNT(*)
                                        FROM torneo.alineacion_detalle ad
                                        WHERE ad.formacion_id = f.formacion_id
                                                AND ad.es_titular = 1    ) <> 11)
                SET @errores += N'- Cada formación debe tener exactamente 11 jugadores titulares.' + @saltoDeLinea;
            -- No tiene sentido parametrizar el 11, es una constante que nunca cambió y se proyecta que no cambiará más

            SELECT @minimoSuplentes = valor FROM torneo.parametro_reglamento WHERE clave = 'MIN_SUPLENTES';

            IF @minimoSuplentes IS NULL
                SET @errores += N'- Falta configurar el parámetro MIN_SUPLENTES en el reglamento.' + @saltoDeLinea;

            IF @minimoSuplentes IS NOT NULL
                    AND EXISTS (    SELECT 1
                                    FROM torneo.formacion_partido f
                                    WHERE f.partido_id = @idPartido
                                            AND (   SELECT COUNT(*)
                                                    FROM torneo.alineacion_detalle ad
                                                    WHERE ad.formacion_id = f.formacion_id
                                                            AND ad.es_titular = 0) < @minimoSuplentes   )
                SET @errores += N'- Cada formación debe tener al menos ' + CAST(@minimoSuplentes AS NVARCHAR(10)) + N' suplentes.' + @saltoDeLinea;

            IF EXISTS ( SELECT 1 FROM torneo.formacion_partido f
                        WHERE f.partido_id = @idPartido
                                AND (   SELECT COUNT(*)
                                        FROM torneo.alineacion_detalle ad
                                                JOIN torneo.jugador j ON j.jugador_id = ad.jugador_id
                                        WHERE ad.formacion_id = f.formacion_id AND ad.es_titular = 1
                                                AND j.posicion = 'ARQ') <> 1)
                SET @errores += N'- Cada formación debe tener exactamente un arquero titular.' + @saltoDeLinea;

            IF EXISTS ( SELECT 1
                        FROM torneo.alineacion_detalle ad
                                JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                        WHERE f.partido_id = @partidoId
                                AND NOT EXISTS (    SELECT 1 FROM torneo.convocatoria c
                                                    WHERE c.jugador_id = ad.jugador_id
                                                            AND c.seleccion_id = f.seleccion_id
                                                            AND c.estado = 'VIGENTE'))
                SET @errores += N'- Hay jugadores alineados sin convocatoria vigente en su selección.' + @saltoDeLinea;

            IF EXISTS ( SELECT 1
                        FROM torneo.alineacion_detalle ad
                                JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                                JOIN torneo.suspension s ON s.jugador_id = ad.jugador_id
                        WHERE f.partido_id = @partidoId
                                AND s.partidos_cumplidos < s.partidos_suspendidos
                                AND s.fecha_inicio < @fechaPartido)
                SET @errores += N'- Hay jugadores alineados con suspensión vigente.' + @saltoDeLinea;

            -- Terna arbitral
            IF (    SELECT COUNT(*)
                    FROM arbitraje.designacion_arbitral
                    WHERE partido_id = @idPartido
                            AND rol_arbitral = 'ASISTENTE') <> 2
                SET @errores += N'- El partido debe tener exactamente dos árbitros asistentes.' + @saltoDeLinea;
            
            IF (    SELECT COUNT(DISTINCT rol_arbitral)
                    FROM arbitraje.designacion_arbitral
                    WHERE partido_id = @idPartido
                            AND rol_arbitral IN ('PRINCIPAL','CUARTO','VAR')) < 3
                SET @errores += N'- Falta designar al árbitro principal, al cuarto árbitro o al VAR.' + @saltoDeLinea;

            -- Exclusión de partidos simultáneos / orden cronológico
            IF EXISTS ( SELECT 1
                        FROM torneo.partido
                        WHERE partido_id <> @idPartido
                                AND estado = 'EN_CURSO'
                                AND sede_id = @idSede)
                SET @errores += N'- La sede ya tiene otro partido en curso.' + @saltoDeLinea;

            IF EXISTS ( SELECT 1
                        FROM torneo.partido
                        WHERE partido_id <> @idPartido
                                AND estado = 'EN_CURSO'
                                AND (seleccion_local_id IN (@seleccionLocalId, @seleccionVisitanteId)
                                        OR seleccion_visitante_id IN (@seleccionLocalId, @seleccionVisitanteId)))
                SET @errores += N'- Alguna de las selecciones tiene otro partido en curso.' + @saltoDeLinea;

            IF EXISTS (SELECT 1 FROM torneo.partido
                        WHERE partido_id <> @idPartido AND fecha_hora_utc < @fechaUtc AND estado <> 'FINALIZADO'
                                AND (seleccion_local_id IN (@seleccionLocalId, @seleccionVisitanteId)
                                        OR seleccion_visitante_id IN (@seleccionLocalId, @seleccionVisitanteId)))
                SET @errores += N'- Alguna de las selecciones tiene un partido anterior sin finalizar.' + @saltoDeLinea;
        END;

        IF @errores <> N''
        BEGIN
            SET @errores = N'No se pudo iniciar el partido:' + @saltoDeLinea + @errores;
            THROW 53101, @errores, 1;   -- cae al CATCH, que hace rollback y relanza
        END;

        UPDATE torneo.partido
        SET estado = 'EN_CURSO', goles_local = 0, goles_visitante = 0
        WHERE partido_id = @idPartido AND estado = 'PROGRAMADO';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO