/* ============================================================================
   Universidad : Universidad Nacional de La Matanza (UNLaM)
   Materia     : 3641 - Bases de Datos Aplicada
   Comision    : Com:5600      Grupo:09
   Integrantes : Gauto, Andino, Garbaccio, Dugo
   Fecha       : 06/10/2026
   Script      : 05_sp_matriz_primetime.sql
   Objetivo    : Matriz de Prime Time por mercado (PIVOT Dinámico).
   ============================================================================ */
CREATE OR ALTER PROCEDURE reportes.sp_matriz_primetime
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Columnas NVARCHAR(MAX);
    DECLARE @Query NVARCHAR(MAX);

    -- 1. Construir la lista de columnas dinámicamente consultando los países reales
    -- Resultado esperado: '[ARG],[BRA],[ESP],[USA],[MEX],[FRA]...'
    SELECT @Columnas = STRING_AGG(QUOTENAME(codigo_iso), ',') WITHIN GROUP (ORDER BY codigo_iso)
    FROM (SELECT DISTINCT codigo_iso FROM torneo.pais) AS paises;

    -- Si no hay países cargados, cortamos la ejecución para que no falle la sintaxis
    IF @Columnas IS NULL RETURN;

    -- 2. Armar todo el script SQL dentro de un string, inyectando la variable @Columnas
    SET @Query = N'
    ;WITH base AS (
        SELECT
            p.partido_id,
            p.fase,
            pa.codigo_iso,
            CASE
                WHEN DATEPART(
                    HOUR, (
                        CAST(p.fecha_hora_utc AS DATETIME2)
                        AT TIME ZONE ''UTC''
                        AT TIME ZONE pa.huso_horario
                    )
                ) BETWEEN 19 AND 23
                THEN ''SI''
                ELSE ''NO''
            END AS prime_time
        FROM torneo.partido p
        CROSS JOIN torneo.pais pa
    )
    SELECT
        partido_id,
        fase,
        ' + @Columnas + N'
    FROM base
    PIVOT (
        MAX(prime_time)
        FOR codigo_iso IN (' + @Columnas + N')
    ) p
    ORDER BY partido_id;';

    -- 3. Ejecutar el script dinámico
    EXEC sp_executesql @Query;
END;
GO