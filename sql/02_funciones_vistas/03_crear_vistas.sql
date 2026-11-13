/* ============================================================================

    Universidad : Universidad Nacional de La Matanza (UNLaM)
    Materia     : 3641 - Bases de Datos Aplicada
    Comision    : Com:5600      Grupo:09
    Integrantes : Gauto, Andino, Garbaccio, Dugo
    Fecha       : 08/11/2026
    Script      : 03_crear_vistas.sql
    Objetivo    : Capa semantica para la plataforma de BI (esquema bi).

    Cada vista encapsula una regla de negocio que, si no, habria que
    reimplementar en cada grafico:
            - bi.vw_partido              fixture + resultado en una fila (local y visitante son dos
                                    joins a seleccion) y quien gano, incluida la tanda de penales.
            - bi.vw_gol_detalle          que goles cuentan para el goleador y para el resultado.
            - bi.vw_tarjeta_detalle      a que seleccion pertenecia el jugador en ese partido.
            - bi.vw_ingreso_publicidad   importes normalizados a USD con la cotizacion vigente.
            - bi.vw_sede_mapa            coordenadas + ocupacion de estadio y de pauta por sede.

============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- bi.vw_gol_detalle
--   * Los goles del periodo PENALES (tanda) no suman al resultado ni al goleador.
--   * Un gol EN_CONTRA suma al resultado de la seleccion beneficiada
--     (gol.seleccion_id) pero no al goleador: el autor pertenece al rival.
-- ============================================================================
CREATE OR ALTER VIEW bi.vw_gol_detalle
AS
SELECT  g.gol_id,
        g.partido_id,
        p.fase,
        p.fecha_hora_utc,
        p.estado                AS estado_partido,
        s.seleccion_id,
        s.nombre                AS seleccion,
        j.jugador_id,
        j.nombre                AS jugador,
        ja.nombre               AS asistente,
        g.tipo_gol,
        g.periodo,
        g.minuto,
        CAST(CASE WHEN g.periodo <> 'PENALES' THEN 1 ELSE 0 END AS BIT)
                                AS cuenta_para_resultado,
        CAST(CASE WHEN g.periodo <> 'PENALES' AND g.tipo_gol <> 'EN_CONTRA' THEN 1 ELSE 0 END AS BIT)
                                AS cuenta_para_goleador
FROM torneo.gol AS g
         JOIN torneo.partido   AS p  ON p.partido_id   = g.partido_id
         JOIN torneo.seleccion AS s  ON s.seleccion_id = g.seleccion_id
         JOIN torneo.jugador   AS j  ON j.jugador_id   = g.jugador_id
         LEFT JOIN torneo.jugador AS ja ON ja.jugador_id = g.jugador_asistente_id;
GO

-- ============================================================================
-- bi.vw_tarjeta_detalle
-- Un registro por tarjeta. torneo.tarjeta no guarda la seleccion: se deriva de
-- la alineacion del jugador en ese partido.
-- ============================================================================
CREATE OR ALTER VIEW bi.vw_tarjeta_detalle
AS
SELECT  t.tarjeta_id,
        t.partido_id,
        p.fase,
        p.fecha_hora_utc,
        s.seleccion_id,
        s.nombre        AS seleccion,
        j.jugador_id,
        j.nombre        AS jugador,
        t.tipo,
        t.origen_roja,
        t.minuto
FROM torneo.tarjeta AS t
        JOIN torneo.partido            AS p  ON p.partido_id   = t.partido_id
        JOIN torneo.formacion_partido  AS f  ON f.partido_id   = t.partido_id
        JOIN torneo.alineacion_detalle AS ad ON ad.formacion_id = f.formacion_id
                                            AND ad.jugador_id   = t.jugador_id
        JOIN torneo.seleccion          AS s  ON s.seleccion_id = f.seleccion_id
        JOIN torneo.jugador            AS j  ON j.jugador_id   = t.jugador_id;
GO

-- ============================================================================
-- bi.vw_ingreso_publicidad
-- Un registro por espacio publicitario exhibido.
-- importe_usd usa la ultima cotizacion con fecha <= dia de emision, en
-- cualquiera de las dos direcciones cargadas en publicidad.tipo_cambio
-- (X->USD o USD->X). NULL = no hay cotizacion cargada para esa moneda/fecha;
-- el BI debe tratarlo como dato faltante, no como cero.
-- ============================================================================
CREATE OR ALTER VIEW bi.vw_ingreso_publicidad
AS
SELECT  pp.publicidad_id,
        pp.partido_id,
        p.fase,
        pp.momento_emision,
        sd.sede_id,
        sd.nombre_estadio       AS sede,
        pp.espacio,
        an.anunciante_id,
        an.nombre               AS anunciante,
        pa.nombre               AS pais_anunciante,
        c.campania_id,
        c.nombre                AS campania,
        pz.pieza_id,
        pz.nombre               AS pieza,
        pz.idioma,
        pp.importe_facturado,
        pp.moneda,
        CAST(pp.importe_facturado *
             CASE WHEN pp.moneda = 'USD' THEN 1.0 ELSE cot.tasa_a_usd END
             AS DECIMAL(14,2))  AS importe_usd
FROM publicidad.publicidad_partido AS pp
        JOIN torneo.partido                 AS p  ON p.partido_id    = pp.partido_id
        JOIN torneo.sede                    AS sd ON sd.sede_id      = p.sede_id
        JOIN publicidad.pieza_publicitaria  AS pz ON pz.pieza_id     = pp.pieza_id
        JOIN publicidad.campania            AS c  ON c.campania_id   = pz.campania_id
        JOIN publicidad.anunciante          AS an ON an.anunciante_id = c.anunciante_id
        JOIN torneo.pais                    AS pa ON pa.pais_id      = an.pais_id
        OUTER APPLY (
            SELECT TOP (1) x.tasa AS tasa_a_usd
            FROM (
                SELECT tc.fecha, tc.tasa
                FROM publicidad.tipo_cambio AS tc
                WHERE tc.moneda_origen = pp.moneda AND tc.moneda_destino = 'USD'
                UNION ALL
                SELECT tc.fecha, CAST(1.0 / tc.tasa AS DECIMAL(18,8))
                FROM publicidad.tipo_cambio AS tc
                WHERE tc.moneda_origen = 'USD' AND tc.moneda_destino = pp.moneda
            ) AS x
            WHERE x.fecha <= CAST(pp.momento_emision AS DATE)
            ORDER BY x.fecha DESC
        ) AS cot;
GO

-- ============================================================================
-- bi.vw_sede_mapa
-- Un registro por sede, con latitud/longitud para el mapa.
-- ============================================================================
CREATE OR ALTER VIEW bi.vw_sede_mapa
AS
WITH partidos AS (
    SELECT  p.sede_id,
            COUNT(*)                                                    AS partidos_total,
            COUNT(CASE WHEN p.estado = 'FINALIZADO' THEN 1 END)         AS partidos_finalizados,
            SUM(CAST(p.asistencia AS BIGINT))                           AS asistencia_total,
            AVG(CAST(p.asistencia AS DECIMAL(12,2)))                    AS asistencia_promedio
    FROM torneo.partido AS p
    GROUP BY p.sede_id
),
pauta AS (
    SELECT  p.sede_id,
            COUNT(*) AS espacios_asignados
    FROM publicidad.publicidad_partido AS pp
            JOIN torneo.partido AS p ON p.partido_id = pp.partido_id
    GROUP BY p.sede_id
)
SELECT  sd.sede_id,
        sd.nombre_estadio,
        sd.ciudad,
        pa.nombre                                   AS pais,
        sd.latitud,
        sd.longitud,
        sd.capacidad,
        sd.huso_horario,
        ISNULL(pt.partidos_total, 0)                AS partidos_total,
        ISNULL(pt.partidos_finalizados, 0)          AS partidos_finalizados,
        pt.asistencia_total,
        CAST(pt.asistencia_promedio AS DECIMAL(12,2))
                                                    AS asistencia_promedio,
        CAST(pt.asistencia_promedio * 100.0 / sd.capacidad AS DECIMAL(5,2))
                                                    AS ocupacion_estadio_pct,
        ISNULL(pu.espacios_asignados, 0)            AS espacios_publicitarios_asignados,
        ISNULL(pt.partidos_total, 0) * 4            AS espacios_publicitarios_posibles
FROM torneo.sede AS sd
        JOIN torneo.pais    AS pa ON pa.pais_id = sd.pais_id
        LEFT JOIN partidos  AS pt ON pt.sede_id = sd.sede_id
        LEFT JOIN pauta     AS pu ON pu.sede_id = sd.sede_id;
GO

-- ============================================================================
-- bi.vw_partido
-- Un registro por partido: fixture y resultado en la misma fila,
-- para filtrar por sede, fase, seleccion o fecha desde la herramienta de BI.
-- torneo.partido guarda goles_* sin la tanda de penales (la tanda se cuenta
-- aparte en penales_*), igual que torneo.sp_partido_finalizar.
-- ganador: NULL si el partido no esta FINALIZADO o si empato sin penales
-- (fase de grupos).
-- ============================================================================
CREATE OR ALTER VIEW bi.vw_partido
AS
SELECT  p.partido_id,
        p.fase,
        p.estado,
        p.fecha_hora_local,
        p.fecha_hora_utc,
        sd.sede_id,
        sd.nombre_estadio       AS sede,
        sd.ciudad,
        ps.nombre               AS pais_sede,
        sd.huso_horario,
        sl.seleccion_id         AS seleccion_local_id,
        sl.nombre               AS seleccion_local,
        sv.seleccion_id         AS seleccion_visitante_id,
        sv.nombre               AS seleccion_visitante,
        p.goles_local,
        p.goles_visitante,
        p.penales_local,
        p.penales_visitante,
        p.asistencia,
        CAST(p.asistencia * 100.0 / sd.capacidad AS DECIMAL(5,2))
                                AS ocupacion_estadio_pct,
        CASE WHEN p.estado <> 'FINALIZADO'                  THEN NULL
             WHEN p.goles_local    > p.goles_visitante      THEN sl.nombre
             WHEN p.goles_local    < p.goles_visitante      THEN sv.nombre
             WHEN p.penales_local  > p.penales_visitante    THEN sl.nombre
             WHEN p.penales_local  < p.penales_visitante    THEN sv.nombre
        END                     AS ganador
FROM torneo.partido AS p
        JOIN torneo.sede      AS sd ON sd.sede_id      = p.sede_id
        JOIN torneo.pais      AS ps ON ps.pais_id      = sd.pais_id
        JOIN torneo.seleccion AS sl ON sl.seleccion_id = p.seleccion_local_id
        JOIN torneo.seleccion AS sv ON sv.seleccion_id = p.seleccion_visitante_id;
GO