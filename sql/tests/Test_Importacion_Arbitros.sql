/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : Test_Importacion_Arbitros.sql
   Objetivo    : Script de testing para la importación de árbitros desde XML.
   ============================================================================ */

USE MundialDB;
GO

PRINT '====================================================================';
PRINT '0. PREPARACIÓN DEL ENTORNO (SETUP DE DATOS)';
PRINT '====================================================================';

BEGIN TRY

    DECLARE @PaisArg INT;
    DECLARE @PaisEng INT;

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
        WHERE codigo_iso = 'ENG'
    )
    BEGIN
        EXEC torneo.sp_pais_alta
            @nombre='Inglaterra',
            @continente='EUROPA',
            @codigoIso='ENG',
            @husoHorario='GMT Standard Time',
            @paisId=@PaisEng OUTPUT;
    END

    PRINT 'Países auxiliares preparados correctamente.';

END TRY
BEGIN CATCH

    PRINT 'Error durante preparación: ' + ERROR_MESSAGE();

END CATCH;
GO

PRINT '====================================================================';
PRINT 'TEST: IMPORTACIÓN DE ÁRBITROS XML';
PRINT '====================================================================';

DECLARE @rutaArbitros NVARCHAR(260);

SET @rutaArbitros =
'C:\Users\maxim\Documents\maximo\.UNLAM\TP_DBA\sql\datasets\arbitros.xml';

BEGIN TRY

    PRINT 'Ejecutando sp_importar_arbitros_xml...';

    EXEC importacion.sp_importar_arbitros_xml
        @archivo = @rutaArbitros;

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
WHERE origen = 'Importación Arbitros'
ORDER BY importacion_id DESC;
GO

PRINT '--- DETALLE DE ERRORES ---';

SELECT
    e.importacion_id,
    e.detalle AS motivo_del_rechazo
FROM importacion.importacion_error e
INNER JOIN importacion.importacion_log l
    ON e.importacion_id = l.importacion_id
WHERE l.origen = 'Importación Arbitros'
AND l.importacion_id =
(
    SELECT MAX(importacion_id)
    FROM importacion.importacion_log
    WHERE origen = 'Importación Arbitros'
);
GO

PRINT '--- IMPACTO EN TABLAS DE NEGOCIO ---';

SELECT
    a.arbitro_id,
    a.nombre,
    p.codigo_iso,
    p.nombre AS pais,
    a.categoria
FROM arbitraje.arbitro a
JOIN torneo.pais p
    ON a.pais_id = p.pais_id
ORDER BY a.nombre;
GO

PRINT '====================================================================';
PRINT 'ZONA DE LIMPIEZA (TEARDOWN) - Ejecutar para repetir el test';
PRINT '====================================================================';

/*

BEGIN TRY

    PRINT 'Limpiando árbitros importados...';

    DELETE
    FROM arbitraje.arbitro
    WHERE nombre IN
    (
        'Facundo Tello',
        'Michael Oliver',
        'Arbitro Error'
    );

    DECLARE @ultimoId INT =
    (
        SELECT MAX(importacion_id)
        FROM importacion.importacion_log
        WHERE origen = 'Importación Arbitros'
    );

    IF @ultimoId IS NOT NULL
    BEGIN
        DELETE
        FROM importacion.importacion_error
        WHERE importacion_id = @ultimoId;

        DELETE
        FROM importacion.importacion_log
        WHERE importacion_id = @ultimoId;
    END

    PRINT 'Limpieza completada correctamente.';

END TRY
BEGIN CATCH

    PRINT 'Error durante limpieza: ' + ERROR_MESSAGE();

END CATCH;
GO

*/