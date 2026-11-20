/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 01_seguridad_cifrado.sql
   Objetivo    : Crear objetos de cifrado para datos sensibles.
   ============================================================================ */

   USE MundialDB;
GO

/*SELECT COUNT(*) AS TotalInformes 
FROM arbitraje.informe_arbitral;
GO*/
--modificamos la tabla para que acepte cifrado
ALTER TABLE arbitraje.informe_arbitral
ALTER COLUMN detalle VARBINARY(MAX) NOT NULL;
GO
--modificamos los sp para que acepte cifrado
CREATE OR ALTER PROCEDURE arbitraje.sp_informe_arbitral_alta
    @designacionId  INT,
    @fecha          DATE,
    @tipo           VARCHAR(10),
    @detalle        NVARCHAR(500),
    @fraseClave     NVARCHAR(128), -- Frase clave para el cifrado
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
    IF @fecha IS NOT NULL AND @fecha > CAST(GETDATE() AS DATE)
        SET @errores += N'- La fecha del informe no puede ser una fecha futura.' + @nl;
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

    -- Insertamos cifrando el detalle con la frase clave y un hash basado en el designacion_id
    INSERT INTO arbitraje.informe_arbitral (designacion_id, fecha, tipo, detalle)
    VALUES (
        @designacionId, 
        @fecha, 
        @tipo, 
        EncryptByPassPhrase(@fraseClave, CONVERT(NVARCHAR(500), LTRIM(RTRIM(@detalle))), 1, CONVERT(VARBINARY, @designacionId))
    );

    SET @informeId = SCOPE_IDENTITY();
END;
GO
CREATE OR ALTER PROCEDURE arbitraje.sp_informe_arbitral_modificacion
    @informeId   INT,
    @fecha       DATE,
    @tipo        VARCHAR(10),
    @detalle     NVARCHAR(500),
    @fraseClave  NVARCHAR(128) -- Frase clave para volver a cifrar el nuevo texto
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fechaPartido DATE;
    DECLARE @designacionId INT;
 
    SELECT 
        @fechaPartido = CAST(p.fecha_hora_local AS DATE),
        @designacionId = d.designacion_id
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
    IF @fecha IS NOT NULL AND @fecha > CAST(GETDATE() AS DATE)
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
 
    -- Actualizamos aplicando el cifrado al nuevo detalle modificado
    UPDATE arbitraje.informe_arbitral
    SET 
        fecha = @fecha, 
        tipo = @tipo, 
        detalle = EncryptByPassPhrase(@fraseClave, CONVERT(NVARCHAR(500), LTRIM(RTRIM(@detalle))), 1, CONVERT(VARBINARY, @designacionId))
    WHERE informe_id = @informeId;
END;
GO
DECLARE @nuevoId INT;

--ejemplo
EXEC arbitraje.sp_informe_arbitral_alta
    @designacionId = 1, 
    @fecha = '2026-06-11',
    @tipo = 'SANCION',
    @detalle = N'El jugador protestó de mal modo y fue expulsado.',
    @fraseClave = N'ClaveSecretaDelMundial2026',
    @informeId = @nuevoId OUTPUT;

PRINT 'Informe creado con ID: ' + CAST(@nuevoId AS VARCHAR);

EXEC arbitraje.sp_informe_arbitral_modificacion
    @informeId = 1,
    @fecha = '2026-06-11',
    @tipo = 'SANCION',
    @detalle = N'Detalle actualizado: insulto grave al juez de línea tras finalizar.',
    @fraseClave = N'ClaveSecretaDelMundial2026';
GO
DECLARE @nuevoId INT;

EXEC arbitraje.sp_informe_arbitral_alta
    @designacionId = 1,
    @fecha = '2026-06-11',
    @tipo = 'SANCION',
    @detalle = N'El jugador protestó de mal modo.',
    @fraseClave = N'ClaveSecretaDelMundial2026',
    @informeId = @nuevoId OUTPUT;

PRINT 'Informe creado con ID: ' + CAST(@nuevoId AS VARCHAR);
GO
--si colocamos bien la clave 
DECLARE @FraseClave NVARCHAR(128) = N'ClaveSecretaDelMundial2026';

SELECT 
    informe_id,
    designacion_id,
    fecha,
    tipo,
    CONVERT(NVARCHAR(500), DecryptByPassPhrase(
        @FraseClave, 
        detalle, 
        1, 
        CONVERT(VARBINARY, designacion_id)
    )) AS detalle_descifrado
FROM arbitraje.informe_arbitral;
GO
--si colocamos mal la clave 
DECLARE @FraseClave NVARCHAR(128) = N'ClaveSecretaDelMundial2025';

SELECT 
    informe_id,
    designacion_id,
    fecha,
    tipo,
    CONVERT(NVARCHAR(500), DecryptByPassPhrase(
        @FraseClave, 
        detalle, 
        1, 
        CONVERT(VARBINARY, designacion_id)
    )) AS detalle_descifrado
FROM arbitraje.informe_arbitral;
GO