USE MundialDB;
GO

SET NOCOUNT ON;

-- ============================================================================
-- 1. PAÍSES Y 16 SELECCIONES PARTICIPANTES
-- ============================================================================
DECLARE @p_id INT, @sel_id INT;

EXEC torneo.sp_pais_alta @nombre='Mexico', @continente='América', @codigoIso='MEX', @husoHorario='Central Standard Time', @pbiPerCapita=10000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de México', @confederacion='CONCACAF', @rankingFifa=15, @grupo='A', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Canada', @continente='América', @codigoIso='CAN', @husoHorario='Eastern Standard Time', @pbiPerCapita=52000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Canadá', @confederacion='CONCACAF', @rankingFifa=35, @grupo='A', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Estados Unidos', @continente='América', @codigoIso='USA', @husoHorario='Eastern Standard Time', @pbiPerCapita=75000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Estados Unidos', @confederacion='CONCACAF', @rankingFifa=11, @grupo='B', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Argentina', @continente='América', @codigoIso='ARG', @husoHorario='Argentina Standard Time', @pbiPerCapita=12000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Argentina', @confederacion='CONMEBOL', @rankingFifa=1, @grupo='B', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Brasil', @continente='América', @codigoIso='BRA', @husoHorario='E. South America Standard Time', @pbiPerCapita=9000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Brasil', @confederacion='CONMEBOL', @rankingFifa=5, @grupo='C', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Francia', @continente='Europa', @codigoIso='FRA', @husoHorario='W. Europe Standard Time', @pbiPerCapita=44000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Francia', @confederacion='UEFA', @rankingFifa=2, @grupo='C', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='España', @continente='Europa', @codigoIso='ESP', @husoHorario='Romance Standard Time', @pbiPerCapita=31000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de España', @confederacion='UEFA', @rankingFifa=3, @grupo='D', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Japon', @continente='Asia', @codigoIso='JPN', @husoHorario='Tokyo Standard Time', @pbiPerCapita=39000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Japón', @confederacion='AFC', @rankingFifa=18, @grupo='D', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Alemania', @continente='Europa', @codigoIso='GER', @husoHorario='W. Europe Standard Time', @pbiPerCapita=48000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Alemania', @confederacion='UEFA', @rankingFifa=10, @grupo='E', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Inglaterra', @continente='Europa', @codigoIso='ENG', @husoHorario='GMT Standard Time', @pbiPerCapita=45000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Inglaterra', @confederacion='UEFA', @rankingFifa=4, @grupo='E', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Uruguay', @continente='América', @codigoIso='URU', @husoHorario='Montevideo Standard Time', @pbiPerCapita=17000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Uruguay', @confederacion='CONMEBOL', @rankingFifa=14, @grupo='F', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Colombia', @continente='América', @codigoIso='COL', @husoHorario='SA Pacific Standard Time', @pbiPerCapita=7000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Colombia', @confederacion='CONMEBOL', @rankingFifa=12, @grupo='F', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Marruecos', @continente='África', @codigoIso='MAR', @husoHorario='Morocco Standard Time', @pbiPerCapita=3800, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Marruecos', @confederacion='CAF', @rankingFifa=13, @grupo='G', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Senegal', @continente='África', @codigoIso='SEN', @husoHorario='Greenwich Standard Time', @pbiPerCapita=1600, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Senegal', @confederacion='CAF', @rankingFifa=20, @grupo='G', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Corea del Sur', @continente='Asia', @codigoIso='KOR', @husoHorario='Korea Standard Time', @pbiPerCapita=33000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Corea del Sur', @confederacion='AFC', @rankingFifa=22, @grupo='H', @seleccionId=@sel_id OUTPUT;

EXEC torneo.sp_pais_alta @nombre='Australia', @continente='Oceanía/Asia', @codigoIso='AUS', @husoHorario='AUS Eastern Standard Time', @pbiPerCapita=60000, @pbiAnio=2025, @paisId=@p_id OUTPUT;
EXEC torneo.sp_seleccion_alta @paisId=@p_id, @nombre=N'Selección de Australia', @confederacion='AFC', @rankingFifa=24, @grupo='H', @seleccionId=@sel_id OUTPUT;
GO

-- ============================================================================
--sedes
-- ============================================================================
EXEC importacion.sp_importar_sedes_wikipedia @rutaCsv = N'C:\Temp\sedes_wikipedia.csv';

-- ============================================================================
--arbitros
-- ============================================================================
EXEC importacion.sp_importar_arbitros @archivo = 'C:\Temp\referees.csv';

-- ============================================================================
-- 2. JUGADORES Y CONVOCATORIAS (23+ jugadores por cada selección)
-- ============================================================================
DECLARE @param_id INT;

EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_SELECCIONES_GRUPO', @valor = 4, @descripcion = 'Máximo de selecciones por grupo', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_CONVOCADOS', @valor = 26, @descripcion = 'Máximo de jugadores convocados por selección', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MIN_MINUTOS_ENTRE_PARTIDOS_SEDE', @valor = 120, @descripcion = 'Minutos mínimos entre partidos en la misma sede', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MIN_MINUTOS_DESCANSO_SELECCION', @valor = 1440, @descripcion = 'Descanso mínimo entre partidos para una selección (24 hs)', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_SUPLENTES', @valor = 15, @descripcion = 'Máximo de suplentes en banca', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_CAMBIOS_REGULAR', @valor = 5, @descripcion = 'Cambios máximos en tiempo regular', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_CAMBIOS_SUPLEMENTARIO', @valor = 1, @descripcion = 'Cambio adicional en suplementario', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MAX_VENTANAS', @valor = 3, @descripcion = 'Ventanas de cambio en tiempo regular', @parametroId = @param_id OUTPUT;
EXEC torneo.sp_parametro_reglamento_alta @clave = 'MIN_MINUTOS_ENTRE_PARTIDOS_ARBITRO', @valor = 180, @descripcion = 'Descanso mínimo para árbitros', @parametroId = @param_id OUTPUT;
GO

DECLARE @s_id INT, @j_id INT, @conv_id INT;
DECLARE @i INT;
DECLARE @pos VARCHAR(10);
DECLARE @nombre_sel NVARCHAR(100);
DECLARE @nombre_jugador NVARCHAR(150);

DECLARE cur_sels CURSOR LOCAL FAST_FORWARD FOR 
    SELECT seleccion_id, nombre FROM torneo.seleccion;

OPEN cur_sels;
FETCH NEXT FROM cur_sels INTO @s_id, @nombre_sel;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @i = 1;
    WHILE @i <= 26 -- 26 jugadores por selección
    BEGIN
        -- Determinar posición orientativa según el dorsal
        SET @pos = CASE 
            WHEN @i = 1 THEN 'ARQ'
            WHEN @i BETWEEN 2 AND 9 THEN 'DEF'
            WHEN @i BETWEEN 10 AND 18 THEN 'MED'
            ELSE 'DEL'
        END;

        -- Armamos el nombre único del jugador
        SET @nombre_jugador = N'Jugador ' + CAST(@i AS NVARCHAR(5)) + ' de ' + @nombre_sel;

        -- Validamos que no exista previamente el jugador para evitar duplicados en re-ejecuciones
        IF NOT EXISTS (SELECT 1 FROM torneo.jugador WHERE nombre = @nombre_jugador)
        BEGIN
            -- Registrar el jugador
            EXEC torneo.sp_jugador_alta 
                @nombre = @nombre_jugador,
                @fechaNacimiento = '2000-01-01',
                @posicion = @pos,
                @clubOrigen = N'Club Local',
                @jugadorId = @j_id OUTPUT;
        END
        ELSE
        BEGIN
            SELECT @j_id = jugador_id FROM torneo.jugador WHERE nombre = @nombre_jugador;
        END

        -- Registrar la convocatoria solo si no la tiene vigente
        IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE seleccion_id = @s_id AND jugador_id = @j_id AND estado = 'VIGENTE')
        BEGIN
            -- Nos aseguramos de no repetir dorsal en la misma selección
            IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE seleccion_id = @s_id AND dorsal = @i AND estado = 'VIGENTE')
            BEGIN
                EXEC torneo.sp_convocatoria_alta 
                    @seleccionId = @s_id,
                    @jugadorId = @j_id,
                    @dorsal = @i,
                    @fechaConvocatoria = '2026-06-01',
                    @convocatoriaId = @conv_id OUTPUT;
            END
        END

        SET @i = @i + 1;
    END

    FETCH NEXT FROM cur_sels INTO @s_id, @nombre_sel;
END

CLOSE cur_sels;
DEALLOCATE cur_sels;
GO

-- ============================================================================
-- 3. ANUNCIANTES DE PAÍSES Y CAMPAÑAS PUBLICITARIAS
-- ============================================================================
USE MundialDB;
GO

SET NOCOUNT ON;

DECLARE @anunciante_id INT, @campania_id INT, @pieza_id INT;
DECLARE @pais_id INT;

-- 1. Anunciante de Estados Unidos (USA)
SELECT @pais_id = pais_id FROM torneo.pais WHERE codigo_iso = 'USA';
EXEC publicidad.sp_anunciante_alta 
    @nombre = N'TechCorp USA', 
    @rubro = 'Tecnología', 
    @email = 'contacto@techusa.com', 
    @paisId = @pais_id, 
    @anuncianteId = @anunciante_id OUTPUT;

EXEC publicidad.sp_campania_alta 
    @anuncianteId = @anunciante_id, 
    @nombre = N'Campaña Tech Global', 
    @presupuesto = 500000.00, 
    @moneda = 'USD', 
    @fechaInicio = '2026-06-01', 
    @fechaFin = '2026-07-31', 
    @campaniaId = @campania_id OUTPUT;

EXEC publicidad.sp_pieza_publicitaria_alta 
    @campaniaId = @campania_id, 
    @nombre = N'Spot 30s USA', 
    @idioma = 'Inglés', 
    @piezaId = @pieza_id OUTPUT;


-- 2. Anunciante de Argentina (ARG)
SELECT @pais_id = pais_id FROM torneo.pais WHERE codigo_iso = 'ARG';
EXEC publicidad.sp_anunciante_alta 
    @nombre = N'MateBA Argentina', 
    @rubro = 'Alimentos', 
    @email = 'info@mateba.com.ar', 
    @paisId = @pais_id, 
    @anuncianteId = @anunciante_id OUTPUT;

EXEC publicidad.sp_campania_alta 
    @anuncianteId = @anunciante_id, 
    @nombre = N'Campaña Tradición', 
    @presupuesto = 200000.00, 
    @moneda = 'USD', 
    @fechaInicio = '2026-06-01', 
    @fechaFin = '2026-07-31', 
    @campaniaId = @campania_id OUTPUT;

EXEC publicidad.sp_pieza_publicitaria_alta 
    @campaniaId = @campania_id, 
    @nombre = N'Spot 30s Argentina', 
    @idioma = 'Español', 
    @piezaId = @pieza_id OUTPUT;


-- 3. Anunciante de Japón (JPN)
SELECT @pais_id = pais_id FROM torneo.pais WHERE codigo_iso = 'JPN';
EXEC publicidad.sp_anunciante_alta 
    @nombre = N'Tokyo Electronics', 
    @rubro = 'Electrónica', 
    @email = 'support@tokyoelec.jp', 
    @paisId = @pais_id, 
    @anuncianteId = @anunciante_id OUTPUT;

EXEC publicidad.sp_campania_alta 
    @anuncianteId = @anunciante_id, 
    @nombre = N'Campaña Innovation', 
    @presupuesto = 800000.00, 
    @moneda = 'USD', 
    @fechaInicio = '2026-06-01', 
    @fechaFin = '2026-07-31', 
    @campaniaId = @campania_id OUTPUT;

EXEC publicidad.sp_pieza_publicitaria_alta 
    @campaniaId = @campania_id, 
    @nombre = N'Spot 30s Japón', 
    @idioma = 'Japonés', 
    @piezaId = @pieza_id OUTPUT;


-- 4. Anunciante de Francia (FRA)
SELECT @pais_id = pais_id FROM torneo.pais WHERE codigo_iso = 'FRA';
EXEC publicidad.sp_anunciante_alta 
    @nombre = N'Paris Mode', 
    @rubro = 'Indumentaria', 
    @email = 'contact@parismode.fr', 
    @paisId = @pais_id, 
    @anuncianteId = @anunciante_id OUTPUT;

EXEC publicidad.sp_campania_alta 
    @anuncianteId = @anunciante_id, 
    @nombre = N'Campaña Elegance', 
    @presupuesto = 400000.00, 
    @moneda = 'USD', 
    @fechaInicio = '2026-06-01', 
    @fechaFin = '2026-07-31', 
    @campaniaId = @campania_id OUTPUT;

EXEC publicidad.sp_pieza_publicitaria_alta 
    @campaniaId = @campania_id, 
    @nombre = N'Spot 30s Francia', 
    @idioma = 'Francés', 
    @piezaId = @pieza_id OUTPUT;


-- 5. Anunciante de Alemania (GER)
SELECT @pais_id = pais_id FROM torneo.pais WHERE codigo_iso = 'GER';
EXEC publicidad.sp_anunciante_alta 
    @nombre = N'Berlin Motors', 
    @rubro = 'Automotriz', 
    @email = 'service@berlinmotors.de', 
    @paisId = @pais_id, 
    @anuncianteId = @anunciante_id OUTPUT;

EXEC publicidad.sp_campania_alta 
    @anuncianteId = @anunciante_id, 
    @nombre = N'Campaña Power', 
    @presupuesto = 600000.00, 
    @moneda = 'USD', 
    @fechaInicio = '2026-06-01', 
    @fechaFin = '2026-07-31', 
    @campaniaId = @campania_id OUTPUT;

EXEC publicidad.sp_pieza_publicitaria_alta 
    @campaniaId = @campania_id, 
    @nombre = N'Spot 30s Alemania', 
    @idioma = 'Alemán', 
    @piezaId = @pieza_id OUTPUT;


-- 6. Anunciante de Brasil (BRA)
SELECT @pais_id = pais_id FROM torneo.pais WHERE codigo_iso = 'BRA';
EXEC publicidad.sp_anunciante_alta 
    @nombre = N'Café do Brasil', 
    @rubro = 'Alimentos', 
    @email = 'contato@cafedobrasil.br', 
    @paisId = @pais_id, 
    @anuncianteId = @anunciante_id OUTPUT;

EXEC publicidad.sp_campania_alta 
    @anuncianteId = @anunciante_id, 
    @nombre = N'Campaña Sabor', 
    @presupuesto = 300000.00, 
    @moneda = 'USD', 
    @fechaInicio = '2026-06-01', 
    @fechaFin = '2026-07-31', 
    @campaniaId = @campania_id OUTPUT;

EXEC publicidad.sp_pieza_publicitaria_alta 
    @campaniaId = @campania_id, 
    @nombre = N'Spot 30s Brasil', 
    @idioma = 'Portugués', 
    @piezaId = @pieza_id OUTPUT;
GO

-- ============================================================================
-- 4. CREACIÓN DE LOS 24 PARTIDOS (Fase de grupos y eliminación directa)
-- ============================================================================

DECLARE @sede_azteca INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = N'Mexico City Stadium');
DECLARE @sede_akron INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = N'New York New Jersey Stadium');
DECLARE @sede_metlife INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = N'Dallas Stadium');
DECLARE @sede_sofi INT = (SELECT TOP 1 sede_id FROM torneo.sede WHERE nombre_estadio = N'Los Angeles Stadium');

DECLARE @mex INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de México%');
DECLARE @can INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de Canadá%');
DECLARE @usa INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de Estados Unidos%');
DECLARE @arg INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de Argentina%');
DECLARE @bra INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de Brasil%');
DECLARE @fra INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de Francia%');
DECLARE @esp INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de España%');
DECLARE @jpn INT = (SELECT seleccion_id FROM torneo.seleccion WHERE nombre LIKE '%Selección de Japón%');

DECLARE @p_id INT;

EXEC torneo.sp_partido_alta @fase='GRUPOS', @sedeId=@sede_azteca, @seleccionLocalId=@mex, @seleccionVisitanteId=@can, @fechaHoraLocal='2026-06-11 18:00:00', @partidoId=@p_id OUTPUT;

EXEC torneo.sp_partido_alta @fase='GRUPOS', @sedeId=@sede_metlife, @seleccionLocalId=@usa, @seleccionVisitanteId=@arg, @fechaHoraLocal='2026-06-15 21:00:00', @partidoId=@p_id OUTPUT;

UPDATE torneo.partido SET estado = 'FINALIZADO' WHERE partido_id = @p_id;

EXEC torneo.sp_partido_alta @fase='GRUPOS', @sedeId=@sede_sofi, @seleccionLocalId=@bra, @seleccionVisitanteId=@fra, @fechaHoraLocal='2026-06-18 16:00:00', @partidoId=@p_id OUTPUT;

EXEC torneo.sp_partido_alta @fase='GRUPOS', @sedeId=@sede_akron, @seleccionLocalId=@esp, @seleccionVisitanteId=@jpn, @fechaHoraLocal='2026-06-20 20:00:00', @partidoId=@p_id OUTPUT;
GO

-- ============================================================================
-- 5. DESIGNACIONES ARBITRALES Y RECHAZO POR CONFLICTO DE NACIONALIDAD
-- ============================================================================
DECLARE @partido_g1 INT = (SELECT TOP 1 partido_id FROM torneo.partido WHERE fase = 'GRUPOS');
DECLARE @arb_mex INT = (SELECT TOP 1 a.arbitro_id FROM arbitraje.arbitro a JOIN torneo.pais p ON a.pais_id = p.pais_id WHERE p.codigo_iso = 'MEX');
DECLARE @arb_inter INT = (SELECT TOP 1 a.arbitro_id FROM arbitraje.arbitro a JOIN torneo.pais p ON a.pais_id = p.pais_id WHERE p.codigo_iso <> 'MEX');
DECLARE @des_id INT;

-- Caso obligatorio: Conflicto de nacionalidad (Árbitro mexicano intentando arbitrar a México)
BEGIN TRY
    EXEC arbitraje.sp_designacion_arbitral_alta 
        @partidoId = @partido_g1, 
        @arbitroId = @arb_mex, 
        @rolArbitral = 'PRINCIPAL', 
        @designacionId = @des_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'OK: Conflicto de nacionalidad capturado y derivado a designacion_rechazada por el SP.';
END CATCH;

-- Designación válida con árbitro internacional
IF @arb_inter IS NOT NULL
BEGIN
    EXEC arbitraje.sp_designacion_arbitral_alta 
        @partidoId = @partido_g1, 
        @arbitroId = @arb_inter, 
        @rolArbitral = 'PRINCIPAL', 
        @designacionId = @des_id OUTPUT;
END;
GO

-- ============================================================================
-- 6. FORMACIONES, CAMBIOS POR LESIÓN Y TARJETAS (Casos obligatorios)
-- ============================================================================
-- Tomamos el primer partido y una selección participante para inyectar los eventos de juego
DECLARE @partido_target INT = (SELECT TOP 1 partido_id FROM torneo.partido);
DECLARE @sel_target INT = (SELECT TOP 1 seleccion_local_id FROM torneo.partido WHERE partido_id = @partido_target);
DECLARE @form_id INT, @alin_id INT, @jug_id INT;

-- Creamos la formación para la selección
EXEC torneo.sp_formacion_partido_alta 
    @partidoId = @partido_target, 
    @seleccionId = @sel_target, 
    @esquema = '4-3-3', 
    @formacionId = @form_id OUTPUT;

-- Seleccionamos un jugador convocado para simular la lesión y el cambio temprano (< 20 minutos)
SELECT TOP 1 @jug_id = j.jugador_id 
FROM torneo.convocatoria c
JOIN torneo.jugador j ON c.jugador_id = j.jugador_id
WHERE c.seleccion_id = @sel_target AND c.estado = 'VIGENTE';

IF @jug_id IS NOT NULL
BEGIN
    -- Lo agregamos como titular
    EXEC torneo.sp_alineacion_detalle_alta 
        @formacionId = @form_id, 
        @jugadorId = @jug_id, 
        @posicionCampo = 'DEF', 
        @esTitular = 1, 
        @alineacionId = @alin_id OUTPUT;

    -- Agregamos otro jugador en el banco para que ingrese por el lesionado
    DECLARE @jug_suplente INT;
    SELECT TOP 1 @jug_suplente = j.jugador_id 
    FROM torneo.convocatoria c
    JOIN torneo.jugador j ON c.jugador_id = j.jugador_id
    WHERE c.seleccion_id = @sel_target AND c.estado = 'VIGENTE' AND c.jugador_id <> @jug_id;

    IF @jug_suplente IS NOT NULL
    BEGIN
        EXEC torneo.sp_alineacion_detalle_alta 
            @formacionId = @form_id, 
            @jugadorId = @jug_suplente, 
            @posicionCampo = 'MED', 
            @esTitular = 0, 
            @alineacionId = @alin_id OUTPUT;

        -- Actualizamos el estado del partido a EN_CURSO temporalmente para permitir cambios/tarjetas
        UPDATE torneo.partido SET estado = 'EN_CURSO' WHERE partido_id = @partido_target;

        -- Caso obligatorio: Cambio por lesión antes de los 20 minutos (Minuto 14)
        DECLARE @cambio_id INT;
        EXEC torneo.sp_cambio_alta 
            @partidoId = @partido_target, 
            @seleccionId = @sel_target, 
            @jugadorSaleId = @jug_id, 
            @jugadorEntraId = @jug_suplente, 
            @minuto = 14, 
            @ventana = 1, 
            @motivo = 'LESION', 
            @esSuplementario = 0, 
            @cambioId = @cambio_id OUTPUT;
            
        -- Caso obligatorio: Tarjeta amarilla y posterior expulsión por doble amarilla / roja directa
        DECLARE @tarjeta_id INT;
        EXEC torneo.sp_tarjeta_alta 
            @partidoId = @partido_target, 
            @jugadorId = @jug_suplente, 
            @tipo = 'AMARILLA', 
            @minuto = 35, 
            @motivo = N'Falta táctica', 
            @tarjetaId = @tarjeta_id OUTPUT;
            
        -- Volvemos el partido a PROGRAMADO o FINALIZADO según corresponda
        UPDATE torneo.partido SET estado = 'FINALIZADO' WHERE partido_id = @partido_target;
    END;
END;
GO

DECLARE @fixture TABLE (
    orden INT IDENTITY(1,1), fase VARCHAR(20), local_n NVARCHAR(50), visit_n NVARCHAR(50),
    sede NVARCHAR(100), fecha DATETIME2(0)
);

--24 partidos del torneo (8 grupos de 2 selecciones)

INSERT INTO @fixture (fase, local_n, visit_n, sede, fecha) VALUES
 -- GRUPOS (A-H). Los cuatro primeros ya estaban cargados.
 ('GRUPOS', N'México',         N'Canadá',         N'Mexico City Stadium',         '2026-06-11 18:00'),
 ('GRUPOS', N'Estados Unidos', N'Argentina',      N'Dallas Stadium',              '2026-06-15 21:00'),
 ('GRUPOS', N'Brasil',         N'Francia',        N'Los Angeles Stadium',         '2026-06-18 16:00'),
 ('GRUPOS', N'España',         N'Japón',          N'New York New Jersey Stadium', '2026-06-20 20:00'),
 ('GRUPOS', N'Alemania',       N'Inglaterra',     N'Boston Stadium',              '2026-06-12 15:00'),
 ('GRUPOS', N'Uruguay',        N'Colombia',       N'Houston Stadium',             '2026-06-13 18:00'),
 ('GRUPOS', N'Marruecos',      N'Senegal',        N'Toronto Stadium',             '2026-06-14 12:00'),
 ('GRUPOS', N'Corea del Sur',  N'Australia',      N'BC Place Vancouver',          '2026-06-16 19:00'),
 -- OCTAVOS
 ('OCTAVOS', N'Argentina',     N'Australia',      N'Kansas City Stadium',         '2026-06-28 17:00'),
 ('OCTAVOS', N'Francia',       N'Canadá',         N'Los Angeles Stadium',         '2026-06-28 20:00'),
 ('OCTAVOS', N'Brasil',        N'Corea del Sur',  N'Philadelphia Stadium',        '2026-06-29 15:00'),
 ('OCTAVOS', N'España',        N'Senegal',        N'Atlanta Stadium',             '2026-06-29 19:00'),
 ('OCTAVOS', N'Estados Unidos',N'Japón',          N'Miami Stadium',               '2026-06-30 16:00'),
 ('OCTAVOS', N'Inglaterra',    N'Colombia',       N'Houston Stadium',             '2026-06-30 20:00'),
 ('OCTAVOS', N'México',        N'Uruguay',        N'Mexico City Stadium',         '2026-07-01 18:00'),
 ('OCTAVOS', N'Alemania',      N'Marruecos',      N'Dallas Stadium',              '2026-07-01 21:00'),
 -- CUARTOS
 ('CUARTOS', N'Argentina',     N'Francia',        N'Houston Stadium',             '2026-07-04 16:00'),
 ('CUARTOS', N'Brasil',        N'España',         N'Philadelphia Stadium',        '2026-07-04 20:00'),
 ('CUARTOS', N'Estados Unidos',N'Inglaterra',     N'Kansas City Stadium',         '2026-07-05 16:00'),
 ('CUARTOS', N'México',        N'Alemania',       N'Mexico City Stadium',         '2026-07-05 20:00'),
 -- SEMIFINALES, TERCER PUESTO Y FINAL
 ('SEMIFINAL',     N'Argentina', N'Brasil',       N'Dallas Stadium',              '2026-07-09 20:00'),
 ('SEMIFINAL',     N'Inglaterra',N'Alemania',     N'Atlanta Stadium',             '2026-07-10 20:00'),
 ('TERCER_PUESTO', N'Brasil',    N'Alemania',     N'Miami Stadium',               '2026-07-18 17:00'),
 ('FINAL',         N'Argentina', N'Inglaterra',   N'New York New Jersey Stadium', '2026-07-19 15:00');

DECLARE @i INT = 0, @fase VARCHAR(20), @ln NVARCHAR(50), @vn NVARCHAR(50), @sedeN NVARCHAR(100), @fecha DATETIME2(0);
DECLARE @l INT, @v INT, @s INT, @p INT;
DECLARE @nuevos INT = 0, @existentes INT = 0, @errores INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = orden, @fase = fase, @ln = local_n, @vn = visit_n, @sedeN = sede, @fecha = fecha
    FROM @fixture WHERE orden > @i ORDER BY orden;
    IF @@ROWCOUNT = 0 BREAK;

    SELECT @l = NULL, @v = NULL, @s = NULL, @p = NULL;
    SELECT @l = seleccion_id FROM torneo.seleccion WHERE nombre = N'Selección de ' + @ln;
    SELECT @v = seleccion_id FROM torneo.seleccion WHERE nombre = N'Selección de ' + @vn;
    SELECT @s = sede_id      FROM torneo.sede      WHERE nombre_estadio = @sedeN;

    IF @l IS NULL OR @v IS NULL OR @s IS NULL
    BEGIN
        PRINT CONCAT('ERROR (no se encontro seleccion o sede): ', @fase, ' ', @ln, ' vs ', @vn, ' en ', @sedeN);
        SET @errores += 1;
        CONTINUE;
    END;

    IF EXISTS (SELECT 1 FROM torneo.partido
               WHERE fase = @fase AND seleccion_local_id = @l AND seleccion_visitante_id = @v)
    BEGIN
        SET @existentes += 1;
        CONTINUE;
    END;

    BEGIN TRY
        EXEC torneo.sp_partido_alta
             @fase = @fase, @sedeId = @s, @seleccionLocalId = @l, @seleccionVisitanteId = @v,
             @fechaHoraLocal = @fecha, @partidoId = @p OUTPUT;
        SET @nuevos += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR en ', @fase, ' ', @ln, ' vs ', @vn, ': ', ERROR_MESSAGE());
        SET @errores += 1;
    END CATCH;
END;

PRINT CONCAT('Partidos nuevos: ', @nuevos, ' | ya existian: ', @existentes, ' | con error: ', @errores);

SELECT fase, COUNT(*) AS partidos FROM torneo.partido GROUP BY fase;  
GO

--Una formacion por (partido, seleccion)
DECLARE @pares TABLE (id INT IDENTITY(1,1), partido_id INT, seleccion_id INT);
INSERT INTO @pares (partido_id, seleccion_id)
SELECT partido_id, seleccion_local_id     FROM torneo.partido
UNION ALL
SELECT partido_id, seleccion_visitante_id FROM torneo.partido;

DECLARE @i INT = 0, @pa INT, @se INT, @form INT, @formaciones INT = 0, @errores INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @pa = partido_id, @se = seleccion_id FROM @pares WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    IF NOT EXISTS (SELECT 1 FROM torneo.formacion_partido WHERE partido_id = @pa AND seleccion_id = @se)
    BEGIN
        BEGIN TRY
            EXEC torneo.sp_formacion_partido_alta
                 @partidoId = @pa, @seleccionId = @se, @esquema = '4-3-3', @formacionId = @form OUTPUT;
            SET @formaciones += 1;
        END TRY
        BEGIN CATCH
            PRINT CONCAT('ERROR formacion partido ', @pa, ' seleccion ', @se, ': ', ERROR_MESSAGE());
            SET @errores += 1;
        END CATCH;
    END;
END;
PRINT CONCAT('Formaciones nuevas: ', @formaciones, ' | errores: ', @errores);

-- 2. Jugadores a alinear 
DROP TABLE IF EXISTS #alin;
SELECT IDENTITY(INT,1,1) AS id,
       f.formacion_id, c.jugador_id, c.dorsal, j.posicion,
       CASE WHEN c.dorsal IN (1,2,3,4,5,10,11,12,19,20,21) THEN 1 ELSE 0 END AS titular,
       p.fase, s.nombre AS seleccion
INTO #alin
FROM torneo.formacion_partido f
JOIN torneo.partido      p ON p.partido_id   = f.partido_id
JOIN torneo.seleccion    s ON s.seleccion_id = f.seleccion_id
JOIN torneo.convocatoria c ON c.seleccion_id = f.seleccion_id AND c.estado = 'VIGENTE'
JOIN torneo.jugador      j ON j.jugador_id   = c.jugador_id
WHERE NOT EXISTS (SELECT 1 FROM torneo.alineacion_detalle a
                  WHERE a.formacion_id = f.formacion_id AND a.jugador_id = c.jugador_id)
ORDER BY f.formacion_id, c.dorsal;

-- CASO 2: Argentina en cuartos sin el dorsal 11 (suspendido); el 13 lo reemplaza como titular
DELETE FROM #alin WHERE fase = 'CUARTOS' AND seleccion = N'Selección de Argentina' AND dorsal = 11;
UPDATE #alin SET titular = 1
WHERE fase = 'CUARTOS' AND seleccion = N'Selección de Argentina' AND dorsal = 13;

-- 3. Alta de cada alineacion 
DECLARE @k INT = 0, @fo INT, @ju INT, @pos VARCHAR(10), @tit BIT, @al INT, @cargados INT = 0, @err2 INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @k = id, @fo = formacion_id, @ju = jugador_id, @pos = posicion, @tit = titular
    FROM #alin WHERE id > @k ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    BEGIN TRY
        EXEC torneo.sp_alineacion_detalle_alta
             @formacionId = @fo, @jugadorId = @ju, @posicionCampo = @pos,
             @esTitular = @tit, @alineacionId = @al OUTPUT;
        SET @cargados += 1;
    END TRY
    BEGIN CATCH
        IF @err2 < 10 PRINT CONCAT('ERROR alineacion formacion ', @fo, ' jugador ', @ju, ': ', ERROR_MESSAGE());
        SET @err2 += 1;
    END CATCH;
END;
PRINT CONCAT('Alineaciones cargadas: ', @cargados, ' | errores: ', @err2);
GO
-- ============================================================================
-- 7. CASO 5: designacion rechazada por conflicto de nacionalidad
-- ============================================================================
DECLARE @pa INT, @pais INT, @arb INT, @des INT;

SELECT @pa = p.partido_id, @pais = sl.pais_id
FROM torneo.partido p
JOIN torneo.seleccion sl ON sl.seleccion_id = p.seleccion_local_id
WHERE p.fase = 'GRUPOS' AND sl.nombre = N'Selección de México';

IF @pa IS NULL
    PRINT 'No se encontro el partido de grupos de Mexico (ejecutar antes seed_02_partidos_24.sql).';
ELSE IF NOT EXISTS (SELECT 1 FROM arbitraje.designacion_rechazada WHERE partido_id = @pa)
BEGIN
    SELECT TOP (1) @arb = arbitro_id FROM arbitraje.arbitro WHERE pais_id = @pais ORDER BY arbitro_id;

    IF @arb IS NULL
        EXEC arbitraje.sp_arbitro_alta @nombre = N'Árbitro Demo México', @paisId = @pais,
                                       @categoria = 'FIFA', @arbitroId = @arb OUTPUT;

    BEGIN TRY
        EXEC arbitraje.sp_designacion_arbitral_alta
             @partidoId = @pa, @arbitroId = @arb, @rolArbitral = 'PRINCIPAL', @designacionId = @des OUTPUT;
        PRINT 'ATENCION: se esperaba un rechazo por nacionalidad y la designacion se acepto.';
    END TRY
    BEGIN CATCH
        PRINT 'OK (rechazo esperado): ' + REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' ');
    END CATCH;
END;
GO

-- ============================================================================
-- 8. Designaciones completas en todos los partidos
-- ============================================================================
DECLARE @slots TABLE (orden INT, rol VARCHAR(10), req INT);
INSERT INTO @slots (orden, rol, req) VALUES
    (1, 'PRINCIPAL', 1), (2, 'ASISTENTE', 1), (3, 'ASISTENTE', 2), (4, 'CUARTO', 1), (5, 'VAR', 1);

DECLARE @partidos TABLE (id INT IDENTITY(1,1), partido_id INT, pais_l INT, pais_v INT, utc DATETIME2(0));
INSERT INTO @partidos (partido_id, pais_l, pais_v, utc)
SELECT p.partido_id, sl.pais_id, sv.pais_id, p.fecha_hora_utc
FROM torneo.partido p
JOIN torneo.seleccion sl ON sl.seleccion_id = p.seleccion_local_id
JOIN torneo.seleccion sv ON sv.seleccion_id = p.seleccion_visitante_id
ORDER BY p.fecha_hora_utc;

DECLARE @i INT = 0, @j INT, @pa INT, @pl INT, @pv INT, @utc DATETIME2(0),
        @rol VARCHAR(10), @req INT, @arb INT, @des INT, @ok INT = 0, @err INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @pa = partido_id, @pl = pais_l, @pv = pais_v, @utc = utc
    FROM @partidos WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    SET @j = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @j = orden, @rol = rol, @req = req FROM @slots WHERE orden > @j ORDER BY orden;
        IF @@ROWCOUNT = 0 BREAK;

        IF (SELECT COUNT(*) FROM arbitraje.designacion_arbitral
            WHERE partido_id = @pa AND rol_arbitral = @rol) >= @req
            CONTINUE;

        SET @arb = NULL;
        SELECT TOP (1) @arb = a.arbitro_id
        FROM arbitraje.arbitro a
        WHERE a.pais_id NOT IN (@pl, @pv)                                           
          AND NOT EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral d            
                          WHERE d.partido_id = @pa AND d.arbitro_id = a.arbitro_id)
          AND NOT EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral d            
                          JOIN torneo.partido p2 ON p2.partido_id = d.partido_id
                          WHERE d.arbitro_id = a.arbitro_id AND d.partido_id <> @pa
                            AND ABS(DATEDIFF(MINUTE, p2.fecha_hora_utc, @utc)) < 180)
        ORDER BY CASE WHEN @rol = 'PRINCIPAL' AND a.categoria = 'FIFA' THEN 0 ELSE 1 END,
                 CASE WHEN EXISTS (SELECT 1 FROM torneo.seleccion s WHERE s.pais_id = a.pais_id) THEN 1 ELSE 0 END,
                 (SELECT COUNT(*) FROM arbitraje.designacion_arbitral d WHERE d.arbitro_id = a.arbitro_id),
                 a.arbitro_id;

        IF @arb IS NULL
        BEGIN
            PRINT CONCAT('Sin arbitro elegible para partido ', @pa, ' rol ', @rol);
            SET @err += 1;
            CONTINUE;
        END;

        BEGIN TRY
            EXEC arbitraje.sp_designacion_arbitral_alta
                 @partidoId = @pa, @arbitroId = @arb, @rolArbitral = @rol, @designacionId = @des OUTPUT;
            SET @ok += 1;
        END TRY
        BEGIN CATCH
            PRINT CONCAT('ERROR partido ', @pa, ' rol ', @rol, ' arbitro ', @arb, ': ',
                         REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
            SET @err += 1;
        END CATCH;
    END;
END;
PRINT CONCAT('Designaciones cargadas: ', @ok, ' | errores: ', @err);
GO
-- ============================================================================
-- 9. Tarifas
-- ============================================================================
DECLARE @t TABLE (id INT IDENTITY(1,1), fase VARCHAR(15), espacio TINYINT, importe DECIMAL(12,2));
INSERT INTO @t (fase, espacio, importe)
SELECT f.fase, e.espacio, CAST(f.base * e.factor AS DECIMAL(12,2))
FROM (VALUES ('GRUPOS', 50000.00), ('OCTAVOS', 80000.00), ('CUARTOS', 120000.00),
             ('SEMIFINAL', 200000.00), ('TERCER_PUESTO', 90000.00), ('FINAL', 400000.00)) AS f(fase, base)
CROSS JOIN (VALUES (1, 1.00), (2, 0.90), (3, 0.80), (4, 0.70)) AS e(espacio, factor);

DECLARE @i INT = 0, @fase VARCHAR(15), @esp TINYINT, @imp DECIMAL(12,2), @id INT, @n INT = 0;
WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @fase = fase, @esp = espacio, @imp = importe FROM @t WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;
    IF EXISTS (SELECT 1 FROM publicidad.tarifa_publicidad WHERE fase = @fase AND espacio = @esp) CONTINUE;
    BEGIN TRY
        EXEC publicidad.sp_tarifa_publicidad_alta @fase = @fase, @espacio = @esp, @moneda = 'USD',
                                                  @importe = @imp, @tarifaId = @id OUTPUT;
        SET @n += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR tarifa ', @fase, ' espacio ', @esp, ': ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
    END CATCH;
END;
PRINT CONCAT('Tarifas nuevas: ', @n);
GO

-- ============================================================================
-- 10. Tipos de cambio (valores de ejemplo para el seed)
-- ============================================================================
DECLARE @tc TABLE (id INT IDENTITY(1,1), destino VARCHAR(10), tasa DECIMAL(18,8));
INSERT INTO @tc (destino, tasa) VALUES
    ('EUR', 0.92), ('GBP', 0.78), ('JPY', 150.0), ('ARS', 1100.0), ('BRL', 5.3),
    ('MXN', 17.8), ('CAD', 1.37), ('COP', 4000.0), ('KRW', 1370.0);

DECLARE @i INT = 0, @dest VARCHAR(10), @tasa DECIMAL(18,8), @id INT, @n INT = 0, @fecha DATE = '2026-06-01';
WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @dest = destino, @tasa = tasa FROM @tc WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;
    IF EXISTS (SELECT 1 FROM publicidad.tipo_cambio
               WHERE moneda_origen = 'USD' AND moneda_destino = @dest AND fecha = @fecha) CONTINUE;
    BEGIN TRY
        EXEC publicidad.sp_tipo_cambio_alta @monedaOrigen = 'USD', @monedaDestino = @dest,
                                            @fecha = @fecha, @tasa = @tasa, @tipoCambioId = @id OUTPUT;
        SET @n += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR tipo de cambio USD-', @dest, ': ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
    END CATCH;
END;
PRINT CONCAT('Tipos de cambio nuevos: ', @n);
GO

-- ============================================================================
-- 11. Anunciantes, campanias y piezas adicionales
-- ============================================================================
DECLARE @a TABLE (id INT IDENTITY(1,1), iso VARCHAR(3), anunciante NVARCHAR(100), rubro NVARCHAR(100),
                  email VARCHAR(150), campania NVARCHAR(100), moneda VARCHAR(10), presupuesto DECIMAL(14,2),
                  pieza NVARCHAR(100), idioma NVARCHAR(50));
INSERT INTO @a (iso, anunciante, rubro, email, campania, moneda, presupuesto, pieza, idioma) VALUES
 ('MEX', N'Aztec Beverages',  N'Bebidas',    'contacto@aztecbeverages.mx', N'Campaña Fiesta',   'MXN',   6000000.00,    N'Spot 30s México',    N'Español'),
 ('COL', N'Café Andino',      N'Alimentos',  'hola@cafeandino.co',         N'Campaña Origen',   'COP', 1200000000.00,    N'Spot 30s Colombia',  N'Español'),
 ('CAN', N'Maple Outdoors',   N'Deportes',   'info@mapleoutdoors.ca',      N'Campaña Aventura', 'CAD',    500000.00,    N'Spot 30s Canadá',    N'Inglés'),
 ('KOR', N'Seoul Mobile',     N'Tecnología', 'contact@seoulmobile.kr',     N'Campaña Conecta',  'KRW', 700000000.00,    N'Spot 30s Corea',     N'Coreano'),
 ('ESP', N'Iberia Foods',     N'Alimentos',  'info@iberiafoods.es',        N'Campaña Sol',      'EUR',    350000.00,    N'Spot 30s España',    N'Español'),
 ('ENG', N'London Bank',      N'Finanzas',   'press@londonbank.co.uk',     N'Campaña Capital',  'GBP',    450000.00,    N'Spot 30s Inglaterra',N'Inglés');

DECLARE @i INT = 0, @iso VARCHAR(3), @nom NVARCHAR(100), @rub NVARCHAR(100), @mail VARCHAR(150),
        @camN NVARCHAR(100), @mon VARCHAR(10), @pres DECIMAL(14,2), @pzN NVARCHAR(100), @idi NVARCHAR(50);
DECLARE @pais INT, @anun INT, @cam INT, @pz INT;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @iso = iso, @nom = anunciante, @rub = rubro, @mail = email, @camN = campania,
                   @mon = moneda, @pres = presupuesto, @pzN = pieza, @idi = idioma
    FROM @a WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    BEGIN TRY
        SELECT @pais = pais_id FROM torneo.pais WHERE codigo_iso = @iso;
        IF @pais IS NULL THROW 50900, 'No se encontro el pais por codigo_iso.', 1;

        SET @anun = (SELECT anunciante_id FROM publicidad.anunciante WHERE nombre = @nom AND pais_id = @pais);
        IF @anun IS NULL
            EXEC publicidad.sp_anunciante_alta @nombre = @nom, @rubro = @rub, @email = @mail,
                                               @paisId = @pais, @anuncianteId = @anun OUTPUT;

        SET @cam = (SELECT campania_id FROM publicidad.campania WHERE anunciante_id = @anun AND nombre = @camN);
        IF @cam IS NULL
            EXEC publicidad.sp_campania_alta @anuncianteId = @anun, @nombre = @camN, @presupuesto = @pres,
                                             @moneda = @mon, @fechaInicio = '2026-06-01', @fechaFin = '2026-07-31',
                                             @campaniaId = @cam OUTPUT;

        SET @pz = (SELECT pieza_id FROM publicidad.pieza_publicitaria WHERE campania_id = @cam AND nombre = @pzN);
        IF @pz IS NULL
            EXEC publicidad.sp_pieza_publicitaria_alta @campaniaId = @cam, @nombre = @pzN, @idioma = @idi,
                                                       @piezaId = @pz OUTPUT;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR anunciante ', @nom, ' (', @iso, '): ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
    END CATCH;
    SET @pais = NULL;
END;
GO

-- ============================================================================
-- 12. Paises de interes de cada pieza
-- ============================================================================
DECLARE @pp TABLE (id INT IDENTITY(1,1), pieza NVARCHAR(100), iso VARCHAR(3));
INSERT INTO @pp (pieza, iso) VALUES
    (N'Spot 30s USA', 'USA'),      (N'Spot 30s USA', 'CAN'),
    (N'Spot 30s Argentina', 'ARG'),(N'Spot 30s Argentina', 'URU'),
    (N'Spot 30s Brasil', 'BRA'),   (N'Spot 30s Francia', 'FRA'),
    (N'Spot 30s Alemania', 'GER'), (N'Spot 30s Japón', 'JPN'),
    (N'Spot 30s México', 'MEX'),   (N'Spot 30s Colombia', 'COL'),
    (N'Spot 30s Canadá', 'CAN'),   (N'Spot 30s Corea', 'KOR'),
    (N'Spot 30s España', 'ESP'),   (N'Spot 30s Inglaterra', 'ENG');

DECLARE @i INT = 0, @pzN NVARCHAR(100), @iso VARCHAR(3), @pz INT, @pais INT, @n INT = 0;
WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @pzN = pieza, @iso = iso FROM @pp WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    SELECT @pz = NULL, @pais = NULL;
    SELECT @pz   = pieza_id FROM publicidad.pieza_publicitaria WHERE nombre = @pzN;
    SELECT @pais = pais_id  FROM torneo.pais WHERE codigo_iso = @iso;

    IF @pz IS NULL OR @pais IS NULL
    BEGIN
        PRINT CONCAT('ERROR pieza_pais (no se encontro pieza o pais): ', @pzN, ' / ', @iso);
        CONTINUE;
    END;
    IF EXISTS (SELECT 1 FROM publicidad.pieza_pais WHERE pieza_id = @pz AND pais_id = @pais) CONTINUE;

    BEGIN TRY
        EXEC publicidad.sp_pieza_pais_alta @piezaId = @pz, @paisId = @pais;
        SET @n += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR pieza_pais ', @pzN, ' / ', @iso, ': ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
    END CATCH;
END;
PRINT CONCAT('Paises de interes nuevos: ', @n);
GO

-- ============================================================================
--13.Resultados y goles de los partidos jugados
-- ============================================================================
DECLARE @res TABLE (
    orden INT IDENTITY(1,1), fase VARCHAR(15), local_n NVARCHAR(50), visit_n NVARCHAR(50),
    gl TINYINT, gv TINYINT, pl TINYINT NULL, pv TINYINT NULL
);
INSERT INTO @res (fase, local_n, visit_n, gl, gv, pl, pv) VALUES
 ('GRUPOS',  N'México',         N'Canadá',        2, 1, NULL, NULL),
 ('GRUPOS',  N'Estados Unidos', N'Argentina',     1, 3, NULL, NULL),
 ('GRUPOS',  N'Brasil',         N'Francia',       2, 2, NULL, NULL),
 ('GRUPOS',  N'España',         N'Japón',         3, 0, NULL, NULL),
 ('GRUPOS',  N'Alemania',       N'Inglaterra',    1, 1, NULL, NULL),
 ('GRUPOS',  N'Uruguay',        N'Colombia',      0, 1, NULL, NULL),
 ('GRUPOS',  N'Marruecos',      N'Senegal',       2, 0, NULL, NULL),
 ('GRUPOS',  N'Corea del Sur',  N'Australia',     1, 1, NULL, NULL),
 ('OCTAVOS', N'Argentina',      N'Australia',     3, 0, NULL, NULL),
 ('OCTAVOS', N'Francia',        N'Canadá',        2, 0, NULL, NULL),
 ('OCTAVOS', N'Brasil',         N'Corea del Sur', 4, 1, NULL, NULL),
 ('OCTAVOS', N'España',         N'Senegal',       1, 1, 4,    2),
 ('OCTAVOS', N'Estados Unidos', N'Japón',         2, 1, NULL, NULL),
 ('OCTAVOS', N'Inglaterra',     N'Colombia',      2, 0, NULL, NULL),
 ('OCTAVOS', N'México',         N'Uruguay',       1, 0, NULL, NULL),
 ('OCTAVOS', N'Alemania',       N'Marruecos',     2, 1, NULL, NULL),
 ('CUARTOS', N'Argentina',      N'Francia',       2, 1, NULL, NULL),
 ('CUARTOS', N'Brasil',         N'España',        2, 1, NULL, NULL),
 ('CUARTOS', N'Estados Unidos', N'Inglaterra',    1, 2, NULL, NULL),
 ('CUARTOS', N'México',         N'Alemania',      1, 2, NULL, NULL);

DECLARE @o INT = 0, @fase VARCHAR(15), @ln NVARCHAR(50), @vn NVARCHAR(50),
        @gl TINYINT, @gv TINYINT, @pl TINYINT, @pv TINYINT;
DECLARE @l INT, @v INT, @pa INT, @sede INT, @fh DATETIME2(0), @estado VARCHAR(12), @asist INT;
DECLARE @side INT, @k INT, @n INT, @team INT, @m INT;
DECLARE @dAut INT, @dAsi INT, @aut INT, @asi INT, @min SMALLINT, @tipo VARCHAR(12), @per VARCHAR(15), @golId INT;
DECLARE @finalizados INT = 0, @goles INT = 0, @errores INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @o = orden, @fase = fase, @ln = local_n, @vn = visit_n, @gl = gl, @gv = gv, @pl = pl, @pv = pv
    FROM @res WHERE orden > @o ORDER BY orden;
    IF @@ROWCOUNT = 0 BREAK;

    SELECT @l = NULL, @v = NULL, @pa = NULL;
    SELECT @l = seleccion_id FROM torneo.seleccion WHERE nombre = N'Selección de ' + @ln;
    SELECT @v = seleccion_id FROM torneo.seleccion WHERE nombre = N'Selección de ' + @vn;
    SELECT @pa = partido_id, @sede = sede_id, @fh = fecha_hora_local, @estado = estado
    FROM torneo.partido WHERE fase = @fase AND seleccion_local_id = @l AND seleccion_visitante_id = @v;

    IF @pa IS NULL
    BEGIN
        PRINT CONCAT('No existe el partido ', @fase, ' ', @ln, ' vs ', @vn, ' (correr seed_02).');
        SET @errores += 1;
        CONTINUE;
    END;
    IF @estado = 'FINALIZADO' CONTINUE;

    BEGIN TRY
        IF @estado = 'PROGRAMADO'
            EXEC torneo.sp_partido_modificacion
                 @partidoId = @pa, @fase = @fase, @sedeId = @sede, @seleccionLocalId = @l,
                 @seleccionVisitanteId = @v, @fechaHoraLocal = @fh, @estado = 'EN_CURSO';

        IF NOT EXISTS (SELECT 1 FROM torneo.gol WHERE partido_id = @pa)
        BEGIN
            SET @side = 0;
            WHILE @side <= 1
            BEGIN
                SET @team = CASE WHEN @side = 0 THEN @l ELSE @v END;
                SET @n    = CASE WHEN @side = 0 THEN @gl ELSE @gv END;
                SET @k = 1;
                WHILE @k <= @n
                BEGIN
                    SET @m    = (@o + @k + @side) % 6;
                    SET @dAut = CHOOSE((@m % 5) + 1, 19, 20, 21, 11, 10);
                    SET @dAsi = CHOOSE((@m % 4) + 1, 10, 12, 18, 17);
                    IF @dAsi = @dAut SET @dAsi = 16;
                    SET @tipo = CASE @m WHEN 0 THEN 'PENAL' WHEN 2 THEN 'CABEZAZO' WHEN 3 THEN 'TIRO_LIBRE' ELSE 'JUGADA' END;
                    SET @min  = 9 + 19 * (@k - 1) + 4 * @side + (@o % 3);
                    SET @per  = CASE WHEN @min <= 45 THEN 'PRIMER_TIEMPO' ELSE 'SEGUNDO_TIEMPO' END;

                    IF @fase = 'CUARTOS' AND @ln = N'Brasil' AND @side = 0 AND @k = 2
                        SELECT @min = 104, @per = 'ALARGUE', @tipo = 'JUGADA';

                    SELECT @aut = NULL, @asi = NULL;
                    SELECT @aut = jugador_id FROM torneo.convocatoria
                    WHERE seleccion_id = @team AND dorsal = @dAut AND estado = 'VIGENTE';
                    IF @tipo <> 'PENAL'
                        SELECT @asi = jugador_id FROM torneo.convocatoria
                        WHERE seleccion_id = @team AND dorsal = @dAsi AND estado = 'VIGENTE';

                    EXEC torneo.sp_gol_alta
                         @partidoId = @pa, @seleccionId = @team, @jugadorId = @aut, @jugadorAsistenteId = @asi,
                         @minuto = @min, @tipoGol = @tipo, @periodo = @per, @golId = @golId OUTPUT;
                    SET @goles += 1;
                    SET @k += 1;
                END;
                SET @side += 1;
            END;
        END;

       
        SET @asist = CAST((SELECT capacidad FROM torneo.sede WHERE sede_id = @sede) * 0.93 AS INT);
        EXEC torneo.sp_partido_modificacion
             @partidoId = @pa, @fase = @fase, @sedeId = @sede, @seleccionLocalId = @l,
             @seleccionVisitanteId = @v, @fechaHoraLocal = @fh,
             @golesLocal = @gl, @golesVisitante = @gv, @penalesLocal = @pl, @penalesVisitante = @pv,
             @asistencia = @asist, @estado = 'FINALIZADO';
        SET @finalizados += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR ', @fase, ' ', @ln, ' vs ', @vn, ': ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
        SET @errores += 1;
    END CATCH;
END;
PRINT CONCAT('Partidos finalizados: ', @finalizados, ' | goles cargados: ', @goles, ' | errores: ', @errores);
GO
-- ============================================================================
-- 14. Cambios (el primero es el CASO 3)
-- ============================================================================
DECLARE @c TABLE (id INT IDENTITY(1,1), fase VARCHAR(15), local_n NVARCHAR(50), equipo_n NVARCHAR(50),
                  sale INT, entra INT, minuto SMALLINT, ventana TINYINT, motivo VARCHAR(10));
INSERT INTO @c (fase, local_n, equipo_n, sale, entra, minuto, ventana, motivo) VALUES
 ('GRUPOS',  N'Estados Unidos', N'Estados Unidos', 3,  6, 14, 1, 'LESION'),      -- CASO 3
 ('GRUPOS',  N'México',         N'México',         11, 17, 60, 1, 'TACTICO'),
 ('GRUPOS',  N'México',         N'Canadá',         21, 24, 72, 2, 'TACTICO'),
 ('OCTAVOS', N'España',         N'España',         10, 14, 33, 1, 'LESION'),
 ('OCTAVOS', N'México',         N'Uruguay',        19, 22, 65, 1, 'TACTICO'),
 ('CUARTOS', N'Argentina',      N'Francia',        12, 16, 80, 2, 'PRECAUCION');

DECLARE @i INT = 0, @fase VARCHAR(15), @ln NVARCHAR(50), @en NVARCHAR(50), @ds INT, @de INT,
        @min SMALLINT, @vent TINYINT, @mot VARCHAR(10);
DECLARE @pa INT, @sel INT, @sale INT, @entra INT, @id INT, @ok INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @fase = fase, @ln = local_n, @en = equipo_n, @ds = sale, @de = entra,
                   @min = minuto, @vent = ventana, @mot = motivo
    FROM @c WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    SELECT @pa = NULL, @sel = NULL, @sale = NULL, @entra = NULL;
    SELECT @pa = p.partido_id
    FROM torneo.partido p JOIN torneo.seleccion s ON s.seleccion_id = p.seleccion_local_id
    WHERE p.fase = @fase AND s.nombre = N'Selección de ' + @ln;
    SELECT @sel   = seleccion_id FROM torneo.seleccion WHERE nombre = N'Selección de ' + @en;
    SELECT @sale  = jugador_id FROM torneo.convocatoria WHERE seleccion_id = @sel AND dorsal = @ds AND estado = 'VIGENTE';
    SELECT @entra = jugador_id FROM torneo.convocatoria WHERE seleccion_id = @sel AND dorsal = @de AND estado = 'VIGENTE';

    IF EXISTS (SELECT 1 FROM torneo.cambio WHERE partido_id = @pa AND jugador_sale_id = @sale) CONTINUE;

    BEGIN TRY
        EXEC torneo.sp_cambio_alta @partidoId = @pa, @seleccionId = @sel, @jugadorSaleId = @sale,
                                   @jugadorEntraId = @entra, @minuto = @min, @ventana = @vent,
                                   @motivo = @mot, @esSuplementario = 0, @cambioId = @id OUTPUT;
        SET @ok += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR cambio ', @fase, ' ', @en, ' dorsal ', @ds, ': ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
    END CATCH;
END;
PRINT CONCAT('Cambios cargados: ', @ok);
GO

-- ============================================================================
-- 15. Tarjetas (las marcadas con tag alimentan las suspensiones)
-- ============================================================================
DECLARE @t TABLE (id INT IDENTITY(1,1), fase VARCHAR(15), local_n NVARCHAR(50), equipo_n NVARCHAR(50), dorsal INT,
                  tipo VARCHAR(8), origen VARCHAR(15) NULL, minuto SMALLINT, motivo NVARCHAR(200), tag VARCHAR(20) NULL);
INSERT INTO @t (fase, local_n, equipo_n, dorsal, tipo, origen, minuto, motivo, tag) VALUES
 -- CASO 1a: doble amarilla
 ('GRUPOS',  N'Alemania',       N'Alemania',       4,  'AMARILLA', NULL,             31, N'Falta táctica',            NULL),
 ('GRUPOS',  N'Alemania',       N'Alemania',       4,  'AMARILLA', NULL,             67, N'Falta por detrás',         NULL),
 ('GRUPOS',  N'Alemania',       N'Alemania',       4,  'ROJA',     'DOBLE_AMARILLA', 67, N'Segunda amonestación',     'GER_DOBLE'),
 -- CASO 1b: roja directa
 ('GRUPOS',  N'Brasil',         N'Brasil',         5,  'ROJA',     'DIRECTA',        52, N'Juego brusco grave',       'BRA_DIRECTA'),
 -- CASO 2: dos amarillas en partidos distintos
 ('OCTAVOS', N'Argentina',      N'Argentina',      11, 'AMARILLA', NULL,             38, N'Protestas',                'ARG_Y1'),
 ('CUARTOS', N'Argentina',      N'Argentina',      11, 'AMARILLA', NULL,             71, N'Falta táctica',            'ARG_Y2'),
 -- Amarillas comunes (completan el reporte de tarjetas por seleccion y jugador)
 ('GRUPOS',  N'México',         N'México',         6,  'AMARILLA', NULL,             22, N'Falta táctica',            NULL),
 ('GRUPOS',  N'México',         N'Canadá',         8,  'AMARILLA', NULL,             55, N'Protestas',                NULL),
 ('GRUPOS',  N'Estados Unidos', N'Argentina',      5,  'AMARILLA', NULL,             40, N'Falta táctica',            NULL),
 ('GRUPOS',  N'Estados Unidos', N'Estados Unidos', 10, 'AMARILLA', NULL,             77, N'Juego peligroso',          NULL),
 ('GRUPOS',  N'España',         N'Japón',          3,  'AMARILLA', NULL,             63, N'Falta táctica',            NULL),
 ('GRUPOS',  N'Uruguay',        N'Uruguay',        9,  'AMARILLA', NULL,             30, N'Simulación',               NULL),
 ('GRUPOS',  N'Uruguay',        N'Colombia',       2,  'AMARILLA', NULL,             88, N'Pérdida de tiempo',        NULL),
 ('OCTAVOS', N'España',         N'Senegal',        7,  'AMARILLA', NULL,             49, N'Falta táctica',            NULL),
 ('OCTAVOS', N'España',         N'España',         4,  'AMARILLA', NULL,             83, N'Protestas',                NULL),
 ('OCTAVOS', N'Estados Unidos', N'Estados Unidos', 8,  'AMARILLA', NULL,             59, N'Juego peligroso',          NULL),
 ('OCTAVOS', N'Inglaterra',     N'Colombia',       6,  'AMARILLA', NULL,             35, N'Falta táctica',            NULL),
 ('CUARTOS', N'Estados Unidos', N'Inglaterra',     3,  'AMARILLA', NULL,             70, N'Juego peligroso',          NULL);

-- Guarda tarjeta, jugador y fecha de las marcadas para armar las suspensiones
CREATE TABLE #tag (tag VARCHAR(20) PRIMARY KEY, tarjeta_id INT, jugador_id INT, fecha DATE);

DECLARE @i INT = 0, @fase VARCHAR(15), @ln NVARCHAR(50), @en NVARCHAR(50), @dorsal INT, @tipo VARCHAR(8),
        @origen VARCHAR(15), @min SMALLINT, @motivo NVARCHAR(200), @tag VARCHAR(20);
DECLARE @pa INT, @sel INT, @ju INT, @tj INT, @fecha DATE, @ok INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @fase = fase, @ln = local_n, @en = equipo_n, @dorsal = dorsal, @tipo = tipo,
                   @origen = origen, @min = minuto, @motivo = motivo, @tag = tag
    FROM @t WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    SELECT @pa = NULL, @sel = NULL, @ju = NULL, @tj = NULL, @fecha = NULL;
    SELECT @pa = p.partido_id, @fecha = CAST(p.fecha_hora_local AS DATE)
    FROM torneo.partido p JOIN torneo.seleccion s ON s.seleccion_id = p.seleccion_local_id
    WHERE p.fase = @fase AND s.nombre = N'Selección de ' + @ln;
    SELECT @sel = seleccion_id FROM torneo.seleccion WHERE nombre = N'Selección de ' + @en;
    SELECT @ju  = jugador_id FROM torneo.convocatoria WHERE seleccion_id = @sel AND dorsal = @dorsal AND estado = 'VIGENTE';

    SELECT @tj = tarjeta_id FROM torneo.tarjeta
    WHERE partido_id = @pa AND jugador_id = @ju AND tipo = @tipo AND minuto = @min;

    BEGIN TRY
        IF @tj IS NULL
        BEGIN
            EXEC torneo.sp_tarjeta_alta @partidoId = @pa, @jugadorId = @ju, @tipo = @tipo, @origenRoja = @origen,
                                        @minuto = @min, @motivo = @motivo, @tarjetaId = @tj OUTPUT;
            SET @ok += 1;
        END;
        IF @tag IS NOT NULL INSERT INTO #tag (tag, tarjeta_id, jugador_id, fecha) VALUES (@tag, @tj, @ju, @fecha);
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR tarjeta ', @fase, ' ', @en, ' dorsal ', @dorsal, ' ', @tipo, ': ',
                     REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
    END CATCH;
END;
PRINT CONCAT('Tarjetas cargadas: ', @ok);

-- ============================================================================
-- 16. Suspensiones
-- ============================================================================
DECLARE @s TABLE (id INT IDENTITY(1,1), tag VARCHAR(20), motivo NVARCHAR(200), suspendidos TINYINT, cumplidos TINYINT);
INSERT INTO @s (tag, motivo, suspendidos, cumplidos) VALUES
 ('GER_DOBLE',   N'Expulsión por doble amonestación',                  1, 1),   -- cumplida en octavos
 ('BRA_DIRECTA', N'Expulsión por roja directa',                        2, 2),   -- cumplida en octavos y cuartos
 ('ARG_Y2',      N'Acumulación de 2 amarillas en partidos distintos',  1, 0);   -- ACTIVA: se pierde la semifinal

DECLARE @k INT = 0, @mot NVARCHAR(200), @susp TINYINT, @cum TINYINT, @tarj INT, @jug INT, @sid INT, @oks INT = 0;
WHILE 1 = 1
BEGIN
    SELECT TOP (1) @k = id, @tag = tag, @mot = motivo, @susp = suspendidos, @cum = cumplidos
    FROM @s WHERE id > @k ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    SELECT @tarj = NULL, @jug = NULL, @fecha = NULL;
    SELECT @tarj = tarjeta_id, @jug = jugador_id, @fecha = fecha FROM #tag WHERE tag = @tag;
    IF @tarj IS NULL
    BEGIN
        PRINT CONCAT('Sin tarjeta de origen para ', @tag, ' (revisar los mensajes de error anteriores).');
        CONTINUE;
    END;
    IF EXISTS (SELECT 1 FROM torneo.suspension WHERE tarjeta_origen_id = @tarj) CONTINUE;

    BEGIN TRY
        EXEC torneo.sp_suspension_alta @jugadorId = @jug, @tarjetaOrigenId = @tarj, @motivo = @mot,
                                       @fechaInicio = @fecha, @partidosSuspendidos = @susp,
                                       @partidosCumplidos = @cum, @suspensionId = @sid OUTPUT;
        SET @oks += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR suspension ', @tag, ': ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
    END CATCH;
END;
PRINT CONCAT('Suspensiones cargadas: ', @oks);

DROP TABLE #tag;
GO
-- ============================================================================
-- 17. Publicidad por partido
-- ============================================================================
DECLARE @asig TABLE (id INT IDENTITY(1,1), partido_id INT, pieza_id INT, espacio TINYINT,
                     tarifa_id INT, momento DATETIME2(0), importe DECIMAL(12,2), moneda VARCHAR(10));

;WITH cand AS (
    SELECT p.partido_id, p.fase, p.fecha_hora_utc, pz.pieza_id,
           MAX(CASE WHEN pp.pais_id IN (sl.pais_id, sv.pais_id) THEN 1 ELSE 0 END) AS objetivo_equipos,
           MAX(pa.pbi_per_capita) AS pbi,
           MAX(CASE WHEN DATEPART(HOUR, CAST((p.fecha_hora_utc AT TIME ZONE 'UTC') AT TIME ZONE pa.huso_horario AS DATETIME2(0)))
                         BETWEEN 19 AND 22 THEN 1 ELSE 0 END) AS prime
    FROM torneo.partido p
    JOIN torneo.seleccion sl ON sl.seleccion_id = p.seleccion_local_id
    JOIN torneo.seleccion sv ON sv.seleccion_id = p.seleccion_visitante_id
    CROSS JOIN publicidad.pieza_publicitaria pz
    JOIN publicidad.campania c ON c.campania_id = pz.campania_id
                              AND CAST(p.fecha_hora_local AS DATE) BETWEEN c.fecha_inicio AND c.fecha_fin
    JOIN publicidad.pieza_pais pp ON pp.pieza_id = pz.pieza_id
    JOIN torneo.pais pa ON pa.pais_id = pp.pais_id
    GROUP BY p.partido_id, p.fase, p.fecha_hora_utc, pz.pieza_id
), rk AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY partido_id
                                 ORDER BY objetivo_equipos DESC, pbi DESC, prime DESC, pieza_id) AS espacio
    FROM cand
)
INSERT INTO @asig (partido_id, pieza_id, espacio, tarifa_id, momento, importe, moneda)
SELECT r.partido_id, r.pieza_id, r.espacio, t.tarifa_id, r.fecha_hora_utc, t.importe, t.moneda
FROM rk r
JOIN publicidad.tarifa_publicidad t ON t.fase = r.fase AND t.espacio = r.espacio
WHERE r.espacio <= 4;

DECLARE @i INT = 0, @pa INT, @pz INT, @esp TINYINT, @tar INT, @mom DATETIME2(0), @imp DECIMAL(12,2), @mon VARCHAR(10);
DECLARE @id INT, @ok INT = 0, @err INT = 0;

WHILE 1 = 1
BEGIN
    SELECT TOP (1) @i = id, @pa = partido_id, @pz = pieza_id, @esp = espacio, @tar = tarifa_id,
                   @mom = momento, @imp = importe, @mon = moneda
    FROM @asig WHERE id > @i ORDER BY id;
    IF @@ROWCOUNT = 0 BREAK;

    IF EXISTS (SELECT 1 FROM publicidad.publicidad_partido WHERE partido_id = @pa AND espacio = @esp) CONTINUE;

    BEGIN TRY
        EXEC publicidad.sp_publicidad_partido_alta
             @partidoId = @pa, @piezaId = @pz, @tarifaId = @tar, @momentoEmision = @mom,
             @espacio = @esp, @importeFacturado = @imp, @moneda = @mon, @publicidadId = @id OUTPUT;
        SET @ok += 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('ERROR partido ', @pa, ' espacio ', @esp, ': ', REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '));
        SET @err += 1;
    END CATCH;
END;
PRINT CONCAT('Publicidades cargadas: ', @ok, ' | errores: ', @err);
GO
