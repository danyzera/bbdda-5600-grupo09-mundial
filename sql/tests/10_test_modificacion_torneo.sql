/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 10_test_modificacion_torneo.sql

   Objetivo:
   Testing 1:1 de 10_sp_modificacion_torneo.sql.

   Verifica:
   - torneo.sp_pais_modificacion

   IMPORTANTE:
   Los datos de prueba se eliminan al finalizar el script.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 10_test_modificacion_torneo.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre='TEST_PAIS_MOD_10',
        @continente='AMERICA',
        @codigoIso='TPM',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH
    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_pais_modificacion';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - El país debe modificarse correctamente.
--   - Deben reflejarse los nuevos valores.
--
-- Evidencia:
--   - Se visualizará el registro actualizado.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_pais_modificacion
        @paisId = @PaisId,
        @nombre = 'TEST_PAIS_MODIFICADO_10',
        @continente = 'EUROPA',
        @codigoIso = 'TMD',
        @husoHorario = 'UTC',
        @pbiPerCapita = 25000,
        @pbiAnio = 2025;

    PRINT '[OK] País modificado';

    SELECT
        'EVIDENCIA_MODIFICACION' AS Prueba,
        *
    FROM torneo.pais
    WHERE pais_id = @PaisId;

END TRY
BEGIN CATCH
    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe rechazarse la modificación.
--   - No debe existir un país con ese ID.
--
-- Motivo:
--   - Se intenta modificar un país inexistente.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_pais_modificacion
        @paisId = -1,
        @nombre = 'PAIS_INEXISTENTE',
        @continente = 'EUROPA',
        @codigoIso = 'PIN',
        @husoHorario = 'UTC',
        @pbiPerCapita = 10000,
        @pbiAnio = 2025;

    PRINT '[FALLO] Permitió modificar un país inexistente';

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
    FROM torneo.pais
    WHERE pais_id = @PaisId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH
    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();
END CATCH;

GO