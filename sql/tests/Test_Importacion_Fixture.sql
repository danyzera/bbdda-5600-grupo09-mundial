/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : Test_Importacion_Fixture.sql
   Objetivo    : Script de testing para la importación del fixture de partidos.
   ============================================================================ */

USE MundialDB;
GO

PRINT '====================================================================';
PRINT '0. PREPARACIÓN DEL ENTORNO (SETUP DE DATOS)';
PRINT '====================================================================';

BEGIN TRY

    DECLARE @ParametroId INT;
    DECLARE @PaisArg INT;
    DECLARE @PaisBra INT;
    DECLARE @SedeId INT;
    DECLARE @SeleccionArg INT;
    DECLARE @SeleccionBra INT;

    IF NOT EXISTS (
        SELECT 1
        FROM torneo.parametro_reglamento
        WHERE clave = 'MAX_SELECCIONES_GRUPO'
    )
    BEGIN
        EXEC torneo.sp_parametro_reglamento_alta
            @clave = 'MAX_SELECCIONES_GRUPO',
            @valor = 4,
            @descripcion = 'Testing Fixture',
            @parametroId = @ParametroId OUTPUT;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM torneo.pais
        WHERE codigo_iso = 'ARG'
    )
    BEGIN
        EXEC torneo.sp_pais_alta
            @nombre='Argentina',
            @continente='AMERICA',
            @codigoIso='ARG',
            @husoHorario='Argentina Standard Time',
            @paisId=@PaisArg OUTPUT;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM torneo.pais
        WHERE codigo_iso = 'BRA'
    )
    BEGIN
        EXEC torneo.sp_pais_alta
            @nombre='Brasil',
            @continente='AMERICA',
            @codigoIso='BRA',
            @husoHorario='E. South America Standard Time',
            @paisId=@PaisBra OUTPUT;
    END

    SELECT @PaisArg = pais_id
    FROM torneo.pais
    WHERE codigo_iso='ARG';

    SELECT @PaisBra = pais_id
    FROM torneo.pais
    WHERE codigo_iso='BRA';

    IF NOT EXISTS (
        SELECT 1
        FROM torneo.sede
        WHERE nombre_estadio='ESTADIO_TEST_FIXTURE'
    )
    BEGIN
        EXEC torneo.sp_sede_alta
            @paisId=@PaisArg,
            @nombreEstadio='ESTADIO_TEST_FIXTURE',
            @ciudad='Buenos Aires',
            @capacidad=50000,
            @husoHorario='Argentina Standard Time',
            @sedeId=@SedeId OUTPUT;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM torneo.seleccion
        WHERE nombre='Argentina'
    )
    BEGIN
        EXEC torneo.sp_seleccion_alta
            @paisId=@PaisArg,
            @nombre='Argentina',
            @confederacion='CONMEBOL',
            @grupo='A',
            @seleccionId=@SeleccionArg OUTPUT;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM torneo.seleccion
        WHERE nombre='Brasil'
    )
    BEGIN
        EXEC torneo.sp_seleccion_alta
            @paisId=@PaisBra,
            @nombre='Brasil',
            @confederacion='CONMEBOL',
            @grupo='A',
            @seleccionId=@SeleccionBra OUTPUT;
    END

    PRINT 'Datos base preparados correctamente.';

END TRY
BEGIN CATCH

    PRINT 'Error durante preparación: ' + ERROR_MESSAGE();

END CATCH;
GO

PRINT '====================================================================';
PRINT 'TEST: IMPORTACIÓN DE FIXTURE';
PRINT '====================================================================';

DECLARE @rutaFixture NVARCHAR(260);

SET @rutaFixture =
'C:\Users\maxim\Documents\maximo\.UNLAM\TP_DBA\sql\datasets\fixture.csv';

BEGIN TRY

    PRINT 'Ejecutando sp_importar_fixture_csv...';

    EXEC importacion.sp_importar_fixture_csv
        @archivo = @rutaFixture;

END TRY
BEGIN CATCH

    PRINT 'Error en la ejecución general: ' + ERROR_MESSAGE();

END CATCH;
GO

PRINT '--- RESULTADO DEL LOG ---';

SELECT TOP 1
    importacion_id,
    origen,
    estado,
    registros_leidos,
    registros_ok,
    registros_error
FROM importacion.importacion_log
WHERE origen = 'Importación Fixture'
ORDER BY importacion_id DESC;
GO

PRINT '--- DETALLE DE ERRORES ---';

SELECT
    e.importacion_id,
    e.detalle AS motivo_del_rechazo
FROM importacion.importacion_error e
INNER JOIN importacion.importacion_log l
    ON e.importacion_id = l.importacion_id
WHERE l.origen = 'Importación Fixture'
AND l.importacion_id =
(
    SELECT MAX(importacion_id)
    FROM importacion.importacion_log
    WHERE origen = 'Importación Fixture'
);
GO

PRINT '--- IMPACTO EN TABLAS DE NEGOCIO ---';

SELECT
    p.partido_id,
    p.fase,
    se.nombre_estadio,
    sl.nombre AS local,
    sv.nombre AS visitante,
    p.fecha_hora_local,
    p.estado
FROM torneo.partido p
INNER JOIN torneo.sede se
    ON p.sede_id = se.sede_id
INNER JOIN torneo.seleccion sl
    ON p.seleccion_local_id = sl.seleccion_id
INNER JOIN torneo.seleccion sv
    ON p.seleccion_visitante_id = sv.seleccion_id
ORDER BY p.fecha_hora_local;
GO

PRINT '====================================================================';
PRINT 'ZONA DE LIMPIEZA (TEARDOWN)';
PRINT '====================================================================';

/*

BEGIN TRY

    DELETE FROM torneo.partido;

    DECLARE @ultimoId INT =
    (
        SELECT MAX(importacion_id)
        FROM importacion.importacion_log
        WHERE origen = 'Importación Fixture'
    );

    IF @ultimoId IS NOT NULL
    BEGIN
        DELETE FROM importacion.importacion_error
        WHERE importacion_id = @ultimoId;

        DELETE FROM importacion.importacion_log
        WHERE importacion_id = @ultimoId;
    END

    PRINT 'Limpieza completada correctamente.';

END TRY
BEGIN CATCH

    PRINT 'Error durante limpieza: ' + ERROR_MESSAGE();

END CATCH;
GO

*/