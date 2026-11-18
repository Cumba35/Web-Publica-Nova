# Fútbol Nova — balones oficiales por liga y sistema de canteras

**Estado:** requisito confirmado por el usuario el 14-11-2026; diseño funcional y fuentes de recursos investigados. Implementación y pruebas pendientes.
**Ámbito:** todas las ligas nacionales y sus divisiones; estructura cubana inicial y futuras pirámides nacionales.
**Principio:** cada liga nacional/estructura liguera tendrá un balón oficial propio, compartido por todas sus divisiones. Los clubes de Primera tendrán cantera operativa desde el inicio. Los clubes de Segunda, Tercera y categorías inferiores comenzarán sin cantera operativa y solo podrán crear/activar una academia si cumplen los mismos requisitos reglamentarios, económicos y operativos establecidos para Segunda.

## 1. Balón oficial de liga

- Cada liga nacional tendrá una identidad de balón oficial, asociada a la asociación/estructura liguera, no a una división.
- El mismo balón se usará en Primera, Segunda y Tercera y en las demás divisiones que formen parte de esa misma liga.
- El balón será diferente entre ligas nacionales, con nombre, ID, patrón, paleta, textura y recursos originales/licenciados.
- El balón se asignará automáticamente a partidos oficiales de liga de cualquier división. El selector prepartido lo mostrará como obligatorio/bloqueado en esos encuentros.
- Los amistosos y partidos no oficiales podrán permitir otros balones disponibles, según las reglas del selector prepartido.
- Copa y Supercopa solo tendrán balón propio si el organizador/competición define uno; de lo contrario heredarán el balón de la asociación anfitriona o la regla de sede documentada. No inventar una asignación para competiciones sin decisión.
- El balón asignado afecta apariencia. No se introducirán ventajas físicas por diseño/color. Parámetros físicos deberán ser comunes y equilibrados, salvo que un reglamento o modo de entrenamiento defina lo contrario.
- El cambio de temporada podrá renovar el diseño mediante versión/temporada sin cambiar el ID histórico de partidos ya jugados.

### 1.1 Catálogo de diseños y licencias

Investigar primero recursos de dominio público/CC0 y diseños propios. Candidatos localizados:
- Wikimedia Commons, **Football (soccer ball).svg**: la ficha declara CC0 1.0, permite copiar/modificar/distribuir incluso con fines comerciales sin pedir permiso, sujeto a los términos de CC0. Es un icono simple, no una textura 3D de balón terminado.
- Wikimedia Commons, **Blue and red design of a custom soccer ball.svg**: la ficha lo marca como dominio público por carecer de autoría original protegible; diseño simple con bordes azules y líneas rojas. Debe conservarse registro de la ficha y comprobar el archivo descargado.
- FreeSVG, **Soccer ball** y **Soccer ball vector graphics**: publicados como Public Domain/CC0 según sus fichas.
- FreeSVG, **Seamless Soccer pattern**: patrón de balones con licencia Public Domain/CC0 según su ficha.

Fuentes:
- https://commons.wikimedia.org/wiki/File:Football_(soccer_ball).svg
- https://commons.wikimedia.org/wiki/File:Blue_and_red_design_of_a_custom_soccer_ball.svg
- https://freesvg.org/soccer-ball
- https://freesvg.org/soccer-ball-vector-graphics
- https://freesvg.org/seamless-soccer-pattern

**Advertencia legal:** no existe una búsqueda web que permita garantizar que un diseño está libre de todos los derechos en todos los países. CC0/dominio público de una imagen resuelve la licencia de copyright de ese archivo en los términos declarados, pero no garantiza por sí solo ausencia de marcas, diseños industriales registrados, derechos sobre elementos añadidos o derechos de terceros. La búsqueda de diseños registrados puede ser no exhaustiva; revisar DesignView/EUIPO y registros relevantes antes de usar un diseño comercialmente. Evitar por completo logotipos, nombres, patrones reconocibles y siluetas distintivas de marcas o torneos reales. Ante duda, crear un patrón propio desde geometría básica y documentar la autoría.
- Referencia de búsqueda de diseños: https://www.euipo.europa.eu/en/designs/before-applying/availability

### 1.2 Producción de los balones

- Usar los archivos CC0 como inspiración/elementos base sencillos, no como balones comerciales de marcas conocidas.
- Crear para cada liga un patrón original y un mapa UV/textura 2D propio; aplicar al modelo 3D común del balón.
- Variar paneles, líneas, colores y composición sin replicar diseños registrados o fácilmente identificables.
- Registrar por asset: ID, autor/origen, URL de origen, licencia declarada, fecha de verificación, hash SHA-256, modificaciones realizadas, revisión legal y ligas/temporadas que lo usan.
- Si la licencia o procedencia no puede verificarse, el asset queda fuera del juego hasta reemplazo.
- El catálogo debe poder ampliarse sin descargar assets de sitios externos en tiempo de partido; los recursos necesarios deben estar instalados/paquetizados y validados.

## 2. Política de cantera por división

Cada club tendrá un registro de estado de cantera para que el juego pueda evaluar su elegibilidad, pero ese registro no significa que la academia esté operativa. La configuración inicial será:

- **Primera División:** todos los clubes comienzan con cantera operativa y equipos juveniles.
- **Segunda División:** los clubes comienzan sin cantera operativa. Pueden crearla/activarla cuando cumplan los requisitos de licencia, instalaciones, personal, protección juvenil, presupuesto y solvencia definidos en la sección 3.
- **Tercera División y todas las categorías inferiores:** ningún club comienza con cantera ni equipos juveniles. Si desea crear una, deberá cumplir exactamente las mismas reglas y controles de elegibilidad que un club de Segunda División; no habrá requisitos más fáciles por pertenecer a una categoría inferior.
- La categoría deportiva no concede una exención automática: todos los clubes que soliciten academia deben superar la misma auditoría base de asociación. Los costes y umbrales podrán configurarse por asociación, pero la regla de elegibilidad será común para Segunda, Tercera e inferiores.
- Hasta obtener aprobación, el club mostrará el estado «Sin cantera — puede solicitar creación» o «Solicitud de cantera pendiente», según corresponda.
- Un club que no pueda financiar una academia podrá seguir compitiendo sin ella. No se generarán juveniles de ese club ni se le inscribirán equipos juveniles automáticamente.
- Si una academia ya creada entra en dificultades financieras, podrá reducir capacidad, suspender captación o reestructurarse sin borrar el historial de los jugadores registrados.

## 3. Requisitos comunes para crear o activar cantera en Segunda, Tercera e inferiores

La asociación debe definir y validar requisitos nacionales configurables. Como mínimo:

1. **Licencia y registro:** solicitud de academia, responsables identificados dentro del universo ficticio, reglamento juvenil aceptado y aprobación de la asociación.
2. **Instalaciones:** acceso contractual a campo(s) de entrenamiento y partidos juveniles, vestuarios, almacenamiento/equipamiento y espacio seguro. No se exige estadio propio si hay convenio válido.
3. **Personal mínimo:** responsable de cantera, entrenador juvenil cualificado, responsable médico/físico compartido o contratado y administración/registro de jugadores. La asociación define equivalencias y ratios.
4. **Protección y elegibilidad:** política de protección de menores, autorizaciones requeridas dentro del mundo ficticio, registro de edad, salud y elegibilidad, protocolo de quejas y transporte seguro.
5. **Presupuesto inicial:** fondos suficientes para alta, equipamiento, licencias e instalación o convenio.
6. **Solvencia operativa:** demostrar capacidad para cubrir salarios/servicios, desplazamientos, mantenimiento y competición juvenil durante el periodo mínimo establecido por la asociación, además de mantener la liquidez mínima y atender obligaciones vencidas.
7. **Plan deportivo:** grupos de edad, capacidad de plantilla, calendario de entrenamiento, metodología y vía de promoción al primer equipo.
8. **Aprobación final:** auditoría automática del juego que valida documentación, instalaciones, personal y presupuesto; la asociación puede conceder, denegar o exigir correcciones.

No fijar importes absolutos universales: umbrales, ratios, costes, licencias y plazos serán configurables por asociación/país y se calibrarán con la moneda única del juego, que sigue pendiente de elección.

## 4. Capacidad, costes y sostenibilidad

- La capacidad de la academia depende de instalaciones, personal, presupuesto y categoría del club.
- Costes recurrentes: salarios del personal, mantenimiento, equipamiento, desplazamientos, atención médica, alojamiento cuando corresponda y cuotas de competición.
- Ingresos/financiación posibles: presupuesto del club, inversión aprobada por propietarios, subvenciones ficticias de asociación, acuerdos regionales y compensaciones de formación/solidaridad que correspondan según las reglas del juego.
- No permitir que el club active una cantera si la operación deja su tesorería por debajo del umbral de liquidez/reserva o provoca impagos previsibles.
- La junta directiva podrá exigir desarrollo juvenil como objetivo de temporada solo si el club tiene una academia legalmente operativa y presupuesto suficiente. No se penalizará al club por no tener cantera cuando su categoría o estado inicial no la incluye.
- Si el club entra en insolvencia, activar plan de reducción/reestructuración antes de cerrar la academia. No borrar contratos ni historiales.

## 5. Equipos y competiciones juveniles

- Las canteras tendrán categorías de edad configurables por asociación; el juego debe respetar edad mínima/máxima, ventanas de inscripción y reglas de elegibilidad.
- Los equipos juveniles se vinculan a la asociación, país, región y estructura de divisiones del primer equipo.
- La estructura puede incluir liga, copa, supercopa y torneos adicionales cuando la asociación lo justifique y exista calendario viable.
- El sistema de calendario debe evitar conflictos con partidos profesionales, exámenes/descanso representados por el modo, viajes y disponibilidad de instalaciones.
- Los equipos de cantera pueden jugar amistosos si las reglas y el consentimiento del rival lo permiten.
- Ascender al primer equipo, ceder, renovar o liberar juveniles debe respetar edad, contrato, inscripción y normativa ficticia aplicable.
- Mantener un historial de clubes formadores y temporadas/años de formación. Integrar compensación de formación y solidaridad con el sistema financiero ya especificado, sin duplicar pagos.

## 6. Generación y desarrollo de juveniles

- Generar jugadores juveniles de forma coherente con país/región, tamaño de población futbolística, red de ojeo, prestigio y calidad de formación de la academia.
- Los informes de scouting deben usar rangos estimados de atributos/potencial hasta que la observación mejore la precisión.
- El desarrollo depende de edad, potencial, entrenamiento, calidad de entrenadores, instalaciones, minutos, salud, carga y entorno; no garantizar que todos alcancen su potencial.
- Evitar generar plantillas juveniles idénticas o cantidades irreales; usar nombres y atributos ficticios originales.
- Cada jugador mantiene historial de academia, alta/baja, entrenamientos, minutos, promociones, contratos y clubes formadores.
- El juego base debe poblar las canteras de forma que las competiciones juveniles puedan comenzar sin exigir microgestión del usuario; las decisiones avanzadas quedan disponibles en Modo Manager.

## 7. Modelo de datos mínimo

### Balón
`ball_id`, `league_system_id`, `season_id`, `display_name`, `asset_id`, `texture_hash`, `license_record_id`, `effective_from`, `effective_to`, `official_for_divisions`, `physics_profile_id`, `schema_version`.

### Academia
`academy_id`, `club_id`, `association_id`, `status` (pending/active/suspended/restructuring), `license_id`, `facility_ids`, `staff_ids`, `youth_teams`, `capacity`, `annual_budget`, `operating_costs`, `liquidity_check`, `compliance_status`, `created_at`, `schema_version`.

### Jugador juvenil
`youth_registration_id`, `player_id`, `academy_id`, `registered_from`, `registered_to`, `age_group`, `eligibility_status`, `development_history`, `promotion_history`.

## 8. Pruebas de aceptación

1. La liga cubana asigna un único balón oficial compartido por Primera, Segunda y Tercera.
2. Un partido oficial de cualquier división usa automáticamente el balón de la liga y bloquea su cambio.
3. Un amistoso permite seleccionar un balón alternativo cuando está instalado y permitido.
4. Un partido de Copa/Supercopa sigue la asignación explícita de su reglamento y no hereda una regla inventada.
5. Todos los clubes de Primera comienzan con cantera operativa.
6. Ningún club de Segunda, Tercera o categorías inferiores comienza con cantera operativa ni recibe juveniles automáticamente.
7. Los clubes de Segunda, Tercera e inferiores solo pueden crear/activar cantera tras superar los mismos requisitos y auditorías comunes; pertenecer a una categoría inferior no reduce los requisitos de elegibilidad.
8. Si cumple todos los requisitos, la asociación permite crear/activar la academia y el coste queda registrado en el libro mayor.
9. Una academia no puede comprometer pagos por encima de la liquidez o reservas exigidas.
10. La falta temporal de fondos activa reestructuración/suspensión de captación sin borrar historiales.
11. Los equipos juveniles se inscriben en competiciones compatibles y sus calendarios no chocan con restricciones.
12. Promoción y transferencias juveniles conservan historial y compensaciones formativas correspondientes.
13. Los assets de balón sin licencia/procedencia verificada no se empaquetan.
14. Guardar/cargar conserva asignación de balón, licencias, academia, presupuesto, plantilla juvenil y progreso.
15. El sistema funciona offline con el catálogo de assets instalado.

**Límite actual:** este documento define requisitos y candidatos de recursos. No afirma que los balones, academias, licencias, economía juvenil o competiciones de cantera estén implementados. Deben conectarse a los datos, calendario, reglamentos y libro mayor existentes y superar pruebas en Godot.
