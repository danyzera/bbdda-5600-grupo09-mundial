/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com        Grupo:
   Integrantes : 
   Script      : 01_crear_tablas.sql
   Objetivo    : Crear todas las tablas, restricciones e indices de MundialDB.
   ============================================================================ */

USE MundialDB;
GO

-- Necesario para poder operar sobre tablas con indices filtrados.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- LIMPIEZA PREVIA (orden inverso de dependencias)
-- ============================================================================
DROP TABLE IF EXISTS importacion.importacion_error;
DROP TABLE IF EXISTS importacion.importacion_log;
DROP TABLE IF EXISTS publicidad.publicidad_partido;
DROP TABLE IF EXISTS publicidad.tipo_cambio;
DROP TABLE IF EXISTS publicidad.tarifa_publicidad;
DROP TABLE IF EXISTS publicidad.pieza_pais;
DROP TABLE IF EXISTS publicidad.pieza_publicitaria;
DROP TABLE IF EXISTS publicidad.campania;
DROP TABLE IF EXISTS publicidad.anunciante;
DROP TABLE IF EXISTS arbitraje.informe_arbitral;
DROP TABLE IF EXISTS arbitraje.designacion_rechazada;
DROP TABLE IF EXISTS arbitraje.designacion_arbitral;
DROP TABLE IF EXISTS arbitraje.arbitro_idioma;
DROP TABLE IF EXISTS arbitraje.arbitro;
DROP TABLE IF EXISTS torneo.suspension;
DROP TABLE IF EXISTS torneo.tarjeta;
DROP TABLE IF EXISTS torneo.gol;
DROP TABLE IF EXISTS torneo.cambio;
DROP TABLE IF EXISTS torneo.alineacion_detalle;
DROP TABLE IF EXISTS torneo.formacion_partido;
DROP TABLE IF EXISTS torneo.reemplazo_convocatoria;
DROP TABLE IF EXISTS torneo.partido;
DROP TABLE IF EXISTS torneo.convocatoria;
DROP TABLE IF EXISTS torneo.jugador;
DROP TABLE IF EXISTS torneo.cuerpo_tecnico;
DROP TABLE IF EXISTS torneo.seleccion;
DROP TABLE IF EXISTS torneo.sede;
DROP TABLE IF EXISTS torneo.pais;
DROP TABLE IF EXISTS torneo.parametro_reglamento;
GO

-- ============================================================================
-- ESQUEMA: torneo
-- ============================================================================

CREATE TABLE torneo.pais (
    pais_id        INT IDENTITY(1,1) NOT NULL,
    nombre         NVARCHAR(100)     NOT NULL,
    continente     NVARCHAR(50)      NOT NULL,
    codigo_iso     CHAR(3)           NOT NULL,
    huso_horario   VARCHAR(100)      NOT NULL, 
    CONSTRAINT PK_pais PRIMARY KEY (pais_id),
    CONSTRAINT UQ_pais_nombre UNIQUE (nombre),
    CONSTRAINT UQ_pais_codigo_iso UNIQUE (codigo_iso)
);
GO

CREATE TABLE torneo.sede (
    sede_id         INT IDENTITY(1,1) NOT NULL,
    pais_id         INT               NOT NULL,
    nombre_estadio  NVARCHAR(100)     NOT NULL,
    ciudad          NVARCHAR(100)     NOT NULL,
    capacidad       INT               NOT NULL,
    huso_horario    VARCHAR(100)      NOT NULL,  -- nombre Windows de huso horario
    latitud         DECIMAL(9,6)      NULL,
    longitud        DECIMAL(9,6)      NULL,
    CONSTRAINT PK_sede PRIMARY KEY (sede_id),
    CONSTRAINT FK_sede_pais FOREIGN KEY (pais_id) REFERENCES torneo.pais(pais_id),
    CONSTRAINT UQ_sede_nombre_estadio UNIQUE (nombre_estadio),
    CONSTRAINT CK_sede_capacidad CHECK (capacidad > 0),
    CONSTRAINT CK_sede_latitud CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT CK_sede_longitud CHECK (longitud BETWEEN -180 AND 180)
);
GO

CREATE TABLE torneo.seleccion (
    seleccion_id   INT IDENTITY(1,1) NOT NULL,
    pais_id        INT               NOT NULL,
    nombre         NVARCHAR(100)     NOT NULL,
    confederacion  VARCHAR(10)       NOT NULL,
    ranking_fifa   SMALLINT          NULL,
    grupo          CHAR(1)           NULL,
    CONSTRAINT PK_seleccion PRIMARY KEY (seleccion_id),
    CONSTRAINT FK_seleccion_pais FOREIGN KEY (pais_id) REFERENCES torneo.pais(pais_id),
    CONSTRAINT UQ_seleccion_pais UNIQUE (pais_id),
    CONSTRAINT UQ_seleccion_nombre UNIQUE (nombre),
    CONSTRAINT CK_seleccion_confederacion CHECK (confederacion IN ('UEFA','CONMEBOL','CONCACAF','CAF','AFC','OFC')),
    CONSTRAINT CK_seleccion_ranking_fifa CHECK (ranking_fifa > 0),
    CONSTRAINT CK_seleccion_grupo CHECK (grupo BETWEEN 'A' AND 'L')
);
GO

CREATE TABLE torneo.cuerpo_tecnico (
    cuerpo_id     INT IDENTITY(1,1) NOT NULL,
    seleccion_id  INT               NOT NULL,
    nombre        NVARCHAR(150)     NOT NULL,
    rol           CHAR(2)           NOT NULL,  -- DT director tecnico, AT ayudante, PF preparador fisico
    nacionalidad  NVARCHAR(100)     NOT NULL,
    CONSTRAINT PK_cuerpo_tecnico PRIMARY KEY (cuerpo_id),
    CONSTRAINT FK_cuerpo_tecnico_seleccion FOREIGN KEY (seleccion_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT UQ_cuerpo_tecnico_seleccion_nombre UNIQUE (seleccion_id, nombre),
    CONSTRAINT CK_cuerpo_tecnico_rol CHECK (rol IN ('DT','AT','PF'))
);
GO

-- Un solo director tecnico por seleccion
CREATE UNIQUE NONCLUSTERED INDEX IX_cuerpo_tecnico_dt_unico
ON torneo.cuerpo_tecnico(seleccion_id)
WHERE rol = 'DT';
GO

CREATE TABLE torneo.jugador (
    jugador_id        INT IDENTITY(1,1) NOT NULL,
    nombre            NVARCHAR(150)     NOT NULL,
    fecha_nacimiento  DATE              NOT NULL,
    posicion          VARCHAR(3)        NOT NULL,
    club_origen       NVARCHAR(100)     NULL,
    CONSTRAINT PK_jugador PRIMARY KEY (jugador_id),
    CONSTRAINT UQ_jugador_nombre_nacimiento UNIQUE (nombre, fecha_nacimiento),
    CONSTRAINT CK_jugador_posicion CHECK (posicion IN ('ARQ','DEF','MED','DEL'))
);
GO

CREATE TABLE torneo.convocatoria (
    convocatoria_id     INT IDENTITY(1,1) NOT NULL,
    seleccion_id        INT               NOT NULL,
    jugador_id          INT               NOT NULL,
    dorsal              TINYINT           NOT NULL,
    fecha_convocatoria  DATE              NOT NULL,
    estado              VARCHAR(10)       NOT NULL CONSTRAINT DF_convocatoria_estado DEFAULT 'VIGENTE',
    fecha_baja          DATE              NULL,
    CONSTRAINT PK_convocatoria PRIMARY KEY (convocatoria_id),
    CONSTRAINT FK_convocatoria_seleccion FOREIGN KEY (seleccion_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT FK_convocatoria_jugador FOREIGN KEY (jugador_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT CK_convocatoria_dorsal CHECK (dorsal BETWEEN 1 AND 99),
    CONSTRAINT CK_convocatoria_estado CHECK (estado IN ('VIGENTE','BAJA')),
    CONSTRAINT CK_convocatoria_baja CHECK (
        (estado = 'VIGENTE' AND fecha_baja IS NULL)
        OR (estado = 'BAJA' AND fecha_baja IS NOT NULL AND fecha_baja >= fecha_convocatoria)
    )
);
GO

-- Un jugador solo puede tener una convocatoria vigente (en una sola seleccion)
CREATE UNIQUE NONCLUSTERED INDEX IX_convocatoria_jugador_vigente
ON torneo.convocatoria(jugador_id)
WHERE estado = 'VIGENTE';
GO

-- Dorsal unico por seleccion entre convocados vigentes (permite reasignar tras una baja)
CREATE UNIQUE NONCLUSTERED INDEX IX_convocatoria_seleccion_dorsal_vigente
ON torneo.convocatoria(seleccion_id, dorsal)
WHERE estado = 'VIGENTE';
GO

CREATE TABLE torneo.partido (
    partido_id              INT IDENTITY(1,1) NOT NULL,
    fase                    VARCHAR(15)       NOT NULL,
    sede_id                 INT               NOT NULL,
    seleccion_local_id      INT               NOT NULL,
    seleccion_visitante_id  INT               NOT NULL,
    fecha_hora_local        DATETIME2(0)      NOT NULL,
    fecha_hora_utc          DATETIME2(0)      NOT NULL,
    goles_local             TINYINT           NULL,
    goles_visitante         TINYINT           NULL,
    penales_local           TINYINT           NULL,
    penales_visitante       TINYINT           NULL,
    asistencia              INT               NULL,
    estado                  VARCHAR(12)       NOT NULL CONSTRAINT DF_partido_estado DEFAULT 'PROGRAMADO',
    CONSTRAINT PK_partido PRIMARY KEY (partido_id),
    CONSTRAINT FK_partido_sede FOREIGN KEY (sede_id) REFERENCES torneo.sede(sede_id),
    CONSTRAINT FK_partido_seleccion_local FOREIGN KEY (seleccion_local_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT FK_partido_seleccion_visitante FOREIGN KEY (seleccion_visitante_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT UQ_partido_fase_selecciones UNIQUE (fase, seleccion_local_id, seleccion_visitante_id),
    CONSTRAINT UQ_partido_sede_utc UNIQUE (sede_id, fecha_hora_utc),
    CONSTRAINT CK_partido_fase CHECK (fase IN ('GRUPOS','DIECISEISAVOS','OCTAVOS','CUARTOS','SEMIFINAL','TERCER_PUESTO','FINAL')),
    CONSTRAINT CK_partido_estado CHECK (estado IN ('PROGRAMADO','EN_CURSO','FINALIZADO')),
    CONSTRAINT CK_partido_selecciones_distintas CHECK (seleccion_local_id <> seleccion_visitante_id),
    CONSTRAINT CK_partido_asistencia CHECK (asistencia >= 0),
    CONSTRAINT CK_partido_goles_par CHECK (
        (goles_local IS NULL AND goles_visitante IS NULL)
        OR (goles_local IS NOT NULL AND goles_visitante IS NOT NULL)
    ),
    CONSTRAINT CK_partido_penales_par CHECK (
        (penales_local IS NULL AND penales_visitante IS NULL)
        OR (penales_local IS NOT NULL AND penales_visitante IS NOT NULL)
    ),
    CONSTRAINT CK_partido_penales_fase CHECK (penales_local IS NULL OR fase <> 'GRUPOS'),
    CONSTRAINT CK_partido_finalizado_con_resultado CHECK (estado <> 'FINALIZADO' OR goles_local IS NOT NULL)
);
GO

CREATE TABLE torneo.reemplazo_convocatoria (
    reemplazo_id    INT IDENTITY(1,1) NOT NULL,
    seleccion_id    INT               NOT NULL,
    jugador_baja_id INT               NOT NULL,
    jugador_alta_id INT               NOT NULL,
    motivo          NVARCHAR(200)     NOT NULL,
    fecha_cambio    DATE              NOT NULL,
    CONSTRAINT PK_reemplazo_convocatoria PRIMARY KEY (reemplazo_id),
    CONSTRAINT FK_reemplazo_convocatoria_seleccion FOREIGN KEY (seleccion_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT FK_reemplazo_convocatoria_jugador_baja FOREIGN KEY (jugador_baja_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT FK_reemplazo_convocatoria_jugador_alta FOREIGN KEY (jugador_alta_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT CK_reemplazo_convocatoria_jugadores_distintos CHECK (jugador_baja_id <> jugador_alta_id)
);
GO

CREATE TABLE torneo.formacion_partido (
    formacion_id  INT IDENTITY(1,1) NOT NULL,
    partido_id    INT               NOT NULL,
    seleccion_id  INT               NOT NULL,
    esquema       VARCHAR(10)       NOT NULL,  -- ej. 4-3-3, 4-2-3-1
    CONSTRAINT PK_formacion_partido PRIMARY KEY (formacion_id),
    CONSTRAINT FK_formacion_partido_partido FOREIGN KEY (partido_id) REFERENCES torneo.partido(partido_id),
    CONSTRAINT FK_formacion_partido_seleccion FOREIGN KEY (seleccion_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT UQ_formacion_partido_partido_seleccion UNIQUE (partido_id, seleccion_id),
    CONSTRAINT CK_formacion_partido_esquema CHECK (esquema LIKE '[0-9]-%' AND esquema NOT LIKE '%[^0-9-]%')
);
GO

CREATE TABLE torneo.alineacion_detalle (
    alineacion_id   INT IDENTITY(1,1) NOT NULL,
    formacion_id    INT               NOT NULL,
    jugador_id      INT               NOT NULL,
    posicion_campo  VARCHAR(20)       NULL,
    es_titular      BIT               NOT NULL,  -- 1 titular, 0 suplente (banco)
    CONSTRAINT PK_alineacion_detalle PRIMARY KEY (alineacion_id),
    CONSTRAINT FK_alineacion_detalle_formacion FOREIGN KEY (formacion_id) REFERENCES torneo.formacion_partido(formacion_id),
    CONSTRAINT FK_alineacion_detalle_jugador FOREIGN KEY (jugador_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT UQ_alineacion_detalle_formacion_jugador UNIQUE (formacion_id, jugador_id)
);
GO

CREATE TABLE torneo.cambio (
    cambio_id         INT IDENTITY(1,1) NOT NULL,
    partido_id        INT               NOT NULL,
    seleccion_id      INT               NOT NULL,
    jugador_sale_id   INT               NOT NULL,
    jugador_entra_id  INT               NOT NULL,
    minuto            SMALLINT          NOT NULL,
    ventana           TINYINT           NOT NULL,  -- ventana de cambios (1 a 3 en tiempo regular, 4 en suplementario)
    motivo            VARCHAR(10)       NOT NULL,
    es_suplementario  BIT               NOT NULL CONSTRAINT DF_cambio_es_suplementario DEFAULT 0,
    CONSTRAINT PK_cambio PRIMARY KEY (cambio_id),
    CONSTRAINT FK_cambio_partido FOREIGN KEY (partido_id) REFERENCES torneo.partido(partido_id),
    CONSTRAINT FK_cambio_seleccion FOREIGN KEY (seleccion_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT FK_cambio_jugador_sale FOREIGN KEY (jugador_sale_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT FK_cambio_jugador_entra FOREIGN KEY (jugador_entra_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT UQ_cambio_partido_jugador_sale UNIQUE (partido_id, jugador_sale_id),
    CONSTRAINT UQ_cambio_partido_jugador_entra UNIQUE (partido_id, jugador_entra_id),
    CONSTRAINT CK_cambio_minuto CHECK (minuto BETWEEN 1 AND 130),
    CONSTRAINT CK_cambio_ventana CHECK (ventana BETWEEN 1 AND 4),
    CONSTRAINT CK_cambio_motivo CHECK (motivo IN ('TACTICO','LESION','PRECAUCION')),
    CONSTRAINT CK_cambio_jugadores_distintos CHECK (jugador_sale_id <> jugador_entra_id)
);
GO

CREATE TABLE torneo.gol (
    gol_id                INT IDENTITY(1,1) NOT NULL,
    partido_id            INT               NOT NULL,
    seleccion_id          INT               NOT NULL,  -- seleccion a la que se le computa el gol
    jugador_id            INT               NOT NULL,
    jugador_asistente_id  INT               NULL,
    minuto                SMALLINT          NOT NULL,
    tipo_gol              VARCHAR(12)       NOT NULL,
    periodo               VARCHAR(15)       NOT NULL,
    CONSTRAINT PK_gol PRIMARY KEY (gol_id),
    CONSTRAINT FK_gol_partido FOREIGN KEY (partido_id) REFERENCES torneo.partido(partido_id),
    CONSTRAINT FK_gol_seleccion FOREIGN KEY (seleccion_id) REFERENCES torneo.seleccion(seleccion_id),
    CONSTRAINT FK_gol_jugador FOREIGN KEY (jugador_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT FK_gol_jugador_asistente FOREIGN KEY (jugador_asistente_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT CK_gol_minuto CHECK (minuto BETWEEN 1 AND 130),
    CONSTRAINT CK_gol_tipo_gol CHECK (tipo_gol IN ('JUGADA','PENAL','TIRO_LIBRE','EN_CONTRA','CABEZAZO')),
    CONSTRAINT CK_gol_periodo CHECK (periodo IN ('PRIMER_TIEMPO','SEGUNDO_TIEMPO','ADICIONAL','ALARGUE','PENALES')),
    CONSTRAINT CK_gol_asistente_distinto CHECK (jugador_asistente_id IS NULL OR jugador_asistente_id <> jugador_id)
);
GO

CREATE TABLE torneo.tarjeta (
    tarjeta_id   INT IDENTITY(1,1) NOT NULL,
    partido_id   INT               NOT NULL,
    jugador_id   INT               NOT NULL,
    tipo         VARCHAR(8)        NOT NULL,
    origen_roja  VARCHAR(15)       NULL,
    minuto       SMALLINT          NOT NULL,
    motivo       NVARCHAR(200)     NULL,
    CONSTRAINT PK_tarjeta PRIMARY KEY (tarjeta_id),
    CONSTRAINT FK_tarjeta_partido FOREIGN KEY (partido_id) REFERENCES torneo.partido(partido_id),
    CONSTRAINT FK_tarjeta_jugador FOREIGN KEY (jugador_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT CK_tarjeta_tipo CHECK (tipo IN ('AMARILLA','ROJA')),
    CONSTRAINT CK_tarjeta_origen_roja CHECK (origen_roja IN ('DIRECTA','DOBLE_AMARILLA')),
    CONSTRAINT CK_tarjeta_minuto CHECK (minuto BETWEEN 1 AND 130),
    CONSTRAINT CK_tarjeta_origen_roja_valido CHECK (
        (tipo = 'ROJA' AND origen_roja IS NOT NULL)
        OR (tipo = 'AMARILLA' AND origen_roja IS NULL)
    )
);
GO

CREATE TABLE torneo.suspension (
    suspension_id         INT IDENTITY(1,1) NOT NULL,
    jugador_id            INT               NOT NULL,
    tarjeta_origen_id     INT               NULL,
    motivo                NVARCHAR(200)     NOT NULL,
    fecha_inicio          DATE              NOT NULL,
    partidos_suspendidos  TINYINT           NOT NULL,
    partidos_cumplidos    TINYINT           NOT NULL CONSTRAINT DF_suspension_partidos_cumplidos DEFAULT 0,
    CONSTRAINT PK_suspension PRIMARY KEY (suspension_id),
    CONSTRAINT FK_suspension_jugador FOREIGN KEY (jugador_id) REFERENCES torneo.jugador(jugador_id),
    CONSTRAINT FK_suspension_tarjeta_origen FOREIGN KEY (tarjeta_origen_id) REFERENCES torneo.tarjeta(tarjeta_id),
    CONSTRAINT CK_suspension_partidos_suspendidos CHECK (partidos_suspendidos > 0),
    CONSTRAINT CK_suspension_partidos_cumplidos CHECK (partidos_cumplidos <= partidos_suspendidos)
);
GO

CREATE TABLE torneo.parametro_reglamento (
    parametro_id  INT IDENTITY(1,1) NOT NULL,
    clave         VARCHAR(50)       NOT NULL,
    valor         INT               NOT NULL,
    descripcion   NVARCHAR(200)     NULL,
    CONSTRAINT PK_parametro_reglamento PRIMARY KEY (parametro_id),
    CONSTRAINT UQ_parametro_reglamento_clave UNIQUE (clave)
);
GO

-- ============================================================================
-- ESQUEMA: arbitraje
-- ============================================================================

CREATE TABLE arbitraje.arbitro (
    arbitro_id  INT IDENTITY(1,1) NOT NULL,
    nombre      NVARCHAR(150)     NOT NULL,
    pais_id     INT               NOT NULL,
    categoria   VARCHAR(15)       NOT NULL,
    CONSTRAINT PK_arbitro PRIMARY KEY (arbitro_id),
    CONSTRAINT FK_arbitro_pais FOREIGN KEY (pais_id) REFERENCES torneo.pais(pais_id),
    CONSTRAINT UQ_arbitro_nombre_pais UNIQUE (nombre, pais_id),
    CONSTRAINT CK_arbitro_categoria CHECK (categoria IN ('FIFA','CONFEDERACION'))
);
GO

CREATE TABLE arbitraje.arbitro_idioma (
    arbitro_id  INT          NOT NULL,
    idioma      NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_arbitro_idioma PRIMARY KEY (arbitro_id, idioma),
    CONSTRAINT FK_arbitro_idioma_arbitro FOREIGN KEY (arbitro_id) REFERENCES arbitraje.arbitro(arbitro_id)
);
GO

CREATE TABLE arbitraje.designacion_arbitral (
    designacion_id  INT IDENTITY(1,1) NOT NULL,
    partido_id      INT               NOT NULL,
    arbitro_id      INT               NOT NULL,
    rol_arbitral    VARCHAR(10)       NOT NULL,
    CONSTRAINT PK_designacion_arbitral PRIMARY KEY (designacion_id),
    CONSTRAINT FK_designacion_arbitral_partido FOREIGN KEY (partido_id) REFERENCES torneo.partido(partido_id),
    CONSTRAINT FK_designacion_arbitral_arbitro FOREIGN KEY (arbitro_id) REFERENCES arbitraje.arbitro(arbitro_id),
    CONSTRAINT UQ_designacion_arbitral_partido_arbitro UNIQUE (partido_id, arbitro_id),
    CONSTRAINT CK_designacion_arbitral_rol CHECK (rol_arbitral IN ('PRINCIPAL','ASISTENTE','CUARTO','VAR'))
);
GO

-- Un solo arbitro por rol que no sea ASISTENTE en cada partido
CREATE UNIQUE NONCLUSTERED INDEX IX_designacion_arbitral_partido_rol_unico
ON arbitraje.designacion_arbitral(partido_id, rol_arbitral)
WHERE rol_arbitral <> 'ASISTENTE';
GO

-- Registro de designaciones descartadas (por ejemplo, conflicto de nacionalidad)
CREATE TABLE arbitraje.designacion_rechazada (
    rechazo_id    INT IDENTITY(1,1) NOT NULL,
    partido_id    INT               NOT NULL,
    arbitro_id    INT               NOT NULL,
    rol_arbitral  VARCHAR(10)       NOT NULL,
    motivo        NVARCHAR(200)     NOT NULL,
    fecha_hora    DATETIME2(0)      NOT NULL CONSTRAINT DF_designacion_rechazada_fecha_hora DEFAULT SYSDATETIME(),
    CONSTRAINT PK_designacion_rechazada PRIMARY KEY (rechazo_id),
    CONSTRAINT FK_designacion_rechazada_partido FOREIGN KEY (partido_id) REFERENCES torneo.partido(partido_id),
    CONSTRAINT FK_designacion_rechazada_arbitro FOREIGN KEY (arbitro_id) REFERENCES arbitraje.arbitro(arbitro_id),
    CONSTRAINT CK_designacion_rechazada_rol CHECK (rol_arbitral IN ('PRINCIPAL','ASISTENTE','CUARTO','VAR'))
);
GO

CREATE TABLE arbitraje.informe_arbitral (
    informe_id      INT IDENTITY(1,1) NOT NULL,
    designacion_id  INT               NOT NULL,
    fecha           DATE              NOT NULL,
    tipo            VARCHAR(10)       NOT NULL,
    detalle         NVARCHAR(500)     NOT NULL,
    CONSTRAINT PK_informe_arbitral PRIMARY KEY (informe_id),
    CONSTRAINT FK_informe_arbitral_designacion FOREIGN KEY (designacion_id) REFERENCES arbitraje.designacion_arbitral(designacion_id),
    CONSTRAINT CK_informe_arbitral_tipo CHECK (tipo IN ('INFORME','SANCION'))
);
GO

-- ============================================================================
-- ESQUEMA: publicidad
-- ============================================================================

CREATE TABLE publicidad.anunciante (
    anunciante_id  INT IDENTITY(1,1) NOT NULL,
    nombre         NVARCHAR(100)     NOT NULL,
    rubro          NVARCHAR(100)     NULL,
    email          VARCHAR(150)      NULL,
    pais_id        INT               NOT NULL,
    CONSTRAINT PK_anunciante PRIMARY KEY (anunciante_id),
    CONSTRAINT FK_anunciante_pais FOREIGN KEY (pais_id) REFERENCES torneo.pais(pais_id),
    CONSTRAINT UQ_anunciante_nombre_pais UNIQUE (nombre, pais_id)
);
GO

-- E-mail unico cuando esta informado
CREATE UNIQUE NONCLUSTERED INDEX IX_anunciante_email_unico
ON publicidad.anunciante(email)
WHERE email IS NOT NULL;
GO

CREATE TABLE publicidad.campania (
    campania_id    INT IDENTITY(1,1) NOT NULL,
    anunciante_id  INT               NOT NULL,
    nombre         NVARCHAR(100)     NOT NULL,
    presupuesto    DECIMAL(14,2)     NOT NULL,
    moneda         CHAR(3)           NOT NULL CONSTRAINT DF_campania_moneda DEFAULT 'USD',
    fecha_inicio   DATE              NOT NULL,
    fecha_fin      DATE              NOT NULL,
    CONSTRAINT PK_campania PRIMARY KEY (campania_id),
    CONSTRAINT FK_campania_anunciante FOREIGN KEY (anunciante_id) REFERENCES publicidad.anunciante(anunciante_id),
    CONSTRAINT UQ_campania_anunciante_nombre UNIQUE (anunciante_id, nombre),
    CONSTRAINT CK_campania_presupuesto CHECK (presupuesto >= 0),
    CONSTRAINT CK_campania_fechas CHECK (fecha_fin >= fecha_inicio)
);
GO

CREATE TABLE publicidad.pieza_publicitaria (
    pieza_id     INT IDENTITY(1,1) NOT NULL,
    campania_id  INT               NOT NULL,
    nombre       NVARCHAR(100)     NOT NULL,
    idioma       NVARCHAR(50)      NOT NULL,
    CONSTRAINT PK_pieza_publicitaria PRIMARY KEY (pieza_id),
    CONSTRAINT FK_pieza_publicitaria_campania FOREIGN KEY (campania_id) REFERENCES publicidad.campania(campania_id),
    CONSTRAINT UQ_pieza_publicitaria_campania_nombre UNIQUE (campania_id, nombre)
);
GO

-- Paises (mercados) a los que se dirige cada pieza
CREATE TABLE publicidad.pieza_pais (
    pieza_id  INT NOT NULL,
    pais_id   INT NOT NULL,
    CONSTRAINT PK_pieza_pais PRIMARY KEY (pieza_id, pais_id),
    CONSTRAINT FK_pieza_pais_pieza FOREIGN KEY (pieza_id) REFERENCES publicidad.pieza_publicitaria(pieza_id),
    CONSTRAINT FK_pieza_pais_pais FOREIGN KEY (pais_id) REFERENCES torneo.pais(pais_id)
);
GO

CREATE TABLE publicidad.tarifa_publicidad (
    tarifa_id  INT IDENTITY(1,1) NOT NULL,
    fase       VARCHAR(15)       NOT NULL,
    espacio    TINYINT           NOT NULL,
    moneda     CHAR(3)           NOT NULL,
    importe    DECIMAL(12,2)     NOT NULL,
    CONSTRAINT PK_tarifa_publicidad PRIMARY KEY (tarifa_id),
    CONSTRAINT UQ_tarifa_publicidad_fase_espacio UNIQUE (fase, espacio),
    CONSTRAINT UQ_tarifa_publicidad_id_espacio UNIQUE (tarifa_id, espacio),  -- habilita la FK compuesta de publicidad_partido
    CONSTRAINT CK_tarifa_publicidad_fase CHECK (fase IN ('GRUPOS','DIECISEISAVOS','OCTAVOS','CUARTOS','SEMIFINAL','TERCER_PUESTO','FINAL')),
    CONSTRAINT CK_tarifa_publicidad_espacio CHECK (espacio BETWEEN 1 AND 4),
    CONSTRAINT CK_tarifa_publicidad_importe CHECK (importe >= 0)
);
GO

-- Tipos de cambio (API de tipo de cambio) para convertir la pauta entre monedas
CREATE TABLE publicidad.tipo_cambio (
    tipo_cambio_id  INT IDENTITY(1,1) NOT NULL,
    moneda_origen   CHAR(3)           NOT NULL,
    moneda_destino  CHAR(3)           NOT NULL,
    fecha           DATE              NOT NULL,
    tasa            DECIMAL(18,8)     NOT NULL,
    CONSTRAINT PK_tipo_cambio PRIMARY KEY (tipo_cambio_id),
    CONSTRAINT UQ_tipo_cambio_monedas_fecha UNIQUE (moneda_origen, moneda_destino, fecha),
    CONSTRAINT CK_tipo_cambio_tasa CHECK (tasa > 0),
    CONSTRAINT CK_tipo_cambio_monedas_distintas CHECK (moneda_origen <> moneda_destino)
);
GO

CREATE TABLE publicidad.publicidad_partido (
    publicidad_id      INT IDENTITY(1,1) NOT NULL,
    partido_id         INT               NOT NULL,
    pieza_id           INT               NOT NULL,
    tarifa_id          INT               NOT NULL,
    momento_emision    DATETIME2(0)      NOT NULL,
    espacio            TINYINT           NOT NULL,
    importe_facturado  DECIMAL(12,2)     NOT NULL,  -- importe historico al momento de facturar
    moneda             CHAR(3)           NOT NULL,
    CONSTRAINT PK_publicidad_partido PRIMARY KEY (publicidad_id),
    CONSTRAINT FK_publicidad_partido_partido FOREIGN KEY (partido_id) REFERENCES torneo.partido(partido_id),
    CONSTRAINT FK_publicidad_partido_pieza FOREIGN KEY (pieza_id) REFERENCES publicidad.pieza_publicitaria(pieza_id),
    -- FK compuesta: el espacio guardado debe coincidir con el espacio de la tarifa
    CONSTRAINT FK_publicidad_partido_tarifa FOREIGN KEY (tarifa_id, espacio) REFERENCES publicidad.tarifa_publicidad(tarifa_id, espacio),
    CONSTRAINT UQ_publicidad_partido_partido_espacio UNIQUE (partido_id, espacio),
    CONSTRAINT UQ_publicidad_partido_partido_pieza UNIQUE (partido_id, pieza_id),
    CONSTRAINT CK_publicidad_partido_espacio CHECK (espacio BETWEEN 1 AND 4),
    CONSTRAINT CK_publicidad_partido_importe CHECK (importe_facturado >= 0)
);
GO

-- ============================================================================
-- ESQUEMA: importacion
-- ============================================================================

CREATE TABLE importacion.importacion_log (
    importacion_id    INT IDENTITY(1,1) NOT NULL,
    origen            NVARCHAR(200)     NOT NULL,
    tipo_fuente       VARCHAR(10)       NOT NULL,
    archivo           NVARCHAR(260)     NULL,
    fecha_inicio      DATETIME2(0)      NOT NULL CONSTRAINT DF_importacion_log_fecha_inicio DEFAULT SYSDATETIME(),
    fecha_fin         DATETIME2(0)      NULL,
    estado            VARCHAR(10)       NOT NULL CONSTRAINT DF_importacion_log_estado DEFAULT 'EN_CURSO',
    registros_leidos  INT               NOT NULL CONSTRAINT DF_importacion_log_registros_leidos DEFAULT 0,
    registros_ok      INT               NOT NULL CONSTRAINT DF_importacion_log_registros_ok DEFAULT 0,
    registros_error   INT               NOT NULL CONSTRAINT DF_importacion_log_registros_error DEFAULT 0,
    CONSTRAINT PK_importacion_log PRIMARY KEY (importacion_id),
    CONSTRAINT CK_importacion_log_tipo_fuente CHECK (tipo_fuente IN ('CSV','XML','EXCEL','API','SCRAPING')),
    CONSTRAINT CK_importacion_log_estado CHECK (estado IN ('EN_CURSO','OK','PARCIAL','ERROR')),
    CONSTRAINT CK_importacion_log_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT CK_importacion_log_registros CHECK (
        registros_leidos >= 0 AND registros_ok >= 0 AND registros_error >= 0
        AND registros_ok + registros_error <= registros_leidos
    )
);
GO

CREATE TABLE importacion.importacion_error (
    error_id        INT IDENTITY(1,1) NOT NULL,
    importacion_id  INT               NOT NULL,
    fila            INT               NULL,
    detalle         NVARCHAR(500)     NOT NULL,
    CONSTRAINT PK_importacion_error PRIMARY KEY (error_id),
    CONSTRAINT FK_importacion_error_log FOREIGN KEY (importacion_id) REFERENCES importacion.importacion_log(importacion_id)
);
GO