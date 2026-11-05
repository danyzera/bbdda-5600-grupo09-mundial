/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 15_test_tarjeta_registrar.sql

   Objetivo:
   Testing 1:1 de 15_sp_tarjeta_registrar.sql.

   Procedimiento probado:
   - torneo.sp_tarjeta_registrar

   IMPORTANTE:
   El script verifica las validaciones principales del procedimiento.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 15_test_tarjeta_registrar.sql';
PRINT '======================================================================';

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_tarjeta_registrar';

-- ---------------------------------------------------------------------------
-- CASO DE ERROR
--
-- Resultado esperado:
--   - Debe lanzarse THROW 53103.
--   - No debe registrarse ninguna tarjeta.
--
-- Motivo:
--   - El partido y la alineación del jugador no existen.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @TarjetaId INT;

    EXEC torneo.sp_tarjeta_registrar
        @idPartido = -1,
        @idJugador = -1,
        @tipo = 'AMARILLA',
        @origenRoja = NULL,
        @minuto = 20,
        @motivo = N'TEST',
        @idTarjeta = @TarjetaId OUTPUT;

    PRINT '[FALLO] Permitió registrar una tarjeta sobre un partido inexistente';

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
FROM torneo.tarjeta
WHERE partido_id = -1;

GO