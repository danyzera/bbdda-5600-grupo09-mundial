/* ============================================================================
   Universidad Nacional de La Matanza
   Materia: 3641 - Bases de Datos Aplicada
   Grupo 09

   Script: 20_test_publicidad_partido_asignar.sql

   Objetivo:
   Testing 1:1 de 20_sp_publicidad_partido_asignar.sql.

   Procedimiento probado:
   - publicidad.sp_publicidad_partido_asignar

   IMPORTANTE:
   El script genera sus propios datos de prueba y los elimina al finalizar.
   Asume una base vacía.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

PRINT '======================================================================';
PRINT ' TEST: 20_test_publicidad_partido_asignar.sql';
PRINT '======================================================================';

DECLARE @PaisLocalId INT;
DECLARE @PaisVisitanteId INT;
DECLARE @PaisMercadoId INT;

DECLARE @ParametroId INT;

DECLARE @SedeId INT;
DECLARE @SeleccionLocalId INT;
DECLARE @SeleccionVisitanteId INT;
DECLARE @PartidoId INT;

DECLARE @AnuncianteId INT;
DECLARE @CampaniaId INT;

DECLARE @Pieza1Id INT;
DECLARE @Pieza2Id INT;
DECLARE @Pieza3Id INT;
DECLARE @Pieza4Id INT;

DECLARE @Tarifa1Id INT;
DECLARE @Tarifa2Id INT;
DECLARE @Tarifa3Id INT;
DECLARE @Tarifa4Id INT;

-- ============================================================================
-- SETUP
-- ============================================================================

PRINT '';
PRINT '>>> SETUP DE DATOS';

BEGIN TRY

    EXEC torneo.sp_parametro_reglamento_alta
        @clave='MAX_SELECCIONES_GRUPO',
        @valor=4,
        @descripcion='Testing',
        @parametroId=@ParametroId OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_LOCAL_20',
        @continente='AMERICA',
        @codigoIso='PLL',
        @husoHorario='Argentina Standard Time',
        @paisId=@PaisLocalId OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_VISITA_20',
        @continente='EUROPA',
        @codigoIso='PVT',
        @husoHorario='UTC',
        @paisId=@PaisVisitanteId OUTPUT;

    EXEC torneo.sp_pais_alta
        @nombre='PAIS_MERCADO_20',
        @continente='ASIA',
        @codigoIso='PMC',
        @husoHorario='UTC',
        @paisId=@PaisMercadoId OUTPUT;

    EXEC torneo.sp_sede_alta
        @paisId=@PaisLocalId,
        @nombreEstadio='ESTADIO_20',
        @ciudad='CASANOVA',
        @capacidad=50000,
        @husoHorario='Argentina Standard Time',
        @sedeId=@SedeId OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@PaisLocalId,
        @nombre='SELECCION_A_20',
        @confederacion='CONMEBOL',
        @grupo='A',
        @seleccionId=@SeleccionLocalId OUTPUT;

    EXEC torneo.sp_seleccion_alta
        @paisId=@PaisVisitanteId,
        @nombre='SELECCION_B_20',
        @confederacion='UEFA',
        @grupo='A',
        @seleccionId=@SeleccionVisitanteId OUTPUT;

    EXEC torneo.sp_partido_alta
        @fase='GRUPOS',
        @sedeId=@SedeId,
        @seleccionLocalId=@SeleccionLocalId,
        @seleccionVisitanteId=@SeleccionVisitanteId,
        @fechaHoraLocal='2026-12-01 20:00',
        @partidoId=@PartidoId OUTPUT;

    EXEC publicidad.sp_anunciante_alta
        @nombre='ANUNCIANTE_20',
        @rubro='BEBIDAS',
        @email='test20@test.com',
        @paisId=@PaisMercadoId,
        @anuncianteId=@AnuncianteId OUTPUT;

    EXEC publicidad.sp_campania_alta
        @anuncianteId=@AnuncianteId,
        @nombre='CAMPANIA_20',
        @presupuesto=100000,
        @moneda='USD',
        @fechaInicio='2026-01-01',
        @fechaFin='2027-12-31',
        @campaniaId=@CampaniaId OUTPUT;

    EXEC publicidad.sp_pieza_publicitaria_alta
        @campaniaId=@CampaniaId,
        @nombre='PIEZA_20_A',
        @idioma='ESPANOL',
        @piezaId=@Pieza1Id OUTPUT;

    EXEC publicidad.sp_pieza_publicitaria_alta
        @campaniaId=@CampaniaId,
        @nombre='PIEZA_20_B',
        @idioma='ESPANOL',
        @piezaId=@Pieza2Id OUTPUT;

    EXEC publicidad.sp_pieza_publicitaria_alta
        @campaniaId=@CampaniaId,
        @nombre='PIEZA_20_C',
        @idioma='ESPANOL',
        @piezaId=@Pieza3Id OUTPUT;

    EXEC publicidad.sp_pieza_publicitaria_alta
        @campaniaId=@CampaniaId,
        @nombre='PIEZA_20_D',
        @idioma='ESPANOL',
        @piezaId=@Pieza4Id OUTPUT;

    EXEC publicidad.sp_pieza_pais_alta @piezaId=@Pieza1Id,@paisId=@PaisLocalId;
    EXEC publicidad.sp_pieza_pais_alta @piezaId=@Pieza2Id,@paisId=@PaisVisitanteId;
    EXEC publicidad.sp_pieza_pais_alta @piezaId=@Pieza3Id,@paisId=@PaisMercadoId;
    EXEC publicidad.sp_pieza_pais_alta @piezaId=@Pieza4Id,@paisId=@PaisMercadoId;

    EXEC publicidad.sp_tarifa_publicidad_alta
        @fase='GRUPOS',
        @espacio=1,
        @moneda='USD',
        @importe=1000,
        @tarifaId=@Tarifa1Id OUTPUT;

    EXEC publicidad.sp_tarifa_publicidad_alta
        @fase='GRUPOS',
        @espacio=2,
        @moneda='USD',
        @importe=1000,
        @tarifaId=@Tarifa2Id OUTPUT;

    EXEC publicidad.sp_tarifa_publicidad_alta
        @fase='GRUPOS',
        @espacio=3,
        @moneda='USD',
        @importe=1000,
        @tarifaId=@Tarifa3Id OUTPUT;

    EXEC publicidad.sp_tarifa_publicidad_alta
        @fase='GRUPOS',
        @espacio=4,
        @moneda='USD',
        @importe=1000,
        @tarifaId=@Tarifa4Id OUTPUT;

    PRINT '[OK] Datos auxiliares creados';

END TRY
BEGIN CATCH

    PRINT '[FALLO SETUP] ' + ERROR_MESSAGE();

END CATCH;

-- ============================================================================
-- TEST 1
-- ============================================================================

PRINT '';
PRINT '>>> 1. TEST: publicidad.sp_publicidad_partido_asignar';

-- ---------------------------------------------------------------------------
-- CASO EXITOSO
--
-- Resultado esperado:
--   - Deben asignarse exactamente 4 espacios publicitarios.
--
-- Evidencia:
--   - Se visualizarán los registros creados.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_publicidad_partido_asignar
        @idPartido=@PartidoId;

    PRINT '[OK] Publicidad asignada';

    SELECT
        'EVIDENCIA_PUBLICIDAD' AS Prueba,
        *
    FROM publicidad.publicidad_partido
    WHERE partido_id=@PartidoId;

END TRY
BEGIN CATCH

    PRINT '[FALLO INESPERADO] ' + ERROR_MESSAGE();

END CATCH;

-- ---------------------------------------------------------------------------
-- CASO ERROR
--
-- Resultado esperado:
--   - Debe rechazarse una segunda asignación.
-- ---------------------------------------------------------------------------

BEGIN TRY

    EXEC publicidad.sp_publicidad_partido_asignar
        @idPartido=@PartidoId;

    PRINT '[FALLO] Permitió asignar publicidad dos veces';

END TRY
BEGIN CATCH

    PRINT '[OK ESPERADO] ' + ERROR_MESSAGE();

END CATCH;

PRINT '';
PRINT '======================================================================';
PRINT ' LIMPIEZA DE DATOS DE PRUEBA';
PRINT '======================================================================';

BEGIN TRY

    DELETE FROM publicidad.publicidad_partido
    WHERE partido_id=@PartidoId;

    DELETE FROM publicidad.pieza_pais
    WHERE pieza_id IN (@Pieza1Id,@Pieza2Id,@Pieza3Id,@Pieza4Id);

    DELETE FROM publicidad.pieza_publicitaria
    WHERE pieza_id IN (@Pieza1Id,@Pieza2Id,@Pieza3Id,@Pieza4Id);

    DELETE FROM publicidad.campania
    WHERE campania_id=@CampaniaId;

    DELETE FROM publicidad.anunciante
    WHERE anunciante_id=@AnuncianteId;

    DELETE FROM publicidad.tarifa_publicidad
    WHERE tarifa_id IN (@Tarifa1Id,@Tarifa2Id,@Tarifa3Id,@Tarifa4Id);

    DELETE FROM torneo.partido
    WHERE partido_id=@PartidoId;

    DELETE FROM torneo.seleccion
    WHERE seleccion_id IN (@SeleccionLocalId,@SeleccionVisitanteId);

    DELETE FROM torneo.sede
    WHERE sede_id=@SedeId;

    DELETE FROM torneo.pais
    WHERE pais_id IN (@PaisLocalId,@PaisVisitanteId,@PaisMercadoId);

    DELETE FROM torneo.parametro_reglamento
    WHERE parametro_id=@ParametroId;

    PRINT '[OK] Datos de prueba eliminados correctamente.';

END TRY
BEGIN CATCH

    PRINT '[ADVERTENCIA] Error durante la limpieza: ' + ERROR_MESSAGE();

END CATCH;

GO