/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 10_sp_modificacion_torneo.sql
   Objetivo    : Procedimientos almacenados de MODIFICACION del esquema torneo.

   CONVENCIONES
     - Nombres: torneo.sp_<tabla>_baja y torneo.sp_<tabla>_modificacion.
     - BAJA: borrado fisico, salvo convocatoria (baja logica: estado BAJA + fecha_baja).
       Se rechaza si el registro no existe o si otros registros dependen de el.
     - MODIFICACION: reemplaza TODOS los datos editables (los parametros opcionales
       en NULL dejan el campo en NULL). Los campos que definen la identidad del
       registro (por ejemplo jugador/selección en una convocatoria) no se modifican:
       se da de baja y se vuelve a dar de alta.
     - Un unico THROW agrupa todas las validaciones incumplidas.
     - Sin cursores ni SQL dinamico: todo set-based.
     - Numeros de error: baja 51101-51115, modificacion 52101-52115
       (mismo orden de tablas que los de alta).
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- torneo.pais
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_pais_modificacion
    @paisId        INT,
    @nombre        NVARCHAR(100),
    @continente    NVARCHAR(50),
    @codigoIso     VARCHAR(10),
    @husoHorario   VARCHAR(100),
    @pbiPerCapita  DECIMAL(12,2) = NULL,
    @pbiAnio       SMALLINT      = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El país no existe.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.pais WHERE nombre = LTRIM(RTRIM(@nombre)) AND pais_id <> @paisId)
        SET @errores += N'- Ya existe otro país con ese nombre.' + @nl;

    IF @continente IS NULL OR LTRIM(RTRIM(@continente)) = N''
        SET @errores += N'- El continente es obligatorio.' + @nl;

    IF @codigoIso IS NULL OR @codigoIso NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- El código ISO debe tener exactamente 3 letras.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.pais WHERE codigo_iso = @codigoIso AND pais_id <> @paisId)
        SET @errores += N'- Ya existe otro país con ese código ISO.' + @nl;

    IF @husoHorario IS NULL OR NOT EXISTS (SELECT 1 FROM sys.time_zone_info WHERE name = @husoHorario)
        SET @errores += N'- El huso horario no es válido (usar nombres de sys.time_zone_info).' + @nl;

    IF @pbiPerCapita IS NOT NULL AND @pbiPerCapita <= 0
        SET @errores += N'- El PBI per cápita debe ser mayor a cero.' + @nl;
    IF (@pbiPerCapita IS NULL AND @pbiAnio IS NOT NULL) OR (@pbiPerCapita IS NOT NULL AND @pbiAnio IS NULL)
        SET @errores += N'- El PBI y su año deben informarse juntos.' + @nl;
    IF @pbiAnio IS NOT NULL AND (@pbiAnio < 1960 OR @pbiAnio > YEAR(SYSDATETIME()))
        SET @errores += N'- El año del PBI está fuera de rango.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el país:' + @nl + @errores;
        THROW 52101, @errores, 1;
    END;

    UPDATE torneo.pais
    SET nombre = LTRIM(RTRIM(@nombre)), continente = LTRIM(RTRIM(@continente)),
        codigo_iso = UPPER(@codigoIso), huso_horario = @husoHorario,
        pbi_per_capita = @pbiPerCapita, pbi_anio = @pbiAnio
    WHERE pais_id = @paisId;
END;
GO

-- ============================================================================
-- torneo.sede
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_sede_modificacion
    @sedeId         INT,
    @paisId         INT,
    @nombreEstadio  NVARCHAR(100),
    @ciudad         NVARCHAR(100),
    @capacidad      INT,
    @husoHorario    VARCHAR(100),
    @latitud        DECIMAL(9,6) = NULL,
    @longitud       DECIMAL(9,6) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @husoActual VARCHAR(100) = (SELECT huso_horario FROM torneo.sede WHERE sede_id = @sedeId);

    IF @husoActual IS NULL
        SET @errores += N'- La sede no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El país no existe.' + @nl;

    IF @nombreEstadio IS NULL OR LTRIM(RTRIM(@nombreEstadio)) = N''
        SET @errores += N'- El nombre del estadio es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.sede WHERE nombre_estadio = LTRIM(RTRIM(@nombreEstadio)) AND sede_id <> @sedeId)
        SET @errores += N'- Ya existe otro estadio con ese nombre.' + @nl;

    IF @ciudad IS NULL OR LTRIM(RTRIM(@ciudad)) = N''
        SET @errores += N'- La ciudad es obligatoria.' + @nl;

    IF @capacidad IS NULL OR @capacidad <= 0
        SET @errores += N'- La capacidad debe ser mayor a cero.' + @nl;
    IF @capacidad IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.partido WHERE sede_id = @sedeId AND asistencia > @capacidad)
        SET @errores += N'- La capacidad es menor a la asistencia registrada en algún partido de la sede.' + @nl;

    IF @husoHorario IS NULL OR NOT EXISTS (SELECT 1 FROM sys.time_zone_info WHERE name = @husoHorario)
        SET @errores += N'- El huso horario no es válido (usar nombres de sys.time_zone_info).' + @nl;
    IF @husoActual IS NOT NULL AND @husoHorario <> @husoActual
       AND EXISTS (SELECT 1 FROM torneo.partido WHERE sede_id = @sedeId)
        SET @errores += N'- No se puede cambiar el huso horario: hay partidos con hora UTC calculada.' + @nl;

    IF (@latitud IS NULL AND @longitud IS NOT NULL) OR (@latitud IS NOT NULL AND @longitud IS NULL)
        SET @errores += N'- Latitud y longitud deben informarse juntas.' + @nl;
    IF @latitud IS NOT NULL AND @latitud NOT BETWEEN -90 AND 90
        SET @errores += N'- La latitud debe estar entre -90 y 90.' + @nl;
    IF @longitud IS NOT NULL AND @longitud NOT BETWEEN -180 AND 180
        SET @errores += N'- La longitud debe estar entre -180 y 180.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la sede:' + @nl + @errores;
        THROW 52102, @errores, 1;
    END;

    UPDATE torneo.sede
    SET pais_id = @paisId, nombre_estadio = LTRIM(RTRIM(@nombreEstadio)), ciudad = LTRIM(RTRIM(@ciudad)),
        capacidad = @capacidad, huso_horario = @husoHorario, latitud = @latitud, longitud = @longitud
    WHERE sede_id = @sedeId;
END;
GO

-- ============================================================================
-- torneo.seleccion
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_seleccion_modificacion
    @seleccionId    INT,
    @paisId         INT,
    @nombre         NVARCHAR(100),
    @confederacion  VARCHAR(10),
    @rankingFifa    SMALLINT = NULL,
    @grupo          CHAR(1)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @paisActual INT, @grupoActual CHAR(1),
            @maxGrupo INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_SELECCIONES_GRUPO');

    SELECT @paisActual = pais_id, @grupoActual = grupo FROM torneo.seleccion WHERE seleccion_id = @seleccionId;

    IF @paisActual IS NULL
        SET @errores += N'- La selección no existe.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El país no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.seleccion WHERE pais_id = @paisId AND seleccion_id <> @seleccionId)
        SET @errores += N'- El país ya tiene otra selección registrada.' + @nl;
    IF @paisActual IS NOT NULL AND @paisId <> @paisActual
       AND (EXISTS (SELECT 1 FROM torneo.partido WHERE seleccion_local_id = @seleccionId OR seleccion_visitante_id = @seleccionId)
            OR EXISTS (SELECT 1 FROM torneo.convocatoria WHERE seleccion_id = @seleccionId))
        SET @errores += N'- No se puede cambiar el país de una selección con partidos o convocatorias.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.seleccion WHERE nombre = LTRIM(RTRIM(@nombre)) AND seleccion_id <> @seleccionId)
        SET @errores += N'- Ya existe otra selección con ese nombre.' + @nl;

    IF @confederacion IS NULL OR @confederacion NOT IN ('UEFA','CONMEBOL','CONCACAF','CAF','AFC','OFC')
        SET @errores += N'- La confederación debe ser UEFA, CONMEBOL, CONCACAF, CAF, AFC u OFC.' + @nl;

    IF @rankingFifa IS NOT NULL AND @rankingFifa <= 0
        SET @errores += N'- El ranking FIFA debe ser mayor a cero.' + @nl;

    IF @grupo IS NOT NULL AND @grupo NOT LIKE '[A-L]'
        SET @errores += N'- El grupo debe ser una letra entre A y L.' + @nl;
    IF @grupo IS NOT NULL AND @maxGrupo IS NOT NULL
       AND (SELECT COUNT(*) FROM torneo.seleccion WHERE grupo = @grupo AND seleccion_id <> @seleccionId) >= @maxGrupo
        SET @errores += N'- El grupo ya alcanzó el máximo de selecciones permitido.' + @nl;
    IF @paisActual IS NOT NULL AND ISNULL(@grupo, '') <> ISNULL(@grupoActual, '')
       AND EXISTS (SELECT 1 FROM torneo.partido
                   WHERE fase = 'GRUPOS' AND (seleccion_local_id = @seleccionId OR seleccion_visitante_id = @seleccionId))
        SET @errores += N'- No se puede cambiar el grupo: la selección ya tiene partidos de fase de grupos.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la selección:' + @nl + @errores;
        THROW 52103, @errores, 1;
    END;

    UPDATE torneo.seleccion
    SET pais_id = @paisId, nombre = LTRIM(RTRIM(@nombre)), confederacion = @confederacion,
        ranking_fifa = @rankingFifa, grupo = UPPER(@grupo)
    WHERE seleccion_id = @seleccionId;
END;
GO

-- ============================================================================
-- torneo.cuerpo_tecnico
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_cuerpo_tecnico_modificacion
    @cuerpoId      INT,
    @seleccionId   INT,
    @nombre        NVARCHAR(150),
    @rol           VARCHAR(10),
    @nacionalidad  NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.cuerpo_tecnico WHERE cuerpo_id = @cuerpoId)
        SET @errores += N'- El integrante del cuerpo técnico no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección no existe.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cuerpo_tecnico
               WHERE seleccion_id = @seleccionId AND nombre = LTRIM(RTRIM(@nombre)) AND cuerpo_id <> @cuerpoId)
        SET @errores += N'- La persona ya integra el cuerpo técnico de esa selección.' + @nl;

    IF @rol IS NULL OR @rol NOT IN ('DT','AT','PF')
        SET @errores += N'- El rol debe ser DT, AT o PF.' + @nl;
    IF @rol = 'DT' AND EXISTS (SELECT 1 FROM torneo.cuerpo_tecnico
                               WHERE seleccion_id = @seleccionId AND rol = 'DT' AND cuerpo_id <> @cuerpoId)
        SET @errores += N'- La selección ya tiene un director técnico.' + @nl;

    IF @nacionalidad IS NULL OR LTRIM(RTRIM(@nacionalidad)) = N''
        SET @errores += N'- La nacionalidad es obligatoria.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el integrante del cuerpo técnico:' + @nl + @errores;
        THROW 52104, @errores, 1;
    END;

    UPDATE torneo.cuerpo_tecnico
    SET seleccion_id = @seleccionId, nombre = LTRIM(RTRIM(@nombre)), rol = @rol,
        nacionalidad = LTRIM(RTRIM(@nacionalidad))
    WHERE cuerpo_id = @cuerpoId;
END;
GO

-- ============================================================================
-- torneo.jugador
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_jugador_modificacion
    @jugadorId         INT,
    @nombre            NVARCHAR(150),
    @fechaNacimiento   DATE,
    @posicion          VARCHAR(10),
    @clubOrigen        NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador no existe.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;

    IF @fechaNacimiento IS NULL
        SET @errores += N'- La fecha de nacimiento es obligatoria.' + @nl;
    IF @fechaNacimiento IS NOT NULL
       AND (@fechaNacimiento > CAST(SYSDATETIME() AS DATE) OR @fechaNacimiento < '19000101')
        SET @errores += N'- La fecha de nacimiento está fuera de rango.' + @nl;

    IF EXISTS (SELECT 1 FROM torneo.jugador
               WHERE nombre = LTRIM(RTRIM(@nombre)) AND fecha_nacimiento = @fechaNacimiento AND jugador_id <> @jugadorId)
        SET @errores += N'- Ya existe otro jugador con el mismo nombre y fecha de nacimiento.' + @nl;

    IF @posicion IS NULL OR @posicion NOT IN ('ARQ','DEF','MED','DEL')
        SET @errores += N'- La posición debe ser ARQ, DEF, MED o DEL.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el jugador:' + @nl + @errores;
        THROW 52105, @errores, 1;
    END;

    UPDATE torneo.jugador
    SET nombre = LTRIM(RTRIM(@nombre)), fecha_nacimiento = @fechaNacimiento,
        posicion = @posicion, club_origen = @clubOrigen
    WHERE jugador_id = @jugadorId;
END;
GO

-- ============================================================================
-- torneo.convocatoria 
-- ============================================================================
-- Solo se modifican dorsal y fecha; para cambiar selección o jugador: baja + alta
CREATE OR ALTER PROCEDURE torneo.sp_convocatoria_modificacion
    @convocatoriaId      INT,
    @dorsal              TINYINT,
    @fechaConvocatoria   DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estado VARCHAR(10), @seleccionId INT;

    SELECT @estado = estado, @seleccionId = seleccion_id
    FROM torneo.convocatoria WHERE convocatoria_id = @convocatoriaId;

    IF @estado IS NULL
        SET @errores += N'- La convocatoria no existe.' + @nl;
    IF @estado = 'BAJA'
        SET @errores += N'- No se puede modificar una convocatoria dada de baja.' + @nl;

    IF @dorsal IS NULL OR @dorsal NOT BETWEEN 1 AND 99
        SET @errores += N'- El dorsal debe estar entre 1 y 99.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.convocatoria
               WHERE seleccion_id = @seleccionId AND dorsal = @dorsal AND estado = 'VIGENTE'
                 AND convocatoria_id <> @convocatoriaId)
        SET @errores += N'- El dorsal ya está asignado a otro convocado de la selección.' + @nl;

    IF @fechaConvocatoria IS NULL
        SET @errores += N'- La fecha de convocatoria es obligatoria.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la convocatoria:' + @nl + @errores;
        THROW 52106, @errores, 1;
    END;

    UPDATE torneo.convocatoria
    SET dorsal = @dorsal, fecha_convocatoria = @fechaConvocatoria
    WHERE convocatoria_id = @convocatoriaId;
END;
GO

-- ============================================================================
-- torneo.reemplazo_convocatoria
-- ============================================================================
-- Solo motivo y fecha; los jugadores y la selección definen el reemplazo
CREATE OR ALTER PROCEDURE torneo.sp_reemplazo_convocatoria_modificacion
    @reemplazoId  INT,
    @motivo       NVARCHAR(200),
    @fechaCambio  DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.reemplazo_convocatoria WHERE reemplazo_id = @reemplazoId)
        SET @errores += N'- El reemplazo no existe.' + @nl;
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = N''
        SET @errores += N'- El motivo es obligatorio.' + @nl;
    IF @fechaCambio IS NULL
        SET @errores += N'- La fecha del cambio es obligatoria.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el reemplazo de convocatoria:' + @nl + @errores;
        THROW 52107, @errores, 1;
    END;

    UPDATE torneo.reemplazo_convocatoria
    SET motivo = LTRIM(RTRIM(@motivo)), fecha_cambio = @fechaCambio
    WHERE reemplazo_id = @reemplazoId;
END;
GO

-- ============================================================================
-- torneo.partido
-- ============================================================================
-- Reprograma (solo si PROGRAMADO) y/o registra el resultado y el avance de estado.
CREATE OR ALTER PROCEDURE torneo.sp_partido_modificacion
    @partidoId              INT,
    @fase                   VARCHAR(15),
    @sedeId                 INT,
    @seleccionLocalId       INT,
    @seleccionVisitanteId   INT,
    @fechaHoraLocal         DATETIME2(0),
    @golesLocal             TINYINT = NULL,
    @golesVisitante         TINYINT = NULL,
    @penalesLocal           TINYINT = NULL,
    @penalesVisitante       TINYINT = NULL,
    @asistencia             INT     = NULL,
    @estado                 VARCHAR(12)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estadoActual VARCHAR(12), @faseActual VARCHAR(15), @sedeActual INT,
            @localActual INT, @visitanteActual INT, @fechaActual DATETIME2(0),
            @huso VARCHAR(100), @capacidad INT, @fechaHoraUtc DATETIME2(0),
            @grupoLocal CHAR(1), @grupoVisitante CHAR(1),
            @minSede INT = ISNULL((SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MIN_MINUTOS_ENTRE_PARTIDOS_SEDE'), 180),
            @minSeleccion INT = ISNULL((SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MIN_MINUTOS_DESCANSO_SELECCION'), 2880);

    SELECT @estadoActual = estado, @faseActual = fase, @sedeActual = sede_id,
           @localActual = seleccion_local_id, @visitanteActual = seleccion_visitante_id,
           @fechaActual = fecha_hora_local
    FROM torneo.partido WHERE partido_id = @partidoId;

    SELECT @huso = huso_horario, @capacidad = capacidad FROM torneo.sede WHERE sede_id = @sedeId;
    SELECT @grupoLocal = grupo FROM torneo.seleccion WHERE seleccion_id = @seleccionLocalId;
    SELECT @grupoVisitante = grupo FROM torneo.seleccion WHERE seleccion_id = @seleccionVisitanteId;

    IF @estadoActual IS NULL
        SET @errores += N'- El partido no existe.' + @nl;

    IF @estado IS NULL OR @estado NOT IN ('PROGRAMADO','EN_CURSO','FINALIZADO')
        SET @errores += N'- El estado debe ser PROGRAMADO, EN_CURSO o FINALIZADO.' + @nl;
    IF @estadoActual IS NOT NULL AND @estado IN ('PROGRAMADO','EN_CURSO','FINALIZADO')
       AND (CASE @estado WHEN 'PROGRAMADO' THEN 0 WHEN 'EN_CURSO' THEN 1 ELSE 2 END)
         < (CASE @estadoActual WHEN 'PROGRAMADO' THEN 0 WHEN 'EN_CURSO' THEN 1 ELSE 2 END)
        SET @errores += N'- El estado del partido no puede retroceder.' + @nl;

    IF @fase IS NULL OR @fase NOT IN ('GRUPOS','DIECISEISAVOS','OCTAVOS','CUARTOS','SEMIFINAL','TERCER_PUESTO','FINAL')
        SET @errores += N'- La fase no es válida.' + @nl;
    IF @huso IS NULL
        SET @errores += N'- La sede no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionLocalId)
        SET @errores += N'- La selección local no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionVisitanteId)
        SET @errores += N'- La selección visitante no existe.' + @nl;
    IF @seleccionLocalId = @seleccionVisitanteId
        SET @errores += N'- La selección local y la visitante deben ser distintas.' + @nl;
    IF @fechaHoraLocal IS NULL
        SET @errores += N'- La fecha y hora local son obligatorias.' + @nl;

    IF @estadoActual IS NOT NULL AND @estadoActual <> 'PROGRAMADO'
       AND (@fase <> @faseActual OR @sedeId <> @sedeActual OR @seleccionLocalId <> @localActual
            OR @seleccionVisitanteId <> @visitanteActual OR @fechaHoraLocal <> @fechaActual)
        SET @errores += N'- Un partido ya iniciado no puede reprogramarse (fase, sede, selecciones u horario).' + @nl;

    IF @huso IS NOT NULL AND @fechaHoraLocal IS NOT NULL
        SET @fechaHoraUtc = CAST((@fechaHoraLocal AT TIME ZONE @huso) AT TIME ZONE 'UTC' AS DATETIME2(0));

    -- Validaciones de programación (solo mientras el partido sigue PROGRAMADO)
    IF @estadoActual = 'PROGRAMADO' AND @fase = 'GRUPOS'
       AND (@grupoLocal IS NULL OR @grupoVisitante IS NULL OR @grupoLocal <> @grupoVisitante)
        SET @errores += N'- En fase de grupos ambas selecciones deben tener el mismo grupo asignado.' + @nl;
    IF @estadoActual = 'PROGRAMADO'
       AND EXISTS (SELECT 1 FROM torneo.partido
                   WHERE partido_id <> @partidoId AND fase = @fase
                     AND ((seleccion_local_id = @seleccionLocalId AND seleccion_visitante_id = @seleccionVisitanteId)
                       OR (seleccion_local_id = @seleccionVisitanteId AND seleccion_visitante_id = @seleccionLocalId)))
        SET @errores += N'- Esas selecciones ya tienen otro partido cargado en esa fase.' + @nl;
    IF @estadoActual = 'PROGRAMADO' AND @fechaHoraUtc IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.partido
                   WHERE partido_id <> @partidoId AND sede_id = @sedeId
                     AND ABS(DATEDIFF(MINUTE, fecha_hora_utc, @fechaHoraUtc)) < @minSede)
        SET @errores += N'- La sede ya tiene otro partido en un rango menor al margen mínimo permitido.' + @nl;
    IF @estadoActual = 'PROGRAMADO' AND @fechaHoraUtc IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.partido
                   WHERE partido_id <> @partidoId
                     AND (seleccion_local_id IN (@seleccionLocalId, @seleccionVisitanteId)
                       OR seleccion_visitante_id IN (@seleccionLocalId, @seleccionVisitanteId))
                     AND ABS(DATEDIFF(MINUTE, fecha_hora_utc, @fechaHoraUtc)) < @minSeleccion)
        SET @errores += N'- Alguna de las selecciones juega otro partido sin el descanso mínimo requerido.' + @nl;

    -- Resultado
    IF @estado = 'PROGRAMADO'
       AND (@golesLocal IS NOT NULL OR @golesVisitante IS NOT NULL OR @penalesLocal IS NOT NULL
            OR @penalesVisitante IS NOT NULL OR @asistencia IS NOT NULL)
        SET @errores += N'- Un partido PROGRAMADO no puede tener resultado ni asistencia.' + @nl;
    IF (@golesLocal IS NULL AND @golesVisitante IS NOT NULL) OR (@golesLocal IS NOT NULL AND @golesVisitante IS NULL)
        SET @errores += N'- Los goles de ambas selecciones deben informarse juntos.' + @nl;
    IF (@penalesLocal IS NULL AND @penalesVisitante IS NOT NULL) OR (@penalesLocal IS NOT NULL AND @penalesVisitante IS NULL)
        SET @errores += N'- Los penales de ambas selecciones deben informarse juntos.' + @nl;
    IF @estado = 'FINALIZADO' AND @golesLocal IS NULL
        SET @errores += N'- Un partido FINALIZADO requiere resultado.' + @nl;
    IF @penalesLocal IS NOT NULL AND @fase = 'GRUPOS'
        SET @errores += N'- La fase de grupos no se define por penales.' + @nl;
    IF @penalesLocal IS NOT NULL AND (@golesLocal IS NULL OR @golesLocal <> @golesVisitante)
        SET @errores += N'- Solo hay penales si el partido terminó empatado.' + @nl;
    IF @penalesLocal IS NOT NULL AND @penalesLocal = @penalesVisitante
        SET @errores += N'- La definición por penales no puede terminar empatada.' + @nl;
    IF @estado = 'FINALIZADO' AND @fase <> 'GRUPOS' AND @golesLocal IS NOT NULL
       AND @golesLocal = @golesVisitante AND @penalesLocal IS NULL
        SET @errores += N'- Un partido eliminatorio empatado requiere definición por penales.' + @nl;

    IF @asistencia IS NOT NULL AND @asistencia < 0
        SET @errores += N'- La asistencia no puede ser negativa.' + @nl;
    IF @asistencia IS NOT NULL AND @capacidad IS NOT NULL AND @asistencia > @capacidad
        SET @errores += N'- La asistencia supera la capacidad de la sede.' + @nl;

    IF @estado = 'FINALIZADO' AND @golesLocal IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.gol WHERE partido_id = @partidoId)
       AND ((SELECT COUNT(*) FROM torneo.gol WHERE partido_id = @partidoId AND seleccion_id = @seleccionLocalId AND periodo <> 'PENALES') <> @golesLocal
         OR (SELECT COUNT(*) FROM torneo.gol WHERE partido_id = @partidoId AND seleccion_id = @seleccionVisitanteId AND periodo <> 'PENALES') <> @golesVisitante)
        SET @errores += N'- El resultado no coincide con los goles registrados en el partido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el partido:' + @nl + @errores;
        THROW 52108, @errores, 1;
    END;

    UPDATE torneo.partido
    SET fase = @fase, sede_id = @sedeId, seleccion_local_id = @seleccionLocalId,
        seleccion_visitante_id = @seleccionVisitanteId,
        fecha_hora_local = @fechaHoraLocal, fecha_hora_utc = @fechaHoraUtc,
        goles_local = @golesLocal, goles_visitante = @golesVisitante,
        penales_local = @penalesLocal, penales_visitante = @penalesVisitante,
        asistencia = @asistencia, estado = @estado
    WHERE partido_id = @partidoId;
END;
GO

-- ============================================================================
-- torneo.formacion_partido
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_formacion_partido_modificacion
    @formacionId  INT,
    @esquema      VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.formacion_partido WHERE formacion_id = @formacionId)
        SET @errores += N'- La formación no existe.' + @nl;
    IF @esquema IS NULL OR LEN(@esquema) > 10
       OR @esquema NOT LIKE '[0-9]-%' OR @esquema LIKE '%[^0-9-]%'
        SET @errores += N'- El esquema debe tener formato numérico separado por guiones (ej. 4-3-3).' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la formación:' + @nl + @errores;
        THROW 52109, @errores, 1;
    END;

    UPDATE torneo.formacion_partido SET esquema = @esquema WHERE formacion_id = @formacionId;
END;
GO

-- ============================================================================
-- torneo.alineacion_detalle
-- ============================================================================
-- Solo posición en campo y condición de titular; para cambiar el jugador: baja + alta
CREATE OR ALTER PROCEDURE torneo.sp_alineacion_detalle_modificacion
    @alineacionId   INT,
    @posicionCampo  VARCHAR(20) = NULL,
    @esTitular      BIT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @formacionId INT, @partidoId INT, @jugadorId INT, @titularActual BIT,
            @maxSuplentes INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_SUPLENTES');

    SELECT @formacionId = ad.formacion_id, @partidoId = f.partido_id,
           @jugadorId = ad.jugador_id, @titularActual = ad.es_titular
    FROM torneo.alineacion_detalle ad
    JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
    WHERE ad.alineacion_id = @alineacionId;

    IF @partidoId IS NULL
        SET @errores += N'- El registro de alineación no existe.' + @nl;
    IF @esTitular IS NULL
        SET @errores += N'- Debe indicarse si el jugador es titular o suplente.' + @nl;

    IF @partidoId IS NOT NULL AND @esTitular <> @titularActual
       AND (EXISTS (SELECT 1 FROM torneo.cambio WHERE partido_id = @partidoId AND @jugadorId IN (jugador_sale_id, jugador_entra_id))
            OR EXISTS (SELECT 1 FROM torneo.gol WHERE partido_id = @partidoId AND @jugadorId IN (jugador_id, jugador_asistente_id))
            OR EXISTS (SELECT 1 FROM torneo.tarjeta WHERE partido_id = @partidoId AND jugador_id = @jugadorId))
        SET @errores += N'- No se puede cambiar la condición de titular: el jugador tiene eventos en el partido.' + @nl;

    IF @esTitular = 1 AND @titularActual = 0
       AND EXISTS (SELECT 1 FROM torneo.suspension s WHERE s.jugador_id = @jugadorId AND s.partidos_cumplidos < s.partidos_suspendidos)
        SET @errores += N'- El jugador está suspendido y no puede ser titular.' + @nl;
    IF @esTitular = 1 AND @titularActual = 0
       AND (SELECT COUNT(*) FROM torneo.alineacion_detalle WHERE formacion_id = @formacionId AND es_titular = 1) >= 11
        SET @errores += N'- La formación ya tiene 11 titulares.' + @nl;
    IF @esTitular = 0 AND @titularActual = 1 AND @maxSuplentes IS NOT NULL
       AND (SELECT COUNT(*) FROM torneo.alineacion_detalle WHERE formacion_id = @formacionId AND es_titular = 0) >= @maxSuplentes
        SET @errores += N'- La formación ya alcanzó el máximo de suplentes permitido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la alineación:' + @nl + @errores;
        THROW 52110, @errores, 1;
    END;

    UPDATE torneo.alineacion_detalle
    SET posicion_campo = @posicionCampo, es_titular = @esTitular
    WHERE alineacion_id = @alineacionId;
END;
GO

-- ============================================================================
-- torneo.cambio
-- ============================================================================
-- Los jugadores no se modifican (baja + alta). Se revalidan topes y ventanas.
CREATE OR ALTER PROCEDURE torneo.sp_cambio_modificacion
    @cambioId          INT,
    @minuto            SMALLINT,
    @ventana           TINYINT,
    @motivo            VARCHAR(10),
    @esSuplementario   BIT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @seleccionId INT, @saleId INT, @entraId INT,
            @fase VARCHAR(15), @estado VARCHAR(12),
            @maxRegular INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_REGULAR'),
            @maxSuplementario INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_CAMBIOS_SUPLEMENTARIO'),
            @maxVentanas INT = (SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MAX_VENTANAS'),
            @cantRegular INT, @cantSuplementario INT, @otrasVentanas INT;
 
    SELECT @partidoId = c.partido_id, @seleccionId = c.seleccion_id,
           @saleId = c.jugador_sale_id, @entraId = c.jugador_entra_id,
           @fase = p.fase, @estado = p.estado
    FROM torneo.cambio c
    JOIN torneo.partido p ON p.partido_id = c.partido_id
    WHERE c.cambio_id = @cambioId;
 
    SELECT @cantRegular = COUNT(CASE WHEN es_suplementario = 0 THEN 1 END),
           @cantSuplementario = COUNT(CASE WHEN es_suplementario = 1 THEN 1 END),
           @otrasVentanas = COUNT(DISTINCT CASE WHEN es_suplementario = 0 AND ventana <> @ventana THEN ventana END)
    FROM torneo.cambio
    WHERE partido_id = @partidoId AND seleccion_id = @seleccionId AND cambio_id <> @cambioId;
 
    IF @partidoId IS NULL
        SET @errores += N'- El cambio no existe.' + @nl;
    IF @estado = 'FINALIZADO'
        SET @errores += N'- El partido está finalizado; no se pueden modificar sus cambios.' + @nl;
    IF @maxRegular IS NULL OR @maxSuplementario IS NULL OR @maxVentanas IS NULL
        SET @errores += N'- Faltan parámetros del reglamento (MAX_CAMBIOS_REGULAR, MAX_CAMBIOS_SUPLEMENTARIO o MAX_VENTANAS).' + @nl;
 
    IF @minuto IS NULL OR @minuto NOT BETWEEN 1 AND 130
        SET @errores += N'- El minuto debe estar entre 1 y 130.' + @nl;
    IF @motivo IS NULL OR @motivo NOT IN ('TACTICO','LESION','PRECAUCION')
        SET @errores += N'- El motivo debe ser TACTICO, LESION o PRECAUCION.' + @nl;
    IF @esSuplementario IS NULL
        SET @errores += N'- Debe indicarse si el cambio es en tiempo suplementario.' + @nl;
 
    IF @esSuplementario = 0 AND @maxRegular IS NOT NULL AND @cantRegular >= @maxRegular
        SET @errores += N'- La selección ya usó el máximo de cambios del tiempo regular.' + @nl;
    IF @esSuplementario = 0 AND @maxVentanas IS NOT NULL
       AND (@ventana IS NULL OR @ventana NOT BETWEEN 1 AND @maxVentanas)
        SET @errores += N'- La ventana de cambios es inválida para el tiempo regular.' + @nl;
    IF @esSuplementario = 0 AND @maxVentanas IS NOT NULL AND @otrasVentanas >= @maxVentanas
        SET @errores += N'- Se superaría el máximo de ventanas de cambio permitido.' + @nl;
 
    IF @esSuplementario = 1 AND @maxSuplementario IS NOT NULL AND @cantSuplementario >= @maxSuplementario
        SET @errores += N'- La selección ya usó el cambio adicional del tiempo suplementario.' + @nl;
    IF @esSuplementario = 1 AND @fase = 'GRUPOS'
        SET @errores += N'- No hay tiempo suplementario en la fase de grupos.' + @nl;
    IF @esSuplementario = 1 AND @minuto <= 90
        SET @errores += N'- Un cambio suplementario debe ocurrir después del minuto 90.' + @nl;
    IF @esSuplementario = 1 AND @maxVentanas IS NOT NULL AND (@ventana IS NULL OR @ventana <> @maxVentanas + 1)
        SET @errores += N'- La ventana del cambio suplementario debe ser la siguiente al máximo regular.' + @nl;
 
    -- Cronología del partido (solo se evalúa si el minuto es válido)
    IF @minuto BETWEEN 1 AND 130
       AND EXISTS (SELECT 1 FROM torneo.cambio
                   WHERE partido_id = @partidoId AND jugador_entra_id = @saleId
                     AND cambio_id <> @cambioId AND minuto >= @minuto)
        SET @errores += N'- El jugador que sale ingresó al partido en un minuto igual o posterior al de este cambio.' + @nl;
    IF @minuto BETWEEN 1 AND 130
       AND EXISTS (SELECT 1 FROM torneo.cambio
                   WHERE partido_id = @partidoId AND jugador_sale_id = @entraId
                     AND cambio_id <> @cambioId AND minuto <= @minuto)
        SET @errores += N'- El jugador que ingresa sale del partido en otro cambio en un minuto igual o anterior al de este ingreso.' + @nl;
    IF @minuto BETWEEN 1 AND 130
       AND EXISTS (SELECT 1 FROM torneo.tarjeta
                   WHERE partido_id = @partidoId AND jugador_id = @saleId
                     AND tipo = 'ROJA' AND minuto < @minuto)
        SET @errores += N'- El jugador que sale ya había sido expulsado antes de ese minuto.' + @nl;
    IF @minuto BETWEEN 1 AND 130
       AND EXISTS (SELECT 1 FROM torneo.tarjeta
                   WHERE partido_id = @partidoId AND jugador_id = @entraId
                     AND tipo = 'ROJA' AND minuto < @minuto)
        SET @errores += N'- El jugador que ingresa ya había sido expulsado antes de ese minuto.' + @nl;
    IF @minuto BETWEEN 1 AND 130 AND @ventana IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.cambio
                   WHERE partido_id = @partidoId AND seleccion_id = @seleccionId AND cambio_id <> @cambioId
                     AND ((ventana < @ventana AND minuto > @minuto)
                       OR (ventana > @ventana AND minuto < @minuto)))
        SET @errores += N'- El minuto no es coherente con el orden de las ventanas de cambio de la selección.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el cambio:' + @nl + @errores;
        THROW 52111, @errores, 1;
    END;
 
    UPDATE torneo.cambio
    SET minuto = @minuto, ventana = @ventana, motivo = @motivo, es_suplementario = @esSuplementario
    WHERE cambio_id = @cambioId;
END;
GO

-- ============================================================================
-- torneo.gol
-- ============================================================================
-- Autor y selección no se modifican (baja + alta)
CREATE OR ALTER PROCEDURE torneo.sp_gol_modificacion
    @golId                 INT,
    @jugadorAsistenteId    INT = NULL,
    @minuto                SMALLINT,
    @tipoGol               VARCHAR(12),
    @periodo               VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @seleccionId INT, @autorId INT, @estado VARCHAR(12), @fase VARCHAR(15),
            @seleccionAutorId INT;
 
    SELECT @partidoId = g.partido_id, @seleccionId = g.seleccion_id, @autorId = g.jugador_id,
           @estado = p.estado, @fase = p.fase
    FROM torneo.gol g
    JOIN torneo.partido p ON p.partido_id = g.partido_id
    WHERE g.gol_id = @golId;
 
    -- Selección a la que pertenece el autor en este partido (según las alineaciones)
    SELECT @seleccionAutorId = MIN(f.seleccion_id)
    FROM torneo.alineacion_detalle ad
    JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
    WHERE f.partido_id = @partidoId AND ad.jugador_id = @autorId;
 
    IF @partidoId IS NULL
        SET @errores += N'- El gol no existe.' + @nl;
    IF @estado = 'FINALIZADO'
        SET @errores += N'- El partido está finalizado; no se pueden modificar sus goles.' + @nl;
 
    IF @jugadorAsistenteId IS NOT NULL AND @jugadorAsistenteId = @autorId
        SET @errores += N'- El asistente no puede ser el autor del gol.' + @nl;
    IF @jugadorAsistenteId IS NOT NULL AND @partidoId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.alineacion_detalle ad
                       JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
                       WHERE f.partido_id = @partidoId AND f.seleccion_id = @seleccionId
                         AND ad.jugador_id = @jugadorAsistenteId)
        SET @errores += N'- El asistente no figura en la alineación de la selección que convierte.' + @nl;
    IF @jugadorAsistenteId IS NOT NULL AND @tipoGol IN ('EN_CONTRA','PENAL')
        SET @errores += N'- Ese tipo de gol no admite asistencia.' + @nl;
 
    IF @minuto IS NULL OR @minuto NOT BETWEEN 1 AND 130
        SET @errores += N'- El minuto debe estar entre 1 y 130.' + @nl;
    IF @tipoGol IS NULL OR @tipoGol NOT IN ('JUGADA','PENAL','TIRO_LIBRE','EN_CONTRA','CABEZAZO')
        SET @errores += N'- El tipo de gol no es válido.' + @nl;
    IF @periodo IS NULL OR @periodo NOT IN ('PRIMER_TIEMPO','SEGUNDO_TIEMPO','ADICIONAL','ALARGUE','PENALES')
        SET @errores += N'- El período no es válido.' + @nl;
    IF @periodo IN ('ALARGUE','PENALES') AND @fase = 'GRUPOS'
        SET @errores += N'- La fase de grupos no tiene alargue ni definición por penales.' + @nl;
    IF @periodo = 'ALARGUE' AND @minuto <= 90
        SET @errores += N'- Un gol de alargue debe ocurrir después del minuto 90.' + @nl;
 
    -- Coherencia tipo de gol / selección del autor
    IF @partidoId IS NOT NULL AND @seleccionAutorId IS NULL
        SET @errores += N'- El autor del gol no figura en las alineaciones del partido.' + @nl;
    IF @tipoGol = 'EN_CONTRA' AND @seleccionAutorId = @seleccionId
        SET @errores += N'- En un gol en contra el autor debe pertenecer a la selección rival (a la que no se le computa el gol).' + @nl;
    IF @tipoGol IN ('JUGADA','PENAL','TIRO_LIBRE','CABEZAZO') AND @seleccionAutorId <> @seleccionId
        SET @errores += N'- Solo un gol en contra puede ser convertido por un jugador de la selección rival.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el gol:' + @nl + @errores;
        THROW 52112, @errores, 1;
    END;
 
    UPDATE torneo.gol
    SET jugador_asistente_id = @jugadorAsistenteId, minuto = @minuto, tipo_gol = @tipoGol, periodo = @periodo
    WHERE gol_id = @golId;
END;
GO

-- ============================================================================
-- torneo.tarjeta
-- ============================================================================
-- El tipo y el jugador no se modifican (baja + alta)
CREATE OR ALTER PROCEDURE torneo.sp_tarjeta_modificacion
    @tarjetaId    INT,
    @origenRoja   VARCHAR(15) = NULL,
    @minuto       SMALLINT,
    @motivo       NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @jugadorId INT, @tipo VARCHAR(8), @origenActual VARCHAR(15),
            @estado VARCHAR(12), @cantAmarillas INT;
 
    SELECT @partidoId = t.partido_id, @jugadorId = t.jugador_id, @tipo = t.tipo,
           @origenActual = t.origen_roja, @estado = p.estado
    FROM torneo.tarjeta t
    JOIN torneo.partido p ON p.partido_id = t.partido_id
    WHERE t.tarjeta_id = @tarjetaId;
 
    SELECT @cantAmarillas = COUNT(*) FROM torneo.tarjeta
    WHERE partido_id = @partidoId AND jugador_id = @jugadorId AND tipo = 'AMARILLA';
 
    IF @partidoId IS NULL
        SET @errores += N'- La tarjeta no existe.' + @nl;
    IF @estado = 'FINALIZADO'
        SET @errores += N'- El partido está finalizado; no se pueden modificar sus tarjetas.' + @nl;
 
    IF @tipo = 'ROJA' AND (@origenRoja IS NULL OR @origenRoja NOT IN ('DIRECTA','DOBLE_AMARILLA'))
        SET @errores += N'- La roja requiere un origen DIRECTA o DOBLE_AMARILLA.' + @nl;
    IF @tipo = 'AMARILLA' AND @origenRoja IS NOT NULL
        SET @errores += N'- La amarilla no admite origen de roja.' + @nl;
    IF @tipo = 'ROJA' AND @origenRoja = 'DOBLE_AMARILLA' AND @cantAmarillas < 2
        SET @errores += N'- La roja por doble amarilla requiere dos amarillas previas en el partido.' + @nl;
    IF @tipo = 'ROJA' AND ISNULL(@origenRoja, '') <> ISNULL(@origenActual, '')
       AND EXISTS (SELECT 1 FROM torneo.suspension WHERE tarjeta_origen_id = @tarjetaId)
        SET @errores += N'- No se puede cambiar el origen de la roja: ya originó una suspensión (eliminar antes la suspensión).' + @nl;
 
    IF @minuto IS NULL OR @minuto NOT BETWEEN 1 AND 130
        SET @errores += N'- El minuto debe estar entre 1 y 130.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la tarjeta:' + @nl + @errores;
        THROW 52113, @errores, 1;
    END;
 
    UPDATE torneo.tarjeta
    SET origen_roja = @origenRoja, minuto = @minuto, motivo = @motivo
    WHERE tarjeta_id = @tarjetaId;
END;
GO

-- ============================================================================
-- torneo.suspension
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_suspension_modificacion
    @suspensionId          INT,
    @motivo                NVARCHAR(200),
    @partidosSuspendidos   TINYINT,
    @partidosCumplidos     TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.suspension WHERE suspension_id = @suspensionId)
        SET @errores += N'- La suspensión no existe.' + @nl;
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = N''
        SET @errores += N'- El motivo es obligatorio.' + @nl;
    IF @partidosSuspendidos IS NULL OR @partidosSuspendidos <= 0
        SET @errores += N'- Los partidos suspendidos deben ser mayores a cero.' + @nl;
    IF @partidosCumplidos IS NULL OR @partidosCumplidos > ISNULL(@partidosSuspendidos, 0)
        SET @errores += N'- Los partidos cumplidos no pueden superar a los suspendidos.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la suspensión:' + @nl + @errores;
        THROW 52114, @errores, 1;
    END;

    UPDATE torneo.suspension
    SET motivo = LTRIM(RTRIM(@motivo)), partidos_suspendidos = @partidosSuspendidos,
        partidos_cumplidos = @partidosCumplidos
    WHERE suspension_id = @suspensionId;
END;
GO

-- ============================================================================
-- torneo.parametro_reglamento
-- ============================================================================
-- La clave no se modifica (los SP la usan como identificador)
CREATE OR ALTER PROCEDURE torneo.sp_parametro_reglamento_modificacion
    @parametroId  INT,
    @valor        INT,
    @descripcion  NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE parametro_id = @parametroId)
        SET @errores += N'- El parámetro no existe.' + @nl;
    IF @valor IS NULL OR @valor < 0
        SET @errores += N'- El valor debe ser un entero mayor o igual a cero.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el parámetro de reglamento:' + @nl + @errores;
        THROW 52115, @errores, 1;
    END;

    UPDATE torneo.parametro_reglamento
    SET valor = @valor, descripcion = @descripcion
    WHERE parametro_id = @parametroId;
END;
GO
