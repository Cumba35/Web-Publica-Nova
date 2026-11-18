# Liga de Campeones del Caribe — implementación

**Estado:** motor de competición integrado en el servicio de datos; edición real bloqueada hasta completar las plazas, disponer de los 48 clubes jugables y confirmar la sede neutral. La ejecución de pruebas Godot queda pendiente en un entorno con Godot 4.

## Formato implementado

- 48 clubes de Primera División, sin duplicados.
- Sorteo restringido: los clubes de una misma asociación CFU quedan en grupos diferentes; cada grupo admite como máximo un club de cada asociación.
- Cuatro grupos de 12, una vuelta: 11 partidos por club, 66 por grupo y 264 en total.
- Los tres primeros de cada grupo pasan directamente a octavos.
- Repesca intergrupal a doble partido: A4-B5, B4-A5, C4-D5 y D4-C5.
- Octavos, cuartos y semifinales a doble partido.
- Los dos perdedores de semifinales disputan un partido único por el tercer puesto, en la misma sede neutral confirmada para la final.
- Final a partido único en sede neutral, cuya sede debe registrarse antes del inicio.
- No se aplica gol de visitante. Un empate global queda pendiente de decisión por prórroga/penaltis; el motor no inventa un criterio de desempate. La generación de la repesca se bloquea si hay empate de puntos que afecte a los cinco primeros o al corte del quinto puesto, hasta aprobar y resolver el desempate.

## Integración técnica

La competición también está registrada en `data/international_club_competitions.json`.

Motor: `scripts/simulation/caribbean_champions_league_engine.gd`.

Servicio integrado: `scripts/data/football_data_service.gd`.

La edición, grupos, calendarios, clasificaciones, eliminatorias y sede se guardan en el estado de temporada mediante `FootballDatabase.save_season_state`. Los resultados de partidos pasan por el mismo simulador y registro de resultados que el resto de competiciones.

### Operaciones expuestas por FootballData

- `qualify_caribbean_champions_league(slot_distribution, domestic_tables)`: toma las plazas y las clasificaciones nacionales; solo considera filas de Primera División y bloquea empates de posición sin resolver en las plazas asignadas.
- `create_caribbean_champions_league_edition(season_id, participants, neutral_final_venue, seed)`: valida 48 clubes disponibles en el catálogo jugable y crea la fase de grupos.
- `get_caribbean_champions_league_state(season_id)`: recupera la edición guardada.
- `simulate_caribbean_champions_league_fixture(season_id, fixture_bucket, fixture_id, seed)`: simula y registra un partido de grupos o eliminatorias.
- `build_caribbean_champions_league_playoff(season_id)`: genera la repesca cuando todos los partidos de grupos están finalizados.
- `set_caribbean_champions_league_round_of_16_draw(season_id, pairings)`: registra ocho emparejamientos y valida que sean los 12 clasificados directos y los cuatro ganadores de repesca.
- `set_caribbean_knockout_round(season_id, round_id, pairings)`: genera octavos, cuartos o semifinales, validando los ganadores de la ronda anterior.
- `resolve_caribbean_knockout_tie(season_id, fixture_bucket, tie_id, winner_team_id)`: registra al ganador por penaltis solo cuando el agregado sigue empatado tras la prórroga; no aplica gol visitante.
- `set_caribbean_champions_league_final(season_id, finalist_a, finalist_b)`: crea la final solo con los ganadores de semifinales y la sede confirmada.

## Temporada actual 2026-2027 — calendario estilo Champions League

**Inicio oficial:** 10 de octubre de 2026. **Final única:** 10 de junio de 2027. Al 16 de noviembre de 2026, la temporada está en curso; las tres primeras ventanas han transcurrido y la siguiente es la jornada 4.

La fase de grupos mantiene once jornadas y 264 partidos, distribuidos en ventanas espaciadas. Cada jornada contiene 24 partidos: seis por grupo.

| Jornada | Ventana |
|---|---|
| 1 | 10–13 octubre 2026 |
| 2 | 24–27 octubre 2026 |
| 3 | 7–10 noviembre 2026 |
| 4 | 21–24 noviembre 2026 |
| 5 | 5–8 diciembre 2026 |
| 6 | 19–22 diciembre 2026 |
| 7 | 16–19 enero 2027 |
| 8 | 30 enero–2 febrero 2027 |
| 9 | 13–16 febrero 2027 |
| 10 | 27 febrero–2 marzo 2027 |
| 11 | 12–15 marzo 2027 |
| Repesca, ida / vuelta | 26 marzo / 2 abril 2027 |
| Octavos, ida / vuelta | 9 / 16 abril 2027 |
| Cuartos, ida / vuelta | 23 / 30 abril 2027 |
| Semifinales, ida / vuelta | 7 / 14 mayo 2027 |
| Reserva | 15 mayo–9 junio 2027 |
| **Final única** | **10 junio 2027** |

Las fechas son ventanas de planificación: el día exacto de cada partido debe asignarse al fixture y revisarse frente a las ventanas de selecciones y las competiciones nacionales. No se deben interpretar las jornadas ya transcurridas como partidos disputados ni inventar resultados.

## Partido por el tercer puesto

El partido por el tercer puesto enfrenta a los dos perdedores de semifinales en un único encuentro en sede neutral. El motor lo genera al confirmar los dos finalistas y lo guarda como `knockout_fixtures.third_place`; aplica prórroga y penaltis si el partido termina empatado. Para 2026-2027 está programado el 21 de mayo de 2027, antes de la final del 10 de junio.

## Historia de la competición y carrera de Anier

La competición fue fundada el **10 de octubre de 2020**. La temporada actual 2026-2027 es su séptima edición; al comenzar, el 10 de octubre de 2026, cumple seis años. Alcanzará siete años de funcionamiento el 10 de octubre de 2027. Antes de la temporada actual se completaron seis temporadas (2020-2021 a 2025-2026).

Anier Cumbá ganó dos títulos consecutivos con Santiago de Cuba: la edición 2023-2024 (final del 10 de junio de 2024) y la edición 2024-2025 (final del 10 de junio de 2025). Su fichaje por el Real Madrid quedó fechado el 23 de junio de 2025, trece días después del segundo título. El campeón de 2025-2026 y los campeones de las tres primeras ediciones siguen pendientes de documentación.

## Pendientes que bloquean una edición real

1. Incorporar los 48 clubes de Primera División al catálogo jugable con datos verificables.
2. Confirmar la sede neutral de la final antes del inicio del torneo.
3. Aprobar criterios generales de desempate; hasta entonces, el motor bloquea clasificaciones afectadas y exige registrar la resolución de un empate global.
4. Vincular las fechas del calendario propuesto a cada fixture generado por el motor.
5. Ejecutar pruebas en Godot 4 y validar la interfaz de usuario. No se declara la prueba como superada hasta ejecutarla en ese entorno.
6. La interfaz de usuario debe invocar estas operaciones desde los menús de competición y sorteo; la integración de backend no crea por sí sola las pantallas.

## Prueba añadida

`tests/test_caribbean_champions_league.gd` verifica las 48 plazas asignadas, la exigencia de sede neutral, 4 grupos de 12, 66 partidos por grupo, 11 partidos por club, 264 partidos totales, prevención de clubes duplicados, repesca y final a partido único.


## Participaciones consecutivas de Anier Cumbá

Se registran cuatro participaciones consecutivas de Anier Cumbá en la Liga de Campeones del Caribe: **2021-2022, 2022-2023, 2023-2024 y 2024-2025**. Su último partido en la competición fue la final del 10 de junio de 2025, que ganó con Santiago de Cuba para conquistar su segundo título consecutivo. Anier **no disputó partidos por el tercer puesto**. Esta participación histórica no modifica el formato del partido por el tercer puesto, que sigue reservado a los perdedores de semifinales.


### Resultados históricos de Anier por edición

- **2021-2022:** 11.º puesto.
- **2022-2023:** 6.º puesto.
- **2023-2024:** campeón con Santiago de Cuba.
- **2024-2025:** campeón con Santiago de Cuba.

Los puestos de 2021-2022 y 2022-2023 corresponden al historial de participación de Anier; no se infiere ni se registra un club para esas dos temporadas sin confirmación expresa.

## Clasificación al Torneo Americano de Supercampeones (TAS)

La Liga de Campeones del Caribe aporta **tres clubes** al Torneo Americano de Supercampeones (TAS) y es la **única competición que representa al Caribe** en ese torneo. La Copa del Caribe de Concacaf y el CFU Club Shield quedan excluidos de la lista de competiciones clasificatorias del TAS para evitar duplicar la representación caribeña. Las otras dos competiciones regionales registradas son la **Liga de Campeones de Sudamérica** y la **Liga de Campeones de Norteamérica y Centroamérica**; cada una aporta tres clubes al TAS.

1. **Campeón:** ganador de la final.
2. **Subcampeón:** perdedor de la final.
3. **Tercer puesto:** ganador del partido único por el tercer puesto, disputado por los dos perdedores de semifinales.

La regla general del TAS es de tres representantes por competición regional. Si una competición regional no organiza un partido por el tercer puesto, se tomará el club que tenga oficialmente registrado el tercer puesto. El formato, número total de participantes, calendario, sede y sistema de eliminatorias del TAS quedan pendientes de definición; no se presuponen en esta fase.



## Presentación del sorteo
La creación de la edición de la Liga de Campeones del Caribe emite el sorteo de grupos a `FootballData.draw_ceremony_requested`. Los sorteos de octavos y rondas eliminatorias también usan el mismo evento; GameHub muestra la ceremonia animada y permite saltarla sin modificar los emparejamientos ya guardados. Detalles generales en `docs/COMPETITION_DRAW_CEREMONY.md`.
