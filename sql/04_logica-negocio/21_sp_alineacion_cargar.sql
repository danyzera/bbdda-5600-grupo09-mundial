/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 05/11/2026
   Script      : 21_sp_alineacion_cargar.sql
   Objetivo    : Registrar la formación completa de una selección para un partido.
   Código de error del SP: 53302
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER PROCEDURE torneo.sp_alineacion_cargar
    @partidoId      INT,
    @seleccionId    INT,
    @esquema        VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @errores NVARCHAR(MAX) = N'',
            @nl NCHAR(2) = CHAR(13) + CHAR(10);

    DECLARE @formacionId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM torneo.partido
            WHERE partido_id = @partidoId
        )
            SET @errores += N'- El partido no existe.' + @nl;

        IF NOT EXISTS (
            SELECT 1
            FROM torneo.seleccion
            WHERE seleccion_id = @seleccionId
        )
            SET @errores += N'- La selección no existe.' + @nl;

        IF EXISTS (
            SELECT 1
            FROM torneo.formacion_partido
            WHERE partido_id = @partidoId
              AND seleccion_id = @seleccionId
        )
            SET @errores += N'- La alineación de la selección ya fue cargada para este partido.' + @nl;

        IF @errores <> N''
        BEGIN
            SET @errores =
                N'No se puede cargar la alineación:' + @nl + @errores;

            THROW 53302, @errores, 1;
        END;

        EXEC torneo.sp_formacion_partido_alta
            @partidoId   = @partidoId,
            @seleccionId = @seleccionId,
            @esquema     = @esquema,
            @formacionId = @formacionId OUTPUT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO