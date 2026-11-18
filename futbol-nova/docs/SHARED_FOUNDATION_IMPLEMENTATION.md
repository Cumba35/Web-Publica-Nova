# Fútbol Nova — primera implementación funcional compartida

**Estado:** catálogo cubano con 52 equipos (16/16/20) y 1.144 perfiles de plantilla conectado al servicio de datos. La validación real en Godot sigue pendiente; Android no validado.

## Objetivo
Crear una base común para partidos jugados, partidos simulados, plantillas y competiciones. Ambos tipos de partido deben producir el mismo contrato de resultado para que Manager, Leyenda, tablas, historial y estadísticas no mantengan sistemas incompatibles.

## Componentes añadidos
- `scripts/core/match_contract.gd`: contrato versionado de estado, eventos, goles y resultado final.
- `scripts/data/player_profile.gd`: validación de identidad, posición, pie dominante, datos físicos y atributos en escala 1–99.
- `scripts/data/team_profile.gd`: validación de equipo, IDs de plantilla y referencias a futbolistas.
- `scripts/data/football_data_registry.gd`: registro offline en memoria para jugadores, equipos y competiciones; valida referencias antes de aceptar datos.
- `scripts/data/cuba_league_importer.gd`: importa los 52 clubes de `data/cuba_leagues.json`, incluyendo los dos grupos de Tercera División.
- `scripts/data/cuba_roster_importer.gd`: importa los 1.144 perfiles guardados de las tres divisiones, transforma sus 35 atributos compactos al esquema canónico y enlaza sus IDs a los equipos.
- `scripts/data/cuba_roster_importer.gd`: carga las tres plantillas cubanas estáticas; `data/players/cuba_first_division.json` contiene las 16 plantillas de Primera.
- `scripts/data/football_data_service.gd`: servicio de inicio automático registrado como autoload `FootballData`; prepara catálogos, fixtures y tablas al iniciar el proyecto.
- `scripts/simulation/round_robin_scheduler.gd`: calendario todos-contra-todos, ida/vuelta y descanso cuando hay número impar de equipos.
- `scripts/simulation/league_standings.gd`: tabla, puntos, goles, diferencia y desempates iniciales.
- `scripts/simulation/season_match_simulator.gd`: simulación rápida reproducible por semilla, fuerza de equipo y forma; genera estadísticas sintéticas y eventos de gol.
- `tests/test_shared_foundation.gd`: pruebas iniciales de calendario, tabla, reproducibilidad y validación de perfiles.
- `scripts/competitions/league_ball_service.gd` + `data/league_official_balls.json`: asignación de balón oficial por liga y catálogo con estado de licencia.
- `scripts/manager/club_academy_service.gd` + `data/youth_academy_rules.json`: cantera automática solo en Primera; creación en Segunda e inferiores mediante auditoría común de cumplimiento y solvencia.
- `scripts/manager/board_objectives_service.gd`: objetivos cortos de disciplina, goles en ambas partes y titulares sub-25.
- `scripts/manager/manager_career_service.gd`: carrera de entrenador, confianza de junta, recompensas, rotación de objetivos y guardado local.
- `scripts/simulation/competition_calendar_builder.gd`: fixtures de playoff de Segunda, playoff de ascenso de Tercera, Copa de Cuba y Supercopa.
- `tests/test_league_and_manager_systems.gd`: pruebas de balones, academias, objetivos, persistencia y calendarios.
- `.github/workflows/futbol-nova-tests.yml`: ejecución headless de ambas suites con Godot en GitHub Actions.

## Datos cubanos conectados
El archivo `data/cuba_leagues.json` contiene 52 clubes ficticios: 16 en Primera, 16 en Segunda y 20 en Tercera (dos grupos regionales de diez). El calendario de fase regular genera Primera a doble vuelta (240 partidos), Segunda a doble vuelta (240) y dos grupos de Tercera a una vuelta (45 partidos cada uno): **570 partidos**. Los playoffs, Copa y Supercopa están descritos en reglas; su resolución completa e integración con la temporada siguen pendientes.

Las plantillas están guardadas estáticamente en GitHub:
- Primera: 16 clubes × 22 = 352 perfiles en `data/players/cuba_first_division.json`.
- Segunda: 16 clubes × 22 = 352 perfiles en `data/players/cuba_second_division.json`.
- Tercera: 20 clubes × 22 = 440 perfiles en `data/cuba_players.json`, incluidos los 88 perfiles conservados de Morón, Trinidad, Baracoa y Manzanillo.
- Total: 1.144 perfiles, con IDs estables y 22 jugadores por cada uno de los 52 clubes.

## Flujo compartido
1. El importador carga los clubes del catálogo cubano; el importador de plantillas carga los 1.144 perfiles estáticos desde los tres archivos de GitHub. El registro valida perfiles, IDs y referencias entre los 52 equipos y sus 1.144 jugadores.
2. El planificador genera fixtures con IDs estables de competición y temporada.
3. El partido jugado o la simulación rápida producen un resultado con equipos, marcador, eventos, estadísticas, semilla y versión.
4. La tabla aplica el resultado sin conocer si fue jugado o simulado.
5. El historial puede almacenar el mismo objeto de resultado.

## Límites deliberados
- Los 1.144 perfiles cubanos se conservan y enlazan en sus divisiones vigentes: 352 de Primera, 352 de Segunda y 440 de Tercera. Los 88 jugadores de los cuatro clubes trasladados mantienen sus IDs y cambian únicamente de club/división en la plantilla. Todos deben pasar validación de Godot y calibración deportiva.
- No se fijó una fórmula definitiva de overall ni se infieren ratings de fuentes que no los proporcionan.
- La simulación rápida es un baseline técnico reproducible, no un modelo profesional. No sustituye la IA espacial de FootySim, la táctica de League-Soccer ni la física del partido 3D.
- Las estadísticas y xG de esta simulación son estimaciones sintéticas; no deben presentarse como datos observados.
- El prototipo visual actual solo contiene un futbolista controlable y balón. La integración de 22 agentes se hará después de validar el contrato y los datos.
- No se importó código ni assets de terceros.

## Ejecutar pruebas
Desde la raíz del proyecto, con Godot 4.x instalado:

```sh
godot --headless --path . --script res://tests/test_shared_foundation.gd
```

Este entorno de trabajo no dispone de Godot instalado. Se añadió un workflow de GitHub Actions para ejecutar ambas suites con Godot 4.4.1; no se debe afirmar PASS hasta inspeccionar una ejecución satisfactoria. Resolver cualquier error de parser/runtime antes de integrar estos módulos en Manager, Leyenda o la escena de partido.

## Próximo paso
Ejecutar las pruebas Godot sobre las 52 plantillas cubanas y las diez ligas base, corregir errores de importación y después construir el primer partido 11 contra 11 con agentes básicos sobre el contrato común. La física del balón y las reglas deberán emitir eventos al mismo contrato, no crear un resultado paralelo.

## Ampliación del campeonato cubano (14-11-2026)
La estructura vigente del campeonato cubano es Primera 16, Segunda 16 y Tercera 20 en dos grupos regionales de diez. El calendario de fase regular suma 570 partidos. La clasificación registra enfrentamientos directos y minitablas para desempates entre tres o más equipos.

Detalles: [Reglamento cubano inspirado en el sistema español](CUBAN_COMPETITIONS_SPANISH_RULES.md) y [reglas en JSON](../data/cuban_competition_rules.json).

La nueva estructura se ha guardado en GitHub, pero las pruebas no se han ejecutado: Godot 4.x no está disponible en este entorno. No afirmar compilación ni validación Android.


## Plantillas cubanas consolidadas (14-11-2026)
- 52 equipos definidos: 16 de Primera, 16 de Segunda y 20 de Tercera.
- 1.144 jugadores guardados: 352 en Primera, 352 en Segunda y 440 en Tercera. Los 88 jugadores de los cuatro clubes trasladados conservan sus IDs.
- 22 futbolistas por equipo con distribución posicional uniforme según el documento de generación.
- El personaje personalizado que representa al jugador humano no forma parte de estas plantillas y se creará al final.
- Se añadieron pruebas para comprobar las 52 plantillas completas; no declarar PASS hasta ejecutar Godot 4.x.


## Ampliación de las diez ligas base — 15-11-2026
El registro y los archivos de GitHub ahora contienen 725 clubes de las diez ligas base y 15.950 perfiles ficticios guardados, 22 por club. Se añadieron importadores estáticos para Estados Unidos, España, Brasil, Italia, Alemania, Francia, Portugal y Argentina, además de los tres archivos estáticos de Cuba. Los perfiles son contenido ficticio de juego y no plantillas profesionales reales.
- Importador de clubes: `scripts/data/base_league_importer.gd`
- Importador de plantillas: `scripts/data/base_league_roster_importer.gd`
- Datos de clubes: `data/base_league_clubs_2026.json`, `data/spain_clubs_2026_27.json`, `data/usa_clubs_2026.json`
- Validación: `tests/test_base_league_data.gd` y `tests/test_usa_league_data.gd`
- La ejecución real de Godot y Android sigue pendiente de confirmación CI.


## Ajuste regional de divisiones (15-11-2026)
La estructura definitiva queda en 16 clubes de Primera, 16 de Segunda y 20 de Tercera (dos grupos de diez). Morón Deportivo y Trinidad Colonial están en el Grupo Occidental; Baracoa FC y Manzanillo Marítimo, en el Oriental. Sus 88 futbolistas se conservan y pasan con ellos; los IDs de jugador no cambian. Total: 52 clubes y 1.144 futbolistas. Fase regular: 570 partidos.


## Corrección de coherencia de plantillas — 15-11-2026
Se corrigieron los archivos fuente, no solo la documentación: Primera contiene 16 clubes/352 jugadores; Segunda 16/352; Tercera 20/440. Los cuatro clubes regionales transferidos a Tercera usan IDs CUB-S3-017 a CUB-S3-020; los 88 IDs de sus jugadores permanecen estables. Tercera se disputa a una vuelta por grupo (9 jornadas y 45 partidos en cada grupo). Las pruebas deben confirmar la importación de las 52 plantillas y la normalización estadística común de todos los perfiles.
