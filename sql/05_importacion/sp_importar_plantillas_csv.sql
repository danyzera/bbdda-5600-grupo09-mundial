/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : sp_importar_plantillas_csv.sql
   Objetivo    : Importar selecciones, jugadores y convocatorias desde CSV.
   ============================================================================ */

CREATE OR ALTER PROCEDURE importacion.sp_importar_plantillas_csv
    @archivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @importacionId INT;

    INSERT INTO importacion.importacion_log (origen, tipo_fuente, archivo)
    VALUES ('Importación Plantillas', 'CSV', @archivo);

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY
        IF OBJECT_ID('tempdb..#stg_plantilla') IS NOT NULL DROP TABLE #stg_plantilla;

        CREATE TABLE #stg_plantilla (
            iso_pais CHAR(3),
            nombre_seleccion NVARCHAR(100),
            confederacion VARCHAR(10),
            grupo CHAR(1),
            nombre_jugador NVARCHAR(150),
            fecha_nacimiento DATE,
            posicion VARCHAR(10),
            club_origen NVARCHAR(100),
            dorsal TINYINT,
            fecha_convocatoria DATE
        );

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = 'BULK INSERT #stg_plantilla FROM ''' + @archivo + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0D0A'', CODEPAGE = ''65001'');';
        EXEC (@sql);

        DECLARE @iso_pais CHAR(3), @nombre_seleccion NVARCHAR(100), @confederacion VARCHAR(10), @grupo CHAR(1);
        DECLARE @nombre_jugador NVARCHAR(150), @fecha_nacimiento DATE, @posicion VARCHAR(10), @club_origen NVARCHAR(100);
        DECLARE @dorsal TINYINT, @fecha_convocatoria DATE;

        DECLARE c_plantilla CURSOR LOCAL FAST_FORWARD FOR
        SELECT iso_pais, nombre_seleccion, confederacion, grupo, nombre_jugador, fecha_nacimiento, posicion, club_origen, dorsal, fecha_convocatoria
        FROM #stg_plantilla;

        OPEN c_plantilla;
        FETCH NEXT FROM c_plantilla INTO @iso_pais, @nombre_seleccion, @confederacion, @grupo, @nombre_jugador, @fecha_nacimiento, @posicion, @club_origen, @dorsal, @fecha_convocatoria;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            BEGIN TRY
                DECLARE @paisId INT = NULL, @seleccionId INT = NULL, @jugadorId INT = NULL, @convocatoriaId INT = NULL;

                -- 1. Buscar País
                SELECT @paisId = pais_id FROM torneo.pais WHERE codigo_iso = @iso_pais;

                IF @paisId IS NOT NULL
                BEGIN
                    -- 2. UPSERT Selección
                    SELECT @seleccionId = seleccion_id FROM torneo.seleccion WHERE pais_id = @paisId;

                    IF @seleccionId IS NULL
                    BEGIN
                        EXEC torneo.sp_seleccion_alta 
                            @paisId = @paisId, @nombre = @nombre_seleccion, @confederacion = @confederacion, 
                            @rankingFifa = NULL, @grupo = @grupo, @seleccionId = @seleccionId OUTPUT;
                    END
                    ELSE
                    BEGIN
                        -- TODO: Reemplazar con tu SP de modificación
                        PRINT 'Llamar a torneo.sp_seleccion_modificacion';
                    END

                    -- 3. UPSERT Jugador (Se valida por nombre y fecha nacimiento según tu SP)
                    SELECT @jugadorId = jugador_id FROM torneo.jugador WHERE nombre = @nombre_jugador AND fecha_nacimiento = @fecha_nacimiento;

                    IF @jugadorId IS NULL
                    BEGIN
                        EXEC torneo.sp_jugador_alta 
                            @nombre = @nombre_jugador, @fechaNacimiento = @fecha_nacimiento, @posicion = @posicion, 
                            @clubOrigen = @club_origen, @jugadorId = @jugadorId OUTPUT;
                    END
                    ELSE
                    BEGIN
                         -- TODO: Reemplazar con tu SP de modificación
                        PRINT 'Llamar a torneo.sp_jugador_modificacion';
                    END

                    -- 4. UPSERT Convocatoria
                    SELECT @convocatoriaId = convocatoria_id FROM torneo.convocatoria WHERE seleccion_id = @seleccionId AND jugador_id = @jugadorId AND estado = 'VIGENTE';

                    IF @convocatoriaId IS NULL
                    BEGIN
                        EXEC torneo.sp_convocatoria_alta 
                            @seleccionId = @seleccionId, @jugadorId = @jugadorId, @dorsal = @dorsal, 
                            @fechaConvocatoria = @fecha_convocatoria, @convocatoriaId = @convocatoriaId OUTPUT;
                    END

                    UPDATE importacion.importacion_log SET registros_leidos = registros_leidos + 1, registros_ok = registros_ok + 1 WHERE importacion_id = @importacionId;
                END
                ELSE
                BEGIN
                    INSERT INTO importacion.importacion_error (importacion_id, detalle) VALUES (@importacionId, 'País no encontrado: ' + @iso_pais);
                    UPDATE importacion.importacion_log SET registros_leidos = registros_leidos + 1, registros_error = registros_error + 1 WHERE importacion_id = @importacionId;
                END
            END TRY
            BEGIN CATCH
                INSERT INTO importacion.importacion_error (importacion_id, detalle) VALUES (@importacionId, ERROR_MESSAGE());
                UPDATE importacion.importacion_log SET registros_leidos = registros_leidos + 1, registros_error = registros_error + 1 WHERE importacion_id = @importacionId;
            END CATCH;

            FETCH NEXT FROM c_plantilla INTO @iso_pais, @nombre_seleccion, @confederacion, @grupo, @nombre_jugador, @fecha_nacimiento, @posicion, @club_origen, @dorsal, @fecha_convocatoria;
        END;

        CLOSE c_plantilla; DEALLOCATE c_plantilla;
        
        DECLARE @Errores INT;
        SELECT @Errores = registros_error FROM importacion.importacion_log WHERE importacion_id = @importacionId;
        UPDATE importacion.importacion_log SET estado = CASE WHEN @Errores = 0 THEN 'OK' ELSE 'PARCIAL' END, fecha_fin = SYSDATETIME() WHERE importacion_id = @importacionId;

    END TRY
    BEGIN CATCH
        UPDATE importacion.importacion_log SET estado = 'ERROR', fecha_fin = SYSDATETIME() WHERE importacion_id = @importacionId;
        THROW;
    END CATCH;
END;
GO