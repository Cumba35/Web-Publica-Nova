# Fútbol Nova — Investigación de proyectos públicos y licencias

**Fecha de revisión:** 16 noviembre 2026  
**Objetivo:** estudiar implementaciones públicas para orientar la arquitectura de Fútbol Nova sin copiar código, modelos, imágenes, marcas ni contenido deportivo sin permiso.

## Proyectos revisados

| Proyecto | Tecnología / ideas útiles | Decisión de uso |
|---|---|---|
| [Godotball](https://github.com/aliyavuzz/Godotball) | Port de GameplayFootball a Godot 4.4; física de balón, GDExtension y estructura básica de 22 agentes | Referencia arquitectónica. No se reutiliza código ni assets: no se confirmó una licencia aplicable en esta revisión. |
| [League-Soccer](https://github.com/awest813/League-Soccer) | Motor 3D 22 jugadores, árbitro, fuera de juego, táctica colectiva, carreras y repetición | Referencia de arquitectura y lista de sistemas. El repositorio declara Apache-2.0; no se incorporó código ni dependencias. |
| [Soccer Box Game](https://github.com/namelesssyf/soccer-box-game) | Godot 4, física de balón, porteros IA, colisiones y modelo autoritativo de red | Referencia de diseño y separación de responsabilidades. No se copia código ni contenido; licencia no confirmada. |
| [FreeKick](https://github.com/AKM-8byte/FreeKick) | Godot 4, física configurable, IK procedural, repeticiones y pruebas visuales/de rendimiento | Se verificó archivo MIT. Se estudian patrones de pruebas y organización; no se incorporó código de este proyecto. Si se reutiliza código en el futuro, se conservarán aviso de copyright y licencia MIT. |
| [FootySim](https://github.com/Tobilion/footysim) | Simulación espacial 11v11 por agentes, decisiones basadas en atributos y geometría | Referencia conceptual para IA y simulación determinista; su implementación Python no se integra directamente en Godot. |
| [Documentación oficial Godot 4.4 — mandos](https://docs.godotengine.org/en/4.4/tutorials/inputs/controllers_gamepads_joysticks.html) | Mapeo por acciones, compatibilidad multiplataforma y soporte Android | Fuente técnica para mantener controles configurables en InputMap. |

| [GameplayFootball / League-Soccer (Apache-2.0)](https://github.com/awest813/League-Soccer) | Física de balón separada, agentes, árbitro, estadísticas y pruebas headless por suites | Se estudió la separación de subsistemas y la estrategia de pruebas. No se copió código ni se integró su motor C++/dependencias, para mantener el núcleo ligero Godot/Android. |

## Investigación específica: árbitro, fuera de juego y reinicios — 16-11-2026

| Repositorio | Archivos inspeccionados | Licencia verificada | Decisión |
|---|---|---|---|
| [fotbiler-football](https://github.com/erengaygusuz/fotbiler-football) | `src/onthepitch/referee.cpp`, `referee.hpp`, `player/controller/refereecontroller.cpp` | Apache-2.0, confirmada mediante la API de GitHub | Referencia para separar la autoridad arbitral, el estado de faltas, las fases y los reinicios. No se copió código C++ ni recursos; se implementó una versión geométrica propia en GDScript. |
| [League-Soccer](https://github.com/awest813/League-Soccer) | README y descripción de los sistemas de árbitro, offside y set pieces | Apache-2.0, confirmada mediante la API de GitHub | Referencia para cobertura de reglas y pruebas; no se importó código. |
| [open-soccer](https://github.com/modelence/open-soccer) | README y funciones declaradas de saque, córner, saque de puerta y fuera de juego | Sin licencia identificada en metadatos de GitHub | Solo ideas generales; no se reutiliza código ni assets. |

Decisión técnica: primero usar geometría pura y determinista en GDScript, sin dependencia C++ ni servidor, para que las reglas sean comprobables offline y en Android. La referencia de árbitro C++ ofrece un enfoque con buffer de reinicios y estado de falta; Fútbol Nova aún no adopta ese flujo completo.

## Referencias normativas oficiales

- [IFAB, Ley 11 — Fuera de juego 2025/26](https://www.theifab.com/laws/2025-26/offside/): posición en campo rival, balón y penúltimo adversario; posición no equivale a infracción y debe existir participación activa.
- [IFAB, Ley 1 — Terreno de juego](https://www.theifab.com/laws/latest/the-field-of-play/): anchura interior de portería 7,32 m y altura 2,44 m.
- [IFAB, Ley 9 — Balón en juego/fuera de juego](https://www.theifab.com/laws/2025-26/the-ball-in-and-out-of-play/): el balón está fuera cuando lo ha cruzado completamente por tierra o aire.
- [IFAB, Ley 10 — Resultado del partido](https://www.theifab.com/laws/2025-26/determining-the-outcome-of-a-match/): gol cuando el balón completo cruza la línea entre postes y bajo el larguero.

## Principios de cumplimiento

1. No descargar ni incorporar recursos de terceros solo porque un repositorio sea público.
2. Antes de reutilizar código, comprobar el archivo de licencia, su alcance, dependencias y avisos de copyright. En la revisión del 16-11-2026, la API de GitHub devolvió `license: null` para Godotball; por tanto, se considera sin licencia confirmada y no se reutiliza código.
3. Una licencia MIT exige conservar el aviso de copyright y el texto de licencia en copias o partes sustanciales.
4. Si no hay licencia identificable, tratar el contenido como «todos los derechos reservados» y limitarse a estudiar ideas generales.
5. No copiar nombres, escudos, equipaciones, fotografías, modelos, animaciones, comentarios ni bases de datos deportivas de terceros.
6. Mantener los datos de clubes y futbolistas ficticios de Fútbol Nova mientras no exista una fuente autorizada para datos reales.

## Aplicación en Fútbol Nova

La primera implementación propia inspirada en los requisitos generales de fútbol 11 se encuentra en:
- `scripts/gameplay/match_11v11_controller.gd`: alineaciones 4-3-3, actores ligeros, IA con decisiones espaciadas y control del jugador local.
- `tests/test_match_11v11_foundation.gd`: validación de 22 IDs, once jugadores por lado, roles y límites del terreno.
- `docs/TECHNICAL_ARCHITECTURE.md`: arquitectura y limitaciones pendientes.

No se copió código de los repositorios externos enumerados. La implementación de Fútbol Nova es original y debe seguir ampliándose con pruebas propias.


## Protocolo permanente de búsqueda por subsistema

Antes de modificar cada detalle del motor (física, control, IA, porteros, árbitro, reglas, animaciones, interfaz, rendimiento, temporadas o red) se hará una búsqueda nueva en GitHub con términos específicos de ese subsistema. No basta con consultar una lista general de proyectos:
- Registrar repositorios, rutas de código y documentación realmente inspeccionadas.
- Verificar licencia y dependencias en la fuente primaria. La visibilidad pública no equivale a permiso de reutilización.
- Comparar enfoques y descartar los que requieran servidores, motores C++ o extensiones que no aporten una ventaja demostrable en Android.
- Anotar la técnica general que se puede adaptar y la decisión tomada para Fútbol Nova.
- Si se reutiliza código bajo licencia permisiva, conservar avisos, licencia y atribución exigidos.
- Repetir la búsqueda cuando se pase a otro subsistema o cuando aparezca una versión upstream relevante; no presentar esta revisión como exhaustiva de todo GitHub.


## Investigación específica: reloj de partido, períodos y sustituciones — 16-11-2026

| Repositorio | Documentación inspeccionada | Licencia | Decisión |
|---|---|---|---|
| [openfootmanager/openfootmanager](https://github.com/openfootmanager/openfootmanager) | `docs/MATCH_SIMULATION.md`: máquina de estados de partido en vivo, cambios, descanso, prórroga, tanda y pruebas | GPL-3.0-or-later declarada en README; tecnología Rust/Tauri | Solo referencia conceptual. No se copia código ni se incorpora dependencia GPL al núcleo Godot/GDScript. |
| [awest813/League-Soccer](https://github.com/awest813/League-Soccer) | README: reloj, tiempo añadido, fatiga, sustituciones, lesiones y árbitro | Apache-2.0, verificada en revisión anterior | Referencia de cobertura de sistemas y pruebas; sin código importado. |
| [MikeDee101/football-simulator](https://github.com/MikeDee101/football-simulator) | README: motor determinista por minuto, prórroga y tanda | MIT declarada en README | Referencia conceptual para separar prórroga y penaltis como etapas; sin código importado. |

La implementación de Fútbol Nova se mantiene original y sigue los tiempos y límites definidos por el usuario en `GAME_DESIGN.md`. Ningún código, recurso, dato deportivo ni dependencia fue copiado.


## Investigación específica: sustituciones, fatiga y motor en vivo — 16-11-2026

| Repositorio | Fuente primaria inspeccionada | Licencia verificada | Decisión |
|---|---|---|---|
| [openfootmanager/openfootmanager](https://github.com/openfootmanager/openfootmanager) | `docs/MATCH_SIMULATION.md`: motor live por minuto con comandos entre minutos, condición por minuto, eventos y separación del motor instantáneo | GPL-3.0 identificada en la API de GitHub; Rust/Tauri | Referencia de arquitectura para separar estado de partido y simular condición por intervalos. No se copia código por licencia y tecnología distintas. |
| [Kapsid/footie-club-manager](https://github.com/Kapsid/footie-club-manager) | `docs/FNM_MATCH_ENGINE.md`: sustituciones de IA en ventanas, condición/fatiga, determinismo, separación de flujos aleatorios y pruebas de calibración | API de GitHub devuelve `license: null` | Solo referencia conceptual; no se copia código ni contenido. |
| [awest813/League-Soccer](https://github.com/awest813/League-Soccer) | API del repositorio y descripción de motor de fútbol, IA, árbitro y pruebas | Apache-2.0 identificada en API; C++ | Referencia de cobertura y separación de sistemas; no se importa el motor C++ para mantener compatibilidad Android/Godot y evitar dependencias grandes. |

Decisión: implementar reglas de sustitución y fatiga en GDScript puro, determinista y offline. La condición se calcula por intervalos de física del actor, sin RNG adicional ni dependencia de servidor. Ningún código ni recurso de estos repositorios fue copiado.
