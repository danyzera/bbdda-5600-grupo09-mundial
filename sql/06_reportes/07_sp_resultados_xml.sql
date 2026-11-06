/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 07_sp_resultados_xml.sql
   Objetivo    : Resultados de encuentros en XML.
   ============================================================================ */

CREATE OR ALTER PROCEDURE reportes.sp_resultados_xml
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        p.partido_id AS '@id',
        p.fase AS '@fase',
        sl.nombre AS '@local',
        sv.nombre AS '@visitante',
        p.goles_local AS '@goles_local',
        p.goles_visitante AS '@goles_visitante',
        p.penales_local AS '@penales_local',
        p.penales_visitante AS '@penales_visitante'

    FROM torneo.partido p
        INNER JOIN torneo.seleccion sl
            ON sl.seleccion_id = p.seleccion_local_id
        INNER JOIN torneo.seleccion sv
            ON sv.seleccion_id = p.seleccion_visitante_id

    FOR XML PATH('partido'), ROOT('resultados');
END;
GO