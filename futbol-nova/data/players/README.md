# Fútbol Nova — player roster datasets

All files in this folder are versioned game data. Every newly added base-league roster in this batch contains 22 **fictional Fútbol Nova player profiles per club**. These are not real professional players and do not claim to reproduce real-world club squads.

## Base-game country files

| Country | Season | Clubs | Profiles | File |
|---|---|---:|---:|---|
| England | 2026/27 | 68 | 1,496 | `england_premier_2026_27.json`, `england_championship_2026_27.json`, `england_league_one_2026_27.json` |
| Spain | 2026/27 | 82 | 1,804 | `esp_base_2026_27.json` |
| Brazil | 2026 | 60 | 1,320 | `bra_base_2026.json` |
| Italy | 2026/27 | 100 | 2,200 | `ita_base_2026_27.json` |
| Germany | 2026/27 | 56 | 1,232 | `ger_base_2026_27.json` |
| France | 2026/27 | 54 | 1,188 | `fra_base_2026_27.json` |
| Portugal | 2026/27 | 56 | 1,232 | `por_base_2026_27.json` |
| Argentina | 2026 | 125 | 2,750 | `arg_base_2026.json` |
| Cuba | 2026 | 52 | 1,144 | `cuba_first_division.json`, `cuba_second_division.json`, `../cuba_players.json` |
| United States | 2026 | 72 | 1,584 | `usa_base_2026.json` |

Total: **725 clubs and 15,950 fictional profiles**, 22 per club.

## Import pipeline

- `scripts/data/cuba_roster_importer.gd` loads the three Cuban roster files.
- `scripts/data/base_league_roster_importer.gd` loads Spain, Brazil, Italy, Germany, France, Portugal, Argentina and USA.
- `scripts/data/football_data_service.gd` validates that 725 clubs and 15,950 profiles are registered and that every club has a 22-player roster.
- `tests/test_base_league_data.gd` validates saved files, club references, IDs, profile schema and roster sizes.
- `tests/test_shared_foundation.gd` and `tests/test_football_database.gd` cover service and persistent master-catalog integration.

## Data rules

1. Keep club membership references separate from fictional game identities.
2. Do not relabel generated players as real professional footballers.
3. Keep stable player IDs and the `club_id` relationship.
4. Do not replace existing files or Cuba/England data without reading the current file and updating the corresponding manifest/status records.
5. Keep `playable=false` and `downloadable=false` until engine tests, season membership audits, schedule rules and rights reviews pass.


## Estadísticas unificadas — 15-11-2026

Los **15.950 perfiles de las diez ligas base** reciben el mismo bloque de estadísticas al registrarse en el catálogo del juego, mediante `scripts/data/player_statistics_service.gd` y `scripts/data/football_data_registry.gd`. Esto incluye los datos de Inglaterra, España, Brasil, Italia, Alemania, Francia, Portugal, Argentina, Cuba y Estados Unidos.

Cada jugador dispone de estadísticas de carrera y temporada: partidos, titularidades, suplencias, minutos, resultados, goles, asistencias, tiros, pases, precisión, creación, regates, defensa, disciplina, portería y valoración. Las tasas y medias se recalculan a partir de sus totales y denominadores; cuando no hay partidos o intentos registrados se muestran como no disponibles (`null`), no como porcentajes falsos.

Los perfiles ficticios conservan sus identidades, clubes, posiciones, nacionalidades, atributos, GRL y potencial. Las estadísticas de partido solo se incrementan mediante resultados/eventos registrados; no se generan goles ni asistencias a partir de la valoración general.

## Auditoría global de las diez ligas

El objetivo base es de **725 clubes**: Inglaterra 68, España 82, Brasil 60, Italia 100, Alemania 56, Francia 54, Portugal 56, Argentina 125, Cuba 52 y Estados Unidos 72. Los diez paquetes suman 15.950 perfiles ficticios, exactamente 22 por club. No faltan clubes dentro del alcance definido (0 pendientes de incorporación). La prueba integral `test_ten_base_leagues_complete.gd` comprueba la importación conjunta; su ejecución real sigue pendiente de un runner Godot CI.
