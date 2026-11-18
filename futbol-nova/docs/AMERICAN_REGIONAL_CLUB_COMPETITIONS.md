# Competiciones regionales americanas de clubes

## Estructura oficial del catálogo

Fútbol Nova conserva únicamente estas cuatro competiciones internacionales de clubes:

1. Liga de Campeones del Caribe — `caribbean_champions_league_nova`.
2. Liga de Campeones de Sudamérica — `south_america_champions_league_nova`.
3. Liga de Campeones de Norteamérica y Centroamérica — `north_central_america_champions_league_nova`.
4. Torneo Americano de Supercampeones (TAS) — `american_super_champions_tas`, competición superior.

Las demás competiciones continentales e intercontinentales anteriores se retiraron del catálogo. El Caribe queda representado exclusivamente por su Liga de Campeones; la Copa del Caribe de Concacaf y el CFU Club Shield no clasifican al TAS.

## Separación en módulos independientes

Cada competición continental tiene un módulo separado, sin compartir estado competitivo con las otras:

| Módulo | Competición | Configuración / motor |
|---|---|---|
| `caribbean_champions_league` | Liga de Campeones del Caribe | `data/caribbean_champions_league.json` y motor caribeño |
| `south_america_champions_league` | Liga de Campeones de Sudamérica | `data/south_america_champions_league.json` y motor regional |
| `north_central_america_champions_league` | Liga de Campeones de Norteamérica y Centroamérica | `data/north_central_america_champions_league.json` y motor regional |
| `american_super_champions_tas` | Torneo Americano de Supercampeones | catálogo internacional y motor TAS |

Los manifiestos se encuentran bajo `modules/continental_competitions/<module_id>/module.json`; el registro está en `modules/continental_competitions/module_registry.json`. Cada módulo declara sus reglas, calendario, clasificación y motor. Los servicios de registro de clubes, base de datos, calendario y tablas son dependencias compartidas; no convierten las competiciones en un único módulo.

**Dependencias obligatorias del TAS:** al solicitar su descarga, el catálogo resuelve y encola primero `caribbean_champions_league`, `south_america_champions_league` y `north_central_america_champions_league`; el TAS queda al final de la cola. Antes de encolar, se comprueba que todas las fichas de paquete estén publicadas y que superen la validación HTTPS, tamaño y SHA-256. Si falta una dependencia, no se inicia ninguna descarga del conjunto. Durante la instalación, el gestor vuelve a comprobar que las tres ligas estén instaladas antes de permitir el TAS. La desinstalación de una liga requerida se bloquea mientras exista un módulo instalado que dependa de ella.

La resolución y la protección de dependencias ya están implementadas en la interfaz y en `ContentPackages`. Los cuatro paquetes continentales continúan en desarrollo, sin URL, tamaño ni SHA-256 publicados; por eso todavía no se ofrece una descarga real.

## Formato de las dos nuevas ligas

Cada una tendrá 40 clubes, cuatro grupos de diez y una vuelta:

- Diez clubes por grupo, con un representante de cada una de las diez asociaciones.
- Cuatro clubes por asociación, distribuidos con exactamente uno en cada grupo.
- Nueve partidos por club, 45 por grupo y 180 partidos de fase de grupos.
- Los tres primeros de cada grupo avanzan directamente a octavos.
- Los clubes en cuarto y quinto lugar disputan una repesca intergrupal a doble partido: A4-B5, B4-A5, C4-D5 y D4-C5.
- Los cuatro ganadores de la repesca completan los 16 participantes de octavos.
- Octavos, cuartos y semifinales a doble partido.
- Los perdedores de semifinales disputan un partido único por el tercer puesto.
- La final se disputa a partido único en sede neutral. El partido por el tercer puesto utiliza esa misma sede y se celebra antes de la final.
- En los partidos únicos, si persiste el empate tras el tiempo reglamentario, se juega prórroga y después penaltis.
- No se presume gol de visitante. Los criterios de desempate de grupos y eliminatorias deben aprobarse expresamente.

## Liga de Campeones de Sudamérica

Archivo: `data/south_america_champions_league.json`.

Asociaciones: Argentina, Bolivia, Brasil, Chile, Colombia, Ecuador, Paraguay, Perú, Uruguay y Venezuela. Cada una aporta cuatro clubes de Primera División. Total: 40 clubes.

## Liga de Campeones de Norteamérica y Centroamérica

Archivo: `data/north_central_america_champions_league.json`.

Asociaciones: Canadá, Estados Unidos, México, Belice, Costa Rica, El Salvador, Guatemala, Honduras, Nicaragua y Panamá. Cada una aporta cuatro clubes de Primera División. Total: 40 clubes.

## Calendarios 2026-2027

Ambas ligas reutilizan el calendario de la LCC para la misma temporada. Como tienen diez equipos por grupo, disputan nueve jornadas (cinco partidos por grupo y 20 partidos totales por jornada), usando las primeras nueve ventanas de la LCC:

| Jornada | Ventana |
|---|---|
| 1 | 10–13 octubre 2026 |
| 2 | 24–27 octubre 2026 |
| 3 | 7–8 noviembre 2026 (9–10 bloqueados por ventana FIFA) |
| 4 | 21–24 noviembre 2026 |
| 5 | 5–8 diciembre 2026 |
| 6 | 19–22 diciembre 2026 |
| 7 | 16–19 enero 2027 |
| 8 | 30 enero–2 febrero 2027 |
| 9 | 13–16 febrero 2027 |

Las eliminatorias conservan provisionalmente las mismas fechas que la LCC:

| Fase | Fechas |
|---|---|
| Repesca, ida / vuelta | 3 / 17 abril 2027 |
| Octavos, ida / vuelta | 23 / 30 abril 2027 |
| Cuartos, ida / vuelta | 7 / 14 mayo 2027 |
| Semifinales, ida / vuelta | 21 / 28 mayo 2027 |
| Partido por el tercer puesto | 17 junio 2027 |
| Reserva | 29 mayo–16 junio 2027 |
| Final única | 21 junio 2027 |

Inicio común de temporada para las tres ligas regionales: 10 de octubre de 2026. Final común: 21 de junio de 2027. El nuevo motor asigna fechas de planificación a cada fixture de grupos y excluye los días bloqueados indicados. No representan partidos ya disputados ni resultados.\n\n### Auditoría parcial del calendario internacional\n\nLa consulta del calendario masculino FIFA 2025–2030 detecta tres ventanas relevantes: 9–17 noviembre 2026, 22–30 marzo 2027 y 7–15 junio 2027. Por eso, la jornada 3 se concentra en 7–8 noviembre y no programa partidos el 9 ni el 10. La repesca se disputa el 3 y 17 de abril, fuera de la ventana FIFA de marzo. El tercer puesto (17 de junio) y la final (21 de junio) quedan después de la ventana FIFA del 7 al 15 de junio. Fuente: FIFA, [calendario internacional masculino 2025–2030](https://inside.fifa.com/en/organisation/fifa-council/media-releases/fifa-council-approves-international-match-calendars).\n\nLa comprobación de calendarios nacionales de las diez asociaciones de cada región sigue incompleta. No se declara ausencia de conflictos domésticos; el registro jugable todavía no contiene las diez asociaciones de cada torneo con calendarios oficiales 2026–2027 completos.

La final y el partido por el tercer puesto se celebran en la misma sede neutral. La sede de la final debe confirmarse antes del inicio de la competición.

## Torneo Americano de Supercampeones (TAS)

El TAS comenzará el 27 de agosto de 2027 y terminará el 11 de septiembre de 2027. Participarán nueve equipos: campeón, subcampeón y tercer lugar de cada una de las tres ligas regionales (Caribe, Sudamérica y Norteamérica y Centroamérica).

La primera fase tendrá tres grupos de tres equipos. Cada grupo contendrá exactamente un representante de cada región y combinará un primer lugar, un segundo lugar y un tercer lugar regional:

| Grupo | Caribe | Sudamérica | Norteamérica y Centroamérica |
|---|---:|---:|---:|
| A | 1.º | 2.º | 3.º |
| B | 2.º | 3.º | 1.º |
| C | 3.º | 1.º | 2.º |

Esta rotación distribuye los puestos regionales de forma equilibrada: cada grupo recibe un primero, un segundo y un tercero, sin repetir región dentro del grupo.

**Primera fase:** cada grupo juega todos contra todos a una sola vuelta. Cada equipo disputa dos partidos; son tres partidos por grupo y nueve en total. Solo el primer lugar de cada grupo avanza.

**Fase final:** los tres ganadores se reúnen en un único grupo y juegan todos contra todos a una sola vuelta. Cada equipo disputa dos partidos y la fase suma tres encuentros. Los dos primeros de la tabla clasifican a la final del TAS, disputada a partido único; el ganador de esa final será el campeón.

El torneo suma trece partidos: nueve en la primera fase, tres en el grupo final y una final por el título. **Los trece encuentros se disputan a partido único; no hay ida y vuelta ni revancha.**

**Desempates de las tablas (primera fase y grupo final):** se aplican, en este orden, los siguientes criterios: (1) puntos; (2) diferencia de goles general; (3) goles a favor; (4) resultados entre los clubes empatados —puntos, diferencia de goles y goles a favor en sus enfrentamientos directos—; (5) juego limpio, favoreciendo al club con menos puntos disciplinarios; y (6) sorteo si persiste la igualdad. El sorteo utiliza una semilla reproducible y guarda la semilla y el lote asignado a cada club en el estado de temporada. La misma clasificación se conserva al volver a cargar la temporada.

La lógica está implementada en `NovaTASMatchDecisionEngine.get_ordered_tas_table()` y se expone mediante `FootballDataService.get_ordered_tas_standings()`. El método `save_tas_standings()` persiste la tabla ordenada y el registro del sorteo para cada fase.

**Desempate durante los partidos:** en la primera fase y en el grupo final, el marcador al terminar los 90 minutos se conserva, incluido el empate. Estos partidos no tienen prórroga ni tanda de penaltis, porque sus resultados alimentan las tablas de clasificación.

**Final por el título:** debe terminar con un ganador. Si hay empate tras los 90 minutos reglamentarios, se disputan dos tiempos de prórroga de 15 minutos (30 minutos en total). Si persiste el empate después de la prórroga, se realiza una tanda de cinco penaltis por equipo y, si continúa igualada, muerte súbita hasta obtener un ganador. Los goles de la tanda se registran por separado y no se suman al marcador de goles del partido.

El motor de decisión está en `scripts/simulation/tas_match_decision_engine.gd` y el ciclo de vida de la edición en `scripts/simulation/tas_competition_engine.gd`. `FootballDataService` ya permite crear una edición con nueve clasificados validados, generar los tres grupos iniciales, simular y persistir partidos, actualizar tablas, avanzar al grupo final, generar la final y cerrar la edición con campeón. El guardado de cada resultado y del estado de la edición se realiza en una operación transaccional de `FootballDatabase`. La pantalla está conectada en `scripts/ui/game_hub.gd` dentro de Modos > TAS. Los trece fixtures se crean a partido único; la primera fase y el grupo final permiten empates, y solo la final utiliza prórroga y penaltis. La entrada de los nueve clasificados todavía debe conectarse automáticamente a los podios finales de las tres ligas regionales; hasta entonces la creación de edición recibe los nueve clasificados como entrada validada. Las pruebas son `tests/test_tas_match_decision_engine.gd` y `tests/test_tas_competition_engine.gd`; su ejecución real con Godot 4.4.1 sigue pendiente.

**Sede:** el torneo cambiará de país anfitrión en cada edición. La sede se sorteará aleatoriamente entre los países representados por los clubes participantes de esa edición. Ningún país será considerado elegible hasta presentar confirmación oficial y verificable de que acepta organizar el torneo; los países sin confirmación antes del sorteo del 24 de junio de 2027 quedarán fuera del sorteo vigente y se registrará el motivo. Antes del sorteo, NOVA publicará la lista de países elegibles. Se excluirán los últimos cinco países anfitriones de las cinco ediciones anteriores; por tanto, se conservará el historial de sedes y se comprobarán las cinco ediciones más recientes antes de admitir un país al sorteo. Si queda exactamente un país elegible, será designado automáticamente sin sorteo. Si no queda ningún país elegible, se ampliará excepcionalmente el sorteo a los siguientes tres países participantes de la lista de exclusión, es decir, los países representados por clubes participantes que ocupen los puestos sexto, séptimo y octavo en el orden de anfitriones anteriores más recientes. En ese caso se realizará un sorteo público entre esos tres países el mismo 24 de junio de 2027, junto con el sorteo ordinario de la sede. La designación automática o el sorteo de contingencia también se publicarán en NOVA y quedarán registrados en la auditoría. Si uno o más de esos tres países tampoco pueden albergar el torneo por una circunstancia excepcional, se documentará la causa y se ampliará el sorteo a los siguientes tres países participantes del orden de exclusión; se repetirá en bloques de tres hasta obtener un anfitrión válido. Estas ampliaciones se harán públicamente el 24 de junio de 2027, siempre que sea posible, y quedarán registradas en la auditoría.

El sorteo del país anfitrión se realizará públicamente el 24 de junio de 2027, tres días después de las finales regionales del 21 de junio de 2027 y antes del inicio del TAS. Antes del sorteo, NOVA publicará los países elegibles y los últimos cinco países anfitriones excluidos. Al terminar, NOVA publicará automáticamente el país anfitrión y el resultado, junto con la fecha y el registro de auditoría del sorteo. Los criterios de desempate de las tablas ya están definidos e implementados; las fechas individuales de cada partido siguen pendientes.

## Contexto histórico de la edición inaugural del TAS (2027)

El TAS comenzó después de concluir la primera temporada de las tres ligas regionales: las ligas finalizaron el 21 de junio de 2027 y la edición inaugural del TAS comenzó el 27 de agosto de 2027.

Como antecedente deportivo de esta edición queda registrado que Anier ganó con Santiago de Cuba su primer torneo internacional y, posteriormente, ganó la edición inaugural del TAS de 2027. Este dato se conserva como historial deportivo indicado por el usuario; no representa todavía un resultado generado o verificado por el motor de simulación.

## Estado de implementación

Las dos nuevas ligas tienen sus 40 plazas asignadas. El motor regional reutilizable valida las 40 plazas, exige cuatro clubes por asociación, distribuye exactamente uno de cada asociación por grupo y genera 45 fixtures por grupo. `FootballDataService.create_american_regional_champions_edition()` valida los clubes jugables, persiste la edición y emite el resultado del sorteo a la ceremonia común de GameHub. Los resultados y la progresión completa de eliminatorias siguen pendientes; la validación automatizada requiere ejecutar Godot 4 en CI.

Antes de iniciar temporadas todavía se requiere:

1. Completar y verificar los clubes de Primera División en el registro global.
2. Implementar un motor regional reutilizable sin acoplar reglas específicas del Caribe.
3. Implementar y probar el sorteo con un club de cada asociación en cada grupo.
4. Integrar resultados, tablas, eliminatorias y persistencia de temporadas.
5. Definir criterios de desempate.
6. Completar la auditoría de las nuevas fechas contra calendarios nacionales oficiales y disponibilidad de sedes.
7. Añadir y ejecutar pruebas automatizadas con Godot 4.
8. Definir formato, calendario y sede del TAS.

No se declara terminada la integración de motor ni la validación en tiempo de ejecución.


## Decisión registrada: repesca 2027

Para ambas ligas regionales, la ida de la repesca queda fijada el 3 de abril de 2027 y la vuelta el 17 de abril de 2027, exactamente dos semanas después. La ida ya no coincide con la ventana internacional masculina FIFA del 22 al 30 de marzo. Sin embargo, la vuelta del 17 de abril ocurre después de las fechas actualmente asignadas a octavos (9 y 16 de abril), lo que rompe el orden deportivo: los octavos no pueden comenzar antes de conocerse los cuatro ganadores de la repesca. Por tanto, los octavos y las fases posteriores quedan pendientes de reprogramación. No se considera validado el calendario completo hasta resolverlo y auditar los calendarios nacionales.


## Calendario común de las tres competiciones regionales

Las tres ligas —Caribe, Sudamérica y Norteamérica y Centroamérica— comparten temporada del 10 de octubre de 2026 al 21 de junio de 2027. La secuencia de eliminatorias común queda así: repesca 3 y 17 de abril; octavos 23 y 30 de abril; cuartos 7 y 14 de mayo; semifinales 21 y 28 de mayo; tercer puesto 17 de junio; final 21 de junio. La ventana internacional masculina FIFA del 7 al 15 de junio queda libre. Las fechas siguen sujetas a auditoría de calendarios nacionales y sedes.



## Año de fundación compartido

Por decisión confirmada por el usuario, las tres competiciones regionales se consideran fundadas en **2020**: Liga de Campeones del Caribe, Liga de Campeones de Sudamérica y Liga de Campeones de Norteamérica y Centroamérica. El Torneo Americano de Supercampeones (TAS) se considera fundado en **2021**, ya que es una competición posterior que reúne a los tres primeros clasificados de las ligas regionales. El catálogo y los manifiestos registran `founding_year` y `founding_status: user_confirmed` con el año correspondiente. La interfaz debe mostrar el año de fundación y calcular la antigüedad a partir de la fecha actual del juego; no debe fijar un número de años transcurridos.

## Presentación audiovisual de sorteos

Todos los sorteos oficiales de competiciones deben utilizar una presentación común, con estilo de ceremonia televisiva de FIFA: escenario y rótulos del torneo, bombos visibles, bolas que se extraen una por una, revelación animada de clubes/asociaciones y asignación visual a grupos o cruces. La secuencia debe generarse dentro del juego a partir del resultado real del motor de sorteo, no volver a sortear ni alterar el resultado por la animación. Debe incluir el botón **Saltar sorteo**, disponible desde el inicio; al activarlo se omite la animación restante y se muestra inmediatamente el resultado completo ya calculado. La semilla, las restricciones, el resultado y el orden de extracción se conservan en el registro de auditoría. Esta presentación debe ser reutilizable por todas las competiciones (continentales, nacionales y torneos personalizados), respetando las reglas particulares de cada sorteo. Se añadió `scripts/ui/competition_draw_ceremony.gd`, una secuencia animada dentro del juego (no un archivo MP4 exportado) con extracción de bolas, revelación secuencial y botón Saltar sorteo. `GameHub.present_competition_draw()` y `present_edition_draw()` muestran el resultado ya calculado sin volver a sortearlo. Los motores de Caribe, Sudamérica, Norteamérica/Centroamérica y TAS ahora incluyen `draw_presentation`; las pruebas comprueban 48, 40 y 9 participantes, respectivamente. La lista continental muestra los años de fundación. Aún falta conectar los flujos de interfaz que crean cada edición, además de copas y torneos domésticos/personalizados, con el punto de entrada y validar la secuencia en Godot 4; hasta completar esas conexiones no se declara la función integrada globalmente.


## Integración global de la ceremonia de sorteos

`FootballData.draw_ceremony_requested` es la señal común que publica los resultados de sorteos ya resueltos. `GameHub` escucha esa señal y abre `NovaCompetitionDrawCeremony` automáticamente. Se conectaron los flujos existentes de:
- Liga de Campeones del Caribe: sorteo de grupos, octavos y rondas eliminatorias sorteadas.
- Liga de Campeones de Sudamérica y Liga de Campeones de Norteamérica/Centroamérica: sorteo de grupos mediante el motor regional compartido y el nuevo método de servicio.
- TAS: grupos iniciales, grupo final y final por el título.
- Copa de Cuba y Supercopa de Cuba.
- Playoffs de ascenso de Segunda y Tercera División.

La ceremonia muestra los clubes y sus rivales con nombres resueltos, la fase o grupo correspondiente y permite saltar la animación sin cambiar el sorteo guardado. Las ligas de formato todos-contra-todos no necesitan sorteo de emparejamientos: su calendario se genera directamente. La animación es una presentación dentro de Godot, no un archivo de vídeo MP4. La prueba de la ceremonia y la prueba de apertura desde GameHub se añadieron al workflow de Godot 4; la ejecución queda pendiente de CI.


La ceremonia audiovisual común está documentada en `docs/COMPETITION_DRAW_CEREMONY.md`; los sorteos regionales usan la misma presentación que Caribe, TAS y las copas nacionales.
