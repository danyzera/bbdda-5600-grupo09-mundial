/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 09_sp_baja_publicidad.sql
   Objetivo    : Procedimientos almacenados de BAJA del esquema publicidad.
                 Mismas convenciones que el script 06. Sin cursores ni SQL dinamico.
                 Numeros de error: baja 51301-51307.
   ============================================================================ */

USE MundialDB;
GO
 
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
 
-- ============================================================================
-- publicidad.anunciante
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_anunciante_baja
    @anuncianteId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE anunciante_id = @anuncianteId)
        SET @errores += N'- El anunciante no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.campania WHERE anunciante_id = @anuncianteId)
        SET @errores += N'- El anunciante tiene campañas asociadas. Dé de baja las campañas primero.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el anunciante:' + @nl + @errores;
        THROW 51301, @errores, 1;
    END;
 
    DELETE FROM publicidad.anunciante WHERE anunciante_id = @anuncianteId;
END;
GO

-- ============================================================================
-- publicidad.campania
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_campania_baja
    @campaniaId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.campania WHERE campania_id = @campaniaId)
        SET @errores += N'- La campaña no existe.' + @nl;
    
    IF EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria WHERE campania_id = @campaniaId)
        SET @errores += N'- La campaña tiene piezas publicitarias asociadas. Dé de baja las piezas primero.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la campaña:' + @nl + @errores;
        THROW 51302, @errores, 1;
    END;
 
    DELETE FROM publicidad.campania WHERE campania_id = @campaniaId;
END;
GO
 
-- ============================================================================
-- publicidad.pieza_publicitaria
-- La baja quita también sus países en una transacción.
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_pieza_publicitaria_baja
    @piezaId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria WHERE pieza_id = @piezaId)
        SET @errores += N'- La pieza publicitaria no existe.' + @nl;
        
    IF EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE pieza_id = @piezaId)
        SET @errores += N'- La pieza está asignada a uno o más partidos. Elimine esas asignaciones primero.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la pieza publicitaria:' + @nl + @errores;
        THROW 51303, @errores, 1;
    END;
 
    BEGIN TRY
        BEGIN TRAN;
        
        -- Eliminar primero la tabla hija (pieza_pais)
        DELETE FROM publicidad.pieza_pais WHERE pieza_id = @piezaId;
        
        -- Luego eliminar la pieza
        DELETE FROM publicidad.pieza_publicitaria WHERE pieza_id = @piezaId;
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
 
-- ============================================================================
-- publicidad.pieza_pais
-- Una pieza debe quedar dirigida al menos a un pais (si no, no entra en ningun criterio
-- de asignacion de la seccion H). Para quitarlos todos se da de baja la pieza.
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_pieza_pais_baja
    @piezaId INT,
    @paisId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_pais WHERE pieza_id = @piezaId AND pais_id = @paisId)
        SET @errores += N'- La relación entre la pieza y el país no existe.' + @nl;
        
    -- Validar que no se elimine el único país asociado
    IF (SELECT COUNT(*) FROM publicidad.pieza_pais WHERE pieza_id = @piezaId) <= 1
        SET @errores += N'- No se puede quitar el único país asociado. Para quitarlos todos, dé de baja la pieza completa.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo quitar el país de la pieza:' + @nl + @errores;
        THROW 51304, @errores, 1;
    END;
 
    DELETE FROM publicidad.pieza_pais WHERE pieza_id = @piezaId AND pais_id = @paisId;
END;
GO
 
-- ============================================================================
-- publicidad.tarifa_publicidad
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_tarifa_publicidad_baja
    @tarifaId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.tarifa_publicidad WHERE tarifa_id = @tarifaId)
        SET @errores += N'- La tarifa publicitaria no existe.' + @nl;
        
    IF EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE tarifa_id = @tarifaId)
        SET @errores += N'- La tarifa no se puede eliminar porque ya está siendo utilizada en asignaciones de partidos.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la tarifa:' + @nl + @errores;
        THROW 51305, @errores, 1;
    END;
 
    DELETE FROM publicidad.tarifa_publicidad WHERE tarifa_id = @tarifaId;
END;
GO
 
-- ============================================================================
-- publicidad.tipo_cambio
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_tipo_cambio_baja
    @tipoCambioId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
 
    IF NOT EXISTS (SELECT 1 FROM publicidad.tipo_cambio WHERE tipo_cambio_id = @tipoCambioId)
        SET @errores += N'- El tipo de cambio no existe.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el tipo de cambio:' + @nl + @errores;
        THROW 51306, @errores, 1;
    END;
 
    DELETE FROM publicidad.tipo_cambio WHERE tipo_cambio_id = @tipoCambioId;
END;
GO
 
-- ============================================================================
-- publicidad.publicidad_partido
-- La baja solo se permite mientras el partido esta PROGRAMADO: una vez jugado, la
-- publicidad exhibida es el registro historico para facturar a los anunciantes.
-- ============================================================================
CREATE OR ALTER PROCEDURE publicidad.sp_publicidad_partido_baja
    @publicidadId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estadoPartido VARCHAR(20);
    
    SELECT @estadoPartido = p.estado 
    FROM publicidad.publicidad_partido pp
    JOIN torneo.partido p ON p.partido_id = pp.partido_id
    WHERE pp.publicidad_id = @publicidadId;
 
    IF @estadoPartido IS NULL
        SET @errores += N'- La asignación de publicidad en el partido no existe.' + @nl;
    ELSE IF @estadoPartido <> 'PROGRAMADO'
        SET @errores += N'- Solo se puede eliminar la publicidad de un partido en estado PROGRAMADO.' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la publicidad del partido:' + @nl + @errores;
        THROW 51307, @errores, 1;
    END;
 
    DELETE FROM publicidad.publicidad_partido WHERE publicidad_id = @publicidadId;
END;
GO