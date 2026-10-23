# Norma de nomenclatura — MundialDB

| | |
|---|---|
| Universidad | Universidad Nacional de La Matanza (UNLaM) |
| Materia | 3641 – Bases de Datos Aplicada |
| Comisión / Grupo | 5600 / 09 |
| Integrantes | Dugo Daniel (danyzera) · Gauto Gastón Santiago (GastonGauto) · Garbaccio Francisco Gastón (Garbaaa) · Andino Máximo (MaximoA04) |
| Fecha | 09/10/2026 |
| Versión | 1.0 |

Este documento define cómo se nombran los objetos de la base de datos `MundialDB`, los
parámetros y variables de T-SQL, los códigos de error y los archivos del repositorio.


## 1. Resumen

| Objeto | Formato | Ejemplo |
|---|---|---|
| Base de datos | PascalCase | `MundialDB` |
| Esquema | minúscula, una palabra, sin tildes | `torneo` |
| Tabla | `esquema.nombre_en_singular` (snake_case) | `torneo.cuerpo_tecnico` |
| Columna | snake_case | `fecha_hora_utc` |
| Clave primaria (columna) | `<núcleo de la entidad>_id` | `cuerpo_id` |
| Clave foránea (columna) | igual que la PK que referencia, con rol si hace falta | `jugador_asistente_id` |
| Constraint PK | `PK_<tabla>` | `PK_pais` |
| Constraint FK | `FK_<tabla>_<columna FK sin _id>` | `FK_partido_seleccion_local` |
| Constraint UQ | `UQ_<tabla>_<campos>` | `UQ_pais_codigo_iso` |
| Constraint CK | `CK_<tabla>_<columna o regla>` | `CK_sede_capacidad` |
| Constraint DF | `DF_<tabla>_<columna>` | `DF_partido_estado` |
| Índice | `IX_<tabla>_<descripción>` | `IX_convocatoria_jugador_vigente` |
| SP de ABM | `<esquema>.sp_<tabla>_<alta\|baja\|modificacion>` | `torneo.sp_pais_alta` |
| SP de lógica de negocio | `<esquema>.sp_<entidad>_<verbo en infinitivo>` | `torneo.sp_partido_cerrar` |
| Parámetro / variable | `@camelCase` | `@codigoIso` |
| Tabla en memoria | `@PascalCase` | `@SuspensionesParaActualizar` |
| Valor de dominio | `MAYUSCULAS_CON_GUION_BAJO` | `TERCER_PUESTO` |
| Código de error | `50000 + operación·1000 + esquema·100 + orden` | `50203` |


## 2. Principios generales

1. Idioma español. Se aceptan términos técnicos consagrados en inglés (`log`, `email`, `utc`).
2. Sin tildes ni eñe en identificadores. `campania`, `pbi_anio`, `seleccion`, `designacion`.
   Las tildes solo se usan dentro de textos (mensajes de error, comentarios).
3. Singular para nombres de tablas.
4. Lo que vive en el modelo de datos (esquemas, tablas, columnas) va
   en `snake_case`; lo que vive en el código T-SQL (parámetros y variables) va en `camelCase`.
5. Algunas abreviaturas: `id`, `utc`, `iso`, `pbi`, `fifa`. Fuera de esa lista no se abrevia.
6. **Todo constraint e índice se nombra explícitamente.** Nunca se dejan nombres autogenerados.