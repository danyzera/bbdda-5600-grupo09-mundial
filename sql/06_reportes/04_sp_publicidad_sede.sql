/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 04_sp_publicidad_sede.sql
   Objetivo    : Ocupación publicitaria por sede y partido.
   ============================================================================ */

CREATE OR ALTER PROCEDURE reportes.sp_publicidad_sede
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        se.nombre_estadio,
        p.partido_id,
        a.nombre AS anunciante,
        c.nombre AS campania,
        pp.espacio,
        pp.moneda,
        pp.importe_facturado,

        SUM(pp.importe_facturado)
        OVER(PARTITION BY p.partido_id)
        AS ingreso_total_partido

    FROM publicidad.publicidad_partido pp
        INNER JOIN torneo.partido p
            ON p.partido_id = pp.partido_id
        INNER JOIN torneo.sede se
            ON se.sede_id = p.sede_id
        INNER JOIN publicidad.pieza_publicitaria pie
            ON pie.pieza_id = pp.pieza_id
        INNER JOIN publicidad.campania c
            ON c.campania_id = pie.campania_id
        INNER JOIN publicidad.anunciante a
            ON a.anunciante_id = c.anunciante_id

    ORDER BY
        se.nombre_estadio,
        p.partido_id,
        pp.espacio;

END;
GO