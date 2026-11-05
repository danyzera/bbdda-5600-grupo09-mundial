/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 18_test_convocatoria_reemplazar.sql

   Objetivo:
   Testing 1:1 de 18_sp_convocatoria_reemplazar.sql.

   Procedimiento probado:
   - torneo.sp_convocatoria_reemplazar

   IMPORTANTE:
   El script genera sus propios datos de prueba y los elimina al finalizar.
   Asume una base completamente vacía.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 18_test_convocatoria_reemplazar.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;
DECLARE @SeleccionId INT;
DECLARE @JugadorBajaId INT;
DECLARE @JugadorAltaId INT;
DECLARE @ConvocatoriaId INT;
DECLARE @ReemplazoId INT;
DECLARE @ParametroId INT;

-- ============================================================================
-- SETUP
-- ============================================================================

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_parametro_reglamento_alta
        @clave='MAX_CONVOCADOS',
        @valor=26,
        @descripcion='Máximo de convocados permitido',
        @parametroId=@ParametroId OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_TEST_18',
        @continente='AMERICA',
        @codigoIso='PTD',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@PaisId,
        @nombre='SELECCION_TEST_18',
        @confederacion='CONMEBOL',
        @grupo='A',
        @seleccionId=@SeleccionId OUTPUT;

    EXEC torneo.sp_jugador_alta
        @nombre='JUGADOR_BAJA_18',
        @fechaNacimiento='2000-01-01',
        @posicion='DEL',
        @jugadorId=@JugadorBajaId OUTPUT;

    EXEC torneo.sp_jugador_alta
        @nombre='JUGADOR_ALTA_18',
        @fechaNacimiento='2001-01-01',
        @posicion='MED',
        @jugadorId=@JugadorAltaId OUTPUT;

    EXEC torneo.sp_convocatoria_alta
        @seleccionId=@SeleccionId,
        @jugadorId=@JugadorBajaId,
        @dorsal=10,
        @fechaConvocatoria='2026-01-01',
        @convocatoriaId=@ConvocatoriaId OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH

    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- TEST 1
-- ============================================================================

PRINT '';
PRINT '>>> 1. TEST: torneo.sp_convocatoria_reemplazar';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - Debe registrarse el reemplazo.
--   - La convocatoria anterior debe quedar dada de baja.
--   - El nuevo jugador debe quedar convocado.
--   - Debe conservarse el dorsal.
--
-- Evidencia:
--   - SELECT sobre reemplazo_convocatoria.
--   - SELECT sobre convocatoria.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC torneo.sp_convocatoria_reemplazar
        @seleccionId=@SeleccionId,
        @jugadorBajaId=@JugadorBajaId,
        @jugadorAltaId=@JugadorAltaId,
        @motivo=N'Lesión',
        @fechaCambio='2026-06-01',
        @reemplazoId=@ReemplazoId OUTPUT;

    PRINT '[OK] Reemplazo realizado';

    SELECT
        'EVIDENCIA_REEMPLAZO' AS Prueba,
        *
    FROM torneo.reemplazo_convocatoria
    WHERE reemplazo_id=@ReemplazoId;

    SELECT
        'EVIDENCIA_CONVOCATORIAS' AS Prueba,
        *
    FROM torneo.convocatoria
    WHERE seleccion_id=@SeleccionId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe rechazarse la operación.
--
-- Motivo:
--   - El jugador de alta ya tiene una convocatoria vigente.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @DummyReemplazo INT;

    EXEC torneo.sp_convocatoria_reemplazar
        @seleccionId=@SeleccionId,
        @jugadorBajaId=@JugadorBajaId,
        @jugadorAltaId=@JugadorAltaId,
        @motivo=N'Segundo intento',
        @fechaCambio='2026-06-02',
        @reemplazoId=@DummyReemplazo OUTPUT;

    PRINT '[FALLO] Permitió realizar un reemplazo inválido';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- LIMPIEZA
-- ============================================================================

PRINT '';
PRINT '======================================================================';
PRINT ' LIMPIEZA DE DATOS DE PRUEBA';
PRINT '======================================================================';

BEGIN TRY

    DELETE
    FROM torneo.reemplazo_convocatoria
    WHERE reemplazo_id=@ReemplazoId;

    DELETE
    FROM torneo.convocatoria
    WHERE seleccion_id=@SeleccionId;

    DELETE
    FROM torneo.jugador
    WHERE jugador_id IN (@JugadorBajaId,@JugadorAltaId);

    DELETE
    FROM torneo.seleccion
    WHERE seleccion_id=@SeleccionId;

    DELETE
    FROM torneo.pais
    WHERE pais_id=@PaisId;

    DELETE
    FROM torneo.parametro_reglamento
    WHERE parametro_id=@ParametroId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();

END CATCH;

GO

EXEC sp_helptext 'torneo.sp_reemplazo_convocatoria_alta';
