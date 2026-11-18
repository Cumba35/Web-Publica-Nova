# Global club and squad completion plan

## Division rule
Use the IFFHS 2025 men's national league ranking published 16 January 2026 as the tier-count baseline:
- Ranks 1–10: three divisions.
- Ranks 11–20: two divisions.
- Rank 21 onward: one division.
- Cuba remains at three divisions as already established in Fútbol Nova.
- The base-game top ten is a product selection, not a strict copy of the IFFHS ranking: Cuba and the United States replace Netherlands and Colombia at positions 9 and 10.
- Netherlands and Colombia are retained as optional future leagues, not deleted from the global research catalogue.
- United States requires a separate competition model: MLS, USL Championship and USL League One are not a conventional promotion/relegation pyramid.

This ranking sets the number of playable tiers, not which clubs belong in each tier. Membership must be confirmed against season-specific league/federation data.

## Top 20 configured
1 England — Premier League
2 Spain — LaLiga
3 Brazil — Brasileirão Série A
4 Italy — Serie A
5 Germany — Bundesliga
6 France — Ligue 1
7 Portugal — Primeira Liga
8 Argentina — Liga Profesional
9 Cuba — Sistema Nacional de Ligas de Cuba (estructura existente de tres divisiones)
10 Estados Unidos — MLS, USL Championship y USL League One (competiciones independientes)
11 Türkiye — Süper Lig
12 Belgium — Jupiler Pro League
13 Saudi Arabia — Saudi Pro League
14 Ecuador — LigaPro
15 Greece — Super League
16 Egypt — Premier League
17 Czechia — First League
18 Japan — J1 League
19 Paraguay — Primera División
20 Cyprus — First Division

The ranking source and country-specific OpenFootball clubs/players discovery paths are recorded in data/global_league_tiers.json.

## Source limitations and player assignment
OpenFootball Clubs is a broad public-domain discovery catalogue. It contains active, historical and reserve entities; its country file is not a season roster and must not be treated as such.
OpenFootball Players is organized by country and player bio, not guaranteed current club affiliation. It is a discovery source only. A nationality-only list must never be assigned to a club.
For current professional squad assignment, use a season-specific source that explicitly connects player to club and review its reuse terms. Do not scrape or redistribute Transfermarkt data without permission. Use Transfermarkt only as a valuation-method reference, not as an assumed freely reusable roster API.

## Completion pipeline
1. Obtain current and recent-season club membership per competition level.
2. Normalize into data/imports/verified_club_membership.csv.
3. Obtain squad rosters with explicit player-to-club relationship and legal reuse permission; normalize into data/imports/verified_player_squads.csv.
4. Build each country batch with the current schema: stable club IDs, per-division player JSON files, 22-player rosters, and a matching competition catalog. The existing `tools/build_global_database.py` is a legacy single-file pipeline and must not be used to overwrite the current split England batch until it is migrated to this schema.
5. Generate original SVG crests and original home/away/goalkeeper kit assets. No copying of club marks, official kit patterns, sponsors or manufacturers.
6. Validate duplicates, club tiers, roster size, positions, IDs, and source provenance.
7. Integrate the generated JSON into Godot's registry and run headless tests before release.

## Current truth — 15 November 2026

- Ten base countries are selected: England, Spain, Brazil, Italy, Germany, France, Portugal, Argentina, Cuba and United States. Netherlands and Colombia remain optional reserve leagues.
- The repository now stores **725 base clubs and 15,950 fictional player profiles**, with 22 profiles per club. All player data is original fictional game content, not real professional squads.
- England: 68 clubs / 1,496 saved fictional profiles.
- Spain: 82 clubs / 1,804 saved fictional profiles.
- Brazil: 60 clubs / 1,320 saved fictional profiles.
- Italy: 100 clubs / 2,200 saved fictional profiles.
- Germany: 56 clubs / 1,232 saved fictional profiles.
- France: 54 clubs / 1,188 saved fictional profiles.
- Portugal: 56 clubs / 1,232 saved fictional profiles.
- Argentina: 125 clubs / 2,750 saved fictional profiles; Federal A and Primera B Metropolitana are separate parallel third-tier competitions.
- Cuba: 52 clubs / 1,144 saved fictional profiles in three static division files.
- United States: 72 clubs / 1,584 saved fictional profiles; MLS, USL Championship and USL League One remain independent competitions.
- The base club importer, static roster importer and final 725-club / 15,950-player validation are integrated into `football_data_service.gd`.
- The master catalog now includes 891 club records and memberships (725 base + 166 additional reference clubs), 41 competitions, 20 country-seasons and 34 sources.
- All new roster files and tests are committed to GitHub. The test workflow includes USA and all-base-league data checks.
- Godot headless/runtime and Android tests have **not yet been executed successfully** in this environment. Do not mark any league playable or downloadable until CI passes.

## Additional first-division reference catalog — 14 November 2026

A further 166 club memberships across ten first divisions have been added to the master reference catalog: Türkiye, Belgium, Saudi Arabia, Ecuador, Greece, Egypt, Czechia, Japan, Paraguay and Cyprus. The seed is in `data/imports/additional_league_club_membership_2026_27.json`.

- The 166 records are club-membership references only; no playable player rosters are included.
- Several leagues still require a second source review; no package is marked downloadable.
- The runtime database also indexes the 82 Spanish fictionalized club identities and the 211-association FIFA directory.
- Current master catalog seeds total 368 club records. Only Cuba (52) and England (68) currently have playable 22-player rosters in the active registry; England's 1,496 players are fictional profiles.

The script and importer are controlled data pipelines, not evidence that the worldwide database is complete.

## Roster reference ingestion — 14 November 2026

Two additional datasets are now preserved in the master database as **reference-only**, not as playable player profiles:

- Türkiye Süper Lig 2026/27: 501 published registration-name records across 18 clubs.
- Belgium Jupiler Pro League 2026/27: 276 partial roster-name records across 9 clubs.

Both source packages explicitly state that reuse rights are not cleared and `playable=false`. The records retain their source club codes, names, shirt numbers and source URLs, but are not merged into the canonical player table. Missing nationality, position, age, height, statistics or eligibility are not inferred. They cannot be selected in matches or national teams until rights, full roster validation and identity matching are complete.

The master catalog also links 68 English and 82 Spanish source membership rows to their fictionalized in-game club IDs using `source_reference_id`. The 166 additional league memberships remain reference-only and pending second-source review.


## Base-game selection update — 15 November 2026

The ten base leagues are now England, Spain, Brazil, Italy, Germany, France, Portugal, Argentina, Cuba and the United States. Cuba reuses its existing `data/cuba_leagues.json` and `data/cuba_players.json` data; no Cuba records were deleted or regenerated. Netherlands and Colombia are retained in the optional future-league reserve. The United States base slot starts with MLS; the exact relationship of USL Championship and USL League One to the three-division game structure must be configured without inventing automatic promotion/relegation between separate closed competitions.


## Base-game squad work — 15 November 2026

### Cuba
- 52 clubs: 20 Primera, 16 Segunda and 16 Tercera.
- 1,144 saved profiles: Primera 440 (352 new + 88 retained with four restored S1 clubs), Segunda 352 and Tercera 352.
- All three divisions load from static GitHub roster files; no runtime-only first-division generation is required.

### United States
- 72 clubs catalogued for 2026: 30 MLS, 25 USL Championship and 17 USL League One.
- 1,584 fictional profiles saved in `data/players/usa_base_2026.json` (22 per club).
- The three competitions remain independent. Their exact official fixture calendars are not implemented, so fixture generation is intentionally skipped.

### Other base countries
- Spain, Brazil, Italy, Germany, France, Portugal and Argentina now have club catalogues and static fictional 22-player rosters.
- Brazil, Italy, Germany, France, Portugal and Argentina still require a final official season-membership audit.
- Argentina Liga Profesional phase rules and the USA competition-specific schedules remain pending.

### Release gate
All ten packages remain non-downloadable and are not certified playable until GitHub Actions/Godot tests pass, the outstanding membership and schedule audits are completed, and visual/name rights are reviewed.


### Calendarios jugables para calendarios federativos pendientes — 15 noviembre 2026

- Las competiciones que todavía no tienen calendario oficial importado ya no quedan sin partidos: Liga Profesional Argentina, MLS, USL Championship y USL League One reciben un calendario interno determinista de una vuelta.
- Cada fixture se etiqueta como `generated_single_round_robin` y `official_calendar_verified=false`. Es un calendario propio del juego para permitir iniciar temporadas y disputar partidos; no se presenta como el calendario oficial de la federación.
- El servicio de datos expone `simulate_fixture(stage_id, fixture_id, seed)` y `simulate_round(stage_id, round_number, seed)`: construye la fuerza a partir de las plantillas, simula, aplica el resultado y lo persiste con protección contra duplicados. Los resultados se rechazan si los IDs de los equipos no coinciden con el fixture.
- Se añadieron pruebas de cobertura, equilibrio de enfrentamientos, IDs y rechazo de resultados mal asociados. El workflow CI debe ejecutarlas; hasta obtener una ejecución Godot verde, la integración sigue sin certificación.
- El calendario generado no sustituye la importación de los calendarios oficiales MLS/USL ni resuelve las reglas de fases de Argentina. Los ascensos/descensos automáticos y la transición de temporada todavía necesitan un servicio integrado.

### CI status — 15 November 2026
The latest Fútbol Nova headless workflow run (`43753315917`, attempt 1) ended before any job step started: GitHub assigned no runner (`runner_id=0`, no steps). Therefore the Godot tests have **not executed**; this is not a passing validation and does not prove a code failure. The current code changes and new tests remain unverified by the engine.


## Integración de estadísticas y ciclo de temporada — 15 noviembre 2026

- La simulación de liga ahora adjunta los IDs de los once titulares de cada equipo.
- El servicio de estadísticas registra apariciones, titularidades, minutos, resultado individual, goles vinculados a eventos y porterías a cero de los porteros. Se conserva la distinción entre estadísticas de carrera y de temporada.
- El guardado de las estadísticas se realiza a través del snapshot de catálogo y los resultados/clasificaciones mediante el guardado transaccional de partido y competición. Si falla el guardado de estadísticas, se revierte la actualización en memoria y se rechaza el resultado.
- Se añadió `scripts/data/season_progression_service.gd`: planificación explícita de ascensos/descensos, protección de sistemas cerrados y playoffs pendientes, generación del siguiente calendario y archivo de estadísticas de temporada.
- FootballData expone APIs para planificar y aplicar movimientos validados, abrir una nueva edición de una fase completamente terminada y archivar estadísticas por temporada.
- Importante: no se activan reglas de ascenso para una liga hasta que su jerarquía y plazas estén configuradas. Cuba tiene playoffs y reglas regionales que deben resolverse antes de mover clubes; Estados Unidos mantiene sus tres competiciones separadas.
- Pruebas de estadísticas y transición añadidas al workflow. No se declara PASS hasta que Godot 4.4.1 ejecute todos los scripts en CI.

## Conteo actualizado de las diez ligas base — 15 noviembre 2026

No faltan clubes respecto al alcance base definido: **725 de 725 están catalogados (0 pendientes de incorporar)**. El desglose es Inglaterra 68, España 82, Brasil 60, Italia 100, Alemania 56, Francia 54, Portugal 56, Argentina 125, Cuba 52 y Estados Unidos 72. Hay 15.950 perfiles ficticios guardados (22 por club).

Se agregó una prueba integral que ejecuta los importadores en un registro limpio y verifica el total por país, las plantillas, las referencias a clubes y las membresías de competición. La prueba ya está en el workflow. No se declara validación runtime hasta que Godot se ejecute realmente: GitHub Actions ha estado cerrando los trabajos sin runner asignado. Las identidades de los clubes y futbolistas del juego son ficticias; no se han importado plantillas profesionales reales.


## Gate de identidad de clubes — 17 de noviembre de 2026

Los 68 clubes del lote inglés siguen siendo candidatos `draft_review_required`, no identidades aprobadas. El importador transmite el estado de revisión al catálogo maestro y bloquea `playable` hasta que el nombre, la revisión de marcas y los recursos visuales originales estén aprobados. Los 451 clubes de seis países en `base_league_clubs_2026.json` ya tienen nombres ficticios originales únicos y mantienen `player_ids=[]`; siguen pendientes las auditorías de membresía y plantillas, por lo que no se habilitan como jugables.

## Original fictional club display names — 17 November 2026

The 451 records that previously had provisional names across Brazil (60), Italy (100), Germany (56), France (54), Portugal (56) and Argentina (125) now have unique original fictional display names. The previous `Nova + reference club name` naming pattern has been removed from the game-facing `display_name` field. Stable club IDs, source reference IDs, competition membership, division and season fields are preserved; the six-country records remain membership-only with empty player references.

The 68 English club display names have also been replaced and reviewed as original fictional display names. Their 22 existing fictional player references per club remain attached to the same stable club IDs.

The complete name register is `data/club_identity_name_review_2026-11-17.json`; automated checks are in `tools/validate_club_identity_names.py`, included in the Android/Godot workflow.

**Approval boundary:** this completes the original game-facing name assignment and English display-name review only. It does not certify trademarks, crests, kits, sponsors, visual assets, or full club identity approval. Those remain release gates. The six-country membership audits and historical player identity links are also still pending. No club is made playable or downloadable by this name change.

