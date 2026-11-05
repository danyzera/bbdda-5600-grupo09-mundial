/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 04_test_alta_torneo.sql

   Objetivo:
   Testing 1:1 del script 04_sp_alta_torneo.sql.
   Verifica casos exitosos y casos de error controlados.

   IMPORTANTE:
   Los datos de prueba se eliminan al finalizar el script.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 04_test_alta_torneo.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_pais_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
-- Resultado esperado:
--   - El procedimiento debe ejecutarse sin errores.
--   - Debe registrarse un nuevo país.
--   - Debe generarse un pais_id válido.
-- Evidencia:
--   - Se mostrará el registro insertado.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre='TESTLAND_04',
        @continente='AMERICA',
        @codigoIso='TST',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    PRINT '[OK] País creado';

    SELECT
        'EVIDENCIA_PAIS' AS Prueba,
        *
    FROM torneo.pais
    WHERE pais_id = @PaisId;

END TRY
BEGIN CATCH
    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------------
-- CASO DE ERROR
-- Resultado esperado:
--   - Debe lanzarse THROW 50101.
--   - No debe insertarse ningún registro.
-- Motivo:
--   - Se intenta registrar un país con nombre duplicado.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @DummyPais INT;

    EXEC torneo.sp_pais_alta
        @nombre='TESTLAND_04',
        @continente='AMERICA',
        @codigoIso='AAA',
        @husoHorario='Argentina Standard Time',
        @paisId=@DummyPais OUTPUT;

    PRINT '[FALLO] Permitió un país duplicado';

END TRY
BEGIN CATCH
    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT '>>> 2. TEST: torneo.sp_jugador_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
-- Resultado esperado:
--   - El procedimiento debe ejecutarse correctamente.
--   - Debe crearse un jugador nuevo.
-- Evidencia:
--   - Se visualizará el registro generado.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @JugadorId INT;

    EXEC torneo.sp_jugador_alta
        @nombre='JUAN_TEST_04',
        @fechaNacimiento='2000-01-01',
        @posicion='DEL',
        @jugadorId=@JugadorId OUTPUT;

    PRINT '[OK] Jugador creado';

    SELECT
        'EVIDENCIA_JUGADOR' AS Prueba,
        *
    FROM torneo.jugador
    WHERE jugador_id = @JugadorId;

END TRY
BEGIN CATCH
    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------------
-- CASO DE ERROR
-- Resultado esperado:
--   - Debe rechazarse el alta.
--   - No debe crearse ningún jugador.
-- Motivo:
--   - Nombre vacío.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @JugadorDummy INT;

    EXEC torneo.sp_jugador_alta
        @nombre='',
        @fechaNacimiento='2000-01-01',
        @posicion='DEL',
        @jugadorId=@JugadorDummy OUTPUT;

    PRINT '[FALLO] Permitió crear un jugador sin nombre';

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
    WHERE nombre = 'JUAN_TEST_04';

    DELETE
    FROM torneo.pais
    WHERE nombre = 'TESTLAND_04';

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();

END CATCH;
GO
