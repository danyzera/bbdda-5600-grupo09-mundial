/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 12_test_modificacion_publicidad.sql

   Objetivo:
   Testing 1:1 de 12_sp_modificacion_publicidad.sql.

   Verifica:
   - publicidad.sp_anunciante_modificacion

   IMPORTANTE:
   Los datos de prueba se eliminan al finalizar el script.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 12_test_modificacion_publicidad.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;
DECLARE @AnuncianteId INT;

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre='TEST_PAIS_PUB_12',
        @continente='AMERICA',
        @codigoIso='TPP',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    EXEC publicidad.sp_anunciante_alta
        @nombre='ANUNCIANTE_TEST_12',
        @paisId=@PaisId,
        @anuncianteId=@AnuncianteId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH
    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '>>> 1. TEST: publicidad.sp_anunciante_modificacion';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - El anunciante debe modificarse correctamente.
--   - Deben reflejarse los nuevos valores.
--
-- Evidencia:
--   - Se visualizará el registro actualizado.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_anunciante_modificacion
        @anuncianteId = @AnuncianteId,
        @nombre = 'ANUNCIANTE_MODIFICADO_12',
        @rubro = 'BEBIDAS',
        @email = 'test12@publicidad.com',
        @paisId = @PaisId;

    PRINT '[OK] Anunciante modificado';

    SELECT
        'EVIDENCIA_MODIFICACION' AS Prueba,
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
--   - Debe rechazarse la modificación.
--   - No debe existir un anunciante con ese ID.
--
-- Motivo:
--   - Se intenta modificar un anunciante inexistente.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_anunciante_modificacion
        @anuncianteId = -1,
        @nombre = 'ANUNCIANTE_INEXISTENTE',
        @rubro = 'TEST',
        @email = 'error@test.com',
        @paisId = @PaisId;

    PRINT '[FALLO] Permitió modificar un anunciante inexistente';

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
    FROM publicidad.anunciante
    WHERE anunciante_id = @AnuncianteId;

    DELETE
    FROM torneo.pais
    WHERE pais_id = @PaisId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH
    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();
END CATCH;

GO