# Fútbol Nova — Sistema visual y arquitectura de pantallas

Estado: documento de referencia visual. La estructura raíz vigente es de cuatro pantallas; los inventarios de datos se recopilan antes de integrar interfaces. No equivale a implementación ni a aprobación definitiva de cada mockup.

## 1. Objetivo y referencias

Fútbol Nova será un simulador 3D de fútbol para Android. Su interfaz debe sentirse como una retransmisión deportiva moderna combinada con una central de gestión futbolística: inmersiva en los partidos, clara y eficiente en menús de gestión, y coherente entre modos.

Referencias:
- **Principal para menús y flujos:** FIFA 23, incluidas las capturas que el usuario aportó y las fuentes documentadas en este archivo.
- **Complementaria:** Football League, Google Play: https://play.google.com/store/apps/details?id=com.football.soccer.league; sus imágenes públicas sirven como apoyo para referencias de partido/campo y no sustituyen las decisiones confirmadas de Fútbol Nova.
- Capturas de HUD, botón de pausa y menú de pausa aportadas por el usuario y descritas en GAME_DESIGN.md; los detalles que no se hayan inspeccionado visualmente se mantienen como pendientes de verificación.
Las referencias orientan jerarquía, ritmo, legibilidad, disposición de información y flujo de uso. No autorizan a reproducir literalmente interfaces, marcas, escudos, equipaciones, modelos, texturas, sonidos, animaciones ni otros recursos protegidos.

### Referencia funcional y visual principal: FIFA 23

FIFA 23 es la referencia solicitada para estudiar organización del menú, hubs de modos, información contextual, ajustes, preparación de partido, controles, HUD, pausa y datos de carrera. Las capturas aportadas por el usuario y archivadas en `assets/references/` tienen prioridad para los apartados que representan.

Fuentes de consulta para completar los datos que no aparecen en las capturas:
- FIFA 23 — guía de inicio y pestañas Home, Play, Online y Customise: https://www.fifplay.com/fifa-23-how-to-get-started
- FIFA 23 — ajustes de partido, cámara, visuales, reglas, audio y personalización: https://fifauteam.com/fifa-23-game-settings/
- FIFA 23 — controles y asistencias: https://www.fifplay.com/fifa-23-customise-controls/
- Recursos oficiales de accesibilidad FIFA 23: https://www.ea.com/able/resources/fifa/fifa-23
- Carrera Manager FIFA 23: https://www.fifplay.com/fifa-23-career-mode-manager-guide/
- Carrera de jugador FIFA 23: https://www.fifplay.com/fifa-23-career-mode-player-guide/
- Notas de EA sobre el hub de Carrera e información contextual: https://www.ea.com/es-es/ea-play/news/pitch-notes-fifa-23-career-deep-dive

La adaptación respeta las decisiones vigentes de Fútbol Nova: exactamente cuatro pantallas raíz —Inicio, Online, Modos y Configuración—, navegación horizontal circular y conservación del estado. Ultimate Team está excluido. No añadir secciones raíz antiguas ni sistemas de Ultimate Team.

La información que debe reunirse por pantalla, modo, partido y ajustes está en [Catálogo maestro de datos](SCREEN_DATA_CATALOG.md). La documentación no implica integración de pantallas ni aprobación de un mockup.

### Requisito confirmado: carrusel horizontal y comportamiento del menú

El menú principal tendrá una franja/carrusel horizontal desplazable para explorar los modos y accesos. Este carrusel será una parte real de la navegación, no un adorno:

- Desplazamiento por gesto táctil de izquierda/derecha; soporte de mando y teclado cuando estén disponibles.
- Tarjetas con imagen original, título, breve descripción y estado de disponibilidad.
- Tarjeta seleccionada destacada y panel principal actualizado según el foco.
- Visibilidad parcial de la siguiente tarjeta para indicar continuidad; indicadores de posición discretos.
- Desplazamiento por páginas o tarjetas con movimiento suave, sin saltos inesperados.
- Al seleccionar un modo, una acción principal permitirá entrar; no se iniciará una partida accidentalmente por mover el carrusel.
- El carrusel recordará la última posición útil al salir y regresar al hub.
- La lista podrá crecer sin rehacer la pantalla; las tarjetas se adaptarán a la anchura y orientación Android.
- La navegación persistente de secciones se mantendrá separada del carrusel de modos.

### Estructura visual y funcional propuesta para Fútbol Nova

- **Franja superior:** marca Fútbol Nova, sección activa, perfil y accesos de sistema pertinentes.
- **Área central destacada:** escena deportiva original; el contenido y la acción principal cambian según la sección o tarjeta seleccionada.
- **Zona de información contextual:** resumen breve, estado de actividad/temporada y acceso directo cuando corresponda.
- **Carrusel horizontal:** tarjetas de modos con foco visual, desplazamiento táctil y selección explícita.
- **Zona inferior de navegación:** accesos persistentes a las secciones principales, ajustados a ergonomía móvil.
- **Capas secundarias:** paneles de selección, confirmación y configuración que aparecen sin perder el contexto del hub.

La composición, proporciones, textos, iconos, colores, animaciones, ilustraciones y distribución final serán originales. No se reutilizarán nombres de marca, escudos, fotografías, futbolistas, tipografías propietarias, sonidos, código ni recursos visuales de FIFA 23. Se toma su lógica de experiencia como guía y se rediseña para la identidad Nova y las limitaciones de Android.

### Alcance y validación

Este requisito actualiza el Mockup 01: deja de ser solo una portada con tarjetas y pasa a ser la especificación de un hub navegable con secciones, panel contextual, accesos rápidos y carrusel horizontal. El mockup existente queda como exploración inicial, no como diseño aprobado. Se validarán por separado: (a) jerarquía y apariencia, (b) comportamiento de navegación, (c) adaptación a pantallas Android y (d) funcionamiento real una vez implementado.

## 2. Dirección artística propuesta

**Concepto:** simulación deportiva premium, nocturna y tecnológica, con protagonismo del césped y la iluminación de estadio. La interfaz debe distinguirse de la referencia y mantener una identidad propia.

### Paleta inicial propuesta
- Azul noche profundo: fondo principal y superficies de navegación.
- Azul petróleo: paneles secundarios y capas.
- Cian eléctrico: foco, selección activa, navegación y datos interactivos.
- Verde lima de cancha: confirmaciones deportivas, indicadores positivos y acentos de juego.
- Blanco frío: texto principal y cifras de alta prioridad.
- Gris acero: texto secundario, divisores y estados deshabilitados.
- Ámbar: advertencias, lesiones/alertas no críticas y estados que requieren atención.
- Rojo: errores, expulsiones y acciones destructivas; nunca como decoración.

Los valores HEX exactos, contraste y estados claro/oscuro se fijarán en la fase de tokens y pruebas de accesibilidad. El tema oscuro será la presentación principal; el tema claro se diseñará como variante coherente, no como una interfaz distinta.

### Tipografía y composición
- Tipografía sans-serif deportiva, compacta y de alta legibilidad; cifras tabulares para marcador, cronómetro y estadísticas.
- Jerarquía clara: título de pantalla, contexto/competición, contenido principal y acciones.
- Paneles con esquinas moderadas, bordes discretos, capas translúcidas solo cuando no reduzcan legibilidad.
- Uso de fotografías/renders propios de estadio y jugadores ficticios como fondos; degradados y desenfoque controlados para separar texto del fondo.
- Animaciones cortas y funcionales para selección, transición, goles y apertura de paneles. Respetar ajustes de accesibilidad y rendimiento.
- Diseño adaptable a distintas relaciones de aspecto Android, zonas seguras, orientación y tamaños de pantalla.

## 3. Lenguaje de componentes

- Botón primario: acción principal de pantalla, alto contraste y área táctil amplia.
- Botón secundario: acciones alternativas sin competir con la principal.
- Tarjeta de modo: imagen temática, nombre, breve descripción y estado disponible/bloqueado.
- Tarjeta de equipo: escudo original o emblema ficticio, nombre, país y valoración cuando exista.
- Fila de competición: nombre, temporada, fase/estado y acceso a detalles.
- Pestañas: navegación entre secciones hermanas; estado activo inequívoco.
- Panel lateral/desplegable: filtros, detalles y opciones avanzadas.
- Controles de ajuste: selectores, interruptores, deslizadores y campos numéricos con unidades y límites visibles.
- Estados universales: cargando, vacío, error recuperable, sin conexión, contenido descargable y confirmación.
- Confirmaciones para borrar, abandonar, reiniciar o sobrescribir; nunca ocultar consecuencias.

## 4. Arquitectura global de navegación

### Navegación raíz — estructura confirmada
1. **Inicio:** Continuar, Nueva partida, Amistosos y Entrenamiento.
2. **Online:** servicios por Internet y multijugador local por zona Wi-Fi, con requisitos de conexión claramente separados.
3. **Modos:** Leyenda, Entrenador, Torneos, Ligas y Copas.
4. **Configuración:** Edición, Módulos, Música, Juego, Datos, Controles, Audio, Gráficos, Accesibilidad, Administración e Información.

No crear Perfil, Ajustes, Módulos ni otras categorías como pantallas raíz independientes: pertenecen a las pantallas y categorías ya confirmadas. El acceso sin Internet debe mantenerse disponible. Ultimate Team no existe en el alcance de Fútbol Nova.

### Modos y centros internos
- Partido rápido y amistosos: accesos desde Inicio.
- Entrenamiento: acceso desde Inicio.
- Ligas y Copas.
- Torneo personalizado.
- Entrenador (Manager).
- Leyenda.
- Multijugador: Internet y zona Wi-Fi local, accesible desde Online según disponibilidad.

Cada modo tendrá su propio centro de datos y acciones frecuentes. Los hubs internos no crean nuevas pantallas raíz. No se mezclarán reglas de progresión entre modos.

## 5. Inventario inicial de pantallas

### A. Inicio y navegación
- Splash/carga.
- Primer inicio y preferencias básicas.
- Menú principal.
- Selector de modo.
- Centro de notificaciones/eventos locales.
- Perfil y espacios de guardado.
- Ajustes generales.
- Accesibilidad, controles y audio.
- Centro de módulos: disponibles, instalados, versiones y gestión.

### B. Partido rápido y preparación

El selector previo al partido muestra ambos equipos a la vez, modelos 3D, escudos/banderas, OVR, VS, estadio, uniformes independientes, balón, configuración contextual y botón de inicio. Cambios de estadio, balón y equipación afectan solo al encuentro actual. Los ajustes de reglas solo son editables en amistosos/exhibición y otros encuentros no oficiales configurables; en partidos oficiales se bloquean los valores impuestos por el reglamento. Ver [Selector de equipos y preparación del partido](PRE_MATCH_TEAM_SELECTION.md).

- Selección de tipo de partido.
- Selección de equipo local/visitante.
- Selector de clubes o selecciones.
- Selección de estadio, clima, balón y equipaciones.
- Configuración del partido.
- Formación y alineación.
- Tácticas e instrucciones.
- Resumen final previo al inicio.
- Presentación de equipos y entrada al campo.

### C. Experiencia durante el partido
- HUD principal: marcador, cronómetro, añadido, radar, controles táctiles y señales contextuales.
- HUD alternativo configurable y ajustes rápidos de cámara.
- Menú de pausa.
- Gestión de alineación y sustituciones.
- Tácticas durante pausa.
- Estadísticas en vivo.
- Repetición y selección de cámara.
- Descanso.
- Prórroga y tanda de penaltis.
- Resultado final y estadísticas detalladas.

### D. Ligas y Copas
- Selector clubes/selecciones.
- Catálogo de países y competiciones.
- Detalle de competición.
- Selección de equipo.
- Configuración de temporada.
- Calendario.
- Tabla de clasificación.
- Cuadro de copa.
- Estadísticas, goleadores y disciplina.
- Presentación de campeón y cierre de temporada.

### E. Torneo personalizado
- Centro de torneos.
- Crear torneo: nombre, tipo y participantes.
- Selección y gestión de equipos.
- Constructor de fases.
- Editor de grupos y jornadas.
- Editor de eliminatorias y cruces.
- Editor de puntuación y desempates.
- Editor de reglas por fase: ida/vuelta, prórroga, penaltis y resolución.
- Validación de estructura y conflictos.
- Resumen/reglamento del torneo.
- Calendario, clasificación, cuadro y estadísticas del torneo.

### F. Entrenador (Manager)
- Crear/elegir club y entrenador.
- Panel principal de temporada.
- Plantilla, reservas y cantera.
- Ficha de futbolista.
- Tácticas, formación e instrucciones.
- Entrenamiento y condición física.
- Mercado, negociaciones y contratos.
- Scouting.
- Finanzas e instalaciones.
- Cuerpo técnico.
- Calendario y centro de partido.
- Vestuario, moral, prensa y objetivos.
- Historial y estadísticas.

### G. Leyenda
- Creación de futbolista.
- Apariencia y atributos iniciales.
- Selección de academia/club.
- Panel de carrera.
- Entrenamiento.
- Calendario y convocatorias.
- Evaluación de rendimiento.
- Relación con entrenador/equipo.
- Contratos, representante y traspasos.
- Estadísticas, premios y legado.

### H. Multijugador
- Selector Internet / zona Wi-Fi.
- Crear/unirse a sala.
- Lobby y lista de participantes.
- Selección de equipos/posiciones.
- Preferencias y resolución de ajustes compartidos.
- Confirmación de reglas.
- Estado de conexión y reconexión.
- Panel de iconos rápidos.
- Resultado y resumen.

## 6. Reglas específicas de interfaz

- Toda pantalla debe responder claramente: dónde está el usuario, qué puede hacer, cuál es la acción principal y cómo volver sin perder cambios.
- Los flujos largos se dividirán en pasos con progreso visible y posibilidad de volver a pasos anteriores conservando datos válidos.
- Las pantallas de gestión priorizarán densidad informativa ordenada; las pantallas de partido priorizarán el campo y reducirán elementos superpuestos.
- Las acciones que cambien reglas de competición mostrarán resumen y validación antes de confirmar.
- Las tarjetas, tablas y gráficos utilizarán nombres, cifras y estados procedentes de datos del juego; no mostrarán estadísticas ficticias como si fueran reales.
- Los controles táctiles respetarán el tamaño mínimo, separación y zonas seguras de Android. Los botones de partido se adaptarán a manos y tamaños de pantalla, con remapeo ya previsto en GAME_DESIGN.md.
- Toda pantalla contemplará estados sin datos, sin conexión y con contenido opcional no instalado cuando sean aplicables.

## 7. Orden de producción visual

Se trabajará por familias, generando y mostrando un mockup por pantalla que se cree o rediseñe:
1. Menú principal y selector de modo.
2. Selección de equipos y configuración de partido.
3. HUD de partido y menú de pausa.
4. Resultados y estadísticas.
5. Centro de Torneo y constructor de competiciones.
6. Centros y flujos de Ligas/Copas, Manager y Leyenda.
7. Multijugador.
8. Ajustes, perfil y módulos.

La primera pantalla que se prepara visualmente es el **menú principal**. El mockup inicial será una propuesta para personalizar; no se considera aprobación definitiva ni implementación.
- **Mockup 01 — Menú principal:** generado y presentado en la conversación el 12-11-2026. Estado: propuesta inicial pendiente de correcciones/aprobación. Dirección visual: estadio nocturno, identidad Fútbol Nova, base azul noche, acentos cian y verde lima, accesos directos a Partido Rápido, Ligas y Copas, Torneo, Entrenador, Leyenda y Multijugador; navegación inferior Inicio, Modos, Perfil y Módulos. El mockup es una composición conceptual panorámica; la adaptación final a tamaños y orientación Android deberá resolverse en diseño responsive.

## 8. Investigación de repositorios y recursos

La investigación de GitHub se realiza por necesidad técnica y por áreas concretas; no es posible garantizar una revisión exhaustiva de cada repositorio público existente. Antes de adoptar cualquier componente se debe revisar código, licencia del repositorio, licencias individuales de recursos, dependencias, mantenimiento, seguridad, compatibilidad con Godot/Android y rendimiento.

Candidatos y referencias revisados o ya registrados en `Nova-Nexus/library/games-sources.json`:
- Player12 — https://github.com/FlavioMili/Player12 — referencia de diseño para simulación, gestión y conexión entre partido y carrera. Licencia registrada GPL-3.0: no integrar código sin análisis de obligaciones y compatibilidad.
- Agentic FC — https://github.com/gaemi/agentic-fc — referencia para simulación de temporadas, eventos reproducibles y sistemas de IA. Licencia registrada MIT; revisar dependencias y assets.
- Football Engine 2026 — https://github.com/DeltaBitsSystem/FootballEngine — referencia para física, agentes, tácticas y reglas; licencia registrada GPL-3.0, con revisión obligatoria antes de cualquier reutilización.
- FreeKick — https://github.com/AKM-8byte/FreeKick — referencia Godot para física configurable, IK procedural y repeticiones; licencia registrada MIT, revisar assets y dependencias individualmente.
- Pixel-Striker — https://github.com/devinarena/Pixel-Striker — juego móvil de fútbol 2D con licencia MIT; útil solo como referencia de flujo móvil y modos específicos, no como base visual/3D.
- OpenFootManager — https://github.com/openfootmanager/openfootmanager — simulación de gestión con licencia GPL-3.0; referencia conceptual para profundidad de gestión, no candidato directo de integración en Godot.

No se ha integrado ni copiado código o assets de estos repositorios en esta fase. La selección técnica debe realizarse mediante pruebas aisladas y revisión de licencia, no por popularidad o por el mero hecho de ser público.

## 9. Estado y control de cambios

- Este documento define la propuesta inicial de sistema visual e inventario de pantallas.
- Las decisiones confirmadas por el usuario se trasladarán al documento principal de diseño.
- Cada mockup se entregará en el chat y se registrará con estado: propuesta, corregido, aprobado o sustituido.
- Mockup, implementación y prueba son estados distintos.
- Mantener consistencia con `GAME_DESIGN.md` y el estándar global `Nova-Nexus/library/game-creation-standards.md`.
