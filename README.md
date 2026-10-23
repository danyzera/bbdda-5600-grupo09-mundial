# Sistema de Registro y Gestión del Mundial de Fútbol

**Universidad Nacional de La Matanza**<br>
**Materia:** 3641 – Bases de Datos Aplicada<br>
**Comisión:** 5600<br>
**Grupo:** 9<br>

## Integrantes

| Apellido y nombre | Usuario de GitHub |
|---|---|
| Dugo Daniel | danyzera |
| Gauto Gastón Santiago | GastonGauto |
| Garbaccio Francisco Gastón | Garbaaa |
| Andino Máximo | MaximoA04 |

---

## Descripción

Sistema centralizado, desarrollado íntegramente en **T-SQL sobre Microsoft SQL Server**, para gestionar la operación de los partidos del Mundial de Fútbol: sedes y fixture, selecciones y convocatorias, formaciones, cambios, goles, tarjetas y suspensiones, designaciones arbitrales y asignación de pauta publicitaria por partido. Incluye importación de datos externos (CSV/XML/Excel, scraping y APIs), reportes y su presentación en una plataforma de BI.

## Estado de las entregas

| Entrega | Contenido | Estado | Ubicación |
|---|---|---|---|
| 1 y 2 | Informes de costos On-Premise y Cloud | Individuales (se envían por Teams) | `NULL` |
| 3 | Diagrama de Entidad Relación | Entregada | [`docs/entrega-03_DER/`](docs/entrega-03_DER/) |
| 4 | Instalación y configuración de SQL Server | Entregada | [`docs/entrega-04_instalacion/`](docs/entrega-04_instalacion/) |
| 5 | Base de datos (tablas, SPs, validaciones, lógica de negocio) | En desarrollo | [`sql/`](sql/) |
| 6 | Procesos de importación | En desarrollo | [`sql/05_importacion/`](sql/05_importacion/) |
| 7 | Reportes | Pendiente | [`sql/06_reportes/`](sql/06_reportes/) |
| 8 | Seguridad y respaldo | Pendiente | [`sql/07_seguridad/`](sql/07_seguridad/) |
| 9 | BI y aplicación ABM | Pendiente | [`bi/`](bi/), [`app/`](app/) |

Cada entrega queda marcada con un tag de Git (`entrega-03`, `entrega-04`, ...).

## Estructura del repositorio

```
/
├── README.md
├── .gitignore
├── docs/                       Documentación por entrega, norma de nomenclatura y fuentes
├── sql/                        Solución de SSMS (.ssmssln) con todos los scripts
│   ├── 01_estructura/          Base de datos, esquemas, tablas y restricciones
│   ├── 02_funciones_vistas/    Algunas Inline utilizadas en los SP, y vistas de estadísticas y demás
│   ├── 03_ABM/                 SPs de alta, baja y modificación
│   ├── 04_logica-negocio/      SPs transaccionales de lógica de negocio
│   ├── 05_importacion/         SPs de importación (separados del resto)
│   ├── 06_reportes/            Matrices y presentaciones de los datos pertinentes a la entrega 7
│   ├── 07_seguridad/           Cifrado y roles
│   ├── 08_seed/                Datos de carga (criterios de aceptación)
│   └── tests/                  Testing, 1:1 con cada script de SP
├── data/                       Archivos de ejemplo CSV/XML/Excel, sin modificar
├── scraping/                   Resultados y documentación del scraping
├── bi/                         Tablero de BI
└── app/                        Aplicación ABM
```

## Cómo ejecutar el proyecto desde cero

**Requisitos**

- Microsoft SQL Server `<versión / edición>` (ver [instalación y configuración](docs/entrega-04_instalacion/)).
- SQL Server Management Studio (SSMS) `<versión>`.
- Permisos de administrador sobre la instancia.

**Pasos**

1. Clonar el repositorio y abrir `sql/<nombre>.ssmssln` en SSMS.
2. Ejecutar los scripts **en el orden indicado por carpeta y prefijo numérico** (de `01_estructura` a `08_seed`). Los scripts verifican la existencia de los objetos antes de crear o borrar, por lo que pueden ejecutarse más de una vez.


**Orden de ejecución completo**

> *Eliminar la Base de Datos en su totalidad antes de comenzar no es necesario, porque el script de creación es de carácter idempotente o destructivo a priori*.

| Orden | Script | Objetivo |
|---|---|---|
| 1 | `sql/01_estructura/00_crear_bd_y_esquemas.sql` |
| 2 | `sql/01_estructura/01_crear_tablas.sql` |
| 3 | `sql/02_funciones_vistas/02_crear_funciones_reutilizables.sql` |
| 4 | `sql/02_funciones_vistas/03_crear_vistas.sql` |
| 5 | `sql/03_abm/04_sp_alta_torneo.sql` |
| 6 | `sql/03_abm/05_sp_alta_arbitraje.sql` |
| 7 | `sql/03_abm/06_sp_alta_publicidad.sql` |
| 8 | `sql/03_abm/07_sp_baja_torneo.sql` |
| 9 | `sql/03_abm/08_sp_baja_arbitraje.sql` |
| 10 | `sql/03_abm/09_sp_baja_publicidad.sql` |
| 11 | `sql/03_abm/10_sp_modificacion_torneo.sql` |
| 12 | `sql/03_abm/11_sp_modificacion_arbitraje.sql` |
| 13 | `sql/03_abm/12_sp_modificacion_publicidad.sql` |
| 14 | `sql/04_logica-negocio/13_sp_partido_iniciar.sql` |
| 15 | `sql/04_logica-negocio/14_sp_gol_registrar.sql` |
| 16 | `sql/04_logica-negocio/15_sp_tarjeta_registrar.sql` |
| 17 | `sql/04_logica-negocio/16_sp_cambio_registrar.sql` |
| 18 | `sql/04_logica-negocio/17_sp_partido_finalizar.sql` |
| 19 | `sql/04_logica-negocio/18_sp_convocatoria_reemplazar.sql` |
| 20 | `sql/04_logica-negocio/19_sp_terna_arbitral_designar.sql` |
| 21 | `sql/04_logica-negocio/20_sp_publicidad_partido_asignar.sql` |
| 22 | `sql/04_logica-negocio/21_sp_alineacion_cargar.sql` |

## Probar los objetos

- Si se desea probar los distintos procedimientos de la base de datos, ejecutar los scripts de `sql/tests/` para validar el comportamiento. Cada uno indica en comentarios el resultado esperado.
- Algunos scripts de test pueden modificar los datos cargados, si se desea reiniciar la base de datos se recomienda volver a ejecutar el script 00.

## Configuración local (claves y rutas)

- **No se suben claves de API ni credenciales.** Los scripts que consumen APIs con clave (por ejemplo football-data.org) usan el marcador `<API_KEY>`; reemplazarlo localmente sin commitear el cambio.
- Los archivos de importación se encuentran en `data/`. El nombre del archivo es un parámetro de cada SP de importación; la ruta absoluta debe ajustarse al entorno local `<documentar la ruta esperada>`.

## Convenciones

- **Nomenclatura** de tablas, SPs y variables: ver [`docs/norma-nomenclatura.md`](docs/norma-nomenclatura.md).
- **Scripts:** prefijo de dos dígitos para el orden de ejecución; encabezado con universidad, materia, integrantes, fecha y objetivo.
- **Fuentes de datos, APIs y scraping** (incluyendo límites de uso): ver [`docs/fuentes-datos-y-apis.md`](docs/fuentes-datos-y-apis.md).
- **Flujo de trabajo:** cada integrante trabaja con su propia cuenta de GitHub, directamente sobre la rama main o sobre sus ramas propias y generando pull requests.
- **Registro de cambios y consideraciones:** se irán volcando las consideraciones necesarias en [`docs/cambios-y-decisiones.md`](docs/cambios-y-decisiones.md).