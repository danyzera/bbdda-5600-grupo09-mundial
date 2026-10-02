# Sistema de Registro y Gestión del Mundial de Fútbol

**Universidad Nacional de La Matanza**<br>
**Materia:** 3641 – Bases de Datos Aplicada<br>
**Comisión:** 5600<br>
**Grupo:** 9<br>
**Docente asignado:** A definir<br>
**Fecha de última entrega:** -<br>

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
| 1 y 2 | Informes de costos On-Premise y Cloud | Individuales (se envían por Teams) |  |
| 3 | Diagrama de Entidad Relación | Entregada | [`docs/entrega-03_DER/`](docs/entrega-03_DER/) |
| 4 | Instalación y configuración de SQL Server | Entregada | [`docs/entrega-04_instalacion/`](docs/entrega-04_instalacion/) |
| 5 | Base de datos (tablas, SPs, validaciones, lógica de negocio) | En desarrollo | [`sql/`](sql/) |
| 6 | Procesos de importación | Pendiente | [`sql/05_importacion/`](sql/05_importacion/) |
| 7 | Reportes | Pendiente | [`sql/06_reportes/`](sql/06_reportes/) |
| 8 | Seguridad y respaldo | Pendiente | [`sql/07_seguridad/`](sql/07_seguridad/) |
| 9 | BI y aplicación ABM | Pendiente | [`bi/`](bi/), [`app/`](app/) |

Cada entrega queda marcada con un tag de Git (`entrega-03`, `entrega-04`, ...).

## Estructura del repositorio

```
/
├── README.md
├── .gitignore
├── docs/                      Documentación por entrega, norma de nomenclatura y fuentes
├── sql/                       Solución de SSMS (.ssmssln) con todos los scripts
│   ├── 01_estructura/         Base de datos, esquemas, tablas y restricciones
│   ├── 02_abm/                SPs de alta, baja y modificación
│   ├── 03_logica-negocio/     SPs transaccionales de lógica de negocio
│   ├── 04_vistas-funciones/
│   ├── 05_importacion/        SPs de importación (separados del resto)
│   ├── 06_reportes/
│   ├── 07_seguridad/          Cifrado y roles
│   ├── 08_seed/               Datos de carga (criterios de aceptación)
│   └── tests/                 Testing, 1:1 con cada script de SP
├── data/                      Archivos de ejemplo CSV/XML/Excel, sin modificar
├── scraping/                  Resultados y documentación del scraping
├── bi/                        Tablero de BI
└── app/                       Aplicación ABM
```

## Cómo ejecutar el proyecto desde cero

**Requisitos**

- Microsoft SQL Server `<versión / edición>` (ver [instalación y configuración](docs/entrega-04_instalacion/)).
- SQL Server Management Studio (SSMS) `<versión>`.
- Permisos de administrador sobre la instancia.

**Pasos**

1. Clonar el repositorio y abrir `sql/<nombre>.ssmssln` en SSMS.
2. Ejecutar los scripts **en el orden indicado por carpeta y prefijo numérico** (de `01_estructura` a `08_seed`). Los scripts verifican la existencia de los objetos antes de crear o borrar, por lo que pueden ejecutarse más de una vez.
3. Ejecutar los scripts de `sql/tests/` para validar el comportamiento. Cada uno indica en comentarios el resultado esperado.

**Orden de ejecución completo**

| Orden | Script | Objetivo |
|---|---|---|
| 1 | `sql/01_estructura/01_...sql` | `completar a medida que se agreguen scripts` |

## Configuración local (claves y rutas)

- **No se suben claves de API ni credenciales.** Los scripts que consumen APIs con clave (por ejemplo football-data.org) usan el marcador `<API_KEY>`; reemplazarlo localmente sin commitear el cambio.
- Los archivos de importación se encuentran en `data/`. El nombre del archivo es un parámetro de cada SP de importación; la ruta absoluta debe ajustarse al entorno local `<documentar la ruta esperada>`.

## Convenciones

- **Nomenclatura** de tablas, SPs y variables: ver [`docs/norma-nomenclatura.md`](docs/norma-nomenclatura.md).
- **Scripts:** prefijo de dos dígitos para el orden de ejecución; encabezado con universidad, materia, integrantes, fecha y objetivo.
- **Fuentes de datos, APIs y scraping** (incluyendo límites de uso): ver [`docs/fuentes-datos-y-apis.md`](docs/fuentes-datos-y-apis.md).
- **Flujo de trabajo:** cada integrante trabaja con su propia cuenta de GitHub, en ramas propias y mediante pull requests.
