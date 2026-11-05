/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 07_test_baja_torneo.sql

   Objetivo:
   Testing 1:1 de 07_sp_baja_torneo.sql.

   Verifica:
   - torneo.sp_jugador_baja

   IMPORTANTE:
   Los datos de prueba se eliminan al finalizar el script.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 07_test_baja_torneo.sql';
PRINT '======================================================================';

DECLARE @JugadorId INT;

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_jugador_alta
        @nombre='JUGADOR_BAJA_TEST_07',
        @fechaNacimiento='2000-01-01',
        @posicion='DEL',
        @jugadorId=@JugadorId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH
    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_jugador_baja';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - El jugador debe eliminarse correctamente.
--   - El procedimiento debe ejecutarse sin errores.
--
-- Evidencia:
--   - El jugador no debe existir luego de la baja.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_jugador_baja
        @jugadorId=@JugadorId;

    PRINT '[OK] Jugador eliminado';

    SELECT
        'EVIDENCIA_POST_BAJA' AS Prueba,
        *
    FROM torneo.jugador
    WHERE jugador_id=@JugadorId;

END TRY
BEGIN CATCH
    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe rechazarse la operación.
--   - El jugador ya no existe.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_jugador_baja
        @jugadorId=@JugadorId;

    PRINT '[FALLO] Permitió eliminar un jugador inexistente';

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
    FROM torneo.jugador
    WHERE nombre='JUGADOR_BAJA_TEST_07';

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH
    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();
END CATCH;

GO