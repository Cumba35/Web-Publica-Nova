# Fútbol Nova — generación y calibración de futbolistas

## Alcance de la generación inicial
La base cubana vigente contiene 52 clubes y 1.144 futbolistas ficticios: Primera División, 16 clubes × 22 = 352; Segunda División, 16 × 22 = 352; Tercera División, 20 × 22 = 440. Los cuatro clubes transferidos a Tercera conservan sus perfiles originales. La base de las diez ligas principales suma 725 clubes y 15.950 perfiles ficticios, 22 por club.

## Principios de realismo
- La nacionalidad del jugador es independiente del país del club.
- Nombre, apellidos y lugar de nacimiento se generan según el país de nacimiento; no se asigna un nombre cubano a un extranjero por defecto.
- La nacionalidad no determina por sí sola la calidad. La fuerza se calcula por país futbolístico, nivel real de la liga, división, rendimiento del club y edad/desarrollo.
- En divisiones inferiores y países con menor fuerza competitiva se eleva la probabilidad de jugadores nacionales. Las ligas de mayor nivel reciben una proporción mayor de extranjeros, ponderada por cercanía regional, vínculos migratorios y mercados de fichajes plausibles.
- No se copian jugadores reales, nombres de futbolistas profesionales, estadísticas individuales, caras, biografías ni ratings propietarios.
- Los equipos ficticios no heredan automáticamente la fuerza de un club real. Su nivel inicial se deriva de su división y de un rango calibrado para esa competición.

## Plantilla de 22
Distribución inicial: 2 POR, 5 DFC, 2 LI, 2 LD, 2 MCD, 3 MC, 1 MCO, 1 MI, 1 MD, 1 EI, 1 ED y 1 DC. Las posiciones secundarias no sustituyen la posición principal.

## Escala y calibración
Se utiliza una escala provisional de atributos 1–99. El campo `estimated_overall` es una estimación procedural y no una fórmula definitiva del juego. El catálogo separa atributos, potencial y variables dinámicas. Los rangos iniciales para clubes cubanos de nivel 2 y 3 son deliberadamente modestos y con dispersión individual; deberán calibrarse con pruebas de partidos y datos de competición.

La fórmula definitiva de valoración general debe ponderar atributos por posición, y no usar una media aritmética simple. El potencial es una estimación de desarrollo, no una promesa de alcanzar esa valoración.

## Modelo de fuerza real
Cada actualización de temporada debe guardar un snapshot de:
1. Clasificación FIFA masculina de selecciones (contexto de fuerza futbolística nacional; no es una medición directa de la liga).
2. Coeficientes continentales de clubes/asociaciones cuando existan (por ejemplo, UEFA).
3. Ranking mundial de clubes de fuentes comparables (por ejemplo, IFFHS y modelos Elo independientes), con fecha, metodología y cobertura.
4. Nivel de la división y reglas de ascenso/descenso de la temporada.
5. Rendimiento del club en su competición y copas, sin confundirlo con la reputación histórica.
6. Mercado laboral: proporción de extranjeros observada en la liga, regiones de captación y restricciones de inscripción.

No se mezclan puntuaciones incompatibles como si fueran una única escala. Se normalizan por separado y se combinan mediante pesos versionados. Toda fuente externa debe conservar URL, fecha de consulta, ámbito, metodología y licencia. Si un ranking no cubre un país o división, el dato queda como no disponible; no se inventa un puesto.

## Nacionalidad y mercado
La probabilidad de nacionalidad doméstica se calcula con una función monotónica: aumenta al bajar la fuerza del país y de la división; disminuye al subirlas. Se ajusta por tamaño del mercado, reglas de inscripción, región y disponibilidad de jugadores. El algoritmo debe garantizar diversidad plausible, no cuotas rígidas idénticas para todos los clubes. Los jugadores extranjeros deben tener una razón de mercado plausible y no aparecer en cantidades incompatibles con la economía del club.

## Identidad y diversidad
- IDs permanentes; el cambio de club no cambia la identidad del jugador.
- Fecha de nacimiento, altura, peso, pie dominante, posición, roles, atributos, potencial y nacionalidad son campos separados.
- La base de nombres se organiza por país y región, con reglas de apellidos dobles, transliteración y caracteres locales.
- Evitar duplicados exactos y colisiones excesivas de nombres dentro de una plantilla y competición.
- Los datos de nacimiento deben ser plausibles para edad, país y época.
- La generación usa semilla reproducible y registra versión del algoritmo.

## Estado y límites
Los 32 equipos cubanos del catálogo ya están definidos; esta generación no completa aún las plantillas de España, Francia, Italia, Alemania, Portugal, Inglaterra, Brasil, Estados Unidos y Argentina porque sus catálogos de clubes ficticios todavía deben existir. El mismo generador se aplicará a cada país y a sus divisiones 1–3 cuando esos clubes estén definidos. No se marcará un equipo como completo antes de generar y validar su plantilla.

## Fuentes de calibración consultadas (13-11-2026)
- FIFA Men's World Ranking: https://inside.fifa.com/fifa-rankings/world-ranking/men — clasificación de selecciones; la última actualización publicada localizada fue 7-10-2026.
- UEFA rankings: https://www.uefa.com/nationalassociations/uefarankings/ — coeficientes de asociaciones y clubes europeos, basados en resultados continentales de cinco temporadas para el coeficiente deportivo.
- IFFHS Club World Ranking: https://isfhs.com/rankings/club-world-ranking-2026-the-top-500-2/ — ranking global de clubes con periodo de resultados 1-10-2025 a 30-09-2026.
- Opta Power Rankings methodology: https://theanalyst.com/articles/power-rankings-your-club-ranked — referencia metodológica para comparar fuerza de clubes a escala global.
- World Club Ratings methodology: https://worldclubratings.com/about/ — referencia complementaria; su propio sitio advierte que el ranking es experimental.

**Importante:** FIFA rank mide selecciones, UEFA mide rendimiento de clubes en competiciones UEFA e IFFHS/Elo tienen coberturas/metodologías distintas. Son señales separadas para calibración, no equivalencias directas.


## Generación inicial completada — Cuba (13-11-2026)

Se generaron y validaron **704 futbolistas ficticios para los 32 clubes actualmente catalogados**:
- Segunda División: 16 clubes × 22 jugadores = 352.
- Tercera División: 20 clubes × 22 jugadores = 440 (10 por grupo occidental y 10 por grupo oriental).
- Primera División: 16 clubes × 22 jugadores = 352.
- Total cubano vigente: 1.144 perfiles, 22 por club, con IDs únicos.
- Los 88 perfiles de los cuatro clubes trasladados a Tercera conservan sus IDs permanentes.
- Cada futbolista tiene 35 atributos numéricos, posición, posiciones secundarias, nacionalidad, lugar de nacimiento, fecha de nacimiento, altura, peso, pie preferido, valoración estimada y potencial.

Archivos:
- Segunda División: `data/players/cuba_second_division.json`.
- Tercera División: `data/cuba_players.json` (contiene los 20 clubes de nivel 3, ambos grupos).

### Orden de atributos del arreglo compacto

El campo `attributes` contiene valores en el siguiente orden, definido por `attribute_keys`:
`acc, spd, attp, fin, shot, long, vol, pen, vis, cross, fk, short, longp, curve, agi, bal, react, ctrl, drib, comp, int, head, aware, tack, slide, jump, sta, str, agr, dive, hand, kick, ref, gkspd, gkpos`

La clave `estimated_overall` es una estimación provisional del generador; no es una fórmula de valoración definitiva. Antes de integrarla en el motor de juego, debe reemplazarse o recalibrarse con ponderaciones posicionales probadas. Los atributos de portero se conservan en el mismo arreglo compacto, pero solo los seis atributos de portero son relevantes de forma principal para POR.


## Actualización 12-11-2026 — modelo global

La generación inicial cubana está completa: 32 clubes, 22 jugadores por club, 704 futbolistas ficticios. Segunda División tiene 10 extranjeros de 352 (2,84%); Tercera tiene 6 de 352 (1,70%). En total: 688 cubanos y 16 extranjeros. Los mercados presentes son Jamaica, Haití, República Dominicana, Panamá, Colombia y Venezuela. La proporción extranjera mayor en Segunda que en Tercera respeta la tendencia solicitada.

Se añade el modelo versionado de fuerza real en [REAL_WORLD_STRENGTH_CALIBRATION.md](REAL_WORLD_STRENGTH_CALIBRATION.md) y su snapshot de fuentes en [football_strength_sources.json](../data/football_strength_sources.json). La calidad de los jugadores debe depender del club, liga, división, edad, posición y desarrollo; la nacionalidad no aplica bonificaciones automáticas.

FIFA, Opta, IFFHS y UEFA miden ámbitos distintos. No se mezclan sus rankings como si fueran una escala única. Los clubes ficticios no reciben posiciones reales inventadas: sus niveles se estiman con la liga/división comparable y se marca la confianza. Los nombres siguen las convenciones del país y región de nacimiento; ciudadanía, selección representada y club actual se almacenan como datos independientes.

Los ratings existentes son provisionales y deben pasar por la calibración posicional y pruebas de partidos antes de considerarse definitivos. La generación de otros países se realizará cuando sus catálogos de clubes estén definidos.


## Regla obligatoria desde 13-11-2026 — nivel individual según el club

**La nacionalidad jamás será un techo ni un descuento de calidad.** Un futbolista cubano, haitiano, jamaiquino o de cualquier otro país que sea titular habitual de un club de élite tendrá una valoración coherente con el nivel competitivo de ese club y con su rendimiento individual. No se le asignará una valoración baja por proceder de un país con selección de menor ranking.

### Orden de cálculo
1. Medir la fuerza real del club (rating global, resultados, competición, profundidad de plantilla y temporada).
2. Determinar la calidad que exige el puesto en ese club y el rol del futbolista (titular indiscutible, titular rotacional, suplente, promesa).
3. Generar atributos específicos de su posición y estilo, usando rendimiento, minutos, edad, potencial, forma y trayectoria simulada.
4. Ajustar la valoración al nivel competitivo observado, manteniendo dispersión: un titular de un club estrella debe ser un jugador de nivel alto, pero no todos los titulares serán estrellas mundiales.
5. Validar que la media y distribución de los titulares y suplentes sean coherentes con la fuerza del club y que el jugador no resulte artificialmente inferior por su nacionalidad.

### Qué determina cada dato
- **País y nacionalidad:** influyen en el mercado de captación, disponibilidad, reglas de inscripción, nombre, lugar de nacimiento y selección que representa. No restan puntos de habilidad.
- **Club y competición:** determinan el entorno competitivo y el rango de nivel esperado.
- **Rol y rendimiento:** determinan la posición relativa del jugador dentro de su plantilla.
- **Edad, potencial y desarrollo:** determinan progresión y evolución a lo largo de la carrera.

### Bandas orientativas de valoración (escala de juego 1–99)
Son bandas de diseño para calibrar plantillas ficticias, no ratings oficiales ni equivalencias exactas de bases de datos comerciales. La fuerza concreta del club y la posición prevalecen sobre el país del jugador.

| Entorno competitivo del club | Titulares habituales | Rotación / suplentes | Promesas |
|---|---:|---:|---:|
| Élite mundial | 82–92 | 76–86 | 65–82 |
| Muy fuerte / continental | 76–87 | 70–81 | 60–78 |
| Primera división competitiva | 68–81 | 62–75 | 52–73 |
| Primera división de nivel medio | 58–73 | 52–67 | 45–65 |
| División inferior profesional | 45–63 | 40–57 | 35–58 |
| Semiprofesional / amateur | 30–52 | 25–46 | 20–48 |

Las bandas se solapan intencionalmente: un joven con potencial, un veterano o un jugador excepcional pueden quedar fuera del centro de su grupo. No aplicar mínimos o máximos automáticos por nacionalidad.

### Control de coherencia
- Si un jugador cubano es titular de un club de élite, su valoración se calcula como la de cualquier titular de ese club; puede estar en la banda de 82–92 si su rendimiento lo respalda.
- Si un jugador de una potencia futbolística juega en un equipo modesto de una división inferior, no recibe una valoración alta solo por su pasaporte.
- La nacionalidad doméstica y la extranjera se distribuyen según la fuerza del país/liga/división, el mercado, las reglas de inscripción y la economía del club; esta distribución no se usa para decidir la calidad.
- El overall debe calcularse con ponderaciones posicionales y atributos relacionados con el rendimiento. La posición de titular por sí sola tampoco garantiza una puntuación máxima.
- Si los datos de un club son estimados o de baja confianza, conservar esa incertidumbre en la generación y no presentar el rating como oficial.

Esta regla es obligatoria para toda plantilla nueva, regeneración de plantilla, fichaje generado y actualización de temporada. Los ratings provisionales de los 704 jugadores cubanos existentes no se declaran recalibrados por este cambio; deberán recalcularse cuando se ejecute una pasada de ratings con datos comparables de los clubes.


## Regeneración de plantillas y sistema de habilidades — 13-11-2026

Se regeneran los perfiles de los **704 futbolistas actualmente existentes** de Cuba, conservando sus IDs permanentes, nombres, nacionalidad, datos biográficos, club y posición para no romper referencias entre plantillas. Se recalibran los atributos, la valoración estimada y el potencial mediante una semilla reproducible por ID. Las bandas de generación continúan siendo prudentes para las divisiones cubanas ficticias; no se presentan como ratings oficiales. La nacionalidad no participa en la puntuación.

Cada futbolista del modo de juego estándar incorpora el objeto `skill_profile`: espacios activos habilitados según el overall, lista de habilidades activas, inventario almacenado vacío y `secondary_skills_enabled=false`. Los jugadores estándar no guardan habilidades secundarias. La asignación de habilidades activas se determina por su overall; no se concede una habilidad por nacionalidad.

El catálogo de habilidades está en [skill_catalog.json](../data/skills/skill_catalog.json). Contiene tres habilidades para cada uno de los tres niveles. Las reglas son:

| Overall | Modo Leyenda: espacios equipables | Plantilla estándar: habilidades activas |
|---:|---:|---:|
| Menos de 70 | 0 | 0 |
| 70–79 | 1 | 1 |
| 80–90 | 2 | 2 |
| 91–99 | 3 | 3 |

En Leyenda se pueden almacenar hasta nueve habilidades: tres por nivel. Solo se puede equipar una habilidad de cada nivel y nunca más de tres en total. Al subir de nivel general, se asigna aleatoriamente una habilidad del nivel que corresponda al nuevo overall (nivel 1 desde 70, nivel 2 desde 80 y nivel 3 desde 91). No se repiten habilidades ya almacenadas y cada nivel tiene un máximo de tres.

**Importante sobre el alcance:** en esta fecha el catálogo del proyecto contiene 32 clubes cubanos y 704 futbolistas. Esta regeneración cubre esos 704 jugadores; no existen aún plantillas de otras ligas en el repositorio, por lo que no se han inventado ni contado como regeneradas. Los futuros catálogos usarán el mismo generador y reglas.



## Clasificación de habilidades por estrellas — 13-11-2026

Las habilidades tendrán una calidad de 1 a 5 estrellas, independiente del nivel de habilidad (1–3) y del overall del jugador. Las estrellas miden potencia/calidad y no modifican la regla de espacios. El catálogo define el valor de cada habilidad; los valores iniciales son provisionales y requieren balance de juego.


## Habilidades por posición y nivel — 13-11-2026

Catálogo ampliado a 300 habilidades originales: 10 de portero, 30 de defensor, 30 de mediocampista y 30 de delantero por nivel. Los rangos son obligatorios: nivel 1 = 1–2 estrellas; nivel 2 = 3–4; nivel 3 = 5. Se mantienen los IDs de las nueve habilidades iniciales. Modo Leyenda ofrece tres opciones compatibles al desbloquear cada nivel; una activa por nivel y máximo tres almacenadas por nivel. Plantillas estándar reciben una habilidad compatible por espacio y no guardan habilidades secundarias. Ningún efecto garantiza el resultado; se conservan atributos, contexto y contrajuego. Se requiere prueba en Godot para confirmar ejecución.


## Mecánicas individuales del catálogo — 13-11-2026

El esquema 2.1.0 amplía las 300 entradas con datos estructurados consumibles por el juego:

- `mechanics.action_family`: familia de acción concreta y `mechanics.action_id`: identificador estable del concepto.
- `mechanics.activation`: condición contextual, balón en juego, animación válida y contacto legal.
- `mechanics.attributes`: atributo principal, dos secundarios y ponderaciones 50/30/20.
- `mechanics.effect_model`: modificador inicial, duración, alcance, coste de resistencia, límites de éxito y regla especial cuando corresponda.
- `mechanics.counterplay`: atributos de oposición, interrupción y respeto a fuera de juego/faltas.
- `mechanics.failure_outcome` y `mechanics.restrictions`: resolución cuando no se cumple la acción y límites explícitos.

Las nueve habilidades originales conservan sus IDs. Se mantienen además las excepciones aprobadas: Disparo seguro dirige el tiro a portería sin garantizar gol; Barrida segura solo garantiza una entrada limpia si existe una ventana legal; Volea potente conserva 60% de probabilidad de gol; Chilena de estrella garantiza gol únicamente después de un contacto válido y dentro de su ventana contextual. Los valores de duración, alcance, coste y modificadores son valores iniciales de diseño, no cifras balanceadas.

**Estado real:** las definiciones de datos están completas para las 300 entradas; falta conectar el nuevo esquema con las acciones reales del partido, verificar las animaciones y ejecutar pruebas de balance en Godot. No se declara integración runtime terminada.


## Ampliación de plantillas de Primera División (14-11-2026)
Los perfiles se distribuyen en 352 jugadores de Primera, 352 de Segunda y 440 de Tercera. Los 88 futbolistas de Morón Deportivo, Trinidad Colonial, Baracoa FC y Manzanillo Marítimo conservan sus IDs permanentes y acompañan a sus clubes en el traslado a Tercera. El total permanece en 1.144 jugadores. Todos los perfiles de Primera tienen nacionalidad cubana. Esta generación es ficticia, determinista y provisional; no copia jugadores reales ni afirma que los ratings sean oficiales. El personaje personalizado del usuario se crea por separado, después de completar las plantillas.


## Regla obligatoria de valor de mercado — Transfermarkt como referencia (14-11-2026)

Todos los futbolistas de Fútbol Nova deben tener su valor de mercado estimado usando Transfermarkt como referencia principal, tanto los perfiles personalizados como los jugadores ficticios de plantillas y los futuros fichajes. Aplicar [PLAYER_MARKET_VALUE_METHODOLOGY.md](PLAYER_MARKET_VALUE_METHODOLOGY.md).

La cifra del juego será una estimación propia, nunca una cotización oficial de Transfermarkt ni un precio de traspaso. Comparar jugadores de edad, posición, nivel de liga, rendimiento y contexto semejantes; registrar comparables, importes, fechas, URL, confianza y justificación. No copiar valores de manera automática ni convertir GRL/POT a euros.

No inventar minutos, goles, asistencias, contratos, salarios, lesiones, clubes contractuales ni ofertas. Cuando falten datos, marcar la estimación como provisional y reducir su confianza. El club favorito no equivale al club contractual. La nacionalidad no será una penalización de valor o calidad.

La regla se aplica en cada generación, fichaje, actualización de temporada y recalibración. Los valores históricos no se sobrescriben sin guardar la fecha y versión de metodología. Los lotes existentes deben auditarse y recibir valoraciones cuando sus datos de club, liga, edad, posición y rendimiento permitan comparaciones defendibles; no declarar una revaloración masiva completada sin procesar y validar cada registro.


## Coherencia global de perfiles y estadísticas — 15-11-2026

La temporada base se unifica en 2026/27 (2026 para las competiciones de año natural). Las diez ligas principales contienen 725 clubes y 15.950 perfiles ficticios de 22 jugadores por club. Se mantienen IDs, nacionalidades, clubes, posiciones, fechas de nacimiento, altura, peso, pie dominante, atributos y potencial existentes; el sistema no cambia esos valores solo para forzar una media común.

El catálogo incorpora un bloque estadístico uniforme por jugador a través de `NovaPlayerStatisticsService`. Se separan estadísticas de carrera y temporada. Las estadísticas aditivas comienzan en cero cuando no hay actas, y los porcentajes/promedios se calculan solo con denominadores válidos. Los GRL estimados, atributos y potencial no se usan para inventar partidos, goles, asistencias o valoraciones de rendimiento.

El GRL de los perfiles generados sigue siendo una estimación procedural. La fórmula ponderada del Modo Leyenda se utiliza para las valoraciones calculadas de ese modo; no se reescriben automáticamente los GRL guardados de todas las ligas sin una calibración completa y pruebas de balance.

### Perfil especial de Anier Cumbá

Se preservan sus datos confirmados: ID `NOVA-PLAYER-0035`, Anier Cumbá, Albor Madrid (club ficticio representante del Real Madrid), dorsal 35, MCO/MC, GRL 92 y POT 97. Los atributos base y los atributos efectivos con bonificaciones se mantienen como campos distintos. Sus estadísticas de partido permanecen vacías hasta registrar encuentros verificables.


## Distribución cubana vigente — 15-11-2026
Primera: 16 × 22 = 352. Segunda: 16 × 22 = 352. Tercera: 20 × 22 = 440, en dos grupos regionales de diez. Los cuatro clubes trasladados a Tercera conservan los 88 IDs de jugador. Ningún GRL, POT, posición ni atributo se recalcula solo por el cambio de división; los datos económicos se marcan por el nuevo nivel de división.
