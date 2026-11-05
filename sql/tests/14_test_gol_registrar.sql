/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 14_test_gol_registrar.sql

   Objetivo:
   Testing 1:1 de 14_sp_gol_registrar.sql.

   Procedimiento probado:
   - torneo.sp_gol_registrar

   IMPORTANTE:
   El script genera sus propios datos y los elimina al finalizar.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 14_test_gol_registrar.sql';
PRINT '======================================================================';

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_gol_registrar';

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe lanzarse THROW 53102.
--   - No debe registrarse ningún gol.
--
-- Motivo:
--   - El partido no existe.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @GolId INT;

    EXEC torneo.sp_gol_registrar
        @partidoId = -1,
        @seleccionId = -1,
        @jugadorId = -1,
        @jugadorAsistenteId = NULL,
        @minuto = 15,
        @tipoGol = 'JUGADA',
        @periodo = 'PRIMER_TIEMPO',
        @golId = @GolId OUTPUT;

    PRINT '[FALLO] Permitió registrar un gol en un partido inexistente';

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
FROM torneo.gol
WHERE partido_id = -1;

GO