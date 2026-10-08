/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com____        Grupo: ____
   Integrantes : (completar nombre y apellido de cada integrante)
   Fecha       : 06/10/2026
   Script      : 06_sp_baja_modificacion_torneo.sql
   Objetivo    : Procedimientos almacenados de BAJA del esquema torneo.

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

CREATE OR ALTER PROCEDURE torneo.sp_pais_baja
    @paisId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.pais WHERE pais_id = @paisId)
        SET @errores += N'- El país no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.sede WHERE pais_id = @paisId)
        SET @errores += N'- El país tiene sedes asociadas.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.seleccion WHERE pais_id = @paisId)
        SET @errores += N'- El país tiene una selección asociada.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.arbitro WHERE pais_id = @paisId)
        SET @errores += N'- El país tiene árbitros asociados.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.anunciante WHERE pais_id = @paisId)
        SET @errores += N'- El país tiene anunciantes asociados.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.pieza_pais WHERE pais_id = @paisId)
        SET @errores += N'- El país es mercado de piezas publicitarias.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el país:' + @nl + @errores;
        THROW 51101, @errores, 1;
    END;

    DELETE FROM torneo.pais WHERE pais_id = @paisId;
END;
GO

-- ============================================================================
-- torneo.sede
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_sede_baja
    @sedeId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.sede WHERE sede_id = @sedeId)
        SET @errores += N'- La sede no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.partido WHERE sede_id = @sedeId)
        SET @errores += N'- La sede tiene partidos asociados.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la sede:' + @nl + @errores;
        THROW 51102, @errores, 1;
    END;

    DELETE FROM torneo.sede WHERE sede_id = @sedeId;
END;
GO

-- ============================================================================
-- torneo.seleccion
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_seleccion_baja
    @seleccionId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cuerpo_tecnico WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección tiene cuerpo técnico asociado.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.convocatoria WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección tiene convocatorias asociadas.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.reemplazo_convocatoria WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección tiene reemplazos de convocatoria registrados.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.partido
               WHERE seleccion_local_id = @seleccionId OR seleccion_visitante_id = @seleccionId)
        SET @errores += N'- La selección tiene partidos asociados.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.formacion_partido WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección tiene formaciones registradas.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cambio WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección tiene cambios registrados.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.gol WHERE seleccion_id = @seleccionId)
        SET @errores += N'- La selección tiene goles registrados.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la selección:' + @nl + @errores;
        THROW 51103, @errores, 1;
    END;

    DELETE FROM torneo.seleccion WHERE seleccion_id = @seleccionId;
END;
GO

-- ============================================================================
-- torneo.cuerpo_tecnico
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_cuerpo_tecnico_baja
    @cuerpoId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.cuerpo_tecnico WHERE cuerpo_id = @cuerpoId)
        SET @errores += N'- El integrante del cuerpo técnico no existe.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja al integrante del cuerpo técnico:' + @nl + @errores;
        THROW 51104, @errores, 1;
    END;

    DELETE FROM torneo.cuerpo_tecnico WHERE cuerpo_id = @cuerpoId;
END;
GO

-- ============================================================================
-- torneo.jugador
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_jugador_baja
    @jugadorId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.convocatoria WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador tiene convocatorias registradas.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.reemplazo_convocatoria
               WHERE jugador_baja_id = @jugadorId OR jugador_alta_id = @jugadorId)
        SET @errores += N'- El jugador figura en reemplazos de convocatoria.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.alineacion_detalle WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador figura en alineaciones.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cambio WHERE jugador_sale_id = @jugadorId OR jugador_entra_id = @jugadorId)
        SET @errores += N'- El jugador figura en cambios.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.gol WHERE jugador_id = @jugadorId OR jugador_asistente_id = @jugadorId)
        SET @errores += N'- El jugador figura en goles.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.tarjeta WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador tiene tarjetas registradas.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.suspension WHERE jugador_id = @jugadorId)
        SET @errores += N'- El jugador tiene suspensiones registradas.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja al jugador:' + @nl + @errores;
        THROW 51105, @errores, 1;
    END;

    DELETE FROM torneo.jugador WHERE jugador_id = @jugadorId;
END;
GO

-- ============================================================================
-- torneo.convocatoria  (baja LOGICA: conserva el historial del plantel)
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_convocatoria_baja
    @convocatoriaId  INT,
    @fechaBaja       DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estado VARCHAR(10), @fechaConvocatoria DATE;

    SELECT @estado = estado, @fechaConvocatoria = fecha_convocatoria
    FROM torneo.convocatoria WHERE convocatoria_id = @convocatoriaId;

    IF @estado IS NULL
        SET @errores += N'- La convocatoria no existe.' + @nl;
    IF @estado = 'BAJA'
        SET @errores += N'- La convocatoria ya está dada de baja.' + @nl;

    IF @fechaBaja IS NULL
        SET @errores += N'- La fecha de baja es obligatoria.' + @nl;
    IF @fechaBaja IS NOT NULL AND @fechaConvocatoria IS NOT NULL AND @fechaBaja < @fechaConvocatoria
        SET @errores += N'- La fecha de baja no puede ser anterior a la de convocatoria.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la convocatoria:' + @nl + @errores;
        THROW 51106, @errores, 1;
    END;

    UPDATE torneo.convocatoria
    SET estado = 'BAJA', fecha_baja = @fechaBaja
    WHERE convocatoria_id = @convocatoriaId;
END;
GO

-- ============================================================================
-- torneo.reemplazo_convocatoria
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_reemplazo_convocatoria_baja
    @reemplazoId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.reemplazo_convocatoria WHERE reemplazo_id = @reemplazoId)
        SET @errores += N'- El reemplazo no existe.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el reemplazo de convocatoria:' + @nl + @errores;
        THROW 51107, @errores, 1;
    END;

    DELETE FROM torneo.reemplazo_convocatoria WHERE reemplazo_id = @reemplazoId;
END;
GO

-- ============================================================================
-- torneo.partido
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_partido_baja
    @partidoId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estado VARCHAR(12) = (SELECT estado FROM torneo.partido WHERE partido_id = @partidoId);

    IF @estado IS NULL
        SET @errores += N'- El partido no existe.' + @nl;
    IF @estado IS NOT NULL AND @estado <> 'PROGRAMADO'
        SET @errores += N'- Solo se puede dar de baja un partido en estado PROGRAMADO.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.formacion_partido WHERE partido_id = @partidoId)
        SET @errores += N'- El partido tiene formaciones cargadas.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cambio WHERE partido_id = @partidoId)
        SET @errores += N'- El partido tiene cambios cargados.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.gol WHERE partido_id = @partidoId)
        SET @errores += N'- El partido tiene goles cargados.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.tarjeta WHERE partido_id = @partidoId)
        SET @errores += N'- El partido tiene tarjetas cargadas.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE partido_id = @partidoId)
        SET @errores += N'- El partido tiene designaciones arbitrales.' + @nl;
    IF EXISTS (SELECT 1 FROM arbitraje.designacion_rechazada WHERE partido_id = @partidoId)
        SET @errores += N'- El partido tiene designaciones rechazadas registradas.' + @nl;
    IF EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE partido_id = @partidoId)
        SET @errores += N'- El partido tiene publicidad asignada.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el partido:' + @nl + @errores;
        THROW 51108, @errores, 1;
    END;

    DELETE FROM torneo.partido WHERE partido_id = @partidoId;
END;
GO

-- ============================================================================
-- torneo.formacion_partido
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_formacion_partido_baja
    @formacionId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.formacion_partido WHERE formacion_id = @formacionId)
        SET @errores += N'- La formación no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.alineacion_detalle WHERE formacion_id = @formacionId)
        SET @errores += N'- La formación tiene jugadores alineados.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la formación:' + @nl + @errores;
        THROW 51109, @errores, 1;
    END;

    DELETE FROM torneo.formacion_partido WHERE formacion_id = @formacionId;
END;
GO

-- ============================================================================
-- torneo.alineacion_detalle
-- ============================================================================1
CREATE OR ALTER PROCEDURE torneo.sp_alineacion_detalle_baja
    @alineacionId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @jugadorId INT;

    SELECT @partidoId = f.partido_id, @jugadorId = ad.jugador_id
    FROM torneo.alineacion_detalle ad
    JOIN torneo.formacion_partido f ON f.formacion_id = ad.formacion_id
    WHERE ad.alineacion_id = @alineacionId;

    IF @partidoId IS NULL
        SET @errores += N'- El registro de alineación no existe.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.cambio
               WHERE partido_id = @partidoId AND @jugadorId IN (jugador_sale_id, jugador_entra_id))
        SET @errores += N'- El jugador participa de un cambio en ese partido.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.gol
               WHERE partido_id = @partidoId AND @jugadorId IN (jugador_id, jugador_asistente_id))
        SET @errores += N'- El jugador figura en un gol de ese partido.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.tarjeta WHERE partido_id = @partidoId AND jugador_id = @jugadorId)
        SET @errores += N'- El jugador tiene tarjetas en ese partido.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo quitar al jugador de la alineación:' + @nl + @errores;
        THROW 51110, @errores, 1;
    END;

    DELETE FROM torneo.alineacion_detalle WHERE alineacion_id = @alineacionId;
END;
GO

-- ============================================================================
-- torneo.cambio
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_cambio_baja
    @cambioId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @entraId INT, @estado VARCHAR(12);

    SELECT @partidoId = c.partido_id, @entraId = c.jugador_entra_id, @estado = p.estado
    FROM torneo.cambio c
    JOIN torneo.partido p ON p.partido_id = c.partido_id
    WHERE c.cambio_id = @cambioId;

    IF @partidoId IS NULL
        SET @errores += N'- El cambio no existe.' + @nl;
    IF @estado = 'FINALIZADO'
        SET @errores += N'- El partido está finalizado; no se pueden modificar sus cambios.' + @nl;
    IF @partidoId IS NOT NULL
       AND EXISTS (SELECT 1 FROM torneo.cambio
                   WHERE partido_id = @partidoId AND jugador_sale_id = @entraId AND cambio_id <> @cambioId)
        SET @errores += N'- El jugador que ingresó en este cambio fue reemplazado luego; eliminar antes ese cambio.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el cambio:' + @nl + @errores;
        THROW 51111, @errores, 1;
    END;

    DELETE FROM torneo.cambio WHERE cambio_id = @cambioId;
END;
GO

-- ============================================================================
-- torneo.gol
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_gol_baja
    @golId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @estado VARCHAR(12) = (SELECT p.estado FROM torneo.gol g
                                   JOIN torneo.partido p ON p.partido_id = g.partido_id
                                   WHERE g.gol_id = @golId);

    IF @estado IS NULL
        SET @errores += N'- El gol no existe.' + @nl;
    IF @estado = 'FINALIZADO'
        SET @errores += N'- El partido está finalizado; no se pueden modificar sus goles.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el gol:' + @nl + @errores;
        THROW 51112, @errores, 1;
    END;

    DELETE FROM torneo.gol WHERE gol_id = @golId;
END;
GO

-- ============================================================================
-- torneo.tarjeta
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_tarjeta_baja
    @tarjetaId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @partidoId INT, @jugadorId INT, @tipo VARCHAR(8), @estado VARCHAR(12), @fechaUtc DATETIME2(0);
 
    SELECT @partidoId = t.partido_id, @jugadorId = t.jugador_id, @tipo = t.tipo,
           @estado = p.estado, @fechaUtc = p.fecha_hora_utc
    FROM torneo.tarjeta t
    JOIN torneo.partido p ON p.partido_id = t.partido_id
    WHERE t.tarjeta_id = @tarjetaId;
 
    IF @partidoId IS NULL
        SET @errores += N'- La tarjeta no existe.' + @nl;
    IF @estado = 'FINALIZADO'
        SET @errores += N'- El partido está finalizado; no se pueden modificar sus tarjetas.' + @nl;
    IF EXISTS (SELECT 1 FROM torneo.suspension WHERE tarjeta_origen_id = @tarjetaId)
        SET @errores += N'- La tarjeta originó una suspensión (eliminar antes la suspensión).' + @nl;
 
    -- Criterio conservador: una amarilla del jugador, anterior o igual (por fecha de partido) a la
    -- tarjeta que originó una suspensión por acumulación, forma parte de esa acumulación.
    IF @tipo = 'AMARILLA'
       AND EXISTS (SELECT 1
                   FROM torneo.suspension s
                   JOIN torneo.tarjeta o  ON o.tarjeta_id = s.tarjeta_origen_id
                   JOIN torneo.partido po ON po.partido_id = o.partido_id
                   WHERE s.jugador_id = @jugadorId
                     AND o.tipo = 'AMARILLA'
                     AND o.tarjeta_id <> @tarjetaId
                     AND po.fecha_hora_utc >= @fechaUtc)
        SET @errores += N'- La amarilla forma parte de la acumulación que originó una suspensión del jugador (eliminar antes la suspensión).' + @nl;
 
    -- Si en el partido hay roja por doble amarilla, deben quedar al menos dos amarillas
    IF @tipo = 'AMARILLA'
       AND EXISTS (SELECT 1 FROM torneo.tarjeta
                   WHERE partido_id = @partidoId AND jugador_id = @jugadorId
                     AND tipo = 'ROJA' AND origen_roja = 'DOBLE_AMARILLA')
       AND (SELECT COUNT(*) FROM torneo.tarjeta
            WHERE partido_id = @partidoId AND jugador_id = @jugadorId AND tipo = 'AMARILLA') <= 2
        SET @errores += N'- La amarilla sustenta una roja por doble amarilla en este partido (eliminar antes la roja).' + @nl;
 
    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la tarjeta:' + @nl + @errores;
        THROW 51113, @errores, 1;
    END;
 
    DELETE FROM torneo.tarjeta WHERE tarjeta_id = @tarjetaId;
END;
GO

-- ============================================================================
-- torneo.suspension
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_suspension_baja
    @suspensionId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM torneo.suspension WHERE suspension_id = @suspensionId)
        SET @errores += N'- La suspensión no existe.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja la suspensión:' + @nl + @errores;
        THROW 51114, @errores, 1;
    END;

    DELETE FROM torneo.suspension WHERE suspension_id = @suspensionId;
END;
GO

-- ============================================================================
-- torneo.parametro_reglamento
-- ============================================================================
CREATE OR ALTER PROCEDURE torneo.sp_parametro_reglamento_baja
    @parametroId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'', @nl NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @clave VARCHAR(50) = (SELECT clave FROM torneo.parametro_reglamento WHERE parametro_id = @parametroId);

    IF @clave IS NULL
        SET @errores += N'- El parámetro no existe.' + @nl;
    IF @clave IN ('MAX_CONVOCADOS','MIN_CONVOCADOS','MAX_CAMBIOS_REGULAR','MAX_CAMBIOS_SUPLEMENTARIO',
                  'MAX_VENTANAS','AMARILLAS_PARA_SUSPENSION', 'MAX_SUPLENTES','MAX_SELECCIONES_GRUPO')
        SET @errores += N'- El parámetro es utilizado por los procedimientos del sistema y no puede eliminarse.' + @nl;

    IF @errores <> N''
    BEGIN
        SET @errores = N'No se pudo dar de baja el parámetro de reglamento:' + @nl + @errores;
        THROW 51115, @errores, 1;
    END;

    DELETE FROM torneo.parametro_reglamento WHERE parametro_id = @parametroId;
END;
GO

