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

CREATE OR ALTER VIEW torneo.vw_goleadores
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

CREATE OR ALTER VIEW torneo.vw_tarjetas_por_seleccion AS
SELECT
   s.nombre AS Seleccion,
   s.grupo AS Fase_Grupo,
   COUNT(t.tarjeta_id) AS Total_Tarjetas,
   SUM(CASE WHEN t.tipo = 'AMARILLA' THEN 1 ELSE 0 END) AS Tarjetas_Amarillas,
   SUM(CASE WHEN t.tipo = 'ROJA' THEN 1 ELSE 0 END) AS Tarjetas_Rojas,
   SUM(CASE WHEN t.tipo = 'AMARILLA' THEN 1 ELSE 0 END) + 
   (SUM(CASE WHEN t.tipo = 'ROJA' THEN 1 ELSE 0 END) * 3) AS Fair_Play_Negativo
FROM
   torneo.seleccion s
LEFT JOIN
   torneo.jugador j ON s.seleccion_id = (SELECT seleccion_id FROM torneo.convocatoria c WHERE c.jugador_id = j.jugador_id AND c.estado = 'VIGENTE')
LEFT JOIN
   torneo.tarjeta t ON j.jugador_id = t.jugador_id
GROUP BY
   s.nombre,
   s.grupo;
GO

