/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 06_sp_selecciones_plantilla_xml.sql
   Objetivo    : Selecciones con convocados en formato XML.
   ============================================================================ */

CREATE OR ALTER PROCEDURE reportes.sp_selecciones_plantilla_xml
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.nombre AS '@seleccion',
        (
            SELECT
                j.nombre AS '@nombre',
                j.posicion AS '@posicion',
                j.club_origen AS '@club',
                c.dorsal AS '@dorsal'

            FROM torneo.convocatoria c
                INNER JOIN torneo.jugador j
                    ON j.jugador_id = c.jugador_id
            WHERE
                c.seleccion_id = s.seleccion_id
                AND c.estado = 'VIGENTE'
            FOR XML PATH('jugador'), TYPE
        )

    FROM torneo.seleccion s
    FOR XML PATH('seleccion'), ROOT('selecciones');
END;
GO