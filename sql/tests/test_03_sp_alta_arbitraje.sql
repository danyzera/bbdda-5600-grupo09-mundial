-- ============================================================================
-- Universidad Nacional de La Matanza
-- Asignatura: 3641 - Bases de Datos Aplicada
-- Grupo 09
-- Objetivo: Testing 1:1 del script 03_sp_alta_arbitraje.sql (éxito y error)
-- ============================================================================

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 03_test_alta_arbitraje.sql                                     ';
PRINT '======================================================================';

-- SETUP: Obtenemos datos del seed para cumplir dependencias sin fallar por FK
DECLARE @PaisId INT = (SELECT TOP 1 pais_id FROM torneo.pais);
DECLARE @PartidoId INT = (SELECT TOP 1 partido_id FROM torneo.partido WHERE estado = 'PROGRAMADO');

-- Variables de salida
DECLARE @TestArbitroId INT;
DECLARE @TestDesignacionId INT;
DECLARE @TestRechazoId INT;
DECLARE @TestInformeId INT;

PRINT '';
PRINT '>>> 1. TEST: arbitraje.sp_arbitro_alta';
-- ----------------------------------------------------------------------------
-- Resultado esperado: Ejecución exitosa. Se inserta un árbitro y se genera su ID.
-- Evidencia: Se mostrará el registro recién insertado en arbitraje.arbitro.
BEGIN TRY
    EXEC arbitraje.sp_arbitro_alta 
        @nombre = 'Arbitro Test Alta', @paisId = @PaisId, @categoria = 'FIFA', 
        @arbitroId = @TestArbitroId OUTPUT;
    PRINT '    [OK] Árbitro dado de alta. ID: ' + CAST(@TestArbitroId AS VARCHAR);
    SELECT 'EVIDENCIA_ALTA_ARBITRO' AS Prueba, * FROM arbitraje.arbitro WHERE arbitro_id = @TestArbitroId;
END TRY
BEGIN CATCH PRINT '    [FALLO INESPERADO] ' + ERROR_MESSAGE(); END CATCH;

-- Resultado esperado: Error controlado. Fallará si intentamos dejar el nombre vacío (o NULL).
BEGIN TRY
    DECLARE @DummyId INT;
    EXEC arbitraje.sp_arbitro_alta @nombre = '', @paisId = @PaisId, @categoria = 'FIFA', @arbitroId = @DummyId OUTPUT;
    PRINT '    [FALLO] Permitió crear un árbitro sin nombre.';
END TRY
BEGIN CATCH PRINT '    [OK ESPERADO] ' + ERROR_MESSAGE(); END CATCH;

PRINT '';
PRINT '>>> 2. TEST: arbitraje.sp_arbitro_idioma_alta';
-- ----------------------------------------------------------------------------
-- Resultado esperado: Ejecución exitosa. Se registra el idioma para el árbitro.
-- Evidencia: Se mostrará el registro en arbitraje.arbitro_idioma.
BEGIN TRY
    EXEC arbitraje.sp_arbitro_idioma_alta @arbitroId = @TestArbitroId, @idioma = 'Inglés';
    PRINT '    [OK] Idioma registrado correctamente.';
    SELECT 'EVIDENCIA_ALTA_IDIOMA' AS Prueba, * FROM arbitraje.arbitro_idioma WHERE arbitro_id = @TestArbitroId;
END TRY
BEGIN CATCH PRINT '    [FALLO INESPERADO] ' + ERROR_MESSAGE(); END CATCH;

-- Resultado esperado: Error controlado (THROW 50202). Fallará al intentar duplicar el mismo idioma.
BEGIN TRY
    EXEC arbitraje.sp_arbitro_idioma_alta @arbitroId = @TestArbitroId, @idioma = 'Inglés';
    PRINT '    [FALLO] Permitió duplicar el idioma.';
END TRY
BEGIN CATCH PRINT '    [OK ESPERADO] ' + ERROR_MESSAGE(); END CATCH;

PRINT '';
PRINT '>>> 3. TEST: arbitraje.sp_designacion_arbitral_alta';
-- ----------------------------------------------------------------------------
-- Resultado esperado: Ejecución exitosa. Se asigna el árbitro a un partido programado.
-- Evidencia: Se mostrará el registro en arbitraje.designacion_arbitral.
BEGIN TRY
    EXEC arbitraje.sp_designacion_arbitral_alta 
        @partidoId = @PartidoId, @arbitroId = @TestArbitroId, @rolArbitral = 'PRINCIPAL', 
        @designacionId = @TestDesignacionId OUTPUT;
    PRINT '    [OK] Árbitro designado. ID Designación: ' + CAST(@TestDesignacionId AS VARCHAR);
    SELECT 'EVIDENCIA_ALTA_DESIGNACION' AS Prueba, * FROM arbitraje.designacion_arbitral WHERE designacion_id = @TestDesignacionId;
END TRY
BEGIN CATCH PRINT '    [FALLO INESPERADO] ' + ERROR_MESSAGE(); END CATCH;

-- Resultado esperado: Error controlado (THROW 50203). Fallará por rol inválido.
BEGIN TRY
    DECLARE @DummyDesig INT;
    EXEC arbitraje.sp_designacion_arbitral_alta 
        @partidoId = @PartidoId, @arbitroId = @TestArbitroId, @rolArbitral = 'INVENTO', @designacionId = @DummyDesig OUTPUT;
    PRINT '    [FALLO] Permitió asignar un rol arbitral que no existe.';
END TRY
BEGIN CATCH PRINT '    [OK ESPERADO] ' + ERROR_MESSAGE(); END CATCH;
GO