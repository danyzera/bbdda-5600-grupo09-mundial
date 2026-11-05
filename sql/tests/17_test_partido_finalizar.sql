/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 17_test_partido_finalizar.sql

   Objetivo:
   Testing 1:1 de 17_sp_partido_finalizar.sql.

   Procedimiento probado:
   - torneo.sp_partido_finalizar

   IMPORTANTE:
   El script verifica las validaciones principales del procedimiento.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 17_test_partido_finalizar.sql';
PRINT '======================================================================';

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_partido_finalizar';

-- ---------------------------------------------------------------------------
-- CASO DE ERROR
--
-- Resultado esperado:
--   - Debe lanzarse THROW 53105.
--   - No debe finalizarse ningún partido.
--
-- Motivo:
--   - El partido especificado no existe.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_partido_finalizar
        @idPartido = -1,
        @asistencia = 1000;

    PRINT '[FALLO] Permitió finalizar un partido inexistente';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

PRINT '';
PRINT '======================================================================';
PRINT ' EVIDENCIA ';
PRINT '======================================================================';

SELECT
    *
FROM torneo.partido
WHERE partido_id = -1;

GO