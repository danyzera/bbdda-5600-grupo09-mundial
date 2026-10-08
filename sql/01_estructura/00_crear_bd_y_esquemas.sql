/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com       Grupo:
   Integrantes : 
   Script      : 00_crear_bd_y_esquemas.sql
   Objetivo    : Crear la base de datos MundialDB y sus esquemas
                 (torneo, arbitraje, publicidad, importacion).
   ============================================================================ */

USE master;
GO

DROP DATABASE IF EXISTS MundialDB;
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