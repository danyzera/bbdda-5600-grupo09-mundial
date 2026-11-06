/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 03_sp_designaciones_arbitrales.sql
   Objetivo    : Historial de designaciones arbitrales.
   ============================================================================ */

CREATE OR ALTER PROCEDURE reportes.sp_designaciones_arbitrales
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH tarjetas_partido AS
    (
        SELECT
            partido_id,
            SUM(CASE WHEN tipo = 'AMARILLA' THEN 1 ELSE 0 END) AS amarillas,
            SUM(CASE WHEN tipo = 'ROJA' THEN 1 ELSE 0 END) AS rojas
        FROM torneo.tarjeta
        GROUP BY
            partido_id
    )
    SELECT
        a.nombre,
        a.categoria,
        da.rol_arbitral,

        COUNT(DISTINCT da.partido_id) AS partidos_dirigidos,

        ISNULL(SUM(tp.amarillas), 0) AS amarillas_senaladas,
        ISNULL(SUM(tp.rojas), 0) AS expulsiones_senaladas

    FROM arbitraje.designacion_arbitral da
        INNER JOIN arbitraje.arbitro a
            ON a.arbitro_id = da.arbitro_id

        LEFT JOIN tarjetas_partido tp
            ON tp.partido_id = da.partido_id

    GROUP BY
        a.arbitro_id,
        a.nombre,
        a.categoria,
        da.rol_arbitral

    ORDER BY
        partidos_dirigidos DESC,
        a.nombre;

END;
GO