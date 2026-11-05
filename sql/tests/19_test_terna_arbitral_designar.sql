/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 19_test_terna_arbitral_designar.sql

   Objetivo:
   Testing 1:1 de 19_sp_terna_arbitral_designar.sql.

   Procedimiento probado:
   - arbitraje.sp_terna_arbitral_designar

   IMPORTANTE:
   El script genera sus propios datos de prueba y los elimina al finalizar.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 19_test_terna_arbitral_designar.sql';
PRINT '======================================================================';

DECLARE @Pais1Id INT;
DECLARE @Pais2Id INT;
DECLARE @Pais3Id INT;

DECLARE @SedeId INT;

DECLARE @Seleccion1Id INT;
DECLARE @Seleccion2Id INT;

DECLARE @PartidoId INT;

DECLARE @ArbitroPrincipal INT;
DECLARE @ArbitroAsistente1 INT;
DECLARE @ArbitroAsistente2 INT;
DECLARE @ArbitroCuarto INT;
DECLARE @ArbitroVar INT;

DECLARE @ParametroId INT;

-- ============================================================================
-- SETUP
-- ============================================================================

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_parametro_reglamento_alta
        @clave='MAX_SELECCIONES_GRUPO',
        @valor=4,
        @descripcion='Testing',
        @parametroId=@ParametroId OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_LOCAL_19',
        @continente='AMERICA',
        @codigoIso='PLN',
        @husoHorario='Argentina Standard Time',
        @paisId=@Pais1Id OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_VISITA_19',
        @continente='EUROPA',
        @codigoIso='PVN',
        @husoHorario='UTC',
        @paisId=@Pais2Id OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_ARBITRAL_19',
        @continente='ASIA',
        @codigoIso='PAN',
        @husoHorario='UTC',
        @paisId=@Pais3Id OUTPUT;

    EXEC torneo.sp_sede_alta
        @paisId=@Pais1Id,
        @nombreEstadio='ESTADIO_19',
        @ciudad='CASANOVA',
        @capacidad=50000,
        @husoHorario='Argentina Standard Time',
        @sedeId=@SedeId OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@Pais1Id,
        @nombre='SELECCION_A_19',
        @confederacion='CONMEBOL',
        @grupo='A',
        @seleccionId=@Seleccion1Id OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@Pais2Id,
        @nombre='SELECCION_B_19',
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

    EXEC arbitraje.sp_arbitro_alta
        @nombre='PRINCIPAL_19',
        @paisId=@Pais3Id,
        @categoria='FIFA',
        @arbitroId=@ArbitroPrincipal OUTPUT;

    EXEC arbitraje.sp_arbitro_alta
        @nombre='ASISTENTE1_19',
        @paisId=@Pais3Id,
        @categoria='FIFA',
        @arbitroId=@ArbitroAsistente1 OUTPUT;

    EXEC arbitraje.sp_arbitro_alta
        @nombre='ASISTENTE2_19',
        @paisId=@Pais3Id,
        @categoria='FIFA',
        @arbitroId=@ArbitroAsistente2 OUTPUT;

    EXEC arbitraje.sp_arbitro_alta
        @nombre='CUARTO_19',
        @paisId=@Pais3Id,
        @categoria='FIFA',
        @arbitroId=@ArbitroCuarto OUTPUT;

    EXEC arbitraje.sp_arbitro_alta
        @nombre='VAR_19',
        @paisId=@Pais3Id,
        @categoria='FIFA',
        @arbitroId=@ArbitroVar OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH

    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- TEST 1
-- ============================================================================

PRINT '';
PRINT '>>> 1. TEST: arbitraje.sp_terna_arbitral_designar';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_terna_arbitral_designar
        @idPartido=@PartidoId,
        @idPrincipal=@ArbitroPrincipal,
        @idAsistente1=@ArbitroAsistente1,
        @idAsistente2=@ArbitroAsistente2,
        @idCuarto=@ArbitroCuarto,
        @idVar=@ArbitroVar;

    PRINT '[OK] Terna arbitral registrada';

    SELECT
        'EVIDENCIA_TERNA' AS Prueba,
        *
    FROM arbitraje.designacion_arbitral
    WHERE partido_id=@PartidoId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Motivo:
--   Mismo árbitro en todos los roles.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_terna_arbitral_designar
        @idPartido=@PartidoId,
        @idPrincipal=@ArbitroPrincipal,
        @idAsistente1=@ArbitroPrincipal,
        @idAsistente2=@ArbitroPrincipal,
        @idCuarto=@ArbitroPrincipal,
        @idVar=@ArbitroPrincipal;

    PRINT '[FALLO] Permitió usar el mismo árbitro en múltiples roles';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- LIMPIEZA
-- ============================================================================

PRINT '';
PRINT '======================================================================';
PRINT ' LIMPIEZA DE DATOS DE PRUEBA';
PRINT '======================================================================';

BEGIN TRY

    DELETE FROM arbitraje.designacion_arbitral
    WHERE partido_id=@PartidoId;

    DELETE FROM arbitraje.arbitro
    WHERE arbitro_id IN (
        @ArbitroPrincipal,
        @ArbitroAsistente1,
        @ArbitroAsistente2,
        @ArbitroCuarto,
        @ArbitroVar
    );

    DELETE FROM torneo.partido
    WHERE partido_id=@PartidoId;

    DELETE FROM torneo.seleccion
    WHERE seleccion_id IN (@Seleccion1Id,@Seleccion2Id);

    DELETE FROM torneo.sede
    WHERE sede_id=@SedeId;

    DELETE FROM torneo.pais
    WHERE pais_id IN (@Pais1Id,@Pais2Id,@Pais3Id);

    DELETE FROM torneo.parametro_reglamento
    WHERE parametro_id=@ParametroId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();

END CATCH;

GO