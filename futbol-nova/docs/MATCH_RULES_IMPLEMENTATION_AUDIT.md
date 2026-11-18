# Fútbol Nova — Auditoría de reglas del partido

**Fecha:** 16 noviembre 2026 · **Rama:** `main`  
**Fuente normativa del producto:** `docs/GAME_DESIGN.md`, sección 4 y «Árbitros y VAR».  
**Regla:** el diseño original del usuario prevalece sobre valores genéricos de otros motores. Una función auxiliar no equivale a integración en el partido.

## Resultado de la revisión

| Sistema | Requisito del diseño | Estado comprobado en código | Siguiente trabajo |
|---|---|---|---|
| Duración | Dos tiempos; 5 min por defecto; opciones 3/5/6/8/10/15/20 | Máquina de estados conectada al partido y HUD; descanso espera confirmación. El runtime usa 5 min y reloj continuo como valores provisionales | El selector previo permite elegir duración y reloj; falta configuración general y persistencia por modo |
| Reloj detenido | Detener en reinicios, faltas, fuera de juego, goles, cambios, lesiones, VAR, penaltis e interrupciones arbitrales; añadido autónomo de 1–3 min | Cálculo auxiliar añadido; eventos reales todavía no activan/paran el reloj | Enlazar cada evento arbitral y registrar causas |
| Reloj continuo | Cronómetro sigue y compensa pérdidas reales sin límite fijo | Runtime registra motivos de interrupción y calcula añadido; se garantiza al menos 1 min por período y no hay máximo fijo | Conectar duración real de lesiones, cambios, goles, VAR y reinicios |
| Descansos | Descanso normal y de prórroga esperan decisión del usuario | No integrado | Estados de descanso y controles Reanudar/Continuar |
| Prórroga | Dos períodos con duración ligada al tiempo normal: 1/2/2/3/3/5/7 min | Tabla de duración y guardia de elegibilidad añadidas; no se juega todavía | Integrar estados y reglamento por competición |
| Penaltis | Solo si el reglamento de competición los establece | Guardas auxiliares; tanda no implementada | Motor de tanda, orden y reglas de finalización |
| Sustituciones | 5 en 3 ventanas; descanso cuenta; prórroga añade 1 y 1 ventana; amistosos permiten 11; lesión también consume cambio | Reglas puras y pruebas añadidas; todavía sin banco ni menú de cambios en el partido 3D | Integrar plantillas, menú de pausa y sustitución segura de actores |
| Lesiones | Parada médica contextual; leves/moderadas permiten seguir con penalización; graves impiden volver; atención fuera y reingreso autorizado | No implementado en el controlador actual | Estado médico, árbitro, rendimiento y retorno |
| Árbitro/VAR | Estilos, atributos, revisiones de goles/penaltis/rojas/identidad; hasta 3 reclamaciones si se permiten errores | Geometría de fuera de juego y salida/gol parcialmente implementada; falta arbitraje en vivo | Captura del pase/último toque, faltas, tarjetas, VAR y reclamaciones |

## Reglas puras incorporadas en esta revisión

Nuevo archivo: `scripts/gameplay/match_clock_rules.gd`.

- Valida exclusivamente las siete duraciones definidas por el diseño.
- Convierte los minutos configurados a segundos.
- Devuelve la duración exacta de cada tiempo de prórroga de la tabla original.
- En modo continuo, garantiza al menos 60 segundos de añadido y compensa las pérdidas reales cuando superan ese mínimo, sin un máximo fijo.
- En modo detenido, calcula un añadido dentro del intervalo obligatorio de 1–3 minutos, teniendo en cuenta duración elegida, pérdidas y período.
- Expone una secuencia conceptual de fases y una condición para no iniciar prórroga si no está permitida o no hay empate.

**Importante:** el cálculo de añadido detenido es una primera política determinista de árbitro para el prototipo, no una simulación completa de juicio arbitral. Debe calibrarse con los eventos reales del partido. La secuencia de fases es una ayuda de dominio, no un cronómetro en ejecución.

## Investigación pública específica de cronómetro, períodos y sustituciones

| Fuente inspeccionada | Licencia / compatibilidad | Aprendizaje y decisión |
|---|---|---|
| [OpenFoot Manager — MATCH_SIMULATION.md](https://github.com/openfootmanager/openfootmanager/blob/develop/docs/MATCH_SIMULATION.md) | GPL-3.0-or-later declarada por el proyecto; Rust/Tauri, no compatible como copia directa del núcleo GDScript sin adoptar obligaciones GPL | Se estudió su máquina de estados `PreKickOff → FirstHalf → HalfTime → SecondHalf → FullTime → ExtraTime → PenaltyShootout`, el modelo de partido en vivo y las pruebas de transición. Solo se adapta el concepto; no se copia código. |
| [League-Soccer](https://github.com/awest813/League-Soccer) | Apache-2.0 declarada y verificada en la revisión previa | Referencia de reloj jugable, tiempo añadido, fatiga, cambios y eventos. No se copia código C++ ni dependencias. |
| [football-simulator](https://github.com/MikeDee101/football-simulator) | MIT declarada en README; simulación Python por minutos, no integrada | Referencia conceptual para extra tiempo y tanda como etapas distintas. No se copia código. |

No se importaron código, assets, bases de datos ni dependencias de estos proyectos. Los detalles concretos de Fútbol Nova siguen siendo los de `GAME_DESIGN.md`, no los valores por defecto de esas referencias.

## Validación añadida y límites

Se amplió `tests/test_match_11v11_foundation.gd` para cubrir las siete duraciones, las siete duraciones de prórroga, límites de añadido, reloj continuo sin máximo, métodos desconocidos, elegibilidad de prórroga y secuencias de períodos.

La prueba está guardada en GitHub, pero **no se ha ejecutado**: este entorno no tiene Godot instalado y los runs recientes de GitHub Actions no proporcionaron pasos/logs verificables. No declarar aprobado ni APK generado hasta obtener un resultado real.


## Sustituciones y módulo Realista — 16 noviembre 2026

Se añadió `scripts/gameplay/match_substitution_rules.gd`:
- 5 cambios y 3 ventanas oficiales; múltiples cambios en una misma interrupción comparten `window_id`.
- El descanso cuenta como ventana.
- La prórroga suma 1 cambio y 1 ventana.
- Los amistosos permiten hasta 11 sustituciones.
- Las sustituciones por lesión consumen cambio y ventana, sin excepción.
- Se bloquea el regreso de sustituidos y la entrada de expulsados o lesionados graves.
- La sustitución previa a penaltis queda sujeta a los mismos límites restantes.

**Límite:** las reglas están implementadas y probadas de forma pura, pero aún no se conectan al banco, menú de pausa ni actores 3D.

## Módulo Realista

Se creó `scripts/modules/realism_module.gd`, el perfil de paquete `data/modules/realism/realism_profile.json` y la ficha de agregado. El gestor de paquetes ahora reconoce el tipo `realism_module`. El catálogo muestra Realista como **En desarrollo**, no descargable: todavía no existe ZIP/JSON publicado con URL, tamaño y SHA-256 auténticos.

Primera función integrada: fatiga gradual de jugadores IA. La resistencia cae al moverse, se recupera al descansar y reduce progresivamente la velocidad hasta el mínimo del perfil. Sin paquete instalado, el comportamiento base no cambia. Lesiones avanzadas, biomecánica, variaciones arbitrales y física ampliada están documentadas como siguientes extensiones, no como funciones ya activas.


## Integración del reloj en vivo — 16 noviembre 2026

Se creó `scripts/gameplay/match_clock_state_machine.gd` y se conectó a `match_11v11_controller.gd` y `main.gd`:
- El partido comienza con dos tiempos y 5 minutos por tiempo.
- El HUD muestra fase y cuenta atrás.
- Al acabar el primer tiempo, el juego se pausa y muestra un botón; el segundo tiempo no comienza hasta que el usuario lo pulsa.
- El controlador expone `set_clock_interruption(reason, active)`: en modo detenido no avanza mientras exista una interrupción; en continuo la registra para el añadido.
- Cada período recibe añadido. En modo detenido son 1–3 minutos. En continuo se compensa la pérdida real, con mínimo de 1 minuto para cumplir el requisito de que todo período tenga añadido y sin máximo fijo.
- Si la configuración de competición permite prórroga y hay empate, el flujo pasa por dos períodos de prórroga y un descanso que también espera al usuario.
- Si el reglamento habilita penaltis tras el empate, se emite `penalty_shootout_pending`.

**Límites importantes:** el modo de reloj del runtime se inicia provisionalmente en continuo y 5 minutos; falta interfaz para elegir duración/método y persistirlo por modo. Los motivos de interrupción ya tienen API, pero todavía no están conectados automáticamente a todas las incidencias del árbitro. La tanda de penaltis aún no existe: el flujo solo la señala como pendiente. No se ha validado en Godot.


## Ajustes previos al partido

El HUD previo al partido ahora permite seleccionar duración por tiempo (3, 5, 6, 8, 10, 15 o 20 minutos), método de reloj continuo/detenido y, para el amistoso local de prueba, prórroga y penaltis. Estos indicadores se ocultan durante el partido y reaparecen al finalizar o salir. La configuración general persistente por modo y los reglamentos automáticos de competiciones aún están pendientes.
