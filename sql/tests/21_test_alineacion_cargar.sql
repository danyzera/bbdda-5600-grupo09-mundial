/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 21_test_alineacion_cargar.sql

   Objetivo:
   Testing 1:1 de 21_sp_alineacion_cargar.sql.

   Procedimiento probado:
   - torneo.sp_alineacion_cargar

   IMPORTANTE:
   El script genera sus propios datos de prueba y los elimina al finalizar.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 21_test_alineacion_cargar.sql';
PRINT '======================================================================';

DECLARE @ParametroId INT;

DECLARE @Pais1Id INT;
DECLARE @Pais2Id INT;

DECLARE @SedeId INT;

DECLARE @Seleccion1Id INT;
DECLARE @Seleccion2Id INT;

DECLARE @PartidoId INT;

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_parametro_reglamento_alta
        @clave='MAX_SELECCIONES_GRUPO',
        @valor=4,
        @descripcion='Testing',
        @parametroId=@ParametroId OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_A_21',
        @continente='AMERICA',
        @codigoIso='PAA',
        @husoHorario='Argentina Standard Time',
        @paisId=@Pais1Id OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_B_21',
        @continente='EUROPA',
        @codigoIso='PBB',
        @husoHorario='UTC',
        @paisId=@Pais2Id OUTPUT;

    EXEC torneo.sp_sede_alta
        @paisId=@Pais1Id,
        @nombreEstadio='ESTADIO_21',
        @ciudad='CASANOVA',
        @capacidad=50000,
        @husoHorario='Argentina Standard Time',
        @sedeId=@SedeId OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@Pais1Id,
        @nombre='SELECCION_A_21',
        @confederacion='CONMEBOL',
        @grupo='A',
        @seleccionId=@Seleccion1Id OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@Pais2Id,
        @nombre='SELECCION_B_21',
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
PRINT '>>> 1. TEST: torneo.sp_alineacion_cargar';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - Se debe crear una nueva formación.
--   - Debe quedar asociada al partido y la selección.
--
-- Evidencia:
--   - SELECT sobre torneo.formacion_partido.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_alineacion_cargar
        @partidoId=@PartidoId,
        @seleccionId=@Seleccion1Id,
        @esquema='4-3-3';

    PRINT '[OK] Alineación cargada';

    SELECT
        'EVIDENCIA_ALINEACION' AS Prueba,
        *
    FROM torneo.formacion_partido
    WHERE partido_id=@PartidoId
      AND seleccion_id=@Seleccion1Id;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe rechazarse la operación.
--
-- Motivo:
--   - La alineación ya fue cargada.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_alineacion_cargar
        @partidoId=@PartidoId,
        @seleccionId=@Seleccion1Id,
        @esquema='4-4-2';

    PRINT '[FALLO] Permitió cargar dos alineaciones para la misma selección';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

PRINT '';
PRINT '======================================================================';
PRINT ' LIMPIEZA DE DATOS DE PRUEBA';
PRINT '======================================================================';

BEGIN TRY

    DELETE FROM torneo.formacion_partido
    WHERE partido_id=@PartidoId;

    DELETE FROM torneo.partido
    WHERE partido_id=@PartidoId;

    DELETE FROM torneo.seleccion
    WHERE seleccion_id IN (@Seleccion1Id,@Seleccion2Id);

    DELETE FROM torneo.sede
    WHERE sede_id=@SedeId;

    DELETE FROM torneo.pais
    WHERE pais_id IN (@Pais1Id,@Pais2Id);

    DELETE FROM torneo.parametro_reglamento
    WHERE parametro_id=@ParametroId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();

END CATCH;

GO