# Fútbol Nova — selector de equipos y preparación del partido

**Estado:** primera versión funcional del selector de clubes y preparación de amistosos integrada el 17-11-2026; validación Godot/Android pendiente. Las vistas 3D, equipaciones, estadio y balón siguen pendientes.
**Referencia:** captura aportada por el usuario de una pantalla de amistoso con dos futbolistas 3D, escudos, valoración OVR, estadio, accesos de equipación, balón, ajustes y botón de inicio.

## Estado de implementación — 17 noviembre 2026

Implementado en la rama de trabajo:
- Selección independiente de club local y visitante desde el catálogo offline.
- Solo se ofrecen clubes cuya plantilla contiene al menos once jugadores resolubles.
- El inicio se bloquea si los equipos coinciden o una plantilla no supera la validación.
- Selección de once titulares sin IDs repetidos, priorizando las posiciones del sistema 4-3-3.
- Configuración previa del amistoso para duración por tiempo, reloj continuo/detenido y prórroga.
- La tanda de penaltis aparece identificada como «en desarrollo» y deshabilitada porque su motor de ejecución aún no existe.
- El botón de repetir partido vuelve a abrir la preparación y no inicia un encuentro genérico.

Pendiente de implementación y validación:
- Modelos 3D representativos y valoración OVR de los equipos.
- Escudos/banderas y vistas previas de equipaciones.
- Selector de balón y estadio con recursos reales instalados.
- Detección de conflictos de equipación y reglas visuales de porteros.
- Persistencia de preferencias de amistosos.
- Pruebas de interfaz en Godot, diferentes resoluciones y dispositivos Android.

La selección de equipos y el once inicial no deben confundirse con una integración completa de perfiles, atributos, animaciones o apariencias: los actores del partido siguen usando la representación procedural del motor actual.

## 1. Objetivo

Crear una pantalla previa al saque inicial que permita revisar el enfrentamiento y configurar visualmente el partido sin navegar por varios menús. Debe funcionar con clubes y selecciones, y adaptar sus controles al tipo de encuentro y al modo de origen.

La referencia orienta la composición y la jerarquía, pero Fútbol Nova tendrá identidad, recursos y componentes originales.

## 2. Composición de pantalla

- Cabecera con el tipo de encuentro (por ejemplo, Amistoso), acceso a ajustes y retorno.
- Equipo local a la izquierda y visitante a la derecha.
- En cada lado: modelo 3D representativo con la equipación seleccionada, escudo/bandera, nombre y valoración general OVR calculada desde la plantilla y el criterio del modo.
- Marcador central VS y controles para cambiar/seleccionar equipos cuando el modo lo permita.
- Selector visible del estadio, con nombre y vista previa; controles para recorrer estadios disponibles.
- Acceso de equipación independiente para local y visitante, con vista previa 3D inmediata.
- Acceso al selector de balón con vista previa.
- Botón principal para iniciar el partido, habilitado solo cuando equipos, plantillas, estadio, equipaciones y reglas superen las validaciones.

Los controles de aleatorizar o cambiar equipo, si se ofrecen, deberán distinguirse claramente de los controles de apariencia y nunca modificar una selección sin reflejarlo en pantalla.

## 3. Cambiar uniformes

- Abrir el selector correspondiente al equipo local o visitante sin perder la selección del otro.
- Mostrar las equipaciones realmente disponibles para ese equipo: local, visitante, alternativa y portero cuando aplique.
- Previsualizar simultáneamente el modelo 3D y los colores elegidos.
- Validar contraste entre ambos equipos y con los porteros; advertir y proponer una alternativa si hay conflicto visual.
- Permitir equipaciones personalizadas solo si pertenecen al catálogo/edición y cumplen validaciones.
- Guardar la elección para ese encuentro; no sobrescribir la equipación oficial del club ni los datos originales.

## 4. Cambiar balón

- Abrir un catálogo visual de balones disponibles y autorizados.
- Mostrar nombre/identificador y vista previa 3D.
- Aplicar el balón elegido al partido actual.
- En competiciones oficiales, usar el balón obligatorio de la competición si su reglamento o configuración lo fija; mostrarlo como selección bloqueada o informativa.
- No conceder ventajas de física por elegir una apariencia: las diferencias físicas solo existen si el diseño del balón y las reglas del juego las definen de forma legítima y equilibrada.

## 5. Cambiar estadio

- Recorrer estadios disponibles y mostrar nombre, vista previa y datos pertinentes (superficie y capacidad si están registrados).
- Aplicar el estadio seleccionado solo al encuentro actual.
- En partidos oficiales, respetar sede y estadio asignados por el calendario/reglamento. Si la competición admite sede alternativa, aplicar sus reglas.
- Si un estadio no está instalado o no es compatible con el modo, deshabilitarlo con una explicación; nunca sustituir silenciosamente una sede oficial.

## 6. Configuración del juego y clasificación de partidos

El acceso a configuración contextual de partido será editable únicamente en partidos no oficiales que permitan personalización, por ejemplo amistosos, exhibición, entrenamiento o partidos de torneo personalizado que el reglamento marque como configurables.

En partidos oficiales (liga, copa, supercopa, eliminatorias oficiales, partidos oficiales de selección y cualquier encuentro vinculado a una carrera/competición con reglamento obligatorio):
- Los ajustes incompatibles con las reglas estarán bloqueados.
- Los parámetros obligatorios vendrán del reglamento de la competición o del modo.
- Los ajustes generales de accesibilidad, volumen, gráficos y controles seguirán disponibles si no alteran la competición.
- No se podrá cambiar manualmente el resultado, la dificultad competitiva, las reglas, la sede, el balón obligatorio ni los parámetros protegidos por el reglamento.

En partidos no oficiales configurables, el panel puede incluir, según soporte del motor:
- Duración de cada tiempo y método del reloj.
- Dificultad de IA y velocidad de juego.
- Prórroga y tanda de penaltis.
- Manos, lesiones y sanciones disciplinarias.
- Número de sustituciones y límites amistosos.
- Árbitro, precisión arbitral y VAR.
- Clima/hora del día y otras condiciones de exhibición.
- Otras reglas de partido disponibles y probadas.

La pantalla debe indicar qué opciones se aplicarán, cuáles están bloqueadas y por qué. No mostrar controles sin efecto real. Los valores deben validarse y guardarse en la configuración del encuentro, sin contaminar ajustes globales ni carreras.

## 7. Precedencia de reglas

Resolver los valores efectivos en este orden:
1. Reglamento obligatorio de competición oficial.
2. Reglas del modo/carrera y estado del calendario.
3. Configuración permitida del tipo de partido.
4. Preferencias globales compatibles.

Un valor inferior nunca puede anular uno superior. La interfaz debe reflejar el valor efectivo, no solo el valor solicitado por el usuario.

## 8. Persistencia y datos

La configuración del encuentro debe registrar como mínimo:
- `match_id`, `match_type`, `mode_id`, `competition_id` cuando aplique.
- `home_team_id`, `away_team_id`, `stadium_id`, `ball_id`.
- `home_kit_id`, `away_kit_id`, variantes de portero.
- `requested_settings`, `effective_settings`, `locked_settings` y motivos de bloqueo.
- `ruleset_id`, `validation_status`, `schema_version`.

Las elecciones cosméticas de un amistoso no deben alterar los datos permanentes de clubes, equipaciones o competiciones. La selección puede recordarse como preferencia para amistosos, pero debe poder revisarse antes de iniciar cada partido.

## 9. Accesibilidad y adaptación Android

- Controles táctiles amplios y separados; iconos acompañados de etiquetas o ayudas accesibles.
- Mantener la información esencial legible en orientación y tamaños de pantalla compatibles.
- No depender exclusivamente del color para diferenciar local y visitante.
- Permitir navegación por mando/teclado además del tacto.
- Animaciones y modelos 3D deben tener niveles de calidad para dispositivos Android de distintas capacidades.

## 10. Pruebas de aceptación

1. La pantalla muestra simultáneamente local, visitante, escudos/banderas, OVR, VS, estadio y acceso a iniciar.
2. Cambiar la equipación local no modifica la visitante y viceversa; la vista previa 3D se actualiza.
3. Un conflicto de colores se detecta y se ofrece una equipación compatible.
4. Cambiar el balón afecta solo al partido actual y no modifica el catálogo ni el balón oficial de un torneo.
5. Cambiar el estadio afecta solo al encuentro configurable.
6. En un amistoso, las opciones permitidas se pueden modificar y el resumen muestra sus valores efectivos.
7. En un partido oficial, los parámetros reglamentarios aparecen bloqueados y no se pueden alterar mediante UI ni datos manipulados.
8. La precedencia del reglamento prevalece sobre preferencias globales y ajustes del usuario.
9. Un encuentro oficial mantiene el estadio, balón, reglas y sede establecidos por su competición.
10. Guardar/cargar una configuración mantiene las selecciones sin modificar clubes ni carreras.
11. Las opciones no soportadas o recursos ausentes aparecen deshabilitados con explicación.
12. El botón de inicio no permite lanzar un partido con datos inválidos o selecciones incompatibles.

**Límite actual:** esta especificación no afirma que la pantalla ni sus selectores estén implementados. Deben integrarse con el catálogo de datos, el contrato común de partido y el motor de reglas, y probarse en Godot/Android antes de considerarlos terminados.
