/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600       Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 06_sp_alta_publicidad.sql
   Objetivo    : Procedimientos almacenados de ALTA del esquema publicidad.
                 Numeros de error: 50301-50307.
   ============================================================================ */

USE MundialDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- publicidad.anunciante
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_anunciante_alta
    @nombre        NVARCHAR(100),
    @rubro         NVARCHAR(100) = NULL,
    @email         VARCHAR(150)  = NULL,
    @paisId        INT,
    @anuncianteId  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;

    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El pa�s no existe.' + @nl;

    IF EXISTS (SELECT 1 FROM publicidad.anunciante WHERE nombre = LTRIM(RTRIM(@nombre)) AND pais_id = @paisId)
        SET @errores += N'- Ya existe un anunciante con ese nombre en ese pa�s.' + @nl;

    IF @email IS NOT NULL AND @email NOT LIKE '%_@_%._%'
        SET @errores += N'- El e-mail no tiene un formato v�lido.' + @nl;
    IF @email IS NOT NULL AND EXISTS (SELECT 1 FROM publicidad.anunciante WHERE email = LTRIM(RTRIM(@email)))
        SET @errores += N'- Ya existe un anunciante con ese e-mail.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el anunciante:' + @nl + @errores;
        THROW 50301, @errores, 1;
    END;

    INSERT INTO publicidad.anunciante (nombre, rubro, email, pais_id)
    VALUES (LTRIM(RTRIM(@nombre)), @rubro, LTRIM(RTRIM(@email)), @paisId);

    SET @anuncianteId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- publicidad.campania
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_campania_alta
    @anuncianteId  INT,
    @nombre        NVARCHAR(100),
    @presupuesto   DECIMAL(14,2),
    @moneda        VARCHAR(10) = 'USD',
    @fechaInicio   DATE,
    @fechaFin      DATE,
    @campaniaId    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE anunciante_id = @anuncianteId)
        SET @errores += N'- El anunciante no existe.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.campania
               WHERE anunciante_id = @anuncianteId AND nombre = LTRIM(RTRIM(@nombre)))
        SET @errores += N'- El anunciante ya tiene una campa�a con ese nombre.' + @nl;

    IF @presupuesto IS NULL OR @presupuesto < 0
        SET @errores += N'- El presupuesto debe ser mayor o igual a cero.' + @nl;

    IF @moneda IS NULL OR @moneda NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda debe ser un c�digo de 3 letras (ej. USD).' + @nl;

    IF @fechaInicio IS NULL OR @fechaFin IS NULL
        SET @errores += N'- Las fechas de inicio y fin son obligatorias.' + @nl;
    IF @fechaInicio IS NOT NULL AND @fechaFin IS NOT NULL AND @fechaFin < @fechaInicio
        SET @errores += N'- La fecha de fin no puede ser anterior a la de inicio.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la campa�a:' + @nl + @errores;
        THROW 50302, @errores, 1;
    END;

    INSERT INTO publicidad.campania (anunciante_id, nombre, presupuesto, moneda, fecha_inicio, fecha_fin)
    VALUES (@anuncianteId, LTRIM(RTRIM(@nombre)), @presupuesto, UPPER(@moneda), @fechaInicio, @fechaFin);

    SET @campaniaId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- publicidad.pieza_publicitaria
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_pieza_publicitaria_alta
    @campaniaId  INT,
    @nombre      NVARCHAR(100),
    @idioma      NVARCHAR(50),
    @piezaId     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM publicidad.campania WHERE campania_id = @campaniaId)
        SET @errores += N'- La campa�a no existe.' + @nl;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria
               WHERE campania_id = @campaniaId AND nombre = LTRIM(RTRIM(@nombre)))
        SET @errores += N'- La campa�a ya tiene una pieza con ese nombre.' + @nl;

    IF @idioma IS NULL OR LTRIM(RTRIM(@idioma)) = N''
        SET @errores += N'- El idioma es obligatorio.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la pieza publicitaria:' + @nl + @errores;
        THROW 50303, @errores, 1;
    END;

    INSERT INTO publicidad.pieza_publicitaria (campania_id, nombre, idioma)
    VALUES (@campaniaId, LTRIM(RTRIM(@nombre)), LTRIM(RTRIM(@idioma)));

    SET @piezaId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- publicidad.pieza_pais 
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_pieza_pais_alta
    @piezaId  INT,
    @paisId   INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria WHERE pieza_id = @piezaId)
        SET @errores += N'- La pieza no existe.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El pa�s no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.pieza_pais WHERE pieza_id = @piezaId AND pais_id = @paisId)
        SET @errores += N'- La pieza ya est� dirigida a ese pa�s.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo asociar la pieza al pa�s:' + @nl + @errores;
        THROW 50304, @errores, 1;
    END;

    INSERT INTO publicidad.pieza_pais (pieza_id, pais_id)
    VALUES (@piezaId, @paisId);
END;
GO

-- ============================================================================
-- publicidad.tarifa_publicidad
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_tarifa_publicidad_alta
    @fase       VARCHAR(15),
    @espacio    TINYINT,
    @moneda     VARCHAR(10),
    @importe    DECIMAL(12,2),
    @tarifaId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF @fase IS NULL OR @fase NOT IN ('GRUPOS','DIECISEISAVOS','OCTAVOS','CUARTOS','SEMIFINAL','TERCER_PUESTO','FINAL')
        SET @errores += N'- La fase no es v�lida.' + @nl;

    IF @espacio IS NULL OR @espacio NOT BETWEEN 1 AND 4
        SET @errores += N'- El espacio debe estar entre 1 y 4.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.tarifa_publicidad WHERE fase = @fase AND espacio = @espacio)
        SET @errores += N'- Ya existe una tarifa para esa fase y espacio.' + @nl;

    IF @moneda IS NULL OR @moneda NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda debe ser un c�digo de 3 letras (ej. USD).' + @nl;

    IF @importe IS NULL OR @importe < 0
        SET @errores += N'- El importe debe ser mayor o igual a cero.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la tarifa:' + @nl + @errores;
        THROW 50305, @errores, 1;
    END;

    INSERT INTO publicidad.tarifa_publicidad (fase, espacio, moneda, importe)
    VALUES (@fase, @espacio, UPPER(@moneda), @importe);

    SET @tarifaId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- publicidad.tipo_cambio
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_tipo_cambio_alta
    @monedaOrigen   VARCHAR(10),
    @monedaDestino  VARCHAR(10),
    @fecha          DATE,
    @tasa           DECIMAL(18,8),
    @tipoCambioId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF @monedaOrigen IS NULL OR @monedaOrigen NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda de origen debe ser un c�digo de 3 letras.' + @nl;
    IF @monedaDestino IS NULL OR @monedaDestino NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda de destino debe ser un c�digo de 3 letras.' + @nl;
    IF @monedaOrigen = @monedaDestino
        SET @errores += N'- Las monedas de origen y destino deben ser distintas.' + @nl;

    IF @fecha IS NULL
        SET @errores += N'- La fecha es obligatoria.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.tipo_cambio
               WHERE moneda_origen = @monedaOrigen AND moneda_destino = @monedaDestino AND fecha = @fecha)
        SET @errores += N'- Ya existe un tipo de cambio para ese par de monedas y esa fecha.' + @nl;

    IF @tasa IS NULL OR @tasa <= 0
        SET @errores += N'- La tasa debe ser mayor a cero.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar el tipo de cambio:' + @nl + @errores;
        THROW 50306, @errores, 1;
    END;

    INSERT INTO publicidad.tipo_cambio (moneda_origen, moneda_destino, fecha, tasa)
    VALUES (UPPER(@monedaOrigen), UPPER(@monedaDestino), @fecha, @tasa);

    SET @tipoCambioId = SCOPE_IDENTITY();
END;
GO

-- ============================================================================
-- publicidad.publicidad_partido
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_publicidad_partido_alta
    @partidoId          INT,
    @piezaId            INT,
    @tarifaId           INT,
    @momentoEmision     DATETIME2(0),
    @espacio            TINYINT,
    @importeFacturado   DECIMAL(12,2),
    @moneda             VARCHAR(10),
    @publicidadId       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fasePartido VARCHAR(15), @fechaPartido DATE,
            @faseTarifa VARCHAR(15), @espacioTarifa TINYINT,
            @inicioCampania DATE, @finCampania DATE;

    SELECT @fasePartido = fase, @fechaPartido = CAST(fecha_hora_local AS DATE)
    FROM torneo.partido WHERE partido_id = @partidoId;

    SELECT @faseTarifa = fase, @espacioTarifa = espacio
    FROM publicidad.tarifa_publicidad WHERE tarifa_id = @tarifaId;

    SELECT @inicioCampania = c.fecha_inicio, @finCampania = c.fecha_fin
    FROM publicidad.pieza_publicitaria pz
    JOIN publicidad.campania c ON c.campania_id = pz.campania_id
    WHERE pz.pieza_id = @piezaId;

    IF @fasePartido IS NULL
        SET @errores += N'- El partido no existe.' + @nl;
    IF @inicioCampania IS NULL
        SET @errores += N'- La pieza publicitaria no existe.' + @nl;
    IF @faseTarifa IS NULL
        SET @errores += N'- La tarifa no existe.' + @nl;

    IF @espacio IS NULL OR @espacio NOT BETWEEN 1 AND 4
        SET @errores += N'- El espacio debe estar entre 1 y 4.' + @nl;
    IF @espacioTarifa IS NOT NULL AND @espacio <> @espacioTarifa
        SET @errores += N'- El espacio no coincide con el de la tarifa indicada.' + @nl;
    IF @faseTarifa IS NOT NULL AND @fasePartido IS NOT NULL AND @faseTarifa <> @fasePartido
        SET @errores += N'- La tarifa no corresponde a la fase del partido.' + @nl;

    IF EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE partido_id = @partidoId AND espacio = @espacio)
        SET @errores += N'- Ese espacio publicitario ya est� ocupado en el partido.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE partido_id = @partidoId AND pieza_id = @piezaId)
        SET @errores += N'- La pieza ya se emite en ese partido.' + @nl;

    IF @fechaPartido IS NOT NULL AND @inicioCampania IS NOT NULL
       AND (@fechaPartido < @inicioCampania OR @fechaPartido > @finCampania)
        SET @errores += N'- La campa�a de la pieza no est� vigente en la fecha del partido.' + @nl;

    IF @momentoEmision IS NULL
        SET @errores += N'- El momento de emisi�n es obligatorio.' + @nl;

    IF @importeFacturado IS NULL OR @importeFacturado < 0
        SET @errores += N'- El importe facturado debe ser mayor o igual a cero.' + @nl;

    IF @moneda IS NULL OR @moneda NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda debe ser un c�digo de 3 letras (ej. USD).' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo registrar la publicidad del partido:' + @nl + @errores;
        THROW 50307, @errores, 1;
    END;

    INSERT INTO publicidad.publicidad_partido (partido_id, pieza_id, tarifa_id, momento_emision,
                                               espacio, importe_facturado, moneda)
    VALUES (@partidoId, @piezaId, @tarifaId, @momentoEmision,
            @espacio, @importeFacturado, UPPER(@moneda));

    SET @publicidadId = SCOPE_IDENTITY();
END;
GO