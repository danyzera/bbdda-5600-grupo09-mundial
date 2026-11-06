/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 01_sp_goleadores.sql
   Objetivo    : Goleadores por selección y fase.
   ============================================================================ */

CREATE OR ALTER PROCEDURE reportes.sp_goleadores
(
    @seleccionId INT = NULL,
    @fase VARCHAR(15) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.nombre AS seleccion,
        p.fase,
        j.nombre AS jugador,
        COUNT(*) AS goles
    FROM torneo.gol g
        INNER JOIN torneo.partido p
            ON p.partido_id = g.partido_id
        INNER JOIN torneo.jugador j
            ON j.jugador_id = g.jugador_id
        INNER JOIN torneo.seleccion s
            ON s.seleccion_id = g.seleccion_id
    WHERE
        (@seleccionId IS NULL OR s.seleccion_id = @seleccionId)
        AND (@fase IS NULL OR p.fase = @fase)
    GROUP BY
        s.nombre,
        p.fase,
        j.nombre
    ORDER BY
        goles DESC,
        jugador;

END;
GO