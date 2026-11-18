# Fútbol Nova — Registro de investigación

Fecha de revisión: 2026-11-11. Fuentes de terceros consultadas como referencia de arquitectura y diseño. No se ha importado ni ejecutado su código.

| Proyecto | Licencia declarada/metadatos | Valor para Fútbol Nova | Restricciones |
|---|---|---|---|
| [League-Soccer](https://github.com/awest813/League-Soccer) | Apache-2.0 en API GitHub | Partido 3D, 22 jugadores, física de balón, IA, mando, repeticiones, carrera/gestión | Es un fork de GameplayFootball; revisar procedencia, dependencias y assets por separado |
| [Player12](https://github.com/FlavioMili/Player12) | GPL-3.0 | Motor de movimiento y balón, vista 2D/3D, control directo, ligas y carrera | GPL-3.0; no reutilizar sin decisión de compatibilidad |
| [Football Engine 2026](https://github.com/DeltaBitsSystem/FootballEngine) | GPL-3.0 declarada en README | Física, agentes, percepción, táctica, reglas y datos JSON | WIP; verificar LICENSE y dependencias antes de reutilizar |
| [Open Football](https://github.com/ZOXEXIVO/open-football) | Apache-2.0 | Simulación autónoma de clubes, jugadores, transferencias y ligas | No es un juego de control directo |
| [Openfoot Manager](https://github.com/openfootmanager/openfootmanager) | GPL-3.0 | Plantillas, tácticas, fichajes, entrenamientos, staff y simulación por eventos | GPL-3.0; gestión textual, no gameplay 3D |
| [Agentic FC](https://github.com/gaemi/agentic-fc) | MIT | Temporadas persistentes, copas, contratos, carreras y determinismo | Proyecto temprano y centrado en agentes/terminal |
| [Global Soccer Manager](https://github.com/ecrou-exact/Global-Soccer-Manager) | Apache-2.0 | Motor de eventos, atributos, tácticas y probabilidad | Simulación textual |
| [Football Simulation Engine](https://github.com/GallagherAiden/footballSimulationEngine) | MIT en registro previo | Referencia de módulo de simulación Node.js | Revisar API, pruebas y estado actual |

## Conclusión técnica

League-Soccer y Player12 son las referencias más cercanas a la combinación de partido visible/controlable y carrera. Football Engine 2026 aporta detalles de física y agentes. Openfoot Manager, Open Football y Agentic FC ayudan a diseñar el mundo persistente, las competiciones y la gestión.

La propuesta de Nova es construir una implementación original en Godot, sin basar el producto en un fork de ninguno de esos juegos. Antes de reutilizar cualquier componente se revisarán el texto íntegro de licencia, dependencias, submódulos, assets, fuentes, audio y bases de datos.


## Auditoría consolidada — 14-11-2026

La investigación ampliada de las 20 fuentes principales y las referencias adicionales ya aprobadas está centralizada en [REPOSITORY_INTEGRATION_PLAN_2026-11-14.md](REPOSITORY_INTEGRATION_PLAN_2026-11-14.md). El documento incluye capacidades, uso propuesto, licencias/condiciones, límites, riesgos Android y orden de implementación.

Correcciones y advertencias importantes:
- La referencia #12 correcta es `michaltomczykowski/godot-ai-animation-toolkit`; verificar licencia y versión antes de cualquier reutilización.
- FootySim no presenta una licencia abierta clara confirmada y documenta brechas en offside, córneres y saques de banda; se reserva para análisis/calibración hasta aclarar derechos.
- StatsBomb Open Data está sujeto a condiciones de uso para investigación y atribución; no es una licencia general para redistribuir datos dentro de un juego comercial.
- WorldSoccerStadiums presenta discrepancia entre README (public domain) y metadatos de GitHub (MIT); no redistribuir hasta resolverla.
- EasyStore es MIT, pero su backend Steam no es el backend de nube para Android; adaptar la arquitectura con backend Nova Nexus.
- Chirp (MIT, Godot 4.6+) declara que exportaciones y móviles no están probados; TCA Weather (MIT, Godot 4.6+) deja adaptación móvil como trabajo de roadmap; MultiNode (MIT, Godot 4.6, Open Alpha) requiere extensión nativa y benchmark Android.
- Netfox es MIT; la demo godot-rocket-league requiere Godot con Stepping PR o Blazium, por lo que no es una dependencia directa de Godot estable.
- League-Soccer declara Apache-2.0, pero su README indica linaje de GameplayFootball/Google Research Football y el enlace de clonación apunta a awest813/League-Soccer. Fijar el repositorio y commit exactos y auditar NOTICE, dependencias y assets.
- La licencia de cada repositorio solo cubre lo que realmente pertenece a ese proyecto; datos, modelos, marcas, nombres, fotos, audio y assets de terceros se verifican por separado.

**Estado general:** investigación y plan consolidados; ningún repositorio externo ha sido copiado ni ejecutado. Los helpers FreeKick ya presentes son componentes originales iniciales, todavía no conectados al motor completo ni probados en Godot/Android.


## Fuente adicional — 14-11-2026

| Proyecto | Licencia declarada/metadatos | Valor para Fútbol Nova | Restricciones |
|---|---|---|---|
| [Global Soccer Manager](https://github.com/ecrou-exact/Global-Soccer-Manager) | Apache-2.0 confirmada por GitHub | Motor Python por fases/cadenas de posesión; tácticas con trade-offs, fatiga, localía, clima, eventos disciplinarios, lesiones, sustituciones automáticas y pruebas estadísticas. Referencia para enriquecer el simulador rápido del Modo Manager | No es Godot ni 3D. Si se porta código, conservar licencia y avisos, añadir aviso de modificación y NOTICE si existe. Proyecto temprano; revisar dependencias antes de portar |

Verificación adicional: [Tobilion/footysim](https://github.com/Tobilion/footysim) tiene `license: null` en los metadatos actuales de GitHub. Se mantiene como referencia de diseño/calibración 11v11, no como fuente de código redistribuible hasta aclarar derechos. Los ejemplos Godot antiguos revisados sin licencia confirmada se excluyen de la reutilización directa.
