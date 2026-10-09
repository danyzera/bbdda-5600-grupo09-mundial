USE MundialDB;
GO

-- ============================================================================
-- Universidad Nacional de La Matanza
-- Asignatura: 3641 - Bases de Datos Aplicada
-- Grupo 09
-- Objetivo: Script Seed (Parte 1) - Países, Sedes, Árbitros y Publicidad
-- ============================================================================

SET NOCOUNT ON;
GO

-- ----------------------------------------------------------------------------
-- DECLARACIÓN DE VARIABLES DE ENLACE (Solo las necesarias para relaciones)
-- ----------------------------------------------------------------------------
DECLARE @DummyId INT; -- Para reciclar en outputs que no necesitamos recordar

-- Países (16 participantes + 1 extra para publicidad si hace falta)
DECLARE @P_Arg INT, @P_Bra INT, @P_Uru INT, @P_Col INT; 
DECLARE @P_Fra INT, @P_Ale INT, @P_Esp INT, @P_Ing INT;
DECLARE @P_Ita INT, @P_Por INT, @P_Hol INT, @P_Bel INT;
DECLARE @P_Jap INT, @P_Cor INT, @P_Eeu INT, @P_Mex INT;

-- Sedes (8 exigidas)
DECLARE @Sede1 INT, @Sede2 INT, @Sede3 INT, @Sede4 INT;
DECLARE @Sede5 INT, @Sede6 INT, @Sede7 INT, @Sede8 INT;

-- Árbitros (15 exigidos, guardamos algunos para las designaciones)
DECLARE @Arb1 INT, @Arb2 INT, @Arb3 INT, @Arb4 INT, @Arb5 INT;
DECLARE @Arb6 INT, @Arb7 INT, @Arb8 INT, @Arb9 INT, @Arb10 INT;

-- ----------------------------------------------------------------------------
-- 1. REGLAMENTO
-- ----------------------------------------------------------------------------
EXEC torneo.sp_parametro_reglamento_alta 'MAX_SELECCIONES_GRUPO', 4, NULL, @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_CONVOCADOS', 26, NULL, @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_SUPLENTES', 15, NULL, @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MIN_MINUTOS_ENTRE_PARTIDOS_SEDE', 180, NULL, @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MIN_MINUTOS_DESCANSO_SELECCION', 2880, NULL, @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_CAMBIOS_REGULAR', 5, NULL, @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_CAMBIOS_SUPLEMENTARIO', 1, NULL, @DummyId OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta 'MAX_VENTANAS', 3, NULL, @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- 2. PAÍSES (16 selecciones base)
-- ----------------------------------------------------------------------------
EXEC torneo.sp_pais_alta 'Argentina', 'América', 'ARG', 'Argentina Standard Time', 13000, 2023, @P_Arg OUTPUT;
EXEC torneo.sp_pais_alta 'Brasil', 'América', 'BRA', 'E. South America Standard Time', 9000, 2023, @P_Bra OUTPUT;
EXEC torneo.sp_pais_alta 'Uruguay', 'América', 'URU', 'Montevideo Standard Time', 17000, 2023, @P_Uru OUTPUT;
EXEC torneo.sp_pais_alta 'Colombia', 'América', 'COL', 'SA Pacific Standard Time', 6000, 2023, @P_Col OUTPUT;

EXEC torneo.sp_pais_alta 'Francia', 'Europa', 'FRA', 'Romance Standard Time', 40000, 2023, @P_Fra OUTPUT;
EXEC torneo.sp_pais_alta 'Alemania', 'Europa', 'GER', 'W. Europe Standard Time', 48000, 2023, @P_Ale OUTPUT;
EXEC torneo.sp_pais_alta 'España', 'Europa', 'ESP', 'Romance Standard Time', 30000, 2023, @P_Esp OUTPUT;
EXEC torneo.sp_pais_alta 'Inglaterra', 'Europa', 'ENG', 'GMT Standard Time', 45000, 2023, @P_Ing OUTPUT;
EXEC torneo.sp_pais_alta 'Italia', 'Europa', 'ITA', 'W. Europe Standard Time', 35000, 2023, @P_Ita OUTPUT;
EXEC torneo.sp_pais_alta 'Portugal', 'Europa', 'POR', 'GMT Standard Time', 24000, 2023, @P_Por OUTPUT;
EXEC torneo.sp_pais_alta 'Países Bajos', 'Europa', 'NED', 'W. Europe Standard Time', 53000, 2023, @P_Hol OUTPUT;
EXEC torneo.sp_pais_alta 'Bélgica', 'Europa', 'BEL', 'Romance Standard Time', 50000, 2023, @P_Bel OUTPUT;

EXEC torneo.sp_pais_alta 'Japón', 'Asia', 'JPN', 'Tokyo Standard Time', 39000, 2023, @P_Jap OUTPUT;
EXEC torneo.sp_pais_alta 'Corea del Sur', 'Asia', 'KOR', 'Korea Standard Time', 32000, 2023, @P_Cor OUTPUT;
EXEC torneo.sp_pais_alta 'Estados Unidos', 'América', 'USA', 'Eastern Standard Time', 70000, 2023, @P_Eeu OUTPUT;
EXEC torneo.sp_pais_alta 'México', 'América', 'MEX', 'Central Standard Time (Mexico)', 10000, 2023, @P_Mex OUTPUT;

-- ----------------------------------------------------------------------------
-- 3. SEDES (8 exigidas, al menos 3 husos horarios distintos)
-- ----------------------------------------------------------------------------
EXEC torneo.sp_sede_alta @P_Arg, 'Monumental', 'Buenos Aires', 84000, 'Argentina Standard Time', NULL, NULL, @Sede1 OUTPUT;
EXEC torneo.sp_sede_alta @P_Arg, 'Kempes', 'Córdoba', 57000, 'Argentina Standard Time', NULL, NULL, @Sede2 OUTPUT;
EXEC torneo.sp_sede_alta @P_Uru, 'Centenario', 'Montevideo', 60000, 'Montevideo Standard Time', NULL, NULL, @Sede3 OUTPUT;
EXEC torneo.sp_sede_alta @P_Bra, 'Maracaná', 'Río de Janeiro', 78000, 'E. South America Standard Time', NULL, NULL, @Sede4 OUTPUT;
EXEC torneo.sp_sede_alta @P_Eeu, 'MetLife', 'New York', 82000, 'Eastern Standard Time', NULL, NULL, @Sede5 OUTPUT;
EXEC torneo.sp_sede_alta @P_Eeu, 'Rose Bowl', 'Los Angeles', 90000, 'Pacific Standard Time', NULL, NULL, @Sede6 OUTPUT;
EXEC torneo.sp_sede_alta @P_Mex, 'Azteca', 'CDMX', 83000, 'Central Standard Time (Mexico)', NULL, NULL, @Sede7 OUTPUT;
EXEC torneo.sp_sede_alta @P_Fra, 'Stade de France', 'París', 80000, 'Romance Standard Time', NULL, NULL, @Sede8 OUTPUT;

-- ----------------------------------------------------------------------------
-- 4. ÁRBITROS (15 exigidos)
-- ----------------------------------------------------------------------------
EXEC arbitraje.sp_arbitro_alta 'Néstor Pitana', @P_Arg, 'FIFA', @Arb1 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Wilton Sampaio', @P_Bra, 'FIFA', @Arb2 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Clement Turpin', @P_Fra, 'FIFA', @Arb3 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Michael Oliver', @P_Ing, 'FIFA', @Arb4 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Daniele Orsato', @P_Ita, 'FIFA', @Arb5 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Mateu Lahoz', @P_Esp, 'FIFA', @Arb6 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Danny Makkelie', @P_Hol, 'FIFA', @Arb7 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Artur Dias', @P_Por, 'FIFA', @Arb8 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'César Ramos', @P_Mex, 'FIFA', @Arb9 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Ismail Elfath', @P_Eeu, 'FIFA', @Arb10 OUTPUT;
-- Los 5 restantes los guardamos en variables descartables porque solo serán cuarto árbitro o VAR
EXEC arbitraje.sp_arbitro_alta 'Andrés Cunha', @P_Uru, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Wilmar Roldán', @P_Col, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Yoshimi Yamashita', @P_Jap, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Daniel Siebert', @P_Ale, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Anthony Taylor', @P_Ing, 'FIFA', @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- 5. PUBLICIDAD (Anunciantes de al menos 6 países distintos exigido)
-- ----------------------------------------------------------------------------
DECLARE @Anun1 INT, @Camp1 INT, @Pieza1 INT;
EXEC publicidad.sp_anunciante_alta 'Coca-Cola', 'Bebidas', 'sponsor@coca.com', @P_Eeu, @Anun1 OUTPUT;
EXEC publicidad.sp_campania_alta @Anun1, 'Mundial 2026', 5000000, 'USD', '2026-01-01', '2026-12-31', @Camp1 OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp1, 'Spot 30s USA', 'Inglés', @Pieza1 OUTPUT;
EXEC publicidad.sp_pieza_pais_alta @Pieza1, @P_Eeu;

DECLARE @Anun2 INT, @Camp2 INT, @Pieza2 INT;
EXEC publicidad.sp_anunciante_alta 'Adidas', 'Indumentaria', 'sponsor@adidas.com', @P_Ale, @Anun2 OUTPUT;
EXEC publicidad.sp_campania_alta @Anun2, 'All In', 4000000, 'EUR', '2026-01-01', '2026-12-31', @Camp2 OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp2, 'Spot 15s EUR', 'Alemán', @Pieza2 OUTPUT;
EXEC publicidad.sp_pieza_pais_alta @Pieza2, @P_Ale;
EXEC publicidad.sp_pieza_pais_alta @Pieza2, @P_Fra;

DECLARE @Anun3 INT, @Camp3 INT, @Pieza3 INT;
EXEC publicidad.sp_anunciante_alta 'Sony', 'Tecnología', 'sponsor@sony.com', @P_Jap, @Anun3 OUTPUT;
EXEC publicidad.sp_campania_alta @Anun3, 'Bravia 2026', 3000000, 'USD', '2026-01-01', '2026-12-31', @Camp3 OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp3, 'Banner Lateral', 'Japonés', @Pieza3 OUTPUT;
EXEC publicidad.sp_pieza_pais_alta @Pieza3, @P_Jap;

DECLARE @Anun4 INT, @Camp4 INT, @Pieza4 INT;
EXEC publicidad.sp_anunciante_alta 'MercadoLibre', 'E-commerce', 'sponsor@meli.com', @P_Arg, @Anun4 OUTPUT;
EXEC publicidad.sp_campania_alta @Anun4, 'Envíos Rápidos', 2000000, 'USD', '2026-01-01', '2026-12-31', @Camp4 OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp4, 'Spot 10s LATAM', 'Español', @Pieza4 OUTPUT;
EXEC publicidad.sp_pieza_pais_alta @Pieza4, @P_Arg;
EXEC publicidad.sp_pieza_pais_alta @Pieza4, @P_Uru;

DECLARE @Anun5 INT, @Camp5 INT, @Pieza5 INT;
EXEC publicidad.sp_anunciante_alta 'Corona', 'Bebidas', 'sponsor@corona.com', @P_Mex, @Anun5 OUTPUT;
EXEC publicidad.sp_campania_alta @Anun5, 'This is Living', 2500000, 'USD', '2026-01-01', '2026-12-31', @Camp5 OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp5, 'Estática Gol', 'Español', @Pieza5 OUTPUT;
EXEC publicidad.sp_pieza_pais_alta @Pieza5, @P_Mex;

DECLARE @Anun6 INT, @Camp6 INT, @Pieza6 INT;
EXEC publicidad.sp_anunciante_alta 'Itaú', 'Finanzas', 'sponsor@itau.com', @P_Bra, @Anun6 OUTPUT;
EXEC publicidad.sp_campania_alta @Anun6, 'Feito Para Você', 1500000, 'USD', '2026-01-01', '2026-12-31', @Camp6 OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp6, 'Spot Final', 'Portugués', @Pieza6 OUTPUT;
EXEC publicidad.sp_pieza_pais_alta @Pieza6, @P_Bra;

-- Tarifas base requeridas por el sistema
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 1, 'USD', 10000, @DummyId OUTPUT;
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 2, 'USD', 10000, @DummyId OUTPUT;
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 3, 'USD', 10000, @DummyId OUTPUT;
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 4, 'USD', 10000, @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- DECLARACIÓN DE VARIABLES PARA SELECCIONES Y JUGADORES CLAVE
-- ----------------------------------------------------------------------------
DECLARE @Sel_Arg INT, @Sel_Bra INT, @Sel_Uru INT, @Sel_Col INT;
DECLARE @Sel_Fra INT, @Sel_Ale INT, @Sel_Esp INT, @Sel_Ing INT;
DECLARE @Sel_Ita INT, @Sel_Por INT, @Sel_Hol INT, @Sel_Bel INT;
DECLARE @Sel_Jap INT, @Sel_Cor INT, @Sel_Eeu INT, @Sel_Mex INT;

-- Variable temporal reciclable para los 368 jugadores
DECLARE @TempJugador INT;

-- Variables fijas solo para jugadores que participarán de eventos en los partidos
DECLARE @Jug_Arg_10 INT, @Jug_Arg_11 INT;
DECLARE @Jug_Fra_10 INT, @Jug_Fra_9 INT;
DECLARE @Jug_Bra_10 INT, @Jug_Ale_10 INT;

-- ----------------------------------------------------------------------------
-- 6. ALTA DE SELECCIONES (16 equipos divididos en 4 grupos)
-- ----------------------------------------------------------------------------
-- Grupo A
EXEC torneo.sp_seleccion_alta @P_Arg, 'Argentina', 'CONMEBOL', 1, 'A', @Sel_Arg OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Fra, 'Francia', 'UEFA', 2, 'A', @Sel_Fra OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Jap, 'Japón', 'AFC', 18, 'A', @Sel_Jap OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Eeu, 'Estados Unidos', 'CONCACAF', 13, 'A', @Sel_Eeu OUTPUT;

-- Grupo B
EXEC torneo.sp_seleccion_alta @P_Bra, 'Brasil', 'CONMEBOL', 5, 'B', @Sel_Bra OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Ale, 'Alemania', 'UEFA', 16, 'B', @Sel_Ale OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Cor, 'Corea del Sur', 'AFC', 23, 'B', @Sel_Cor OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Mex, 'México', 'CONCACAF', 15, 'B', @Sel_Mex OUTPUT;

-- Grupo C
EXEC torneo.sp_seleccion_alta @P_Uru, 'Uruguay', 'CONMEBOL', 11, 'C', @Sel_Uru OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Esp, 'España', 'UEFA', 8, 'C', @Sel_Esp OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Hol, 'Países Bajos', 'UEFA', 7, 'C', @Sel_Hol OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Por, 'Portugal', 'UEFA', 6, 'C', @Sel_Por OUTPUT;

-- Grupo D
EXEC torneo.sp_seleccion_alta @P_Col, 'Colombia', 'CONMEBOL', 14, 'D', @Sel_Col OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Ing, 'Inglaterra', 'UEFA', 4, 'D', @Sel_Ing OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Ita, 'Italia', 'UEFA', 9, 'D', @Sel_Ita OUTPUT;
EXEC torneo.sp_seleccion_alta @P_Bel, 'Bélgica', 'UEFA', 3, 'D', @Sel_Bel OUTPUT;

-- ----------------------------------------------------------------------------
-- 7. CUERPOS TÉCNICOS (Solo el DT para cumplir dependencia base)
-- ----------------------------------------------------------------------------
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Arg, 'Lionel Scaloni', 'DT', 'Argentina', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Fra, 'Didier Deschamps', 'DT', 'Francia', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Jap, 'Hajime Moriyasu', 'DT', 'Japón', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Eeu, 'Gregg Berhalter', 'DT', 'Estados Unidos', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Bra, 'Dorival Júnior', 'DT', 'Brasil', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Ale, 'Julian Nagelsmann', 'DT', 'Alemania', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Cor, 'Jürgen Klinsmann', 'DT', 'Alemania', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Mex, 'Jaime Lozano', 'DT', 'México', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Uru, 'Marcelo Bielsa', 'DT', 'Argentina', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Esp, 'Luis de la Fuente', 'DT', 'España', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Hol, 'Ronald Koeman', 'DT', 'Países Bajos', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Por, 'Roberto Martínez', 'DT', 'España', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Col, 'Néstor Lorenzo', 'DT', 'Argentina', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Ing, 'Gareth Southgate', 'DT', 'Inglaterra', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Ita, 'Luciano Spalletti', 'DT', 'Italia', @DummyId OUTPUT;
EXEC torneo.sp_cuerpo_tecnico_alta @Sel_Bel, 'Domenico Tedesco', 'DT', 'Italia', @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- 8. PLANTELES - GRUPO A (23 por equipo, obligatorios por consigna)
-- ----------------------------------------------------------------------------

-- ARGENTINA
EXEC torneo.sp_jugador_alta 'Emiliano Martinez', '1992-09-02', 'ARQ', 'Aston Villa', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Nahuel Molina', '1998-04-06', 'DEF', 'Atletico Madrid', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Cristian Romero', '1998-04-27', 'DEF', 'Tottenham', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Nicolas Otamendi', '1988-02-12', 'DEF', 'Benfica', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Nicolas Tagliafico', '1992-08-31', 'DEF', 'Lyon', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Rodrigo De Paul', '1994-05-24', 'MED', 'Atletico Madrid', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Enzo Fernandez', '2001-01-17', 'MED', 'Chelsea', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Alexis Mac Allister', '1998-12-24', 'MED', 'Liverpool', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Angel Di Maria', '1988-02-14', 'DEL', 'Benfica', @Jug_Arg_11 OUTPUT; -- Lo guardamos para eventos
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @Jug_Arg_11, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Lionel Messi', '1987-06-24', 'DEL', 'Inter Miami', @Jug_Arg_10 OUTPUT; -- Lo guardamos para eventos
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @Jug_Arg_10, 10, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Julian Alvarez', '2000-01-31', 'DEL', 'Man City', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 9, '2026-05-01', @DummyId OUTPUT;
-- 12 suplentes genéricos para completar 23
EXEC torneo.sp_jugador_alta 'Franco Armani', '1986-10-16', 'ARQ', 'River', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 ARG', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 ARG', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 ARG', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 ARG', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 ARG', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 ARG', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 ARG', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 ARG', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 ARG', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 ARG', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Geronimo Rulli', '1992-05-20', 'ARQ', 'Ajax', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Arg, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;

-- FRANCIA
EXEC torneo.sp_jugador_alta 'Hugo Lloris', '1986-12-26', 'ARQ', 'LAFC', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Kylian Mbappe', '1998-12-20', 'DEL', 'Real Madrid', @Jug_Fra_10 OUTPUT; -- Para eventos
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @Jug_Fra_10, 10, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Olivier Giroud', '1986-09-30', 'DEL', 'AC Milan', @Jug_Fra_9 OUTPUT; -- Para eventos
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @Jug_Fra_9, 9, '2026-05-01', @DummyId OUTPUT;
-- Relleno hasta 23
EXEC torneo.sp_jugador_alta 'Jugador 2 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 3 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 4 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 5 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 6 FRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 7 FRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 8 FRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 11 FRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 12 FRA', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 FRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 FRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 FRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 FRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 FRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 FRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 FRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 23 FRA', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Fra, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;

-- JAPÓN (23 Genéricos)
EXEC torneo.sp_jugador_alta 'Jugador 1 JAP', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 2 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 3 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 4 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 5 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 6 JAP', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 7 JAP', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 8 JAP', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 9 JAP', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 9, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 10 JAP', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 10, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 11 JAP', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 12 JAP', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 JAP', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 JAP', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 JAP', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 JAP', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 JAP', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 JAP', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 JAP', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 23 JAP', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Jap, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;

-- ESTADOS UNIDOS (23 Genéricos)
EXEC torneo.sp_jugador_alta 'Jugador 1 EEU', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 2 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 3 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 4 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 5 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 6 EEU', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 7 EEU', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 8 EEU', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 9 EEU', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 9, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 10 EEU', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 10, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 11 EEU', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 12 EEU', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 EEU', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 EEU', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 EEU', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 EEU', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 EEU', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 EEU', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 EEU', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 23 EEU', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Eeu, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;


-- ----------------------------------------------------------------------------
-- 9. PLANTELES - GRUPO B 
-- ----------------------------------------------------------------------------

-- BRASIL
EXEC torneo.sp_jugador_alta 'Alisson Becker', '1992-10-02', 'ARQ', 'Liverpool', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Vinicius Junior', '2000-07-12', 'DEL', 'Real Madrid', @Jug_Bra_10 OUTPUT; -- Para eventos
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @Jug_Bra_10, 10, '2026-05-01', @DummyId OUTPUT;
-- Relleno hasta 23
EXEC torneo.sp_jugador_alta 'Jugador 2 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 3 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 4 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 5 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 6 BRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 7 BRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 8 BRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 9 BRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 9, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 11 BRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 12 BRA', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 BRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 BRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 BRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 BRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 BRA', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 BRA', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 BRA', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 23 BRA', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Bra, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;

-- ALEMANIA
EXEC torneo.sp_jugador_alta 'Manuel Neuer', '1986-03-27', 'ARQ', 'Bayern Munich', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jamal Musiala', '2003-02-26', 'MED', 'Bayern Munich', @Jug_Ale_10 OUTPUT; -- Para eventos
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @Jug_Ale_10, 10, '2026-05-01', @DummyId OUTPUT;
-- Relleno hasta 23
EXEC torneo.sp_jugador_alta 'Jugador 2 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 3 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 4 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 5 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 6 ALE', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 7 ALE', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 8 ALE', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 9 ALE', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 9, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 11 ALE', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 12 ALE', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 ALE', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 ALE', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 ALE', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 ALE', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 ALE', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 ALE', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 ALE', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 23 ALE', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Ale, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;

-- COREA DEL SUR (23 Genéricos)
EXEC torneo.sp_jugador_alta 'Jugador 1 COR', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 2 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 3 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 4 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 5 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 6 COR', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 7 COR', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 8 COR', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 9 COR', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 9, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 10 COR', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 10, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 11 COR', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 12 COR', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 COR', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 COR', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 COR', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 COR', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 COR', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 COR', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 COR', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 23 COR', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Cor, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;

-- MÉXICO (23 Genéricos)
EXEC torneo.sp_jugador_alta 'Jugador 1 MEX', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 1, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 2 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 2, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 3 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 3, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 4 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 4, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 5 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 5, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 6 MEX', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 6, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 7 MEX', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 7, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 8 MEX', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 8, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 9 MEX', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 9, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 10 MEX', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 10, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 11 MEX', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 11, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 12 MEX', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 12, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 13 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 13, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 14 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 14, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 15 MEX', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 15, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 16 MEX', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 16, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 17 MEX', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 17, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 18 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 18, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 19 MEX', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 19, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 20 MEX', '2000-01-01', 'MED', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 20, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 21 MEX', '2000-01-01', 'DEL', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 21, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 22 MEX', '2000-01-01', 'DEF', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 22, '2026-05-01', @DummyId OUTPUT;
EXEC torneo.sp_jugador_alta 'Jugador 23 MEX', '2000-01-01', 'ARQ', 'Libre', @TempJugador OUTPUT;
EXEC torneo.sp_convocatoria_alta @Sel_Mex, @TempJugador, 23, '2026-05-01', @DummyId OUTPUT;