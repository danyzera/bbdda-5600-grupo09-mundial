/* ============================================================================
   REPORTES ENTREGA 7 - TESTING
   ============================================================================ */

USE MundialDB;
GO

PRINT '===========================================================';
PRINT 'REPORTE 1 - GOLEADORES';
PRINT '===========================================================';

EXEC reportes.sp_goleadores;
GO
EXEC reportes.sp_goleadores
    @fase = 'GRUPOS';
GO
EXEC reportes.sp_goleadores
    @seleccionId = 1;
GO
EXEC reportes.sp_goleadores
    @seleccionId = 1,
    @fase = 'GRUPOS';
GO


PRINT '===========================================================';
PRINT 'REPORTE 2 - TARJETAS Y SUSPENSIONES';
PRINT '===========================================================';

EXEC reportes.sp_tarjetas_suspensiones;
GO

PRINT '===========================================================';
PRINT 'REPORTE 3 - DESIGNACIONES ARBITRALES';
PRINT '===========================================================';

EXEC reportes.sp_designaciones_arbitrales;
GO

PRINT '===========================================================';
PRINT 'REPORTE 4 - PUBLICIDAD POR SEDE Y PARTIDO';
PRINT '===========================================================';

EXEC reportes.sp_publicidad_sede;
GO

PRINT '===========================================================';
PRINT 'REPORTE 5 - MATRIZ PRIME TIME';
PRINT '===========================================================';

EXEC reportes.sp_matriz_primetime;
GO

PRINT '===========================================================';
PRINT 'REPORTE 6 - SELECCIONES Y PLANTILLA (XML)';
PRINT '===========================================================';

EXEC reportes.sp_selecciones_plantilla_xml;
GO

PRINT '===========================================================';
PRINT 'REPORTE 7 - RESULTADOS DE ENCUENTROS (XML)';
PRINT '===========================================================';

EXEC reportes.sp_resultados_xml;
GO

PRINT '===========================================================';
PRINT 'CONTROL DE DATOS PARA LOS REPORTES';
PRINT '===========================================================';

SELECT 'Partidos' AS tabla, COUNT(*) AS cantidad
FROM torneo.partido
UNION ALL
SELECT 'Goles', COUNT(*)
FROM torneo.gol
UNION ALL
SELECT 'Tarjetas', COUNT(*)
FROM torneo.tarjeta
UNION ALL
SELECT 'Suspensiones', COUNT(*)
FROM torneo.suspension
UNION ALL
SELECT 'Arbitros', COUNT(*)
FROM arbitraje.arbitro
UNION ALL
SELECT 'Designaciones Arbitrales', COUNT(*)
FROM arbitraje.designacion_arbitral
UNION ALL
SELECT 'Publicidad Partido', COUNT(*)
FROM publicidad.publicidad_partido
UNION ALL
SELECT 'Selecciones', COUNT(*)
FROM torneo.seleccion
UNION ALL
SELECT 'Convocatorias', COUNT(*)
FROM torneo.convocatoria;
GO