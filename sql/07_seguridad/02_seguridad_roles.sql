/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 02_seguridad_roles.sql
   Objetivo    : Crear roles de seguridad y asignar permisos granulares.
   Requisito   : Los SP de torneo y publicidad (scripts 04 a 12) ya deben existir.
   ============================================================================ */

USE MundialDB;
GO

/* ==========================================================
   1) CREACION DE ROLES
   ========================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'administrador')
    CREATE ROLE administrador;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'cargador_resultados')
    CREATE ROLE cargador_resultados;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'gestor_publicidad')
    CREATE ROLE gestor_publicidad;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'consulta')
    CREATE ROLE consulta;
GO

/* ==========================================================
   2) PERMISOS

   Criterio: minimo privilegio. Se otorga solo lo necesario y se usa DENY
   unicamente donde un GRANT mas amplio dejaria una puerta abierta.
   Los SP ejecutan con los permisos de su dueno (encadenamiento de
   propiedad), por eso un rol puede ejecutar un SP que escribe en tablas
   sobre las que no tiene permiso directo.
   ========================================================== */

-- ADMINISTRADOR: control total sobre la base (incluye claves y certificados)
GRANT CONTROL ON DATABASE::MundialDB
TO administrador;
GO

-- CONSULTA: lectura de torneo y ejecucion de reportes.
-- Las columnas cifradas se ven como VARBINARY (no tiene acceso a la clave).
GRANT SELECT ON SCHEMA::torneo
TO consulta;
GO

GRANT EXECUTE ON SCHEMA::reportes
TO consulta;
GO

-- CARGADOR DE RESULTADOS: solo ejecuta los SP de carga de resultados.
-- No tiene acceso directo a las tablas ni a otros esquemas.
GRANT EXECUTE ON OBJECT::torneo.sp_partido_modificacion     TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_gol_alta                 TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_gol_modificacion         TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_tarjeta_alta             TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_tarjeta_modificacion     TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_cambio_alta              TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_cambio_modificacion      TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_suspension_alta          TO cargador_resultados;
GRANT EXECUTE ON OBJECT::torneo.sp_suspension_modificacion  TO cargador_resultados;
GO

-- GESTOR DE PUBLICIDAD: lee el esquema publicidad y escribe solo por SP
-- (alta y modificacion). Las bajas quedan prohibidas de forma explicita.
GRANT SELECT, EXECUTE ON SCHEMA::publicidad
TO gestor_publicidad;
GO

DENY EXECUTE ON OBJECT::publicidad.sp_anunciante_baja           TO gestor_publicidad;
DENY EXECUTE ON OBJECT::publicidad.sp_campania_baja             TO gestor_publicidad;
DENY EXECUTE ON OBJECT::publicidad.sp_pieza_publicitaria_baja   TO gestor_publicidad;
DENY EXECUTE ON OBJECT::publicidad.sp_pieza_pais_baja           TO gestor_publicidad;
DENY EXECUTE ON OBJECT::publicidad.sp_tarifa_publicidad_baja    TO gestor_publicidad;
DENY EXECUTE ON OBJECT::publicidad.sp_tipo_cambio_baja          TO gestor_publicidad;
DENY EXECUTE ON OBJECT::publicidad.sp_publicidad_partido_baja   TO gestor_publicidad;
GO