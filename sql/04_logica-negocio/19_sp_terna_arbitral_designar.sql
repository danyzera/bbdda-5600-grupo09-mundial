/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 22/10/2026
   Script      : 19_sp_terna_arbitral_designar.sql
   Objetivo    : Procedimiento almacenado que designa a la terna arbitral 
                 completa para un partido en una única transacción. Atrapa 
                 rechazos por nacionalidad en una variable de tabla para 
                 persistirlos a pesar del rollback en caso de error.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE OR ALTER PROCEDURE arbitraje.sp_terna_arbitral_designar
    @idPartido      INT,
    @idPrincipal    INT,
    @idAsistente1   INT,
    @idAsistente2   INT,
    @idCuarto       INT,
    @idVar          INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @errores        NVARCHAR(MAX) = N'', 
            @saltoDeLinea   NCHAR(2) = CHAR(13) + CHAR(10);
            
    DECLARE @estadoPartido  VARCHAR(12),
            @paisLocal      INT,
            @paisVisitante  INT,
            @designacionId  INT; -- Para recibir el output de las altas

    -- Variable de tabla para capturar rechazos.
    DECLARE @Rechazos TABLE (
        arbitro_id   INT,
        rol_arbitral VARCHAR(10),
        motivo       NVARCHAR(200)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Obtener estado del partido y países (bloqueo por concurrencia)
        SELECT  @estadoPartido = p.estado,
                @paisLocal = sl.pais_id,
                @paisVisitante = sv.pais_id
        FROM torneo.partido p WITH (UPDLOCK)
        JOIN torneo.seleccion sl ON p.seleccion_local_id = sl.seleccion_id
        JOIN torneo.seleccion sv ON p.seleccion_visitante_id = sv.seleccion_id
        WHERE p.partido_id = @idPartido;

        IF @estadoPartido IS NULL
            SET @errores += N'- El partido especificado no existe.' + @saltoDeLinea;
        ELSE IF @estadoPartido <> 'PROGRAMADO'
            SET @errores += N'- Solo se pueden designar árbitros para partidos PROGRAMADOS.' + @saltoDeLinea;

        -- 2. Validar que no se ingrese el mismo árbitro en distintos roles
        IF @idPrincipal IN (@idAsistente1, @idAsistente2, @idCuarto, @idVar) OR
           @idAsistente1 IN (@idAsistente2, @idCuarto, @idVar) OR
           @idAsistente2 IN (@idCuarto, @idVar) OR
           @idCuarto = @idVar
        BEGIN
            SET @errores += N'- Un árbitro no puede ocupar más de un rol en el mismo partido.' + @saltoDeLinea;
        END

        IF @estadoPartido = 'PROGRAMADO'
        BEGIN
            -- 3. Pre-validación de nacionalidad
            
            -- Árbitro Principal
            IF EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @idPrincipal AND pais_id IN (@paisLocal, @paisVisitante))
            BEGIN
                INSERT INTO @Rechazos (arbitro_id, rol_arbitral, motivo) 
                VALUES (@idPrincipal, 'PRINCIPAL', N'Conflicto de nacionalidad con una de las selecciones.');
                SET @errores += N'- El árbitro principal tiene conflicto de nacionalidad.' + @saltoDeLinea;
            END

            -- Asistente 1
            IF EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @idAsistente1 AND pais_id IN (@paisLocal, @paisVisitante))
            BEGIN
                INSERT INTO @Rechazos (arbitro_id, rol_arbitral, motivo) 
                VALUES (@idAsistente1, 'ASISTENTE', N'Conflicto de nacionalidad con una de las selecciones.');
                SET @errores += N'- El asistente 1 tiene conflicto de nacionalidad.' + @saltoDeLinea;
            END

            -- Asistente 2
            IF EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @idAsistente2 AND pais_id IN (@paisLocal, @paisVisitante))
            BEGIN
                INSERT INTO @Rechazos (arbitro_id, rol_arbitral, motivo) 
                VALUES (@idAsistente2, 'ASISTENTE', N'Conflicto de nacionalidad con una de las selecciones.');
                SET @errores += N'- El asistente 2 tiene conflicto de nacionalidad.' + @saltoDeLinea;
            END

            -- Cuarto Árbitro
            IF EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @idCuarto AND pais_id IN (@paisLocal, @paisVisitante))
            BEGIN
                INSERT INTO @Rechazos (arbitro_id, rol_arbitral, motivo) 
                VALUES (@idCuarto, 'CUARTO', N'Conflicto de nacionalidad con una de las selecciones.');
                SET @errores += N'- El cuarto árbitro tiene conflicto de nacionalidad.' + @saltoDeLinea;
            END

            -- VAR
            IF EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @idVar AND pais_id IN (@paisLocal, @paisVisitante))
            BEGIN
                INSERT INTO @Rechazos (arbitro_id, rol_arbitral, motivo) 
                VALUES (@idVar, 'VAR', N'Conflicto de nacionalidad con una de las selecciones.');
                SET @errores += N'- El árbitro de VAR tiene conflicto de nacionalidad.' + @saltoDeLinea;
            END
        END

        IF @errores <> N''
        BEGIN
            SET @errores = N'No se pudo designar la terna arbitral:' + @saltoDeLinea + @errores;
            THROW 53201, @errores, 1;
        END

        -- 4. Si llegamos sin errores, delegamos el alta a los ABMs.
        EXEC arbitraje.sp_designacion_arbitral_alta @partidoId = @idPartido, @arbitroId = @idPrincipal,  @rolArbitral = 'PRINCIPAL', @designacionId = @designacionId OUTPUT;
        EXEC arbitraje.sp_designacion_arbitral_alta @partidoId = @idPartido, @arbitroId = @idAsistente1, @rolArbitral = 'ASISTENTE', @designacionId = @designacionId OUTPUT;
        EXEC arbitraje.sp_designacion_arbitral_alta @partidoId = @idPartido, @arbitroId = @idAsistente2, @rolArbitral = 'ASISTENTE', @designacionId = @designacionId OUTPUT;
        EXEC arbitraje.sp_designacion_arbitral_alta @partidoId = @idPartido, @arbitroId = @idCuarto,     @rolArbitral = 'CUARTO',    @designacionId = @designacionId OUTPUT;
        EXEC arbitraje.sp_designacion_arbitral_alta @partidoId = @idPartido, @arbitroId = @idVar,        @rolArbitral = 'VAR',       @designacionId = @designacionId OUTPUT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        IF EXISTS (SELECT 1 FROM @Rechazos)
        BEGIN
            INSERT INTO arbitraje.designacion_rechazada (partido_id, arbitro_id, rol_arbitral, motivo)
            SELECT @idPartido, arbitro_id, rol_arbitral, motivo 
            FROM @Rechazos;
        END;
        ;THROW; 
    END CATCH
END;
GO