/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 16_test_cambio_registrar.sql

   Objetivo:
   Testing 1:1 de 16_sp_cambio_registrar.sql.

   Procedimiento probado:
   - torneo.sp_cambio_registrar

   IMPORTANTE:
   El script verifica las validaciones principales del procedimiento.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 16_test_cambio_registrar.sql';
PRINT '======================================================================';

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_cambio_registrar';

-- ---------------------------------------------------------------------------
-- CASO DE ERROR
--
-- Resultado esperado:
--   - Debe lanzarse THROW 53104.
--   - No debe registrarse ninguna sustitución.
--
-- Motivo:
--   - El partido no existe.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @CambioId INT;

    EXEC torneo.sp_cambio_registrar
        @idPartido = -1,
        @idSeleccion = -1,
        @idJugadorSale = -1,
        @idJugadorEntra = -1,
        @minuto = 60,
        @ventana = 1,
        @motivo = 'TACTICO',
        @idCambio = @CambioId OUTPUT;

    PRINT '[FALLO] Permitió registrar una sustitución en un partido inexistente';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

PRINT '';
PRINT '======================================================================';
PRINT ' EVIDENCIA ';
PRINT '======================================================================';

SELECT *
FROM torneo.cambio
WHERE partido_id = -1;

GO
