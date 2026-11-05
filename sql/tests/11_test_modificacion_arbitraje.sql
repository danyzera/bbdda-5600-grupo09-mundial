/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 11_test_modificacion_arbitraje.sql

   Objetivo:
   Testing 1:1 de 11_sp_modificacion_arbitraje.sql.

   Verifica:
   - arbitraje.sp_arbitro_modificacion

   IMPORTANTE:
   Los datos de prueba se eliminan al finalizar el script.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 11_test_modificacion_arbitraje.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;
DECLARE @ArbitroId INT;

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre='TEST_PAIS_ARB_11',
        @continente='AMERICA',
        @codigoIso='TAB',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    EXEC arbitraje.sp_arbitro_alta
        @nombre='ARBITRO_TEST_11',
        @paisId=@PaisId,
        @categoria='FIFA',
        @arbitroId=@ArbitroId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH
    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '>>> 1. TEST: arbitraje.sp_arbitro_modificacion';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - El árbitro debe modificarse correctamente.
--   - Deben reflejarse los nuevos valores.
--
-- Evidencia:
--   - Se visualizará el registro actualizado.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_arbitro_modificacion
        @arbitroId = @ArbitroId,
        @nombre = 'ARBITRO_MODIFICADO_11',
        @paisId = @PaisId,
        @categoria = 'CONFEDERACION';

    PRINT '[OK] Árbitro modificado';

    SELECT
        'EVIDENCIA_MODIFICACION' AS Prueba,
        *
    FROM arbitraje.arbitro
    WHERE arbitro_id = @ArbitroId;

END TRY
BEGIN CATCH
    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe rechazarse la modificación.
--   - No debe existir un árbitro con ese ID.
--
-- Motivo:
--   - Se intenta modificar un árbitro inexistente.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC arbitraje.sp_arbitro_modificacion
        @arbitroId = -1,
        @nombre = 'ARBITRO_INEXISTENTE',
        @paisId = @PaisId,
        @categoria = 'FIFA';

    PRINT '[FALLO] Permitió modificar un árbitro inexistente';

END TRY
BEGIN CATCH
    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '======================================================================';
PRINT ' LIMPIEZA DE DATOS DE PRUEBA';
PRINT '======================================================================';

BEGIN TRY

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