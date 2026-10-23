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

# SPs de lógica de negocio: flujo estándar de procedimientos

## [17-10-2026]

El flujo habitual de aplicación de los SPs transaccionales se divide claramente en cuatro fases.

### 1. Flujo de preparación pre-partido (setup y validaciones)

Antes de que la pelota ruede, el sistema debe garantizar que el partido cumple con todas las reglas de la FIFA y los requerimientos comerciales de la consigna. En esta etapa, el partido se encuentra en estado PROGRAMADO.

* `torneo.sp_convocatoria_reemplazar` (Eventual): Si ocurre una lesión grave en los días previos, o algún reemplazo no esperado, este SP actúa primero. De forma transaccional, da de baja al jugador lesionado, ingresa al reemplazo respetando el dorsal y el tope máximo del plantel, y deja el registro de auditoría.

* `arbitraje.sp_terna_arbitral_designar` (Obligatorio): Se asignan los jueces para el encuentro. El SP validará reglas críticas del negocio, como el **rechazo automático si existe un conflicto de nacionalidad entre el árbitro principal y las selecciones que juegan**.

* `publicidad.sp_publicidad_partido_asignar` (Obligatorio): El motor comercial evalúa el huso horario de la sede y asigna exactamente 4 espacios publicitarios simultáneos (pauta) a los anunciantes según el prime time y su PBI.

* `torneo.sp_alineacion_cargar` (Obligatorio): Los directores técnicos confirman el esquema táctico. Este SP orquesta las altas para definir quiénes son los 11 jugadores titulares que van al campo y quiénes ocuparán el banco de suplentes.

### 2. Flujo de comienzo de partido

* `torneo.sp_partido_iniciar` (Crítico - Puerta de enlace): Este es el SP principal de esta fase, porque justamente habilita los sucesivos. Su trabajo es verificar que los tres pasos anteriores se cumplieron (hay árbitros, hay 4 publicidades, y hay 22 jugadores titulares en el campo). Si la integridad es correcta, cambia el estado del partido a EN_CURSO. Este SP es una condición ineludible; sin él, el sistema debe bloquear cualquier intento de registrar goles o incidencias.

### 3. Flujo de incidencias en vivo

Con el partido EN_CURSO, se habilita la carga de eventos dinámicos. Estos SPs transaccionales pueden llamarse en cualquier orden según lo que ocurra en la cancha, pero todos dependen de que sp_partido_iniciar haya habilitado el partido.

* `torneo.sp_gol_registrar`: Inserta el gol en la tabla de incidencias, validando minuto y período, y vinculando al autor (y opcionalmente al asistente). En este punto, la tabla cabecera del partido aún no consolida el resultado.

* `torneo.sp_tarjeta_registrar`: Registra las infracciones. Contiene lógica de negocio profunda: si inserta una roja directa, o si al insertar una amarilla el jugador alcanza el límite (AMARILLAS_PARA_SUSPENSION), el SP dispara automáticamente el cálculo y la inserción en la tabla de suspensiones. La lógica de disparo de suspensión es fundamental, porque recae prácticamente completamente en este SP.

* `torneo.sp_cambio_registrar`: Registra las sustituciones. Valida que el equipo no exceda el máximo de cambios ni de ventanas permitidas según el reglamento, y transaccionalmente saca al jugador del campo para ingresar al suplente.

### 4. Flujo de cierre y consolidación (post partido)

* `torneo.sp_partido_finalizar` (Crítico - Cierre): Cuando el árbitro dictamina el final, se ejecuta este SP. En lugar de recibir los goles tipeados por un usuario, el SP cuenta los registros generados por `sp_gol_registrar` para auto-calcular el resultado final. Cambia el estado a FINALIZADO e internamente avanza el contador de partidos_cumplidos para aquellos jugadores que arrastraban suspensiones.

> **Conclusión**: en síntesis, se acaba de describir la *cohesión transaccional*. No se puede iniciar un partido sin designaciones, pauta ni alineaciones (`sp_partido_iniciar` actúa de barrera). No se pueden cargar eventos si el partido no inició (los SPs de incidencias requieren estado EN_CURSO). No se puede finalizar un partido si no se consolidan primero los datos de la etapa en vivo (`sp_partido_finalizar` recolecta lo sucedido).