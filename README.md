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

Sistema centralizado, desarrollado íntegramente en **T-SQL sobre Microsoft SQL Server**, para gestionar la operación de los partidos del Mundial de Fútbol: sedes y fixture, selecciones y convocatorias, formaciones, cambios, goles, tarjetas y suspensiones, designaciones arbitrales y asignación de pauta publicitaria por partido. Incluye importación de datos externos (CSV/XML/Excel), reportes y su presentación en una plataforma de BI.

## Estado de las entregas

| Entrega | Contenido | Estado | Ubicación |
|---|---|---|---|
| 1 y 2 | Informes de costos On-Premise y Cloud | Individuales (se envían por Teams) | `NULL` |
| 3 | Diagrama de Entidad Relación | Entregada | [`docs/entrega-03_DER/`](docs/entrega-03_DER/) |
| 4 | Instalación y configuración de SQL Server | Entregada | [`docs/entrega-04_instalacion/`](docs/entrega-04_instalacion/) |
| 5 | Base de datos (tablas, SPs, validaciones, lógica de negocio) | Entregada | [`sql/`](sql/) |
| 6 | Procesos de importación | Entregada | [`sql/05_importacion/`](sql/05_importacion/) |
| 7 | Reportes | Entregada | [`sql/06_reportes/`](sql/06_reportes/) |
| 8 | Seguridad y respaldo | Entregada | [`sql/07_seguridad/`](sql/07_seguridad/) y [`docs/entrega-08_seguridad-backup/`](docs/entrega-08_seguridad-backup/) |
| 9 | BI y aplicación ABM | Pendiente | [`bi/`](bi/), [`app/`](app/), y [`docs/entrega-09_bi-app/`](docs/entrega-09_bi-app/) |

## Estructura del repositorio

```
/
├── app/                        Aplicación ABM en C#
├── bi/                         Evidencia del dashboard funcional en Metabase
├── docs/                       Documentación general y específica
├── sql/                        Solución de SSMS (.ssmssln) con todos los scripts
│   ├── 01_estructura/          Base de datos, esquemas, tablas y restricciones
│   ├── 02_funciones_vistas/    Algunas Inline utilizadas en los SP, y vistas de BI
│   ├── 03_abm/                 SPs de alta, baja y modificación
│   ├── 04_logica-negocio/      SPs transaccionales de lógica de negocio
│   ├── 05_importacion/         SPs de importación (separados del resto)
│   ├── 06_reportes/            Representaciones necesarias para entrega 7
│   ├── 07_seguridad/           Cifrado, roles, y usuarios mínimos
│   ├── 08_seed/                Datos de carga (criterios de aceptación)
│   ├── datasets/               Archivos de datos utilizados en importación
│   ├── tests/                  Testing, 1:1 con cada script de SP
│   └── reconstruir_bd.bat      Utilidad para evadir ejecución 1 por 1 de scripts
├── README.md
└── .gitignore
```

## Cómo ejecutar el proyecto desde cero

**Requisitos**

- Microsoft SQL Server `<versión / edición>` (ver [instalación y configuración](docs/entrega-04_instalacion/)).
- SQL Server Management Studio (SSMS) `<versión>`.
- Permisos de administrador sobre la instancia.

**Pasos**

1. Clonar el repositorio y abrir `sql/<nombre>.ssmssln` en SSMS.
2. Ejecutar los scripts **en el orden indicado por carpeta y prefijo numérico** (de `01_estructura` a `08_seed`); puede valerse del archivo por lotes proveido en el directorio `sql/`. Los scripts verifican la existencia de los objetos antes de crear o borrar, por lo que pueden ejecutarse más de una vez.

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
| 23 | `sql/05_importacion/22_sp_importar_paises_csv.sql` |
| 24 | `sql/05_importacion/23_sp_importar_fixture_csv.sql` |
| 25 | `sql/05_importacion/24_sp_importar_plantillas_csv.sql` |
| 26 | `sql/05_importacion/25_sp_importar_arbitros_xml.sql` |
| 27 | `sql/05_importacion/26_sp_importar_sedes_wikipedia.sql` |
| 28 | `sql/05_importacion/27_sp_importar_arbitros.sql` |
| 29 | `sql/06_reportes/28_sp_goleadores.sql` |
| 30 | `sql/06_reportes/29_sp_tarjetas_suspensiones.sql` |
| 31 | `sql/06_reportes/30_sp_designaciones_arbitrales.sql` |
| 32 | `sql/06_reportes/31_sp_publicidad_sede.sql` |
| 33 | `sql/06_reportes/32_sp_matriz_primetime.sql` |
| 34 | `sql/06_reportes/33_sp_selecciones_plantilla_xml.sql` |
| 35 | `sql/06_reportes/34_sp_resultados_xml.sql` |
| 36 | `sql/07_seguridad/35_seguridad_cifrado.sql` |
| 37 | `sql/07_seguridad/36_seguridad_roles.sql` |
| 38 | `sql/07_seguridad/37_seguridad_usuarios.sql` |

> *Los scripts de seed_inicial están deprecados, y hay un script en particular que es una segunda opción para otro. Además, los scripts de testing no son mandatorios para reconstruir la base de datos. Ergo, todos ellos no se incluyen en la secuencia*.

## Probar los objetos

- Si se desea probar los distintos procedimientos de la base de datos, ejecutar los scripts de `sql/tests/` para validar el comportamiento. Cada uno indica en comentarios el resultado esperado.
- Algunos scripts de test pueden modificar los datos cargados, si se desea reiniciar la base de datos se recomienda volver a ejecutar el script 00.

## Convenciones

- **Nomenclatura** de tablas, SPs y variables: ver [`docs/norma-nomenclatura.md`](docs/norma-nomenclatura.md).
- **Scripts:** prefijo de dos dígitos para el orden de ejecución; encabezado con universidad, materia, integrantes, fecha y objetivo.
- **Fuentes de datos**: ver [`sql/datasets/`](sql/datasets/) y enlaces en [`docs/cambios-y-decisiones.md`](docs/cambios-y-decisiones.md).
- **Registro de cambios y consideraciones:** se irán volcando las consideraciones necesarias en [`docs/cambios-y-decisiones.md`](docs/cambios-y-decisiones.md).