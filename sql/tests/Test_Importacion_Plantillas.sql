/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : Test_Importacion_Plantillas.sql
   Objetivo    : Script de testing para la importación de plantillas (selecciones y jugadores).
   ============================================================================ */

USE MundialDB;
GO

PRINT '====================================================================';
PRINT '0. PREPARACIÓN DEL ENTORNO (SETUP DE PARÁMETROS)';
PRINT '====================================================================';
BEGIN TRY
    DECLARE @idParam INT;
    
    IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = 'MAX_CONVOCADOS')
        EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_CONVOCADOS', @valor = 26, @parametroId = @idParam OUTPUT;
        
    IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = 'MAX_SELECCIONES_GRUPO')
        EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_SELECCIONES_GRUPO', @valor = 4, @parametroId = @idParam OUTPUT;
        
    IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = 'MAX_SUPLENTES')
        EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_SUPLENTES', @valor = 15, @parametroId = @idParam OUTPUT;
        
    IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_REGULAR')
        EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_CAMBIOS_REGULAR', @valor = 5, @parametroId = @idParam OUTPUT;
        
    IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_SUPLEMENTARIO')
        EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_CAMBIOS_SUPLEMENTARIO', @valor = 1, @parametroId = @idParam OUTPUT;
        
    IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = 'MAX_VENTANAS')
        EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_VENTANAS', @valor = 3, @parametroId = @idParam OUTPUT;
        
    PRINT 'Parámetros requeridos configurados correctamente.';
END TRY
BEGIN CATCH
    PRINT 'Error al configurar parámetros: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '====================================================================';
PRINT 'TEST: IMPORTACIÓN DE PLANTILLAS';
PRINT '====================================================================';

-- 1. Definir ruta (Ruta corregida)
DECLARE @rutaPlantillas NVARCHAR(260) = 'C:\Users\maxim\Documents\maximo\.UNLAM\TP_DBA\sql\datasets\plantillas.csv';

BEGIN TRY
    PRINT 'Ejecutando sp_importar_plantillas_csv...';
    EXEC importacion.sp_importar_plantillas_csv @archivo = @rutaPlantillas;
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
WHERE origen = 'Importación Plantillas'
ORDER BY importacion_id DESC;
GO

PRINT '--- DETALLE DE ERRORES ---';
SELECT 
    e.importacion_id, 
    e.detalle AS motivo_del_rechazo
FROM importacion.importacion_error e
JOIN importacion.importacion_log l ON e.importacion_id = l.importacion_id
WHERE l.origen = 'Importación Plantillas'
  AND l.importacion_id = (SELECT MAX(importacion_id) FROM importacion.importacion_log WHERE origen = 'Importación Plantillas');
GO

PRINT '--- IMPACTO EN TABLAS DE NEGOCIO ---';
SELECT 
    p.codigo_iso,
    s.nombre AS seleccion,
    j.nombre AS jugador,
    j.posicion,
    c.dorsal,
    c.estado AS estado_convocatoria
FROM torneo.convocatoria c
JOIN torneo.seleccion s ON c.seleccion_id = s.seleccion_id
JOIN torneo.pais p ON s.pais_id = p.pais_id
JOIN torneo.jugador j ON c.jugador_id = j.jugador_id
ORDER BY s.nombre, c.dorsal;
GO

PRINT '====================================================================';
PRINT 'ZONA DE LIMPIEZA (TEARDOWN) - Ejecutar para repetir el test';
PRINT '====================================================================';

/*

BEGIN TRY
    PRINT 'Limpiando datos de negocio en orden inverso para no romper Foreign Keys...';
    
    -- 1. Borrar convocatorias de los jugadores de prueba
    DELETE FROM torneo.convocatoria 
    WHERE jugador_id IN (SELECT jugador_id FROM torneo.jugador WHERE nombre IN ('Lionel Messi', 'Emiliano Martinez', 'Pedri'));

    -- 2. Borrar los jugadores de prueba
    DELETE FROM torneo.jugador 
    WHERE nombre IN ('Lionel Messi', 'Emiliano Martinez', 'Pedri');

    -- 3. Borrar las selecciones de prueba
    DELETE FROM torneo.seleccion 
    WHERE nombre IN ('Argentina', 'España');

    -- 4. Borrar los parámetros de reglamento (OPCIONAL: Solo si quieres dejar la tabla totalmente vacía)
    DELETE FROM torneo.parametro_reglamento 
    WHERE clave IN ('MAX_CONVOCADOS', 'MAX_SELECCIONES_GRUPO', 'MAX_SUPLENTES', 'MAX_CAMBIOS_REGULAR', 'MAX_CAMBIOS_SUPLEMENTARIO', 'MAX_VENTANAS');

    PRINT 'Limpiando logs de la última ejecución...';
    DECLARE @ultimoId INT = (SELECT MAX(importacion_id) FROM importacion.importacion_log WHERE origen = 'Importación Plantillas');
    
    IF @ultimoId IS NOT NULL
    BEGIN
        DELETE FROM importacion.importacion_error WHERE importacion_id = @ultimoId;
        DELETE FROM importacion.importacion_log WHERE importacion_id = @ultimoId;
    END

    PRINT 'Limpieza completada con éxito. El entorno está listo para un nuevo test.';
END TRY
BEGIN CATCH
    PRINT 'Error durante la limpieza: ' + ERROR_MESSAGE();
END CATCH;
GO

*/