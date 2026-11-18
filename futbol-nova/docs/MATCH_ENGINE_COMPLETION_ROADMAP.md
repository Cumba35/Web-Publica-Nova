# Fútbol Nova — Hoja de ruta de finalización del motor de partido

**Actualizado:** 16 noviembre 2026  
**Repositorio:** `Cumba35/Nova-Workspace` · rama `main`  
**Objetivo:** llevar el prototipo 11 contra 11 a un partido local completo, verificable y optimizado para Android, sin presentar funciones planificadas como terminadas.

## Estados

- **Base implementada:** existe código funcional inicial, pero aún puede faltar integración o validación.
- **En desarrollo:** hay una primera implementación parcial.
- **Pendiente:** no debe anunciarse como disponible.
- **Bloqueado para validar:** el código está guardado, pero falta ejecutar las pruebas en un entorno Godot real.

## Fases del motor

| Fase | Estado | Criterio de finalización |
|---|---|---|
| 1. Balón, primer toque y posesión | En desarrollo | Control en movimiento, conducción con toques, pases rasos/elevados, recepción, control orientado, rebotes y pruebas físicas. |
| 2. Movimiento y contactos | En desarrollo | Aceleración, frenado, giro, colisiones físicas estables, protección corporal y prevención de penetraciones sin empujes artificiales. |
| 3. Presión, entradas e intercepciones | En desarrollo | Entradas frontales/laterales, robos, interceptación dinámica, faltas, enfriamientos, animaciones y pruebas de situaciones límite. |
| 4. Porteros | En desarrollo | Posicionamiento, anticipación, blocaje, despeje, estirada, caída, rebote, saque y reacción según atributos. |
| 5. Árbitro y reglas | En desarrollo | Geometría determinista de fuera de juego y salidas; validación inicial de gol integrada. Pendientes: detección en vivo al pase, faltas/ventaja, tarjetas, penaltis, ejecución de reinicios e infracciones. |
| 6. Flujo del encuentro | En desarrollo | Reglas puras de duración, añadido y secuencia de fases guardadas y probadas estructuralmente; falta conectar cronómetro, interrupciones, descansos, prórroga y tanda al partido en vivo. |
| 7. IA colectiva | En desarrollo | Roles, coberturas, líneas, anchura/profundidad, presión coordinada, repliegue, transiciones y ajustes tácticos. |
| 8. Animación y presentación | En desarrollo | Ciclos locomotores, pases, tiros, entradas, atajadas, choques, celebraciones, cámara y transiciones sin saltos. |
| 9. Estadísticas y eventos | En desarrollo | Posesión, pases, tiros, atajadas, recuperaciones, faltas, mapa de calor, cronología y estadísticas consistentes con eventos. |
| 10. Controles y accesibilidad | En desarrollo | Teclado, pantalla táctil, mandos configurables, reasignación, ayudas, accesibilidad y pruebas en distintas relaciones de aspecto. |
| 11. Rendimiento y calidad Android | Bloqueado para validar | Pruebas headless, perfilado CPU/GPU, memoria, estabilidad térmica, sesiones largas y APK ARM64 verificado en dispositivo. |
| 12. Online y multijugador local | Pendiente | Sincronización autoritativa, salas, reconexión, validación anti-trampas y pruebas de red. No anunciar hasta que exista backend operativo. |

## Trabajo ya guardado en la base 11v11

- Alineaciones 4-3-3 con 22 identificadores y 21 actores IA más el futbolista controlado.
- Movimiento táctico inicial, presión del jugador más cercano y separación cinemática ligera.
- Pase IA a compañero adelantado y comprobación geométrica de rivales en la línea de pase.
- Primer control/posesión con liberación explícita del balón para pase y disparo.
- Portero con seguimiento lateral y despeje básico.
- Primera evaluación geométrica de entradas: alcance, orientación y detección de contacto peligroso por detrás.
- Entrada del usuario conectada al botón táctil **PRESIÓN** y a la tecla **G**.
- Los botones **F** y **ESPACIO** liberan el balón desde el controlador de posesión.
- Pruebas unitarias estructurales y geométricas en `tests/test_match_11v11_foundation.gd`.

## Protocolo obligatorio para cada fase

1. Buscar en GitHub proyectos públicos relacionados específicamente con el sistema que se va a trabajar.
2. Abrir los repositorios candidatos y revisar código, documentación, actividad, dependencias y compatibilidad con Godot/Android.
3. Verificar la licencia en el propio repositorio o en la API de GitHub. Si no hay licencia identificable, no copiar código ni assets; estudiar únicamente ideas generales.
4. Comparar al menos dos enfoques cuando existan alternativas razonables y elegir el que mejor preserve rendimiento móvil, funcionamiento offline y modularidad.
5. Implementar en Fútbol Nova con código propio o con reutilización expresamente compatible y atribuida.
6. Añadir pruebas de casos normales, límites y errores; documentar qué cubren y qué no.
7. Guardar cambios en `main`, releer desde GitHub todos los archivos afectados y verificar sus SHA.
8. Consultar GitHub Actions y registrar su resultado real. Un workflow sin runner, pasos o logs no cuenta como prueba ejecutada.
9. No declarar una fase terminada mientras falten integración, pruebas o validación del dispositivo cuando correspondan.

## Restricciones técnicas

- Mantener el núcleo ligero y offline; no incorporar GDExtensions, motores C++ grandes ni dependencias de servidor sin demostrar necesidad, compatibilidad y coste en Android.
- No copiar escudos, equipaciones, modelos, animaciones, fotografías, audio, marcas ni bases de datos protegidas.
- Mantener separadas las reglas del árbitro, la IA, la física del balón, los controles, la presentación y la simulación de temporada.
- No marcar Online ni multijugador como disponibles hasta que el backend exista y esté probado.
- Las funciones parciales deben mostrarse como prototipo o en desarrollo.

## Referencias públicas estudiadas en esta revisión

- [League-Soccer](https://github.com/awest813/League-Soccer) — Apache-2.0 declarado; referencia para separar física, IA, árbitro, estadísticas y suites headless. No se importó código ni su motor C++.
- [Godotball](https://github.com/aliyavuzz/Godotball) — port de GameplayFootball a Godot con GDExtension y física de balón; GitHub API devolvió `license: null`, por lo que no se reutiliza código.
- [Soccer Box Game](https://github.com/namelesssyf/soccer-box-game) — referencia de física rígida, tackles y autoridad de red; licencia no confirmada, no se reutiliza código.

## Condición de cierre

El motor se considerará terminado únicamente cuando las fases aplicables estén implementadas, integradas, documentadas y superen sus pruebas automatizadas; el APK debe compilar y abrirse en Android ARM64, y los flujos de partido deben probarse de principio a fin. Las funciones online se evalúan aparte y no bloquean el modo offline, pero no se pueden anunciar como disponibles sin backend.


## Primera base del árbitro y reglas — 16 noviembre 2026

Se creó `scripts/gameplay/match_rules.gd` como módulo puro y ligero, independiente de la escena:
- Evalúa la posición de fuera de juego en el instante del pase con dirección de ataque, balón y penúltimo defensor.
- Distingue estar en posición antirreglamentaria de cometer infracción: requiere participación activa para devolver `offence=true`; contempla las exenciones de fuera de juego en saques de puerta, saques de banda y córneres directos.
- Clasifica la salida del balón como saque de banda, córner, saque de puerta o gol, y determina el equipo beneficiado según el último toque y el lado defendido.
- Se comprueba que el balón completo haya cruzado las líneas (incluido su radio), y que quepa entre postes y bajo el larguero; un balón fuera por encima del larguero o por debajo del suelo no se acepta como gol.
- El marcador de la escena principal ahora valida el balón dentro de la boca de gol reglamentaria antes de sumar. Se ajustaron las dimensiones interiores de la portería a 7,32 m × 2,44 m; el sensor se coloca detrás de la línea para evitar sumar antes de que cruce el balón completo.

Pruebas añadidas: fuera de juego activo y pasivo, campo propio, igualdad con el penúltimo defensor, exenciones de fuera de juego en los tres reinicios directos, saque de banda, córner, saque de puerta, gol, balón alto, balón bajo, límites de línea, cruce completo de banda y balón que no cabe entre los postes.

**No está terminado ni integrado todo el arbitraje:** la captura de posiciones en el pase aún no está conectada a los pases reales; no se rastrea todavía el último toque para reinicios en juego; faltan ejecución física de saques, tiros libres y penaltis, detección completa de faltas, ventaja, tarjetas y sanciones. Tampoco se ha ejecutado Godot en este entorno.


## Reglas del reloj — 16 noviembre 2026

Se añadió `scripts/gameplay/match_clock_rules.gd` como capa pura de reglas basada en `docs/GAME_DESIGN.md`:
- Acepta las duraciones reglamentarias de 3, 5, 6, 8, 10, 15 y 20 minutos por tiempo.
- Calcula las duraciones de prórroga 1, 2, 2, 3, 3, 5 y 7 minutos por cada período.
- Diferencia el añadido del reloj detenido (siempre 1–3 minutos) y la compensación del reloj continuo (pérdidas reales, sin límite fijo).
- Comprueba que la prórroga solo pueda comenzar si hay empate y el reglamento de la competición la permite.
- Expone la secuencia de períodos reglamentarios, prórroga y tanda.

Se amplió `tests/test_match_11v11_foundation.gd` con casos de duración, añadido, elegibilidad y secuencia. La lógica es auxiliar y todavía no está conectada al bucle de juego, HUD ni eventos de interrupción. La auditoría completa de requisitos/estado está en `docs/MATCH_RULES_IMPLEMENTATION_AUDIT.md`.

Investigación específica: OpenFoot Manager (GPL-3.0-or-later; solo referencia conceptual, sin código), League-Soccer (Apache-2.0; referencia, sin código) y football-simulator (MIT; referencia, sin código). Ver detalle y decisiones en `docs/MATCH_RULES_IMPLEMENTATION_AUDIT.md`.


## Sustituciones — 16 noviembre 2026

Se añadió `scripts/gameplay/match_substitution_rules.gd` y cobertura automatizada para:
- límite oficial de 5 cambios / 3 ventanas;
- múltiples cambios dentro de la misma ventana;
- ventana del descanso;
- 6.º cambio y 4.ª ventana en prórroga;
- amistosos con hasta 11 cambios;
- cambios por lesión que consumen los límites;
- bloqueo de reingreso, expulsados y lesionados graves;
- validación antes de penaltis.

La capa es determinista y no depende de la interfaz. Falta el banco, el menú de pausa y reemplazar realmente actores/jugadores en el partido 3D. Por ello, el sistema está en desarrollo, no disponible todavía como función de partido.

## Módulo Realista — primera integración

Se creó el agregado opcional `futbol_nova_realism`. El juego base no depende de él. El perfil descargable es JSON y se instala mediante el gestor existente, que comprueba HTTPS, tamaño, SHA-256 y rutas seguras; el gestor ahora acepta `content_type=realism_module`.

Primera función runtime: fatiga de los 21 jugadores IA del partido local. Cada actor empieza con resistencia 100, consume resistencia mientras se desplaza y la recupera cuando descansa; la resistencia modifica gradualmente su velocidad. Si el paquete no está instalado o no supera validación, el factor es 1.0 y se conserva el comportamiento base.

Estado del agregado en catálogo: **En desarrollo / no descargable**. No se inventaron URL, checksum ni tamaño de distribución. Ver `docs/REALISM_MODULE_DESIGN.md`.


## Cronómetro integrado al partido local — 16 noviembre 2026

La máquina de estados `scripts/gameplay/match_clock_state_machine.gd` ya se ejecuta desde el `_physics_process` del controlador:
- Dos tiempos, 5 minutos por tiempo por defecto.
- HUD con fase y cuenta atrás.
- Descanso obligatorio y botón de continuar para iniciar el segundo tiempo.
- Método de reloj detenido y continuo; API para registrar interrupciones y contabilizar pérdidas.
- Añadido de 1–3 minutos con reloj detenido; reloj continuo con compensación de pérdidas, mínimo de 1 minuto y sin máximo fijo.
- Prórroga de dos tiempos según la tabla original, con descanso; solo se inicia si la competición la autoriza y el marcador está empatado.
- Si se requieren penaltis, se indica el estado pendiente; no existe todavía el motor de tanda.

Pendiente: conectar faltas, reinicios, goles, cambios, lesiones y VAR a la API de interrupciones; selector de reloj/duración por modo; guardar ajustes; completar motor de penaltis. El valor inicial continuo es provisional porque aún no existe selector de configuración.


### Configuración previa del amistoso local

El HUD permite seleccionar la duración de cada tiempo, el método de reloj y activar prórroga/penaltis para el amistoso de prueba. Las opciones se ocultan durante el encuentro. Falta conectar la configuración general persistente y cargar automáticamente las reglas de cada competición oficial.

## Correcciones de orientación de campo — 18 noviembre 2026

La revisión estática del controlador 11v11 encontró errores de signo que afectaban a ambos equipos y no eran detectados por las pruebas anteriores:
- El portero interpretaba el tercio defensivo con la dirección invertida. Ahora la zona se calcula desde la portería propia, con pruebas para local y visitante.
- La IA clasificaba incorrectamente el tercio de ataque. Ahora usa la dirección real de avance de cada equipo.
- El cálculo del avance de los pases IA restaba las posiciones en sentido inverso, por lo que los compañeros adelantados podían no ser seleccionados. Ahora mide el desplazamiento desde el origen hacia el objetivo según el sentido de ataque, y cubre pases locales y visitantes.
- Las faltas del jugador controlado se atribuían al ID genérico `nova_home`; el runtime ahora conserva y comunica el ID del club local seleccionado. El resumen del partido también expone ambos IDs y la prueba de integración los comprueba.

Pruebas añadidas en `tests/test_match_11v11_foundation.gd` y `tests/test_friendly_match_runtime.gd`. Los cambios se guardaron y releen desde `main`; siguen pendientes de ejecución real con Godot 4.4.1 porque GitHub Actions no ha asignado runner.

## Correcciones de integración del partido y del reloj — 18 noviembre 2026

La siguiente revisión estática detectó dos fallos de ejecución que afectaban el flujo normal de un amistoso:

- **Referencia del futbolista controlado:** la escena principal cambiaba el modelo del jugador (por ejemplo, Anier por Máximo Padilla según el club local) después de llamar a `start_match`. El controlador guardaba la referencia al nodo anterior, que se liberaba al terminar el frame. Ahora el modelo definitivo se selecciona antes de iniciar el motor y se valida que siga siendo una instancia válida. Se añadió una aserción en `tests/test_friendly_match_runtime.gd` para comprobar que `controller._player` es exactamente `game.player`.
- **Transición del reloj:** `tick()` invocaba `_advance_period()`, pero la máquina de estados define `_advance()`. Se corrigió la llamada para que el reloj pueda pasar de tiempo, descanso, prórroga y final usando la transición existente.

Los tres archivos modificados se guardaron en `main` y se volvieron a leer desde GitHub. La validación dinámica sigue pendiente: el runner de GitHub Actions aún no ha permitido ejecutar Godot, por lo que no se declara que las pruebas hayan pasado.

### Pausa real del futbolista controlado — 18 noviembre 2026

La auditoría de los controles detectó que pausar el motor detenía la IA y el reloj, pero el `CharacterBody3D` controlado seguía procesando entradas y podía desplazarse durante el descanso o al abrir el menú. El controlador ahora desactiva el procesamiento físico del jugador al pausar y al finalizar el encuentro, lo reactiva al reanudar el partido y lo restaura al detener el amistoso para volver a otros modos. Se amplió `tests/test_friendly_match_runtime.gd` para comprobar pausa y reanudación.

Los cambios se guardaron en `main`; la ejecución de las pruebas sigue pendiente de un runner Godot disponible.

## Corrección de despeje de los porteros — 18 noviembre 2026

La auditoría del comportamiento de los porteros encontró otro error de orientación: el despeje del guardameta local se enviaba hacia +Z, que es su propia portería, mientras que el visitante despejaba hacia -Z, también hacia su propia portería. Se extrajo el cálculo a `goalkeeper_clear_direction()` y ahora ambos despejan hacia el campo rival, conservando el componente lateral y la elevación. Se añadieron pruebas para comprobar el signo de Z de los dos equipos y que el balón salga elevado.

El controlador y las pruebas se guardaron en `main`. Pendiente ejecutar Godot para validar dinámicamente el resultado.

### Reinicio de balón después de un gol — 18 noviembre 2026

Se encontró que el reinicio del balón desde la escena principal solo cambiaba su posición y velocidad. Si un jugador tenía la posesión congelada, el controlador podía volver a colocar el balón junto al poseedor en el siguiente paso físico. Se añadió `reset_ball_for_restart()` para borrar la posesión, descongelar el balón y reiniciar velocidad lineal/angular y posición. La escena principal utiliza ahora ese método y conserva una alternativa segura fuera del motor 11v11. La prueba de aceptación fuerza una posesión, reinicia el balón y comprueba que no quede congelado ni ligado al poseedor anterior.


## Auditoría del primer control y adquisición de posesión — 18 noviembre 2026

La revisión encontró una diferencia entre el primer toque del jugador controlado y la adquisición por parte de los 21 actores IA: el jugador controlado respetaba el límite de altura y velocidad mediante `can_control_ball()`, pero los actores IA solo comprobaban la distancia. Eso permitía que un rival o compañero capturara instantáneamente un balón rápido o elevado y lo congelara, eliminando el rebote y la posibilidad de interceptación. Ahora todos los jugadores pasan por el mismo criterio de distancia, altura y velocidad; también se rechaza una posición del centro del balón por debajo del terreno. Se añadieron casos de regresión para los límites.

Investigación pública consultada para esta revisión:
- [League-Soccer](https://github.com/awest813/League-Soccer) — Apache-2.0 confirmado por la API de GitHub; arquitectura de simulación separada y referencia para pruebas. No se copió código.
- [FreeKick](https://github.com/AKM-8byte/FreeKick) — MIT confirmado por GitHub; referencia para física del balón en Godot 4. No se importó su addon ni sus recursos.
- [Godotball](https://github.com/aliyavuzz/Godotball) y [Soccer Box Game](https://github.com/namelesssyf/soccer-box-game) — proyectos 3D Godot relevantes, pero GitHub no devuelve una licencia identificable para sus repositorios; solo se consultaron descripciones y no se reutilizó código ni assets.

La corrección es GDScript ligero y no introduce dependencias, código nativo ni conexión de red. Los tests están escritos, pero su ejecución real sigue bloqueada mientras GitHub Actions no asigne un runner Godot.


### Reactivación física del balón después de reinicios — 18 noviembre 2026

La revisión de la física encontró un caso límite adicional: un `RigidBody3D` puede quedar dormido tras perder movimiento. Cambiar su posición y poner sus velocidades a cero no garantiza por sí solo que vuelva a simularse inmediatamente ni que la interpolación visual no conserve el transform anterior. El reinicio del motor ahora desactiva `sleeping`, restablece posición y velocidades y llama a `reset_physics_interpolation()`. La ruta alternativa de `main.gd` aplica la misma protección. La prueba runtime simula un balón dormido y comprueba que el reinicio lo despierte.

Referencia técnica: [FreeKick — MIT](https://github.com/AKM-8byte/FreeKick), archivos `ball.gd` y `docs/BALL_PHYSICS_MODEL.md`. Se estudió su secuencia de reset y su explicación sobre el estado físico pendiente; Fútbol Nova mantiene una implementación propia y no incorpora código ni assets del proyecto.


### Orden correcto de salida por banda o línea de meta — 18 noviembre 2026

La auditoría de las reglas detectó que `classify_ball_exit()` daba prioridad automática a la línea de meta cuando el balón terminaba fuera por dos límites a la vez. Eso podía conceder un córner o saque de puerta aunque el balón hubiera cruzado primero la línea lateral. La función ahora acepta la posición anterior del balón y compara el instante de cruce de cada límite usando el segmento de movimiento. Si ambos límites aparecen fuera pero no se aporta una posición anterior válida, devuelve `ambiguous_exit` en vez de inventar un reinicio. Se añadieron pruebas para línea de meta primero, banda primero y salida ambigua.

Investigación pública: se consultó [Soccer-Manager-Pro](https://github.com/antonzymin-eng/Soccer-Manager-Pro), que documenta el orden de resolución entre movimiento, contactos y cruce de límites. GitHub no devuelve una licencia identificable (`license: null`), así que solo se estudió el enfoque y no se reutilizó código. Se mantiene la implementación original de Fútbol Nova.
