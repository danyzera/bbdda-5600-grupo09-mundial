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

    ;WITH tarjetas AS
    (
        SELECT
            j.jugador_id,
            SUM(CASE WHEN t.tipo = 'AMARILLA' THEN 1 ELSE 0 END) AS amarillas,
            SUM(CASE WHEN t.tipo = 'ROJA' THEN 1 ELSE 0 END) AS rojas
        FROM torneo.jugador j
        LEFT JOIN torneo.tarjeta t
            ON t.jugador_id = j.jugador_id
        GROUP BY
            j.jugador_id
    ),
    suspensiones AS
    (
        SELECT
            su.jugador_id,
            COUNT(*) AS suspensiones_activas
        FROM torneo.suspension su
        WHERE su.partidos_cumplidos < su.partidos_suspendidos
        GROUP BY
            su.jugador_id
    )
    SELECT
        sel.nombre AS seleccion,
        j.nombre AS jugador,
        ISNULL(t.amarillas, 0) AS amarillas,
        ISNULL(t.rojas, 0) AS rojas,
        ISNULL(s.suspensiones_activas, 0) AS suspensiones_activas
    FROM torneo.jugador j
        INNER JOIN torneo.convocatoria c
            ON c.jugador_id = j.jugador_id
           AND c.estado = 'VIGENTE'
        INNER JOIN torneo.seleccion sel
            ON sel.seleccion_id = c.seleccion_id
        LEFT JOIN tarjetas t
            ON t.jugador_id = j.jugador_id
        LEFT JOIN suspensiones s
            ON s.jugador_id = j.jugador_id
    ORDER BY
        amarillas DESC,
        rojas DESC,
        jugador;

END;
GO