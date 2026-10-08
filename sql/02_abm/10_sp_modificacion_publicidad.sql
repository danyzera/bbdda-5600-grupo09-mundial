/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com____        Grupo: ____
   Integrantes : (completar nombre y apellido de cada integrante)
   Fecha       : 06/10/2026
   Script      : 08_sp_baja_modificacion_publicidad.sql
   Objetivo    : Procedimientos almacenados de MODIFICACION del esquema publicidad.
                 Mismas convenciones que el script 06. Sin cursores ni SQL dinamico.
                 Numeros de error: baja 51301-51307, modificacion 52301-52307.
   ============================================================================ */

USE MundialDB;
GO
 
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
 
-- ============================================================================
-- publicidad.anunciante
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_anunciante_modificacion
    @anuncianteId  INT,
    @nombre        NVARCHAR(100),
    @rubro         NVARCHAR(100) = NULL,
    @email         VARCHAR(150)  = NULL,
    @paisId        INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE anunciante_id = @anuncianteId)
        SET @errores += N'- El anunciante no existe.' + @nl;
 
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
 
    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El país no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.anunciante
               WHERE nombre = LTRIM(RTRIM(@nombre)) AND pais_id = @paisId AND anunciante_id <> @anuncianteId)
        SET @errores += N'- Ya existe otro anunciante con ese nombre en ese país.' + @nl;
 
    IF @email IS NOT NULL AND @email NOT LIKE '%_@_%._%'
        SET @errores += N'- El e-mail no tiene un formato válido.' + @nl;
    IF @email IS NOT NULL
       AND EXISTS (SELECT 1 FROM publicidad.anunciante WHERE email = LTRIM(RTRIM(@email)) AND anunciante_id <> @anuncianteId)
        SET @errores += N'- Ya existe otro anunciante con ese e-mail.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el anunciante:' + @nl + @errores;
        THROW 52301, @errores, 1;
    END;
 
    UPDATE publicidad.anunciante
    SET nombre = LTRIM(RTRIM(@nombre)), rubro = @rubro, email = LTRIM(RTRIM(@email)), pais_id = @paisId
    WHERE anunciante_id = @anuncianteId;
END;
GO
 
-- ============================================================================
-- publicidad.campania
-- ============================================================================
-- El anunciante no se modifica (baja + alta)
CREATE OR ALTER PROCEDURE publicidad.sp_campania_modificacion
    @campaniaId   INT,
    @nombre       NVARCHAR(100),
    @presupuesto  DECIMAL(14,2),
    @moneda       VARCHAR(10),
    @fechaInicio  DATE,
    @fechaFin     DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @anuncianteId INT = (SELECT anunciante_id FROM publicidad.campania WHERE campania_id = @campaniaId);
 
    IF @anuncianteId IS NULL
        SET @errores += N'- La campaña no existe.' + @nl;
 
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.campania
               WHERE anunciante_id = @anuncianteId AND nombre = LTRIM(RTRIM(@nombre)) AND campania_id <> @campaniaId)
        SET @errores += N'- El anunciante ya tiene otra campaña con ese nombre.' + @nl;
 
    IF @presupuesto IS NULL OR @presupuesto < 0
        SET @errores += N'- El presupuesto debe ser mayor o igual a cero.' + @nl;
 
    IF @moneda IS NULL OR @moneda NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda debe ser un código de 3 letras (ej. USD).' + @nl;
 
    IF @fechaInicio IS NULL OR @fechaFin IS NULL
        SET @errores += N'- Las fechas de inicio y fin son obligatorias.' + @nl;
    IF @fechaInicio IS NOT NULL AND @fechaFin IS NOT NULL AND @fechaFin < @fechaInicio
        SET @errores += N'- La fecha de fin no puede ser anterior a la de inicio.' + @nl;
    IF @fechaInicio IS NOT NULL AND @fechaFin IS NOT NULL
       AND EXISTS (SELECT 1
                   FROM publicidad.publicidad_partido pp
                   JOIN publicidad.pieza_publicitaria pz ON pz.pieza_id = pp.pieza_id
                   JOIN torneo.partido p ON p.partido_id = pp.partido_id
                   WHERE pz.campania_id = @campaniaId
                     AND CAST(p.fecha_hora_local AS DATE) NOT BETWEEN @fechaInicio AND @fechaFin)
        SET @errores += N'- Las nuevas fechas dejan fuera partidos donde la campaña ya tiene publicidad asignada.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la campaña:' + @nl + @errores;
        THROW 52302, @errores, 1;
    END;
 
    UPDATE publicidad.campania
    SET nombre = LTRIM(RTRIM(@nombre)), presupuesto = @presupuesto, moneda = UPPER(@moneda),
        fecha_inicio = @fechaInicio, fecha_fin = @fechaFin
    WHERE campania_id = @campaniaId;
END;
GO
 
-- ============================================================================
-- publicidad.pieza_publicitaria  (la baja quita tambien sus paises, en una transaccion)
-- ============================================================================
-- La campaña no se modifica (baja + alta)
CREATE OR ALTER PROCEDURE publicidad.sp_pieza_publicitaria_modificacion
    @piezaId  INT,
    @nombre   NVARCHAR(100),
    @idioma   NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @campaniaId INT = (SELECT campania_id FROM publicidad.pieza_publicitaria WHERE pieza_id = @piezaId);
 
    IF @campaniaId IS NULL
        SET @errores += N'- La pieza no existe.' + @nl;
 
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria
               WHERE campania_id = @campaniaId AND nombre = LTRIM(RTRIM(@nombre)) AND pieza_id <> @piezaId)
        SET @errores += N'- La campaña ya tiene otra pieza con ese nombre.' + @nl;
 
    IF @idioma IS NULL OR LTRIM(RTRIM(@idioma)) = N''
        SET @errores += N'- El idioma es obligatorio.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la pieza publicitaria:' + @nl + @errores;
        THROW 52303, @errores, 1;
    END;
 
    UPDATE publicidad.pieza_publicitaria
    SET nombre = LTRIM(RTRIM(@nombre)), idioma = LTRIM(RTRIM(@idioma))
    WHERE pieza_id = @piezaId;
END;
GO
 
-- ============================================================================
-- publicidad.pieza_pais
-- Una pieza debe quedar dirigida al menos a un pais (si no, no entra en ningun criterio
-- de asignacion de la seccion H). Para quitarlos todos se da de baja la pieza.
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_pieza_pais_modificacion
    @piezaId      INT,
    @paisActual   INT,
    @paisNuevo    INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_pais WHERE pieza_id = @piezaId AND pais_id = @paisActual)
        SET @errores += N'- La pieza no está dirigida al país a modificar.' + @nl;
    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisNuevo)
        SET @errores += N'- El país nuevo no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.pieza_pais WHERE pieza_id = @piezaId AND pais_id = @paisNuevo)
        SET @errores += N'- La pieza ya está dirigida al país nuevo.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el país de la pieza:' + @nl + @errores;
        THROW 52304, @errores, 1;
    END;
 
    UPDATE publicidad.pieza_pais SET pais_id = @paisNuevo
    WHERE pieza_id = @piezaId AND pais_id = @paisActual;
END;
GO
 
-- ============================================================================
-- publicidad.tarifa_publicidad
-- ============================================================================
-- Fase y espacio no se modifican (la tarifa está atada a emisiones por esos datos)
CREATE OR ALTER PROCEDURE publicidad.sp_tarifa_publicidad_modificacion
    @tarifaId  INT,
    @moneda    VARCHAR(10),
    @importe   DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.tarifa_publicidad WHERE tarifa_id = @tarifaId)
        SET @errores += N'- La tarifa no existe.' + @nl;
    IF @moneda IS NULL OR @moneda NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda debe ser un código de 3 letras (ej. USD).' + @nl;
    IF @importe IS NULL OR @importe < 0
        SET @errores += N'- El importe debe ser mayor o igual a cero.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la tarifa:' + @nl + @errores;
        THROW 52305, @errores, 1;
    END;
 
    UPDATE publicidad.tarifa_publicidad
    SET moneda = UPPER(@moneda), importe = @importe
    WHERE tarifa_id = @tarifaId;
END;
GO
 
-- ============================================================================
-- publicidad.tipo_cambio
-- ============================================================================
-- Monedas y fecha no se modifican (definen la cotización); solo la tasa
CREATE OR ALTER PROCEDURE publicidad.sp_tipo_cambio_modificacion
    @tipoCambioId  INT,
    @tasa          DECIMAL(18,8)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.tipo_cambio WHERE tipo_cambio_id = @tipoCambioId)
        SET @errores += N'- El tipo de cambio no existe.' + @nl;
    IF @tasa IS NULL OR @tasa <= 0
        SET @errores += N'- La tasa debe ser mayor a cero.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el tipo de cambio:' + @nl + @errores;
        THROW 52306, @errores, 1;
    END;
 
    UPDATE publicidad.tipo_cambio SET tasa = @tasa WHERE tipo_cambio_id = @tipoCambioId;
END;
GO
 
-- ============================================================================
-- publicidad.publicidad_partido
-- La baja solo se permite mientras el partido esta PROGRAMADO: una vez jugado, la
-- publicidad exhibida es el registro historico para facturar a los anunciantes.
-- ============================================================================
-- Partido, pieza, tarifa y espacio no se modifican (baja + alta)
CREATE OR ALTER PROCEDURE publicidad.sp_publicidad_partido_modificacion
    @publicidadId       INT,
    @momentoEmision     DATETIME2(0),
    @importeFacturado   DECIMAL(12,2),
    @moneda             VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE publicidad_id = @publicidadId)
        SET @errores += N'- La publicidad del partido no existe.' + @nl;
    IF @momentoEmision IS NULL
        SET @errores += N'- El momento de emisión es obligatorio.' + @nl;
    IF @importeFacturado IS NULL OR @importeFacturado < 0
        SET @errores += N'- El importe facturado debe ser mayor o igual a cero.' + @nl;
    IF @moneda IS NULL OR @moneda NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]'
        SET @errores += N'- La moneda debe ser un código de 3 letras (ej. USD).' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la publicidad del partido:' + @nl + @errores;
        THROW 52307, @errores, 1;
    END;
 
    UPDATE publicidad.publicidad_partido
    SET momento_emision = @momentoEmision, importe_facturado = @importeFacturado, moneda = UPPER(@moneda)
    WHERE publicidad_id = @publicidadId;
END;
GO