/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : Test_Importacion_Paises.sql
   Objetivo    : Script de testing para la importación de países.
   ============================================================================ */

USE MundialDB;
GO

PRINT '====================================================================';
PRINT 'TEST: IMPORTACIÓN DE PAÍSES';
PRINT '====================================================================';

-- 1. Definir ruta (ajustar según el entorno)
DECLARE @rutaPaises NVARCHAR(260) = 'C:\Users\maxim\Documents\maximo\.UNLAM\TP_DBA\sql\datasets\paises.csv';

BEGIN TRY
    PRINT 'Ejecutando sp_importar_paises_csv...';
    EXEC importacion.sp_importar_paises_csv @archivo = @rutaPaises;
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
WHERE origen = 'Importación Países'
ORDER BY importacion_id DESC;
GO

PRINT '--- DETALLE DE ERRORES ---';
SELECT 
    e.importacion_id, 
    e.detalle AS motivo_del_rechazo
FROM importacion.importacion_error e
JOIN importacion.importacion_log l ON e.importacion_id = l.importacion_id
WHERE l.origen = 'Importación Países'
  AND l.importacion_id = (SELECT MAX(importacion_id) FROM importacion.importacion_log WHERE origen = 'Importación Países');
GO

PRINT '--- IMPACTO EN LA TABLA DE NEGOCIO ---';
SELECT 
    pais_id, 
    nombre, 
    continente, 
    codigo_iso, 
    huso_horario, 
    pbi_per_capita, 
    pbi_anio 
FROM torneo.pais;
GO

PRINT '====================================================================';
PRINT 'ZONA DE LIMPIEZA (TEARDOWN) - Ejecutar para repetir el test';
PRINT '====================================================================';

/*

BEGIN TRY
    PRINT 'Limpiando datos de negocio (Países insertados por el CSV)...';
    -- Borramos por los códigos ISO que sabemos que vienen en el archivo de prueba
    DELETE FROM torneo.pais 
    WHERE codigo_iso IN ('ARG', 'BRA', 'ESP', 'XX');

    PRINT 'Limpiando logs de la última ejecución...';
    DECLARE @ultimoId INT = (SELECT MAX(importacion_id) FROM importacion.importacion_log WHERE origen = 'Importación Países');
    
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