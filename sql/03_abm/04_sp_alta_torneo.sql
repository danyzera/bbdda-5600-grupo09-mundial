/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 04_sp_alta_torneo.sql
   Objetivo    : Procedimientos almacenados de ALTA del esquema torneo.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- torneo.pais 
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_pais_alta
    @nombre        NVARCHAR(100),
    @continente    NVARCHAR(50),
    @codigoIso     VARCHAR(10),
    @husoHorario   VARCHAR(100),
    @pbiPerCapita  DECIMAL(12,2) = NULL,
    @pbiAnio       SMALLINT      = NULL,
    @paisId        INT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.pais WHERE nombre = LTRIM(RTRIM(@nombre)))
        SET @errores += N'- Ya existe un pa�s con ese nombre.' + @nl;

    IF @continente IS NULL OR LTRIM(RTRIM(@continente)) = N''
        SET @errores += N'- El continente es obligatorio.' + @nl;

    IF @codigoIso IS NULL OR @codigoIso NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- El c�digo ISO debe tener exactamente 3 letras.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.pais WHERE codigo_iso = @codigoIso)
        SET @errores += N'- Ya existe un pa�s con ese c�digo ISO.' + @nl;

    IF @husoHorario IS NULL OR NOT EXISTS (SELECT 1 FROM sys.time_zone_info WHERE name = @husoHorario)
        SET @errores += N'- El huso horario no es v�lido (usar nombres de sys.time_zone_info).' + @nl;

    IF @pbiPerCapita IS NOT NULL AND @pbiPerCapita <= 0
        SET @errores += N'- El PBI per c�pita debe ser mayor a cero.' + @nl;
    IF (@pbiPerCapita IS NULL AND @pbiAnio IS NOT NULL) OR (@pbiPerCapita IS NOT NULL AND @pbiAnio IS NULL)
        SET @errores += N'- El PBI y su a�o deben informarse juntos.' + @nl;
    IF @pbiAnio IS NOT NULL AND (@pbiAnio < 1960 OR @pbiAnio > YEAR(SYSDATETIME()))
        SET @errores += N'- El a�o del PBI est� fuera de rango.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el pa�s:' + @nl + @errores;
        THROW 50101, @errores, 1;
    END;

    INSERT INTO torneo.pais (nombre, continente, codigo_iso, huso_horario, pbi_per_capita, pbi_anio)
    VALUES (LTRIM(RTRIM(@nombre)), LTRIM(RTRIM(@continente)), UPPER(@codigoIso), @husoHorario, @pbiPerCapita, @pbiAnio);

    SET @paisId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.sede
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_sede_alta
    @paisId         INT,
    @nombreEstadio  NVARCHAR(100),
    @ciudad         NVARCHAR(100),
    @capacidad      INT,
    @husoHorario    VARCHAR(100),
    @latitud        DECIMAL(9,6) = NULL,
    @longitud       DECIMAL(9,6) = NULL,
    @sedeId         INT          OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El pa�s no existe.' + @nl;

    IF @nombreEstadio IS NULL OR LTRIM(RTRIM(@nombreEstadio)) = N''
        SET @errores += N'- El nombre del estadio es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.sede WHERE nombre_estadio = LTRIM(RTRIM(@nombreEstadio)))
        SET @errores += N'- Ya existe un estadio con ese nombre.' + @nl;

    IF @ciudad IS NULL OR LTRIM(RTRIM(@ciudad)) = N''
        SET @errores += N'- La ciudad es obligatoria.' + @nl;

    IF @capacidad IS NULL OR @capacidad <= 0
        SET @errores += N'- La capacidad debe ser mayor a cero.' + @nl;

    IF @husoHorario IS NULL OR NOT EXISTS (SELECT 1 FROM sys.time_zone_info WHERE name = @husoHorario)
        SET @errores += N'- El huso horario no es v�lido (usar nombres de sys.time_zone_info).' + @nl;

    IF (@latitud IS NULL AND @longitud IS NOT NULL) OR (@latitud IS NOT NULL AND @longitud IS NULL)
        SET @errores += N'- Latitud y longitud deben informarse juntas.' + @nl;
    IF @latitud IS NOT NULL AND @latitud NOT BETWEEN -90 AND 90
        SET @errores += N'- La latitud debe estar entre -90 y 90.' + @nl;
    IF @longitud IS NOT NULL AND @longitud NOT BETWEEN -180 AND 180
        SET @errores += N'- La longitud debe estar entre -180 y 180.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la sede:' + @nl + @errores;
        THROW 50102, @errores, 1;
    END;

    INSERT INTO torneo.sede (pais_id, nombre_estadio, ciudad, capacidad, huso_horario, latitud, longitud)
    VALUES (@paisId, LTRIM(RTRIM(@nombreEstadio)), LTRIM(RTRIM(@ciudad)), @capacidad, @husoHorario, @latitud, @longitud);

    SET @sedeId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.seleccion
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_seleccion_alta
    @paisId         INT,
    @nombre         NVARCHAR(100),
    @confederacion  VARCHAR(10),
    @rankingFifa    SMALLINT = NULL,
    @grupo          CHAR(1)  = NULL,
    @seleccionId    INT      OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @maxGrupo INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_SELECCIONES_GRUPO');

    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El pa�s no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.seleccion WHERE pais_id = @paisId)
        SET @errores += N'- El pa�s ya tiene una selecci�n registrada.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.seleccion WHERE nombre = LTRIM(RTRIM(@nombre)))
        SET @errores += N'- Ya existe una selecci�n con ese nombre.' + @nl;

    IF @confederacion IS NULL OR @confederacion NOT IN ('UEFA','CONMEBOL','CONCACAF','CAF','AFC','OFC')
        SET @errores += N'- La confederaci�n debe ser UEFA, CONMEBOL, CONCACAF, CAF, AFC u OFC.' + @nl;

    IF @rankingFifa IS NOT NULL AND @rankingFifa <= 0
        SET @errores += N'- El ranking FIFA debe ser mayor a cero.' + @nl;

    IF @grupo IS NOT NULL AND @grupo NOT LIKE '[A-L]'
        SET @errores += N'- El grupo debe ser una letra entre A y L.' + @nl;
    IF @grupo IS NOT NULL AND @maxGrupo IS NOT NULL
       AND (SELECT COUNT(*) FROM torneo.seleccion WHERE grupo = @grupo) >= @maxGrupo
        SET @errores += N'- El grupo ya alcanz� el m�ximo de selecciones permitido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la selecci�n:' + @nl + @errores;
        THROW 50103, @errores, 1;
    END;

    INSERT INTO torneo.seleccion (pais_id, nombre, confederacion, ranking_fifa, grupo)
    VALUES (@paisId, LTRIM(RTRIM(@nombre)), @confederacion, @rankingFifa, UPPER(@grupo));

    SET @seleccionId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.cuerpo_tecnico
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_cuerpo_tecnico_alta
    @seleccionId   INT,
    @nombre        NVARCHAR(150),
    @rol           VARCHAR(10),
    @nacionalidad  NVARCHAR(100),
    @cuerpoId      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selecci�n no existe.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cuerpo_tecnico
               WHERE seleccion_id = @seleccionId AND nombre = LTRIM(RTRIM(@nombre)))
        SET @errores += N'- La persona ya integra el cuerpo t�cnico de esa selecci�n.' + @nl;

    IF @rol IS NULL OR @rol NOT IN ('DT','AT','PF')
        SET @errores += N'- El rol debe ser DT, AT o PF.' + @nl;
    IF @rol = 'DT' AND EXISTS (SELECT 1 FROM torneo.cuerpo_tecnico WHERE seleccion_id = @seleccionId AND rol = 'DT')
        SET @errores += N'- La selecci�n ya tiene un director t�cnico.' + @nl;

    IF @nacionalidad IS NULL OR LTRIM(RTRIM(@nacionalidad)) = N''
        SET @errores += N'- La nacionalidad es obligatoria.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el integrante del cuerpo t�cnico:' + @nl + @errores;
        THROW 50104, @errores, 1;
    END;

    INSERT INTO torneo.cuerpo_tecnico (seleccion_id, nombre, rol, nacionalidad)
    VALUES (@seleccionId, LTRIM(RTRIM(@nombre)), @rol, LTRIM(RTRIM(@nacionalidad)));

    SET @cuerpoId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.jugador
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_jugador_alta
    @nombre            NVARCHAR(150),
    @fechaNacimiento   DATE,
    @posicion          VARCHAR(10),
    @clubOrigen        NVARCHAR(100) = NULL,
    @jugadorId         INT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;

    IF @fechaNacimiento IS NULL
        SET @errores += N'- La fecha de nacimiento es obligatoria.' + @nl;
    IF @fechaNacimiento IS NOT NULL
       AND (@fechaNacimiento > CAST(SYSDATETIME() AS DATE) OR @fechaNacimiento < '19000101')
        SET @errores += N'- La fecha de nacimiento est� fuera de rango.' + @nl;

    IF EXISTS (SELECT 1 FROM torneo.jugador
               WHERE nombre = LTRIM(RTRIM(@nombre)) AND fecha_nacimiento = @fechaNacimiento)
        SET @errores += N'- Ya existe un jugador con el mismo nombre y fecha de nacimiento.' + @nl;

    IF @posicion IS NULL OR @posicion NOT IN ('ARQ','DEF','MED','DEL')
        SET @errores += N'- La posici�n debe ser ARQ, DEF, MED o DEL.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el jugador:' + @nl + @errores;
        THROW 50105, @errores, 1;
    END;

    INSERT INTO torneo.jugador (nombre, fecha_nacimiento, posicion, club_origen)
    VALUES (LTRIM(RTRIM(@nombre)), @fechaNacimiento, @posicion, @clubOrigen);

    SET @jugadorId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.convocatoria
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_convocatoria_alta
    @seleccionId         INT,
    @jugadorId           INT,
    @dorsal              TINYINT,
    @fechaConvocatoria   DATE,
    @convocatoriaId      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @maxConvocados INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_CONVOCADOS');

    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selecci�n no existe.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.convocatoria WHERE jugador_id = @jugadorId AND estado = 'VIGENTE')
        SET @errores += N'- El jugador ya tiene una convocatoria vigente.' + @nl;

    IF @dorsal IS NULL OR @dorsal NOT BETWEEN 1 AND 99
        SET @errores += N'- El dorsal debe estar entre 1 y 99.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.convocatoria
               WHERE seleccion_id = @seleccionId AND dorsal = @dorsal AND estado = 'VIGENTE')
        SET @errores += N'- El dorsal ya est� asignado a otro convocado de la selecci�n.' + @nl;

    IF @fechaConvocatoria IS NULL
        SET @errores += N'- La fecha de convocatoria es obligatoria.' + @nl;

    IF @maxConvocados IS NULL
        SET @errores += N'- Falta configurar el par�metro MAX_CONVOCADOS en el reglamento.' + @nl;
    IF @maxConvocados IS NOT NULL
       AND (SELECT COUNT(*) FROM torneo.convocatoria WHERE seleccion_id = @seleccionId AND estado = 'VIGENTE') >= @maxConvocados
        SET @errores += N'- La selecci�n ya alcanz� el m�ximo de convocados permitido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la convocatoria:' + @nl + @errores;
        THROW 50106, @errores, 1;
    END;

    INSERT INTO torneo.convocatoria (seleccion_id, jugador_id, dorsal, fecha_convocatoria, estado)
    VALUES (@seleccionId, @jugadorId, @dorsal, @fechaConvocatoria, 'VIGENTE');

    SET @convocatoriaId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.reemplazo_convocatoria 
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_reemplazo_convocatoria_alta
    @seleccionId     INT,
    @jugadorBajaId   INT,
    @jugadorAltaId   INT,
    @motivo          NVARCHAR(200),
    @fechaCambio     DATE,
    @reemplazoId     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selecci�n no existe.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorBajaId)
        SET @errores += N'- El jugador de baja no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE seleccion_id = @seleccionId AND jugador_id = @jugadorBajaId)
        SET @errores += N'- El jugador de baja no pertenece al plantel de la selecci�n.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorAltaId)
        SET @errores += N'- El jugador de alta no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE seleccion_id = @seleccionId AND jugador_id = @jugadorAltaId)
        SET @errores += N'- El jugador de alta no pertenece al plantel de la selecci�n.' + @nl;

    IF @jugadorBajaId = @jugadorAltaId
        SET @errores += N'- El jugador de baja y el de alta deben ser distintos.' + @nl;

    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = N''
        SET @errores += N'- El motivo es obligatorio.' + @nl;

    IF @fechaCambio IS NULL
        SET @errores += N'- La fecha del cambio es obligatoria.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el reemplazo de convocatoria:' + @nl + @errores;
        THROW 50107, @errores, 1;
    END;

    INSERT INTO torneo.reemplazo_convocatoria (seleccion_id, jugador_baja_id, jugador_alta_id, motivo, fecha_cambio)
    VALUES (@seleccionId, @jugadorBajaId, @jugadorAltaId, LTRIM(RTRIM(@motivo)), @fechaCambio);

    SET @reemplazoId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.partido
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_partido_alta
    @fase                   VARCHAR(15),
    @sedeId                 INT,
    @seleccionLocalId       INT,
    @seleccionVisitanteId   INT,
    @fechaHoraLocal         DATETIME2(0),
    @partidoId              INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @huso VARCHAR(100), @fechaHoraUtc DATETIME2(0),
            @grupoLocal CHAR(1), @grupoVisitante CHAR(1),
            @minSede INT = ISNULL((SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MIN_MINUTOS_ENTRE_PARTIDOS_SEDE'), 180),
            @minSeleccion INT = ISNULL((SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MIN_MINUTOS_DESCANSO_SELECCION'), 2880);

    SELECT @huso = huso_horario FROM torneo.sede WHERE sede_id = @sedeId;
    SELECT @grupoLocal = grupo FROM torneo.seleccion WHERE seleccion_id = @seleccionLocalId;
    SELECT @grupoVisitante = grupo FROM torneo.seleccion WHERE seleccion_id = @seleccionVisitanteId;

    IF @fase IS NULL OR @fase NOT IN ('GRUPOS','DIECISEISAVOS','OCTAVOS','CUARTOS','SEMIFINAL','TERCER_PUESTO','FINAL')
        SET @errores += N'- La fase no es v�lida.' + @nl;

    IF @huso IS NULL
        SET @errores += N'- La sede no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionLocalId)
        SET @errores += N'- La selecci�n local no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionVisitanteId)
        SET @errores += N'- La selecci�n visitante no existe.' + @nl;
    IF @seleccionLocalId = @seleccionVisitanteId
        SET @errores += N'- La selecci�n local y la visitante deben ser distintas.' + @nl;

    IF @fechaHoraLocal IS NULL
        SET @errores += N'- La fecha y hora local son obligatorias.' + @nl;

    IF @huso IS NOT NULL AND @fechaHoraLocal IS NOT NULL
        SET @fechaHoraUtc = CAST((@fechaHoraLocal AT TIME ZONE @huso) AT TIME ZONE 'UTC' AS DATETIME2(0));

    IF @fase = 'GRUPOS'
       AND (@grupoLocal IS NULL OR @grupoVisitante IS NULL OR @grupoLocal <> @grupoVisitante)
        SET @errores += N'- En fase de grupos ambas selecciones deben tener el mismo grupo asignado.' + @nl;

    IF EXISTS (SELECT 1 FROM torneo.partido
               WHERE fase = @fase
                 AND ((seleccion_local_id = @seleccionLocalId AND seleccion_visitante_id = @seleccionVisitanteId)
                   OR (seleccion_local_id = @seleccionVisitanteId AND seleccion_visitante_id = @seleccionLocalId)))
        SET @errores += N'- Esas selecciones ya tienen un partido cargado en esa fase.' + @nl;

    IF @fechaHoraUtc IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.partido
                   WHERE sede_id = @sedeId
                     AND ABS(DATEDIFF(MINUTE, fecha_hora_utc, @fechaHoraUtc)) < @minSede)
        SET @errores += N'- La sede ya tiene un partido en un rango menor al margen m�nimo permitido.' + @nl;

    IF @fechaHoraUtc IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.partido
                   WHERE (seleccion_local_id IN (@seleccionLocalId, @seleccionVisitanteId)
                       OR seleccion_visitante_id IN (@seleccionLocalId, @seleccionVisitanteId))
                     AND ABS(DATEDIFF(MINUTE, fecha_hora_utc, @fechaHoraUtc)) < @minSeleccion)
        SET @errores += N'- Alguna de las selecciones juega otro partido sin el descanso m�nimo requerido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el partido:' + @nl + @errores;
        THROW 50108, @errores, 1;
    END;

    INSERT INTO torneo.partido (fase, sede_id, seleccion_local_id, seleccion_visitante_id,
                                fecha_hora_local, fecha_hora_utc, estado)
    VALUES (@fase, @sedeId, @seleccionLocalId, @seleccionVisitanteId,
            @fechaHoraLocal, @fechaHoraUtc, 'PROGRAMADO');

    SET @partidoId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.formacion_partido
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_formacion_partido_alta
    @partidoId     INT,
    @seleccionId   INT,
    @esquema       VARCHAR(20),
    @formacionId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE partido_id = @partidoId)
        SET @errores += N'- El partido no existe.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selecci�n no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.partido
                   WHERE partido_id = @partidoId
                     AND @seleccionId IN (seleccion_local_id, seleccion_visitante_id))
        SET @errores += N'- La selecci�n no participa de ese partido.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.formacion_partido WHERE partido_id = @partidoId AND seleccion_id = @seleccionId)
        SET @errores += N'- La selecci�n ya tiene formaci�n cargada para ese partido.' + @nl;

    IF @esquema IS NULL OR LEN(@esquema) > 10
       OR @esquema NOT LIKE '[0-9]-%' OR @esquema LIKE '%[^0-9-]%'
        SET @errores += N'- El esquema debe tener formato num�rico separado por guiones (ej. 4-3-3).' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la formaci�n:' + @nl + @errores;
        THROW 50109, @errores, 1;
    END;

    INSERT INTO torneo.formacion_partido (partido_id, seleccion_id, esquema)
    VALUES (@partidoId, @seleccionId, @esquema);

    SET @formacionId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.alineacion_detalle
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_alineacion_detalle_alta
    @formacionId    INT,
    @jugadorId      INT,
    @posicionCampo  VARCHAR(20) = NULL,
    @esTitular      BIT,
    @alineacionId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @seleccionId INT, @fechaPartido DATE,
            @maxSuplentes INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_SUPLENTES');

    SELECT @partidoId = f.partido_id, @seleccionId = f.seleccion_id,
           @fechaPartido = CAST(p.fecha_hora_local AS DATE)
    FROM torneo.formacion_partido f
    JOIN torneo.partido p ON p.partido_id = f.partido_id
    WHERE f.formacion_id = @formacionId;

    IF @partidoId IS NULL
        SET @errores += N'- La formaci�n no existe.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador no existe.' + @nl;
    IF @partidoId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.convocatoria
                       WHERE jugador_id = @jugadorId AND seleccion_id = @seleccionId AND estado = 'VIGENTE')
        SET @errores += N'- El jugador no est� convocado (vigente) por la selecci�n de esta formaci�n.' + @nl;

    IF @partidoId IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.alineacion_detalle ad
                   JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                   WHERE f.partido_id = @partidoId AND ad.jugador_id = @jugadorId)
        SET @errores += N'- El jugador ya figura en la alineaci�n de este partido.' + @nl;

    IF @fechaPartido IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.suspension
                   WHERE jugador_id = @jugadorId
                     AND partidos_cumplidos < partidos_suspendidos
                     AND fecha_inicio < @fechaPartido)
        SET @errores += N'- El jugador tiene una suspensi�n vigente y no puede ser incluido.' + @nl;

    IF @esTitular IS NULL
        SET @errores += N'- Debe indicarse si el jugador es titular o suplente.' + @nl;
    IF @esTitular = 1
       AND (SELECT COUNT(*) FROM torneo.alineacion_detalle WHERE formacion_id = @formacionId AND es_titular = 1) >= 11
        SET @errores += N'- La formaci�n ya tiene 11 titulares.' + @nl;
    IF @esTitular = 0 AND @maxSuplentes IS NOT NULL
       AND (SELECT COUNT(*) FROM torneo.alineacion_detalle WHERE formacion_id = @formacionId AND es_titular = 0) >= @maxSuplentes
        SET @errores += N'- La formaci�n ya alcanz� el m�ximo de suplentes permitido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el jugador en la alineaci�n:' + @nl + @errores;
        THROW 50110, @errores, 1;
    END;

    INSERT INTO torneo.alineacion_detalle (formacion_id, jugador_id, posicion_campo, es_titular)
    VALUES (@formacionId, @jugadorId, @posicionCampo, @esTitular);

    SET @alineacionId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.cambio
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_cambio_alta
    @partidoId         INT,
    @seleccionId       INT,
    @jugadorSaleId     INT,
    @jugadorEntraId    INT,
    @minuto            SMALLINT,
    @ventana           TINYINT,
    @motivo            VARCHAR(10),
    @esSuplementario   BIT = 0,
    @cambioId          INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fase VARCHAR(15) = (SELECT fase FROM torneo.partido WHERE partido_id = @partidoId),
            @maxRegular INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_REGULAR'),
            @maxSuplementario INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_SUPLEMENTARIO'),
            @maxVentanas INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_VENTANAS'),
            @cantRegular INT, @cantSuplementario INT, @otrasVentanas INT;

    SELECT @cantRegular = COUNT(CASE WHEN es_suplementario = 0 THEN 1 END),
           @cantSuplementario = COUNT(CASE WHEN es_suplementario = 1 THEN 1 END),
           @otrasVentanas = COUNT(DISTINCT CASE WHEN es_suplementario = 0 AND ventana <> @ventana THEN ventana END)
    FROM torneo.cambio
    WHERE partido_id = @partidoId AND seleccion_id = @seleccionId;

    IF @maxRegular IS NULL OR @maxSuplementario IS NULL OR @maxVentanas IS NULL
        SET @errores += N'- Faltan par�metros del reglamento (MAX_CAMBIOS_REGULAR, MAX_CAMBIOS_SUPLEMENTARIO o MAX_VENTANAS).' + @nl;

    IF @fase IS NULL
        SET @errores += N'- El partido no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.partido
                   WHERE partido_id = @partidoId AND @seleccionId IN (seleccion_local_id, seleccion_visitante_id))
        SET @errores += N'- La selecci�n no participa de ese partido.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorSaleId)
        SET @errores += N'- El jugador que sale no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorEntraId)
        SET @errores += N'- El jugador que entra no existe.' + @nl;
    IF @jugadorSaleId = @jugadorEntraId
        SET @errores += N'- El jugador que sale y el que entra deben ser distintos.' + @nl;

    -- El que sale debe estar en cancha: titular, o suplente que ya ingres�, y no haber salido antes
    IF NOT EXISTS (SELECT 1
                   FROM torneo.alineacion_detalle ad
                   JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                   WHERE f.partido_id = @partidoId AND f.seleccion_id = @seleccionId
                     AND ad.jugador_id = @jugadorSaleId
                     AND (ad.es_titular = 1
                          OR EXISTS (SELECT 1 FROM torneo.cambio c
                                     WHERE c.partido_id = @partidoId AND c.jugador_entra_id = @jugadorSaleId)))
        SET @errores += N'- El jugador que sale no est� en cancha para esa selecci�n.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cambio WHERE partido_id = @partidoId AND jugador_sale_id = @jugadorSaleId)
        SET @errores += N'- El jugador que sale ya hab�a sido reemplazado.' + @nl;

    -- El que entra debe estar en el banco y no haber participado antes de un cambio
    IF NOT EXISTS (SELECT 1
                   FROM torneo.alineacion_detalle ad
                   JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                   WHERE f.partido_id = @partidoId AND f.seleccion_id = @seleccionId
                     AND ad.jugador_id = @jugadorEntraId AND ad.es_titular = 0)
        SET @errores += N'- El jugador que entra no est� en el banco de suplentes de esa selecci�n.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cambio
               WHERE partido_id = @partidoId
                 AND (jugador_entra_id = @jugadorEntraId OR jugador_sale_id = @jugadorEntraId))
        SET @errores += N'- El jugador que entra ya particip� de otro cambio en este partido.' + @nl;

    IF @minuto IS NULL OR @minuto NOT BETWEEN 1 AND 130
        SET @errores += N'- El minuto debe estar entre 1 y 130.' + @nl;
    IF @motivo IS NULL OR @motivo NOT IN ('TACTICO','LESION','PRECAUCION')
        SET @errores += N'- El motivo debe ser TACTICO, LESION o PRECAUCION.' + @nl;
    IF @esSuplementario IS NULL
        SET @errores += N'- Debe indicarse si el cambio es en tiempo suplementario.' + @nl;

    IF @esSuplementario = 0 AND @maxRegular IS NOT NULL AND @cantRegular >= @maxRegular
        SET @errores += N'- La selecci�n ya us� el m�ximo de cambios del tiempo regular.' + @nl;
    IF @esSuplementario = 0 AND @maxVentanas IS NOT NULL
       AND (@ventana IS NULL OR @ventana NOT BETWEEN 1 AND @maxVentanas)
        SET @errores += N'- La ventana de cambios es inv�lida para el tiempo regular.' + @nl;
    IF @esSuplementario = 0 AND @maxVentanas IS NOT NULL AND @otrasVentanas >= @maxVentanas
        SET @errores += N'- Se superar�a el m�ximo de ventanas de cambio permitido.' + @nl;

    IF @esSuplementario = 1 AND @maxSuplementario IS NOT NULL AND @cantSuplementario >= @maxSuplementario
        SET @errores += N'- La selecci�n ya us� el cambio adicional del tiempo suplementario.' + @nl;
    IF @esSuplementario = 1 AND @fase = 'GRUPOS'
        SET @errores += N'- No hay tiempo suplementario en la fase de grupos.' + @nl;
    IF @esSuplementario = 1 AND @minuto <= 90
        SET @errores += N'- Un cambio suplementario debe ocurrir despu�s del minuto 90.' + @nl;
    IF @esSuplementario = 1 AND @maxVentanas IS NOT NULL AND (@ventana IS NULL OR @ventana <> @maxVentanas + 1)
        SET @errores += N'- La ventana del cambio suplementario debe ser la siguiente al m�ximo regular.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el cambio:' + @nl + @errores;
        THROW 50111, @errores, 1;
    END;

    INSERT INTO torneo.cambio (partido_id, seleccion_id, jugador_sale_id, jugador_entra_id,
                               minuto, ventana, motivo, es_suplementario)
    VALUES (@partidoId, @seleccionId, @jugadorSaleId, @jugadorEntraId,
            @minuto, @ventana, @motivo, @esSuplementario);

    SET @cambioId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.gol
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_gol_alta
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
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estado VARCHAR(12), @fase VARCHAR(15), @localId INT, @visitanteId INT,
            @rivalId INT, @seleccionAutorId INT;

    SELECT @estado = estado, @fase = fase, @localId = seleccion_local_id, @visitanteId = seleccion_visitante_id
    FROM torneo.partido WHERE partido_id = @partidoId;

    SET @rivalId = CASE WHEN @seleccionId = @localId THEN @visitanteId ELSE @localId END;
    SET @seleccionAutorId = CASE WHEN @tipoGol = 'EN_CONTRA' THEN @rivalId ELSE @seleccionId END;

    IF @estado IS NULL
        SET @errores += N'- El partido no existe.' + @nl;
    IF @estado = 'PROGRAMADO'
        SET @errores += N'- El partido todav�a no comenz�; no se pueden cargar goles.' + @nl;
    IF @estado IS NOT NULL AND @seleccionId NOT IN (@localId, @visitanteId)
        SET @errores += N'- La selecci�n no participa de ese partido.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador no existe.' + @nl;
    IF @estado IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.alineacion_detalle ad
                       JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                       WHERE f.partido_id = @partidoId AND f.seleccion_id = @seleccionAutorId
                         AND ad.jugador_id = @jugadorId)
        SET @errores += N'- El autor del gol no figura en la alineaci�n de la selecci�n correspondiente.' + @nl;

    IF @jugadorAsistenteId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.alineacion_detalle ad
                       JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                       WHERE f.partido_id = @partidoId AND f.seleccion_id = @seleccionId
                         AND ad.jugador_id = @jugadorAsistenteId)
        SET @errores += N'- El asistente no figura en la alineaci�n de la selecci�n que convierte.' + @nl;
    IF @jugadorAsistenteId IS NOT NULL AND @tipoGol IN ('EN_CONTRA','PENAL')
        SET @errores += N'- Ese tipo de gol no admite asistencia.' + @nl;

    IF @minuto IS NULL OR @minuto NOT BETWEEN 1 AND 130
        SET @errores += N'- El minuto debe estar entre 1 y 130.' + @nl;
    IF @tipoGol IS NULL OR @tipoGol NOT IN ('JUGADA','PENAL','TIRO_LIBRE','EN_CONTRA','CABEZAZO')
        SET @errores += N'- El tipo de gol no es v�lido.' + @nl;
    IF @periodo IS NULL OR @periodo NOT IN ('PRIMER_TIEMPO','SEGUNDO_TIEMPO','ADICIONAL','ALARGUE','PENALES')
        SET @errores += N'- El per�odo no es v�lido.' + @nl;
    IF @periodo IN ('ALARGUE','PENALES') AND @fase = 'GRUPOS'
        SET @errores += N'- La fase de grupos no tiene alargue ni definici�n por penales.' + @nl;
    IF @periodo = 'ALARGUE' AND @minuto <= 90
        SET @errores += N'- Un gol de alargue debe ocurrir despu�s del minuto 90.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el gol:' + @nl + @errores;
        THROW 50112, @errores, 1;
    END;

    INSERT INTO torneo.gol (partido_id, seleccion_id, jugador_id, jugador_asistente_id, minuto, tipo_gol, periodo)
    VALUES (@partidoId, @seleccionId, @jugadorId, @jugadorAsistenteId, @minuto, @tipoGol, @periodo);

    SET @golId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.tarjeta
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_tarjeta_alta
    @partidoId    INT,
    @jugadorId    INT,
    @tipo         VARCHAR(8),
    @origenRoja   VARCHAR(15) = NULL,
    @minuto       SMALLINT,
    @motivo       NVARCHAR(200) = NULL,
    @tarjetaId    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estado VARCHAR(12) = (SELECT estado FROM torneo.partido WHERE partido_id = @partidoId),
            @cantAmarillas INT, @minutoRoja SMALLINT;

    SELECT @cantAmarillas = COUNT(CASE WHEN tipo = 'AMARILLA' THEN 1 END),
           @minutoRoja = MIN(CASE WHEN tipo = 'ROJA' THEN minuto END)
    FROM torneo.tarjeta
    WHERE partido_id = @partidoId AND jugador_id = @jugadorId;

    IF @estado IS NULL
        SET @errores += N'- El partido no existe.' + @nl;
    IF @estado = 'PROGRAMADO'
        SET @errores += N'- El partido todav�a no comenz�; no se pueden cargar tarjetas.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador no existe.' + @nl;
    IF @estado IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.alineacion_detalle ad
                       JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                       WHERE f.partido_id = @partidoId AND ad.jugador_id = @jugadorId)
        SET @errores += N'- El jugador no figura en la alineaci�n de ese partido.' + @nl;

    IF @tipo IS NULL OR @tipo NOT IN ('AMARILLA','ROJA')
        SET @errores += N'- El tipo debe ser AMARILLA o ROJA.' + @nl;
    IF @tipo = 'ROJA' AND (@origenRoja IS NULL OR @origenRoja NOT IN ('DIRECTA','DOBLE_AMARILLA'))
        SET @errores += N'- La roja requiere un origen DIRECTA o DOBLE_AMARILLA.' + @nl;
    IF @tipo = 'AMARILLA' AND @origenRoja IS NOT NULL
        SET @errores += N'- La amarilla no admite origen de roja.' + @nl;

    IF @minuto IS NULL OR @minuto NOT BETWEEN 1 AND 130
        SET @errores += N'- El minuto debe estar entre 1 y 130.' + @nl;

    IF @minutoRoja IS NOT NULL AND @tipo = 'ROJA'
        SET @errores += N'- El jugador ya fue expulsado en este partido.' + @nl;
    IF @minutoRoja IS NOT NULL AND @tipo = 'AMARILLA' AND @minuto > @minutoRoja
        SET @errores += N'- No se pueden registrar amarillas posteriores a la expulsi�n del jugador.' + @nl;
    IF @tipo = 'AMARILLA' AND @cantAmarillas >= 2
        SET @errores += N'- El jugador ya tiene 2 amarillas en este partido.' + @nl;
    IF @tipo = 'ROJA' AND @origenRoja = 'DOBLE_AMARILLA' AND @cantAmarillas < 2
        SET @errores += N'- La roja por doble amarilla requiere dos amarillas previas en el partido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la tarjeta:' + @nl + @errores;
        THROW 50113, @errores, 1;
    END;

    INSERT INTO torneo.tarjeta (partido_id, jugador_id, tipo, origen_roja, minuto, motivo)
    VALUES (@partidoId, @jugadorId, @tipo, @origenRoja, @minuto, @motivo);

    SET @tarjetaId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.suspension
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_suspension_alta
    @jugadorId             INT,
    @tarjetaOrigenId       INT = NULL,
    @motivo                NVARCHAR(200),
    @fechaInicio           DATE,
    @partidosSuspendidos   TINYINT,
    @partidosCumplidos     TINYINT = 0,
    @suspensionId          INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador no existe.' + @nl;

    IF @tarjetaOrigenId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.tarjeta WHERE tarjeta_id = @tarjetaOrigenId AND jugador_id = @jugadorId)
        SET @errores += N'- La tarjeta de origen no existe o no pertenece al jugador.' + @nl;
    IF @tarjetaOrigenId IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.suspension WHERE tarjeta_origen_id = @tarjetaOrigenId)
        SET @errores += N'- Ya existe una suspensi�n originada en esa tarjeta.' + @nl;

    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = N''
        SET @errores += N'- El motivo es obligatorio.' + @nl;

    IF @fechaInicio IS NULL
        SET @errores += N'- La fecha de inicio es obligatoria.' + @nl;

    IF @partidosSuspendidos IS NULL OR @partidosSuspendidos <= 0
        SET @errores += N'- Los partidos suspendidos deben ser mayores a cero.' + @nl;
    IF @partidosCumplidos IS NULL OR @partidosCumplidos > ISNULL(@partidosSuspendidos, 0)
        SET @errores += N'- Los partidos cumplidos no pueden superar a los suspendidos.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la suspensi�n:' + @nl + @errores;
        THROW 50114, @errores, 1;
    END;

    INSERT INTO torneo.suspension (jugador_id, tarjeta_origen_id, motivo, fecha_inicio, partidos_suspendidos, partidos_cumplidos)
    VALUES (@jugadorId, @tarjetaOrigenId, LTRIM(RTRIM(@motivo)), @fechaInicio, @partidosSuspendidos, @partidosCumplidos);

    SET @suspensionId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- torneo.parametro_reglamento
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_parametro_reglamento_alta
    @clave        VARCHAR(50),
    @valor        INT,
    @descripcion  NVARCHAR(200) = NULL,
    @parametroId  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF @clave IS NULL OR LTRIM(RTRIM(@clave)) = ''
        SET @errores += N'- La clave es obligatoria.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = UPPER(LTRIM(RTRIM(@clave))))
        SET @errores += N'- La clave de reglamento ya existe.' + @nl;

    IF @valor IS NULL OR @valor < 0
        SET @errores += N'- El valor debe ser un entero mayor o igual a cero.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el par�metro de reglamento:' + @nl + @errores;
        THROW 50115, @errores, 1;
    END;

    INSERT INTO torneo.parametro_reglamento (clave, valor, descripcion)
    VALUES (UPPER(LTRIM(RTRIM(@clave))), @valor, @descripcion);

    SET @parametroId = SCOPE_IDENTITY();
END;
GO