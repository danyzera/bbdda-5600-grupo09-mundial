/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 05_test_alta_arbitraje.sql

   Objetivo:
   Testing 1:1 de los procedimientos simples de alta del esquema arbitraje.

   Procedimientos probados:
   - arbitraje.sp_arbitro_alta
   - arbitraje.sp_arbitro_idioma_alta

   IMPORTANTE:
   El script genera sus propias dependencias y elimina todos los datos
   de prueba al finalizar.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 05_test_alta_arbitraje.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;
DECLARE @ArbitroId INT;

-- ============================================================================
-- SETUP
-- ============================================================================

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre = 'TEST_PAIS_05',
        @continente = 'AMERICA',
        @codigoIso = 'TPA',
        @husoHorario = 'Argentina Standard Time',
        @paisId = @PaisId OUTPUT;

    PRINT '[OK] Pais auxiliar creado';

END TRY
BEGIN CATCH

    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();

END CATCH;


-- ============================================================================
-- TEST 1
-- ============================================================================

PRINT '';
PRINT '>>> 1. TEST: arbitraje.sp_arbitro_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - El procedimiento debe ejecutarse correctamente.
--   - Debe registrarse un árbitro.
--   - Debe generarse un arbitro_id válido.
--
-- Evidencia:
--   - SELECT sobre arbitraje.arbitro.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_arbitro_alta
        @nombre = 'ARBITRO_TEST_05',
        @paisId = @PaisId,
        @categoria = 'FIFA',
        @arbitroId = @ArbitroId OUTPUT;

    PRINT '[OK] Arbitro creado';

    SELECT
        'EVIDENCIA_ARBITRO' AS Prueba,
        *
    FROM arbitraje.arbitro
    WHERE arbitro_id = @ArbitroId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO DE ERROR
--
-- Resultado esperado:
--   - Debe lanzarse THROW 50201.
--   - No debe insertarse ningún árbitro.
--
-- Motivo:
--   - Nombre vacío.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @DummyArbitro INT;

    EXEC arbitraje.sp_arbitro_alta
        @nombre = '',
        @paisId = @PaisId,
        @categoria = 'FIFA',
        @arbitroId = @DummyArbitro OUTPUT;

    PRINT '[FALLO] Permitió registrar un árbitro sin nombre';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;


-- ============================================================================
-- TEST 2
-- ============================================================================

PRINT '';
PRINT '>>> 2. TEST: arbitraje.sp_arbitro_idioma_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - Debe registrarse un idioma para el árbitro.
--
-- Evidencia:
--   - SELECT sobre arbitraje.arbitro_idioma.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_arbitro_idioma_alta
        @arbitroId = @ArbitroId,
        @idioma = 'INGLES';

    PRINT '[OK] Idioma registrado';

    SELECT
        'EVIDENCIA_IDIOMA' AS Prueba,
        *
    FROM arbitraje.arbitro_idioma
    WHERE arbitro_id = @ArbitroId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO DE ERROR
--
-- Resultado esperado:
--   - Debe lanzarse THROW 50202.
--   - No debe insertarse ningún idioma adicional.
--
-- Motivo:
--   - Intentar registrar el mismo idioma dos veces.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_arbitro_idioma_alta
        @arbitroId = @ArbitroId,
        @idioma = 'INGLES';

    PRINT '[FALLO] Permitió duplicar el idioma';

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

    DELETE
    FROM arbitraje.arbitro_idioma
    WHERE arbitro_id = @ArbitroId;

    DELETE
    FROM arbitraje.arbitro
    WHERE arbitro_id = @ArbitroId;

    DELETE
    FROM torneo.pais
    WHERE pais_id = @PaisId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();

END CATCH;
GO