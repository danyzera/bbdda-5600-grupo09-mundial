/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 17_sp_partido_finalizar.sql
   Objetivo    : Procedimiento almacenado para finalizar un partido.
                (transición EN_CURSO -> FINALIZADO). No se puede finalizar
                un partido PROGRAMADO porque todavía no comenzó, ni uno
                FINALIZADO porque ya finalizó. Hace uso de la tabla 'gol' para
                computar y registrar el resultado. Este SP actualiza tanto
                la tabla partido como la tabla suspensión, por la contabilización
                de los partidos cumplidos.
   Código de error del SP: 53105, en concordancia con la nomenclatura.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER PROCEDURE torneo.sp_partido_finalizar
   @idPartido  INT,
   @asistencia INT
AS
BEGIN
   SET NOCOUNT ON;
   SET XACT_ABORT ON;
   DECLARE  @errores       NVARCHAR(MAX) = N'',
            @saltoDeLinea  NCHAR(2) = CHAR(13) + CHAR(10);
    
   DECLARE  @estadoPartido          VARCHAR(12),
            @fase                   VARCHAR(15),
            @idLocal                INT,
            @idVisitante            INT,
            @idSede                 INT,
            @fechaLocal             DATETIME2(0),
            @capacidadSede          INT,
            @golesLocal             TINYINT = 0, -- Por defecto si no se registró nada del partido en la tabla de goles terminó cero a cero sin penales
            @golesVisitante         TINYINT = 0,
            @penalesLocal           TINYINT = NULL,
            @penalesVisitante       TINYINT = NULL,
            -- Una poscondición de esta unidad de negocio es que se actualizan los partidos jugados
            -- para que contabilicen en las suspensiones restantes.
            -- Pero las suspensiones a actualizar pueden ser más de una, y el ABM se ejecuta uno por uno
            @suspensionId          INT,
            @motivo                NVARCHAR(200),
            @partidosSuspendidos   TINYINT,
            @partidosCumplidos     TINYINT;
   DECLARE  @SuspensionesParaActualizar TABLE (
            indice_referencia_fila    INT IDENTITY(1,1),
            suspension_id           INT,
            motivo                  NVARCHAR(200),
            partidos_suspendidos    TINYINT,
            partidos_cumplidos      TINYINT
            );

   BEGIN TRY
      BEGIN TRANSACTION;
         SELECT   @estadoPartido = p.estado,
                  @fase = p.fase, 
                  @idLocal = p.seleccion_local_id,
                  @idVisitante = p.seleccion_visitante_id,
                  @idSede = p.sede_id,
                  @fechaLocal = p.fecha_hora_local,
                  @capacidadSede = s.capacidad
         FROM torneo.partido AS p
               JOIN torneo.sede AS s ON p.sede_id = s.sede_id
         WHERE p.partido_id = @idPartido;

         IF @estadoPartido IS NULL
            SET @errores += N'- El partido no existe.' + @saltoDeLinea;
         IF @estadoPartido IS NOT NULL AND @estadoPartido <> 'EN_CURSO'
            SET @errores += N'- Solo se puede finalizar un partido que está EN_CURSO.' + @saltoDeLinea;

         IF @estadoPartido = 'EN_CURSO'
         BEGIN
            SELECT   @golesLocal = COUNT(CASE WHEN g.seleccion_id = @idLocal THEN 1 END), -- Conteo condicional para evitar dos cláusulas SELECT independientes
                     @golesVisitante = COUNT(CASE WHEN g.seleccion_id = @idVisitante THEN 1 END)
            FROM torneo.gol AS g
            WHERE g.partido_id = @idPartido
                  AND g.seleccion_id IN (@idLocal,@idVisitante)
                  AND g.periodo <> 'PENALES';

            -- Si hubo penales (periodo = 'PENALES'), se cuentan para registrarlos, con la misma lógica condicional
            IF EXISTS (
                  SELECT 1
                  FROM torneo.gol AS g
                  WHERE g.partido_id = @idPartido
                        AND g.periodo = 'PENALES')
            BEGIN
               SELECT   @penalesLocal = COUNT(CASE WHEN g.seleccion_id = @idLocal THEN 1 END),
                        @penalesVisitante = COUNT(CASE WHEN g.seleccion_id = @idVisitante THEN 1 END)
               FROM torneo.gol AS g
               WHERE g.partido_id = @idPartido
                     AND g.seleccion_id IN (@idLocal,@idVisitante)
                     AND g.periodo = 'PENALES';
            END

            IF @asistencia IS NULL OR @asistencia < 0
               SET @errores += N'- La asistencia es obligatoria y no puede ser negativa.' + @saltoDeLinea;
            IF @asistencia > @capacidadSede
               SET @errores += N'- Incongruencia: la asistencia supera la capacidad máxima del estadio.' + @saltoDeLinea;

            IF @fase <> 'GRUPOS'
                  AND @golesLocal = @golesVisitante
            BEGIN
               IF @penalesLocal IS NULL
                  SET @errores += N'- Un partido de eliminación empatado debe tener definición por penales.' + @saltoDeLinea;
               ELSE IF @penalesLocal = @penalesVisitante
                  SET @errores += N'- La definición por penales no puede terminar en empate.' + @saltoDeLinea;
            END
         END

         IF @errores <> N''
         BEGIN
            SET @errores = N'No se pudo finalizar el partido:' + @saltoDeLinea + @errores;
            THROW 53105, @errores, 1;
         END

         EXEC torneo.sp_partido_modificacion
            @partidoId = @idPartido,
            @fase = @fase,
            @sedeId = @idSede,
            @seleccionLocalId = @idLocal, 
            @seleccionVisitanteId = @idVisitante,
            @fechaHoraLocal = @fechaLocal,
            @golesLocal = @golesLocal,
            @golesVisitante = @golesVisitante,
            @penalesLocal = @penalesLocal,
            @penalesVisitante = @penalesVisitante,
            @asistencia = @asistencia,
            @estado = 'FINALIZADO';

         INSERT INTO @SuspensionesParaActualizar(
            suspension_id,
            motivo,
            partidos_suspendidos,
            partidos_cumplidos
         )
         SELECT s.suspension_id, s.motivo, s.partidos_suspendidos, s.partidos_cumplidos + 1
         FROM torneo.suspension AS s
               JOIN torneo.convocatoria AS c ON s.jugador_id = c.jugador_id
         WHERE c.seleccion_id IN (@idLocal, @idVisitante)
               AND s.partidos_cumplidos < s.partidos_suspendidos
               AND c.estado = 'VIGENTE';

         DECLARE @indiceRecorrido INT = 1;
         DECLARE @cantidadEncontrada INT = (SELECT MAX(indice_referencia_fila) FROM @SuspensionesParaActualizar);

         WHILE @indiceRecorrido <= ISNULL(@cantidadEncontrada, 0)
         BEGIN
            SELECT   @suspensionId = suspension_id,
                     @motivo = motivo,
                     @partidosSuspendidos = partidos_suspendidos,
                     @partidosCumplidos = partidos_cumplidos
            FROM @SuspensionesParaActualizar
            WHERE indice_referencia_fila = @indiceRecorrido;

            EXEC torneo.sp_suspension_modificacion
               @suspensionId = @suspensionId,
               @motivo = @motivo,
               @partidosSuspendidos = @partidosSuspendidos,
               @partidosCumplidos = @partidosCumplidos;

            SET @indiceRecorrido = @indiceRecorrido + 1;
         END

         COMMIT TRANSACTION;
   END TRY
   BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
      THROW;
   END CATCH;
END