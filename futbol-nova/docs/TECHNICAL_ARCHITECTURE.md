# Fútbol Nova — Arquitectura técnica

## Motor y plataformas

Propuesta inicial: Godot 4.x y GDScript, con renderizado 3D y física integrada. Primera validación en PC; los requisitos de Android se medirán antes de prometer soporte. No se fija aún una versión menor concreta del motor: se elegirá una versión estable compatible con los plugins y dispositivos objetivo.

## Frontera entre juego base y módulos descargables

El ejecutable base contiene el menú, los amistosos locales, Ayuda, ajustes generales y el gestor de módulos. Online y Modos son páginas de descubrimiento: no deben instanciar sistemas de carrera, competiciones, entrenamiento ni servicios de red que no pertenezcan al juego base.

Cada módulo debe tener manifiesto versionado, identificador estable, plataformas compatibles, dependencias, integridad verificable y punto de entrada aislado. La activación debe comprobar primero instalación y compatibilidad. La ausencia, fallo o desinstalación de un módulo nunca debe impedir iniciar el juego base y jugar amistosos.

No basta con ocultar botones: antes de distribuir el APK base deben excluirse del paquete sus escenas, scripts, catálogos deportivos, datos y recursos exclusivos de módulos. El catálogo de desarrollo puede conservar las fichas de módulos, pero solo permitirá descargar paquetes publicados y validados.

## Capas

1. **Presentación:** menús, HUD, cámaras, animaciones, audio y accesibilidad.
2. **Gameplay:** control del futbolista, balón, colisiones, porteros, árbitro y reglas.
3. **IA:** percepción, decisiones individuales, coordinación colectiva y entrenador.
4. **Simulación deportiva:** calendario, resultados, ligas, copas, estadísticas y clasificación.
5. **Carreras:** Manager, Leyenda, contratos, fichajes, entrenamiento, economía y progresión.
6. **Datos y persistencia:** JSON validado, identificadores, migraciones y guardados versionados.

## Organización propuesta

```
futbol-nova/
  project.godot
  scenes/
    main/
    pitch/
    players/
    ball/
    ui/
  scripts/
    gameplay/
    physics/
    ai/
    rules/
    competitions/
    manager/
    legend/
    data/
    save/
  data/
    teams/
    players/
    leagues/
    cups/
    tactics/
  assets/
    models/
    animations/
    audio/
    materials/
  tests/
  docs/
  research/
```

## Motor de partido

- Simulación física del balón independiente del controlador visual.
- Movimiento de jugadores mediante aceleración, velocidad máxima, frenado y giro.
- Detección de posesión y control contextual del balón.
- Acciones: pase, pase al espacio, centro, tiro, regate, entrada, despeje y cabezazo.
- Sistemas separados para reglas y árbitro; no resolver fueras de juego o goles dentro del controlador de jugador.
- IA con decisiones en intervalos ajustables, sin recalcular cada sistema a máxima frecuencia.
- Eventos de partido como fuente de estadísticas, comentarios y repetición.

## Simulación de temporada

El motor de temporada no debe depender de la escena 3D. Puede simular partidos no jugados con un modelo probabilístico basado en atributos, forma, táctica, fatiga y localía. Un partido jugado manualmente usa el resultado real del motor de campo. Ambos producen el mismo contrato de datos de resultado y eventos.

## Datos y guardados

- JSON con esquema y versión.
- IDs únicos para clubes, jugadores y competiciones.
- Validación de referencias, reglas de competición y duplicados al importar.
- Guardados con versión de esquema, copia de seguridad y migraciones.
- Semillas de simulación registradas para reproducir errores y pruebas.
- Ningún paquete de datos externo se instala sin validación.

## Rendimiento

- Objetivo inicial: 60 FPS en PC de gama media, ajustable según pruebas.
- Lógica de IA a frecuencia menor que renderizado cuando sea posible.
- LOD, instanciación y animaciones optimizadas para 22 jugadores.
- Perfilado de CPU/GPU antes de ampliar estadios, público y efectos.
- No añadir multijugador online hasta tener una simulación local estable.

## Calidad

Cada sistema tendrá pruebas unitarias o de integración: control, colisiones, gol válido, saque, falta, fuera de juego, sustitución, tabla de liga, eliminatorias, fichajes, progresión y guardado/carga. Los resultados de una misma semilla deben ser reproducibles en los módulos deterministas.

## Implementación compartida añadida (14-11-2026)

Los primeros scripts comunes se encuentran en:
- `scripts/core/match_contract.gd`: formato versionado del estado y resultado del encuentro.
- `scripts/data/player_profile.gd`, `team_profile.gd` y `football_data_registry.gd`: validación y registro de entidades deportivas.
- `scripts/simulation/round_robin_scheduler.gd`: calendario de liga.
- `scripts/simulation/league_standings.gd`: tabla y aplicación de resultados.
- `scripts/simulation/season_match_simulator.gd`: simulación rápida determinista por semilla.

El objetivo es que los partidos jugados y los simulados compartan el mismo esquema de resultado y eventos. El simulador rápido es provisional y no sustituye el motor 3D ni debe presentarse como IA de partido realista. Las estadísticas que produce son sintéticas.

Prueba prevista: `godot --headless --path . --script res://tests/test_shared_foundation.gd`. No se ha ejecutado todavía porque este entorno no tiene Godot instalado.


## Integración inicial de partido local 11 contra 11 — 16 noviembre 2026

Se añadió `scripts/gameplay/match_11v11_controller.gd` como primera capa ejecutable de partido local:
- Genera alineaciones 4-3-3 con once identificadores únicos por equipo y posiciones dentro del campo.
- Conserva a Anier Cumbá como futbolista controlado y crea 21 actores visuales ligeros para completar los dos equipos.
- La IA actualiza decisiones tácticas a intervalos de 200 ms y movimiento en física; los jugadores mantienen posiciones de formación, basculan según el balón y el jugador más cercano de cada equipo puede presionar.
- Los actores usan geometría procedural de bajo coste y materiales sencillos para no incorporar modelos pesados al juego base.
- Los jugadores de IA pueden golpear el balón al acercarse; la fuerza aumenta en el último tercio.
- El HUD incorpora la entrada **Partido local 11 vs 11 · Prueba**. El modo de entrenamiento sigue disponible por separado.

Límites expresos de esta fase:
- No es todavía un partido completo ni una simulación táctica de nivel comercial.
- Los actores IA todavía no usan cuerpos físicos ni colisiones de motor; se añadió separación cinemática ligera para reducir la superposición visual entre futbolistas.
- Se añadió una primera selección de pase: los futbolistas de IA buscan un compañero adelantado a distancia razonable y dirigen el balón hacia él; si no encuentran opción, progresan o despejan. Es una heurística inicial, no una línea de pase que evalúe rivales ni una posesión completa.
- Faltan posesión estable, recepción y control orientado, entradas, faltas, fuera de juego, árbitro, saques, sustituciones, lesiones, tarjetas, cronómetro y reglas de competición.
- El portero solo realiza un seguimiento lateral básico; no tiene todavía un sistema completo de atajadas.
- La prueba nueva valida las dos alineaciones, los 22 IDs, roles y límites del terreno; no sustituye pruebas visuales ni de rendimiento en Android.

Prueba añadida: `godot --headless --path . --script res://tests/test_match_11v11_foundation.gd`. Se incorporó al workflow Android existente. No se declara ejecutada hasta que GitHub Actions proporcione un runner y un resultado verificable.


## Mejora de movimiento colectivo y pase inicial — 16 noviembre 2026

Se amplió `scripts/gameplay/match_11v11_controller.gd`:
- Los actores IA aplican una separación cinemática limitada cuando se acercan demasiado entre sí o al jugador controlado. Reduce solapamientos visuales con coste bajo, pero no sustituye colisiones físicas ni resolución de contactos.
- Al golpear el balón, una IA busca un compañero del mismo equipo que esté adelantado y entre 3 y 19 metros; considera también al futbolista controlado del equipo local. Si encuentra candidato, orienta el impulso hacia él; si no, conserva la acción de progresión/despeje.
- El sistema sigue siendo una heurística de primera fase: no calcula oclusión por rivales, intercepciones, recepción, posesión ni calidad técnica.
- La prueba estructural de alineaciones sigue siendo necesaria y no verifica todavía el comportamiento visual de separación o pase.


## Primer control y posesión local — 16 noviembre 2026

Se amplió `scripts/gameplay/match_11v11_controller.gd` con una primera capa de control del balón:
- Un jugador puede adquirir el balón cuando está a 1,15 m o menos, el balón está a 1,1 m o menos de altura y su velocidad no supera 4 m/s. La elegibilidad se comprueba antes de fijar la posesión.
- Mientras dura la posesión, el balón se mantiene temporalmente en un punto de control delante del futbolista y se neutralizan sus velocidades lineal y angular. Es una aproximación cinemática de primer toque, no una animación de conducción ni una física de contacto completa.
- El jugador controlado conserva la posesión hasta llamar a `release_controlled_ball(direction, power)`, que valida dirección y limita la fuerza del impulso. La IA solo puede pasar o despejar después de adquirir el control; no golpea el balón por simple proximidad. Los actores IA liberan el balón al ejecutar su acción de pase/progresión; el portero libera la posesión antes de despejar.
- Se expone `has_controlled_possession()` para consultar el estado; el pase y el disparo del jugador controlado usan `release_controlled_ball()` para soltar el balón sin que vuelva a quedar adherido.
- Se añadieron pruebas unitarias de umbrales para distancia, altura y velocidad. Estas pruebas no simulan todavía un partido completo ni sustituyen pruebas físicas en Godot.

Límites pendientes: conducción con toques sucesivos, orientación del cuerpo según el control, recepción de pases en movimiento, contactos físicos entre jugadores, entradas animadas, equilibrio y evaluación de atributos técnicos. La posesión es provisional y debe ajustarse tras probar el comportamiento real del balón en Godot.


## Mejora de portero y selección de líneas de pase — 16 noviembre 2026

Se amplió el controlador del partido local 11 contra 11:
- El portero IA ajusta su posición lateral siguiendo el balón y adelanta ligeramente su posición cuando el balón entra en el tercio defensivo, sin abandonar el área próxima a su portería.
- Si el balón llega a una distancia corta y a una altura alcanzable, el portero aplica un impulso de desvío/despeje hacia una zona lateral. Es una primera reacción automatizada; no incluye todavía animación de estirada, manos, atrapada, rebote controlado ni evaluación de atributos.
- Antes de seleccionar un receptor, la IA comprueba la distancia de los rivales a la trayectoria geométrica del pase. También considera al jugador controlado como posible interceptor de un pase del equipo visitante.
- La comprobación de bloqueo de pase se expuso como función geométrica pura y se añadieron casos de prueba para trayectoria bloqueada, rival alejado y segmento de longitud cero.
- Estas mejoras no equivalen a un sistema completo de portero ni a pases tácticos avanzados: no calculan velocidad del balón, anticipación dinámica, cobertura colectiva, recepción, control orientado ni errores técnicos.

Prueba prevista: `godot --headless --path . --script res://tests/test_match_11v11_foundation.gd`. No se declara ejecutada hasta disponer de un resultado real de Godot/GitHub Actions.


## Entradas, robos e intercepciones — 16 noviembre 2026

Se añadió una primera capa de disputa de posesión en el controlador 11v11:
- `evaluate_tackle` evalúa alcance, orientación del atacante y contacto peligroso por detrás mediante geometría reproducible.
- `attempt_controlled_tackle` permite solicitar una entrada del futbolista controlado; la señal de presión existente ya está conectada a esta acción en la capa principal: botón táctil PRESIÓN y tecla G.
- Los actores IA pueden intentar entradas al jugador que tenga la posesión rival, con enfriamiento para evitar intentos por cada frame.
- Una entrada limpia transfiere la posesión; una entrada peligrosa emite un evento de falta y no roba el balón. Los eventos de posesión se notifican para futura integración con estadísticas y HUD.
- Se añadieron pruebas geométricas para entrada frontal, distancia fuera de alcance y entrada peligrosa por detrás.

Limitaciones: no hay todavía animación de entrada, contacto físico, deslizamiento, árbitro que determine tarjeta/ventaja, ni evaluación probabilística basada en atributos. La falta se notifica como evento; no detiene el partido ni genera todavía tiro libre.


La acción de entrada del jugador controlado está conectada: el botón táctil **PRESIÓN** y la tecla **G** llaman a `attempt_controlled_tackle()`. Los botones **F** y **ESPACIO** liberan el balón mediante `release_controlled_ball()` cuando el futbolista controlado tiene la posesión.

## Primera base de reglas del partido — 16 noviembre 2026

`scripts/gameplay/match_rules.gd` contiene funciones geométricas deterministas para:
- evaluar posición e infracción de fuera de juego a partir de una instantánea del instante del pase, con participación activa y exenciones en saques de puerta, banda y córner;
- clasificar el balón fuera por banda o línea de meta y resolver córner/saque de puerta usando el último toque;
- validar el cruce completo del balón por la línea y la boca de gol (7,32 m × 2,44 m) antes de conceder un gol.

La escena principal usa la validación de gol antes de modificar el marcador. Las demás reglas son todavía funciones de dominio probadas de forma unitaria: falta conectar los eventos reales de pase, toque y salida del balón, y ejecutar los reinicios. No se anuncia un árbitro completo ni fuera de juego activo en partido hasta que esa integración exista.


## Sustituciones y Realista — 16 noviembre 2026

### Reglas de sustitución

`scripts/gameplay/match_substitution_rules.gd` contiene una capa pura para límites por equipo, con estado copiable y ventanas identificadas por `window_id`. El diseño original se conserva: 5 cambios/3 ventanas, descanso incluido, +1/+1 en prórroga, 11 en amistosos, cambio por lesión sin excepción y prohibición de reingreso. Los cambios todavía no modifican el partido 3D porque faltan banco y UI de pausa.

### Módulo opcional Realista

`scripts/modules/realism_module.gd` carga un perfil JSON desde el paquete instalado `futbol_nova_realism`. El contenido se valida antes de aplicarse; el juego base continúa si el paquete no existe o es inválido. La primera integración usa resistencia individual para los jugadores IA: consumo en movimiento, recuperación en reposo y reducción gradual de velocidad. El catálogo lo mantiene en desarrollo hasta disponer de un paquete real publicado y validar su instalación y rendimiento en Android.


## Máquina de estados del reloj — 16 noviembre 2026

`scripts/gameplay/match_clock_state_machine.gd` implementa períodos reales y se integra con el controlador 11v11:
- `start_match` crea el estado de reloj; el valor inicial es 5 minutos por tiempo y método continuo mientras se construye el selector de ajustes.
- El controlador actualiza el estado por `delta` de física, emite cambios al HUD y pausa a los actores en el descanso.
- El usuario debe pulsar Continuar para iniciar el segundo tiempo o el segundo período de prórroga.
- `set_clock_interruption(reason, active)` permite registrar interrupciones. El método detenido pausa el reloj; el continuo acumula tiempo perdido.
- Los períodos tienen añadido obligatorio: 1–3 minutos en reloj detenido y, en reloj continuo, mínimo 1 minuto más la pérdida real sin límite máximo.
- La prórroga se somete a las condiciones configuradas de empate y autorización de competición. Si se requieren penaltis, se emite un estado pendiente, pues la tanda no está implementada.

El HUD está en `scripts/main.gd`. El selector de ajustes, persistencia y conexión automática de eventos arbitrales siguen pendientes.


### Ajustes de partido

La escena principal expone en el HUD previo al encuentro las siete duraciones admitidas, reloj continuo/detenido y opciones de prórroga/penaltis para el amistoso local. Se pasan como configuración al crear la máquina de estados. No se persisten aún en ajustes generales ni se leen automáticamente desde cada reglamento de competición.
