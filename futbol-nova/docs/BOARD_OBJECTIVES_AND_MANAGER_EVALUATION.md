# Fútbol Nova — objetivos de la junta directiva y evaluación del entrenador

**Estado:** requisito confirmado por el usuario; diseño funcional documentado. Implementación y pruebas pendientes.
**Ámbito:** Modo Manager cuando el usuario elige el perfil **Entrenador**.
**Referencia:** captura aportada el 14-11-2026 de una pantalla de objetivos de junta directiva con pestañas «A corto plazo» y «De temporada».

## 1. Regla principal

Cuando el usuario inicia una carrera Manager y elige **Entrenador**, queda sujeto a los objetivos deportivos e institucionales establecidos por la junta directiva del club. Debe cumplirlos durante la temporada. Los objetivos no son decorativos: su progreso se calcula con los resultados y eventos reales registrados por el motor común de partidos y competiciones.

Elegir **Presidente** mantiene la separación de responsabilidades definida en MANAGER_GOVERNANCE_AND_CLUB_CREATION.md: el presidente administra el club y puede establecer, aprobar o revisar las metas institucionales; no se evalúa a sí mismo como entrenador. Si el usuario es propietario de un club creado y elige Entrenador, la propiedad no lo exime de la evaluación deportiva de la junta.

## 2. Centro de objetivos de la directiva

El hub del Modo Entrenador tendrá un apartado **Directiva**, con dos vistas principales:

- **A corto plazo:** objetivos de varios partidos o acciones concretas. Al completarse, se actualizan automáticamente y la directiva puede asignar nuevos objetivos compatibles con el calendario.
- **De temporada:** objetivos que se evalúan durante toda la temporada o hasta una fecha/hito establecido. No se reinician al completar un objetivo corto.

Cada tarjeta de objetivo mostrará:
- Descripción clara y condición exacta de cumplimiento.
- Progreso actual y objetivo requerido (por ejemplo, 0/4).
- Plazo o partidos restantes, cuando corresponda.
- Estado: bloqueado, disponible, en curso, completado, fallido o caducado.
- Importancia/prioridad asignada por la junta.
- Consecuencia deportiva/contractual y efecto previsto en la confianza de la directiva.
- Historial de actualización y eventos que cuentan para el progreso.

El progreso se actualiza automáticamente al registrarse el evento pertinente; no exige reclamar manualmente el objetivo.

## 3. Ejemplos de objetivos a corto plazo

La captura de referencia aporta estos ejemplos, que se adaptarán al contexto y al reglamento de Fútbol Nova:

1. **Disciplina:** no recibir tarjetas amarillas ni rojas durante 4 partidos.
2. **Ataque:** marcar al menos un gol en cada uno de los dos tiempos en 6 partidos.
3. **Juventud:** alinear como titulares al menos 3 jugadores menores de 25 años en un mismo partido.

Son ejemplos de diseño, no una lista fija para todos los clubes. El generador debe comprobar que el objetivo sea posible con la plantilla, el calendario, las reglas y la situación del equipo. La edad se calcula en la fecha del partido. «Marcar en ambas partes» requiere al menos un gol del equipo en cada tiempo reglamentario; los goles de prórroga no sustituyen ese requisito.

## 4. Objetivos de temporada

La junta podrá establecer metas acordes con la categoría, reputación, plantilla, presupuesto, historial y situación inicial del club. Familias previstas:

- **Resultados y clasificación:** posición final, puntos, ascenso, permanencia, clasificación continental o rendimiento en copas.
- **Rendimiento del equipo:** goles, porterías a cero, diferencia de goles, rachas o rendimiento como local/visitante.
- **Disciplina y conducta:** límites razonables de tarjetas o sanciones.
- **Desarrollo juvenil:** minutos, convocatorias o promoción de jugadores de cantera.
- **Gestión deportiva:** uso equilibrado de plantilla, cumplimiento de límites de inscripción y objetivos de fichajes cuando sean responsabilidad del entrenador.
- **Reputación y estilo:** metas contextuales que puedan medirse con estadísticas reales, nunca juicios vagos sin criterios.

No todos los clubes recibirán todas las categorías. La junta seleccionará un conjunto limitado y coherente de objetivos, con prioridades diferenciadas.

## 5. Evaluación y consecuencias

- Cada objetivo aporta evidencia a una evaluación global de la junta; no se decide el futuro del entrenador por un único objetivo aislado.
- La evaluación considera importancia, dificultad, progreso, plazo, resultados generales, contexto del club y cumplimiento contractual.
- Cumplir objetivos mejora la confianza de la directiva y puede favorecer renovaciones, primas contractuales u ofertas futuras si esas funciones están disponibles.
- Incumplir objetivos reduce la confianza de forma proporcional a su importancia y al contexto. Un objetivo imposible por una lesión masiva, sanción reglamentaria o cambio extraordinario de calendario debe revisarse o cancelarse con motivo registrado.
- La baja confianza puede activar advertencias, reuniones, exigencias de mejora, revisión contractual y, en casos graves o persistentes, despido conforme al contrato e indemnización aplicable.
- No habrá despido instantáneo por fallar una meta secundaria ni protección automática por ser propietario del club.
- Los resultados deportivos, las finanzas y las responsabilidades de cada cargo se evalúan por separado. El entrenador no debe ser penalizado por decisiones económicas que pertenecen al presidente, salvo que el contrato le asigne expresamente esa responsabilidad.

## 6. Generación justa y actualización

- Generar los objetivos al inicio de la carrera/temporada y cuando corresponda renovar el conjunto de metas cortas.
- Usar dificultad y expectativas acordes al club; no exigir a un recién ascendido objetivos propios de un favorito al título.
- No generar metas contradictorias (por ejemplo, reducir salarios y exigir fichajes costosos sin presupuesto disponible).
- Validar que existan partidos suficientes antes del vencimiento.
- Los objetivos por partido cuentan solo encuentros oficiales o amistosos según lo indique la tarjeta.
- Los partidos abandonados, anulados o no disputados no cuentan como cumplidos; aplicar las reglas de competición para resultados administrativos.
- El motor de objetivos consume eventos y resultados del contrato común de partido, competiciones, calendario, plantilla y disciplina. No mantiene estadísticas duplicadas.
- Guardar el estado, progreso, fechas, origen de cada actualización y versión del esquema para poder reanudar la carrera offline.

## 7. Recompensas y economía

La captura muestra iconos y cantidades de recompensa, pero la moneda global de Fútbol Nova continúa sin decidirse en los requisitos económicos. Por tanto:

- El sistema puede conceder reconocimiento, confianza de la directiva y efectos contractuales ya definidos.
- Las recompensas monetarias solo se habilitarán cuando se apruebe la moneda y se integren con el libro mayor y el presupuesto del club.
- No crear una moneda paralela, moneda premium, energía, anuncios obligatorios ni recompensas de Ultimate Team a partir de la captura.
- Toda bonificación económica debe tener concepto, fecha, importe y asiento en el libro mayor.

## 8. Datos y pruebas de aceptación

Cada objetivo tendrá como mínimo: `id`, `career_id`, `club_id`, `category`, `scope` (short_term/season), `description_key`, `target`, `progress`, `start_date`, `deadline`, `status`, `priority`, `source_event_types`, `board_trust_impact`, `created_by` y `schema_version`.

Pruebas obligatorias:
1. Solo el perfil Entrenador recibe evaluación laboral de la junta; el perfil Presidente conserva sus permisos de gobierno.
2. Un partido sin tarjetas incrementa correctamente el progreso del objetivo disciplinario; una amarilla o roja rompe la condición si así está definida.
3. Un gol en cada tiempo suma un partido válido al objetivo de marcar en ambas partes; dos goles en un solo tiempo no lo cumplen.
4. Tres titulares menores de 25 años en el mismo once cumplen el objetivo juvenil; suplentes o jugadores de 25 años exactos no cuentan.
5. Completar un objetivo corto lo cierra una sola vez y genera el siguiente sin duplicados.
6. Los objetivos de temporada conservan progreso entre jornadas y competiciones.
7. Un objetivo imposible o invalidado se revisa con causa y sin penalización injusta.
8. La confianza de la directiva, las advertencias y el eventual despido son deterministas/reproducibles con los mismos eventos y guardado.
9. Guardar y cargar la carrera conserva exactamente objetivos, progreso, plazos e historial.
10. Los eventos de partidos jugados y simulados producen el mismo resultado de evaluación.

**Límite actual:** el repositorio aún no acredita un sistema Manager completo ni ejecución de pruebas en Godot. Este documento define el comportamiento requerido; no afirma que la función ya esté implementada.
