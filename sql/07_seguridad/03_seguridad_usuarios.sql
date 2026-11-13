/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 03_seguridad_usuarios.sql
   Objetivo    : Crear usuarios de prueba y asignarlos a roles.
   Requisito   : Ejecutar antes 02_seguridad_roles.sql (los roles deben existir).
   ============================================================================ */

USE MundialDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_admin')
    CREATE USER usr_admin WITHOUT LOGIN;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_resultados')
    CREATE USER usr_resultados WITHOUT LOGIN;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_publicidad')
    CREATE USER usr_publicidad WITHOUT LOGIN;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_consulta')
    CREATE USER usr_consulta WITHOUT LOGIN;
GO

ALTER ROLE administrador
ADD MEMBER usr_admin;
GO

ALTER ROLE cargador_resultados
ADD MEMBER usr_resultados;
GO

ALTER ROLE gestor_publicidad
ADD MEMBER usr_publicidad;
GO

ALTER ROLE consulta
ADD MEMBER usr_consulta;
GO