/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 00_crear_bd_y_esquemas.sql
   Objetivo    : Crear la base de datos MundialDB y sus esquemas
                 (torneo, arbitraje, publicidad, importacion).
   ============================================================================ */

USE master;
GO

IF DB_ID('MundialDB') IS NOT NULL
BEGIN
    ALTER DATABASE MundialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MundialDB;
END
GO

CREATE DATABASE MundialDB;
GO

USE MundialDB;
GO

CREATE SCHEMA torneo;
GO
CREATE SCHEMA arbitraje;
GO
CREATE SCHEMA publicidad;
GO
CREATE SCHEMA importacion;
GO