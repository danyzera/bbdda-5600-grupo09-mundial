/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 05/11/2026
   Script      : 18_sp_convocatoria_reemplazar.sql
   Objetivo    : Ejecutar un reemplazo de convocatoria de forma transaccional.
                 Registra el reemplazo, da de baja la convocatoria vigente del
                 jugador saliente y genera la nueva convocatoria para el jugador
                 ingresante conservando el dorsal.
   Código error: 53201
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER PROCEDURE torneo.sp_convocatoria_reemplazar
    @seleccionId      INT,
    @jugadorBajaId    INT,
    @jugadorAltaId    INT,
    @motivo           NVARCHAR(200),
    @fechaCambio      DATE,
    @reemplazoId      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @errores NVARCHAR(MAX) = N'',
            @nl NCHAR(2) = CHAR(13) + CHAR(10);

    DECLARE @convocatoriaIdBaja INT,
            @dorsal TINYINT,
            @nuevaConvocatoriaId INT;

    BEGIN TRY

        BEGIN TRANSACTION;

        SELECT
            @convocatoriaIdBaja = convocatoria_id,
            @dorsal = dorsal
        FROM torneo.convocatoria
        WHERE seleccion_id = @seleccionId
          AND jugador_id = @jugadorBajaId
          AND estado = 'VIGENTE';

        IF NOT EXISTS (
            SELECT 1
            FROM torneo.seleccion
            WHERE seleccion_id = @seleccionId
        )
            SET @errores += N'- La selección no existe.' + @nl;

        IF @convocatoriaIdBaja IS NULL
            SET @errores += N'- El jugador de baja no posee una convocatoria vigente en la selección.' + @nl;

        IF NOT EXISTS (
            SELECT 1
            FROM torneo.jugador
            WHERE jugador_id = @jugadorAltaId
        )
            SET @errores += N'- El jugador de alta no existe.' + @nl;

        IF EXISTS (
            SELECT 1
            FROM torneo.convocatoria
            WHERE jugador_id = @jugadorAltaId
              AND estado = 'VIGENTE'
        )
            SET @errores += N'- El jugador de alta ya posee una convocatoria vigente.' + @nl;

        IF @jugadorBajaId = @jugadorAltaId
            SET @errores += N'- El jugador de baja y el de alta deben ser distintos.' + @nl;

        IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = N''
            SET @errores += N'- El motivo es obligatorio.' + @nl;

        IF @fechaCambio IS NULL
            SET @errores += N'- La fecha del cambio es obligatoria.' + @nl;

        IF @errores <> N''
        BEGIN
            SET @errores =
                N'No se pudo procesar el reemplazo de convocatoria:' +
                @nl +
                @errores;

            THROW 53201, @errores, 1;
        END;

        EXEC torneo.sp_reemplazo_convocatoria_alta
            @seleccionId   = @seleccionId,
            @jugadorBajaId = @jugadorBajaId,
            @jugadorAltaId = @jugadorAltaId,
            @motivo        = @motivo,
            @fechaCambio   = @fechaCambio,
            @reemplazoId   = @reemplazoId OUTPUT;

        EXEC torneo.sp_convocatoria_baja
            @convocatoriaId = @convocatoriaIdBaja,
            @fechaBaja      = @fechaCambio;

        EXEC torneo.sp_convocatoria_alta
            @seleccionId       = @seleccionId,
            @jugadorId         = @jugadorAltaId,
            @dorsal            = @dorsal,
            @fechaConvocatoria = @fechaCambio,
            @convocatoriaId    = @nuevaConvocatoriaId OUTPUT;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END;
GO