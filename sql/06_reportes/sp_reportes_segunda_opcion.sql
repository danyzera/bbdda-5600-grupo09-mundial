USE MundialDB;
GO
CREATE OR ALTER PROCEDURE torneo.sp_reporte_goleadores
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        sel.nombre AS Seleccion,
        j.nombre AS Jugador,
        COUNT(g.gol_id) AS TotalGoles
    FROM torneo.gol g
    JOIN torneo.jugador j ON g.jugador_id = j.jugador_id
    JOIN torneo.convocatoria c ON g.jugador_id = c.jugador_id AND c.seleccion_id = g.seleccion_id
    JOIN torneo.seleccion sel ON g.seleccion_id = sel.seleccion_id
    GROUP BY ROLLUP (sel.nombre, j.nombre);
END;
GO

CREATE OR ALTER PROCEDURE torneo.sp_reporte_tarjetas_suspensiones
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        sel.nombre AS Seleccion,
        j.nombre AS Jugador,
        SUM(CASE WHEN t.tipo = 'AMARILLA' THEN 1 ELSE 0 END) AS TotalAmarillas,
        SUM(CASE WHEN t.tipo IN ('ROJA', 'DOBLE_AMARILLA') THEN 1 ELSE 0 END) AS TotalRojas,
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM torneo.suspension s 
                WHERE s.jugador_id = j.jugador_id
            ) THEN 'SUSPENDIDO'
            ELSE 'HABILITADO'
        END AS EstadoSuspension
    FROM torneo.convocatoria c
    JOIN torneo.jugador j ON c.jugador_id = j.jugador_id
    JOIN torneo.seleccion sel ON c.seleccion_id = sel.seleccion_id
    LEFT JOIN torneo.tarjeta t ON t.jugador_id = j.jugador_id 
    WHERE c.estado = 'VIGENTE'
    GROUP BY sel.nombre, j.nombre, j.jugador_id;
END;
GO

CREATE OR ALTER PROCEDURE arbitraje.sp_reporte_designaciones_arbitros
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.nombre AS Arbitro,
        p.nombre AS PaisArbitro,
        pt.partido_id,
        sl.nombre AS Local,
        sv.nombre AS Visitante,
        da.rol_arbitral,
        COUNT(t.tarjeta_id) AS TarjetasMostradasEnPartido
    FROM arbitraje.designacion_arbitral da
    JOIN arbitraje.arbitro a ON da.arbitro_id = a.arbitro_id
    JOIN torneo.pais p ON a.pais_id = p.pais_id
    JOIN torneo.partido pt ON da.partido_id = pt.partido_id
    JOIN torneo.seleccion sl ON pt.seleccion_local_id = sl.seleccion_id
    JOIN torneo.seleccion sv ON pt.seleccion_visitante_id = sv.seleccion_id
    LEFT JOIN torneo.tarjeta t ON t.partido_id = pt.partido_id
    GROUP BY a.nombre, p.nombre, pt.partido_id, sl.nombre, sv.nombre, da.rol_arbitral;
END;
GO

CREATE OR ALTER PROCEDURE publicidad.sp_reporte_ocupacion_publicitaria
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.nombre_estadio AS SedeEstadio,
        p.partido_id,
        sl.nombre AS Local,
        sv.nombre AS Visitante,
        an.nombre AS Anunciante,
        pp.espacio,
        pp.importe_facturado,
        pp.moneda
    FROM publicidad.publicidad_partido pp
    JOIN torneo.partido p ON pp.partido_id = p.partido_id
    JOIN torneo.sede s ON p.sede_id = s.sede_id
    JOIN torneo.seleccion sl ON p.seleccion_local_id = sl.seleccion_id
    JOIN torneo.seleccion sv ON p.seleccion_visitante_id = sv.seleccion_id
    JOIN publicidad.pieza_publicitaria pz ON pp.pieza_id = pz.pieza_id
    JOIN publicidad.campania c ON pz.campania_id = c.campania_id
    JOIN publicidad.anunciante an ON c.anunciante_id = an.anunciante_id;
END;
GO

CREATE OR ALTER PROCEDURE publicidad.sp_reporte_matriz_prime_time
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.partido_id,
        sl.nombre + ' vs ' + sv.nombre AS Encuentro,
        p.fecha_hora_local,
        STUFF((
            SELECT DISTINCT ', ' + pais.nombre
            FROM publicidad.publicidad_partido pp2
            JOIN publicidad.pieza_publicitaria pz2 ON pp2.pieza_id = pz2.pieza_id
            JOIN publicidad.campania c2 ON pz2.campania_id = c2.campania_id
            JOIN publicidad.anunciante an2 ON c2.anunciante_id = an2.anunciante_id
            JOIN torneo.pais pais ON an2.pais_id = pais.pais_id
            WHERE pp2.partido_id = p.partido_id
            FOR XML PATH('')
        ), 1, 2, '') AS MercadosPrimeTimeActivos
    FROM torneo.partido p
    JOIN torneo.seleccion sl ON p.seleccion_local_id = sl.seleccion_id
    JOIN torneo.seleccion sv ON p.seleccion_visitante_id = sv.seleccion_id;
END;
GO

CREATE OR ALTER PROCEDURE torneo.sp_reporte_xml_selecciones_plantillas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.seleccion_id AS [@id],
        s.nombre AS [@nombre],
        s.grupo AS [@grupo],
        s.confederacion AS [@confederacion],
        (
            SELECT 
                j.jugador_id AS [@id],
                j.nombre AS [nombre],
                j.posicion AS [posicion],
                j.club_origen AS [club],
                c.dorsal AS [dorsal]
            FROM torneo.convocatoria c
            JOIN torneo.jugador j ON c.jugador_id = j.jugador_id
            WHERE c.seleccion_id = s.seleccion_id AND c.estado = 'VIGENTE'
            FOR XML PATH('Jugador'), TYPE
        ) AS Plantel
    FROM torneo.seleccion s
    FOR XML PATH('Seleccion'), ROOT('TorneoMundial');
END;
GO

CREATE OR ALTER PROCEDURE torneo.sp_reporte_xml_resultados_encuentros
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.partido_id AS [@id],
        p.fase AS [@fase],
        p.estado AS [@estado],
        p.fecha_hora_local AS [@fechaHora],
        s.nombre_estadio AS [Sede/Estadio],
        (SELECT nombre FROM torneo.seleccion WHERE seleccion_id = p.seleccion_local_id) AS [Local/Seleccion],
        ISNULL(p.goles_local, 0) AS [Local/Goles],
        (SELECT nombre FROM torneo.seleccion WHERE seleccion_id = p.seleccion_visitante_id) AS [Visitante/Seleccion],
        ISNULL(p.goles_visitante, 0) AS [Visitante/Goles]
    FROM torneo.partido p
    JOIN torneo.sede s ON p.sede_id = s.sede_id
    FOR XML PATH('Partido'), ROOT('ResultadosEncuentros');
END;
GO

EXEC torneo.sp_reporte_goleadores;
EXEC torneo.sp_reporte_tarjetas_suspensiones;
EXEC arbitraje.sp_reporte_designaciones_arbitros;
EXEC publicidad.sp_reporte_ocupacion_publicitaria;
EXEC publicidad.sp_reporte_matriz_prime_time;
EXEC torneo.sp_reporte_xml_selecciones_plantillas;
EXEC torneo.sp_reporte_xml_resultados_encuentros;