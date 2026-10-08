/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com____        Grupo: ____
   Integrantes : (completar nombre y apellido de cada integrante)
   Fecha       : 06/10/2026
   Script      : 07_sp_baja_modificacion_arbitraje.sql
   Objetivo    : Procedimientos almacenados de BAJA del esquema arbitraje.
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
CREATE OR ALTER PROCEDURE arbitraje.sp_arbitro_baja
    @arbitroId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE arbitro_id = @arbitroId)
        SET @errores += N'- El árbitro no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE arbitro_id = @arbitroId)
        SET @errores += N'- El árbitro tiene designaciones registradas.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.designacion_rechazada WHERE arbitro_id = @arbitroId)
        SET @errores += N'- El árbitro tiene designaciones rechazadas registradas.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja al árbitro:' + @nl + @errores;
        THROW 51201, @errores, 1;
    END;
 
    BEGIN TRY
        BEGIN TRANSACTION;
            DELETE FROM arbitraje.arbitro_idioma WHERE arbitro_id = @arbitroId;
            DELETE FROM arbitraje.arbitro WHERE arbitro_id = @arbitroId;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- arbitraje.arbitro_idioma
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_arbitro_idioma_baja
    @arbitroId  INT,
    @idioma     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM arbitraje.arbitro_idioma
                   WHERE arbitro_id = @arbitroId AND idioma = LTRIM(RTRIM(@idioma)))
        SET @errores += N'- El árbitro no tiene registrado ese idioma.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el idioma del árbitro:' + @nl + @errores;
        THROW 51202, @errores, 1;
    END;
 
    DELETE FROM arbitraje.arbitro_idioma
    WHERE arbitro_id = @arbitroId AND idioma = LTRIM(RTRIM(@idioma));
END;
GO

-- ============================================================================
-- arbitraje.designacion_arbitral
-- Solo se pueden dar de baja / modificar designaciones de partidos PROGRAMADOS.
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_designacion_arbitral_baja
    @designacionId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estadoPartido VARCHAR(12) = (SELECT p.estado
                                          FROM arbitraje.designacion_arbitral d
                                          JOIN torneo.partido p ON p.partido_id = d.partido_id
                                          WHERE d.designacion_id = @designacionId);
 
    IF NOT EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE designacion_id = @designacionId)
        SET @errores += N'- La designación no existe.' + @nl;
    IF @estadoPartido IS NOT NULL AND @estadoPartido <> 'PROGRAMADO'
        SET @errores += N'- El partido ya comenzó; no se pueden modificar sus designaciones.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.informe_arbitral WHERE designacion_id = @designacionId)
        SET @errores += N'- La designación tiene informes arbitrales asociados.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la designación arbitral:' + @nl + @errores;
        THROW 51203, @errores, 1;
    END;
 
    DELETE FROM arbitraje.designacion_arbitral WHERE designacion_id = @designacionId;
END;
GO

-- ============================================================================
-- arbitraje.designacion_rechazada
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_designacion_rechazada_baja
    @rechazoId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM arbitraje.designacion_rechazada WHERE rechazo_id = @rechazoId)
        SET @errores += N'- La designación rechazada no existe.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la designación rechazada:' + @nl + @errores;
        THROW 51204, @errores, 1;
    END;
 
    DELETE FROM arbitraje.designacion_rechazada WHERE rechazo_id = @rechazoId;
END;
GO
 
-- ============================================================================
-- arbitraje.informe_arbitral
-- ============================================================================
CREATE OR ALTER PROCEDURE arbitraje.sp_informe_arbitral_baja
    @informeId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM arbitraje.informe_arbitral WHERE informe_id = @informeId)
        SET @errores += N'- El informe no existe.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el informe arbitral:' + @nl + @errores;
        THROW 51205, @errores, 1;
    END;
 
    DELETE FROM arbitraje.informe_arbitral WHERE informe_id = @informeId;
END;
GO
 








