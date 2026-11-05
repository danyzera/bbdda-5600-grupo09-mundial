/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 08_test_baja_arbitraje.sql

   Objetivo:
   Testing 1:1 de los procedimientos simples de baja del esquema arbitraje.

   Procedimientos probados:
   - arbitraje.sp_arbitro_baja

   IMPORTANTE:
   El script genera sus propias dependencias y elimina todos los datos
   de prueba al finalizar.

   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 08_test_baja_arbitraje.sql';
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
        @nombre='TEST_PAIS_08',
        @continente='AMERICA',
        @codigoIso='TPA',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    EXEC arbitraje.sp_arbitro_alta
        @nombre='ARBITRO_TEST_08',
        @paisId=@PaisId,
        @categoria='FIFA',
        @arbitroId=@ArbitroId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH
    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();
END CATCH;

-- ============================================================================
-- TEST 1
-- ============================================================================

PRINT '';
PRINT '>>> 1. TEST: arbitraje.sp_arbitro_baja';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - El árbitro debe eliminarse correctamente.
--   - El procedimiento debe ejecutarse sin errores.
--
-- Evidencia:
--   - No debe existir el árbitro luego de la ejecución.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_arbitro_baja
        @arbitroId=@ArbitroId;

    PRINT '[OK] Árbitro eliminado';

    SELECT
        'EVIDENCIA_POST_BAJA' AS Prueba,
        *
    FROM arbitraje.arbitro
    WHERE arbitro_id=@ArbitroId;

END TRY
BEGIN CATCH
    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe lanzarse THROW.
--   - No debe encontrarse el árbitro.
--
-- Motivo:
--   - Se intenta eliminar nuevamente el mismo árbitro.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_arbitro_baja
        @arbitroId=@ArbitroId;

    PRINT '[FALLO] Permitió eliminar un árbitro inexistente';

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
    FROM torneo.pais
    WHERE pais_id=@PaisId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH
    PRINT '[ADVERTENCIA] Error durante la limpieza: '
        + ERROR_MESSAGE();
END CATCH;

GO