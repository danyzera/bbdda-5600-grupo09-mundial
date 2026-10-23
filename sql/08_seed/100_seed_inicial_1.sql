/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 100_seed_inicial_1.sql
   Objetivo    : Seed Data (Parte 1) - Infraestructura, Sedes y 16 Planteles Completos.
   Precondiciones: Estructura completa y SPs de alta.
   Nota: Se basa en datos del mundial 2026 en general, con algunos ficticios
        generados mediante lógica interna para evitar un script de muchísimas
        líneas y ejecuciones de SP repetitivas.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

DECLARE @DummyId INT;
DECLARE @TempJugador INT;

-------------------------------------------------------------------------------
--------------------------------1. Reglamento----------------------------------
-------------------------------------------------------------------------------

EXEC torneo.sp_parametro_reglamento_alta 'MAX_SELECCIONES_GRUPO', 4, 'Tope de fase de grupos', @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_CONVOCADOS', 26, 'Límite máximo de lista', @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_SUPLENTES', 15, 'Límite de banco', @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MIN_MINUTOS_ENTRE_PARTIDOS_SEDE', 2880, 'Descanso césped (48hs)', @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MIN_MINUTOS_DESCANSO_SELECCION', 4320, 'Descanso equipo (72hs)', @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_CAMBIOS_REGULAR', 5, 'Cambios 90 min', @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_CAMBIOS_SUPLEMENTARIO', 1, 'Cambio extra en alargue', @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_VENTANAS', 3, 'Ventanas tiempo regular', @DummyId OUTPUT;

-------------------------------------------------------------------------------
-----------------------------------2. Países-----------------------------------
-------------------------------------------------------------------------------

DECLARE @P_Arg INT, @P_Aus INT, @P_Bih INT, @P_Bra INT, @P_Col INT, @P_Ecu INT;
DECLARE @P_Hai INT, @P_Kor INT, @P_Mex INT, @P_Mar INT, @P_Par INT, @P_Por INT;
DECLARE @P_Esp INT, @P_Swe INT, @P_Uru INT, @P_Usa INT;

EXEC torneo.sp_pais_alta 'Argentina', 'América', 'ARG', 'Argentina Standard Time', 14200.00, 2025, @P_Arg OUTPUT;
EXEC torneo.sp_pais_alta 'Australia', 'Oceanía', 'AUS', 'AUS Eastern Standard Time', 64700.00, 2025, @P_Aus OUTPUT;
EXEC torneo.sp_pais_alta 'Bosnia y Herzegovina', 'Europa', 'BIH', 'Central European Standard Time', 10400.00, 2025, @P_Bih OUTPUT;
EXEC torneo.sp_pais_alta 'Brasil', 'América', 'BRA', 'E. South America Standard Time', 10700.00, 2025, @P_Bra OUTPUT;
EXEC torneo.sp_pais_alta 'Colombia', 'América', 'COL', 'SA Pacific Standard Time', 8600.00, 2025, @P_Col OUTPUT;
EXEC torneo.sp_pais_alta 'Ecuador', 'América', 'ECU', 'SA Pacific Standard Time', 7100.00, 2025, @P_Ecu OUTPUT;
EXEC torneo.sp_pais_alta 'Haití', 'América', 'HAI', 'Eastern Standard Time', 2700.00, 2025, @P_Hai OUTPUT;
EXEC torneo.sp_pais_alta 'Corea del Sur', 'Asia', 'KOR', 'Korea Standard Time', 36200.00, 2025, @P_Kor OUTPUT;
EXEC torneo.sp_pais_alta 'México', 'América', 'MEX', 'Central Standard Time (Mexico)', 13900.00, 2025, @P_Mex OUTPUT;
EXEC torneo.sp_pais_alta 'Marruecos', 'África', 'MAR', 'Morocco Standard Time', 4700.00, 2025, @P_Mar OUTPUT;
EXEC torneo.sp_pais_alta 'Paraguay', 'América', 'PAR', 'Paraguay Standard Time', 7000.00, 2025, @P_Par OUTPUT;
EXEC torneo.sp_pais_alta 'Portugal', 'Europa', 'POR', 'GMT Standard Time', 32100.00, 2025, @P_Por OUTPUT;
EXEC torneo.sp_pais_alta 'España', 'Europa', 'ESP', 'Romance Standard Time', 38600.00, 2025, @P_Esp OUTPUT;
EXEC torneo.sp_pais_alta 'Suecia', 'Europa', 'SWE', 'W. Europe Standard Time', 63100.00, 2025, @P_Swe OUTPUT;
EXEC torneo.sp_pais_alta 'Uruguay', 'América', 'URU', 'Montevideo Standard Time', 25200.00, 2025, @P_Uru OUTPUT;
EXEC torneo.sp_pais_alta 'Estados Unidos', 'América', 'USA', 'Pacific Standard Time', 90000.00, 2025, @P_Usa OUTPUT;

-------------------------------------------------------------------------------
--------3. Sedes oficiales (8 requeridas en 3 husos horarios distintos)--------
-------------------------------------------------------------------------------

DECLARE @Sede_1 INT, @Sede_2 INT, @Sede_3 INT, @Sede_4 INT;
DECLARE @Sede_5 INT, @Sede_6 INT, @Sede_7 INT, @Sede_8 INT;

EXEC torneo.sp_sede_alta @P_Usa, 'MetLife Stadium', 'New York', 82500, 'Eastern Standard Time', 40.8128, -74.0745, @Sede_1 OUTPUT;
EXEC torneo.sp_sede_alta @P_Usa, 'Hard Rock Stadium', 'Miami', 64767, 'Eastern Standard Time', 25.9580, -80.2389, @Sede_2 OUTPUT;
EXEC torneo.sp_sede_alta @P_Usa, 'Mercedes-Benz Stadium', 'Atlanta', 71000, 'Eastern Standard Time', 33.7554, -84.4006, @Sede_3 OUTPUT;
EXEC torneo.sp_sede_alta @P_Usa, 'AT&T Stadium', 'Dallas', 80000, 'Central Standard Time', 32.7473, -97.0945, @Sede_4 OUTPUT;
EXEC torneo.sp_sede_alta @P_Mex, 'Estadio Azteca', 'CDMX', 83264, 'Central Standard Time (Mexico)', 19.3029, -99.1505, @Sede_5 OUTPUT;
EXEC torneo.sp_sede_alta @P_Mex, 'Estadio Akron', 'Guadalajara', 49850, 'Central Standard Time (Mexico)', 20.6817, -103.4626, @Sede_6 OUTPUT;
EXEC torneo.sp_sede_alta @P_Usa, 'SoFi Stadium', 'Los Angeles', 70240, 'Pacific Standard Time', 33.9534, -118.3390, @Sede_7 OUTPUT;
EXEC torneo.sp_sede_alta @P_Usa, 'Levi''s Stadium', 'San Francisco', 68500, 'Pacific Standard Time', 37.4030, -121.9698, @Sede_8 OUTPUT;

-------------------------------------------------------------------------------
---------4. Selecciones y cuerpos técnicos (16 Requeridas)---------------------
-------------------------------------------------------------------------------

DECLARE @Sel_Arg INT, @Sel_Aus INT, @Sel_Bih INT, @Sel_Bra INT, @Sel_Col INT, @Sel_Ecu INT;
DECLARE @Sel_Hai INT, @Sel_Kor INT, @Sel_Mex INT, @Sel_Mar INT, @Sel_Par INT, @Sel_Por INT;
DECLARE @Sel_Esp INT, @Sel_Swe INT, @Sel_Uru INT, @Sel_Usa INT;

EXEC torneo.sp_seleccion_alta @P_Arg, 'Argentina', 'CONMEBOL', 1, 'A', @Sel_Arg OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Arg, 'Lionel Scaloni', 'DT', 'Argentina', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Aus, 'Australia', 'AFC', 24, 'A', @Sel_Aus OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Aus, 'Rudi Garcia', 'DT', 'Francia', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Bih, 'Bosnia y Herzegovina', 'UEFA', 74, 'B', @Sel_Bih OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Bih, 'Sergej Barbarez', 'DT', 'Bosnia y Herzegovina', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Bra, 'Brasil', 'CONMEBOL', 5, 'B', @Sel_Bra OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Bra, 'Pedro Bubista', 'DT', 'Cabo Verde', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Col, 'Colombia', 'CONMEBOL', 12, 'C', @Sel_Col OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Col, 'Nestor Lorenzo', 'DT', 'Argentina', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Ecu, 'Ecuador', 'CONMEBOL', 30, 'C', @Sel_Ecu OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Ecu, 'Carlos Queiroz', 'DT', 'Portugal', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Hai, 'Haití', 'CONCACAF', 90, 'D', @Sel_Hai OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Hai, 'Jamal Sellami', 'DT', 'Marruecos', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Kor, 'Corea del Sur', 'AFC', 23, 'D', @Sel_Kor OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Kor, 'Hong Myungbo', 'DT', 'Corea del Sur', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Mex, 'México', 'CONCACAF', 15, 'E', @Sel_Mex OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Mex, 'Javier Aguirre', 'DT', 'México', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Mar, 'Marruecos', 'CAF', 13, 'E', @Sel_Mar OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Mar, 'Ronald Koeman', 'DT', 'Países Bajos', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Par, 'Paraguay', 'CONMEBOL', 56, 'F', @Sel_Par OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Par, 'Gustavo Alfaro', 'DT', 'Argentina', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Por, 'Portugal', 'UEFA', 6, 'F', @Sel_Por OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Por, 'Roberto Martinez', 'DT', 'España', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Esp, 'España', 'UEFA', 3, 'G', @Sel_Esp OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Esp, 'Luis de la Fuente', 'DT', 'España', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Swe, 'Suecia', 'UEFA', 26, 'G', @Sel_Swe OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Swe, 'Jon Dahl Tomasson', 'DT', 'Dinamarca', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Uru, 'Uruguay', 'CONMEBOL', 14, 'H', @Sel_Uru OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Uru, 'Marcelo Bielsa', 'DT', 'Argentina', @DummyId OUTPUT;

EXEC torneo.sp_seleccion_alta @P_Usa, 'Estados Unidos', 'CONCACAF', 11, 'H', @Sel_Usa OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Usa, 'Mauricio Pochettino', 'DT', 'Argentina', @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- 5. JUGADORES EXTRAÍDOS EXACTAMENTE DEL PDF "SQUADLISTS" MUNDIAL 2026
-- ----------------------------------------------------------------------------

-- ARGENTINA
EXEC torneo.sp_jugador_alta 'Juan Musso', '1994-05-06', 'ARQ', 'Atlético De Madrid', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Marcos Senesi', '1997-05-10', 'DEF', 'AFC Bournemouth', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Nicolas Tagliafico', '1992-08-31', 'DEF', 'Olympique Lyonnais', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;

-- AUSTRALIA
EXEC torneo.sp_jugador_alta 'Mathew Ryan', '1992-04-08', 'ARQ', 'Levante UD', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Aus, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;

-- BOSNIA Y HERZEGOVINA
EXEC torneo.sp_jugador_alta 'Nikola Vasilj', '1995-12-02', 'ARQ', 'FC St. Pauli', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Bih, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;

-- BRASIL
EXEC torneo.sp_jugador_alta 'Alisson Becker', '1992-10-02', 'ARQ', 'Liverpool FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Kelvin Pires', '2000-06-05', 'DEF', 'SJK', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Helio Varela', '2002-05-03', 'MED', 'Maccabi Tel-Aviv FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;

-- COLOMBIA
EXEC torneo.sp_jugador_alta 'David Ospina', '1988-08-31', 'ARQ', 'Atlético Nacional', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Col, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Daniel Munoz', '1996-05-26', 'DEF', 'Crystal Palace FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Col, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jhon Lucumi', '1998-06-26', 'DEF', 'Bologna FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Col, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Santiago Arias', '1992-01-13', 'DEF', 'CA Independiente', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Col, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;

-- ECUADOR
EXEC torneo.sp_jugador_alta 'Hernan Galindez', '1987-03-30', 'ARQ', 'CA Huracán', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Ecu, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Felix Torres', '1997-01-11', 'DEF', 'SC Internacional', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Ecu, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Piero Hincapie', '2002-01-09', 'DEF', 'Arsenal FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Ecu, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Joel Ordonez', '2004-04-21', 'DEF', 'Club Brugge', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Ecu, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Marvin Senaya', '2001-01-28', 'DEF', 'AJ Auxerre', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Ecu, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;

-- HAITÍ
EXEC torneo.sp_jugador_alta 'Mohammad Aldaoud', '1992-04-12', 'MED', 'Al Wahdat SC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Hai, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Anas Badawi', '1997-09-13', 'DEF', 'Al Faisaly SC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Hai, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;

-- MÉXICO
EXEC torneo.sp_jugador_alta 'Raul Rangel', '2000-02-25', 'ARQ', 'CD Guadalajara', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Brian Gutierrez', '2003-06-17', 'MED', 'CD Guadalajara', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;

-- MARRUECOS
EXEC torneo.sp_jugador_alta 'Jorrel Hato', '2006-03-07', 'DEF', 'Chelsea FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Mar, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Quinten Timber', '2001-06-17', 'MED', 'Olympique Marseille', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Mar, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;

-- PARAGUAY
EXEC torneo.sp_jugador_alta 'Roberto Fernandez', '1988-03-29', 'ARQ', 'Cerro Porteño', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Par, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Alexandro Maidana', '2005-07-26', 'DEF', 'CA Talleres', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Par, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;

-- PORTUGAL
EXEC torneo.sp_jugador_alta 'Samu Costa', '2000-11-27', 'DEF', 'RCD Mallorca', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Por, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Nuno Mendes', '2002-06-19', 'DEF', 'Paris Saint-Germain', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Por, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Francisco Conceicao', '2002-12-14', 'DEL', 'Juventus FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Por, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;

-- ESPAÑA
EXEC torneo.sp_jugador_alta 'David Raya', '1995-09-15', 'ARQ', 'Arsenal FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Esp, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Marc Pubill', '2003-06-20', 'DEF', 'Atlético De Madrid', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Esp, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;

-- SUECIA
EXEC torneo.sp_jugador_alta 'Jacob Widell Zetterstrom', '1998-07-11', 'ARQ', 'Derby County FC', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Swe, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;

-- URUGUAY
EXEC torneo.sp_jugador_alta 'Sergio Rochet', '1993-03-23', 'ARQ', 'SC Internacional', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Uru, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jose Maria Gimenez', '1995-01-20', 'DEF', 'Atlético De Madrid', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Uru, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Sebastian Caceres', '1999-08-18', 'DEF', 'Club América', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Uru, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Juan Manuel Sanabria', '2000-03-29', 'MED', 'Real Salt Lake', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Uru, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Rodrigo Zalazar', '1999-08-12', 'MED', 'SC Braga', @TempJugador OUTPUT; EXEC torneo.sp_convocatoria_alta @Sel_Uru, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- 6. GENERACIÓN MASIVA PARA ALCANZAR LOS 23 CONVOCADOS (Sin Cursores)
-- ----------------------------------------------------------------------------
-- Se completan los lugares faltantes en las listas de 26 jugadores para 
-- cumplir con el mínimo requerido para las pruebas de formaciones.
DECLARE @Selecciones TABLE (Idx INT IDENTITY(1,1), Sel_Id INT, Sigla VARCHAR(10));
INSERT INTO @Selecciones (Sel_Id, Sigla) VALUES 
(@Sel_Arg, 'ARG'), (@Sel_Aus, 'AUS'), (@Sel_Bih, 'BIH'), (@Sel_Bra, 'BRA'),
(@Sel_Col, 'COL'), (@Sel_Ecu, 'ECU'), (@Sel_Hai, 'HAI'), (@Sel_Kor, 'KOR'),
(@Sel_Mex, 'MEX'), (@Sel_Mar, 'MAR'), (@Sel_Par, 'PAR'), (@Sel_Por, 'POR'),
(@Sel_Esp, 'ESP'), (@Sel_Swe, 'SWE'), (@Sel_Uru, 'URU'), (@Sel_Usa, 'USA');

DECLARE @IdxEquipo INT = 1;

WHILE @IdxEquipo <= 16
BEGIN
    DECLARE @SelBucle INT, @SiglaBucle VARCHAR(10);
    SELECT @SelBucle = Sel_Id, @SiglaBucle = Sigla FROM @Selecciones WHERE Idx = @IdxEquipo;
    
    DECLARE @Dorsal INT = 1;
    WHILE @Dorsal <= 26
    BEGIN
        -- Verificamos que el dorsal no esté ya ocupado por los jugadores reales que insertamos arriba
        IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE seleccion_id = @SelBucle AND dorsal = @Dorsal AND estado = 'VIGENTE')
        BEGIN
            DECLARE @NombreGen NVARCHAR(100) = 'Jugador ' + CAST(@Dorsal AS VARCHAR) + ' ' + @SiglaBucle;
            DECLARE @PosGen VARCHAR(3) = CASE WHEN @Dorsal IN (12, 23) THEN 'ARQ' WHEN @Dorsal <= 8 THEN 'DEF' WHEN @Dorsal <= 18 THEN 'MED' ELSE 'DEL' END;
            
            EXEC torneo.sp_jugador_alta @NombreGen, '1995-01-01', @PosGen, 'Liga Local', @TempJugador OUTPUT;
            EXEC torneo.sp_convocatoria_alta @SelBucle, @TempJugador, @Dorsal, '2026-05-01', @DummyId OUTPUT;
        END
        
        SET @Dorsal = @Dorsal + 1;
    END
    
    SET @IdxEquipo = @IdxEquipo + 1;
END;
GO