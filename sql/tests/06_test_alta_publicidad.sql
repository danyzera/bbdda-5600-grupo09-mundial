/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 06_test_alta_publicidad.sql

   Objetivo:
   Testing 1:1 de los procedimientos básicos de alta del esquema publicidad.

   Procedimientos probados:
   - publicidad.sp_anunciante_alta
   - publicidad.sp_campania_alta
   - publicidad.sp_pieza_publicitaria_alta
   - publicidad.sp_pieza_pais_alta

   IMPORTANTE:
   El script crea y elimina sus propios datos de prueba.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 06_test_alta_publicidad.sql';
PRINT '======================================================================';

DECLARE @PaisId INT;
DECLARE @AnuncianteId INT;
DECLARE @CampaniaId INT;
DECLARE @PiezaId INT;

-- ============================================================================
-- SETUP
-- ============================================================================

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_pais_alta
        @nombre='TEST_PAIS_06',
        @continente='AMERICA',
        @codigoIso='TPB',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisId OUTPUT;

    PRINT '[OK] Pais auxiliar creado';

END TRY
BEGIN CATCH

    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- TEST 1
-- ============================================================================

PRINT '';
PRINT '>>> 1. TEST: publicidad.sp_anunciante_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
-- Resultado esperado:
--   - Debe crearse correctamente un anunciante.
--   - Debe generarse un anunciante_id válido.
-- Evidencia:
--   - SELECT sobre publicidad.anunciante.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_anunciante_alta
        @nombre='ANUNCIANTE_TEST_06',
        @rubro='BEBIDAS',
        @email='test06@empresa.com',
        @paisId=@PaisId,
        @anuncianteId=@AnuncianteId OUTPUT;

    PRINT '[OK] Anunciante creado';

    SELECT
        'EVIDENCIA_ANUNCIANTE' AS Prueba,
        *
    FROM publicidad.anunciante
    WHERE anunciante_id = @AnuncianteId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
-- Resultado esperado:
--   - Debe lanzarse THROW 50301.
-- Motivo:
--   - Email inválido.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @DummyAnunciante INT;

    EXEC publicidad.sp_anunciante_alta
        @nombre='ANUNCIANTE_ERROR_06',
        @rubro='BEBIDAS',
        @email='EMAIL_INVALIDO',
        @paisId=@PaisId,
        @anuncianteId=@DummyAnunciante OUTPUT;

    PRINT '[FALLO] Permitió registrar email inválido';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- TEST 2
-- ============================================================================

PRINT '';
PRINT '>>> 2. TEST: publicidad.sp_campania_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
-- Resultado esperado:
--   - Debe registrarse una campaña.
-- Evidencia:
--   - SELECT sobre publicidad.campania.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_campania_alta
        @anuncianteId=@AnuncianteId,
        @nombre='CAMPANIA_TEST_06',
        @presupuesto=100000,
        @moneda='USD',
        @fechaInicio='2026-01-01',
        @fechaFin='2026-12-31',
        @campaniaId=@CampaniaId OUTPUT;

    PRINT '[OK] Campaña creada';

    SELECT
        'EVIDENCIA_CAMPANIA' AS Prueba,
        *
    FROM publicidad.campania
    WHERE campania_id = @CampaniaId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
-- Resultado esperado:
--   - Debe lanzarse THROW 50302.
-- Motivo:
--   - Fecha fin anterior a fecha inicio.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @DummyCampania INT;

    EXEC publicidad.sp_campania_alta
        @anuncianteId=@AnuncianteId,
        @nombre='CAMPANIA_ERROR_06',
        @presupuesto=1000,
        @moneda='USD',
        @fechaInicio='2026-12-31',
        @fechaFin='2026-01-01',
        @campaniaId=@DummyCampania OUTPUT;

    PRINT '[FALLO] Permitió fechas inválidas';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- TEST 3
-- ============================================================================

PRINT '';
PRINT '>>> 3. TEST: publicidad.sp_pieza_publicitaria_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
-- Resultado esperado:
--   - Debe registrarse la pieza publicitaria.
-- Evidencia:
--   - SELECT sobre publicidad.pieza_publicitaria.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_pieza_publicitaria_alta
        @campaniaId=@CampaniaId,
        @nombre='PIEZA_TEST_06',
        @idioma='ESPANOL',
        @piezaId=@PiezaId OUTPUT;

    PRINT '[OK] Pieza creada';

    SELECT
        'EVIDENCIA_PIEZA' AS Prueba,
        *
    FROM publicidad.pieza_publicitaria
    WHERE pieza_id = @PiezaId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
-- Resultado esperado:
--   - Debe lanzarse THROW 50303.
-- Motivo:
--   - Idioma vacío.
-- ---------------------------------------------------------------------------

BEGIN TRY

    DECLARE @DummyPieza INT;

    EXEC publicidad.sp_pieza_publicitaria_alta
        @campaniaId=@CampaniaId,
        @nombre='PIEZA_ERROR_06',
        @idioma='',
        @piezaId=@DummyPieza OUTPUT;

    PRINT '[FALLO] Permitió crear pieza sin idioma';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- TEST 4
-- ============================================================================

PRINT '';
PRINT '>>> 4. TEST: publicidad.sp_pieza_pais_alta';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
-- Resultado esperado:
--   - Debe asociarse la pieza al país.
-- Evidencia:
--   - SELECT sobre publicidad.pieza_pais.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_pieza_pais_alta
        @piezaId=@PiezaId,
        @paisId=@PaisId;

    PRINT '[OK] Asociación creada';

    SELECT
        'EVIDENCIA_PIEZA_PAIS' AS Prueba,
        *
    FROM publicidad.pieza_pais
    WHERE pieza_id = @PiezaId
      AND pais_id = @PaisId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
-- Resultado esperado:
--   - Debe lanzarse THROW 50304.
-- Motivo:
--   - Asociación duplicada.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_pieza_pais_alta
        @piezaId=@PiezaId,
        @paisId=@PaisId;

    PRINT '[FALLO] Permitió duplicar la asociación país-pieza';

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
    FROM publicidad.pieza_pais
    WHERE pieza_id = @PiezaId;

    DELETE
    FROM publicidad.pieza_publicitaria
    WHERE pieza_id = @PiezaId;

    DELETE
    FROM publicidad.campania
    WHERE campania_id = @CampaniaId;

    DELETE
    FROM publicidad.anunciante
    WHERE anunciante_id = @AnuncianteId;

    DELETE
    FROM torneo.pais
    WHERE pais_id = @PaisId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] Error durante la limpieza: '
        + ERROR_MESSAGE();

END CATCH;
GO