# Fútbol Nova

**ID:** `futbol-nova`  
**Tipo:** videojuego de fútbol 3D con simulación deportiva y carrera  
**Estado:** proyecto Godot 4.4.1 estructurado con escena principal, scripts GDScript, escenas 3D, datos deportivos, pruebas y preset Android ARM64. Incluye un prototipo 3D y sistemas de datos/competiciones en desarrollo. La importación y ejecución en Godot 4.4.1, las pruebas completas y la exportación Android todavía deben validarse en un entorno con el motor y sus plantillas.  
**Ruta canónica:** `proyectos/juegos/futbol-nova/`

Fútbol Nova será un juego original de fútbol con partidos en tiempo real, control directo, física del balón, inteligencia artificial, presentación deportiva y sistemas de gestión/carrera. FIFA 23 se utiliza como referencia funcional y visual, sin copiar su identidad, marcas, código, bases de datos ni recursos protegidos.

## Modos principales
- **Partido:** amistosos y partidos rápidos.
- **Manager/Entrenador:** dirigir un club durante varias temporadas.
- **Leyenda:** carrera individual de un futbolista.
- **Torneos, ligas y copas:** calendarios, tablas y eliminatorias.
- **Entrenamiento:** centro con Tutorial, Tiro libre, Penalti y práctica libre.
- **Desafío diario (Momentos):** tarjeta en Inicio, separada del centro de entrenamiento, con reto rotativo y recompensa reclamable una vez por ciclo.

## Menú principal confirmado
El menú tiene exactamente cuatro pantallas: **Inicio**, **Online**, **Modos** y **Configuración**. La navegación horizontal es bidireccional y circular, y conserva el estado de cada pantalla. **Ultimate Team está excluido** y no debe aparecer en el juego.

- [Especificación vigente del menú de cuatro pantallas](docs/MAIN_MENU_FOUR_SCREENS.md)
- [Configuración del menú principal](docs/MAIN_MENU_SETTINGS.md)
- [Sistema de guardado automático y manual](docs/SAVE_SYSTEM.md)
- [Documento antiguo de tres pantallas: sustituido](docs/MAIN_MENU_THREE_SCREENS.md)

## Abrir el proyecto en Godot

- Archivo de proyecto: `project.godot` en esta carpeta.
- Escena principal: `scenes/main.tscn`.
- Versión de referencia: Godot 4.4.1 Standard.
- Guía rápida para PC y Android: [Abrir Fútbol Nova en Godot](docs/GODOT_PROJECT_QUICK_START.md).
- Cachés y compilaciones locales excluidas mediante `.gitignore`.

## Edición del proyecto desde Godot en Android
- [Guía para descargar, importar y editar el proyecto Godot desde el teléfono](docs/ANDROID_GODOT_EDITOR.md)
- El workflow genera el artefacto `futbol-nova-godot-source` con el ZIP editable del proyecto, además de la APK de prueba cuando la compilación termina correctamente.

## APK de prueba para Android
- [Guía para generar y descargar la APK desde Android](docs/ANDROID_TEST_BUILD.md)
- Workflow único activo: `.github/workflows/futbol-nova-android-apk.yml`; ejecución manual mediante `workflow_dispatch`. No se ejecuta automáticamente al modificar archivos.


## Preparación del juego base y navegación
- [Preparación para pruebas y regla común de navegación](docs/BASE_GAME_TEST_PREPARATION_AND_NAVIGATION.md)
- En todas las pantallas aplicables, **Atrás** se ubica abajo a la izquierda y **Siguiente** abajo a la derecha, tanto en Android como en PC.
- Estado: requisito documentado; implementación y validación multiplataforma pendientes. No marcar como listo hasta ejecutar pruebas Godot y Android.

## Dirección técnica
- Motor propuesto: Godot 4.x; falta validar versión y rendimiento.
- Primera prioridad: establecer contratos compartidos entre partido jugado y simulación de temporadas, validar datos deportivos y después ampliar el prototipo 3D a 22 jugadores.
- Arquitectura: motor de partido separado de simulación de temporadas, datos deportivos JSON y guardados versionados.
- El prototipo 3D actual permite controlar un futbolista y el balón en una cancha de entrenamiento; incluye menú principal, guardados locales de carrera y controles táctiles iniciales. Todavía no existe un partido 11 contra 11 con IA completa, árbitro y reglas de partido.
- Se añadieron scripts iniciales para validar jugadores/equipos, registrar datos, generar calendarios, calcular tablas y simular resultados rápidos reproducibles. Están pendientes de ejecutar las pruebas en Godot.

## Primera implementación compartida
- [Diseño y estado de la primera base funcional](docs/SHARED_FOUNDATION_IMPLEMENTATION.md)
- [Contrato común de partido y eventos](scripts/core/match_contract.gd)
- [Registro offline de datos deportivos](scripts/data/football_data_registry.gd)
- [Importador de las 52 entidades de clubes cubanos](scripts/data/cuba_league_importer.gd)
- [Servicio de datos cargado al iniciar el juego](scripts/data/football_data_service.gd)
- [Planificador de calendarios](scripts/simulation/round_robin_scheduler.gd)
- [Tabla de clasificación](scripts/simulation/league_standings.gd)
- [Simulador rápido de temporada](scripts/simulation/season_match_simulator.gd)
- [Pruebas iniciales](tests/test_shared_foundation.gd)
- [Reglamento del campeonato cubano inspirado en el sistema español](docs/CUBAN_COMPETITIONS_SPANISH_RULES.md)
- [Reglas de competición en JSON](data/cuban_competition_rules.json)
- [Catálogo cubano con Primera, Segunda y Tercera](data/cuba_leagues.json)
- [Lógica de formatos de Copa y Supercopa](scripts/simulation/competition_format_rules.gd)
- [Catálogo de competiciones internacionales de clubes](data/international_club_competitions.json)
- [Economía, valoraciones y contratos comerciales](docs/CLUB_ECONOMY_AND_COMMERCIAL_KITS.md)
- [Parámetros económicos y criterios de valoración](data/club_commercial_economy.json)
- [Servicio de contratos, tercera equipación y valoraciones](scripts/manager/club_commercial_service.gd)

- [Reglas de integración de copas internacionales](docs/INTERNATIONAL_CLUB_COMPETITIONS.md)

- [Implementación funcional de la Liga de Campeones del Caribe](docs/CARIBBEAN_CHAMPIONS_LEAGUE_IMPLEMENTATION.md)
- [Formato, motor y estado del TAS](docs/AMERICAN_REGIONAL_CLUB_COMPETITIONS.md)
- [Motor de edición del TAS](scripts/simulation/tas_competition_engine.gd)
- [Pruebas de ciclo de vida del TAS](tests/test_tas_competition_engine.gd)
- [Motor de la Liga de Campeones del Caribe](scripts/simulation/caribbean_champions_league_engine.gd)
- [Pruebas de formato de la Liga de Campeones del Caribe](tests/test_caribbean_champions_league.gd)

- [Reglas mundiales de divisiones y catálogo IFFHS](data/global_league_tiers.json)
- [Proceso de importación de clubes y plantillas mundiales](docs/GLOBAL_CLUB_AND_SQUAD_COMPLETION.md)
- [Generador CSV antiguo (no usar para sobrescribir el lote actual hasta migrarlo)](tools/build_global_database.py)
- [Importador global de ligas para Godot](scripts/data/global_league_importer.gd)
- [Catálogo de Inglaterra 2026/27](data/england_leagues.json)
- [Estado de importación mundial](data/global_database_import_status.json)
- [Primer lote de España 2026/27: 82 clubes y fuentes](docs/SPAIN_DATABASE_2026_27.md)


## Distribución regional, confederaciones y ligas descargables
- [Catálogo maestro de paquetes del juego base y módulo Ligas del Mundo](data/league_content_manifest.json)
- [Regiones y subregiones del catálogo](data/league_regions.json)
- [Diseño del módulo descargable y su integración Godot](docs/DOWNLOADABLE_LEAGUE_MODULES.md)
- [Seis módulos independientes de ligas continentales](docs/CONTINENTAL_LEAGUE_MODULES.md)
- Índice: `data/continental_leagues/manifest.json`; cargador: `scripts/data/continental_league_module_service.gd` (autoload `ContinentalLeagues`).
- Los catálogos continentales están separados por AFC, CAF, CONCACAF, CONMEBOL, OFC y UEFA. La separación de datos ya está creada; no implica que las 100 ligas únicas catalogadas sean jugables o descargables. OFC está creado y pendiente de importar sus ligas.
- El juego base usa la selección propia de `data/league_content_manifest.json` (Inglaterra, España, Brasil, Italia, Alemania, Francia, Portugal, Argentina, Cuba y Estados Unidos). `data/global_league_tiers.json` conserva el ranking IFFHS 2025 y la política de divisiones; no determina por sí solo la selección de paquetes base. El resto se ofrece por confederación, región, país o paquete publicado. La disponibilidad real depende de completar y validar cada paquete.

## Módulos continentales de clubes

Las competiciones continentales americanas se distribuyen en módulos independientes: Caribe, Sudamérica, Norteamérica y Centroamérica, y el Torneo Americano de Supercampeones (TAS). Cada módulo tiene su propio manifiesto en `modules/continental_competitions/`, configuración y motor asignado; comparten únicamente servicios generales de datos, calendario, clasificación y persistencia. La descarga conjunta del TAS está definida en el catálogo y el gestor: una solicitud resuelve primero Caribe, Sudamérica y Norteamérica/Centroamérica, valida todos los paquetes y los encola en ese orden. El TAS no se instala si falta alguna dependencia y no se permite retirar una liga requerida mientras el TAS esté instalado. Los paquetes siguen en desarrollo y aún no son descargables hasta publicar sus ZIP, tamaños y SHA-256.

- [Registro de módulos continentales](modules/continental_competitions/module_registry.json)
- [Especificación de competiciones americanas y TAS](docs/AMERICAN_REGIONAL_CLUB_COMPETITIONS.md)
- [Motor de decisión de partidos del TAS](scripts/simulation/tas_match_decision_engine.gd)
- [Pruebas de partidos únicos del TAS](tests/test_tas_match_decision_engine.gd)

El TAS disputa todos sus encuentros a partido único: nueve partidos en la primera fase, tres en el grupo final y una final. Solo la final utiliza prórroga y penaltis; las fases de grupos permiten empates. El servicio compartido ya integra la resolución de resultados TAS y su persistencia; aún falta automatizar la creación de la edición, los calendarios de sus fases y la transición de clasificados entre grupos. La prueba TAS y la validación estructural de los cuatro manifiestos y sus dependencias están incorporadas al workflow manual; falta ejecutarlo en Godot 4.4.1.

## Documentación
- [Ampliación de requisitos del 14-11-2026](docs/NEW_FEATURE_REQUIREMENTS_2026-11-14.md)
- [Objetivos de la junta directiva y evaluación del entrenador](docs/BOARD_OBJECTIVES_AND_MANAGER_EVALUATION.md)
- [Centro de entrenamiento y desafíos diarios](docs/TRAINING_HUB_AND_DAILY_CHALLENGES.md)
- [Catálogo maestro de datos pendientes](docs/SCREEN_DATA_CATALOG.md)
- [Balones oficiales por liga y sistema de canteras](docs/LEAGUE_BALLS_AND_YOUTH_ACADEMIES.md)
- [Selector de equipos y preparación del partido](docs/PRE_MATCH_TEAM_SELECTION.md)
- [Diseño del juego](docs/GAME_DESIGN.md)
- [Arquitectura técnica](docs/TECHNICAL_ARCHITECTURE.md)
- [Hoja de ruta](docs/ROADMAP.md)
- [Controles táctiles y habilidades](docs/TOUCH_CONTROLS_AND_SKILLS.md)
- [Adaptación FreeKick y gestos para balón parado](docs/FREEKICK_ADAPTATION_AND_SET_PIECES.md)
- [Pruebas de aceptación del gesto de balón parado](docs/SET_PIECE_SWIPE_ACCEPTANCE.md)
- [Menú de pausa](docs/PAUSE_MENU.md)
- [Selector de equipaciones](docs/KIT_SELECTION.md)
- [Fuentes técnicas estudiadas](research/SOURCES.md)
- [Auditoría e integración selectiva de 20 repositorios](research/REPOSITORY_INTEGRATION_PLAN_2026-11-14.md)

## Protección de derechos
Todo el código, identidad visual, nombres, equipos, jugadores, escudos, equipaciones, estadios, música y comentarios serán originales o tendrán licencias compatibles. Las referencias comerciales solo orientan el género y la experiencia. La licencia del código de un repositorio no cubre automáticamente sus assets, datos ni dependencias.

**No se ha copiado ni ejecutado código de terceros.** Toda reutilización futura requiere revisión individual de licencia, dependencias, procedencia, seguridad y rendimiento.

## Base mundial de clubes y jugadores
- Las diez ligas base son Inglaterra, España, Brasil, Italia, Alemania, Francia, Portugal, Argentina, Cuba y Estados Unidos. Países Bajos y Colombia quedan en reserva opcional.
- Política de divisiones configurada según IFFHS 2025: top 10 con tres divisiones, puestos 11–20 con dos y el resto con una; Cuba conserva tres.
- Total: 725 clubes y 15.950 perfiles ficticios guardados en GitHub, con 22 jugadores por club. Cuba aporta 52 clubes/1.144 perfiles; Estados Unidos 72 clubes/1.584 perfiles; las otras ocho ligas tienen sus archivos de plantillas por temporada.
- Los perfiles generados son ficticios; no representan plantillas profesionales reales. Las tres competiciones estadounidenses se mantienen separadas, sin ascenso/descenso entre ellas. Sus calendarios oficiales específicos aún no están implementados.
- España, Brasil, Italia, Alemania, Francia, Portugal y Argentina tienen catálogos de clubes y plantillas ficticias guardadas en GitHub. La validación de Godot y Android sigue pendiente.

## Economía y equipaciones comerciales
- La tercera equipación está reservada a clubes de Primera y exige un contrato comercial activo con derechos y diseño aprobados.
- El valor de mercado y el salario de todos los futbolistas se investigan usando Transfermarkt como referencia principal cuando haya datos disponibles. Las cifras creadas por Fútbol Nova son estimaciones internas claramente etiquetadas; no se presentan como datos oficiales de Transfermarkt. Consulta `docs/PLAYER_MARKET_VALUE_METHODOLOGY.md`.
- El servicio económico ofrece cálculos iniciales para salarios, traspasos, clubes, patrocinios, entradas, equipaciones, estadios e instalaciones. La integración visual y el balance de temporada siguen pendientes de validación.

## Base de datos local y catálogo maestro

- [Diseño, estado y cobertura de la base de datos](docs/DATABASE_IMPLEMENTATION.md)
- [Esquema de almacenamiento v1](data/runtime_database_schema_v1.json)
- Servicio transaccional offline: `scripts/data/football_database_service.gd` (autoload `FootballDatabase`).
- Importador normalizado del catálogo mundial: `scripts/data/master_catalog_importer.gd`.
- Guarda snapshots del catálogo, resultados finalizados, calendarios, clasificaciones, temporadas y copias de carreras.
- Escritura atómica, copia de seguridad, recuperación, migración de esquema y bitácora de cambios.
- Cobertura actual: 211 asociaciones y 211 países/territorios con confederación verificada, 100 ligas en directorio de investigación, 891 clubes y membresías, 41 competiciones, 20 temporadas, 15.950 perfiles ficticios de las diez ligas base y 777 nombres de plantillas de referencia no jugables. Los 166 clubes de ligas adicionales siguen siendo referencias sin plantillas.
- Las plantillas de las diez ligas base son ficticias y están guardadas en GitHub. Las membresías de Brasil, Italia, Alemania, Francia, Portugal y Argentina aún requieren auditoría oficial de temporada; no se anuncian como plantillas profesionales reales.
- Pruebas: `tests/test_football_database.gd`; ejecución Godot 4.4.1 pendiente de confirmación CI.

## Temporadas, calendarios y simulación de ligas

- El servicio central de competiciones es `FootballData` (`scripts/data/football_data_service.gd`). El menú Modos > Ligas y Copas permite abrir competiciones, consultar tablas y simular la siguiente jornada de cada fase; los resultados se guardan localmente.
- `FootballData.get_fixtures(stage_id)` y `FootballData.get_standings(stage_id)` consultan calendario y clasificación.
- `FootballData.simulate_fixture(stage_id, fixture_id, seed)` simula y persiste un encuentro pendiente.
- `FootballData.simulate_round(stage_id, round_number, seed)` procesa los partidos pendientes de una jornada.
- Los calendarios generados para Argentina Liga Profesional y las tres competiciones estadounidenses son calendarios internos de una vuelta; se etiquetan como no oficiales mientras no se importen y auditen los calendarios federativos.
- La simulación usa la fuerza media de las plantillas registradas, genera eventos de gol y actualiza la clasificación con persistencia transaccional. El motor de estadísticas individuales y la transición automática de temporada/ascensos-descensos siguen siendo tareas separadas.

## Modo Leyenda — creador, estadísticas y retirada

- [Pantalla y estado funcional del Modo Leyenda](docs/LEGEND_MODE_HOME.md)
- Servicio local: `scripts/legend/legend_career_service.gd` (autoload `LegendCareer`).
- Creador de futbolista con edad de 14–45 años, 35 atributos individuales, posición, pie dominante y especialización.
- Estadísticas separadas de temporada y carrera: apariciones, titularidades, minutos, resultados, goles, asistencias, tiros, pases, regates, defensa, disciplina, portería, valoración y métricas derivadas.
- Historial persistente de temporadas, premios y retirada confirmada al finalizar temporada y sin contrato.
- La retirada desde los 20 años desbloquea la transición a Manager sin borrar el guardado de Leyenda.
- Pruebas: `tests/test_legend_career.gd`; incluidas en el workflow Godot CI.
- Integración de estadísticas: `record_match_from_contract(...)` recibe el resultado finalizado del contrato de partido y las estadísticas identificadas del futbolista, deriva victorias/empates/derrotas y las acumula en temporada y carrera. El motor de partidos de carrera todavía no invoca este puente automáticamente; hasta integrar ese flujo, no se deben interpretar estadísticas vacías como partidos disputados.

## Datos de jugadores y calibración real
- [Generación y calibración de futbolistas](docs/PLAYER_GENERATION_AND_CALIBRATION.md)
- [Metodología de valor de mercado de jugadores — referencia Transfermarkt](docs/PLAYER_MARKET_VALUE_METHODOLOGY.md)
- [Modelo de fuerza basado en fútbol real](docs/REAL_WORLD_STRENGTH_CALIBRATION.md)
- [Snapshot de fuentes y rankings](data/football_strength_sources.json)
- [Catálogo de habilidades por niveles](data/skills/skill_catalog.json)
- [Sistema de progresión y equipamiento de habilidades](scripts/player_skill_system.gd)


### Descargas recomendadas
Al iniciar el gestor de contenido, el juego recomienda instalar al menos diez ligas adicionales siguiendo el ranking (puestos 11–20) y descargar todas las selecciones nacionales disponibles. La recomendación es opcional y respeta el estado real de publicación: los paquetes planificados no se presentan como descargables hasta validar datos, fuentes y derechos. Consulta `data/national_teams_manifest.json` y `docs/DOWNLOADABLE_LEAGUE_MODULES.md`.


### Gestor de descargas Godot
- Catálogo regional: `scripts/ui/league_download_catalog.gd` (acceso desde el HUD).
- Gestor persistente: `scripts/data/content_package_manager.gd` (autoload `ContentPackages`).
- Recomendación de ligas y selecciones: `scripts/data/download_recommendation_service.gd`.
- El gestor verifica HTTPS y SHA-256, instala archivos en almacenamiento local y permite cancelar/reintentar/desinstalar. Los paquetes siguen sin publicarse hasta completar sus metadatos y validaciones. La integración de importación a las plantillas y competiciones y las pruebas en Godot 4 continúan pendientes.


### Importación del contenido descargado
- `scripts/data/downloaded_league_importer.gd`: valida e importa ligas instaladas al registro principal; sus competiciones reciben calendario y clasificación al iniciar.
- `scripts/data/downloaded_national_teams_importer.gd`: carga selecciones en un registro independiente, con plantillas validadas.
- Contratos: `data/downloaded_package_schema_v1.json` y `data/national_teams_package_schema_v1.json`.
- API: `FootballData.get_downloaded_national_teams()`, `FootballData.get_downloaded_national_team_roster(team_id)` y `FootballData.get_downloaded_content_import_summary()`.


### Datos iniciales de ligas adicionales y selecciones
- `data/imports/additional_league_club_membership_2026_27.json`: afiliación de primera división de los puestos 11–20, 166 clubes, con fuentes por liga. Aún no incluye plantillas y no habilita descargas.
- `data/national_association_directory.json`: directorio de las 211 asociaciones miembro de FIFA, con IDs internos y estados de validación. Aún no contiene plantillas de selecciones.
- Las fuentes y límites de uso están descritos en `docs/DOWNLOADABLE_LEAGUE_MODULES.md`.


### Recomendación de descargas
Al comenzar, el catálogo recomienda las diez ligas siguientes por ranking (puestos 11–20) y todas las selecciones nacionales que estén publicadas y verificadas. Consulta `data/imports/additional_league_club_membership_2026_27.json` para el lote preliminar de 166 clubes de esas diez ligas y `data/national_association_directory.json` para el directorio de 211 asociaciones FIFA. Estos directorios no equivalen a paquetes jugables: las ligas siguen pendientes de plantillas/derechos/validación y las selecciones aún no tienen paquetes publicados.


## Jugador personalizado: Anier Cumbá
- [Implementación, arquitectura, fases y validación pendiente](docs/ANIER_CUMBA_PLAYER_IMPLEMENTATION.md)
- [Actualización de apariencia de Anier Cumbá y Raymond (16-11-2026)](docs/PLAYER_APPEARANCE_UPDATE_2026-11-16.md)
- Perfil: `data/custom_players.json`
- Escena 3D: `scenes/players/anier_cumba.tscn`
- Controlador: `scripts/players/anier_cumba.gd`
- Módulo común de animación: `modules/nova_3d_animation/nova_3d_animation.gd`
- Prueba de contrato: `tests/test_anier_cumba_profile.gd`

**Estado:** perfil y blockout 3D incorporados; rostro final, rig deformable, clips de animación y validación dentro de Godot siguen pendientes. No se considera jugador terminado ni producción hasta superar esas pruebas.


## Diez ligas base — datos guardados
- Países: Inglaterra, España, Brasil, Italia, Alemania, Francia, Portugal, Argentina, Cuba y Estados Unidos.
- Catálogo: 725 clubes y 22 futbolistas ficticios por club (15.510 perfiles guardados en archivos de GitHub, más 440 perfiles de Primera de Cuba generados al iniciar).
- Los perfiles generados son ficticios y no deben confundirse con plantillas profesionales reales.
- Importación: `scripts/data/base_league_importer.gd` y `scripts/data/base_league_roster_importer.gd`, integrados en `scripts/data/football_data_service.gd`.
- Prueba de datos: `tests/test_base_league_data.gd`, incluida en GitHub Actions.
- Estado de publicación/jugabilidad: pendiente de ejecución satisfactoria de pruebas Godot/Android, revisión de calendarios especiales y revisión de derechos de identidad visual. No marcar como jugables ni descargables hasta completar esas verificaciones.

## Estructura cubana vigente — 15-11-2026
- Primera División: 16 clubes, 30 jornadas y 240 partidos.
- Segunda División: 16 clubes, 30 jornadas y 240 partidos.
- Tercera División: 20 clubes en dos grupos de diez; 9 jornadas a una vuelta y 45 partidos por grupo.
- Total cubano: 52 clubes y 1.144 futbolistas ficticios (352/352/440), 22 por plantilla.
- Morón Deportivo y Trinidad Colonial están en el Grupo Occidental de Tercera; Baracoa FC y Manzanillo Marítimo, en el Oriental. Sus 88 IDs de futbolistas se conservaron.
- Los campeones de Tercera ascienden directamente; los subcampeones disputan un playoff a doble partido por la tercera plaza.
- El esquema global data/player_statistics_schema.json se aplica al registrar jugadores: contadores a cero y promedios/porcentajes sin definir hasta que existan actas verificadas.
- Anier Cumbá conserva GRL 92, POT 97, dorsal 35 y posiciones MCO/MC.

**Validación:** se añadieron pruebas de coherencia de estadísticas, datos de ligas base y formato cubano. La ejecución real en Godot y la integración Android siguen pendientes de una ejecución CI válida; no se declara PASS por cambios guardados.

## Estadísticas y transición de temporadas — 15 noviembre 2026

- Los resultados simulados incluyen los once titulares de cada equipo. Al aplicar el resultado, el servicio registra para esos titulares apariciones, titularidades, minutos, victorias/empates/derrotas, goles identificados en los eventos y porterías a cero de los guardametas.
- Las estadísticas de carrera y de temporada se actualizan por separado, se normalizan sus promedios y se guardan en el catálogo local junto con el resultado de liga. Los datos de equipo no se reparten artificialmente entre jugadores.
- `NovaSeasonProgressionService` calcula movimientos de ascenso/descenso solo con jerarquía y reglas explícitas, rechaza sistemas cerrados y promociones que requieren playoff sin resolver, crea calendarios de la siguiente temporada y archiva estadísticas por temporada sin borrar los totales de carrera.
- `FootballData.start_next_season_for_stage(...)` exige que todos los encuentros de la fase estén finalizados antes de generar y persistir la nueva edición.
- `FootballData.archive_season_player_statistics(season_id)` archiva los datos individuales y reinicia únicamente los contadores de la temporada actual.
- Los movimientos de división requieren una configuración explícita por sistema y la resolución previa de playoffs; no se conectan MLS, USL Championship y USL League One.
- Pruebas añadidas: `tests/test_player_statistics_consistency.gd` y `tests/test_season_progression.gd`, incorporadas al workflow Godot CI. La ejecución efectiva de Godot sigue pendiente de un runner asignado.


## Auditoría de las diez ligas base — 15 noviembre 2026

**Clubes que faltan dentro del alcance seleccionado: 0.** El catálogo contiene los 725 clubes previstos y 15.950 perfiles ficticios, con 22 perfiles por club:

| País | Clubes |
|---|---:|
| Inglaterra | 68 |
| España | 82 |
| Brasil | 60 |
| Italia | 100 |
| Alemania | 56 |
| Francia | 54 |
| Portugal | 56 |
| Argentina | 125 |
| Cuba | 52 |
| Estados Unidos | 72 |
| **Total** | **725** |

Se añadió `tests/test_ten_base_leagues_complete.gd` para importar los diez países en un registro limpio y comprobar conteos por país, clubes únicos, plantillas de 22, jugadores y pertenencia a competiciones. El workflow ejecuta esta prueba. El dato de cero clubes pendientes se refiere al alcance de 10 ligas elegido; no significa que se hayan importado plantillas reales profesionales ni que las pruebas de Godot hayan pasado. Las plantillas son ficticias y la validación de ejecución sigue pendiente de un runner de GitHub Actions.


## Juego base ligero y módulos opcionales
- [Configuración de distribución ligera y agregados de Nova Apps](docs/LIGHTWEIGHT_BASE_AND_OPTIONAL_MODULES.md)
- [Manifiesto de módulos opcionales](data/game_modules_manifest.json)
- Fútbol Nova se diseña como juego base ligero más módulos independientes. Las funciones esenciales permanecen en el juego base; narración, música, estadios adicionales, gráficos avanzados, ligas adicionales, selecciones y otros agregados se separan cuando sea técnicamente seguro.
- La ficha de Fútbol Nova se registra en Nova Apps con una sección **Agregados**. Los módulos planificados no se muestran como descargas hasta que existan paquetes reales y superen verificaciones de integridad, derechos, compatibilidad e instalación.
- Formato preferido para recursos adicionales: PCK independiente de Godot; los paquetes de datos pueden usar ZIP. La carga dinámica genérica de PCK y la interfaz de agregados aún requieren implementación y pruebas Android.
- No se han medido todavía los tamaños reales del APK base ni de los módulos. No se publicarán tamaños inventados.


### Módulo opcional Mejoras gráficas
- Agregado: `futbol-nova-graphics-enhancements` / paquete `graphics_enhancements`.
- Adaptador: `scripts/graphics/graphics_enhancements_module.gd`; aplica tonemapping, exposición, iluminación ambiental y sombras solo cuando el paquete esté instalado.
- El juego base conserva su renderizado ligero y no depende del módulo. El paquete aún está en desarrollo y no se ofrece como descarga hasta generar y validar el artefacto y probar rendimiento visual en Android.


## Partido local 11 contra 11 — 16 noviembre 2026
- Se incorporó una primera escena de partido local con dos alineaciones 4-3-3, Anier Cumbá controlable y 21 futbolistas de IA con modelos procedurales ligeros.
- Acceso de prueba: botón **PARTIDO LOCAL 11 vs 11 · PRUEBA** en el HUD.
- La IA actualiza decisiones cada 200 ms para reducir trabajo en dispositivos móviles; mantiene estructura de equipo, bascula según el balón y presiona con el jugador más cercano.
- El partido sigue en fase de prototipo: faltan colisiones de jugadores, porteros completos, árbitro, reglas, posesión, pases inteligentes, faltas, fuera de juego, saques, sustituciones, animaciones y pruebas Android.
- Prueba estructural: `tests/test_match_11v11_foundation.gd`; añadida al workflow único existente, aún pendiente de ejecución CI verificable.
- Implementación: `scripts/gameplay/match_11v11_controller.gd`.
- Referencias técnicas públicas y revisión de licencias: `docs/OPEN_SOURCE_RESEARCH_AND_ATTRIBUTION.md`.

## Competiciones internacionales mundiales

El catálogo internacional de clubes incluye las tres ligas regionales americanas y el TAS, además de las competiciones de UEFA, CAF, AFC, OFC y los torneos intercontinentales FIFA. Consulta `docs/INTERNATIONAL_CLUB_COMPETITIONS.md` y `modules/continental_competitions/module_registry.json`.

Los torneos de selecciones se mantienen en un módulo independiente: `modules/national_team_competitions/`, con catálogo en `data/international_national_team_competitions.json` y documentación en `docs/NATIONAL_TEAM_TOURNAMENTS.md`. No se mezclan identificadores, plantillas ni resultados de clubes con los de selecciones.
## Archivo histórico real de competiciones

Los registros históricos reales se almacenan por separado en `data/competition_historical_reference.json`; consulta `docs/HISTORICAL_COMPETITION_DATA.md`. El archivo contiene 410 registros históricos y 50 fuentes. Las catorce competiciones con equivalente real ya tienen registros iniciales; la Concacaf Champions Cup reúne 59 temporadas con campeón registrado, aunque la mayoría aún no incluye finalistas ni marcadores; el TAS no tiene equivalente real y conserva su historia de carrera separada. No es todavía una historia completa. Los nombres reales de clubes y futbolistas son solo de referencia: el juego debe mostrar identidades ficticias originales y aprobadas, sin copiar escudos, equipaciones o marcas. El TAS es una competición original de Nova y no debe recibir una historia real inventada.

## Identidades originales de clubes — 17 noviembre 2026

- Se sustituyeron los 451 nombres provisionales de Brasil, Italia, Alemania, Francia, Portugal y Argentina por nombres ficticios originales y únicos.
- Se revisaron y sustituyeron los nombres de los 68 clubes ingleses, conservando IDs y referencias de sus 22 jugadores ficticios.
- Registro completo: `data/club_identity_name_review_2026-11-17.json`.
- Validador: `tools/validate_club_identity_names.py`, añadido al workflow Android/Godot.
- La aprobación se limita a los nombres de presentación. Escudos, equipaciones, marcas, membresías pendientes y asociaciones de futbolistas históricos siguen sujetos a sus propias revisiones. Ningún estado de jugabilidad o descarga se habilita con este cambio.

### Archivo histórico de partidos — corte 17 noviembre 2026

El archivo interno acumula **571 resultados y 1.618 goles** en seis ediciones con cobertura partido a partido. La UEFA Conference League 2025/26 se completó para la competición principal: 153 partidos (108 de fase liga y 45 eliminatorios), 379 goles. UCL y UEL 2025/26 conservan 189 partidos cada una. Libertadores 2025 tiene 29 partidos eliminatorios; CAF Champions League y CAF Confederation Cup 2025/26 tienen los dos partidos de cada final; AFC Champions League Elite 2025/26 tiene siete partidos de la fase final. Las cuatro últimas coberturas son parciales. El validador histórico comprueba IDs, fechas, equipos, goles, marcadores, fuentes y coherencia con estadísticas de temporada. El historial completo de todas las temporadas y las incidencias goleadoras por partido siguen pendientes.
 
La auditoría `data/historical_completion_audit_2026-11-17.json` registra el trabajo restante por edición: 403 de 410 ediciones todavía no tienen resultados partido a partido; solo 16 tienen fecha de final, 122 subcampeón/marcador, 14 goleadores y 3 estadísticas estructuradas. No hay mapeos aprobados de futbolistas reales a identidades ficticias. El TAS es una competición original de Nova y no recibe historia real.


## Jugador personalizado: Máximo Padilla
- [Ficha, datos confirmados, referencia visual y estado de integración](docs/MAXIMO_PADILLA_PLAYER.md).
- Perfil canónico: `data/custom_players.json` (ID `NOVA-PLAYER-0036`).
- Valoración confirmada por el propietario: GRL 94 y POT 97.
- Perfil de juego: MCD recuperador inspirado en Casemiro (Real Madrid); atributos base y ajustes de entrada/pase definidos en el perfil canónico.
- Fotografía JPEG válida optimizada (200 × 356 px): `assets/players/maximo_padilla_reference.jpg`.
- Escena 3D con cápsula de colisión: `scenes/players/maximo_padilla.tscn`.
- Controlador procedural con texto 3D de camiseta: `scripts/players/maximo_padilla.gd`.
- Plantilla: club `FN-ESP-BARCELONA` (Litoral Barcelona); jugador controlado en amistosos cuando Litoral Barcelona es local.
- Prueba automatizada: `tests/test_maximo_padilla_profile.gd`, ejecutada antes de exportar el APK.
- Pendiente de validación en Godot/Android: el runner de GitHub Actions no ha sido asignado; no hay APK probado.
