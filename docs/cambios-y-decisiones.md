# Seed data: carga mediante stored procedures

## [17-10-2026]

**Decisión.** El seed se carga llamando a los SP de ABM, no con `INSERT` directo.

**Motivo.**
- Pasa por las mismas validaciones que cualquier otro consumidor (aplicación, importación), así que no puede generar estados inválidos.

**Cómo.**
- `EXEC` explícitos, en el orden del flujo real. Los IDs se capturan por `OUTPUT`; no se asumen valores de `IDENTITY`.
- Los casos de rechazo (p. ej. árbitro del mismo país) no están en el seed, sino en los scripts de testing de validaciones, porque el seed debe terminar con datos válidos.
- Datos de referencia (confederaciones, fases, tipos de gol/tarjeta).

**Fuente de los datos.** Parámetros: documento de reglamento del torneo, que se encuentra en https://www.fifa.com/es/tournaments/mens/worldcup/canadamexicousa2026/organisation. Huso horario de Windows: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11. Selecciones, grupos, convocados, y DTs provienen de https://fdp.fifa.org/assetspublic/ce281/pdf/SquadLists-English.pdf, https://www.fifa.com/es/tournaments/mens/worldcup/canadamexicousa2026/articles/fase-grupos-copa-mundial-2026-partidos-zonas. Estadios y sedes de [URL]. PBI per cápita para publicidad: https://data.worldbank.org/indicator/NY.GDP.PCAP.CD. Los datos de escenarios (eventos, tarjetas) son inventados para cubrir los casos obligatorios.

**Costo aceptado.**
- Si cambia un SP (campo nuevo o validación más estricta), hay que actualizar el seed.
- Una llamada por fila: suficiente para este volumen, no para pruebas de carga.

# SPs de lógica de negocio

## [17-10-2026]

**Decisión.** Los SPs de lógica de negocio tienen como precondición, para su creación, haber creado los SPs de ABM. La lógica de negocio implica ABM sobre diversas tablas; quizás más de una en la misma operación. Luego, toda inserción/actualización/eliminación que se haría dentro de la lógica de negocio, debe estar embebida por requisito explícito del proyecto en un SP de ABM previamente generado.

**Motivo.**
- Requisito explícito del enunciado: "Ninguna operación de alta, baja o modificación debe requerir el acceso directo a la tabla; todas deben estar encapsuladas en stored procedures".

**Cómo.**
- `EXEC` con los parámetros que se le pasen al SP de lógica de negocio ya validados.

**Costo aceptado.**
- Existe la posibilidad de que se pierda solo un poco la trazabilidad de los errores, porque si falla el ABM encapsulado en el SP de lógica de negocio, el error que se lanza a la capa superior es el error correspondiente al ABM, con su código asociado. Sin embargo, lo consideramos aceptable porque sigue la convención de lanzar el error del SP que falló.