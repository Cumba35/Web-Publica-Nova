# Fútbol Nova — Diseño del juego

## 1. Visión

Crear un simulador de fútbol 3D para Android donde el usuario pueda jugar los partidos con control directo y, fuera del campo, gestionar una carrera de club o la trayectoria de un futbolista. La calidad del control y la lectura táctica del partido son el núcleo; los modos comparten una base deportiva, pero cada uno aplica sus propias reglas de progresión y competición.

La aplicación Football League (Google Play: `com.football.soccer.league`) es una referencia visual y de jugabilidad, no una plantilla para copiar. La identidad, el código, los recursos y los datos de Fútbol Nova serán originales. No se copiarán código, recursos ni datos protegidos de FIFA, PES, Football League u otros juegos.

## Arquitectura del juego base y módulos descargables

La aplicación base debe poder instalarse y funcionar de forma independiente. Su alcance funcional es exclusivamente: partidos amistosos locales, ayuda y ajustes generales del juego. El amistoso es la única modalidad jugable incluida en la instalación base.

El menú conserva cuatro pantallas:
- Inicio: iniciar un partido amistoso y consultar Ayuda.
- Online: escaparate del módulo descargable Multijugador Online; no conecta ni crea salas en el juego base.
- Modos: catálogo informativo de módulos descargables; no abre carreras ni competiciones que no estén instaladas.
- Configuración: ajustes generales del juego base y administración del catálogo de módulos.

Modo Leyenda, Modo Entrenador, ligas, copas, torneos de selecciones, TAS, entrenamiento, Momentos, Online y demás experiencias adicionales se distribuyen por módulos independientes. Un módulo solo se habilita después de descargarlo, verificarlo, instalarlo y comprobar su compatibilidad. El código fuente presente en el repositorio no equivale a un paquete instalado: los scripts, escenas, datos y recursos de cada módulo deben separarse del APK base antes de publicar.

## 2. Pilares de jugabilidad

1. **Control sensible:** aceleración, frenado, giro, orientación corporal, primer toque y protección del balón.
2. **Balón creíble:** pases rasos y elevados, rebotes, fricción, efecto, altura, velocidad y respuesta a superficies.
3. **Decisiones tácticas:** desmarques, líneas de pase, presión, coberturas, repliegue, amplitud y transiciones.
4. **Partidos con contexto:** cansancio, forma, moral, clima opcional, localía, presión y estilo de cada equipo.
5. **Modos diferenciados:** la progresión, los traspasos y la persistencia de los efectos dependen del modo elegido.

## 3. Referencias de cámara y controles

### Referencias visuales aportadas por el usuario

- La imagen `Screenshot_20261111-091053.png` se utilizará como referencia de la interfaz durante los partidos, especialmente para la ubicación y la forma del marcador, el radar y los botones de control.
- La imagen `Screenshot_20261111-091128.png` también corresponde a la pantalla durante los partidos. Se tomará como referencia visual adicional para la interfaz en juego, especialmente el diseño, la ubicación y la presentación del botón de pausa. La composición se adaptará a la identidad propia de Fútbol Nova y a Android, sin copiarla literalmente.
- La imagen `Screenshot_20261111-091213.png` corresponde al **menú de pausa durante un partido**. Se tomará como referencia visual y funcional para el menú completo: todos los apartados, opciones, textos, indicadores y demás datos que aparezcan en la captura deberán tenerse en cuenta al diseñar el menú de pausa de Fútbol Nova. La estructura y los elementos se adaptarán a la identidad propia del juego y a Android, sin copiar literalmente el diseño de origen. La captura todavía no ha podido visualizarse dentro del chat; por tanto, los elementos concretos que contiene deberán verificarse visualmente antes de detallarlos o convertirlos en requisitos individuales.
- Estas imágenes orientan la composición y la funcionalidad, pero no se copiarán literalmente. La interfaz final tendrá identidad visual propia de Fútbol Nova y se adaptará a Android.

### Menú de pausa durante el partido

- El menú se inspira en la referencia aportada: estadio y campo visibles detrás de paneles rectangulares oscuros, separadores verde lima, tipografía blanca deportiva y opción enfocada resaltada en claro.
- Incluirá Reanudar partido, Repetición instantánea, Entrenador/Tácticas, Datos del partido, Configuración y Abandonar partido.
- La pausa detendrá el estado completo del partido; abandonar requerirá confirmación y reanudar restaurará el estado exacto.
- La especificación y criterios de aceptación están en [Menú de pausa](PAUSE_MENU.md).

### Selector de equipos y preparación del partido

La pantalla previa al saque inicial mostrará local y visitante simultáneamente, modelos 3D, escudos/banderas, valoración OVR, estadio, selectores independientes de equipación, selector de balón, acceso a configuración y botón de inicio. El usuario podrá cambiar estadio, balón y uniformes para el encuentro actual cuando el tipo de partido lo permita. La configuración contextual será editable solo en amistosos/exhibición y otros encuentros no oficiales configurables; los partidos oficiales bloquearán los parámetros definidos por el reglamento y mostrarán el motivo. La precedencia será reglamento oficial, modo/carrera, tipo de partido y preferencias globales compatibles. Ver [Selector de equipos y preparación del partido](PRE_MATCH_TEAM_SELECTION.md).

### Menú de selección de camisetas

- El menú seguirá el estilo visual de la captura aportada: fondo negro, modelos 3D iluminados a ambos lados y paneles HOME/AWAY en el centro.
- Para cambiar una camiseta, el usuario podrá deslizar horizontalmente el dedo directamente sobre el panel/camiseta que desea modificar. El gesto solo cambiará la equipación de ese equipo; izquierda y derecha recorrerán las camisetas disponibles en sentidos opuestos.
- Las flechas podrán mantenerse como alternativa para mando/teclado y accesibilidad. La camiseta seleccionada y el modelo 3D correspondiente se actualizarán simultáneamente.
- Los detalles de interacción y las pruebas de aceptación están en [Menú de selección de camisetas](KIT_SELECTION_MENU.md).

### Cámaras

El jugador podrá elegir y configurar distintos tipos de cámara:
- Transmisión: vista amplia de retransmisión.
- Táctica: vista elevada.
- Dinámica: seguimiento de las jugadas.
- Cercana.
- De jugador: especialmente útil en el modo Leyenda.
- Cinematográfica: goles, celebraciones, faltas y repeticiones.

Se podrán ajustar altura, distancia/zoom, ángulo y velocidad de seguimiento; cambiar de cámara durante el partido y guardar configuraciones por modo. También habrá cambios automáticos contextuales en ataque, regates, disparos, goles, defensa, saques de esquina, faltas, penaltis y reanudaciones.

### Controles táctiles Android

- Joystick progresivo en el lado izquierdo: cuanto más se aleje del centro, mayor velocidad, limitada por aceleración, velocidad máxima y resistencia del futbolista.
- En ataque: botones de habilidades/técnicas, pase, disparo y centro.
- En defensa: habilidades/técnicas, presionar, cambiar jugador y barrida.
- El antiguo botón de sprint se sustituye por un control gestual de habilidades: mantener y deslizar en una dirección ejecuta técnicas distintas; un movimiento circular activa una técnica avanzada aleatoria. La efectividad depende de técnica, equilibrio, control del balón, resistencia y capacidades del jugador.
- Presión: pulsación normal para presionar al rival con balón. Mantener y deslizar hacia arriba durante un segundo solicita ayuda de presión de un compañero cercano. La respuesta depende de distancia, velocidad, resistencia, capacidad defensiva y posicionamiento, evitando desproteger la defensa.

La especificación completa de gestos, carga de potencia, regates básicos/intermedios, habilidades avanzadas equipables, límites por partido, combos y pruebas de aceptación está en [Controles táctiles y habilidades](TOUCH_CONTROLS_AND_SKILLS.md). Esta especificación no significa que dichas funciones estén implementadas: el prototipo actual sigue siendo una prueba de concepto y debe desarrollarlas y validarlas por fases.

## 4. Estructura de partido y reglas

- La duración predeterminada de cada tiempo reglamentario será de **5 minutos reales** (10 minutos de juego reglamentario en total, divididos en dos tiempos). El usuario podrá elegir también 3, 6, 8, 10, 15 o 20 minutos por tiempo. Siempre habrá dos tiempos.
- Las tácticas, alineaciones y titulares podrán modificarse libremente cuando el usuario lo desee fuera de los partidos, sin bloqueos por temporada. Durante un partido, estos ajustes estarán disponibles desde el menú de pausa; no se podrán realizar directamente mientras el balón esté en juego. El descanso también quedará detenido hasta que el usuario decida continuar y permitirá revisar estadísticas y realizar los ajustes disponibles.
- Al finalizar **cada período de juego cronometrado**, siempre habrá tiempo añadido. Esta regla se aplicará a los dos tiempos reglamentarios y, cuando corresponda, a cada uno de los tiempos de prórroga. El árbitro decidirá y calculará **de forma autónoma**, sin intervención del usuario, la duración del añadido teniendo en cuenta el **método de tiempo seleccionado para el partido**, la duración configurada para ese partido y el desarrollo de cada período.
  - Con **Reloj detenido en interrupciones**, el árbitro añadirá obligatoriamente entre **1 y 3 minutos** por período. La duración concreta dentro de ese intervalo tendrá en cuenta la duración elegida para el partido y las circunstancias del período.
  - Con **Reloj continuo**, no habrá un límite máximo fijo. El árbitro calculará el tiempo que corresponda según el tiempo efectivamente perdido por lesiones y atención médica, sustituciones, goles y celebraciones, pérdida deliberada de tiempo, revisiones VAR, reanudaciones y otras interrupciones pertinentes, teniendo también en cuenta la duración elegida para el partido. El añadido podrá superar los 3 minutos cuando las pérdidas lo justifiquen.
- Cuando un futbolista sufra una lesión que requiera atención, el árbitro podrá detener el juego según la situación y la gravedad aparente. El personal médico entrará al terreno, evaluará al jugador y decidirá si puede continuar, necesita salir para recibir atención o debe ser sustituido; el juego solo se reanudará cuando corresponda. La secuencia tendrá animaciones, tiempos de espera y decisiones coherentes con las reglas aplicables. Con el reloj continuo, esta interrupción se contabilizará al calcular el tiempo añadido cuando corresponda; con el reloj detenido, el cronómetro permanecerá pausado durante la atención. Si el futbolista recibe atención fuera del terreno y está en condiciones de continuar, podrá regresar cuando el árbitro lo autorice y de acuerdo con las reglas aplicables. Esta posibilidad no se aplicará a lesiones graves que impidan continuar ni a jugadores ya sustituidos o expulsados.
- El usuario podrá elegir el **comportamiento del reloj del partido** desde los ajustes generales del juego y desde los ajustes de cada modo. Se contemplan dos opciones:
  - **Reloj detenido en interrupciones:** pausa el cronómetro durante las situaciones configuradas en las que el balón no está en juego. Se detendrá cuando el balón salga del terreno para un saque de banda, un saque de esquina o un saque de portería, y también durante faltas, fueras de juego, goles, sustituciones, lesiones y atención médica, revisiones VAR, penaltis y las interrupciones ordenadas por el árbitro debido a discusiones, enfrentamientos entre jugadores o incidentes con el público. Estas situaciones podrán dar lugar, según su gravedad, el reglamento y el criterio arbitral, a advertencias, tarjetas amarillas, tarjetas rojas, expulsiones u otras sanciones disciplinarias aplicables. Las medidas disciplinarias podrán afectar tanto a futbolistas como a entrenadores y demás miembros del cuerpo técnico. El sistema registrará el motivo y cada persona implicada, y aplicará las consecuencias correspondientes sin automatizar sanciones que no estén justificadas por las reglas. Las secuencias de animación, revisión o preparación de la reanudación se conservarán, pero no consumirán tiempo del cronómetro mientras esté detenido. El juego se reanudará y el reloj volverá a avanzar cuando corresponda reanudar el partido.
  - **Reloj continuo:** mantiene el cronómetro avanzando durante las interrupciones, como en el fútbol real, y gestiona el tiempo añadido para compensar las pérdidas pertinentes.
- La selección del reloj controla la disponibilidad de estos ajustes y comportamientos:
  - **Exclusivos de Reloj continuo:** cálculo detallado del tiempo perdido por interrupciones para determinar el añadido (el tiempo añadido existe con ambos métodos); pérdida deliberada de tiempo por parte de los futbolistas; gestión del tiempo por la IA según el marcador y el momento del partido; duración de las sustituciones; duración de las celebraciones; duración de las revisiones VAR; y ritmo o demora de las reanudaciones. Estos sistemas podrán configurarse cuando corresponda y deberán respetar el reglamento de la competición. La IA podrá, por ejemplo, proteger una ventaja ralentizando ciertas reanudaciones o acelerar el juego cuando necesite remontar.
  - **Disponibles con ambos métodos:** animaciones de interrupciones, cámaras y transiciones cinematográficas, atención médica, repeticiones y presentación audiovisual. Con el reloj detenido, estas secuencias se conservarán, pero su duración no descontará tiempo del cronómetro. Con el reloj continuo, el tiempo que consuman se tendrá en cuenta al calcular el tiempo añadido cuando las reglas y el contexto lo requieran.
- Los ajustes específicos de cada modo podrán establecer valores predeterminados o restricciones coherentes con sus reglas. La lista exacta de eventos que detienen el reloj en el modo detenido y los parámetros detallados de cada ajuste podrán precisarse durante el diseño técnico.
- **Directiva general de realismo:** priorizar siempre una simulación futbolística tan realista, coherente y creíble como sea viable en todos los sistemas: movimiento y biomecánica de jugadores, contacto y física del balón, animaciones contextuales, tácticas colectivas, toma de decisiones de IA, arbitraje y reglas, disciplina de jugadores y cuerpo técnico, lesiones y atención médica, fatiga, clima y terreno, ambiente del estadio, público, sonido, retransmisión, estadísticas y comportamiento dentro y fuera del campo. Las decisiones deberán respetar las reglas reales de la competición elegida, contemplar excepciones reglamentarias y evitar resultados o animaciones artificiales cuando exista una alternativa físicamente y deportivamente plausible. El realismo se equilibrará con controles accesibles, rendimiento estable en Android y opciones configurables. Esta directiva se aplica al juego base y a todos los módulos; el módulo Realista ampliará la profundidad y el nivel de detalle, no será una excusa para que el juego base tenga comportamientos incoherentes.
- **Investigación y recursos externos:** cuando una característica necesite una solución técnica, referencia o recurso que no convenga crear desde cero, investigar repositorios públicos de GitHub y otras fuentes legítimas. Registrar en Nova Nexus las fuentes útiles, capacidades, procedencia, estado de mantenimiento y licencia; inspeccionar también dependencias y licencias individuales de los assets. No copiar ni integrar código, modelos, animaciones, audio, datos deportivos o recursos hasta verificar compatibilidad legal, seguridad, calidad, mantenimiento y rendimiento. Priorizar componentes con licencias compatibles y atribuciones claras; si la licencia es desconocida, ambigua o incompatible, usar solo como referencia conceptual o descartar. No asumir que una licencia del repositorio cubre todos sus contenidos.
- Todas las sustituciones, incluidas las motivadas por lesión, consumirán una sustitución disponible y una ventana de sustitución. No habrá excepciones para los cambios por lesión.
- Un jugador sustituido no podrá volver a entrar al mismo partido bajo ninguna circunstancia. En el menú de sustituciones, los jugadores que ya hayan sido sustituidos aparecerán en gris y no podrán seleccionarse. Los jugadores expulsados también aparecerán en gris y quedarán bloqueados para la selección; junto a cada uno se mostrará un icono que identificará el motivo de la expulsión: acumulación de tarjetas amarillas o tarjeta roja directa. Los jugadores lesionados mostrarán un icono de una cruz roja dentro de un círculo blanco. Los iconos de estado se ubicarán en la esquina inferior derecha de la representación de cada jugador. Las lesiones leves y moderadas permitirán que el futbolista continúe jugando, pero reducirán su rendimiento según la gravedad y el tipo de lesión. Un jugador que haya salido sustituido o que esté lesionado de gravedad no podrá volver a entrar en juego durante ese partido.
- Desde el menú de pausa se podrán realizar sustituciones durante el partido. En partidos oficiales habrá un máximo de cinco sustituciones durante el tiempo reglamentario, distribuidas en un máximo de tres ventanas. Las sustituciones realizadas durante el descanso cuentan como una de esas ventanas. Si se disputa prórroga, se añadirá una sustitución y una cuarta ventana, para un máximo total de seis sustituciones. Antes de una tanda de penaltis también se permitirán sustituciones, únicamente si el equipo todavía dispone de sustituciones y ventanas disponibles conforme a estos límites. En amistosos se podrán sustituir los once jugadores, sin esos límites.
- La duración de cada tiempo de prórroga se relaciona con la duración normal elegida:

| Tiempo normal | Cada tiempo de prórroga |
|---:|---:|
| 3 min | 1 min |
| 5 min | 2 min |
| 6 min | 2 min |
| 8 min | 3 min |
| 10 min | 3 min |
| 15 min | 5 min |
| 20 min | 7 min |

- La prórroga y los penaltis se aplicarán según el reglamento de la competición; no se impondrán cuando el reglamento real establezca otro procedimiento.
- En amistosos y exhibición, el usuario podrá decidir antes del partido si quiere prórroga, penaltis y sanción por manos. También podrá desactivar lesiones. Las incidencias opcionales de estos partidos no alterarán la carrera ni los atributos permanentes.
- El descanso de la prórroga también esperará la decisión del usuario.
- En competiciones oficiales se aplicarán las reglas obligatorias de la competición, incluidas las reglas sobre manos y lesiones.

### Árbitros y VAR

- Habrá estilos arbitrales estricto, equilibrado, permisivo, riguroso y variable, con atributos de criterio, posicionamiento, experiencia y precisión.
- El VAR podrá revisar goles, penaltis, tarjetas rojas directas y confusión de identidad. El usuario podrá ver repeticiones.
- Si se permiten errores arbitrales, el usuario podrá presentar hasta tres reclamaciones por partido sobre goles, penaltis, faltas, expulsiones, fuera de juego y otras decisiones importantes. El proceso incluirá solicitud, repeticiones desde distintas cámaras, revisión y decisión.
- La precisión arbitral tendrá tres niveles: Perfecta (sin errores), Realista (errores ocasionales) y Variable (frecuencia distinta entre partidos). Se podrá elegir en ajustes generales y en el menú previo de cada modo. Con precisión Perfecta no habrá reclamaciones.
- En partidos oficiales se respetará el reglamento de la competición.

## 5. IA, entrenadores y futbolistas

Los equipos controlados por IA tendrán autonomía para gestionar sus equipos, respetando la identidad futbolística del club y el estilo del entrenador actual. La IA podrá elegir y cambiar tácticas, formaciones, sustituciones, presión, línea defensiva, ritmo y estilo; explotar debilidades; proteger resultados o remontar; y gestionar fatiga y estado físico.

Cada club tendrá filosofía, estilo, preferencias del entrenador, formación habitual y estrategia ofensiva/defensiva. Un entrenador nuevo influirá y adaptará progresivamente el comportamiento del equipo.

Entrenadores y jugadores tendrán personalidades, atributos y preferencias:
- Entrenadores: carácter, temperamento, ambición, paciencia, disciplina, liderazgo, capacidad táctica, preparación física, gestión del vestuario, desarrollo de jóvenes, adaptación, experiencia y preferencias de formaciones y estilos.
- Jugadores: liderazgo, ambición, profesionalidad, temperamento, disciplina, confianza; velocidad, aceleración, resistencia, fuerza, equilibrio, control, regate, pase, tiro y defensa, entre otros; posiciones, compañeros, estilo, pie dominante, funciones y roles preferidos.
- Las relaciones entre miembros del equipo podrán incluir amistad, rivalidad, confianza, desacuerdos, preferencias, conflictos y adaptación. Influirán en el vestuario y las reacciones a decisiones, resultados, suplencias, lesiones y rendimiento.

## 6. Modo Entrenador (Manager)

- Selección o creación de club.
- Plantilla principal, reservas y cantera.
- Mercado de fichajes, cesiones, renovaciones, cláusulas y contratos.
- Presupuesto, salarios, ingresos, premios, patrocinio e instalaciones.
- Entrenamiento individual y colectivo, carga, fatiga, lesiones y recuperación.
- Scouting por regiones, posiciones, edad, potencial y coste.
- Cuerpo técnico con especialidades.
- Tácticas, roles, instrucciones por jugador y planes alternativos.
- Moral, cohesión, prensa, afición, directiva y objetivos.
- Calendario de varias competiciones y simulación de partidos controlados por IA o jugados manualmente.
- La progresión y decadencia de jugadores, entrenadores y personal se aplican en este modo. Incluyen envejecimiento, evolución según edad, etapa, entrenamiento, minutos, rendimiento, lesiones, recuperación, experiencia y acontecimientos; también pueden ocurrir retiradas, cambios de club y despidos.

## 7. Modo Leyenda

- Crear personaje: nombre ficticio, edad inicial, país ficticio o habilitado, posición, pie hábil, altura, peso y apariencia original.
- Empezar en academia, equipo juvenil o club de menor categoría.
- Entrenar atributos técnicos, físicos y mentales.
- Ganar titularidad mediante rendimiento, disciplina y adaptación táctica.
- Evaluación por partido: goles, asistencias, pases, duelos, pérdidas, ocasiones y contribución defensiva.
- Conversaciones y decisiones de carrera: representante, renovaciones, cesiones, traspasos y relación con entrenador.
- Objetivos personales, premios, selección nacional y legado.
- La progresión depende de edad, potencial, minutos, entrenamiento, forma y lesiones; no solo de puntos arbitrarios.
- En este modo también progresan o decaen jugadores, entrenadores y personal según sus trayectorias y circunstancias.

## 8. Modo Ligas y Copas

### Acceso y selección

Al entrar aparecerá una pantalla para elegir:
- **Modo de clubes**
- **Modo de selección**

En Modo de clubes se mostrarán las competiciones disponibles de los países definidos. En Modo de selección se utilizará el mismo sistema de navegación y selección, pero con selecciones nacionales.

La pantalla de competiciones de clubes tendrá dos columnas paralelas. Cada columna corresponderá a un país y mostrará su nombre únicamente como encabezado informativo. Debajo aparecerán, en una lista vertical, la liga, las copas y las supercopas disponibles de ese país. Todos los elementos de la disposición vertical deberán verse sin desplazamiento vertical; si el conjunto de países excede el ancho de la pantalla, se recorrerá horizontalmente. El desplazamiento horizontal no ocultará elementos mediante una lista vertical adicional.

Países iniciales solicitados:
- España
- Inglaterra
- Cuba
- Alemania
- Italia
- Francia
- Portugal
- Brasil
- Argentina
- Estados Unidos

Las ligas serán siempre de primera división. Se utilizarán los nombres oficiales y los reglamentos correspondientes a cada competición y temporada. No se inventarán competiciones nacionales cuando no exista una competición verificable. Las supercopas se mostrarán en la misma lista vertical del país, junto a su liga y sus copas.

Catálogo inicial de referencia (los nombres y la existencia/formato de cada competición deberán verificarse y mantenerse actualizados antes de incorporarlos como datos definitivos):
- España: LALIGA EA SPORTS; Copa del Rey; Supercopa de España.
- Inglaterra: Premier League; Emirates FA Cup; Carabao Cup; FA Community Shield.
- Cuba: Liga Nacional de Fútbol de Primera División; copa/supercopa nacional solo si se verifica su existencia y reglamento aplicable.
- Alemania: Bundesliga; DFB-Pokal; DFL-Supercup.
- Italia: Serie A; Coppa Italia; Supercoppa Italiana.
- Francia: Ligue 1; Coupe de France; Trophée des Champions.
- Portugal: Liga Portugal Betclic; Taça de Portugal; Taça da Liga; Supertaça Cândido de Oliveira.
- Brasil: Campeonato Brasileiro Série A; Copa do Brasil; Supercopa Rei.
- Argentina: Liga Profesional de Fútbol; Copa Argentina; Supercopa Argentina; Trofeo de Campeones.
- Estados Unidos: Major League Soccer; Lamar Hunt U.S. Open Cup. Leagues Cup se tratará como competición internacional compartida, no como copa exclusivamente nacional.

### Paneles de información y selección

Al seleccionar una competición, se abrirá una pantalla de selección con dos paneles:
- **Izquierda:** menú de selección del equipo participante.
- **Derecha:** información de la competición seleccionada.

Cuando se seleccione un club, el panel derecho cambiará y mostrará los detalles de ese club; el menú izquierdo seguirá disponible para cambiar la selección. El mismo patrón se aplicará en Modo Entrenador (Manager) y en Modo de selección, sustituyendo clubes por selecciones nacionales cuando corresponda.

Después de elegir el equipo se avanzará a una pantalla siguiente para configurar la temporada o competición.

### Configuración de temporada y restricciones de dificultad

- En Ligas y Copas, la duración de cada tiempo se seleccionará una sola vez antes de comenzar la temporada y quedará bloqueada durante toda ella.
- En Ligas y Copas, antes de cada partido se podrá cambiar la dificultad. Para estos cambios solo estarán disponibles los tres niveles superiores: Profesional, Clase mundial y Leyenda. La elección se aplicará a todos los equipos controlados por la IA y al comportamiento global de los rivales en ese partido; no habrá niveles de dificultad distintos por equipo.
- En los modos Entrenador (Manager) y Leyenda, la dificultad y la duración de cada tiempo podrán modificarse como máximo una vez por cada cinco partidos disputados. El sistema deberá llevar un contador fiable de partidos y bloquear los cambios hasta cumplir el intervalo.
- En Entrenador (Manager) y Leyenda, la posibilidad de modificar estos parámetros solo estará habilitada cuando la dificultad vigente corresponda a uno de los tres niveles superiores: Profesional, Clase mundial o Leyenda. En Principiante, Aficionado y Semiprofesional no se permitirán esos cambios durante la partida.
- Las restricciones de Entrenador (Manager) y Leyenda se aplican tanto al cambio de dificultad como al cambio de duración. La interfaz deberá mostrar cuándo vuelve a estar disponible la modificación y evitar que se eluda el límite mediante reinicios o navegación entre menús.

### Reglas del modo

- Solo se podrá disputar una temporada por partida.
- Al terminar la temporada, se regresará al menú principal. Para volver a jugar se deberá iniciar una nueva liga o copa, o elegir otro modo.
- Las plantillas serán fijas durante toda la competición: no habrá fichajes, traspasos ni cambios de plantilla entre temporadas.
- No habrá progresión ni decadencia de vida: sin envejecimiento, evolución o disminución permanente de atributos, retiradas, despidos ni cambios permanentes de carrera para jugadores, entrenadores o personal.
- Sí se conservarán los resultados, clasificaciones, estadísticas, goleadores, asistencias, tarjetas, récords y títulos de la temporada.

## 9. Nuevo modo Torneo

El modo Torneo permitirá crear **competiciones personalizadas**. El usuario no estará limitado a escoger únicamente entre formatos predefinidos: podrá configurar la estructura de cada torneo y combinar las modalidades compatibles para construir la competición que desea.

El modo tendrá las mismas posibilidades generales de configuración y gestión de equipos que el modo Entrenador (Manager), con estas diferencias:
- No tendrá progresión de vida ni envejecimiento.
- No permitirá traspasos.
- Todos los partidos se considerarán no oficiales.
- Cada partido podrá configurarse individualmente antes de comenzar.
- El usuario podrá crear torneos desde cero.
- La configuración personalizada podrá incluir participantes y equipos, cantidad y composición de grupos, fases, jornadas, rondas, criterios de clasificación, cruces, partidos de ida y vuelta, finales y reglas particulares compatibles.
- Se podrán combinar fases de grupos, eliminación directa, eliminatorias a ida y vuelta, grupos seguidos de eliminatorias y otras estructuras que admita el sistema. También se podrán organizar ligas y copas simultáneas dentro de una misma configuración de competición.
- **Reglas propias del torneo:** el usuario podrá configurar el sistema de puntuación (puntos por victoria, empate y derrota), los criterios y el orden de desempate, la cantidad de equipos que avanzan desde cada grupo, la clasificación por posiciones, los cruces y el modo de asignar emparejamientos. Podrá definir para las eliminatorias si se juegan a partido único o ida y vuelta, cómo se resuelven los empates, si existe prórroga, tanda de penaltis o repetición, y si se aplica alguna regla adicional compatible con el formato creado.
- El editor mostrará las reglas aplicadas a cada fase y permitirá revisar el resumen completo antes de iniciar el torneo. Los cambios deberán validarse para evitar estructuras imposibles o contradictorias.
- El juego validará la coherencia de la estructura antes de crear el torneo y explicará cualquier incompatibilidad o límite técnico. Los límites concretos de equipos, grupos, jornadas, rondas y reglas quedan pendientes de definición; no se presentarán como ilimitadas capacidades que dependan de recursos o restricciones técnicas.
- Las plantillas predefinidas, si se ofrecen, serán atajos opcionales para crear torneos y podrán editarse; nunca sustituirán la personalización.
- La posibilidad de guardar, duplicar y reutilizar configuraciones de torneo queda pendiente de confirmación.

## 10. Progresión por modo

| Modo | Progresión de vida | Traspasos |
|---|---|---|
| Leyenda | Sí | Según la carrera |
| Entrenador (Manager) | Sí | Sí |
| Ligas y Copas | No | No; plantillas fijas |
| Torneo | No | No |

Los amistosos y partidos de exhibición tampoco harán avanzar carreras ni producirán cambios permanentes de atributos, fichajes, despidos, retiradas o envejecimiento. Las lesiones y manos podrán configurarse en esos partidos; si se activan, sus efectos serán solo para ese partido y no persistirán en las carreras.

## 11. Datos deportivos

Todos los equipos, jugadores, competiciones y reglas estarán desacoplados del código. Los primeros datos serán ficticios para evitar problemas de licencias. Los datos de competiciones reales requerirán verificación de nombres, formatos y reglamentos vigentes por temporada, además de revisión de derechos de uso. El editor podrá importar y validar paquetes JSON creados por usuarios, con identificadores estables y control de duplicados.

## 12. Accesibilidad, guardado y opciones

- Remapeo completo de controles.
- Asistencia de pase/tiro, velocidad del partido y dificultad.
- Seis niveles de dificultad: Principiante, Aficionado, Semiprofesional, Profesional, Clase mundial y Leyenda.
- Estilos de juego en partidos oficiales: agresivo, neutro y pasivo, sujetos a dificultad y reglas.
- Subtítulos y localización, empezando por español e inglés.
- Guardado automático y varios espacios de carrera.
- Opciones gráficas escalables para dispositivos modestos.
- Las decisiones de diseño y cambios confirmados deberán registrarse en el repositorio GitHub del proyecto para mantener una copia persistente y reducir el riesgo de pérdida de información.

## 13. Conectividad, funcionamiento sin Internet y multijugador

- **Funcionamiento sin Internet:** Fútbol Nova deberá poder iniciarse y utilizarse sin conexión a Internet. El juego base y las funciones, modos y contenidos disponibles localmente no dependerán de una conexión permanente ni exigirán iniciar sesión en línea para jugar sin conexión.
- Las funciones que por su naturaleza necesiten servicios externos —por ejemplo, multijugador por Internet, descarga de módulos o actualizaciones y servicios en la nube— requerirán conexión y deberán identificarse claramente. Su indisponibilidad no impedirá acceder al contenido local ni continuar utilizando las funciones sin conexión.
- Los datos y partidas locales deberán poder guardarse y cargarse sin Internet. Las funciones de sincronización o respaldo remoto, si se incorporan, se realizarán cuando exista conexión y no sustituirán la disponibilidad del guardado local.
- **Método de reloj en multijugador:** todos los partidos multijugador utilizarán por defecto el **Reloj detenido en interrupciones**. Solo se utilizará **Reloj continuo** cuando todos los participantes de la partida tengan configurado ese método; basta con que un solo participante tenga seleccionado el reloj detenido para que se aplique este último a toda la partida. La comprobación será unánime y se realizará antes de iniciar el partido, mostrando claramente el método que se utilizará.
- **Acuerdo sobre ajustes compartidos:** esta regla de unanimidad se aplicará también a los demás ajustes de partido que afecten por igual a todos los participantes, incluidas la duración de cada tiempo y las reglas opcionales configurables. Un ajuste personalizado solo se aplicará cuando todos los participantes acepten exactamente el mismo valor. Si no hay unanimidad, se utilizará el valor predeterminado del modo o las reglas oficiales de la competición cuando sean obligatorias; para la duración, el valor predeterminado general será de **5 minutos por tiempo**. Ningún participante podrá imponer unilateralmente un ajuste al resto. Antes de comenzar, la sala mostrará los valores definitivos y permitirá a los participantes conocer si se ha aplicado una opción acordada o el valor predeterminado/reglamentario.
- **Métodos de configuración compartida:** cada jugador podrá elegir cómo resolver los ajustes de partido en multijugador: **Modo votaciones**, **Modo predeterminado** o **Modo cooperativo**. Cada modo de juego multijugador tendrá su **propio menú de preferencias**, separado de los demás modos. En ese menú, cada jugador podrá configurar sus preferencias individuales para cada ajuste compartido —por ejemplo, duración de los tiempos, comportamiento del reloj y reglas opcionales—. Las preferencias se guardarán por separado para cada modo en su cuenta y servirán como propuestas o valores de referencia al resolver la configuración de cada partida mediante el método elegido. El jugador podrá modificarlas cuando quiera; las preferencias individuales no anularán el método de resolución compartida ni las reglas oficiales obligatorias. Las preferencias guardadas para el modo seleccionado se cargarán y aplicarán automáticamente al entrar en una partida de ese modo, sin exigir que el jugador vuelva a configurarlas en la sala. La sala mostrará las preferencias recibidas y el resultado final tras resolverlas según el método compartido elegido; cualquier cambio excepcional para esa partida deberá realizarse antes de comenzar y respetar las mismas reglas de resolución. La elección se realizará desde la **configuración del juego** y se conservará como preferencia de la cuenta hasta que el jugador la cambie allí; no será necesario volver a seleccionarla antes de cada partido. El método efectivo de la partida se determinará considerando las preferencias de todos los participantes. El usuario también podrá consultar durante el partido qué preferencias aportó cada participante y cómo se resolvió cada ajuste compartido. Esta información deberá estar disponible de forma clara y accesible, sin entorpecer los controles ni el desarrollo del encuentro.
- **Resolución de votaciones:** en Modo votaciones, gana la opción que obtenga el mayor número de votos. No se exige mayoría absoluta. Si dos o más opciones empatan en el mayor número de votos, se aplicará el valor predeterminado del modo o el reglamento oficial obligatorio para ese ajuste. En Modo predeterminado, un ajuste personalizado solo se aplica si todos los participantes coinciden exactamente; de lo contrario, se conserva el valor predeterminado del modo o el reglamento oficial obligatorio. En Modo cooperativo, si solo un participante lo tiene activado, sus ajustes se sincronizan con los del otro participante. Si ambos lo tienen activado, se combinan todas las configuraciones compatibles de ambos. Cuando existan ajustes incompatibles, se utilizará para esos ajustes el valor predeterminado del modo o el reglamento oficial obligatorio. La sala mostrará antes del inicio qué método está activo y la configuración final resultante. Ningún ajuste podrá contradecir las reglas obligatorias de la competición.
- **El multijugador tendrá dos modalidades diferenciadas:**
  - **Multijugador por Internet:** permitirá jugar con otros usuarios a través de una conexión a Internet.
  - **Multijugador por zona Wi-Fi:** permitirá jugar entre dispositivos conectados a una misma red Wi-Fi local, sin necesitar acceso a Internet. La arquitectura técnica deberá contemplar la conexión local entre dispositivos; el método concreto de descubrimiento, creación de sala y conexión queda pendiente del diseño técnico.
- **Alcance de las decisiones multijugador registradas en esta sección:** todos los ajustes y reglas detallados a continuación sobre preferencias compartidas, votaciones y modo cooperativo, reloj, modos de control, participantes, entradas tardías, desconexiones, anfitrión, expulsiones y reconexiones corresponden al **multijugador local sin Internet por zona Wi-Fi**. No se aplicarán automáticamente al multijugador por Internet; sus reglas deberán definirse por separado.
- La modalidad local por zona Wi-Fi no deberá confundirse con el multijugador por Internet. La interfaz indicará qué conexión requiere cada modalidad y ofrecerá la modalidad local cuando los dispositivos puedan comunicarse mediante la red Wi-Fi compartida.

- **Zona Wi-Fi creada por el propio dispositivo:** además de conectarse a una red Wi-Fi existente, el usuario podrá crear una sesión local desde el teléfono anfitrión y permitir que los demás dispositivos se conecten directamente a esa zona Wi-Fi, sin necesitar un router ni acceso a Internet. La creación de la zona, la sala y la comunicación local se integrarán en Fútbol Nova y utilizarán las capacidades de Android y del dispositivo; no se exigirá instalar otra aplicación ni contratar o conectar un servicio externo para jugar en esta modalidad. Si el dispositivo o la versión de Android no permite crear una zona Wi-Fi compatible mientras se ejecuta el juego, la interfaz deberá explicar la limitación y ofrecer conectarse a una red Wi-Fi local existente.
- **Independencia de dependencias externas:** el multijugador local deberá incluir dentro del propio juego los componentes de sala, descubrimiento de dispositivos, conexión, sincronización y gestión de la partida. No dependerá de SDK, aplicaciones, plataformas o servicios de terceros para establecer partidas por zona Wi-Fi. Se podrán utilizar las API del sistema operativo necesarias para las funciones de red y zona Wi-Fi, sujetas a permisos y restricciones de Android.
- **Comunicación rápida mediante iconos:** durante el multijugador, los usuarios podrán enviarse iconos y símbolos predefinidos para expresar mensajes breves (por ejemplo, saludo, celebración, aprobación, disculpa o petición de pase), sin necesidad de chat de texto ni de voz. Los iconos se elegirán desde un panel rápido integrado en el juego y se mostrarán a los demás participantes de la partida. El catálogo, las categorías, los límites de frecuencia y las opciones para silenciar o bloquear comunicaciones quedan pendientes de concretar. No se habilitará texto libre ni chat de voz como requisito para esta comunicación.
- La modalidad por Internet podrá requerir infraestructura de conexión y coordinación propia de Fútbol Nova. Esa necesidad no se trasladará al modo local por zona Wi-Fi, que deberá funcionar sin Internet y sin servicios externos.
- **El multijugador se dividirá en dos modos de control:**
  - **Plantilla completa:** partido entre exactamente dos usuarios. Cada usuario controlará a todo su equipo, con posibilidad de cambiar de futbolista según las reglas y controles del juego. No se admitirán más usuarios en esta modalidad.
  - **Un solo jugador:** cada usuario controlará únicamente a un futbolista. La partida permitirá reunir usuarios para ocupar las posiciones de campo de ambos equipos; los porteros no serán asignados a usuarios y estarán controlados por la IA. El número de participantes podrá llegar hasta completar todos los puestos de campo disponibles, sujeto a la capacidad de la sala y de los dispositivos.
- En **Un solo jugador**, cada participante podrá elegir un futbolista de los equipos disponibles para el partido o utilizar el personaje que haya creado en el modo Leyenda, siempre que sea compatible con la posición y las reglas de la partida. La selección de un personaje de Leyenda utilizará su identidad y atributos permitidos para este modo, sin crear cambios permanentes en su carrera por disputar partidos multijugador.
- En **Un solo jugador**, los equipos se asignarán de forma aleatoria. El sistema procurará que ambos equipos tengan un nivel global lo más cercano posible, considerando la valoración de sus plantillas y, cuando corresponda, las capacidades de los futbolistas elegidos por los participantes. La asignación deberá evitar ventajas injustificadas y buscar equilibrio entre los dos bandos.
- **Inicio de partida en Un solo jugador:** se podrá comenzar cuando haya como mínimo un usuario humano en cada equipo. No será obligatorio completar todas las posiciones de campo antes del inicio; las posiciones sin participante humano estarán controladas por la IA.
- **Entrada después del inicio:** cada usuario podrá configurar si permite que otros participantes se incorporen a la partida una vez comenzada. La entrada tardía solo estará habilitada si **todos los usuarios que ya participan en la partida** tienen activada esa posibilidad. Si al menos uno la tiene desactivada, no se permitirá que ningún usuario nuevo entre después del inicio. La configuración deberá poder consultarse claramente en la sala antes de comenzar y durante la partida; cambiarla no podrá eludir la regla de consentimiento unánime de los participantes actuales.
- **Abandono y desconexión de participantes en Un solo jugador:** un usuario podrá abandonar voluntariamente la partida. Cuando un participante deje de controlar su futbolista, la IA asumirá temporalmente el control de ese jugador para que el equipo conserve la posición y pueda seguir jugando.
- **Límite de control temporal por IA tras una desconexión:** la IA podrá controlar al futbolista desconectado durante un máximo de **2 minutos**. El plazo comenzará cuando se detecte la desconexión. Si el participante no se reconecta y recupera el control antes de que termine ese plazo, se considerará que ha abandonado la partida y se aplicarán las reglas de abandono: la IA dejará de actuar como sustituto temporal y, si su equipo se queda sin participantes humanos, el partido terminará inmediatamente con derrota por abandono por **3-0**. El límite de dos minutos no se reiniciará mediante desconexiones repetidas del mismo participante durante la misma incidencia.
- **Reconexión dentro del plazo:** si el participante recupera la conexión antes de que finalicen los dos minutos, el juego le devolverá automáticamente el control de su futbolista, sin requerir una solicitud ni intervención manual. La transferencia de control deberá realizarse de forma sincronizada y segura, evitando órdenes simultáneas de la IA y del usuario.
- La partida solo podrá continuar mientras haya al menos un usuario humano activo en cada equipo. Si, debido al abandono o desconexión de participantes, uno de los equipos se queda sin ningún usuario humano, el partido terminará inmediatamente, aunque el equipo contrario conserve varios participantes humanos.
- En ese caso se declarará vencedor por abandono al equipo que todavía tenga participantes humanos y se registrará como resultado por defecto una derrota **3-0** para el equipo que se quedó sin usuarios humanos. Este resultado se aplicará como resultado oficial de esa partida multijugador.
- **Autoridad del anfitrión en zona Wi-Fi:** en las partidas locales creadas mediante una zona Wi-Fi del propio dispositivo, el usuario que cree esa zona será automáticamente el anfitrión de la sala. La autoridad de anfitrión no podrá transferirse a otro participante.
- **Desconexión del anfitrión en zona Wi-Fi:** si el teléfono que creó la zona Wi-Fi se desconecta o se apaga, la partida se pausará automáticamente durante un máximo de **1 minuto** para permitir que el anfitrión se reconecte. Si no recupera la conexión dentro de ese plazo, la partida se cancelará. La autoridad no se transferirá a otro participante.
- **Registro de cancelación por desconexión del anfitrión:** si la partida se cancela al agotarse el minuto de espera, se registrará como **partida cancelada**, sin victoria ni derrota para ninguno de los participantes.
- **Expulsión de participantes antes del inicio:** el anfitrión podrá expulsar a participantes de la sala multijugador antes de comenzar el partido. Esta acción afectará únicamente a la sala y a esa partida; no supondrá un bloqueo permanente del usuario. Los detalles de notificación, restricciones y protección frente a abusos quedan pendientes de definición. Los participantes expulsados podrán volver a solicitar entrar en esa misma sala; la solicitud quedará sujeta a la aceptación del anfitrión.
- La selección de equipo, el emparejamiento de niveles, la ocupación de posiciones y la incorporación de participantes deberán mostrarse claramente antes de iniciar el partido. Los criterios exactos de valoración y los mecanismos técnicos de reconexión quedan pendientes del diseño técnico.
- Las reglas, modos de partido y opciones disponibles en multijugador, así como el número máximo de participantes, la gestión de salas, la sincronización y los mecanismos contra desconexiones o trampas, quedan pendientes de definición.

## 14. Módulos descargables

- Fútbol Nova tendrá una arquitectura modular para que el juego base de Android ocupe menos espacio y el usuario pueda descargar desde el propio juego los paquetes de contenido y sistemas ampliados que quiera utilizar.
- **Todos los módulos serán completamente opcionales.** El usuario podrá jugar al juego base y acceder a todos sus modos sin instalar módulos adicionales. Ningún modo de juego, competición o función esencial podrá exigir obligatoriamente la instalación de un módulo; los módulos solo ampliarán contenido, profundidad o capacidades adicionales.
- El primer módulo previsto será **Modo Realista**, descargable e instalable desde una sección de módulos dentro del juego. Incluirá los sistemas avanzados y recursos adicionales necesarios para elevar el detalle de la simulación: comportamientos y decisiones más profundos de jugadores, entrenadores y árbitros; disciplina y gestión de incidentes; física y animaciones contextuales ampliadas; simulación táctica y ambiental; presentación audiovisual y otros componentes de realismo que se definan durante el diseño técnico.
- El juego base conservará una experiencia futbolística completa y coherente, con las funciones esenciales para jugar. El módulo Realista añadirá profundidad, variedad y recursos de mayor detalle, evitando duplicar innecesariamente los componentes comunes del motor.
- Los módulos deberán descargarse bajo demanda, mostrar tamaño, espacio requerido, versión y dependencias antes de instalarse, verificar integridad y compatibilidad, y permitir gestionar su instalación desde el juego. La descarga deberá poder pausarse y reanudarse cuando la plataforma lo permita. El usuario podrá elegir la política de red para las descargas automáticas: permitir datos móviles y Wi-Fi, permitir únicamente Wi-Fi o permitir exclusivamente una red Wi-Fi sin uso de datos móviles. La elección se respetará tanto en las descargas automáticas de módulos como en las actualizaciones autorizadas; la interfaz deberá mostrar claramente la opción activa. Las descargas iniciadas manualmente también deberán informar qué tipo de conexión se utilizará.
- **Las actualizaciones requerirán siempre la decisión del usuario por defecto.** El juego informará cuando exista una actualización y mostrará la versión actual, la nueva versión, el tamaño de descarga, los cambios relevantes y los requisitos o posibles incompatibilidades; no descargará ni instalará la actualización sin autorización. Habrá dos niveles de control: un interruptor individual de actualización automática para cada módulo y una opción general para autorizar las actualizaciones automáticas de todos los módulos instalados. La opción general permitirá autorizarlos conjuntamente, mientras que los controles individuales permitirán excluir o autorizar módulos concretos; la configuración efectiva de cada módulo deberá mostrarse claramente. Ambas autorizaciones estarán desactivadas por defecto y el usuario podrá modificarlas o retirarlas cuando quiera. Solo se actualizarán automáticamente los módulos comprendidos en el alcance autorizado. Las actualizaciones críticas de seguridad también deberán respetar esta autorización, sin ocultar avisos ni cambiar silenciosamente la configuración. El usuario también podrá programar cuándo se buscan actualizaciones, con frecuencias configurables como diaria o semanal y, cuando sea viable, días y horas preferidos. La búsqueda programada solo detectará y notificará actualizaciones; descargar e instalar seguirá sujeto a las autorizaciones individuales o generales de actualización automática. Si no existe autorización para instalar, el juego mostrará la actualización disponible y esperará la decisión del usuario. El usuario podrá pausar, cambiar o desactivar la programación en cualquier momento. Cuando el usuario haya autorizado las actualizaciones automáticas, Fútbol Nova podrá descargar los paquetes correspondientes en segundo plano mientras juega, siempre que Android y las condiciones del dispositivo lo permitan. La descarga deberá limitar el impacto sobre el rendimiento, la conexión y la batería; podrá pausarse o posponerse si afecta a la experiencia de juego, hay poca batería, falta espacio o la conexión no es adecuada. La instalación o activación de una actualización no interrumpirá una partida en curso: se realizará en un momento seguro, por ejemplo al volver al menú principal o reiniciar el juego, y solo dentro del alcance autorizado.
- El usuario podrá instalar y mantener **varios módulos simultáneamente**, ya que cada módulo podrá aportar funciones diferentes. Los módulos compatibles deberán poder funcionar en conjunto; el sistema gestionará sus dependencias, conflictos, versiones y recursos compartidos, e informará claramente si dos módulos no pueden coexistir o requieren una actualización. La instalación de uno no deberá obligar a desinstalar otro salvo incompatibilidad técnica justificada y comunicada al usuario.
- La arquitectura deberá separar los sistemas comunes del motor y los paquetes opcionales, con interfaces y versiones compatibles. Desinstalar un módulo no deberá corromper partidas guardadas ni impedir el acceso al juego base o a sus modos. Si una partida contiene contenido ampliado asociado a un módulo que no está instalado, el juego deberá avisar y ofrecer instalarlo voluntariamente o utilizar una alternativa segura compatible con el juego base; nunca bloquear el acceso al modo por la ausencia del módulo.
- Los módulos instalados podrán activarse o desactivarse desde el juego cuando no se comprometa la integridad de una partida. Los datos guardados deberán identificar los módulos y versiones requeridos para cada partida.
- Se diseñará el sistema para admitir otros módulos descargables en el futuro, pero sus nombres, contenidos, funciones y prioridades quedan expresamente pendientes de definición por el usuario. No se crearán ni darán por aprobados otros módulos por iniciativa propia.
- La modularidad no deberá introducir riesgos de seguridad, dependencias opacas ni consumo innecesario de memoria o batería. Se revisarán procedencia, licencia, integridad, rendimiento y compatibilidad de cada paquete antes de distribuirlo.

## 15. Estado de implementación

Este documento recoge decisiones de diseño, no certifica que las funciones estén implementadas. El prototipo existente es una prueba de concepto 3D y no se debe presentar como un juego completo o probado hasta ejecutar y validar cada función en Godot y en los dispositivos objetivo.

## Referencias visuales y flujo de diseño

- FIFA 23 es la referencia visual y funcional principal solicitada para estudiar jerarquía, organización, navegación, hubs, ajustes, preparación de partidos, HUD, pausa, carrera y estadísticas. Las capturas aportadas por el usuario tienen prioridad para las pantallas que representan.
- Las referencias de FIFA 23 orientan el diseño, no autorizan copiar interfaces literalmente, marcas, logotipos, textos, bases de datos, imágenes, equipaciones, modelos, música, código ni otros activos protegidos. Fútbol Nova mantendrá identidad y contenido propios.
- Las referencias archivadas y los datos que se deben extraer de ellas están inventariados en [Catálogo maestro de datos](SCREEN_DATA_CATALOG.md) y [Archivo de referencias visuales](../assets/references/README.md).
- El menú principal vigente tiene exactamente cuatro pantallas: Inicio, Online, Modos y Configuración. La especificación normativa es [MAIN_MENU_FOUR_SCREENS.md](MAIN_MENU_FOUR_SCREENS.md). Las propuestas anteriores de tres pantallas quedan sustituidas.
- Ultimate Team está expresamente excluido del alcance. No diseñar ni implementar ese modo ni sus sistemas de cartas, sobres, monedas o mercado.
- El usuario ha indicado que, en esta fase, deben recopilarse y completarse los datos antes de integrar las pantallas. Por tanto, la documentación y auditoría de datos no debe modificar escenas, interfaces ni navegación del motor.
- Cuando posteriormente se autorice el diseño visual de una pantalla, se revisarán requisitos y referencias, se preparará un mockup original para revisión, se registrarán las correcciones y solo después se implementará y probará.
- Un mockup, una descripción o una especificación no equivalen a una pantalla implementada. Las funciones solo se declararán disponibles después de pruebas reales.
- Estas reglas complementan el estándar general de creación de juegos de Nova Nexus: `library/game-creation-standards.md`.


## Requisitos confirmados: idioma español y música global

### Idioma
- Fútbol Nova será un juego íntegramente en español. El español será el idioma predeterminado y cubrirá todos los elementos dirigidos al usuario: menús, botones, ajustes, instrucciones, tutoriales, objetivos, nombres de opciones, mensajes, notificaciones, errores, confirmaciones, ayudas, documentación integrada, accesibilidad, subtítulos y textos de modos y competiciones.
- La traducción debe ser coherente y natural en español; se evitarán cadenas visibles en inglés, textos de depuración y mezclas de idiomas.
- Los nombres propios ficticios, nombres propios de personas/lugares y denominaciones que deban conservarse por identidad no se traducirán arbitrariamente.
- Los recursos de audio hablados, narración y comentarios, cuando existan, tendrán español como idioma inicial. No se mostrará una opción de idioma de voz que no esté realmente disponible.
- El código interno, IDs, claves JSON y nombres técnicos pueden mantenerse en inglés si conviene a la implementación, pero nunca deben aparecer así en la interfaz.

### Música en todas las pantallas
- Si el usuario activa la música, la música de fondo debe poder reproducirse en todas las pantallas del juego: las cuatro secciones raíz, sus submenús y hubs, preparación de partido, pantallas de partido y resultados, pausa y configuración.
- La reproducción debe continuar al cambiar de pantalla sin reiniciarse innecesariamente ni producir cortes o superposiciones de pistas.
- Si el usuario desactiva la música, debe silenciarse globalmente en todas las pantallas. La preferencia se guarda y se respeta al volver a abrir el juego.
- El volumen de música se controla por separado del volumen de efectos, ambiente y voces/comentarios.
- La música debe respetar la preferencia del usuario durante transiciones y cargas. Si no hay pistas instaladas o disponibles, el juego permanece en silencio sin mostrar errores falsos.
- Solo se reproducirá música incluida legalmente o aportada por el usuario y compatible con el sistema; no se asumirán derechos sobre canciones comerciales.
- La activación de música no debe impedir escuchar efectos importantes, alertas, árbitro ni comentarios; se respetarán los controles de mezcla y volumen configurados por el usuario.

## Carrera de club: elección del cargo del usuario

Al iniciar una nueva partida de carrera de club, antes de comenzar la temporada, el usuario debe elegir el cargo desde el que administrará el club. Las dos opciones iniciales son:

### Entrenador principal
El usuario administra el área deportiva y las decisiones propias del primer entrenador:
- plantilla deportiva, convocatorias y alineaciones;
- formación, táctica, estrategia e instrucciones de partido;
- preparación, entrenamiento y desarrollo deportivo de jugadores;
- gestión deportiva de partidos, competiciones y objetivos del equipo;
- comunicación y decisiones del ámbito del vestuario que correspondan al entrenador.

### Presidente del club
El usuario administra la dirección institucional y estratégica:
- presupuesto, finanzas e inversiones del club;
- directiva y estructura ejecutiva;
- objetivos institucionales y planificación estratégica;
- instalaciones e infraestructura;
- decisiones de alto nivel sobre contratos, recursos y organización del club;
- nombramiento, evaluación y sustitución del entrenador principal y del personal directivo/deportivo que dependa de la presidencia.

### Separación de permisos
- Cada cargo habilita únicamente las herramientas y decisiones que le corresponden.
- Las funciones exclusivas del otro cargo no aparecen como acciones ejecutables ni pueden modificarse directamente.
- Cuando una decisión requiera coordinación entre ambas áreas, se representa mediante una propuesta, solicitud, informe o decisión formal dirigida al cargo responsable; no se concede acceso total por conveniencia.
- El cargo elegido se conserva en el guardado de esa carrera.
- La elección se realiza al crear la partida; cualquier posibilidad futura de cambiar de cargo deberá definirse como una acción explícita del juego y no se asumirá como disponible.
- Los nombres de cargos, opciones, mensajes y ayudas se muestran en español.

Esta elección define el rol de administración del usuario, no el puesto del entrenador/personaje dentro de la plantilla de empleados del club. El entrenador principal y el personal técnico siguen siendo entidades del club, con sus propios datos, contratos y responsabilidades.

**Estado:** requisito funcional aprobado por el usuario; el catálogo detallado de permisos, pantallas y flujos de cada cargo se especificará después. No implica implementación ni modificación de pantallas en esta fase.

## Funciones de experiencia y calidad de vida del jugador

Fútbol Nova incorporará funciones destinadas a que cada usuario pueda adaptar la experiencia, comprender mejor el juego, retomar sus partidas y disfrutar de una simulación accesible. Estas funciones son requisitos de diseño; no se consideran implementadas hasta que exista desarrollo y pruebas.

### Personalización de la experiencia de partido
- Perfiles de juego **Auténtico** y **Competitivo**: el primero prioriza ritmo, posicionamiento y comportamiento de fútbol realista; el segundo prioriza respuesta rápida y control directo. Se podrán ajustar individualmente sin obligar a usar una configuración predeterminada.
- Presets personalizables de dificultad y ayudas, con opción de ajustar por separado la dificultad de la IA, asistencia de pase, tiro, defensa, cambio de jugador y portero.
- Deslizadores de juego configurables para velocidad, errores, precisión, marcaje, frecuencia de desmarques y respuesta física, con restauración de valores recomendados.
- Guardar varios perfiles de configuración y asociarlos a modos o mandos cuando corresponda.

### Aprendizaje y práctica
- Centro de entrenamiento con tutoriales interactivos, ejercicios por habilidad y práctica libre.
- Tutoriales contextuales opcionales que expliquen controles, tácticas, menús y sistemas de carrera en el momento oportuno.
- Repetición de ejercicios y registro de mejores resultados para medir progreso.
- Consejos configurables: desactivados, básicos o detallados.

### Comprensión del partido
- Estadísticas en vivo y al descanso: posesión, tiros, tiros a puerta, precisión de pase, entradas, faltas, fueras de juego, córneres y mapa de disparos cuando los datos estén disponibles.
- Resumen posterior al partido con rendimiento individual, eventos clave, objetivos completados y consecuencias para la carrera.
- Repeticiones de goles y jugadas destacadas, con controles para guardar o revisar; las repeticiones no deben bloquear el avance si el usuario las omite.
- Panel táctico rápido para cambiar mentalidad, formación, instrucciones y sustituciones sin recorrer menús profundos.
- Indicadores visuales opcionales para mostrar controles, jugador seleccionado, dirección de pase y ayudas tácticas.

### Continuidad y protección de partidas
- Autoguardado configurable y visible, con protección contra sobrescritura accidental.
- Confirmación antes de borrar o reemplazar una partida; mostrar nombre, modo, fecha y progreso del espacio afectado.
- Recuperación del último guardado válido si una escritura se interrumpe, y validación de integridad al cargar.
- Reanudar rápidamente desde el último punto seguro, sin saltarse confirmaciones importantes.
- Funcionamiento local sin conexión para las funciones base; las funciones que requieran Internet deben identificarse claramente y no bloquear el juego offline.

### Accesibilidad y comodidad
- Modo de alto contraste con colores configurables para equipos, porteros, árbitros y balón.
- Ajuste de saturación del césped, sombras de jugadores/estadio y elementos visuales para mejorar la legibilidad.
- Subtítulos configurables en tamaño, color, fondo y sombra; narración de menús y ayudas de lectura cuando estén disponibles.
- Reasignación de controles, alternativas simplificadas para acciones complejas y ayudas ajustables.
- Opciones para reducir destellos, vibración, movimiento de cámara y elementos visuales intensos.
- Ajustes de audio independientes para música, efectos, ambiente y voces/comentarios, respetando el requisito de música global activable.

### Transparencia y control del usuario
- Mostrar claramente requisitos de conexión, estado de sincronización y qué datos permanecen solo en el dispositivo.
- Explicar antes de confirmar las consecuencias de decisiones de carrera, eventos inesperados, transferencias y cambios de configuración.
- Permitir ajustar o desactivar la frecuencia e impacto de eventos inesperados, manteniendo la coherencia del modo elegido.
- Notificaciones agrupadas y configurables; evitar avisos repetitivos y no interrumpir partidos ni flujos importantes.
- Todos los textos, voces, subtítulos, tutoriales y avisos visibles para el jugador estarán en español, según el requisito global de idioma.

### Rendimiento y estabilidad
- Opciones gráficas escalables según la capacidad del dispositivo, con preajustes y ajustes individuales.
- Indicador de rendimiento opcional y modo de ahorro para dispositivos modestos.
- Cargas progresivas y pantallas de carga con consejos útiles, sin ocultar errores reales.
- Manejo claro de fallos: explicar qué ocurrió, conservar el progreso seguro y ofrecer reintentar o volver atrás cuando sea posible.

**Regla de alcance:** estas funciones deben integrarse dentro de las cuatro pantallas raíz y sus submenús existentes; no crean nuevas secciones raíz ni alteran la navegación horizontal circular ya aprobada. Ultimate Team continúa excluido. Primero se documentan y priorizan; su implementación se realizará cuando el usuario la autorice.

## Requisitos fundamentales: juego offline y universo de jugadores ficticios
Fútbol Nova debe poder jugarse íntegramente sin conexión a Internet. La experiencia principal no dependerá de servicios remotos, inicio de sesión online, servidores ni sincronización en la nube.

### Funcionamiento sin conexión
- El juego debe iniciar y permitir crear, cargar y continuar partidas sin Internet.
- Partidos, amistosos, entrenamiento, modos Leyenda y Entrenador, ligas, copas, torneos personalizados, gestión de clubes, fichajes simulados, cantera, estadísticas y guardados deben funcionar localmente.
- La IA de los equipos y jugadores, calendario, competiciones, mercado y progresión de carrera se ejecutarán en el dispositivo.
- Los datos esenciales, plantillas ficticias, reglas, recursos básicos y configuración se instalarán con el juego o podrán instalarse mediante paquetes descargables antes de jugar; una vez instalados, no requerirán conexión.
- No habrá comprobaciones online obligatorias, DRM dependiente de red ni bloqueo por pérdida de conexión durante una partida.
- Las funciones que realmente necesiten Internet serán opcionales, claramente identificadas y nunca impedirán usar el juego base.
- Guardados locales y copias de seguridad locales estarán disponibles sin cuenta ni nube. La sincronización externa, si se incorpora, será opcional.

### Identidad regional de los clubes
- Todos los clubes del juego deberán llevar en su nombre visible el nombre de la región geográfica a la que pertenecen.
- La regla se aplicará sin excepciones a las diez ligas iniciales y a los clubes incluidos en módulos futuros.
- La región se expresará mediante la división territorial apropiada de cada país (por ejemplo, provincia, comunidad autónoma, departamento, estado o ciudad).
- Si una región tiene más de un club, se añadirán distintivos ficticios para diferenciarlos, manteniendo siempre el nombre regional.
- Los nombres y distintivos serán originales y no reproducirán marcas ni nombres comerciales protegidos de clubes reales.

### Cantidad y naturaleza de la base de jugadores
- Objetivo de escala: al menos 20.000 futbolistas ficticios, tomando como referencia de magnitud los más de 20.000 jugadores anunciados para EA SPORTS FC 26.
- Esta cifra es una meta de contenido de Fútbol Nova, no una autorización para copiar o extraer bases de datos, nombres, imágenes, atributos, escaneos, likeness, plantillas o contenido protegido de EA u otros titulares.
- Todos los futbolistas serán originales y ficticios. No se representará a jugadores reales ni se crearán equivalentes deliberadamente identificables.
- Los nombres, rostros, biografías, nacionalidades, atributos, clubes, historiales y estadísticas serán generados o creados para Fútbol Nova.
- Fútbol Nova no incluirá ni utilizará competiciones femeninas. Las ligas, copas, torneos y plantillas jugables del proyecto se definirán sin competiciones femeninas.
- La cifra objetivo debe incluir jugadores de primer equipo, reservas, cantera y agentes libres, sin duplicar identidades para inflar el total.

**Estado:** requisitos aprobados por el usuario. La meta de 20.000+ es un objetivo de contenido; la cantidad final y distribución por ligas, clubes, género, edad y categoría se concretarán en el plan de datos y se validarán con herramientas de generación y rendimiento.


## Reglas oficiales de ligas y copas y configuración de la competición

- Los modos **Ligas** y **Copas** deberán reproducir exactamente el reglamento oficial de la competición seleccionada, correspondiente a la edición o temporada tomada como referencia y debidamente documentada. No se simplificarán, combinarán, inventarán ni modificarán sus reglas para adaptar la competición al juego.
- Se respetarán, cuando correspondan, el número y la composición de participantes, fases, grupos, jornadas, calendario, sistema de puntos, criterios de desempate y clasificación, partidos de ida y vuelta, reglas de goles, prórrogas, tandas de penaltis, sustituciones, sanciones, ascensos, descensos, plazas clasificatorias y cualquier otra disposición oficial.
- Las reglas pueden variar entre temporadas o ediciones. Cada competición deberá asociarse a una versión identificada de su reglamento; no se presentará como vigente una regla que no haya sido verificada. Si no se encuentra una disposición fiable, se marcará como pendiente de verificación y no se inventará.
- Al crear una liga o copa, el jugador podrá configurar los detalles que el propio reglamento permita o que no alteren la integridad deportiva de la competición. Entre ellos podrán estar la selección del equipo participante cuando proceda, el nombre de la partida/torneo personalizado, la dificultad de la IA, controles, cámara, presentación y otros ajustes de experiencia.
- Las opciones que cambien una regla oficial —por ejemplo, número de equipos, sistema de puntuación, número de jornadas o rondas, estructura de grupos/fases, desempates, ascensos/descensos, partidos de ida/vuelta o criterio de clasificación— no podrán utilizarse para modificar una competición oficial. Se mostrarán bloqueadas o no se ofrecerán en ese modo.
- Si se ofrece un torneo personalizado con reglas distintas, deberá identificarse claramente como **competición personalizada**, no como reproducción oficial de la liga o copa. Esta opción no sustituirá ni alterará el formato oficial de la competición seleccionada.
- La configuración de partido (por ejemplo, controles, cámara, dificultad y ayudas) no podrá anular las reglas obligatorias de la competición. Las opciones incompatibles con el reglamento quedarán desactivadas automáticamente en partidos oficiales.
- Antes de comenzar, el juego mostrará un resumen de la competición, su temporada/reglamento aplicado y las opciones que el jugador sí puede personalizar. La partida guardará la versión del reglamento para conservar la coherencia durante toda la competición.
- Esta norma se aplica a las diez ligas nacionales iniciales, a todas las copas incluidas y a las competiciones añadidas mediante módulos futuros.

**Estado:** requisito confirmado por el usuario. La investigación y documentación de cada reglamento nacional y de cada copa se realizará por separado antes de declarar completa su implementación. No autoriza todavía cambios en pantallas, escenas, interfaz, navegación ni integración en Godot.


## Calendarios y reglamentos oficiales de ligas y copas — regla global

- Todas las competiciones oficiales incluidas en Fútbol Nova utilizarán las bases de competición, reglamentos, estructura y calendario publicados por el organismo competente para la temporada concreta.
- La fecha de inicio y la secuencia de jornadas/rondas se tomarán del calendario oficial de esa edición. No se desplazará el inicio al día en que el jugador crea su partida ni se generarán fechas ficticias.
- Se conservarán formato, participantes, número de jornadas o rondas, fases, puntuación, desempates, prórrogas, penaltis, sustituciones, sanciones, ascensos, descensos y criterios de clasificación tal como establezca el reglamento aplicable.
- Las fechas y horarios que el organismo marque como sujetos a modificación se tratarán como programaciones provisionales y se actualizarán solo cuando exista una modificación oficial verificable.
- La configuración del jugador se limitará a opciones que no contradigan ni alteren las bases oficiales. Una competición con reglas cambiadas se identificará como personalizada y no como edición oficial.
- La base de datos de cada competición almacenará país, organismo, nombre oficial, temporada, versión/fecha de publicación de la norma, URL o referencia de la fuente, fecha inicial/final, rondas, reglas, estado de verificación y fecha de última revisión.
- Si no se ha publicado el reglamento o calendario oficial de una temporada, el contenido quedará marcado como pendiente de verificación; no se rellenarán vacíos con reglas genéricas ni se presentará una edición anterior como vigente.
- Esta política se aplica a las diez ligas nacionales base y a todas las copas nacionales que se incorporen, así como a cualquier módulo futuro.
- Los clubes y futbolistas seguirán siendo ficticios y originales. La fidelidad reglamentaria no autoriza copiar marcas, escudos, plantillas ni bases de datos protegidas.


## Derechos de identidad visual: escudos y uniformes

- Antes de incorporar cualquier escudo, uniforme o elemento de identidad real de un club, Fútbol Nova deberá realizar y registrar una comprobación de derechos por activo y por territorio de distribución.
- La comprobación abarcará marcas registradas y no registradas, derechos de autor, diseños registrados, titulares, licencias y derechos de terceros (fabricantes, patrocinadores, ligas, federaciones y fotógrafos). Se consultarán las bases oficiales pertinentes, incluidas WIPO, EUIPO/TMview, USPTO y registros nacionales cuando proceda.
- Un resultado de búsqueda sin coincidencias no equivale a una autorización ni demuestra por sí solo que el activo sea de libre uso. Si no existe evidencia suficiente o licencia válida, el activo real no se utilizará.
- Cuando el uso esté legalmente autorizado o se documente una situación de libre uso aplicable, podrá utilizarse el activo dentro de su alcance autorizado. Los permisos del club no cubren automáticamente marcas de fabricantes, patrocinadores o competiciones.
- Si el activo está protegido, la situación es dudosa o no se puede verificar, se crearán escudos y uniformes originales que mantengan los colores tradicionales y la identidad cromática general del equipo, pero con composición, silueta, símbolos, tipografía y patrones suficientemente distintos. No se calcarán ni imitarán elementos distintivos hasta producir confusión con el original.
- Todos los equipos tendrán una ficha de auditoría con activo, titular, registro/territorio, fuentes consultadas, evidencia, permiso, conclusión, estado y fecha de revisión. Los estados serán: pendiente, protección localizada, protección confirmada, licencia documentada, uso libre documentado o diseño original requerido.
- No se publicarán ni empaquetarán activos con estado pendiente, dudoso o protegido sin licencia. Esta política no modifica las reglas deportivas ni autoriza a copiar bases de datos, fotografías o materiales de terceros.
