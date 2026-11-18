# España 2026/27 — lote inicial de base de datos

**Fecha de catálogo:** 14-11-2026  
**Estado:** membresía de 82 clubes catalogada y 1.804 perfiles ficticios (22 por club) guardados en GitHub; integración Godot y revisión de identidades pendientes.

## Cobertura

| Nivel | Competición de referencia | Clubes | Grupos |
|---|---|---:|---:|
| 1 | Primera División | 20 | 1 |
| 2 | Segunda División | 22 | 1 |
| 3 | Primera Federación | 40 | 2 |
| **Total** | | **82** | **4** |

La estructura sigue el alcance de tres niveles establecido para los diez primeros países del ranking de ligas. Primera Federación se conserva en sus dos grupos oficiales.

## Fuentes primarias consultadas

- LALIGA — [clubes de Primera División 2026/27](https://www.laliga.com/laliga-easports/clubes).
- LALIGA — [clubes de Segunda División 2026/27](https://www.laliga.com/laliga-hypermotion/clubes).
- RFEF — [grupos de Primera Federación 2026/27](https://rfef.es/es/noticias/aprobados-los-grupos-de-primera-federacion-para-la-temporada-202627).
- RFEF — [estructura de Segunda Federación 2026/27](https://rfef.es/es/noticias/definidos-los-grupos-de-segunda-federacion-para-la-temporada-202627).

## Archivos creados

- `data/spain_leagues_2026_27.json`: competiciones, grupos, puntuación y metadatos de ascenso/descenso.
- `data/spain_clubs_2026_27.json`: 82 clubes de juego con IDs estables, localidad, división, grupo y referencias de origen.
- `data/imports/spain_2026_27_club_membership.csv`: tabla normalizada de pertenencia de clubes y procedencia.
- `data/global_database_import_status.json`: registro del lote y sus pendientes.

## Identidad y derechos

Los nombres visibles del juego son propuestas ficticias originales derivadas de topónimos y conceptos generales. La relación con el club real se conserva como referencia interna de investigación. Ningún escudo, uniforme, patrocinador ni logotipo oficial se ha importado. Los nombres ficticios y sus diseños requieren revisión editorial y de marcas antes de publicarse.

## Plantillas de jugadores

Se guardó `data/players/esp_base_2026_27.json` con 1.804 perfiles ficticios (22 por club), posiciones, edades, atributos y potencial. Son jugadores originales de Fútbol Nova; **no representan plantillas profesionales reales ni afiliaciones verificadas**. La identidad ficticia y los datos de referencia de clubes permanecen separados.

## Validaciones realizadas

- 82 referencias de clubes en 3 niveles y 4 grupos.
- IDs deterministas con prefijos `FN-ESP-` y referencias de origen `ESP-2026-27-`.
- Temporada uniforme `2026-27`.
- 1.804 perfiles ficticios estáticos guardados; 22 por club, con IDs únicos y atributos en el esquema del juego.
- Integración Godot y pruebas de motor todavía pendientes.
