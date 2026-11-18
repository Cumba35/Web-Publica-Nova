# Anier Alejandro Cumbá Ibar — ficha maestra de implementación

**ID:** `NOVA-PLAYER-0035`  
**Proyecto:** Fútbol Nova  
**Ruta:** `proyectos/juegos/futbol-nova/`  
**Fuente canónica de datos estructurados:** `data/custom_players.json`  
**Revisión:** 14-11-2026

## Identidad y datos confirmados por el propietario

| Campo | Valor |
|---|---|
| Nombre completo | Anier Alejandro Cumbá Ibar |
| Nombre para mostrar | Anier Cumbá |
| Nombre en uniforme | CUMBÁ |
| Número favorito | 35 |
| Rol en el equipo | Capitán |
| Fecha de nacimiento | 14/04/2001 (`2001-04-14`) |
| Edad de referencia | 25 años al 14/11/2026; calcular dinámicamente |
| País de nacimiento / nacionalidad registrada | Cuba (`CUB`) |
| Selección preferida | Brasil (`BRA`), sujeta a elegibilidad |
| Altura | 171 cm |
| Peso | 65 kg |
| Posición principal / secundaria | MCO / MC |
| Pie dominante | Derecho |
| Especialización | Velocista |
| Club favorito | Real Madrid |
| Media general (GRL) | **92** |
| Potencial (POT) | **97** |

La selección preferida no cambia la nacionalidad ni concede elegibilidad automática. El club favorito no confirma contrato ni historial contractual.

## Media general y potencial

El propietario confirmó GRL **92** y POT **97**. Como referencias de diseño consultadas en EA SPORTS FC 27 se usaron 91 GRL como máximo masculino y 95 POT como máximo de potencial; Anier queda respectivamente +1 y +2. Son comparaciones de diseño, no valoraciones oficiales de EA SPORTS.

La media general y el potencial son independientes. Los atributos se confirman individualmente y no se deducen del GRL.

## Valor de mercado — estimación Transfermarkt de Fútbol Nova

**Valor provisional:** **120.000.000 €**  
**Fecha de valoración:** 14-11-2026  
**Metodología:** `nova-transfermarkt-reference-v1.0.0`  
**Confianza:** media-baja.

La cifra es una estimación propia de Fútbol Nova, no un valor oficial de Transfermarkt. Se utilizaron como comparables de mediocampistas ofensivos los valores publicados en la actualización del 17-10-2026: Jude Bellingham (160 M€), Morgan Rogers (120 M€), Cole Palmer (110 M€), Rayan Cherki (110 M€) y Arda Güler (100 M€). La estimación de Anier se coloca en 120 M€, considerando su edad de 25 años, GRL 92 y POT 97 dentro del juego. El GRL y el POT no se convierten directamente a dinero.

La confianza es media-baja porque aún faltan estadísticas verificadas, club contractual, duración y condiciones del contrato, historial de lesiones y señales documentadas de demanda. **Real Madrid sigue siendo el club favorito registrado; no se afirma que sea su club contractual.**

La cifra, los comparables, las fuentes y las limitaciones están guardados en `data/custom_players.json`. La metodología general y obligatoria para todos los jugadores está en [PLAYER_MARKET_VALUE_METHODOLOGY.md](PLAYER_MARKET_VALUE_METHODOLOGY.md).

## Atributos individuales confirmados

| Atributo | Valor base confirmado | Referencia real consultada |
|---|---:|---|
| Aceleración | **90 base → 98 efectiva** | Kylian Mbappé: 97 (EA SPORTS FC 27, referencia de diseño) |
| Velocidad punta | **90 base → 98 efectiva** | Kylian Mbappé: 97 (EA SPORTS FC 27, referencia de diseño) |
| Definición | **87** | Erling Haaland: 94 (EA SPORTS FC 27, referencia de diseño) |
| Potencia de tiro | **90** | Federico Valverde: 95 (EA SPORTS FC 27, referencia de diseño) |

El propietario confirma que todos los atributos que ya estaban asignados en esta ficha son los definitivos. Los valores de `base_attributes` quedan confirmados como atributos base; `attributes` conserva los valores efectivos tras aplicar Velocista. La lista `confirmed_attributes` refleja todos los atributos base confirmados. No quedan atributos futbolísticos pendientes de asignación. Los valores base son independientes de las bonificaciones de especialización.

## Regla de valoración con bonificaciones — confirmación del propietario

El propietario solicita que las medias generales ya reflejen las bonificaciones aplicables. Por tanto, el GRL que se muestre debe ser el valor final con las bonificaciones integradas y estas no deben sumarse otra vez al GRL mostrado. La implementación exacta del cálculo debe respetar esta regla y evitar doble aplicación. No recalcular ni modificar el GRL 92 confirmado sin autorización expresa.

## Bonificaciones de especialización

La especialización Velocista tiene estas bonificaciones de sistema:
- Aceleración: +8.
- Velocidad punta: +8.
- Agilidad: +4.

Son bonificaciones, no atributos base confirmados. No duplicarlas en el cálculo de la media general.

## Perfil técnico generado — referencias Kroos y Valverde

El propietario autorizó generar el perfil completo tomando como inspiración el mejor nivel de Toni Kroos y el perfil de Federico Valverde en el Real Madrid. No se copian sus fichas: se combinan la distribución, visión, pase corto/largo, control y serenidad asociadas a Kroos con el ritmo, resistencia, capacidad física, recuperación y llegada de Valverde.

Referencias contrastadas:
- Toni Kroos: en LaLiga 2015-16 completó 2.277 de 2.425 pases (93,9 %); en 2016-17, 1.910 de 2.071 (92,2 %). Su carta Icon de FC 27 muestra visión 93, pase corto 93, pase largo 93, control 92 y serenidad 88.
- Federico Valverde: EA SPORTS FC 27 muestra ritmo 90, aceleración 87, velocidad 93, potencia de tiro 95, resistencia 94, físico 85 y defensa 81.

Fuentes: https://www.statmuse.com/fc/ask/toni-kroos-pass-completion-every-season ; https://www.fut.gg/players/182521-toni-kroos/27-67291385/ ; https://www.ea.com/es/games/ea-sports-fc/ratings/player-ratings/federico-valverde/239053

### Atributos base y atributos efectivos

La tabla siguiente separa la base de Anier de los valores efectivos tras Velocista. Los atributos de portero no son relevantes para su posición.

| Grupo | Atributo | Base | Efectivo |
|---|---|---:|---:|
| Ritmo | Aceleración | 90 | 98 |
| Ritmo | Velocidad punta | 90 | 98 |
| Tiro | Posicionamiento ofensivo | 90 | 90 |
| Tiro | Definición | 87 | 87 |
| Tiro | Potencia de tiro | 90 | 90 |
| Tiro | Tiros lejanos | 91 | 91 |
| Tiro | Voleas | 82 | 82 |
| Tiro | Penaltis | 78 | 78 |
| Pase | Visión | 96 | 96 |
| Pase | Centros | 82 | 82 |
| Pase | Precisión de faltas | 85 | 85 |
| Pase | Pase corto | 96 | 96 |
| Pase | Pase largo | 95 | 95 |
| Pase | Efecto | 90 | 90 |
| Regate | Agilidad | 88 | 92 |
| Regate | Equilibrio | 88 | 88 |
| Regate | Reacciones | 94 | 94 |
| Regate | Control de balón | 96 | 96 |
| Regate | Regate | 91 | 91 |
| Regate | Compostura | 94 | 94 |
| Defensa | Intercepciones | 86 | 86 |
| Defensa | Cabeceo | 72 | 72 |
| Defensa | Conciencia defensiva | 84 | 84 |
| Defensa | Entrada normal | 82 | 82 |
| Defensa | Entrada deslizante | 78 | 78 |
| Físico | Salto | 76 | 76 |
| Físico | Resistencia | 96 | 96 |
| Físico | Fuerza | 80 | 80 |
| Físico | Agresividad | 82 | 82 |

Los seis atributos de portero se guardan en 25 como valores residuales no competitivos; no intervienen en la media de MCO/MC.

### Cálculo de GRL sin doble aplicación

Se incorpora el cálculo posicional versionado `nova-position-weighted-v1`. Para MCO se ponderan especialmente visión, pase corto/largo, control, compostura y regate; para MC se eleva el peso relativo de defensa, intercepciones y resistencia. El cálculo utiliza los atributos efectivos, con bonificaciones ya integradas. No vuelve a sumar Velocista.

Recalculado con aceleración y velocidad punta en 90 base → 98 efectiva: la ponderación MCO da 91,60, que redondea a **92 GRL**. La media secundaria MC da 91,01, que redondea a **91 GRL**. El GRL principal permanece en 92 y POT 97 se conserva.

## Apariencia y referencia artística

- Representación exclusiva en 3D.
- Cabello muy corto; bigote y perilla.
- Equipación provisional: camiseta clara con detalles oscuros, CUMBÁ y dorsal 35; pantalón claro. La camiseta de la equipación se lleva por fuera del short, sin meterla dentro.
- Botas: base roja con diseños dorados y negros (preferencia confirmada por el propietario); el blockout procedural representa la base roja, suela negra y detalles dorados/negros.
- Medias: largas, por encima de las rodillas, y siempre corresponden a los colores y al diseño de la equipación que lleve puesta; no tienen diseño independiente (preferencia confirmada por el propietario).
- Espinilleras: obligatorias para todos los jugadores (regla confirmada por el propietario); Anier las lleva integradas bajo las medias.
- Muñequeras: Anier no lleva muñequeras (preferencia confirmada por el propietario).
- Cinta para el pelo: Anier no lleva cinta para el pelo (preferencia confirmada por el propietario).
- Brazalete de capitán: sí lo lleva y siempre utiliza el modelo/diseño correspondiente al equipo cuya equipación esté usando. Es la excepción a la preferencia general de no usar cintas (no lleva cinta para el pelo ni muñequeras).
- Aretes: Anier no lleva aretes (preferencia confirmada por el propietario).
- Guantes: negros con detalles rojos y dorados (preferencia confirmada por el propietario).
- Camiseta interior: Anier siempre la lleva, independientemente de la equipación y de si la camiseta exterior es de manga corta o larga. Es ajustada al cuerpo, de compresión y manga larga, con estilo similar a las que aparecen en EA SPORTS FIFA 23. Las mangas y el cuello visible alrededor del cuello se adaptan visualmente a la equipación del equipo que esté usando (preferencia confirmada por el propietario).
- Referencia facial: `Dropbox:/Nova/Workspace/Recursos gráficos/Anier Cumbá.png`; pendiente de esculpido 3D de alta fidelidad.
- El blockout actual no es el modelo final ni autoriza a inventar rasgos.

## Archivos y estado

- `data/custom_players.json`: fuente estructurada canónica.
- `scenes/players/anier_cumba.tscn`: escena 3D.
- `scripts/players/anier_cumba.gd`: controlador personalizado.
- `modules/nova_3d_animation/nova_3d_animation.gd`: estados de animación.
- `tests/test_anier_cumba_profile.gd`: prueba de perfil e integración.

La escena y el controlador están incorporados en código, pero la validación real en Godot sigue pendiente. El modelo humanoide final, esqueleto deformable y clips deportivos también están pendientes.

## Datos aún no proporcionados

Los atributos futbolísticos ya asignados quedan confirmados por el propietario; no se deben volver a solicitar ni modificar sin autorización. Siguen pendientes el salario, club contractual e historial, contrato/duración y estadísticas de carrera. El valor de mercado ya tiene una estimación provisional de 120.000.000 €.

## Controles de integridad

- Reflejar correcciones confirmadas en JSON, documentación y pruebas.
- No confundir atributos base y bonificaciones.
- No afirmar que las pruebas pasaron sin ejecutarlas realmente en Godot.
- Calcular edad dinámicamente.
- No convertir selección preferida en nacionalidad/elegibilidad automática.

## Próxima tarea

Completar atributos y datos de carrera mediante confirmación individual del propietario; después validar el perfil y la integración en Godot.


## Estadísticas completas del jugador — actualización 15-11-2026

El perfil de Anier incorpora el esquema global de estadísticas de Fútbol Nova (`data/player_statistics_schema.json`). Se registran participación, titularidades, suplencias, minutos, resultados, goles, asistencias, tiros, pases y precisión, pases clave, ocasiones creadas, regates y porcentaje de éxito, entradas, intercepciones, recuperaciones, faltas, tarjetas, penaltis, paradas, porterías imbatidas, premios y valoración media. Los registros se separan por temporada y carrera y pueden agregarse por competición, club y selección.

**Estado inicial de Anier:** no hay actas de partidos verificadas en su ficha, por lo que los contadores empiezan en cero y las medias/porcentajes quedan sin valor (`null`) hasta que exista una muestra. Esto no significa que Anier haya disputado cero partidos en su vida real; significa que Fútbol Nova todavía no tiene partidos registrados para él. No se deducen goles, asistencias ni rendimiento real a partir de GRL, POT o atributos.

Su perfil de juego queda descrito como MCO creador/llegador (GRL 92), con MC secundario (GRL 91), POT 97 y especialización Velocista. Estos indicadores describen su configuración dentro del juego y no sustituyen estadísticas de partidos.


## Historial de Anier en la Liga de Campeones del Caribe — corrección 16-11-2026

Según la historia de carrera confirmada para Fútbol Nova, Anier Cumbá conquistó dos ediciones consecutivas con Santiago de Cuba:

- **2023-2024:** campeón; final registrada el 10-06-2024.
- **2024-2025:** campeón por segunda vez consecutiva; final registrada el 10-06-2025.
- **23-06-2025:** fichaje por el Real Madrid, trece días después del segundo título.

El club actual del perfil queda como **Real Madrid** (`FN-ESP-REAL-MADRID`). Estos logros se registran como historial narrativo confirmado por el propietario. No se añaden apariciones, goles, asistencias ni minutos sin actas de partidos. La ficha estructurada canónica conserva estos datos en `data/custom_players.json`.

La Liga de Campeones del Caribe fue fundada el **10-10-2020**. La temporada actual 2026-2027 es su séptima edición: al comenzar el 10-10-2026 cumple seis años y alcanzará siete años de funcionamiento el 10-10-2027. Los campeones de las tres primeras ediciones y de 2025-2026 permanecen pendientes de documentación.


## Participaciones en la Liga de Campeones del Caribe — precisión 16-11-2026

Anier disputó cuatro ediciones consecutivas: **2021-2022, 2022-2023, 2023-2024 y 2024-2025**. La primera participación registrada de esta secuencia corresponde a 2021-2022. Su último partido en la competición fue la final del **10-06-2025**, cuando ganó su segundo título consecutivo con **Santiago de Cuba**. No participó en partidos por el tercer puesto. Los títulos confirmados siguen siendo únicamente los de 2023-2024 y 2024-2025; no se atribuyen campeonatos a las dos primeras ediciones de esta secuencia.


### Puestos finales de las primeras participaciones

- **2021-2022:** 11.º puesto.
- **2022-2023:** 6.º puesto.

Después obtuvo dos títulos consecutivos con Santiago de Cuba en 2023-2024 y 2024-2025. Estos puestos se registran como resultado final de sus participaciones; no se asigna un club a las dos primeras temporadas porque no se ha especificado en esta actualización.


## Actualización de apariencia — 16-11-2026

- Guantes: se confirma que Anier utiliza el mismo modelo que Raymond, manteniendo su propia paleta negra con detalles rojos y dorados.
- Medias: por encima de las rodillas, adaptadas a la equipación.
- Camiseta interior: mangas largas, ajustada y adaptada a la equipación; siempre puesta.
- No se modifica ninguna otra característica de Anier.
- El registro compartido de ambos jugadores está en [PLAYER_APPEARANCE_UPDATE_2026-11-16.md](PLAYER_APPEARANCE_UPDATE_2026-11-16.md). La ficha canónica independiente de Raymond no se encontró en el repositorio durante esta revisión, por lo que no se inventó ni se creó una ficha incompleta.
