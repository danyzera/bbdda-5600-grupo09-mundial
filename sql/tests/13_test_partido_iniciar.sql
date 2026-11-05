/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 13_test_partido_iniciar.sql

   Objetivo:
   Testing 1:1 de 13_sp_partido_iniciar.sql.

   Procedimiento probado:
   - torneo.sp_partido_iniciar

   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 13_test_partido_iniciar.sql';
PRINT '======================================================================';

DECLARE @Pais1Id INT;
DECLARE @Pais2Id INT;
DECLARE @SedeId INT;
DECLARE @Seleccion1Id INT;
DECLARE @Seleccion2Id INT;
DECLARE @PartidoId INT;

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_LOCAL_13',
        @continente='AMERICA',
        @codigoIso='PLA',
        @husoHorario='Argentina Standard Time',
        @paisId=@Pais1Id OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_VISITA_13',
        @continente='EUROPA',
        @codigoIso='PVI',
        @husoHorario='UTC',
        @paisId=@Pais2Id OUTPUT;

    EXEC torneo.sp_sede_alta
        @paisId=@Pais1Id,
        @nombreEstadio='ESTADIO_13',
        @ciudad='CASANOVA',
        @capacidad=50000,
        @husoHorario='Argentina Standard Time',
        @sedeId=@SedeId OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@Pais1Id,
        @nombre='SELECCION_A_13',
        @confederacion='CONMEBOL',
        @grupo='A',
        @seleccionId=@Seleccion1Id OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@Pais2Id,
        @nombre='SELECCION_B_13',
        @confederacion='UEFA',
        @grupo='A',
        @seleccionId=@Seleccion2Id OUTPUT;

    EXEC torneo.sp_partido_alta
        @fase='GRUPOS',
        @sedeId=@SedeId,
        @seleccionLocalId=@Seleccion1Id,
        @seleccionVisitanteId=@Seleccion2Id,
        @fechaHoraLocal='2026-12-01 18:00',
        @partidoId=@PartidoId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH
    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_partido_iniciar';

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   Debe rechazarse.
--
-- Motivo:
--   El partido no tiene formaciones,
--   árbitros ni publicidad cargados.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_partido_iniciar
        @idPartido=@PartidoId;

    PRINT '[FALLO] Permitió iniciar un partido incompleto';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO]';
    PRINT ERROR_MESSAGE();

END CATCH;

PRINT '';
PRINT '======================================================================';
PRINT 'EVIDENCIA';
PRINT '======================================================================';

SELECT
    partido_id,
    estado,
    fase
FROM torneo.partido
WHERE partido_id=@PartidoId;

PRINT '';
PRINT '======================================================================';
PRINT ' LIMPIEZA';
PRINT '======================================================================';

BEGIN TRY

    DELETE FROM torneo.partido
    WHERE partido_id=@PartidoId;

    DELETE FROM torneo.seleccion
    WHERE seleccion_id IN (@Seleccion1Id,@Seleccion2Id);

    DELETE FROM torneo.sede
    WHERE sede_id=@SedeId;

    DELETE FROM torneo.pais
    WHERE pais_id IN (@Pais1Id,@Pais2Id);

    PRINT '[OK] Datos eliminados';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] ' + ERROR_MESSAGE();

END CATCH;

GO
