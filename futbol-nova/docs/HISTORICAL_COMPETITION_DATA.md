# Archivo histórico real de competiciones — Fútbol Nova

**Snapshot:** 17-11-2026  
**Dataset:** `data/competition_historical_reference.json`

## Regla de identidad y visualización

- Los registros oficiales se conservan en el archivo de referencia con nombres reales, temporada, resultados y fuentes.
- El juego no debe mostrar nombres reales de clubes ni futbolistas. La interfaz utilizará nombres ficticios originales de Fútbol Nova, aprobados y vinculados mediante un mapeo explícito.
- No se crea una equivalencia por semejanza ni se asigna un jugador histórico a una plantilla actual solo porque coincida el club.
- Los resultados, fechas y estadísticas reales no se alteran para adaptarlos a las identidades ficticias.
- Los campos sin verificación quedan en `null`; no se completan por inferencia.
- No se copian escudos, uniformes oficiales, patrocinadores ni marcas.

## Correspondencia de competiciones

| ID Fútbol Nova | Referencia real | Tratamiento |
|---|---|---|
| `caribbean_champions_league_nova` | Concacaf Caribbean Cup | 2023 en adelante; CFU Club Championship anterior se investiga por separado |
| `south_america_champions_league_nova` | CONMEBOL Libertadores | Referencia histórica; formato Nova independiente |
| `north_central_america_champions_league_nova` | Concacaf Champions Cup | Continuidad histórica de la competición de clubes de Concacaf |
| `american_super_champions_tas` | Sin equivalente real | Competición original de Nova; no inventar historia real |
| `uefa_champions_league_nova` | UEFA Champions League | European Cup y continuidad UCL |
| `uefa_europa_league_nova` | UEFA Europa League | UEFA Cup y continuidad Europa League |
| `uefa_conference_league_nova` | UEFA Conference League | Desde 2021/22 |
| `caf_champions_league_nova` | CAF Champions League | African Cup of Champions Clubs y continuidad CAF |
| `caf_confederation_cup_nova` | CAF Confederation Cup | Desde 2004 |
| `afc_champions_league_elite_nova` | AFC Champions League Elite | Historia ACL con continuidad/eras verificadas |
| `afc_champions_league_two_nova` | AFC Champions League Two | AFC Cup anterior se identifica como predecesora |
| `afc_challenge_league_nova` | AFC Challenge League | No fusionar otros torneos automáticamente |
| `ofc_champions_league_nova` | OFC Champions League | Investigar continuidad OFC Club Championship |
| `fifa_intercontinental_cup_nova` | FIFA Intercontinental Cup | 2024 en adelante; torneos anteriores relacionados, pero separados |
| `fifa_club_world_cup_nova` | FIFA Club World Cup | Ediciones 2000, 2005–2023 y formato ampliado desde 2025 |

## Primera carga de registros

El JSON incorpora actualmente 407 registros históricos iniciales:
- Caribbean Cup 2023–2025: campeones, finalistas, marcadores agregados y goleador de 2023 disponible.
- CONMEBOL Libertadores 1960–2025: 66 ediciones con campeones, subcampeones y resultados finales.
- CAF Champions League 1964–2025: lista de campeones; final 2025/26 con campeón, subcampeón, marcador agregado, fechas, sedes y goleadores de ambas vueltas.
- CAF Confederation Cup 2004–2025: campeones, finalistas y resultados de finales.
- UEFA Conference League 2021/22–2025/26: campeones, finalistas, finales y goleadores de temporada.
- UEFA Champions League 1955/56–2025/26: 71 ediciones con campeones; finales y resultados 1992/93–2025/26 donde están incluidos.
- UEFA Cup / Europa League 1971/72–2025/26: 55 ediciones con campeones; finalistas y marcadores recientes donde están disponibles.
- AFC Champions League Elite: palmarés histórico asiático 1967–2014 y finales 2024/25–2025/26.
- OFC Club Championship / OFC Champions League: 25 registros de temporadas 1987–2026, incluidos los años sin competición por COVID-19; final 2026 con subcampeón, fecha, sede y goleadores.
- AFC Champions League Two y AFC Challenge League 2025/26: campeones, finalistas y resultado final disponible.
- Concacaf Champions Cup: 59 temporadas con campeón registradas a partir de la lista oficial de Concacaf (1962–2025); la edición 2025 conserva además final, goleadores y máximo goleador. En las 57 temporadas añadidas solo se consigna el campeón cuando la fuente no ofrece finalistas ni marcador. La edición 2026 incluye final 1-1, penaltis 6-5, sede, goleadores y premios individuales.
- FIFA Club World Cup 2025: campeón, subcampeón, final, goleadores y premios disponibles.
- FIFA Intercontinental Cup 2024 y 2025: campeones, finalistas y resultados.

## Fuentes

Cada fuente, URL, entidad editora, fecha de consulta y alcance está registrada en el JSON. Se priorizan FIFA, UEFA, CAF, AFC, Concacaf y CONMEBOL. Que una fuente esté registrada no significa que cada campo de todas las ediciones esté completo.

## Pendiente para completar el archivo histórico

1. Completar las temporadas históricas que faltan y ampliar los finalistas y marcadores de las competiciones con registros solo de campeones; no inferir temporadas omitidas.
2. Añadir calendarios y resultados partido a partido, con fechas, sedes y goleadores cuando haya fuentes.
3. Incorporar goleadores por edición, asistencias, tarjetas, alineaciones, premios, asistencia y estadísticas publicadas.
4. Resolver cambios de nombre, fusiones, sucesiones y cambios de formato sin duplicar títulos.
5. Construir el mapeo entre clubes/jugadores reales de referencia e identidades ficticias ya existentes en Fútbol Nova.
6. Añadir validadores de fuentes, unicidad de edición, consistencia de marcadores y bloqueo de nombres reales en la interfaz.
7. Mantener el TAS separado como competición original de Nova y guardar sus escenarios de carrera fuera del historial oficial.

**Actualización 17-11-2026:** el archivo contiene 410 registros de edición y 50 fuentes. Se añadieron los 153 resultados de la UEFA Conference League 2025/26 (108 de fase liga y 45 eliminatorios), con 379 goles; Ismaïla Sarr fue máximo goleador con nueve tantos y Jean-Philippe Mateta marcó el gol de la final. El archivo acumula 571 resultados y 1.618 goles en siete archivos de temporada: UEFA Champions League 2025/26 (189), UEFA Europa League 2025/26 (189), UEFA Conference League 2025/26 (153), Libertadores 2025 (29 eliminatorias), CAF Champions League 2025/26 (2 finales) y CAF Confederation Cup 2025/26 (2 finales) y AFC Champions League Elite 2025/26 (7 partidos de fase final). Los tres torneos UEFA tienen sus partidos de competición principal completos; Libertadores, las dos competiciones CAF y AFC Elite siguen parciales. Se añadieron validaciones de IDs, fechas, marcadores, fuentes y estadísticas.

**Estado:** carga inicial parcial. Solo están respaldados los registros y campos incluidos en el JSON. No se ha declarado completa ninguna historia ni plantilla real licenciada.

## Auditoría exacta de cobertura — 17 noviembre 2026

La auditoría reproducible guardada en `data/historical_completion_audit_2026-11-17.json` cuantifica los huecos del archivo: de 410 ediciones registradas, 7 tienen resultados partido a partido (571 partidos en total) y **403 aún no tienen archivo de partidos**. Solo 16 ediciones tienen fecha de final registrada, 122 tienen subcampeón y marcador final, 14 tienen goleadores de temporada y 3 tienen estadísticas estructuradas. No existe todavía ningún mapeo aprobado de identidades históricas reales a jugadores ficticios. Hay 14 competiciones reales con ediciones y un módulo TAS original de Nova, que no debe recibir historia real.

