/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : sp_importar_fixture_csv.sql
   Objetivo    : Importar el fixture de partidos desde archivo CSV.
   ============================================================================ */

CREATE OR ALTER PROCEDURE importacion.sp_importar_fixture_csv
    @archivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @importacionId INT;

    INSERT INTO importacion.importacion_log (origen, tipo_fuente, archivo)
    VALUES ('Importación Fixture', 'CSV', @archivo);

    SET @importacionId = SCOPE_IDENTITY();

    BEGIN TRY
        IF OBJECT_ID('tempdb..#stg_fixture') IS NOT NULL DROP TABLE #stg_fixture;

        CREATE TABLE #stg_fixture (
            fase VARCHAR(15),
            nombre_estadio NVARCHAR(100),
            iso_local CHAR(3),
            iso_visitante CHAR(3),
            fecha_hora_local DATETIME2(0)
        );

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = 'BULK INSERT #stg_fixture FROM ''' + @archivo + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0D0A'', CODEPAGE = ''65001'');';
        EXEC (@sql);

        DECLARE @fase VARCHAR(15), @nombre_estadio NVARCHAR(100), @iso_local CHAR(3), @iso_visitante CHAR(3), @fecha_hora_local DATETIME2(0);

        DECLARE c_fixture CURSOR LOCAL FAST_FORWARD FOR
        SELECT fase, nombre_estadio, iso_local, iso_visitante, fecha_hora_local FROM #stg_fixture;

        OPEN c_fixture;
        FETCH NEXT FROM c_fixture INTO @fase, @nombre_estadio, @iso_local, @iso_visitante, @fecha_hora_local;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            BEGIN TRY
                DECLARE @sedeId INT = NULL, @seleccionLocalId INT = NULL, @seleccionVisitanteId INT = NULL, @partidoId INT = NULL;

                -- Buscar Sede
                SELECT @sedeId = sede_id FROM torneo.sede WHERE nombre_estadio = @nombre_estadio;
                
                -- Buscar Selecciones cruzando con la tabla país
                SELECT @seleccionLocalId = s.seleccion_id FROM torneo.seleccion s JOIN torneo.pais p ON s.pais_id = p.pais_id WHERE p.codigo_iso = @iso_local;
                SELECT @seleccionVisitanteId = s.seleccion_id FROM torneo.seleccion s JOIN torneo.pais p ON s.pais_id = p.pais_id WHERE p.codigo_iso = @iso_visitante;

                IF @sedeId IS NOT NULL AND @seleccionLocalId IS NOT NULL AND @seleccionVisitanteId IS NOT NULL
                BEGIN
                    -- UPSERT: Buscar si el partido ya existe
                    SELECT @partidoId = partido_id FROM torneo.partido 
                    WHERE fase = @fase AND seleccion_local_id = @seleccionLocalId AND seleccion_visitante_id = @seleccionVisitanteId;

                    IF @partidoId IS NULL
                    BEGIN
                        EXEC torneo.sp_partido_alta 
                            @fase = @fase, @sedeId = @sedeId, @seleccionLocalId = @seleccionLocalId, 
                            @seleccionVisitanteId = @seleccionVisitanteId, @fechaHoraLocal = @fecha_hora_local, 
                            @partidoId = @partidoId OUTPUT;
                    END
                    ELSE
                    BEGIN
                         -- TODO: Reemplazar con tu SP de modificación
                        PRINT 'Llamar a torneo.sp_partido_modificacion';
                    END

                    UPDATE importacion.importacion_log SET registros_leidos = registros_leidos + 1, registros_ok = registros_ok + 1 WHERE importacion_id = @importacionId;
                END
                ELSE
                BEGIN
                    DECLARE @errorMsg NVARCHAR(200) = 'Faltan datos de base: ' + 
                        CASE WHEN @sedeId IS NULL THEN 'Estadio ' ELSE '' END + 
                        CASE WHEN @seleccionLocalId IS NULL THEN 'Local ' ELSE '' END + 
                        CASE WHEN @seleccionVisitanteId IS NULL THEN 'Visitante' ELSE '' END;
                    INSERT INTO importacion.importacion_error (importacion_id, detalle) VALUES (@importacionId, @errorMsg);
                    UPDATE importacion.importacion_log SET registros_leidos = registros_leidos + 1, registros_error = registros_error + 1 WHERE importacion_id = @importacionId;
                END
            END TRY
            BEGIN CATCH
                INSERT INTO importacion.importacion_error (importacion_id, detalle) VALUES (@importacionId, ERROR_MESSAGE());
                UPDATE importacion.importacion_log SET registros_leidos = registros_leidos + 1, registros_error = registros_error + 1 WHERE importacion_id = @importacionId;
            END CATCH;

            FETCH NEXT FROM c_fixture INTO @fase, @nombre_estadio, @iso_local, @iso_visitante, @fecha_hora_local;
        END;

        CLOSE c_fixture; DEALLOCATE c_fixture;

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