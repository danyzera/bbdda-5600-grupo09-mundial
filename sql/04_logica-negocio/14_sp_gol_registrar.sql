/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 14_sp_gol_registrar.sql
   Objetivo    : Registrar un gol durante un partido. Reutiliza la función que
                consulta el equipo en un minuto dado (el minuto del gol)
   Código de error del SP: 53102, en concordancia con la nomenclatura.
   ============================================================================ */


USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER PROCEDURE torneo.sp_gol_registrar
    @partidoId             INT,
    @seleccionId           INT,
    @jugadorId             INT,
    @jugadorAsistenteId    INT = NULL,
    @minuto                SMALLINT,
    @tipoGol               VARCHAR(12),
    @periodo               VARCHAR(15),
    @golId                 INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE     @errores            NVARCHAR(MAX)   = N'',
                @saltoDeLinea       NCHAR(2)        = CHAR(13) + CHAR(10);
    DECLARE     @estadoPartido      VARCHAR(12);
    DECLARE     @localId            INT,
                @visitanteId        INT,
                @seleccionAutorId   INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @estadoPartido   = estado,
               @localId         = seleccion_local_id,
               @visitanteId     = seleccion_visitante_id
        FROM torneo.partido AS p
        WHERE p.partido_id = @partidoId;

        IF @estadoPartido IS NULL
            SET @errores += N'- El partido especificado no existe.' + @saltoDeLinea;
        ELSE IF @estadoPartido <> 'EN_CURSO'
            SET @errores += N'- Las incidencias solo pueden registrarse en partidos EN_CURSO.' + @saltoDeLinea;

        SET @seleccionAutorId = IIF(
            @tipoGol = 'EN_CONTRA',
            IIF(
                @seleccionId = @localId,
                @visitanteId,
                @localId
            ),
            @seleccionId
        );

        IF @estadoPartido = 'EN_CURSO'
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM torneo.fn_obtener_alineacion_actual(@partidoId, @seleccionAutorId, @minuto) 
                WHERE idJugador = @jugadorId
            )
                SET @errores += N'- El autor del gol no se encontraba físicamente en la cancha en ese minuto.' + @saltoDeLinea;

            IF @jugadorAsistenteId IS NOT NULL 
            BEGIN
                IF NOT EXISTS (
                    SELECT 1
                    FROM torneo.fn_obtener_alineacion_actual(@partidoId, @seleccionId, @minuto) 
                    WHERE idJugador = @jugadorAsistenteId
                )
                    SET @errores += N'- El asistente no se encontraba físicamente en la cancha en ese minuto.' + @saltoDeLinea;
            END
        END

        IF @errores <> N''
        BEGIN
            SET @errores = N'No se puede procesar el registro del gol:' + @saltoDeLinea + @errores;
            THROW 53102, @errores, 1;
        END;

        EXEC torneo.sp_gol_alta 
            @partidoId          = @partidoId,
            @seleccionId        = @seleccionId,
            @jugadorId          = @jugadorId,
            @jugadorAsistenteId = @jugadorAsistenteId,
            @minuto             = @minuto,
            @tipoGol            = @tipoGol,
            @periodo            = @periodo,
            @golId              = @golId OUTPUT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO