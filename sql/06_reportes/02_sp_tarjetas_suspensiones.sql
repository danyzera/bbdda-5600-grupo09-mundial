/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 02_sp_tarjetas_suspensiones.sql
   Objetivo    : Tarjetas por selección y jugador con suspensiones.
   ============================================================================ */

CREATE OR ALTER PROCEDURE reportes.sp_tarjetas_suspensiones
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sel.nombre AS seleccion,
        j.nombre AS jugador,

        SUM(CASE
            WHEN t.tipo = 'AMARILLA'
            THEN 1
            ELSE 0
        END) AS amarillas,

        SUM(CASE
            WHEN t.tipo = 'ROJA'
            THEN 1
            ELSE 0
        END) AS rojas,
        COUNT(su.suspension_id) AS suspensiones_activas

    FROM torneo.jugador j
        INNER JOIN torneo.convocatoria c
            ON c.jugador_id = j.jugador_id
            AND c.estado = 'VIGENTE'
        INNER JOIN torneo.seleccion sel
            ON sel.seleccion_id = c.seleccion_id
        LEFT JOIN torneo.tarjeta t
            ON t.jugador_id = j.jugador_id
        LEFT JOIN torneo.suspension su
            ON su.jugador_id = j.jugador_id
            AND su.partidos_cumplidos < su.partidos_suspendidos
    GROUP BY
        sel.nombre,
        j.nombre
    ORDER BY
        amarillas DESC,
        rojas DESC;

END;
GO