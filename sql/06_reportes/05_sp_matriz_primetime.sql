/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 05_sp_matriz_primetime.sql
   Objetivo    : Reporte de matriz prime time.
   ============================================================================ */

CREATE OR ALTER PROCEDURE reportes.sp_matriz_primetime
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.partido_id,
        p.fase,
        p.fecha_hora_utc,
        CASE
            WHEN DATEPART(HOUR,p.fecha_hora_utc)
                BETWEEN 19 AND 23
            THEN 'SI'
            ELSE 'NO'
        END AS horario_prime_time_utc

    FROM torneo.partido p
    ORDER BY
        p.fecha_hora_utc;

END;
GO