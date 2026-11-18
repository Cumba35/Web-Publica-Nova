# Fútbol Nova — Controles táctiles, regates y habilidades

**Estado:** joystick virtual y botones táctiles iniciales conectados al controlador del jugador; gestos avanzados, carga progresiva, animaciones contextuales y pruebas Android siguen pendientes.  
**Plataforma prioritaria:** Android táctil.  
**Principio rector:** los gestos solicitan acciones; las estadísticas, la situación del partido, la animación disponible y las reglas determinan su ejecución y resultado.

## 1. Esquema de controles

- **Implementado inicialmente:** joystick virtual izquierdo que envía dirección e intensidad a las acciones de movimiento. La velocidad todavía no está vinculada de forma completa a atributos, resistencia y fatiga.
- **Implementados inicialmente:** botones táctiles de Pase, Tiro, Técnica y Presión, conectados a las acciones del controlador. Las variantes gestuales descritas más abajo siguen pendientes.
- El botón antiguo de sprint se convierte en el **botón de habilidades y técnicas**. No activa sprint directamente. Mantenerlo y deslizarlo ejecuta técnicas direccionales; mantenerlo y dibujar un círculo solicita una habilidad avanzada aleatoria elegible.
- El botón de disparo admite disparo cargado, recorte lateral con disparo automático y disparo picado.
- El botón de pase admite pase raso cargado, pase elevado, recorte lateral seguido de pase raso y pase atrás de tacón.
- El botón de presión admite presión normal y solicitud de ayuda de un compañero mediante gesto hacia arriba mantenido durante un segundo.
- Los controles deben funcionar con ratón/mando durante pruebas y con zonas táctiles configurables en Android. La interfaz debe reconocer el gesto iniciado dentro del botón, no exigir que el dedo permanezca dentro de su área visual.

## 2. Joystick progresivo y carrera

La distancia radial desde el centro del joystick determina la intensidad deseada de movimiento. Cerca del centro se camina o se desplaza despacio; al alejarlo progresivamente se incrementa la velocidad hasta solicitar carrera a máxima intensidad.

La velocidad real nunca supera los límites derivados de los atributos del futbolista: aceleración, velocidad, resistencia, fatiga, estado físico, lesión y contexto de juego. El joystick no concede velocidad adicional ni iguala a jugadores con estadísticas distintas. Aplicar curva de respuesta configurable y zona muerta para evitar movimientos involuntarios; limitar el vector diagonal para que no otorgue más velocidad que el desplazamiento recto.

La carrera consume resistencia según velocidad, duración y estado del jugador. Cuando la resistencia baja, el rendimiento se reduce progresivamente conforme al modelo físico general.

## 3. Reconocimiento de gestos

Cada botón de acción debe tener estados `idle`, `pressed`, `charging`, `gesture_candidate`, `executing` y `released`. Registrar posición inicial, trayectoria, duración y dirección dominante del dedo. Aplicar umbral mínimo de desplazamiento, tolerancia angular, ventana temporal y cancelación al sacar el dedo de la pantalla o abrir una interrupción del sistema.

- Un toque sin desplazamiento ejecuta la acción principal.
- Un deslizamiento direccional ejecuta la variante asignada a esa dirección.
- Una secuencia de direcciones se reconoce como combo solo cuando el orden y los umbrales están completos.
- Un círculo requiere trayectoria cerrada alrededor del punto inicial, sentido y tolerancia geométrica configurables. No debe confundirse con un simple movimiento irregular.
- La carga de potencia y el reconocimiento de gesto deben coexistir sin disparos o pases accidentales. En gestos con habilidad, la acción se ejecuta al completar el gesto; la duración de carga se conserva para calcular la potencia de la acción posterior cuando corresponda.
- Si una animación, choque, pérdida de posesión o interrupción invalida el gesto, cancelarlo de forma segura sin duplicar acciones.

## 4. Botón de disparo

### Toque y mantenimiento
Al tocar comienza la carga del disparo. La potencia aumenta con el tiempo de presión hasta el máximo de la barra; al llenarse, el disparo se ejecuta automáticamente. Mantener más tiempo no acumula potencia adicional. A mayor potencia, menor precisión, con variación limitada por técnica de tiro, equilibrio, pierna hábil, postura, presión rival, distancia, fatiga y calidad del contacto.

### Deslizar a izquierda o derecha
Solicita un recorte/cambio de dirección hacia el lado elegido, si la técnica, el espacio y el nivel del jugador lo permiten. Al finalizar la animación, se ejecuta automáticamente el disparo. El tiempo de presión determina la carga del disparo posterior: más potencia implica menos precisión. Si la habilidad no puede ejecutarse, resolver con una respuesta contextual coherente (toque de protección o cancelación), sin teletransportar al jugador ni garantizar el disparo.

### Deslizar hacia arriba
Solicita un disparo picado. La potencia depende del tiempo de presión y la precisión disminuye al aumentar la potencia. La trayectoria, altura y posibilidad de superar al portero dependen de atributos, distancia, posición corporal, contacto con el balón y situación del guardameta.

## 5. Botón de pase

- **Toque/mantenimiento:** pase raso. La potencia aumenta con el tiempo de presión; la precisión disminuye al aumentar la potencia.
- **Deslizar hacia arriba:** pase elevado. La carga determina potencia/alcance y afecta negativamente a la precisión al aumentar.
- **Deslizar a izquierda/derecha:** intenta un recorte aleatorio controlado hacia el lado seleccionado y, al terminar, ejecuta un pase raso. La probabilidad y calidad del recorte dependen del nivel técnico, control, equilibrio, pierna hábil, velocidad y presión rival. La selección aleatoria se limita a variantes compatibles con el lado y la animación.
- **Deslizar hacia abajo:** pase atrás de tacón. Su éxito y precisión dependen de técnica, orientación corporal, control, presión y posición del compañero.

La selección del receptor y la trayectoria del balón consideran compañeros, rivales, líneas de pase, distancia, fuerza aplicada y atributos del pasador. La carga no debe convertir automáticamente un pase fuerte en un pase preciso.

## 6. Botón de habilidades y técnicas (sustituye al sprint)

El botón principal de regates usa la dirección del gesto para solicitar:

| Gesto | Técnica solicitada | Categoría |
|---|---|---|
| Toque/mantener | Auto pase: empujar el balón hacia delante y correr tras él | Básica |
| Arriba | Sombrerito y avance para superar al rival frontal | Básica |
| Abajo | Hueca/caño y avance para superar al rival frontal | Básica |
| Izquierda | Elástica y avance | Básica |
| Derecha | Bicicleta y avance | Básica |
| Derecha y después abajo | Marsellesa y avance | Intermedia |
| Izquierda y después arriba | Elástica aérea y avance | Intermedia |
| Izquierda y después abajo | Ruleta con caño incluido y avance | Intermedia |

Las cinco líneas intermedias restantes mencionadas en la solicitud original quedan como **espacios reservados sin técnica asignada**. No se inventarán movimientos hasta que se definan.

La dirección del avance se calcula según el espacio libre y la orientación de ataque, evitando que la animación obligue a correr hacia un rival. La técnica no desplaza al jugador de forma instantánea: usa animación, contacto real con el balón y física. Si hay un rival delante, el jugador intenta superarlo; el éxito depende de sus atributos y de la respuesta defensiva rival.

### Probabilidad de ejecución

La probabilidad de iniciar y completar correctamente una técnica depende principalmente de nivel de habilidad técnica, control del balón, equilibrio, agilidad, pierna hábil, velocidad, fatiga, postura, espacio disponible y presión/atributos del defensor. El nivel no debe ser el único factor. Un intento fallido debe producir una animación/resultado plausible (toque largo, pérdida de control o balón disputado), no una falta automática.

### Gesto circular: habilidad avanzada aleatoria

Mantener el botón y dibujar un círculo solicita una habilidad avanzada aleatoria entre las que el futbolista tenga equipadas, activas, con usos disponibles y cuyos requisitos contextuales se cumplan. Si no tiene habilidades avanzadas equipadas/elegibles, no ocurre nada. Las habilidades avanzadas no fallan una vez que se cumplen sus condiciones y se consumen correctamente. Si la habilidad elegida requiere una condición que no se cumple, se excluye de la selección y se intenta otra habilidad elegible; si no queda ninguna, no se ejecuta ninguna.

## 7. Botón de presión y ayuda de compañero

- Toque: el futbolista controlado presiona al rival que tiene la posesión, respetando distancia, orientación, velocidad, resistencia y capacidad defensiva.
- Mantener y deslizar hacia arriba durante **1 segundo**: solicitar ayuda de presión al compañero cercano mejor situado. El compañero se desplaza para cerrar o presionar al poseedor, según ángulo y cobertura, sin abandonar de forma absurda su zona ni abrir automáticamente un espacio decisivo.
- La ayuda depende de distancia, resistencia, atributos defensivos, disciplina táctica, posición, marcaje y estado de la jugada. Si ningún compañero es apto o está cerca, no se solicita una carrera imposible.
- La presión coordinada no equivale a robo automático. El resultado depende de la entrada, el control del rival, el árbitro y las reglas de contacto.

## 8. Habilidades avanzadas equipables

Cada jugador puede tener hasta **3 habilidades avanzadas equipadas** y puede conservar otras habilidades obtenidas pero inactivas/no equipadas.

### Desbloqueo de espacios y requisitos por rango

| Nivel general del jugador | Espacios de habilidad avanzada |
|---:|---:|
| Menos de 70 | 0 |
| 70–79 | 1 |
| 80–89 | 2 |
| 90 o más | 3 |

Requisito mínimo por estrellas de la habilidad:

- 1–2 estrellas: nivel general 70 o superior.
- 3–4 estrellas: nivel general 80 o superior.
- 5 estrellas: nivel general 90 o superior.

El nivel general debe cumplir el requisito y el jugador debe disponer de un espacio libre. No se puede equipar una habilidad cuyo rango supere el nivel mínimo permitido, aunque el jugador la haya desbloqueado. La adquisición se plantea para el modo Leyenda mediante tareas/recompensas y otros métodos futuros; los métodos concretos quedan pendientes de diseño.

### Límite de usos

Las habilidades avanzadas tienen un límite compartido de **3 activaciones por jugador y partido**, sumando todas sus habilidades equipadas. El contador se reinicia al comenzar un nuevo partido y no se comparte entre futbolistas. Las activaciones contextualmente inválidas no consumen uso. La habilidad se consume al iniciar su ejecución válida; las interrupciones externas posteriores no deben permitir duplicar usos.

### Catálogo inicial

| Habilidad | Rango | Efecto y condiciones |
|---|---:|---|
| Disparo seguro | 5 estrellas | Ejecuta un disparo cuya trayectoria va a puerta. No garantiza gol: el portero puede detenerlo según distancia, colocación, reacción y diferencia de atributos entre portero y tirador. |
| Barrida segura | 4 estrellas | Contra el rival que está presionando/posee el balón, ejecuta una barrida limpia que recupera el balón sin derribar al rival y sin cometer falta. Solo se activa si existe un objetivo válido y el contacto puede resolverse dentro de las reglas espaciales del juego. |
| Pase crítico | 5 estrellas | Envía un pase filtrado aéreo al delantero mejor posicionado para atacar. El receptor puede rematar directamente al llegar el balón, incluso en el aire, si la animación y posición permiten el remate. La elección del delantero evalúa posición, desmarque, fuera de juego y viabilidad de la trayectoria. |
| Chilena de estrella | 5 estrellas | Solo se activa si el futbolista controlado está atacando dentro del área rival y el balón llega por el aire en una altura/posición válida para chilena. Si no se cumple, se excluye y se prueba otra habilidad avanzada elegible. Ejecuta una chilena potente hacia una de las dos escuadras elegida aleatoriamente; el diseño solicitado establece gol garantizado, incluso si el jugador mira en dirección contraria. |
| Volea potente | 4 estrellas | Solo se activa si el futbolista está atacando dentro del área rival y el balón llega por el aire en una altura/posición válida para volea. Si no se cumple, se excluye y se prueba otra habilidad avanzada elegible. Ejecuta una volea potente hacia una de las dos escuadras elegida aleatoriamente, con probabilidad de gol del 60%, incluso si el jugador mira en dirección contraria. |

**Regla de contexto:** Chilena de estrella y Volea potente nunca se activan fuera de sus condiciones. Si se solicita el círculo y alguna no es válida, se selecciona otra habilidad elegible sin gastar un uso de la habilidad excluida.

**Nota de balance:** Disparo seguro significa tiro dirigido a portería, no gol seguro. Chilena de estrella es la excepción solicitada con gol garantizado. Volea potente conserva el 60% de probabilidad indicado. Estas habilidades especiales deben quedar claramente identificadas en el diseño y someterse a pruebas de balance.

## 9. Combos de habilidades

Se podrán definir combinaciones de habilidades que se complementen. Cuando se ejecute un combo reconocido y válido, el beneficio combinado será un **20% superior** al beneficio base de las habilidades que lo componen. El bono se aplica una sola vez al efecto combinado, no se acumula recursivamente con cada habilidad ni supera límites físicos/reglamentarios salvo que una habilidad avanzada indique expresamente una excepción. La lista de combos concretos, compatibilidades y atributos beneficiados queda pendiente de definición; no se inventan combos automáticamente.

## 10. Datos de jugador y persistencia

Cada jugador tendrá datos separados para: nivel general, estrellas/rango de habilidades, habilidades desbloqueadas, habilidades equipadas, habilidades activas, espacios disponibles y usos restantes del partido. Guardar el catálogo y las configuraciones con IDs estables y versión de esquema. Los usos por partido se guardan en el estado de partido y se reinician al crear uno nuevo; no modifican el progreso permanente del jugador.

## 11. Pruebas de aceptación

1. Validar el joystick en Android y completar su integración con velocidad, aceleración, atributos y resistencia.
2. El botón de sprint ya no produce sprint directo; abre las técnicas por gesto.
3. Cada dirección/combos de gesto activa solo la técnica asignada.
4. El círculo no activa habilidades avanzadas inexistentes, inactivas, agotadas o contextualmente inválidas.
5. Cada jugador nunca equipa más de tres habilidades avanzadas y respeta niveles/estrellas.
6. El límite compartido de tres usos por jugador y partido no puede eludirse cambiando de habilidad.
7. Los disparos y pases cargados aumentan potencia y reducen precisión según el modelo de atributos.
8. Los recortes laterales completan la técnica antes de disparar/pasar automáticamente.
9. El pase atrás de tacón, pase elevado, disparo picado y auto pase se reconocen sin confundir gestos.
10. La ayuda de presión solo se solicita tras mantener el gesto hacia arriba durante un segundo y solo con un compañero viable.
11. Chilena y volea solo se activan dentro del área rival con balón aéreo y usan la alternativa elegible cuando la condición falla.
12. Los gestos cancelados por pérdida de posesión, falta, interrupción o cambio de jugador no ejecutan acciones duplicadas.
13. Los controles se prueban en distintas relaciones de aspecto, tamaños de pantalla y zonas táctiles configurables.

## 12. Pendientes explícitos

- Asignar las cinco técnicas intermedias que quedaron sin nombre.
- Definir fórmulas numéricas de precisión, potencia, probabilidad de regate y oposición defensiva mediante pruebas.
- Definir los combos concretos y el sistema para obtener/desbloquear habilidades avanzadas en Leyenda.
- Validar animaciones, ventanas de gesto, tolerancias táctiles y rendimiento en Android.


## Actualización 13-11-2026 — habilidades por nivel y Modo Leyenda

Esta regla sustituye la tabla anterior de espacios equipables: el umbral máximo de tres espacios es **más de 90**, no 90 exactos.

- **Nivel 1:** overall 70–79; tres habilidades disponibles en el catálogo y máximo una equipada.
- **Nivel 2:** overall 80–90; tres habilidades disponibles en el catálogo y máximo una equipada.
- **Nivel 3:** overall 91–99; tres habilidades disponibles en el catálogo y máximo una equipada.
- **Menos de 70:** ningún espacio equipable.

En Modo Leyenda se pueden almacenar hasta nueve habilidades (tres por nivel), equipar una por nivel y utilizar como máximo tres activas a la vez. Al subir de nivel general se otorga aleatoriamente una habilidad del nivel que corresponda al nuevo overall. No se duplican habilidades y el inventario de cada nivel no supera tres.

Los jugadores de las plantillas estándar no tienen inventario secundario ni habilidades almacenadas: reciben únicamente habilidades activas según el overall, con umbrales 70, 80 y 91. El sistema no usa nacionalidad para asignar habilidades.

El catálogo inicial de nueve habilidades está en `data/skills/skill_catalog.json`. Los efectos son temporales y deberán equilibrarse con pruebas de partido antes de considerarlos definitivos.


**Precedencia de reglas:** la actualización del 13-11-2026 sustituye cualquier tabla anterior de espacios o requisitos por estrellas. Las cinco habilidades especiales descritas en el catálogo previo se mantienen como habilidades del juego y se incorporan progresivamente al catálogo por niveles; sus condiciones de activación y balance siguen siendo aplicables. El catálogo inicial de nueve habilidades y la implementación de progresión están en `data/skills/skill_catalog.json` y `scripts/player_skill_system.gd`.



## Rareza/calidad de habilidades por estrellas — 13-11-2026

Todas las habilidades tendrán una clasificación de **1 a 5 estrellas** (★☆☆☆☆ a ★★★★★). Las estrellas representan la calidad, complejidad y potencia del efecto, no el nivel de desbloqueo.

Cada habilidad tendrá dos datos independientes: `level` (1, 2 o 3) y `stars` (1 a 5). El overall determina qué nivel puede desbloquear/equipar; las estrellas no añaden espacios ni permiten duplicar habilidades de un mismo nivel. Por tanto, puede existir una habilidad de nivel 1 con cinco estrellas o una de nivel 3 con una estrella.

Escala de diseño actualizada: 1 estrella = básica; 2 = mejorada; 3 = especializada; 4 = élite; 5 = avanzada/legendaria. Las habilidades que estaban identificadas como avanzadas en la especificación anterior pasan a 5 estrellas. Las habilidades de más estrellas deberán equilibrarse con efectos más fuertes, condiciones de activación y contrajuego adecuados. El catálogo asigna provisionalmente una estrella a cada habilidad hasta completar el balance individual.


## Corrección de clasificación — 13-11-2026

Las habilidades que estaban marcadas expresamente como **avanzadas** en la especificación anterior se clasifican ahora como **5 estrellas**. Se actualiza Disparo seguro de 3 a 5 estrellas. Las habilidades que ya tenían una valoración explícita de 4 o 5 estrellas conservan esa clasificación. Las habilidades sin una clasificación individual anterior siguen en 1 estrella provisional hasta su balance. Esta corrección afecta a la rareza/calidad, no cambia el nivel 1–3, los umbrales de overall, los espacios ni los límites de equipamiento.


## Catálogo posicional completo — 13-11-2026

El catálogo contiene **300 habilidades originales**: 100 por nivel (10 portero, 30 defensor, 30 mediocampista y 30 delantero). Se conservan los nueve IDs iniciales. Los rangos definitivos son nivel 1: 1–2 estrellas; nivel 2: 3–4; nivel 3: 5. Las estrellas no conceden espacios.

Las posiciones se agrupan como POR; DFC/LI/LD; MCD/MC/MCO/MI/MD; EI/ED/DC. Cada habilidad define descripción, efecto, condiciones, enfriamiento y balance. Ninguna garantiza goles ni recuperaciones. En Leyenda se ofrecen tres opciones distintas por cada nivel recién desbloqueado; el usuario elige y puede cambiar entre las almacenadas, con una activa por nivel. En plantillas estándar se asigna una habilidad compatible por espacio, sin inventario secundario.


## Mecánicas estructuradas del catálogo — 13-11-2026

Cada habilidad del catálogo 2.1.0 incluye una familia de acción, identificador de concepto, disparador contextual, atributos ponderados, modificador, duración, alcance, coste de resistencia, enfriamiento, límites, resultado de fallo y contrajuego. El motor de partido deberá leer `mechanics` y ejecutar la animación/acción correspondiente; los valores iniciales no se consideran balance definitivo.

**Excepciones conservadas:** Disparo seguro apunta a portería, pero puede ser detenido; Barrida segura recupera limpiamente el balón solo cuando se puede ejecutar una entrada legal; Volea potente mantiene 60% de probabilidad de gol; Chilena de estrella garantiza gol tras un contacto válido dentro del área rival y con balón en la ventana de chilena. Las dos últimas no deben activarse fuera de sus condiciones y, si no son elegibles, el selector debe probar otra habilidad sin consumir su uso.

**Pendiente de implementación:** conectar cada `action_family` a las mecánicas y animaciones del partido, resolver las probabilidades con atributos reales y validar todos los casos en Godot. La existencia de datos estructurados no significa que el efecto ya se ejecute en el juego.

## Activación definitiva por gesto circular — 13-11-2026

La activación de habilidades avanzadas se solicita dibujando un **círculo cerrado alrededor del botón de gestos**. No se activa tocando el botón, manteniéndolo pulsado ni realizando un deslizamiento direccional: debe reconocerse el círculo completo.

Al completar el círculo, el sistema reúne las habilidades activas/equipadas del futbolista y descarta todas aquellas cuyos requisitos particulares no se cumplan en ese instante. De las que queden elegibles, selecciona **una al azar con probabilidad uniforme** y solicita su ejecución. No se puede seleccionar una habilidad guardada pero no equipada.

- Cada futbolista dispone de **3 activaciones como máximo por partido**, compartidas entre todas sus habilidades equipadas.
- El contador es individual: el uso de un jugador no reduce los usos de sus compañeros ni de los rivales.
- Se consume un uso solamente cuando una habilidad elegible comienza una ejecución válida.
- Si el balón no está en juego, el jugador no puede actuar o ninguna habilidad cumple sus requisitos, no se activa nada y no se consume uso.
- Si una habilidad está en enfriamiento, el evaluador del partido debe excluirla antes del sorteo.
- El contador vuelve a cero al inicializar cada nuevo partido.
- El gesto circular no permite saltarse requisitos, animaciones, fuera de juego, faltas, ventanas de balón ni restricciones propias de cada habilidad.

**Contrato de integración:** el reconocedor táctil avisa cuando termina un círculo válido; el evaluador del partido genera la lista eligible_skill_ids; PlayerSkillSystem.activate_random_skill() filtra esa lista contra las habilidades equipadas, elige una aleatoriamente y descuenta el uso. La ejecución real de la animación y del efecto sigue correspondiendo al controlador del partido.

**Estado de implementación:** la política está documentada y el núcleo de selección/contador está añadido a player_skill_system.gd. Todavía falta conectar el reconocedor del círculo del botón táctil y el evaluador contextual con el controlador del partido, además de probarlo en Godot.


## Implementación del reconocedor circular — 13-11-2026

Se añade `scripts/skill_gesture_button.gd`, un control táctil reutilizable para el botón de habilidades del HUD. El jugador debe iniciar el trazo en el anillo exterior del botón, rodear su centro y cerrar la trayectoria cerca del punto inicial. Se aceptan gestos táctiles Android y ratón para pruebas.

El reconocedor valida:
- inicio dentro de la zona del control y a una distancia exterior del centro;
- al menos 12 puntos de trayectoria;
- cierre dentro de la tolerancia configurada;
- cobertura angular mínima de aproximadamente 295 grados;
- radio medio dentro del anillo permitido y variación radial limitada;
- cancelación si el dedo sale de la zona o se libera fuera del control.

Al completar un círculo válido emite `circle_gesture_completed`. El HUD de `main.gd` escucha la señal y muestra una confirmación visual. **Esta señal todavía no activa una habilidad:** falta el evaluador de requisitos del partido y la integración con el perfil real del jugador y `PlayerSkillSystem.activate_random_skill()`. No se debe considerar terminada la activación de habilidades hasta completar esa integración y probarla en Godot/Android.


## Actualización — cinco técnicas comunes para gestos reservados (13-11-2026)

Se asignan las cinco combinaciones intermedias que estaban reservadas. Las secuencias se reconocen en el orden indicado y solo se ejecutan al completar ambas direcciones:

| Gesto en el botón de habilidades | Técnica | Acción solicitada |
|---|---|---|
| Arriba → derecha | **Croqueta** | Pasar el balón de un pie al otro y salir en diagonal |
| Arriba → izquierda | **Finta de cuerpo** | Engañar con hombros/cadera y salir al lado contrario del defensor |
| Abajo → derecha | **Arrastre atrás y salida** | Arrastrar el balón con la planta y salir en diagonal derecha |
| Abajo → izquierda | **Giro de protección** | Proteger el balón con el cuerpo, girar y salir a la izquierda |
| Derecha → arriba | **Amago de disparo** | Simular el golpeo, cancelar el tiro y conducir hacia delante |

Estas cinco técnicas son regates comunes, no habilidades avanzadas del catálogo de 300. Sus requisitos, atributos ponderados, contrajuego, resultados de fallo y enfriamientos iniciales están definidos en `data/skills/common_gesture_techniques.json`. El éxito depende del control, equilibrio, agilidad/fuerza según la técnica, espacio disponible, fatiga y respuesta del defensor. Ninguna técnica garantiza superar al rival ni desplaza instantáneamente al futbolista.

**Reglas de reconocimiento:** el orden de las direcciones importa; cada tramo debe superar el umbral de desplazamiento y el cambio angular mínimo. La ventana total inicial es de 850 ms. No se ejecuta la primera dirección como acción independiente si el gesto todavía puede convertirse en una secuencia; si se interrumpe o se pierde el balón, se cancela sin duplicar acciones.

**Estado real:** el catálogo de datos y esta asignación quedan definidos. El reconocedor circular existente no reconoce todavía secuencias direccionales; falta integrar este contrato en el botón táctil, enlazar las acciones con animaciones/física y probarlas en Godot y Android. No se considera implementado el control en tiempo de juego hasta completar esas tareas.


## Nueva ampliación — gesto táctil para todas las jugadas a balón parado (14-11-2026)

Se añade el componente reutilizable `scripts/set_piece_swipe_controller.gd`. El usuario dibuja con el dedo la trayectoria que quiere dar al balón. El componente conserva la ruta completa, calcula una potencia inicial a partir de longitud/duración y emite el tipo de reinicio junto con la ruta normalizada.

Tipos admitidos: saque inicial, tiro libre directo, tiro libre indirecto, penalti, córner, saque de puerta y saque de banda. Todos usan el mismo gesto, pero el adaptador de reglas debe aplicar las condiciones legales propias de cada uno.

El modelo inicial `scripts/ball_flight_model.gd` interpreta dirección, elevación y curvatura, y proporciona gravedad, arrastre aerodinámico, efecto Magnus y decaimiento de spin. La trayectoria dibujada no garantiza que el balón llegue al destino: atributos, potencia, contacto, oposición, portero y física determinan el resultado.

**Estado:** componente de captura y modelo base añadidos al repositorio. Todavía falta conectarlos al HUD de partido, al árbitro, al balón físico real, a las animaciones y al adaptador de cada reinicio. La lista de pruebas está en `docs/SET_PIECE_SWIPE_ACCEPTANCE.md`; no se ha afirmado que hayan pasado pruebas en Godot/Android.
