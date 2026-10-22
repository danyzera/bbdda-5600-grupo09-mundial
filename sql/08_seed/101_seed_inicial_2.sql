/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 17/10/2026
   Script      : 101_seed_inicial_2.sql
   Objetivo    : Seed Data (Parte 2) - Partidos, Árbitros, Casos de Prueba y Publicidad.
   ============================================================================ */

USE MundialDB;
GO

SET NOCOUNT ON;
GO

DECLARE @DummyId INT;

-- ----------------------------------------------------------------------------
-- 1. RECUPERACIÓN DE ENTIDADES BASE (Insertadas en Parte 1)
-- ----------------------------------------------------------------------------
DECLARE @P_Arg INT, @P_Usa INT, @P_Mex INT, @P_Can INT, @P_Fra INT, @P_Bra INT;
DECLARE @P_Eng INT, @P_Esp INT, @P_Por INT, @P_Ned INT, @P_Uru INT, @P_Col INT;

SELECT @P_Arg = pais_id FROM torneo.pais WHERE codigo_iso = 'ARG';
SELECT @P_Usa = pais_id FROM torneo.pais WHERE codigo_iso = 'USA';
SELECT @P_Mex = pais_id FROM torneo.pais WHERE codigo_iso = 'MEX';
SELECT @P_Can = pais_id FROM torneo.pais WHERE codigo_iso = 'CAN';
SELECT @P_Fra = pais_id FROM torneo.pais WHERE codigo_iso = 'FRA';
SELECT @P_Bra = pais_id FROM torneo.pais WHERE codigo_iso = 'BRA';
SELECT @P_Eng = pais_id FROM torneo.pais WHERE codigo_iso = 'ENG';
SELECT @P_Esp = pais_id FROM torneo.pais WHERE codigo_iso = 'ESP';

DECLARE @Sel_Arg INT, @Sel_Usa INT, @Sel_Mex INT, @Sel_Can INT, @Sel_Fra INT;
DECLARE @Sel_Bra INT, @Sel_Eng INT, @Sel_Esp INT, @Sel_Por INT, @Sel_Ned INT;
SELECT @Sel_Arg = seleccion_id FROM torneo.seleccion WHERE nombre = 'Argentina';
SELECT @Sel_Usa = seleccion_id FROM torneo.seleccion WHERE nombre = 'Estados Unidos';
SELECT @Sel_Mex = seleccion_id FROM torneo.seleccion WHERE nombre = 'México';
SELECT @Sel_Can = seleccion_id FROM torneo.seleccion WHERE nombre = 'Canadá';
SELECT @Sel_Fra = seleccion_id FROM torneo.seleccion WHERE nombre = 'Francia';
SELECT @Sel_Bra = seleccion_id FROM torneo.seleccion WHERE nombre = 'Brasil';
SELECT @Sel_Eng = seleccion_id FROM torneo.seleccion WHERE nombre = 'Inglaterra';
SELECT @Sel_Esp = seleccion_id FROM torneo.seleccion WHERE nombre = 'España';
SELECT @Sel_Por = seleccion_id FROM torneo.seleccion WHERE nombre = 'Portugal';
SELECT @Sel_Ned = seleccion_id FROM torneo.seleccion WHERE nombre = 'Países Bajos';

DECLARE @Sede1 INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = 'MetLife Stadium');
DECLARE @Sede2 INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = 'Estadio Azteca');
DECLARE @Sede3 INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = 'SoFi Stadium');
DECLARE @Sede4 INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = 'Hard Rock Stadium');

-- ----------------------------------------------------------------------------
-- 2. ÁRBITROS (15 Oficiales)
-- ----------------------------------------------------------------------------
DECLARE @Arb1 INT, @Arb_Eng INT;
EXEC arbitraje.sp_arbitro_alta 'Szymon Marciniak', @P_Fra, 'FIFA', @Arb1 OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Michael Oliver', @P_Eng, 'FIFA', @Arb_Eng OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Cesar Ramos', @P_Mex, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Facundo Tello', @P_Arg, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Wilton Sampaio', @P_Bra, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Ismail Elfath', @P_Usa, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Anthony Taylor', @P_Eng, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Jesus Gil Manzano', @P_Esp, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Danny Makkelie', @P_Ned, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Artur Soares Dias', @P_Por, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Andres Matonte', @P_Uru, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Wilmar Roldan', @P_Col, 'FIFA', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Drew Fischer', @P_Can, 'CONFEDERACION', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Fernando Rapallini', @P_Arg, 'CONFEDERACION', @DummyId OUTPUT;
EXEC arbitraje.sp_arbitro_alta 'Mateu Lahoz', @P_Esp, 'FIFA', @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- 3. FIXTURE DE 24 PARTIDOS 
-- ----------------------------------------------------------------------------
-- Variable de tabla con IDENTITY para poder iterar luego sin cursores
DECLARE @PartidosList TABLE (
    Idx INT IDENTITY(1,1), 
    partido_id INT, 
    local_id INT, 
    visitante_id INT
);

-- Partido 1 (Para caso de lesión temprana)
DECLARE @Ptd_1 INT;
EXEC torneo.sp_partido_alta 'GRUPOS', @Sede1, @Sel_Arg, @Sel_Usa, '2026-06-11 15:00:00', @Ptd_1 OUTPUT;
INSERT INTO @PartidosList (partido_id, local_id, visitante_id) VALUES (@Ptd_1, @Sel_Arg, @Sel_Usa);

-- Partido 2 (Para caso de Roja Directa)
DECLARE @Ptd_2 INT;
EXEC torneo.sp_partido_alta 'GRUPOS', @Sede2, @Sel_Mex, @Sel_Can, '2026-06-12 18:00:00', @Ptd_2 OUTPUT;
INSERT INTO @PartidosList (partido_id, local_id, visitante_id) VALUES (@Ptd_2, @Sel_Mex, @Sel_Can);

-- Partido 3 (Para caso de Doble Amarilla)
DECLARE @Ptd_3 INT;
EXEC torneo.sp_partido_alta 'GRUPOS', @Sede3, @Sel_Fra, @Sel_Bra, '2026-06-13 20:00:00', @Ptd_3 OUTPUT;
INSERT INTO @PartidosList (partido_id, local_id, visitante_id) VALUES (@Ptd_3, @Sel_Fra, @Sel_Bra);

-- Partido 4 (Para conflicto de nacionalidad del árbitro)
DECLARE @Ptd_4 INT;
EXEC torneo.sp_partido_alta 'GRUPOS', @Sede4, @Sel_Eng, @Sel_Esp, '2026-06-14 16:00:00', @Ptd_4 OUTPUT;
INSERT INTO @PartidosList (partido_id, local_id, visitante_id) VALUES (@Ptd_4, @Sel_Eng, @Sel_Esp);

-- Bucle de generación de los 20 partidos restantes (sin cursor)
DECLARE @p INT = 5;
DECLARE @FechaBase DATETIME2(0) = '2026-06-15 12:00:00';
WHILE @p <= 24
BEGIN
    DECLARE @Ptd_Gen INT;
    DECLARE @FaseGen VARCHAR(15) = CASE WHEN @p <= 16 THEN 'GRUPOS' WHEN @p <= 20 THEN 'OCTAVOS' ELSE 'CUARTOS' END;
    
    EXEC torneo.sp_partido_alta @FaseGen, @Sede1, @Sel_Por, @Sel_Ned, @FechaBase, @Ptd_Gen OUTPUT;
    INSERT INTO @PartidosList (partido_id, local_id, visitante_id) VALUES (@Ptd_Gen, @Sel_Por, @Sel_Ned);
    
    SET @FechaBase = DATEADD(HOUR, 24, @FechaBase);
    SET @p = @p + 1;
END;

-- ----------------------------------------------------------------------------
-- 4. FORMACIONES Y ALINEACIONES (Iteración con lógica WHILE, sin cursores)
-- ----------------------------------------------------------------------------
DECLARE @TotalPartidos INT = (SELECT MAX(Idx) FROM @PartidosList);
DECLARE @IdxPartido INT = 1;

WHILE @IdxPartido <= @TotalPartidos
BEGIN
    DECLARE @CurPartidoId INT, @CurLocalId INT, @CurVisitanteId INT;
    SELECT @CurPartidoId = partido_id, @CurLocalId = local_id, @CurVisitanteId = visitante_id
    FROM @PartidosList WHERE Idx = @IdxPartido;
    
    -- Crear formaciones
    DECLARE @FormLocal INT, @FormVisitante INT;
    EXEC torneo.sp_formacion_partido_alta @CurPartidoId, @CurLocalId, '4-3-3', @FormLocal OUTPUT;
    EXEC torneo.sp_formacion_partido_alta @CurPartidoId, @CurVisitanteId, '4-4-2', @FormVisitante OUTPUT;
    
    -- Manejo del plantel Local (13 jugadores: 11 titulares, 2 suplentes)
    DECLARE @JugadoresLocal TABLE (Idx INT IDENTITY(1,1), jugador_id INT);
    DELETE FROM @JugadoresLocal;
    INSERT INTO @JugadoresLocal (jugador_id)
    SELECT TOP 13 jugador_id FROM torneo.convocatoria WHERE seleccion_id = @CurLocalId ORDER BY dorsal;
    
    DECLARE @IdxJL INT = 1;
    DECLARE @MaxJL INT = (SELECT MAX(Idx) FROM @JugadoresLocal);
    
    WHILE @IdxJL <= @MaxJL
    BEGIN
        DECLARE @JugLocalId INT = (SELECT jugador_id FROM @JugadoresLocal WHERE Idx = @IdxJL);
        DECLARE @EsTitularL BIT = CASE WHEN @IdxJL <= 11 THEN 1 ELSE 0 END;
        DECLARE @PosicionL VARCHAR(10) = CASE WHEN @IdxJL <= 11 THEN 'CAMPO' ELSE 'BANCO' END;
        
        EXEC torneo.sp_alineacion_detalle_alta @FormLocal, @JugLocalId, @PosicionL, @EsTitularL, @DummyId OUTPUT;
        SET @IdxJL = @IdxJL + 1;
    END;

    -- Manejo del plantel Visitante (13 jugadores: 11 titulares, 2 suplentes)
    DECLARE @JugadoresVisitante TABLE (Idx INT IDENTITY(1,1), jugador_id INT);
    DELETE FROM @JugadoresVisitante;
    INSERT INTO @JugadoresVisitante (jugador_id)
    SELECT TOP 13 jugador_id FROM torneo.convocatoria WHERE seleccion_id = @CurVisitanteId ORDER BY dorsal;
    
    DECLARE @IdxJV INT = 1;
    DECLARE @MaxJV INT = (SELECT MAX(Idx) FROM @JugadoresVisitante);
    
    WHILE @IdxJV <= @MaxJV
    BEGIN
        DECLARE @JugVisitaId INT = (SELECT jugador_id FROM @JugadoresVisitante WHERE Idx = @IdxJV);
        DECLARE @EsTitularV BIT = CASE WHEN @IdxJV <= 11 THEN 1 ELSE 0 END;
        DECLARE @PosicionV VARCHAR(10) = CASE WHEN @IdxJV <= 11 THEN 'CAMPO' ELSE 'BANCO' END;
        
        EXEC torneo.sp_alineacion_detalle_alta @FormVisitante, @JugVisitaId, @PosicionV, @EsTitularV, @DummyId OUTPUT;
        SET @IdxJV = @IdxJV + 1;
    END;

    SET @IdxPartido = @IdxPartido + 1;
END;

-- ----------------------------------------------------------------------------
-- 5. CASOS DE NEGOCIO OBLIGATORIOS
-- ----------------------------------------------------------------------------

-- CASO A: Cambio por lesión antes de los 20 minutos (Partido 1: ARG)
DECLARE @ArgSale INT = (SELECT TOP 1 jugador_id FROM torneo.convocatoria WHERE seleccion_id = @Sel_Arg AND dorsal = 5); 
DECLARE @ArgEntra INT = (SELECT TOP 1 jugador_id FROM torneo.convocatoria WHERE seleccion_id = @Sel_Arg AND dorsal = 14);
EXEC torneo.sp_cambio_alta @Ptd_1, @Sel_Arg, @ArgSale, @ArgEntra, 15, 1, 'LESION', 0, @DummyId OUTPUT;

-- CASO B: Roja directa y suspensión derivada (Partido 2: MEX)
DECLARE @MexInfractor INT = (SELECT TOP 1 jugador_id FROM torneo.convocatoria WHERE seleccion_id = @Sel_Mex AND dorsal = 4);
DECLARE @TarjetaRojaId INT;
EXEC torneo.sp_tarjeta_alta @Ptd_2, @MexInfractor, 'ROJA', 'DIRECTA', 40, 'Juego brusco grave', @TarjetaRojaId OUTPUT;
EXEC torneo.sp_suspension_alta @MexInfractor, @TarjetaRojaId, 'Roja Directa - Sanción Disciplinaria', '2026-06-13', 1, 0, @DummyId OUTPUT;

-- CASO C: Expulsión por doble amarilla (Partido 3: FRA)
DECLARE @FraInfractor INT = (SELECT TOP 1 jugador_id FROM torneo.convocatoria WHERE seleccion_id = @Sel_Fra AND dorsal = 6);
EXEC torneo.sp_tarjeta_alta @Ptd_3, @FraInfractor, 'AMARILLA', NULL, 25, 'Falta táctica', @DummyId OUTPUT;
EXEC torneo.sp_tarjeta_alta @Ptd_3, @FraInfractor, 'AMARILLA', NULL, 55, 'Mano intencional', @DummyId OUTPUT;
EXEC torneo.sp_tarjeta_alta @Ptd_3, @FraInfractor, 'ROJA', 'DOBLE_AMARILLA', 55, 'Acumulación', @DummyId OUTPUT;

-- CASO D: Conflicto de nacionalidad en designación arbitral (Partido 4: ENG vs ESP)
-- Falla intencionalmente y se registra en arbitraje.designacion_rechazada
BEGIN TRY
    EXEC arbitraje.sp_designacion_arbitral_alta @Ptd_4, @Arb_Eng, 'PRINCIPAL', @DummyId OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Validación Exitosa: Árbitro inglés rechazado para dirigir a Inglaterra. Error: ' + ERROR_MESSAGE();
    -- Alta explícita en rechazada, ya que el TRY bloqueó la ejecución de la validación del SP transaccional
    EXEC arbitraje.sp_designacion_rechazada_alta @Ptd_4, @Arb_Eng, 'PRINCIPAL', 'Conflicto de nacionalidad con el local', @DummyId OUTPUT;
END CATCH;

-- Designación correcta para sortear el conflicto anterior
EXEC arbitraje.sp_designacion_arbitral_alta @Ptd_4, @Arb1, 'PRINCIPAL', @DummyId OUTPUT;

-- ----------------------------------------------------------------------------
-- 6. GESTIÓN DE PUBLICIDAD COMERCIAL (Iteración sin cursores)
-- ----------------------------------------------------------------------------

-- A. Anunciantes 
DECLARE @Anu_Coca INT, @Anu_Bimbo INT, @Anu_YPF INT, @Anu_Ren INT, @Anu_San INT, @Anu_Voda INT;
EXEC publicidad.sp_anunciante_alta 'Coca-Cola', 'Bebidas', 'sponsor@coca-cola.com', @P_Usa, @Anu_Coca OUTPUT;
EXEC publicidad.sp_anunciante_alta 'Grupo Bimbo', 'Alimentos', 'contacto@bimbo.mx', @P_Mex, @Anu_Bimbo OUTPUT;
EXEC publicidad.sp_anunciante_alta 'YPF', 'Energía', 'pauta@ypf.com.ar', @P_Arg, @Anu_YPF OUTPUT;
EXEC publicidad.sp_anunciante_alta 'Renault', 'Automotriz', 'ads@renault.fr', @P_Fra, @Anu_Ren OUTPUT;
EXEC publicidad.sp_anunciante_alta 'Banco Santander', 'Finanzas', 'marketing@santander.es', @P_Esp, @Anu_San OUTPUT;
EXEC publicidad.sp_anunciante_alta 'Vodafone', 'Telecom.', 'ads@vodafone.co.uk', @P_Eng, @Anu_Voda OUTPUT;

-- B. Campañas Globales
DECLARE @Camp_Coca INT, @Camp_Bimbo INT, @Camp_YPF INT, @Camp_Ren INT;
EXEC publicidad.sp_campania_alta @Anu_Coca, 'Share the Magic', 5000000.00, 'USD', '2026-05-01', '2026-08-01', @Camp_Coca OUTPUT;
EXEC publicidad.sp_campania_alta @Anu_Bimbo, 'Alimenta tu Pasión', 2000000.00, 'USD', '2026-05-01', '2026-08-01', @Camp_Bimbo OUTPUT;
EXEC publicidad.sp_campania_alta @Anu_YPF, 'Energía Nacional', 1500000.00, 'USD', '2026-05-01', '2026-08-01', @Camp_YPF OUTPUT;
EXEC publicidad.sp_campania_alta @Anu_Ren, 'Drive The Cup', 3000000.00, 'USD', '2026-05-01', '2026-08-01', @Camp_Ren OUTPUT;

-- C. Piezas Publicitarias
DECLARE @Pz_Coca INT, @Pz_Bimbo INT, @Pz_YPF INT, @Pz_Ren INT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp_Coca, 'Coca Video EN', 'Inglés', @Pz_Coca OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp_Bimbo, 'Bimbo Banner ES', 'Español', @Pz_Bimbo OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp_YPF, 'YPF Spot AR', 'Español', @Pz_YPF OUTPUT;
EXEC publicidad.sp_pieza_publicitaria_alta @Camp_Ren, 'Renault Banner FR', 'Francés', @Pz_Ren OUTPUT;

-- Asociar piezas a mercados (países)
EXEC publicidad.sp_pieza_pais_alta @Pz_Coca, @P_Usa;
EXEC publicidad.sp_pieza_pais_alta @Pz_Bimbo, @P_Mex;
EXEC publicidad.sp_pieza_pais_alta @Pz_YPF, @P_Arg;
EXEC publicidad.sp_pieza_pais_alta @Pz_Ren, @P_Fra;

-- D. Tarifas para Fase de Grupos (4 espacios)
DECLARE @Tar_G1 INT, @Tar_G2 INT, @Tar_G3 INT, @Tar_G4 INT;
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 1, 'USD', 10000.00, @Tar_G1 OUTPUT;
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 2, 'USD', 8500.00, @Tar_G2 OUTPUT;
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 3, 'USD', 7000.00, @Tar_G3 OUTPUT;
EXEC publicidad.sp_tarifa_publicidad_alta 'GRUPOS', 4, 'USD', 5000.00, @Tar_G4 OUTPUT;

-- E. Asignación masiva: 4 publicidades por partido utilizando Bucle WHILE (Partidos de fase de Grupos = 16)
DECLARE @IdxPub INT = 1;

WHILE @IdxPub <= 16
BEGIN
    DECLARE @PubPartidoId INT = (SELECT partido_id FROM @PartidosList WHERE Idx = @IdxPub);

    EXEC publicidad.sp_publicidad_partido_alta @PubPartidoId, @Pz_Coca, @Tar_G1, '2026-06-11 12:00:00', 1, 10000.00, 'USD', @DummyId OUTPUT;
    EXEC publicidad.sp_publicidad_partido_alta @PubPartidoId, @Pz_Bimbo, @Tar_G2, '2026-06-11 12:00:00', 2, 8500.00, 'USD', @DummyId OUTPUT;
    EXEC publicidad.sp_publicidad_partido_alta @PubPartidoId, @Pz_YPF, @Tar_G3, '2026-06-11 12:00:00', 3, 7000.00, 'USD', @DummyId OUTPUT;
    EXEC publicidad.sp_publicidad_partido_alta @PubPartidoId, @Pz_Ren, @Tar_G4, '2026-06-11 12:00:00', 4, 5000.00, 'USD', @DummyId OUTPUT;

    SET @IdxPub = @IdxPub + 1;
END;
GO