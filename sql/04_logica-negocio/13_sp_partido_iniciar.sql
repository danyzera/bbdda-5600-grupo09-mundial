/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 13_sp_partido_iniciar.sql
   Objetivo    : Procedimiento almacenado para dar comienzo a un partido.
                 Con precondiciones, pasa un partido de estar PROGRAMADO
                 A estar EN CURSO. Es condición necesaria que el partido esté
                 EN CURSO para dar lugar a otros procedimientos de negocio
                 como registrar un gol. 
   Código de error del SP: 53101, en concordancia con la nomenclatura.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;               
SET ANSI_NULLS ON;                      
GO                                      

CREATE OR ALTER PROCEDURE torneo.sp_partido_iniciar
    @idPartido INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @saltoDeLinea NCHAR(2) = CHAR(13) + CHAR(10); 
    DECLARE @estadoPartido VARCHAR(12),
            @fase VARCHAR(15),
            @idSede INT,
            @idLocal INT,
            @idVisitante INT,
            @fechaUtc DATETIME2(0),
            @fechaPartido DATETIME2(0),
            @minimoSuplentes INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT  @estadoPartido = estado,
                @fase = fase,
                @idSede = sede_id,
                @idLocal = seleccion_local_id,
                @idVisitante = seleccion_visitante_id,
                @fechaUtc = fecha_hora_utc,
                @fechaPartido = fecha_hora_local
        FROM torneo.partido WITH (UPDLOCK)
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
                        WHERE f.partido_id = @idPartido
                                AND NOT EXISTS (    SELECT 1 FROM torneo.convocatoria c
                                                    WHERE c.jugador_id = ad.jugador_id
                                                            AND c.seleccion_id = f.seleccion_id
                                                            AND c.estado = 'VIGENTE'))
                SET @errores += N'- Hay jugadores alineados sin convocatoria vigente en su selección.' + @saltoDeLinea;

            -- Validación de suspensión: Se une contra tarjeta y partido origen, y se compara por fecha_hora_utc
            IF EXISTS ( SELECT 1
                        FROM torneo.alineacion_detalle ad
                                JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                                JOIN torneo.suspension s ON s.jugador_id = ad.jugador_id
                                JOIN torneo.tarjeta t_origen ON s.tarjeta_origen_id = t_origen.tarjeta_id
                                JOIN torneo.partido p_origen ON t_origen.partido_id = p_origen.partido_id
                        WHERE f.partido_id = @idPartido
                                AND s.partidos_cumplidos < s.partidos_suspendidos
                                AND p_origen.fecha_hora_utc < @fechaUtc)
                SET @errores += N'- Hay jugadores alineados con suspensión vigente.' + @saltoDeLinea;

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
                                AND (seleccion_local_id IN (@idLocal, @idVisitante)
                                            OR seleccion_visitante_id IN (@idLocal, @idVisitante)))
                SET @errores += N'- Alguna de las selecciones tiene otro partido en curso.' + @saltoDeLinea;

            IF EXISTS (SELECT 1 FROM torneo.partido
                        WHERE partido_id <> @idPartido AND fecha_hora_utc < @fechaUtc AND estado <> 'FINALIZADO'
                                AND (seleccion_local_id IN (@idLocal, @idVisitante)
                                            OR seleccion_visitante_id IN (@idLocal, @idVisitante)))
                SET @errores += N'- Alguna de las selecciones tiene un partido anterior sin finalizar.' + @saltoDeLinea;
            
            IF (    SELECT COUNT(*)
                    FROM publicidad.publicidad_partido
                    WHERE partido_id = @idPartido   ) <> 4
            SET @errores += N'- El partido debe tener asignados exactamente 4 espacios publicitarios.' + @saltoDeLinea;
        END;

        IF @errores <> N''
        BEGIN
            SET @errores = N'No se pudo iniciar el partido:' + @saltoDeLinea + @errores; 
            THROW 53101, @errores, 1;
        END;

        EXEC torneo.sp_partido_modificacion
                @partidoId = @idPartido,
                @fase = @fase,
                @sedeId = @idSede,
                @seleccionLocalId = @idLocal,
                @seleccionVisitanteId = @idVisitante,
                @fechaHoraLocal = @fechaPartido,
                @estado = 'EN_CURSO';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
