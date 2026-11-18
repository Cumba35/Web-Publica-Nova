# Campeonato cubano de Fútbol Nova — reglamento adaptado al modelo español

**Estado:** reglamento de datos añadido y primera lógica de desempates/clasificación implementada. Pendiente de ejecución en Godot y de integrar el calendario de copa/supercopa con la interfaz de temporada.

## Principio de adaptación
Se toma como referencia el sistema competitivo español (LaLiga, Copa del Rey y Supercopa de España), adaptándolo al número de clubes y a la estructura ficticia actual de Fútbol Nova. No se afirma que estas competiciones sean oficiales de la Federación Cubana.

## Primera División de Cuba
- 16 clubes originales ficticios.
- Grupo único, todos contra todos a ida y vuelta.
- 30 jornadas y 240 partidos.
- Victoria: 3 puntos; empate: 1; derrota: 0.
- Campeón: primer clasificado.
- Descienden los tres últimos a Segunda División.
- Desempate: puntos; minitabla de enfrentamientos directos (puntos, diferencia y goles); diferencia general; goles a favor; puntos disciplinarios (menos es mejor); sorteo.

Los 16 clubes de Primera tienen plantillas guardadas de 22 jugadores. Morón Deportivo, Trinidad Colonial, Baracoa FC y Manzanillo Marítimo se mantienen en Tercera; sus 88 perfiles se conservan en las plantillas de esa división.

## Segunda División de Cuba
- Se conservan los 16 clubes ya existentes; no se inventan seis equipos solo para imitar la cantidad de 22 de la Segunda española.
- Liga de grupo único a doble vuelta: 30 jornadas y 240 partidos.
- Puntuación y desempates españoles.
- Ascienden directamente los dos primeros.
- Puestos 3.º a 6.º disputan playoff: semifinales y final a ida y vuelta; el ganador ocupa la tercera plaza de ascenso.
- Descienden los tres últimos a Tercera División.

## Tercera División de Cuba
- Tercera reúne 20 clubes en dos grupos regionales de diez.
- Cada grupo disputa una vuelta: 9 jornadas y 45 partidos por grupo (90 partidos en total).
- Puntuación y desempates españoles.
- Los dos primeros de cada grupo clasifican a la fase de ascenso: los campeones regionales ascienden directamente y los subcampeones disputan una eliminatoria a doble partido por la tercera plaza.
- Ascienden tres clubes a Segunda División.
- La integración completa del playoff con el flujo de temporada requiere validación en Godot.

## Copa de Cuba
Modelo inspirado en Copa del Rey:
- Acceso para clubes elegibles de Primera, Segunda y Tercera.
- Eliminatorias a partido único desde las primeras rondas hasta cuartos.
- Enfrentamientos interdivisionales: el equipo de división inferior juega en casa si su estadio es apto.
- Si los dos equipos son de la misma división, la localía se determina por sorteo.
- Semifinales a ida y vuelta.
- Final a partido único en sede neutral.
- En empates de eliminatorias a partido único y en la final: prórroga y, si persiste, penaltis.
- Las rondas preliminares y byes se ajustan automáticamente al total de participantes. El bracket completo aún no está conectado al servicio de temporada.

## Supercopa de Cuba
Modelo Final Four:
- Cuatro participantes: campeón y subcampeón de Primera División, campeón y subcampeón de Copa.
- Si un club ocupa dos plazas, se incorpora el siguiente mejor clasificado de Primera que todavía no esté clasificado.
- Dos semifinales a partido único y final a partido único, todo en sede neutral.
- Sin partido por el tercer puesto.
- Empate: penaltis directamente, sin prórroga.
- Emparejamientos por sorteo, evitando repetir una semifinal idéntica cuando sea posible.

## Reglas compartidas
- Partidos de 90 minutos.
- Cinco sustituciones en un máximo de tres ventanas, sin contar el descanso como ventana.
- Calendario y clasificación deben consumir el mismo contrato de partido que el modo jugable y el simulador de temporada.
- Los puntos disciplinarios deben proceder de tarjetas/eventos reales del partido; si no hay datos, no deben inventarse.

## Implementación añadida
- `data/cuban_competition_rules.json`: fuente central de reglas de las tres divisiones, Copa y Supercopa.
- `data/cuba_leagues.json`: Primera División ajustada a 16 representantes regionales; Segunda conserva 16 y Tercera se amplía a 20.
- `scripts/simulation/league_standings.gd`: registra enfrentamientos directos y calcula los desempates españoles correspondientes a ligas a una o dos vueltas, incluida la minitabla para empates entre tres o más equipos.
- `scripts/simulation/competition_format_rules.gd`: clasifica los cuatro participantes de Supercopa y construye reglas base de emparejamientos de Copa/Supercopa.
- `scripts/data/football_data_service.gd`: carga y expone reglas de competiciones.
- `tests/test_shared_foundation.gd`: expectativas actualizadas para 52 clubes, tres competiciones, cuatro fases y 570 partidos.

## Recuento de calendarios de liga
- Primera: 16 clubes × 15 rivales = 240 partidos.
- Segunda: 16 clubes × 15 rivales = 240 partidos.
- Tercera occidental: 10 clubes × 9 rivales / 2 = 45 partidos.
- Tercera oriental: 10 clubes × 9 rivales / 2 = 45 partidos.
- Total de fase regular: **570 partidos**. No incluye playoffs, Copa ni Supercopa.

## Fuentes de referencia
- RFEF, bases de competición de Primera División: 20 clubes, 38 jornadas y 3/1/0 puntos: https://rfef.es/sites/default/files/pdf/circulares/98_con_anexos_20250624.pdf
- RFEF, explicación de la reforma de Copa del Rey y Supercopa: https://rfef.es/es/noticias/la-rfef-aprueba-las-bases-de-competicion-de-la-nueva-copa-del-rey-supercopa-y-copa-rfef
- RFEF, bases de Copa del Rey 2025/26 y criterios de localía/categoría: https://rfef.es/es/noticias/la-rfef-optimiza-varios-de-sus-principales-torneos-con-la-reforma-de-sus-bases-de
- LaLiga, normativa publicada: https://iaas-public-front-pro.laliga.com/transparencia/normativa

## Pendiente antes de declarar terminado
1. Generar fixtures de playoff de ascenso, Final Four, Copa y Supercopa.
2. Conectar resultados, penaltis, agregados, localía y clasificación con `NovaMatchContract`.
3. Incorporar los puntos disciplinarios desde eventos arbitrales.
4. Probar los criterios de desempate con casos de dos y tres o más equipos.
5. Ejecutar el conjunto de pruebas en Godot 4.x; todavía no se ha ejecutado ni validado Android.


## Ajuste de divisiones — 15-11-2026
La estructura vigente es Primera 16, Segunda 16 y Tercera 20 (dos grupos de diez). Morón Deportivo y Trinidad Colonial se asignan al Grupo Occidental; Baracoa FC y Manzanillo Marítimo al Grupo Oriental. Sus 88 perfiles conservan sus IDs y se trasladan completos con sus clubes. El calendario de fase regular queda en 570 partidos: 240 + 240 + 45 + 45.
