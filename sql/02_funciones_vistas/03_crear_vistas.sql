/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 03_crear_vistas.sql
   Objetivo    : Crear vistas para servir la app de datos tabulares
               sin necesidad de ejecutar un SP.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER VIEW torneo.vw_reporte_goleadores
WITH SCHEMABINDING AS
SELECT
   j.nombre AS Jugador,
   s.nombre AS Seleccion,
   s.grupo AS Fase_Grupo,
   COUNT(g.gol_id) AS Goles_Convertidos,
   SUM(CASE WHEN g.tipo_gol = 'JUGADA' THEN 1 ELSE 0 END) AS Goles_Jugada,
   SUM(CASE WHEN g.tipo_gol = 'PENAL' THEN 1 ELSE 0 END) AS Goles_Penal,
   SUM(CASE WHEN g.tipo_gol = 'TIRO_LIBRE' THEN 1 ELSE 0 END) AS Goles_Tiro_Libre,
   SUM(CASE WHEN g.tipo_gol = 'CABEZAZO' THEN 1 ELSE 0 END) AS Goles_Cabezazo
FROM
   torneo.gol g
      JOIN torneo.jugador j
            ON g.jugador_id = j.jugador_id
      JOIN torneo.seleccion s
            ON g.seleccion_id = s.seleccion_id
WHERE 
   g.tipo_gol <> 'EN_CONTRA' -- Los goles en contra nunca se contabilizan
GROUP BY 
   j.nombre,
   s.nombre,
   s.grupo;
GO