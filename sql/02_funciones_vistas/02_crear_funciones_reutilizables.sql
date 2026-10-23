/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 02_crear_funciones_reutilizables.sql
   Objetivo    : Funciones que retornan valores reutilizables, por ejemplo, en
                la implementación de los procedimientos almacenados. Al degradarse
                la performance en caso de no ser de una única línea de retorno, se
                fomenta que sean inliners para que el query optimizer no tenga
                problemas y no se provoquen penalizaciones en la performance.
   ============================================================================ */

Use MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER FUNCTION torneo.fn_obtener_alineacion_actual
(
    @idPartido          INT,
    @idSeleccion        INT,
    @minutoConsultado   SMALLINT
)
RETURNS TABLE
AS
RETURN
(
    WITH alineacionPlanteada (idPartido,idSeleccion,idJugador,esTitular,posicionEnCancha) AS
    (
        -- Titulares y suplentes de la formación de la selección (lo que importa para esta función son los jugadores)
        SELECT f.partido_id, f.seleccion_id, ad.jugador_id, ad.es_titular, j.posicion
        FROM torneo.formacion_partido AS f
                JOIN torneo.alineacion_detalle AS ad ON ad.formacion_id = f.formacion_id
                JOIN torneo.jugador AS j ON j.jugador_id = ad.jugador_id
                JOIN torneo.partido AS p ON p.partido_id = f.partido_id
        WHERE f.partido_id = @idPartido
                AND f.seleccion_id = @idSeleccion
                AND @idSeleccion IN (p.seleccion_local_id, p.seleccion_visitante_id)
                AND @minutoConsultado BETWEEN 0 AND 130
    ),
    cambiosHastaMomento (idJugadorSale,idJugadorEntra) AS
    (
        -- Cambios hasta el minuto consultado
        SELECT c.jugador_sale_id, c.jugador_entra_id
        FROM torneo.cambio AS c
        WHERE c.partido_id = @idPartido
                AND c.seleccion_id = @idSeleccion
                AND c.minuto <= @minutoConsultado
    )
    SELECT ap.idJugador, ap.posicionEnCancha
    FROM alineacionPlanteada AS ap
    WHERE
        -- Titular o entra por cambio
        (
            ap.esTitular = 1
            OR EXISTS (
                    SELECT 1
                    FROM cambiosHastaMomento AS c
                    WHERE c.idJugadorEntra = ap.idJugador )
        )

        -- No lo sustituyeron
        AND NOT EXISTS (
                SELECT 1
                FROM cambiosHastaMomento AS c
                WHERE c.idJugadorSale = ap.idJugador
        )

        -- No fue expulsado hasta el instante consultado
        AND NOT EXISTS (
                SELECT 1
                FROM torneo.tarjeta AS t
                WHERE t.partido_id = @idPartido
                        AND t.jugador_id = ap.jugador_id
                        AND t.tipo = 'ROJA'
                        AND t.minuto <= @minutoConsultado
        )
);
GO

-- CONTINUAR CON LAS DEMÁS

-- torneo.obtener_tabla_grupo
-- torneo.obtener_goleadores_global (quizás debería ser una vista)
-- torneo.obtener_resultado_en_vivo?
-- publicidad.obtener_cotizacion?