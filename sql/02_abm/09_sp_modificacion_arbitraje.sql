/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com____        Grupo: ____
   Integrantes : (completar nombre y apellido de cada integrante)
   Fecha       : 06/10/2026
   Script      : 07_sp_baja_modificacion_arbitraje.sql
   Objetivo    : Procedimientos almacenados de MODIFICACION del esquema arbitraje.
                 Mismas convenciones que el script 06. Sin cursores ni SQL dinamico.
                 Numeros de error: baja 51201-51205, modificacion 52201-52205.
   ============================================================================ */

USE MundialDB;
GO
 
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
 
-- ============================================================================
-- arbitraje.arbitro  (la baja elimina tambien sus idiomas, en una transaccion)
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_arbitro_modificacion
    @arbitroId  INT,
    @nombre     NVARCHAR(150),
    @paisId     INT,
    @categoria  VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @paisActual INT = (SELECT pais_id FROM arbitraje.arbitro WHERE arbitro_id = @arbitroId);
 
    IF @paisActual IS NULL
        SET @errores += N'- El árbitro no existe.' + @nl;
 
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = N''
        SET @errores += N'- El nombre es obligatorio.' + @nl;
 
    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El país no existe.' + @nl;
    IF @paisActual IS NOT NULL AND @paisId <> @paisActual
       AND EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE arbitro_id = @arbitroId)
        SET @errores += N'- No se puede cambiar el país: el árbitro ya tiene designaciones validadas por nacionalidad.' + @nl;
 
    IF EXISTS (SELECT 1 FROM arbitraje.arbitro
               WHERE nombre = LTRIM(RTRIM(@nombre)) AND pais_id = @paisId AND arbitro_id <> @arbitroId)
        SET @errores += N'- Ya existe otro árbitro con ese nombre y país.' + @nl;
 
    IF @categoria IS NULL OR @categoria NOT IN ('FIFA','CONFEDERACION')
        SET @errores += N'- La categoría debe ser FIFA o CONFEDERACION.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el árbitro:' + @nl + @errores;
        THROW 52201, @errores, 1;
    END;
 
    UPDATE arbitraje.arbitro
    SET nombre = LTRIM(RTRIM(@nombre)), pais_id = @paisId, categoria = @categoria
    WHERE arbitro_id = @arbitroId;
END;
GO
 
-- ============================================================================
-- arbitraje.arbitro_idioma
-- ============================================================================ 
CREATE OR ALTER PROCEDURE arbitraje.sp_arbitro_idioma_modificacion
    @arbitroId      INT,
    @idiomaActual   NVARCHAR(50),
    @idiomaNuevo    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM arbitraje.arbitro_idioma
                   WHERE arbitro_id = @arbitroId AND idioma = LTRIM(RTRIM(@idiomaActual)))
        SET @errores += N'- El árbitro no tiene registrado el idioma a modificar.' + @nl;
 
    IF @idiomaNuevo IS NULL OR LTRIM(RTRIM(@idiomaNuevo)) = N''
        SET @errores += N'- El idioma nuevo es obligatorio.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.arbitro_idioma
               WHERE arbitro_id = @arbitroId AND idioma = LTRIM(RTRIM(@idiomaNuevo)))
        SET @errores += N'- El árbitro ya tiene registrado el idioma nuevo.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el idioma del árbitro:' + @nl + @errores;
        THROW 52202, @errores, 1;
    END;
 
    UPDATE arbitraje.arbitro_idioma
    SET idioma = LTRIM(RTRIM(@idiomaNuevo))
    WHERE arbitro_id = @arbitroId AND idioma = LTRIM(RTRIM(@idiomaActual));
END;
GO
 
-- ============================================================================
-- arbitraje.designacion_arbitral
-- Solo se pueden dar de baja / modificar designaciones de partidos PROGRAMADOS.
-- ============================================================================
-- Solo el rol; para cambiar de partido o de árbitro: baja + alta (se revalida la nacionalidad)
CREATE OR ALTER PROCEDURE arbitraje.sp_designacion_arbitral_modificacion
    @designacionId  INT,
    @rolArbitral    VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @estadoPartido VARCHAR(12);
 
    SELECT @partidoId = d.partido_id, @estadoPartido = p.estado
    FROM arbitraje.designacion_arbitral d
    JOIN torneo.partido p ON p.partido_id = d.partido_id
    WHERE d.designacion_id = @designacionId;
 
    IF @partidoId IS NULL
        SET @errores += N'- La designación no existe.' + @nl;
    IF @estadoPartido IS NOT NULL AND @estadoPartido <> 'PROGRAMADO'
        SET @errores += N'- El partido ya comenzó; no se pueden modificar sus designaciones.' + @nl;
 
    IF @rolArbitral IS NULL OR @rolArbitral NOT IN ('PRINCIPAL','ASISTENTE','CUARTO','VAR')
        SET @errores += N'- El rol debe ser PRINCIPAL, ASISTENTE, CUARTO o VAR.' + @nl;
    IF @rolArbitral IN ('PRINCIPAL','CUARTO','VAR')
       AND EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral
                   WHERE partido_id = @partidoId AND rol_arbitral = @rolArbitral AND designacion_id <> @designacionId)
        SET @errores += N'- El partido ya tiene un árbitro con ese rol.' + @nl;
    IF @rolArbitral = 'ASISTENTE'
       AND (SELECT COUNT(*) FROM arbitraje.designacion_arbitral
            WHERE partido_id = @partidoId AND rol_arbitral = 'ASISTENTE'
              AND designacion_id <> @designacionId) >= 2
        SET @errores += N'- El partido ya tiene los dos árbitros asistentes.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la designación arbitral:' + @nl + @errores;
        THROW 52203, @errores, 1;
    END;
 
    UPDATE arbitraje.designacion_arbitral SET rol_arbitral = @rolArbitral WHERE designacion_id = @designacionId;
END;
GO
 
-- ============================================================================
-- arbitraje.designacion_rechazada
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_designacion_rechazada_modificacion
    @rechazoId  INT,
    @motivo     NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM arbitraje.designacion_rechazada WHERE rechazo_id = @rechazoId)
        SET @errores += N'- La designación rechazada no existe.' + @nl;
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = N''
        SET @errores += N'- El motivo es obligatorio.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar la designación rechazada:' + @nl + @errores;
        THROW 52204, @errores, 1;
    END;
 
    UPDATE arbitraje.designacion_rechazada SET motivo = LTRIM(RTRIM(@motivo)) WHERE rechazo_id = @rechazoId;
END;
GO
 
-- ============================================================================
-- arbitraje.informe_arbitral
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_informe_arbitral_modificacion
    @informeId  INT,
    @fecha      DATE,
    @tipo       VARCHAR(10),
    @detalle    NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fechaPartido DATE;
 
    SELECT @fechaPartido = CAST(p.fecha_hora_local AS DATE)
    FROM arbitraje.informe_arbitral i
    JOIN arbitraje.designacion_arbitral d ON d.designacion_id = i.designacion_id
    JOIN torneo.partido p ON p.partido_id = d.partido_id
    WHERE i.informe_id = @informeId;
 
    IF @fechaPartido IS NULL
        SET @errores += N'- El informe no existe.' + @nl;
 
    IF @fecha IS NULL
        SET @errores += N'- La fecha es obligatoria.' + @nl;
    IF @fecha IS NOT NULL AND @fechaPartido IS NOT NULL AND @fecha < @fechaPartido
        SET @errores += N'- La fecha del informe no puede ser anterior a la del partido.' + @nl;
    IF @fecha IS NOT NULL AND @fecha > CAST(SYSDATETIME() AS DATE)
        SET @errores += N'- La fecha del informe no puede ser futura.' + @nl;
 
    IF @tipo IS NULL OR @tipo NOT IN ('INFORME','SANCION')
        SET @errores += N'- El tipo debe ser INFORME o SANCION.' + @nl;
 
    IF @detalle IS NULL OR LTRIM(RTRIM(@detalle)) = N''
        SET @errores += N'- El detalle es obligatorio.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo modificar el informe arbitral:' + @nl + @errores;
        THROW 52205, @errores, 1;
    END;
 
    UPDATE arbitraje.informe_arbitral
    SET fecha = @fecha, tipo = @tipo, detalle = LTRIM(RTRIM(@detalle))
    WHERE informe_id = @informeId;
END;
GO