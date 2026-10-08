/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com: 5600      Grupo:09
   Integrantes :
   Fecha       : 06/10/2026
   Script      : 03_sp_alta_arbitraje.sql
   Objetivo    : Procedimientos almacenados de ALTA del esquema arbitraje.
                 Numeros de error: 50201-50205.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- arbitraje.arbitro
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_arbitro_alta
    @nombre     NVARCHAR(150),
    @paisId     INT,
    @categoria  VARCHAR(15),
    @arbitroId  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El país no existe.' + @nl;

    IF EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE nombre = LTRIM(RTRIM(@nombre)) AND pais_id = @paisId)
        SET @errores += N'- Ya existe un árbitro con ese nombre y país.' + @nl;

    IF @categoria IS NULL OR @categoria NOT IN ('FIFA','CONFEDERACION')
        SET @errores += N'- La categoría debe ser FIFA o CONFEDERACION.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el árbitro:' + @nl + @errores;
        THROW 50201, @errores, 1;
    END;

    INSERT INTO arbitraje.arbitro (nombre, pais_id, categoria)
    VALUES (LTRIM(RTRIM(@nombre)), @paisId, @categoria);

    SET @arbitroId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- arbitraje.arbitro_idioma 
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_arbitro_idioma_alta
    @arbitroId  INT,
    @idioma     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @arbitroId)
        SET @errores += N'- El árbitro no existe.' + @nl;

    IF @idioma IS NULL OR LTRIM(RTRIM(@idioma)) = N''
        SET @errores += N'- El idioma es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.arbitro_idioma
               WHERE arbitro_id = @arbitroId AND idioma = LTRIM(RTRIM(@idioma)))
        SET @errores += N'- El árbitro ya tiene registrado ese idioma.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el idioma del árbitro:' + @nl + @errores;
        THROW 50202, @errores, 1;
    END;

    INSERT INTO arbitraje.arbitro_idioma (arbitro_id, idioma)
    VALUES (@arbitroId, LTRIM(RTRIM(@idioma)));
END;
GO

-- ============================================================================
-- arbitraje.designacion_arbitral
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_designacion_arbitral_alta
    @partidoId       INT,
    @arbitroId       INT,
    @rolArbitral     VARCHAR(10),
    @designacionId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fase VARCHAR(15), @fechaUtc DATETIME2(0), @paisLocal INT, @paisVisitante INT,
            @paisArbitro INT, @conflicto BIT = 0, @advertir BIT = 0,
            @minArbitro INT = ISNULL((SELECT valor FROM torneo.parametro_reglamento WHERE clave = 'MIN_MINUTOS_ENTRE_PARTIDOS_ARBITRO'), 180);

    SELECT @fase = p.fase, @fechaUtc = p.fecha_hora_utc,
           @paisLocal = sl.pais_id, @paisVisitante = sv.pais_id
    FROM torneo.partido p
    JOIN torneo.seleccion sl ON sl.seleccion_id = p.seleccion_local_id
    JOIN torneo.seleccion sv ON sv.seleccion_id = p.seleccion_visitante_id
    WHERE p.partido_id = @partidoId;

    SELECT @paisArbitro = pais_id FROM arbitraje.arbitro WHERE arbitro_id = @arbitroId;

    IF @fase IS NULL
        SET @errores += N'- El partido no existe.' + @nl;
    IF @paisArbitro IS NULL
        SET @errores += N'- El árbitro no existe.' + @nl;
    IF @rolArbitral IS NULL OR @rolArbitral NOT IN ('PRINCIPAL','ASISTENTE','CUARTO','VAR')
        SET @errores += N'- El rol debe ser PRINCIPAL, ASISTENTE, CUARTO o VAR.' + @nl;

    IF @fase IS NOT NULL AND @paisArbitro IS NOT NULL
       AND @paisArbitro IN (@paisLocal, @paisVisitante)
    BEGIN
        SET @conflicto = 1;
        SET @errores += N'- Conflicto de nacionalidad: el árbitro es del país de una de las selecciones.' + @nl;
    END;

    IF EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE partido_id = @partidoId AND arbitro_id = @arbitroId)
        SET @errores += N'- El árbitro ya está designado en ese partido.' + @nl;
    IF @rolArbitral IN ('PRINCIPAL','CUARTO','VAR')
       AND EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE partido_id = @partidoId AND rol_arbitral = @rolArbitral)
        SET @errores += N'- El partido ya tiene un árbitro con ese rol.' + @nl;

    IF @fechaUtc IS NOT NULL
       AND EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral d
                   JOIN torneo.partido p2 ON p2.partido_id = d.partido_id
                   WHERE d.arbitro_id = @arbitroId AND d.partido_id <> @partidoId
                     AND ABS(DATEDIFF(MINUTE, p2.fecha_hora_utc, @fechaUtc)) < @minArbitro)
        SET @errores += N'- El árbitro está designado en otro partido en un horario superpuesto.' + @nl;

    -- Rechazo por nacionalidad: queda registrado aunque la designación falle
    IF @conflicto = 1 AND @rolArbitral IN ('PRINCIPAL','ASISTENTE','CUARTO','VAR')
        INSERT INTO arbitraje.designacion_rechazada (partido_id, arbitro_id, rol_arbitral, motivo)
        VALUES (@partidoId, @arbitroId, @rolArbitral, N'Conflicto de nacionalidad con una de las selecciones del partido.');

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la designación arbitral:' + @nl + @errores;
        THROW 50203, @errores, 1;
    END;

    INSERT INTO arbitraje.designacion_arbitral (partido_id, arbitro_id, rol_arbitral)
    VALUES (@partidoId, @arbitroId, @rolArbitral);

    SET @designacionId = SCOPE_IDENTITY();

    -- Advertencia (criterio a documentar): selección del país del árbitro que sigue en carrera
    IF @fase <> 'GRUPOS'
       AND EXISTS (
            SELECT 1
            FROM torneo.seleccion s
            WHERE s.pais_id = @paisArbitro
              AND NOT EXISTS (
                    SELECT 1 FROM torneo.partido p
                    WHERE p.fase <> 'GRUPOS' AND p.estado = 'FINALIZADO'
                      AND (   (p.seleccion_local_id = s.seleccion_id
                               AND (p.goles_local < p.goles_visitante
                                    OR (p.goles_local = p.goles_visitante AND p.penales_local < p.penales_visitante)))
                           OR (p.seleccion_visitante_id = s.seleccion_id
                               AND (p.goles_visitante < p.goles_local
                                    OR (p.goles_local = p.goles_visitante AND p.penales_visitante < p.penales_local))))))
        RAISERROR (N'Advertencia: el país del árbitro tiene una selección aún en carrera y podría cruzarse con el árbitro en fases posteriores.', 10, 1) WITH NOWAIT;
END;
GO

-- ============================================================================
-- arbitraje.designacion_rechazada
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_designacion_rechazada_alta
    @partidoId    INT,
    @arbitroId    INT,
    @rolArbitral  VARCHAR(10),
    @motivo       NVARCHAR(200),
    @rechazoId    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE partido_id = @partidoId)
        SET @errores += N'- El partido no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @arbitroId)
        SET @errores += N'- El árbitro no existe.' + @nl;
    IF @rolArbitral IS NULL OR @rolArbitral NOT IN ('PRINCIPAL','ASISTENTE','CUARTO','VAR')
        SET @errores += N'- El rol debe ser PRINCIPAL, ASISTENTE, CUARTO o VAR.' + @nl;
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = N''
        SET @errores += N'- El motivo es obligatorio.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la designación rechazada:' + @nl + @errores;
        THROW 50204, @errores, 1;
    END;

    INSERT INTO arbitraje.designacion_rechazada (partido_id, arbitro_id, rol_arbitral, motivo)
    VALUES (@partidoId, @arbitroId, @rolArbitral, LTRIM(RTRIM(@motivo)));

    SET @rechazoId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- arbitraje.informe_arbitral
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_informe_arbitral_alta
    @designacionId  INT,
    @fecha          DATE,
    @tipo           VARCHAR(10),
    @detalle        NVARCHAR(500),
    @informeId      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fechaPartido DATE;

    SELECT @fechaPartido = CAST(p.fecha_hora_local AS DATE)
    FROM arbitraje.designacion_arbitral d
    JOIN torneo.partido p ON p.partido_id = d.partido_id
    WHERE d.designacion_id = @designacionId;

    IF @fechaPartido IS NULL
        SET @errores += N'- La designación arbitral no existe.' + @nl;

    IF @fecha IS NULL
        SET @errores += N'- La fecha es obligatoria.' + @nl;
    IF @fecha IS NOT NULL AND @fechaPartido IS NOT NULL AND @fecha < @fechaPartido
        SET @errores += N'- La fecha del informe no puede ser anterior a la del partido.' + @nl;

    IF @tipo IS NULL OR @tipo NOT IN ('INFORME','SANCION')
        SET @errores += N'- El tipo debe ser INFORME o SANCION.' + @nl;

    IF @detalle IS NULL OR LTRIM(RTRIM(@detalle)) = N''
        SET @errores += N'- El detalle es obligatorio.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el informe arbitral:' + @nl + @errores;
        THROW 50205, @errores, 1;
    END;

    INSERT INTO arbitraje.informe_arbitral (designacion_id, fecha, tipo, detalle)
    VALUES (@designacionId, @fecha, @tipo, LTRIM(RTRIM(@detalle)));

    SET @informeId = SCOPE_IDENTITY();
END;
GO