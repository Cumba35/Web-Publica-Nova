# Fútbol Nova — Catálogo maestro de datos pendientes

**Propósito:** reunir y completar los datos de diseño y contenido antes de implementar las pantallas.  
**Alcance de esta fase:** documentación, inventario, estructuras de datos y verificación de referencias. **No se crean escenas, interfaces ni navegación en Godot en esta fase.**  
**Referencia visual/funcional principal:** FIFA 23, usando las capturas aportadas y las fuentes de consulta registradas al final. La adaptación tendrá identidad y contenido propios de Fútbol Nova.  
**Exclusiones obligatorias:** Ultimate Team no forma parte del juego. No crear cartas, sobres, monedas UT ni mercado de cartas. No convertir imágenes de referencia de FIFA en recursos distribuibles.

## 1. Reglas maestras ya confirmadas

- El menú raíz tiene exactamente cuatro pantallas: Inicio, Online, Modos y Configuración.
- Desplazamiento horizontal en ambos sentidos, circular, conservando el estado y evitando que gestos dentro de controles activen la navegación raíz.
- Inicio: Continuar, Nueva partida, Amistosos y Entrenamiento.
- Online: servicios de Internet y modalidad local por zona Wi-Fi, siempre distinguiendo los requisitos de conexión.
- Modos: Leyenda, Entrenador, Torneos, Ligas y Copas.
- Configuración: Edición, Módulos, Música, Juego, Datos, Controles, Audio, Gráficos, Accesibilidad, Administración e Información.
- Ultimate Team está excluido. La referencia antigua relacionada se conserva solo como archivo histórico, no como requisito visual ni funcional.
- El juego base debe funcionar sin Internet y sin módulos adicionales.
- Los datos deportivos iniciales serán ficticios. Datos reales requerirán revisión de exactitud, vigencia y derechos de uso.
- La documentación no equivale a implementación. No marcar una función como disponible hasta que exista y haya sido probada.

## 2. Inventario de referencias y qué información extraer

| Referencia disponible | Datos que orienta | Estado |
|---|---|---|
| `assets/references/main-menu-settings-reference.jpg` | Organización de categorías, filas de opciones, foco, valores, ayuda contextual y navegación en Configuración | Imagen archivada; la estructura funcional se detalla en este catálogo |
| `assets/references/pause-menu-reference.jpg` | Acciones de pausa, panel de equipo/formación, datos del partido y jerarquía de opciones | Miniatura archivada; original de mayor resolución pendiente |
| `assets/references/kit-selection-reference.jpg` | Equipaciones local/visitante, selección activa, vistas previas y navegación independiente por equipo | Miniatura archivada; PNG original pendiente |
| `assets/references/legend-mode-home-reference.jpg` | Central de Leyenda, identidad del jugador, progresión, temporada y accesos del modo | Miniatura archivada; original pendiente |
| Referencia de temporada Manager | Calendario, tabla, lesiones, goleadores, estadísticas, próximos encuentros | Descripción documentada; archivo binario pendiente |
| Referencia de ajustes de partido | Duración, dificultad, velocidad, reglas y opciones del encuentro | Descripción documentada; archivo binario pendiente |
| Referencia de ajustes del mando | Asistencias, cambio de jugador, remapeo y comportamiento de controles | Descripción documentada; archivo binario pendiente |
| Captura azul HOME / PLAY / CLUB indicada como Pantalla 3 | Jerarquía del hub principal, navegación, panel destacado, información contextual y accesos | El archivo binario no está disponible en el árbol actual; no afirmar inspección visual completa |
| Referencia antigua de Ultimate Team | Ningún requisito de producto | Excluida; solo archivo histórico |

Las capturas archivadas son referencias de composición y comportamiento. Los valores exactos, textos, marcas, escudos, jugadores, equipaciones y recursos de FIFA no se copian.

## 3. Datos de las cuatro pantallas raíz

### 3.1 Inicio
Datos que debe poder presentar cuando existan:
- Última actividad local: modo, partida/temporada, equipo o jugador, fecha de guardado y acción Continuar.
- Estado de espacios de guardado y compatibilidad.
- Nueva partida: accesos a los modos disponibles sin duplicar sus hubs.
- Amistosos: último emparejamiento, equipos recientes y acceso a crear partido.
- Entrenamiento: último ejercicio o práctica y acceso al centro de entrenamiento.
- Novedades locales: notas de versión, contenido instalado y avisos; no simular noticias en vivo sin servicio.
- Estado de módulos: instalado, disponible para descarga, actualización pendiente, incompatible o desactivado.
- Estado de conectividad cuando una tarjeta dependa de Internet.

Reglas: no mostrar Continue si no existe una partida válida; no inventar eventos, promociones ni actividad remota.

### 3.2 Online
Datos de estado:
- Tipo de conexión: Internet o zona Wi-Fi local.
- Estado del servicio: disponible, conectando, sin conexión, mantenimiento, error recuperable.
- Sala: identificador, anfitrión, participantes, equipos, posiciones, estado listo/no listo y versión compatible.
- Reglas compartidas: método de resolución (votaciones, predeterminado o cooperativo), valores propuestos, votos, resultado final y motivo de cualquier valor predeterminado.
- Calidad de red: latencia/paquetes perdidos solo si el motor puede medirlos.
- Reconexión, abandono y tiempo restante de tolerancia.
- Compatibilidad entre versiones y módulos.

No presentar multijugador por Internet como disponible si no existe backend. La modalidad Wi-Fi local no debe depender de Internet.

### 3.3 Modos
Datos comunes de cada tarjeta:
- ID estable, nombre, descripción, icono/arte original, disponibilidad, requisito de red, partida activa y acción primaria.
- Resumen de progreso y guardado si el modo tiene carrera/temporada.
- Requisitos de versión y contenido, si aplica.

Hubs:
- **Leyenda:** crear/continuar carrera individual.
- **Entrenador:** crear/continuar carrera de club.
- **Torneos:** crear, continuar o abrir torneo personalizado.
- **Ligas y Copas:** modo de clubes o selecciones, catálogo de competición, temporada y clasificación.
- Partido rápido/amistosos y Entrenamiento permanecen accesibles desde Inicio según la estructura confirmada; no añadirlos como pantallas raíz nuevas.

### 3.4 Configuración
Categorías confirmadas y datos que deben organizar:
1. **Edición:** editor de clubes, jugadores, selecciones, equipaciones, escudos originales, estadios, balones y competiciones ficticias; historial de cambios y validación.
2. **Módulos:** nombre, descripción, versión, tamaño, dependencias, compatibilidad, permisos, estado instalado/activo, política de descarga y actualización.
3. **Música:** biblioteca disponible, pista, volumen, reproducción en menús/partido, silencio y política de contenido con licencia.
4. **Juego:** duración, dificultad, velocidad, reglas, comportamiento del reloj, árbitro/VAR y opciones de simulación; respetar bloqueos por modo.
5. **Datos:** perfil local, idioma, importación/exportación, paquetes JSON, integridad, copias y privacidad.
6. **Controles:** perfiles, asignaciones, sensibilidad, zonas táctiles, vibración, ayudas y calibración de mando.
7. **Audio:** música, efectos, ambiente, público, comentaristas, narración, balance y salida disponible.
8. **Gráficos:** calidad, resolución/escala, sombras, efectos, límite de cuadros, sincronización y opciones adaptativas según hardware.
9. **Accesibilidad:** tamaño de texto, contraste, filtros de color, narración, subtítulos, reducción de movimiento, remapeo y ayudas.
10. **Administración:** diagnósticos, almacenamiento, registros, exportación de informes, mantenimiento y acciones protegidas por confirmación.
11. **Información:** versión, créditos, licencias, avisos, soporte y documentación.

Cada opción debe incluir ID estable, tipo, valor actual, valor por defecto, límites/opciones válidas, ámbito (global/modo/partido), dependencia, reinicio requerido, descripción y regla de validación. No ofrecer controles sin efecto real.

## 4. Preparación de partido — datos requeridos

Orden lógico de datos antes del saque inicial:
1. Tipo de encuentro y modo de origen.
2. Equipo local y visitante; club o selección.
3. Plantillas válidas y jugadores disponibles.
4. Formación, titulares, suplentes, capitán y lanzadores.
5. Táctica colectiva, roles e instrucciones individuales.
6. Equipación local y visitante; validar contraste de colores.
7. Estadio, superficie, clima/hora si el modo los soporta.
8. Balón y recursos visuales autorizados.
9. Duración de los tiempos y método de reloj.
10. Dificultad, velocidad y perfil de atributos.
11. Reglas: fuera de juego, manos, lesiones, tarjetas, sustituciones, prórroga y penaltis, según el tipo de encuentro.
12. Árbitro, precisión arbitral y VAR, si están disponibles y permitidos.
13. Resumen de ajustes efectivos y confirmación final.

Los datos de cada selector deben provenir del catálogo real. Las reglas oficiales bloqueadas deben mostrarse como obligatorias, no como opciones editables.

## 5. Datos durante el partido

### HUD
- Equipos, marcador, escudos/emblemas originales y colores de equipación.
- Cronómetro, período, tiempo añadido y estado del reloj.
- Indicador del jugador controlado, nombre/número y barra de resistencia cuando esté activada.
- Radar con posiciones de ambos equipos y balón.
- Controles táctiles configurados y ayudas contextuales.
- Notificaciones: goles, sustituciones, tarjetas, lesiones, VAR y reanudaciones.
- Indicadores de conexión solo en multijugador.

### Pausa
Mantener las seis acciones documentadas en PAUSE_MENU.md:
- Reanudar partido.
- Repetición instantánea.
- Entrenador/Tácticas.
- Datos del partido.
- Configuración.
- Abandonar partido.

Datos del panel de equipo: formación, once, suplentes, valoración/estado, estilo táctico, cambios permitidos y restricciones por competición. La pausa debe conservar el estado exacto del partido.

### Datos del partido
- Marcador y cronología de eventos.
- Posesión, tiros, tiros a puerta, precisión, pases, entradas, faltas, tarjetas y córners.
- Fuera de juego, lesiones, sustituciones y tiempo efectivo cuando se mida.
- Estadísticas individuales y valoración de jugadores.
- Alineaciones, formación y tácticas.
- Fuente de cada cifra y unidades claras.

## 6. Datos al terminar el partido
- Resultado, ganador/empate y estado de la eliminatoria.
- Goleadores, asistentes, minutos y tipo de gol.
- Tarjetas, lesiones, sustituciones y eventos disciplinarios.
- Estadísticas colectivas e individuales.
- Valoración de cada futbolista y jugador del partido si el cálculo está disponible.
- Consecuencias de modo: puntos, clasificación, progreso, objetivos, moral, condición, experiencia o premios, solo donde correspondan.
- Acciones: continuar, revancha cuando el modo lo permita, ver estadísticas, repetir si las reglas lo permiten y volver al hub.
- Guardado confirmado y referencia al espacio actualizado.

## 7. Modo Entrenador — datos del centro de temporada

La referencia de FIFA 23 inspira un centro de información contextual. El panel principal debe reunir, sin obligar a abrir muchas pantallas:
- Calendario y próximo encuentro.
- Clasificación de liga y competiciones activas.
- Profundidad de plantilla por posición.
- Jugadores con contratos próximos a vencer.
- Lesionados, sancionados y estado físico.
- Jóvenes/promesas de cantera y progreso.
- Máximo goleador, asistencias y estadísticas del equipo.
- Próximos rivales, localía y competición.
- Objetivos de directiva y progreso.
- Notificaciones/prensa, cuando el sistema de noticias exista.

Subsecciones y conjuntos de datos:
- **Central:** próximo paso de temporada, calendario semanal, objetivos, noticias y accesos.
- **Plantilla:** jugadores, posición, rol, valoración, edad, contrato, salario, moral, forma, condición, lesión, sanción y desarrollo.
- **Tácticas:** formaciones, estilo, instrucciones, roles, planes alternativos y once.
- **Entrenamiento:** sesiones, cargas, objetivos, condición, fatiga, recuperación y resultados.
- **Traspasos:** búsqueda, filtros, informes de scouting, lista de seguimiento, ofertas enviadas/recibidas, contratos, cesiones e historial.
- **Cantera:** juveniles, edad, posición, potencial estimado, desarrollo y promoción.
- **Finanzas:** presupuesto, salarios, ingresos, gastos, premios, patrocinio, instalaciones y balance.
- **Directiva:** objetivos a corto plazo y de temporada, progreso automático, prioridades, confianza de la junta, evaluación contextual, advertencias, reuniones y consecuencias contractuales. Para el perfil Entrenador, la junta evalúa el cumplimiento de las metas deportivas; el perfil Presidente conserva las funciones de gobierno y establecimiento/revisión de objetivos.

La especificación completa de objetivos, ejemplos de tarjetas, reglas de actualización, evaluación, consecuencias y pruebas está en [Objetivos de la junta directiva y evaluación del entrenador](BOARD_OBJECTIVES_AND_MANAGER_EVALUATION.md).
- **Personal:** cuerpo técnico, especialidad, nivel, contrato y efecto.
- **Vida personal:** pantalla única del entrenador para familia y entorno ficticios, llamadas/mensajes, relaciones personales, agenda, invitaciones, eventos, descanso, vivienda, vehículos, artículos, patrimonio y gastos personales. Los conflictos con obligaciones del club se muestran antes de confirmar actividades.
- **Temporada:** calendario, tabla, estadísticas de equipo/jugadores, resultados y récords.

No se añaden monedas, sobres ni sistemas de Ultimate Team.

## 8. Modo Leyenda — datos del jugador y carrera

La referencia archivada define cuatro áreas de navegación interna: Central, Mi Pro, Temporada y Personalizar. Son secciones del hub del modo, no pantallas raíz adicionales. **Vida personal** es una pantalla principal adicional del hub que concentra toda la información personal, con secciones internas y sin subpantallas independientes para familia, mensajes o agenda.

- **Cabecera:** nombre, dorsal, club, país, posición, edad, valoración general, pie hábil, altura/peso cuando se muestren y estado de temporada.
- **Central:** próximo partido, objetivos inmediatos, noticias del club, situación del jugador y eventos.
- **Mi Pro:** atributos técnicos/físicos/mentales, arquetipo/estilo si existe, habilidades, puntos disponibles, desarrollo y personalidad.
- **Temporada:** calendario, minutos, titularidades, goles, asistencias, pases, tiros, duelos, faltas, tarjetas, lesiones, valoración y tabla.
- **Personalizar:** apariencia original, peinado, rostro, accesorios, botas y equipación autorizada; no permitir modificar datos bloqueados por la carrera.
- **Carrera:** contratos, representante, ofertas, cesiones/traspasos, selección nacional, premios, hitos y legado.
- **Relación deportiva:** confianza del entrenador, rol en plantilla, competencia por puesto y objetivos de rendimiento.

  - **Confianza del entrenador:** puntuación de 0 a 1500, barra segmentada, rol actual, tendencia, motivos de cambio, competencia por puesto y minutos recientes. Rangos de diseño inicial: 0–199 fuera de rotación; 200–599 suplente; 600–1299 rotación/candidato a titular; 1300–1499 titular habitual; 1500 jugador clave. La etiqueta intermedia se interpreta provisionalmente porque la captura de referencia está truncada.
  - La confianza influye en convocatoria, titularidad y minutos, junto con posición, táctica, forma, atributos, condición, lesiones, sanciones y nivel de los competidores. No garantiza ser titular ni impide que un jugador de confianza baja consiga oportunidades.
  - La confianza pertenece a la relación con el entrenador/club; la selección nacional tendrá una evaluación independiente. Mostrar causas comprensibles de subidas y bajadas, sin basarse exclusivamente en goles o resultados colectivos.
  - **Relación personal con el entrenador:** indicador separado de la confianza deportiva; conversaciones contextuales, mensajes, objetivos individuales, promesas de minutos/rol, reuniones y plan de recuperación de confianza.
  - Cada objetivo o promesa debe mostrar condiciones, plazo, progreso y consecuencias posibles. Las promesas no garantizan minutos ante lesión, sanción, baja condición o decisiones tácticas justificadas.
  - Historial de conversaciones, reuniones, compromisos y motivos de cambios; al cambiar de entrenador se inicia una relación nueva conservando el historial anterior.
  - Las conversaciones no otorgan titularidad ni aumentan automáticamente la confianza: sus efectos son moderados, contextuales y verificables.
  - **Vestuario:** resumen de cohesión/clima del equipo, compañeros relevantes, relaciones individuales, amistades, apoyos, rivalidades deportivas, tensiones, mensajes pendientes y liderazgo/capitanía.
  - **Ficha de compañero:** relación resumida, acontecimientos compartidos e interacciones contextuales disponibles (conversar, felicitar, apoyar, disculparse o resolver desacuerdos).
  - Mostrar causas y evolución de relaciones sin convertirlas en una puntuación única; distinguir respeto, cercanía, confianza y tensión, además de la cohesión colectiva.
  - Los avisos del vestuario se agrupan y no interrumpen partidos; las interacciones son opcionales y compatibles con pantalla táctil y mando.
  - **Vida personal (pantalla única):** reúne agenda, invitaciones, actividades con compañeros, eventos del club, descanso/recuperación, familia y entorno, mensajes/llamadas, decisiones personales, vivienda, vehículos, artículos, patrimonio e historial.
  - Cada actividad muestra participantes, fecha/hora, duración, coste si aplica, compromisos afectados y consecuencias previstas antes de confirmar.
  - Las actividades sociales son opcionales; no asistir no genera castigos automáticos. Sus efectos sobre relaciones, cohesión, fatiga y recuperación son moderados y explicables.
  - Integrar compras personales (casa, vehículo y artículos) con el sistema económico común, mostrando precio y costes recurrentes; sin moneda paralela ni microtransacciones obligatorias.
  - **Capitanía:** campo de elegibilidad y antigüedad en el club. El jugador solo puede ser capitán permanente o vicecapitán desde su segunda temporada en el club actual; una transferencia reinicia el cómputo. La elegibilidad no garantiza el nombramiento.
  - **Familia y entorno, comunicaciones, acontecimientos y agenda** son secciones internas de Vida personal, no pantallas independientes. Incluyen vínculos ficticios, mensajes/llamadas, cumpleaños, reuniones, visitas y decisiones opcionales; no acceden a contactos ni datos reales del dispositivo y funcionan offline.

La progresión depende de edad, potencial, minutos, entrenamiento, forma y lesiones, de acuerdo con GAME_DESIGN.md.

## 9. Ligas, copas y torneo personalizado

### Datos de competición
- ID, nombre, país/ámbito, temporada, categoría, tipo (liga/copa/supercopa), participantes, formato, reglas, calendario, fases y estado.
- Sistema de puntos y criterios de desempate.
- Clasificación, ascensos/descensos si aplica, grupos, eliminatorias y cruces.
- Reglas de ida/vuelta, prórroga, penaltis y criterio de resolución.
- Goleadores, asistencias, tarjetas, récords y campeón.

### Catálogo inicial
Se conservan los diez países definidos en GAME_DESIGN.md: España, Inglaterra, Cuba, Alemania, Italia, Francia, Portugal, Brasil, Argentina y Estados Unidos. Las competiciones reales listadas allí son candidatas por verificar por temporada y licencia; no convertirlas en datos definitivos sin comprobación. El primer paquete jugable debe usar nombres, equipos y jugadores ficticios.

### Torneo personalizado
Datos configurables: nombre, tipo, participantes, número de grupos/equipos, jornadas, fases, sistema de puntos, desempates, clasificados, sorteo/cruces, ida/vuelta, prórroga, penaltis y reglas por fase. El validador debe detectar estructuras imposibles antes de crear el torneo. Los límites máximos técnicos y el guardado/duplicación de plantillas siguen pendientes de especificación.

## 10. Catálogo maestro de entidades deportivas

Entidades y campos mínimos:
- **País/región:** ID, nombre visible, código, bandera original/licenciada.
- **Club/selección:** ID, nombre, nombre corto, país, emblema propio, colores, estadio, reputación ficticia.
- **Jugador:** ID estable, nombre ficticio, fecha/edad, nacionalidad ficticia, posiciones, pie hábil, altura/peso, atributos, valoración, potencial, resistencia, condición, moral, contrato, lesión/sanción.
- **Entrenador/personal:** ID, nombre ficticio, nacionalidad, especialidad, atributos, contrato y club.
- **Estadio:** ID, nombre ficticio, capacidad, superficie, iluminación, dimensiones dentro de reglamento y recursos propios.
- **Equipación:** ID, equipo, local/visitante/alternativa/portero, colores, patrón, número, patrocinio solo autorizado.
- **Balón:** ID, nombre original, materiales/parámetros físicos y aspecto.
- **Competición:** ID, temporada, reglamento y estructura.
- **Temporada/partida:** ID, modo, equipo/jugador, fecha, estado, espacio de guardado y versión de esquema.
- **Partido:** ID, competición, jornada/fase, equipos, estadio, ajustes efectivos, alineaciones, eventos y estadísticas.
- **Evento:** tipo, minuto/tiempo añadido, jugador/es implicados, equipo, consecuencia y registro.
- **Módulo:** ID, versión, compatibilidad, dependencias, tamaño, hash, permisos y estado.

Todos los IDs serán estables, los nombres visibles podrán localizarse y los paquetes JSON deberán validar esquema, duplicados, referencias rotas y compatibilidad antes de importarse.

## Balones oficiales y canteras

- Cada liga nacional posee un balón oficial propio compartido por todas sus divisiones; se asigna automáticamente a los partidos oficiales de liga y no puede cambiarse en esos encuentros.
- Los amistosos pueden usar balones alternativos instalados. Copa/Supercopa solo tendrán balón propio cuando su reglamento lo establezca.
- Primera División: todos los clubes comienzan con cantera operativa. Segunda, Tercera y categorías inferiores: todos los clubes comienzan sin cantera operativa ni juveniles generados. Podrán crear/activar una academia solo tras superar las mismas reglas de licencia, instalaciones, personal, protección juvenil, presupuesto y solvencia definidas para Segunda; no hay requisitos más flexibles en divisiones inferiores.
- Los equipos juveniles se conectan a competiciones y calendarios de la asociación correspondiente.
- Especificación, fuentes de assets y pruebas: [Balones oficiales por liga y sistema de canteras](LEAGUE_BALLS_AND_YOUTH_ACADEMIES.md).

## 10A. Modelo de atributos deportivos — propuesta de datos, pendiente de calibración

Tomar como referencia la taxonomía pública de atributos de FIFA 23, pero usar nombres, escalas y fórmulas propias. La escala **1–99 es provisional** para el prototipo de datos; debe calibrarse con pruebas y no se considera una decisión final del usuario.

### Jugadores de campo
- **Ritmo:** aceleración, velocidad punta.
- **Tiro:** posicionamiento ofensivo, definición, potencia de tiro, tiros lejanos, voleas, penaltis.
- **Pase:** visión, centros, precisión de faltas, pase corto, pase largo, efecto.
- **Regate:** agilidad, equilibrio, reacciones, control de balón, regate, compostura.
- **Defensa:** intercepciones, precisión de cabezazo, lectura/conciencia defensiva, entrada normal, entrada deslizante.
- **Físico:** salto, resistencia, fuerza, agresividad.
- **Datos complementarios:** pie dominante, pierna débil, roles/posiciones preferidas, ritmo de trabajo ofensivo y defensivo, rasgos/habilidades y experiencia.

### Porteros
- Estirada, blocaje/agarre, saque/distribución, reflejos, velocidad de desplazamiento y colocación.
- Conservar atributos de campo relevantes para pases, control y decisiones con los pies.
- Separar colocación de portero de la colocación ofensiva del jugador de campo.

### Atributos colectivos del equipo
- Construcción de juego: velocidad, pase y regate.
- Creación de ocasiones: pase, centros, tiros y movimiento.
- Defensa: presión, agresividad, anchura, altura y compactación de línea.
- Identidad táctica: formación base, presión tras pérdida, repliegue, ritmo, amplitud y estilo de salida.

### Reglas de calidad de datos
- Guardar cada atributo individual, no solo la media global.
- Calcular valoraciones por posición usando pesos documentados y revisables; no asignar la misma valoración a un jugador en todas las posiciones.
- La valoración global no sustituye la ficha completa ni debe ser el único factor que decida el comportamiento de IA.
- Potencial, forma, moral, condición física, fatiga y experiencia son variables distintas; no deben mezclarse dentro de los atributos técnicos permanentes.
- Las características de personalidad y relaciones sociales del diseño se almacenan aparte de los atributos de habilidad.
- Para cada jugador de prueba, registrar atributos base, posición principal/secundaria, rol, pierna hábil, altura, edad, potencial y curva de desarrollo.
- No importar ni reproducir bases de datos, nombres, valoraciones ni perfiles de futbolistas reales de FIFA. Crear jugadores ficticios.

### Pendiente de definición/calibración
- Pesos por posición y cálculo de valoración global.
- Escala final y distribución de valores por nivel/competición.
- Fórmulas de potencial, desarrollo, envejecimiento, forma y fatiga.
- Rasgos especiales y su impacto medible en el motor.
- Modelo de atributos de entrenadores y cuerpo técnico.

## 11. Configuración contextual — matriz de opciones

Tomar FIFA 23 como catálogo de referencia, no copiar todas sus opciones automáticamente. Las opciones propias ya definidas en Fútbol Nova tienen prioridad.

| Grupo de datos | Opciones a documentar |
|---|---|
| Partido | duración, dificultad, velocidad, atributos, perfil IA, método de reloj, balón y ayudas |
| Cámara | cámara por contexto/modo, altura, distancia, zoom, ángulo, seguimiento y transiciones |
| Visual/HUD | marcador/reloj, radar, indicador de jugador, tamaño, nombre/número, ayudas y visibilidad |
| Reglas | fuera de juego, lesiones, manos, tarjetas, severidad arbitral, sustituciones, prórroga, penaltis y VAR |
| Audio | música, efectos de menú, público, ambiente, comentaristas, idiomas, volumen y silencios |
| Controles | asignaciones, asistencia de pase/tiro/centro/pase elevado/portero, cambio de jugador, sensibilidad y vibración |
| Simulación del usuario | parámetros de pase, tiro, aceleración, velocidad, portero, posicionamiento y fatiga |
| Simulación IA | equivalentes para CPU, con límites claros y perfiles de dificultad |
| Accesibilidad | remapeo, narración, subtítulos, contraste, filtros, tamaño, reducción de movimiento y ayudas |
| Gráficos | escala, resolución, calidad, sombras, efectos, cuadros/segundo y calidad adaptativa |

Las opciones de ajuste de usuario/IA deben ser avanzadas y opcionales; no sustituir los controles de dificultad ya aprobados. Los valores permitidos deben definirse con pruebas del motor, no copiar rangos numéricos de FIFA sin validación.

## 12. Persistencia y estructura de guardado

Cada modo mantiene cinco espacios: espacio 1 exclusivo de autoguardado; espacios 2–5 manuales/copias. Cada registro de guardado debe contener:
- ID de partida y modo.
- Nombre visible y fecha/hora.
- Versión de esquema y versión de juego.
- Temporada, competición, equipo o jugador.
- Estado del calendario y progreso.
- Plantillas, alineaciones y tácticas relevantes.
- Historial de partidos, resultados y estadísticas.
- Ajustes por modo y preferencias vinculadas.
- Módulos requeridos y versiones.
- Hash/integridad y estado de migración.

No se sobrescribe el último estado válido hasta verificar la nueva escritura. Los datos de modos distintos permanecen separados.

## 13. Prioridad de cierre de datos

### Datos documentados y listos para pasar a revisión de diseño
- Cuatro pantallas raíz y categorías de Configuración.
- Reglas de guardado.
- Estructura funcional del menú de pausa.
- Selector de equipaciones y gestos independientes HOME/AWAY.
- Hub de Leyenda y centro de temporada Manager.
- Reglas principales de modos, ligas, copas, torneo y multijugador.
- Catálogo de ajustes contextuales.

### Datos que aún requieren investigación o especificación técnica, sin preguntar de nuevo decisiones ya tomadas
1. Completar el inventario visual de cada captura original de FIFA 23 de alta resolución y comprobar cuáles faltan físicamente en GitHub.
2. Confirmar los campos definitivos de atributos de jugadores, entrenadores y personal y sus escalas.
3. Definir fórmulas de valoración, potencial, progreso, forma, fatiga, moral y rendimiento.
4. Verificar formatos y reglas vigentes de cada competición real candidata; mantener ficticio el paquete inicial.
5. Definir límites técnicos de torneos personalizados mediante pruebas de rendimiento.
6. Completar el inventario de eventos y estadísticas del motor de partido.
7. Definir las opciones gráficas disponibles por clase de dispositivo Android.
8. Definir esquema JSON, validación, migraciones y versionado de paquetes/guardados.
9. Completar datos de salas y límites del multijugador después de fijar la arquitectura de red.
10. Obtener y verificar las imágenes originales que siguen pendientes; las descripciones de texto no sustituyen los binarios.

## 14. Referencias de consulta

- FIFA 23 — guía de inicio y distribución de Home, Play, Online y Customise: https://www.fifplay.com/fifa-23-how-to-get-started
- FIFA 23 — ajustes de partido, cámara, HUD, reglas, audio y personalización de juego: https://fifauteam.com/fifa-23-game-settings/
- FIFA 23 — guía de controles y asistencias: https://www.fifplay.com/fifa-23-customise-controls/
- Taxonomía de atributos de jugadores basada en FIFA 23: https://fifauteam.com/fifa-23-attributes/
- FIFA 23 — recursos oficiales de accesibilidad y controles: https://www.ea.com/able/resources/fifa/fifa-23
- FIFA 23 — guía de carrera de Manager: https://www.fifplay.com/fifa-23-career-mode-manager-guide/
- FIFA 23 — guía de carrera de jugador: https://www.fifplay.com/fifa-23-career-mode-player-guide/
- FIFA 23 — galería de capturas oficiales para localizar referencias adicionales: https://fifauteam.com/fifa-23-screenshots/
- FIFA 23 — notas oficiales de EA sobre información contextual del hub de Carrera: https://www.ea.com/es-es/ea-play/news/pitch-notes-fifa-23-career-deep-dive

**Nota de derechos:** estas fuentes sirven para identificar categorías y flujos de información. No se copiarán capturas, marcas, textos extensos, datos protegidos ni activos de FIFA/EA dentro de Fútbol Nova.


## Documento ampliado del modelo deportivo

El detalle de jugadores, posiciones, roles, atributos individuales, esquema JSON y validaciones se desarrolla en [SPORTS_DATA_MODEL.md](SPORTS_DATA_MODEL.md). Este documento está en progreso y no implica integración en Godot.


## 1A. Requisitos globales confirmados: español y música

### Idioma español
- Todo el contenido visible y audible dirigido al usuario debe estar en español: interfaz, botones, menús, ajustes, tutoriales, instrucciones, objetivos, diálogos, mensajes, errores, avisos, confirmaciones, estadísticas, textos de modos, accesibilidad y documentación integrada.
- El español es el idioma predeterminado y no debe haber cadenas de interfaz en inglés ni mezclas accidentales de idiomas.
- Nombres propios y denominaciones originales se conservan cuando corresponda; no se traducen nombres personales ni IDs técnicos.
- Comentarios, narración y voces, cuando estén implementados, deben ofrecer español como opción inicial. No presentar idiomas de voz inexistentes como disponibles.

### Música global
- Con la música activada por el usuario, la música de fondo puede sonar en todas las pantallas, incluidas secciones raíz, submenús, hubs de modo, preparación, partido, pausa, resultados y configuración.
- La reproducción continúa entre transiciones sin reiniciar la pista ni superponer reproducciones.
- Con la música desactivada, no debe sonar música en ninguna pantalla. La preferencia se conserva entre sesiones.
- Música, efectos, ambiente y voces/comentarios tienen controles de volumen separados.
- La música debe mezclarse de modo que no oculte alertas, efectos importantes ni voces. La disponibilidad de pistas debe reflejar contenido realmente instalado/licenciado.
- La categoría Configuración > Música controla activación, selección de pista/lista y volumen de música; Configuración > Audio puede ofrecer el balance general de canales sin duplicar el interruptor global.
- No se reproducirán canciones comerciales sin derechos o autorización. Las pistas podrán ser originales, licenciadas o aportadas legalmente por el usuario.

## Requisito aprobado: cargo de administración en la carrera de club

Al crear una nueva partida de carrera de club, el usuario elige uno de estos cargos:

- **Entrenador principal:** administra el área deportiva (plantilla, alineaciones, tácticas, entrenamiento, desarrollo de jugadores y gestión de partidos).
- **Presidente del club:** administra el área institucional y estratégica (presupuesto, finanzas, directiva, inversiones, instalaciones, objetivos institucionales y nombramientos de alto nivel).

Los permisos son distintos y están separados. Cada cargo solo puede ejecutar las acciones que le corresponden. Las decisiones que necesiten coordinación con el otro ámbito se tramitan mediante propuestas, solicitudes o informes al responsable, sin acceso automático a todas las herramientas. El cargo elegido queda guardado con la carrera.

Esta selección es el rol del usuario en la partida; no debe confundirse con la identidad, puesto laboral o contrato del entrenador principal ni de otros miembros del personal del club. Los campos de interfaz y flujos concretos de elección y administración se detallarán en el inventario de datos de carrera. No se integran pantallas en esta fase.

## Mejoras transversales de experiencia de usuario

Las siguientes capacidades deben reflejarse en los datos y controles de las pantallas existentes, sin crear nuevas pantallas raíz:

- **Perfil de partido:** preset Auténtico/Competitivo, dificultad, asistencias y deslizadores personalizados.
- **Ayuda contextual:** tutoriales opcionales, consejos configurables y acceso a práctica desde los flujos pertinentes.
- **Panel de partido:** estadísticas en vivo, descanso, resumen final, rendimiento individual y jugadas destacadas.
- **Acceso táctico rápido:** formación, mentalidad, instrucciones y sustituciones desde pausa o preparación, según el contexto.
- **Accesibilidad visual:** alto contraste, colores de equipos/porteros/árbitros/balón, saturación del césped y control de sombras.
- **Accesibilidad auditiva y de lectura:** subtítulos configurables, narración de menús, tamaños de texto y mezcla independiente de música, efectos, ambiente y voces.
- **Controles:** reasignación, ayudas graduables y alternativas simplificadas.
- **Comodidad:** opciones para reducir vibración, destellos y movimiento de cámara.
- **Guardado seguro:** estado del autoguardado, recuperación del último guardado válido y confirmaciones con detalles del espacio afectado.
- **Estado de conexión:** distinguir claramente funciones offline, online y multijugador local por zona Wi-Fi.
- **Eventos y avisos:** frecuencia configurable, notificaciones agrupadas y sin interrupciones durante el partido.
- **Rendimiento:** preajustes gráficos escalables, modo de ahorro y opción de mostrar indicadores de rendimiento.
- **Idioma:** todo contenido dirigido al usuario en español, sin mezclas accidentales de inglés.

Cada control debe indicar su efecto y conservar la preferencia al reiniciar cuando corresponda. Los ajustes de accesibilidad y controles estarán disponibles desde Configuración y, cuando sea útil, durante la primera puesta en marcha. Los valores predeterminados deberán permitir jugar sin exigir configuración avanzada.

**Estado:** paquete de mejoras de experiencia documentado como requisito de diseño. Falta priorizar cada función, definir los campos exactos de interfaz y validar el rendimiento; no implica que ya esté implementado.

## Requisitos de datos offline y catálogo ficticio
- El catálogo deportivo completo debe estar disponible localmente, sin solicitudes de red para consultar jugadores, clubes, plantillas, atributos, estadísticas o calendarios.
- Objetivo de contenido: 20.000+ jugadores ficticios originales. No se copiarán registros ni recursos de FIFA/EA SPORTS FC.
- Todos los clubes deben incluir el nombre de su región geográfica en el nombre visible. Esta regla se aplica a las diez ligas base y a cualquier módulo futuro; cuando haya varios clubes de una misma región, se diferenciarán con distintivos ficticios sin quitar el nombre regional.
- No se utilizarán competiciones femeninas en el juego ni en los módulos de contenido.
- Los filtros y búsquedas deben operar sobre índices locales y permitir consultar por nombre ficticio, ID, club, posición, edad, nacionalidad, competición y estado contractual.
- La ficha debe diferenciar atributos base de variables dinámicas de cada carrera.
- La creación de juveniles, fichajes simulados, cesiones, retiradas, evolución y estadísticas de carrera debe ejecutarse localmente.
- Los datos básicos y recursos imprescindibles deben estar incluidos en la instalación o en paquetes locales previamente instalados. Descargar paquetes será opcional y nunca requisito para iniciar o continuar una partida ya instalada.
- Mostrar claramente qué funciones complementarias son online, sin presentar como disponible offline una función que no esté implementada.
- Las pruebas de aceptación deben comprobar inicio en modo avión, creación/carga de carrera, búsqueda en la base completa, partido, guardado y carga posterior sin conexión.

## Estilo aprobado para Vida personal — mixto

La pantalla única de Vida personal, tanto en Manager/Entrenador como en Leyenda, usa un **estilo mixto**: tarjetas visuales para navegación y resumen, combinadas con paneles compactos para agenda, mensajes, relaciones y datos económicos.

- En Android móvil, diseño de una columna, tarjetas amplias, iconos redondeados, texto legible y desplazamiento vertical.
- En pantallas grandes, distribución adaptable en columnas con paneles laterales cuando aporte claridad.
- La agenda próxima y los avisos importantes ocupan la zona superior; mensajes recientes y relaciones quedan en segundo nivel; vivienda, vehículos, artículos y patrimonio se agrupan en tarjetas de acceso.
- Abrir una tarjeta cambia la sección interna de Vida personal, sin crear una pantalla raíz ni separar familia, mensajes o agenda en pantallas independientes.
- Mantener compatibilidad con mando, accesibilidad y dispositivos modestos; evitar animaciones o efectos pesados.
- Leyenda prioriza vestuario/carrera/descanso; Entrenador prioriza entorno familiar, compromisos personales y profesionales y eventos. Patrimonio personal nunca se mezcla con finanzas del club.

**Estado:** estilo visual mixto aprobado; wireframe detallado, medidas, estados y componentes pendientes; no implementado ni probado.
