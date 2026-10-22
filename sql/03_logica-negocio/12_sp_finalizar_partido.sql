-- actualizar contabilización de partidos para suspensiones

/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 11_sp_iniciar_partido.sql
   Objetivo    : Procedimiento almacenado para dar comienzo a un partido.
                Con precondiciones, pasa un partido de estar PROGRAMADO
                A estar EN CURSO. Es condición necesaria que el partido esté
                EN CURSO para dar lugar a otros procedimientos de negocio
                como registrar un gol. El procedimiento, al integrar varias
                operaciones que representan una unidad lógica (dar comienzo
                al partido), hace uso del TCL disponible en SQL Server.
                La lógica de negocio sobre partido implica una operación ABM,
                concretamente modificar el estado, es por esto que se utiliza
                alguno de los SPs previamente generados para ABM sobre las tablas.
                Es requisito explícito que ningún 
   ============================================================================ */