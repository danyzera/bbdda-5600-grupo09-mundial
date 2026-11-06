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

    SELECT
        a.nombre,
        a.categoria,
        da.rol_arbitral,
        COUNT(*) AS partidos_dirigidos
    FROM arbitraje.designacion_arbitral da
        INNER JOIN arbitraje.arbitro a
            ON a.arbitro_id = da.arbitro_id
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