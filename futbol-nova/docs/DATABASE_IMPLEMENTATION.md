# Fútbol Nova — base de datos local y catálogo maestro

**Versión:** 1.0.0  
**Arquitectura:** offline-first, JSON versionado de Godot  
**Estado:** integración inicial implementada; ejecución de Godot CI pendiente.

## Almacenamiento

El autoload `FootballDatabase` usa `user://football_database.json`. La base se escribe primero en un archivo temporal y se confirma mediante renombrado atómico. Se conserva una copia `user://football_database.json.bak`; si el archivo principal falta o no se puede leer, el servicio intenta recuperar la copia.

No se requiere cuenta, servidor, conexión a Internet ni credenciales para jugar con los datos instalados. Los catálogos fuente permanecen en `res://data/`; las temporadas, resultados y datos de carrera se guardan en el espacio escribible del dispositivo.

## Tablas

| Tabla | Contenido |
|---|---|
| catalog.players | Futbolistas del registro jugable, indexados por ID |
| catalog.teams | Clubes cargados para el juego |
| catalog.competitions | Competiciones cargadas para el juego |
| master_catalog.associations | Directorio de asociaciones FIFA |
| master_catalog.countries | Países y territorios vinculados a sus asociaciones FIFA |
| master_catalog.clubs | Clubes jugables y clubes de referencia no jugables |
| master_catalog.competitions | Competiciones por país y temporada |
| master_catalog.seasons | Temporadas normalizadas |
| master_catalog.sources | Fuentes, fecha de consulta, licencia y confianza |
| master_catalog.national_teams | Selecciones importadas desde paquetes verificados |
| master_catalog.national_players | Futbolistas incluidos en paquetes nacionales |
| master_catalog.league_directory | 100 ligas seleccionadas para investigación, sin asumir que sean jugables |
| master_catalog.club_memberships | Inscripciones de los 891 clubes por competición y temporada |
| master_catalog.reference_roster_packages | Plantillas de referencia no jugables y con derechos pendientes |
| match_results | Resultados finalizados, con ID único |
| competition_states | Calendarios y clasificaciones por fase |
| season_states | Estado completo de una temporada |
| career_records | Copia de respaldo de carreras Manager y Leyenda |
| audit_log | Historial de cambios recientes |

## Integración de juego

- `FootballData` genera el registro inicial desde los catálogos incluidos y paquetes instalados.
- Después de validar las referencias, guarda el snapshot del registro y el catálogo maestro.
- La inicialización se marca como fallida si falla la importación base o la persistencia del catálogo; los fallos de paquetes opcionales quedan como advertencias sin bloquear el catálogo base.
- `apply_match_result` actualiza la clasificación, marca el fixture como finalizado y guarda resultado + calendario + tabla en una sola transacción.
- Al reiniciar, se restauran las fases guardadas para conservar resultados y posiciones.
- Los servicios Manager y Leyenda mantienen sus archivos de guardado compatibles y reflejan también el estado en la base de datos central.
- Los paquetes descargados siguen sujetos a HTTPS, tamaño, SHA-256, esquema, IDs y relaciones válidas.

## Integridad y recuperación

- IDs vacíos o duplicados rechazados.
- Referencias de plantillas a jugadores inexistentes rechazadas.
- Competiciones con clubes inexistentes rechazadas.
- Selecciones con referencias a jugadores no incluidos rechazadas.
- No se guarda dos veces el mismo resultado de partido.
- Los cambios de resultado y clasificación se confirman juntos.
- Migración de esquema conocida: `0.9.0 → 1.0.0`; versiones futuras desconocidas se rechazan para evitar corrupción.
- La bitácora conserva los últimos 2.000 eventos.

## Cobertura del catálogo base en esta entrega

La base maestra integra los diez países elegidos para el juego base. Cada club base dispone de 22 perfiles ficticios guardados en GitHub; esos perfiles no son futbolistas profesionales reales ni plantillas reales verificadas.

| País | Clubes | Perfiles ficticios | Temporada / estado |
|---|---:|---:|---|
| Cuba | 52 | 1.144 | Tres divisiones; archivos estáticos |
| Inglaterra | 68 | 1.496 | 2026/27; archivos estáticos |
| España | 82 | 1.804 | 2026/27; archivos estáticos |
| Brasil | 60 | 1.320 | 2026; membresía pendiente de auditoría final |
| Italia | 100 | 2.200 | 2026/27; membresía pendiente de auditoría final |
| Alemania | 56 | 1.232 | 2026/27; membresía pendiente de auditoría final |
| Francia | 54 | 1.188 | 2026/27; membresía pendiente de auditoría final |
| Portugal | 56 | 1.232 | 2026/27; membresía pendiente de auditoría final |
| Argentina | 125 | 2.750 | 2026; fases y membresía pendientes de auditoría final |
| Estados Unidos | 72 | 1.584 | 2026; MLS/USL son competiciones independientes |
| **Total base** | **725** | **15.950** | **22 por club** |
| 10 ligas adicionales de referencia | 166 | 0 | Membresías de referencia; no jugables |
| **Total del catálogo maestro** | **891** | **15.950** | **725 clubes base con plantillas ficticias** |

Además, se incorpora el directorio de **211 asociaciones FIFA y 211 países/territorios normalizados**, con las seis confederaciones asignadas y verificadas (AFC 46, CAF 54, Concacaf 35, CONMEBOL 10, OFC 11 y UEFA 55), y el directorio de **100 ligas seleccionadas** para ordenar la investigación. La selección de 100 ligas no implica que sus 100 competiciones estén verificadas o listas para jugar.

El catálogo maestro incluye **891 membresías**, **41 competiciones**, **20 temporadas país** y **34 fuentes**. Las 150 membresías inglesas y españolas (68 + 82) conservan sus vínculos de referencia de temporada; las membresías de Cuba, USA y las otras seis ligas base se identifican como contenido de juego/catalogado, no como afiliaciones profesionales verificadas. Las 166 ligas adicionales permanecen como referencias sin plantillas.

Se conservan además **777 nombres de jugadores de referencia** en dos paquetes separados: 501 registros de la Süper Lig turca (18 clubes) y 276 registros parciales de la Jupiler Pro League belga (9 clubes). Sus derechos de reutilización no están despejados: no se mezclan con los perfiles ficticios base y permanecen no jugables.

Los 15.950 perfiles de las diez ligas base son ficticios. No son plantillas profesionales reales. Las ligas no se declaran jugables ni descargables hasta que pasen las pruebas Godot/Android, la auditoría final de membresías, los calendarios especiales y la revisión de derechos.
## Archivos principales

- `scripts/data/football_database_service.gd`
- `scripts/data/master_catalog_importer.gd`
- `scripts/data/football_data_registry.gd`
- `scripts/data/football_data_service.gd`
- `data/runtime_database_schema_v1.json`
- `tests/test_football_database.gd`

## Validación pendiente

El workflow Godot CI incluye pruebas para el servicio de base de datos, importación de catálogos, integridad referencial, persistencia de resultados, recuperación de estados y reapertura del servicio para comprobar que el catálogo maestro, los resultados y las carreras sobreviven a una nueva instancia. Hasta que GitHub Actions ejecute Godot 4.4.1 y entregue un resultado exitoso, la compatibilidad de parser/runtime debe considerarse pendiente.
