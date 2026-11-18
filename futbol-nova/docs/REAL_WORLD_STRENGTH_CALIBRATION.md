# Fútbol Nova — calibración con el fútbol real

**Versión del modelo:** 1.0.0  
**Fecha de corte documental:** 12-11-2026  
**Ámbito:** selecciones, países, ligas, divisiones, clubes y futbolistas generados.

## 1. Regla principal
Los niveles de países, ligas, clubes y futbolistas deben reflejar la fuerza competitiva del fútbol real en la temporada de referencia. Los equipos y jugadores generados son ficticios: no se les atribuye una clasificación real ni se copian valoraciones individuales de profesionales.

La nacionalidad no es una puntuación de calidad. Un jugador cubano no será automáticamente peor que uno brasileño; la distribución de atributos se deriva del nivel competitivo del club y de la trayectoria individual simulada. El país influye como contexto estadístico, no como penalización personal.

## 2. Fuentes y qué mide cada una
| Fuente | Uso | Limitación |
|---|---|---|
| FIFA Men's World Ranking | Fuerza internacional de selecciones nacionales | No mide directamente ligas ni clubes |
| Opta Power Rankings | Comparación global de clubes y fuerza media/profundidad de ligas | Su cobertura y fecha deben guardarse; no confundir la escala de clubes con FIFA |
| IFFHS Club World Ranking | Resultados internacionales/nacionales de clubes según su metodología | Cobertura limitada al conjunto publicado; no es una escala universal |
| Coeficientes UEFA | Rendimiento de clubes y asociaciones en competiciones UEFA | Solo aplicable a su ámbito; no extrapolar como ranking mundial |
| Resultados oficiales de cada liga | Nivel, rendimiento y forma reciente del club | Comparar solo temporadas y formatos compatibles |

### Snapshot documentado para Cuba
- FIFA muestra a Cuba en el puesto **164** en la ficha de selección masculina consultada, con última actualización oficial indicada de **20-07-2026**. Se actualizará cuando FIFA publique la siguiente clasificación; la ficha señalaba 18-11-2026 como próxima fecha.
- IFFHS publicó su ranking mundial de clubes de octubre de 2026 el 15-10-2026, con periodo de resultados 01-10-2025 a 30-09-2026.
- Opta describe una clasificación jerárquica Elo para más de 13.500 equipos masculinos, 190 países y más de 600 ligas, con ratings comparables en escala 0–100. Se usará la media de equipos para fuerza de liga y la valoración individual del club cuando el dato esté disponible.
- No existe una valoración pública real para los clubes ficticios de Segunda y Tercera División de Fútbol Nova. No se les inventará un puesto FIFA, Opta o IFFHS. Su fuerza se estimará a partir del nivel cubano verificable y se marcará como estimación de baja confianza.

## 3. Jerarquía de fuerza
Guardar por separado:
1. **CountryStrength:** contexto futbolístico del país (selección, clubes, confederación y profundidad competitiva).
2. **LeagueStrength:** fuerza media de los clubes de la liga; la profundidad importa, no solo el campeón.
3. **DivisionStrength:** fuerza de la categoría dentro del sistema nacional.
4. **ClubStrength:** rating real si existe; si no, estimación basada en liga, resultados y división.
5. **PlayerLevel:** calidad individual generada según el club, rol, edad, desarrollo y atributos.

No usar la clasificación FIFA de selecciones como sustituto de una clasificación de clubes. No convertir automáticamente un ranking ordinal en una puntuación lineal de calidad. Normalizar cada fuente por separado, conservar su cobertura y combinar solo señales compatibles.

## 4. Algoritmo de fuerza recomendado
Cuando haya datos comparables:
- Club: 55% rating global de club (Opta/Elo comparable), 20% rendimiento reciente en su liga/copas, 15% fuerza media de la liga y 10% rendimiento continental.
- Liga: 70% media de rating de todos sus clubes, 20% media de sus cinco mejores clubes y 10% resultados continentales agregados, si existen.
- País: 35% fuerza de liga doméstica, 30% fuerza de clubes internacionales, 25% fuerza de selección FIFA normalizada y 10% contexto de confederación/profundidad. Cada componente debe tener cobertura y confianza explícitas.

Estos pesos son parámetros iniciales del simulador, no datos oficiales ni una afirmación de que las fuentes compartan escala. Deben versionarse y ajustarse con pruebas de partidos. Si un componente falta, redistribuir los pesos disponibles proporcionalmente y reducir la confianza; nunca rellenar un dato ausente con un valor ficticio.

Para un club ficticio sin rating real, estimar su nivel desde la distribución de clubes de su liga/división real comparable. En países sin una categoría real equivalente —como las divisiones ficticias cubanas— aplicar una banda de estimación amplia y marcar estimated=true, confidence=low y el motivo.

## 5. Generación de plantillas y extranjeros
La proporción de futbolistas nacionales debe subir cuando baja la fuerza del país y cuando baja el nivel de la división. La proporción de extranjeros puede crecer en ligas fuertes, profesionalizadas y con mercados internacionales amplios.

La probabilidad se calcula con:
- fuerza de la liga y de la división;
- proporción real de extranjeros observada en esa competición, cuando esté disponible;
- cupos y reglas de inscripción vigentes;
- cercanía geográfica, idioma, vínculos migratorios e historial de transferencias;
- presupuesto y reputación del club;
- disponibilidad de jugadores de ese mercado.

No imponer la misma cuota a todos los equipos. Un club puede fichar más extranjeros si su perfil económico y su mercado lo justifican. Los equipos modestos de divisiones inferiores deben tender a plantillas locales.

Los extranjeros deben proceder de mercados plausibles, no de una selección aleatoria uniforme de todos los países. La generación debe permitir casos excepcionales sin romper la tendencia estadística.

## 6. Identidad del jugador: campos separados
Cada futbolista debe tener:
- birth_country_code: país de nacimiento.
- birth_place: ciudad/región de nacimiento.
- citizenship_codes: una o varias nacionalidades legales simuladas, si el juego las modela.
- national_team_code: selección que representa o puede representar; puede ser nula si no está definida.
- club_country_code: país del club actual.
- club_id: equipo actual.
- name_profile_country_code: reglas culturales/lingüísticas usadas para generar nombre y apellidos.

El nombre y los apellidos se generan según el país y la región de nacimiento/familia, nunca copiando nombres de futbolistas reales. No deducir la nacionalidad deportiva a partir del nombre. Un jugador nacido en otro país puede representar a una selección por ascendencia o elegibilidad; esa relación debe ser un dato explícito del jugador.

Los nombres deben respetar convenciones locales: orden de apellidos, nombres compuestos, transliteración, diacríticos y patrones regionales. Se permite que dos jugadores compartan nombre común, pero sus IDs son permanentes y únicos.

## 7. Calidad individual
- El nivel del club determina el rango de calidad inicial más probable, no un rating idéntico para todos.
- La división inferior reduce el nivel medio esperado, manteniendo excepciones raras y talento joven.
- La edad y el potencial afectan desarrollo; no garantizan alcanzar el potencial.
- Los atributos se generan por posición y estilo, con correlaciones realistas. El overall se calcula con ponderaciones específicas por posición, no con una media aritmética simple.
- El país de nacimiento/nacionalidad no aplica bonificaciones o penalizaciones individuales automáticas.
- Los ratings son estimaciones del juego, no estadísticas ni valoraciones de jugadores reales.

## 8. Estado de los datos cubanos existentes
El catálogo contiene 32 clubes ficticios con plantillas guardadas: 16 de Segunda División y 16 de Tercera División. Ya existen 22 jugadores por club: **704 futbolistas** en total.
- Segunda División: 16 plantillas × 22 = 352 jugadores; 10 extranjeros (2,84%).
- Tercera División: 16 plantillas × 22 = 352 jugadores; 6 extranjeros (1,70%).
- Total Segunda/Tercera: 688 cubanos (97,73%) y 16 extranjeros (2,27%).
- Primera División: 20 plantillas × 22 = 440 perfiles, todos con nacionalidad CUB; 352 fueron generados para los 16 clubes originales y 88 perfiles existentes se conservaron al reasignar cuatro clubes S1 a Primera.
- Total de las tres divisiones: 1.128 perfiles CUB y 16 extranjeros (98,60% / 1,40%).
- El porcentaje extranjero es mayor en Segunda que en Tercera, respetando la tendencia solicitada para una categoría de nivel superior.
- Las nacionalidades extranjeras existentes incluyen Jamaica, Haití, República Dominicana, Panamá, Colombia y Venezuela.
- Los ratings actuales son provisionales; deben recalibrarse con el modelo anterior antes de considerarlos definitivos.

## 9. Validaciones obligatorias
Antes de publicar una temporada:
1. IDs únicos en toda la base.
2. Plantilla y distribución posicional válidas.
3. Nacionalidad, nacimiento, nombre y selección sin contradicciones.
4. Jugadores extranjeros plausibles para el mercado y las reglas de la liga.
5. Tendencia estadística de mayor proporción local en divisiones inferiores.
6. Nivel medio de club/división coherente con las fuentes disponibles.
7. Ratings y snapshots con fecha, fuente, metodología y confianza.
8. Ausencia de futbolistas reales copiados o de atributos propietarios.
9. Generación reproducible con semilla y versión del algoritmo.

## 10. Fuentes
- FIFA Men's World Ranking: https://inside.fifa.com/fifa-rankings/world-ranking/men
- Ficha de Cuba en FIFA: https://inside.fifa.com/fifa-rankings/world-ranking/CUB?gender=men
- Opta Power Rankings — metodología: https://theanalyst.com/articles/power-rankings-your-club-ranked
- Opta — fuerza de ligas: https://theanalyst.com/articles/strongest-football-leagues-in-the-world-opta-power-rankings
- IFFHS Club World Ranking 2026 (publicación 15-10-2026): https://isfhs.com/rankings/club-world-ranking-2026-the-top-500-2/
- UEFA rankings: https://www.uefa.com/nationalassociations/uefarankings/

**Regla de actualización:** cada temporada debe guardar un snapshot fechado. No se actualizarán las valoraciones históricas silenciosamente; los cambios de fuente o metodología generan una nueva versión del modelo.


## Regla obligatoria de calidad individual: el club prevalece sobre la nacionalidad

La nacionalidad y el país de nacimiento nunca aplican un multiplicador negativo al overall ni limitan el techo de atributos. Su función está en la identidad del jugador, la elegibilidad de selección y el modelo de mercado/captación. La calidad individual se calibra según la fuerza competitiva del club, la división, el rol dentro de la plantilla, los minutos y el rendimiento, la posición, la edad y el desarrollo.

Por tanto, si un futbolista cubano es titular habitual de un club de élite mundial, su nivel debe corresponder al de un titular de ese club (banda de diseño orientativa 82–92 en escala 1–99, ajustada por posición y rendimiento), no al promedio de la selección cubana. De igual modo, un jugador de un país con selección muy fuerte que juega en un equipo modesto de una división inferior no recibe automáticamente una valoración alta.

Bandas iniciales de diseño para titulares habituales: élite mundial 82–92; muy fuerte/continental 76–87; primera división competitiva 68–81; primera división media 58–73; división inferior profesional 45–63; semiprofesional/amateur 30–52. Son intervalos orientativos del simulador, no ratings reales ni equivalencias directas de FIFA, Opta o IFFHS. La categoría del club y los datos observables determinan la banda; rol, atributos y rendimiento determinan la posición concreta dentro de ella.

La nacionalidad local/extranjera se genera por separado según fuerza de país/liga/división, reglas de inscripción, mercado, economía y vínculos regionales. Nunca se utiliza esa probabilidad como regla para bajar o subir la calidad individual.

Esta regla prevalece sobre cualquier interpretación anterior que pudiera relacionar directamente el ranking de la selección nacional con el rating del jugador. Se aplica a todas las futuras plantillas, fichajes generados y regeneraciones.
