/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 09_test_baja_publicidad.sql

   Objetivo:
   Testing 1:1 de 09_sp_baja_publicidad.sql.

   Verifica:
   - publicidad.sp_anunciante_baja

   IMPORTANTE:
   Los datos de prueba se eliminan al finalizar el script.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 09_test_baja_publicidad.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;
DECLARE @AnuncianteId INT;

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre='TEST_PAIS_09',
        @continente='AMERICA',
        @codigoIso='TPN',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    EXEC publicidad.sp_anunciante_alta
        @nombre='ANUNCIANTE_TEST_09',
        @paisId=@PaisId,
        @anuncianteId=@AnuncianteId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH
    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '>>> 1. TEST: publicidad.sp_anunciante_baja';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - El anunciante debe eliminarse correctamente.
--   - El procedimiento debe ejecutarse sin errores.
--
-- Evidencia:
--   - El anunciante no debe existir luego de la baja.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_anunciante_baja
        @anuncianteId=@AnuncianteId;

    PRINT '[OK] Anunciante eliminado';

    SELECT
        'EVIDENCIA_POST_BAJA' AS Prueba,
        *
    FROM publicidad.anunciante
    WHERE anunciante_id = @AnuncianteId;

END TRY
BEGIN CATCH
    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe rechazarse la operación.
--   - El anunciante ya no existe.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_anunciante_baja
        @anuncianteId=@AnuncianteId;

    PRINT '[FALLO] Permitió eliminar un anunciante inexistente';

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