# Fútbol Nova — Modelo deportivo: jugadores y posiciones

**Estado:** especificación de datos en progreso.  
**Alcance de este paso:** identidad del jugador, posiciones, roles y atributos individuales. No incluye pantallas, escenas ni integración en Godot.  
**Referencia:** categorías funcionales observadas en FIFA 23; vocabulario, estructura y datos de Fútbol Nova son propios.

## 1. Principios

- El paquete inicial utiliza futbolistas ficticios.
- Cada jugador tiene un ID estable e independiente del nombre visible, dorsal o club.
- La posición natural, la posición secundaria y el rol táctico son conceptos separados.
- Los atributos permanentes se separan de variables temporales como forma, moral, fatiga y condición.
- La escala 1–99 se conserva únicamente como propuesta de trabajo, pendiente de calibración.
- No se fija todavía una fórmula de valoración general ni de potencial.

## 2. Posiciones

### Portería
- **POR:** portero.

### Defensa
- **DFC:** defensa central.
- **LI:** lateral izquierdo.
- **LD:** lateral derecho.
- **CAI:** carrilero izquierdo.
- **CAD:** carrilero derecho.

### Mediocampo
- **MCD:** mediocentro defensivo.
- **MC:** mediocentro.
- **MCI:** interior izquierdo.
- **MCDR:** interior derecho (código provisional; revisar para evitar colisión con mediocentro defensivo).
- **MCO:** mediocentro ofensivo.
- **MI:** volante/extremo de banda izquierda.
- **MD:** volante/extremo de banda derecha.

### Ataque
- **EI:** extremo izquierdo.
- **ED:** extremo derecho.
- **SD:** segundo delantero.
- **DC:** delantero centro.

**Nota de normalización:** los códigos anteriores son etiquetas de diseño. Antes de generar paquetes de datos se consolidará un enum único, evitando duplicidades entre MCD (mediocentro defensivo) y cualquier código de interior derecho. El código interno recomendado para interior derecho es `INTERIOR_DERECHO`; para mediocentro defensivo, `MCD`.

## 3. Roles tácticos

Los roles describen el comportamiento esperado dentro de una posición y no sustituyen a la posición:
- Portero: tradicional, adelantado/portero-líbero, distribuidor.
- Central: marcador, corrector/cobertura, central constructor.
- Lateral/carrilero: defensivo, equilibrado, profundo/ofensivo, invertido.
- Mediocentro defensivo: ancla, recuperador, organizador retrasado.
- Mediocentro/interior: organizador, todoterreno, llegador, recuperador.
- Mediocentro ofensivo: creador, mediapunta llegador, enganche.
- Extremo/volante: abierto, interiorizado, creador, atacante directo.
- Segundo delantero: enlace, móvil, finalizador.
- Delantero centro: referencia, atacante de profundidad, delantero asociativo, presionante.

Un rol puede modificar instrucciones y selección de acciones de IA, pero no altera los atributos base del jugador.

## 4. Atributos de jugadores de campo

| Grupo | Atributo | Significado |
|---|---|---|
| Ritmo | aceleración | Capacidad de alcanzar velocidad en pocos pasos |
| Ritmo | velocidad punta | Velocidad máxima en carrera |
| Tiro | posicionamiento ofensivo | Calidad para encontrar espacios de remate |
| Tiro | definición | Precisión al finalizar ocasiones |
| Tiro | potencia de tiro | Fuerza aplicada al disparo |
| Tiro | tiros lejanos | Calidad de disparo desde fuera del área |
| Tiro | voleas | Ejecución de remates sin controlar previamente |
| Tiro | penaltis | Precisión y control en lanzamientos de penalti |
| Pase | visión | Capacidad para detectar líneas y opciones de pase |
| Pase | centros | Precisión de envíos desde zonas laterales |
| Pase | precisión de faltas | Calidad de golpeo en faltas directas |
| Pase | pase corto | Precisión y velocidad de pase corto |
| Pase | pase largo | Precisión de cambios de orientación y envíos largos |
| Pase | efecto | Capacidad de imprimir curva al balón |
| Regate | agilidad | Rapidez para cambiar la dirección corporal |
| Regate | equilibrio | Estabilidad al girar, recibir contacto o ejecutar acciones |
| Regate | reacciones | Rapidez de respuesta ante cambios del juego |
| Regate | control de balón | Calidad del primer toque y recepción |
| Regate | regate | Capacidad de superar rivales conduciendo |
| Regate | compostura | Control técnico bajo presión |
| Defensa | intercepciones | Lectura y corte de líneas de pase |
| Defensa | precisión de cabezazo | Dirección y calidad de cabezazos |
| Defensa | conciencia defensiva | Lectura de espacios, marcas y amenazas |
| Defensa | entrada normal | Eficacia en entradas de pie |
| Defensa | entrada deslizante | Eficacia en entradas deslizantes |
| Físico | salto | Capacidad de elevación |
| Físico | resistencia | Capacidad de sostener esfuerzo durante el partido |
| Físico | fuerza | Capacidad de proteger balón y resistir contacto |
| Físico | agresividad | Intensidad en disputas y presión; no equivale a cometer faltas |

## 5. Atributos de portero

| Atributo | Significado |
|---|---|
| estirada | Alcance y ejecución de paradas en extensión |
| blocaje | Capacidad de atrapar y asegurar el balón |
| saque | Calidad de distribución con manos o pies |
| reflejos | Velocidad de respuesta ante remates |
| velocidad | Movilidad y rapidez al salir del área |
| colocación | Posicionamiento para cubrir ángulos y espacios |

Los porteros conservan también atributos de campo relevantes para controlar y distribuir el balón. La colocación del portero es distinta del posicionamiento ofensivo del jugador de campo.

## 6. Datos complementarios

- Pie dominante: izquierdo, derecho o ambidiestro.
- Pierna débil: nivel cualitativo o numérico, pendiente de calibración.
- Posición principal y lista ordenada de posiciones secundarias.
- Roles preferidos por posición.
- Ritmo de trabajo ofensivo y defensivo.
- Altura, peso y fecha de nacimiento/edad deportiva.
- Rasgos técnicos y de comportamiento, cada uno con ID, descripción y efecto de juego verificable.
- Nacionalidad y club como referencias a entidades del catálogo, no como texto duplicado.
- Dorsal como dato de inscripción en un equipo, no como identidad del jugador.

## 7. Variables dinámicas separadas

No mezclar con los atributos permanentes:
- forma actual;
- moral/confianza;
- condición física;
- fatiga acumulada;
- lesión y tiempo estimado de recuperación;
- sanciones;
- experiencia/minutos;
- estado contractual.

Estas variables deben tener historial o marca temporal cuando afecten una carrera o temporada.

## 8. Esquema JSON de referencia

El siguiente ejemplo es ficticio y solo ilustra la estructura. Los campos numéricos de atributos usan provisionalmente 1–99.

```json
{
  "schema_version": "0.1.0",
  "player": {
    "id": "player_fictional_0001",
    "display_name": "Dario Solís",
    "birth_date": "2002-04-18",
    "nationality_id": "country_fictional_01",
    "height_cm": 181,
    "weight_kg": 74,
    "preferred_foot": "right",
    "primary_position": "DC",
    "secondary_positions": ["SD", "EI"],
    "preferred_roles": ["delantero_profundidad", "finalizador"],
    "work_rate": {
      "attack": "high",
      "defense": "medium"
    },
    "attributes": {
      "pace": {"acceleration": 82, "sprint_speed": 84},
      "shooting": {
        "attacking_position": 78,
        "finishing": 81,
        "shot_power": 79,
        "long_shots": 72,
        "volleys": 68,
        "penalties": 70
      },
      "passing": {
        "vision": 70,
        "crossing": 64,
        "free_kick_accuracy": 55,
        "short_passing": 73,
        "long_passing": 61,
        "curve": 67
      },
      "dribbling": {
        "agility": 80,
        "balance": 76,
        "reactions": 79,
        "ball_control": 78,
        "dribbling": 82,
        "composure": 74
      },
      "defending": {
        "interceptions": 35,
        "heading_accuracy": 75,
        "defensive_awareness": 31,
        "standing_tackle": 28,
        "sliding_tackle": 24
      },
      "physical": {
        "jumping": 77,
        "stamina": 80,
        "strength": 74,
        "aggression": 69
      }
    },
    "potential": null,
    "overall_rating": null,
    "dynamic_state": {
      "form": null,
      "morale": null,
      "fitness": null,
      "fatigue": null,
      "injury_id": null,
      "suspension_matches": 0
    }
  }
}
```

Los valores del ejemplo no constituyen una plantilla de balance ni fijan un nivel de calidad. Los atributos no aplicables pueden omitirse o marcarse como no aplicables según el esquema final; no se deben rellenar artificialmente con valores neutros.

## 9. Validaciones necesarias

- ID único y estable.
- Posición principal válida y compatible con el tipo de jugador.
- Posiciones secundarias sin duplicados.
- Portero con atributos específicos de portero; jugador de campo con atributos de campo.
- Atributos dentro del rango definido por la versión del esquema.
- Altura, peso y fecha de nacimiento dentro de límites plausibles configurados por el juego.
- Roles compatibles con las posiciones declaradas.
- Referencias a nacionalidad, club y equipo existentes.
- No permitir valoración general o potencial calculados hasta aprobar sus fórmulas.
- Importaciones inválidas deben rechazarse con errores por campo, sin corromper el catálogo.

## 10. Pendiente para cerrar este bloque

1. Aprobar el enum definitivo de posiciones y códigos internos.
2. Decidir si la escala final será 1–99 u otra.
3. Definir atributos específicos de entrenadores y cuerpo técnico.
4. Diseñar pesos de valoración por posición y fórmula de potencial/progresión.
5. Probar rangos y distribución con una plantilla ficticia completa.

**Criterio de cierre:** este bloque solo se considera cerrado cuando posiciones, campos, escala y reglas de validación estén aprobados. La implementación en Godot queda fuera de esta fase.

## 11. Identidad del entrenador

Cada entrenador debe tener una identidad propia, independiente del equipo al que esté asignado, del cargo que desempeñe y del nombre visible. Esta identidad permite mantener su ficha, historial y referencias aunque cambie de club o selección.

Campos de identidad:
- `id`: identificador único y estable.
- `first_name`: nombre.
- `last_name`: apellidos.
- `birth_date`: fecha de nacimiento.
- `nationality_id`: referencia a una nacionalidad del catálogo.
- `profile_image_id`: referencia opcional a una imagen de perfil disponible en los recursos del juego.
- `team_id`: referencia al club o selección al que está vinculado actualmente; puede ser nula si está libre o retirado.
- `status`: estado profesional: `active`, `available` (libre), `retired` (retirado) o `suspended` (suspendido).

Reglas:
- El ID no cambia cuando el entrenador cambia de equipo, cargo o nombre visible.
- El equipo actual se almacena como referencia, no como texto libre.
- La nacionalidad debe apuntar a una entidad existente del catálogo.
- La imagen es opcional; la ausencia de imagen no debe impedir cargar la ficha.
- El estado profesional no sustituye al estado contractual: ambos se documentarán por separado.
- Los nombres visibles se mostrarán en español cuando proceda, sin traducir nombres propios.

Ejemplo JSON ficticio:

```json
{
  "id": "coach_fictional_0001",
  "first_name": "Marcos",
  "last_name": "Valera",
  "birth_date": "1978-06-12",
  "nationality_id": "country_fictional_01",
  "profile_image_id": null,
  "team_id": "team_fictional_0001",
  "status": "active"
}
```

**Estado:** estructura de identidad aprobada. Los cargos, especialidades, atributos, contratos, historial y responsabilidades del cuerpo técnico se documentarán en elementos separados. No se fijan todavía escalas de atributos ni fórmulas de impacto.

## 12. Cargo elegido por el usuario en una carrera de club

El cargo de administración seleccionado por el usuario al crear una carrera es un dato de la partida, no un cargo laboral asignado a una persona del cuerpo técnico.

Valores iniciales:
- `head_coach`: entrenador principal. Habilita la administración deportiva de la plantilla, alineaciones, tácticas, entrenamiento, desarrollo de jugadores y partidos.
- `club_president`: presidente del club. Habilita la administración institucional y estratégica, incluidas finanzas, presupuesto, directiva, inversiones, instalaciones, objetivos institucionales y nombramientos de alto nivel.

Reglas de modelado:
- Guardar la elección en los datos de la carrera, por ejemplo en `career.user_management_role`.
- No confundir `user_management_role` con el cargo laboral de un entrenador, segundo entrenador, preparador físico, ojeador u otro empleado.
- La autorización de acciones debe derivarse del cargo elegido y de una matriz explícita de permisos.
- Las acciones que correspondan al otro ámbito se gestionan mediante propuestas, solicitudes o informes, no mediante acceso directo.
- El valor elegido debe persistir al guardar y cargar la carrera.
- No asumir que el usuario puede cambiar de cargo durante una carrera; esa posibilidad requiere una decisión de diseño posterior.

Ejemplo de fragmento de guardado:

```json
{
  "career": {
    "id": "career_fictional_0001",
    "user_management_role": "head_coach"
  }
}
```

**Estado:** elección entre entrenador principal y presidente aprobada. La matriz detallada de permisos y el diseño de las responsabilidades del personal se completarán en pasos separados.

## 13. Personal médico del club

El club puede contratar personal médico y de recuperación para atender a sus futbolistas. Estos puestos pertenecen a la estructura profesional del club y no dependen de que el usuario haya elegido ser presidente, entrenador principal o ambos.

Puestos contemplados:
- **Médico del club:** supervisa la atención sanitaria deportiva, evalúa lesiones y coordina los tratamientos.
- **Fisioterapeuta:** trabaja en la recuperación funcional y el seguimiento físico de los jugadores.
- **Especialista en rehabilitación:** organiza los procesos de recuperación y el retorno progresivo a la competición.
- **Nutricionista:** diseña y supervisa pautas de alimentación relacionadas con las necesidades deportivas.

Datos de cada integrante:
- Identificador único, nombre, apellidos, nacionalidad e imagen de perfil opcional.
- Puesto y especialidad profesional.
- Experiencia y nivel profesional.
- Contrato, salario y estado contractual.
- Equipo o departamento al que está asignado.
- Disponibilidad actual e historial profesional.

Reglas de funcionamiento:
- La disponibilidad y especialidad del personal podrán influir en la atención, seguimiento y recuperación de los jugadores.
- Los efectos concretos, tiempos de recuperación y fórmulas de impacto quedan pendientes de diseño y aprobación.
- No se atribuirán capacidades médicas no definidas a un puesto.
- Los datos médicos y de lesiones de los futbolistas se tratarán como información deportiva interna del juego y se separarán de los atributos permanentes del jugador.
- La falta de un especialista no debe bloquear la partida; el juego deberá aplicar un procedimiento básico alternativo claramente definido.

**Estado:** puestos y responsabilidades generales aprobados. Las escalas de calidad, costes, fórmulas de recuperación y reglas detalladas de disponibilidad quedan pendientes.

## 14. Ojeo y captación de jugadores — metodología de referencia FIFA 23

El sistema de ojeo de Fútbol Nova tomará como referencia funcional los métodos de búsqueda de profesionales y captación juvenil de FIFA 23 Carrera, adaptándolos a la identidad y reglas propias del juego. Se toma como referencia el funcionamiento general, no se copiarán código, recursos gráficos, textos protegidos ni la presentación exacta de FIFA.

### 14.1 Red de ojeo de jugadores profesionales

- El club podrá contratar o asignar ojeadores y enviarlos a países o regiones.
- El usuario configurará instrucciones de búsqueda mediante filtros combinables: posición, edad, atributos o perfil de juego, características deseadas y situación contractual.
- Las instrucciones podrán dejar criterios sin especificar para no restringir innecesariamente los resultados.
- Cada ojeador tendrá dos capacidades diferenciadas:
  - **Experiencia:** influye en la cantidad de candidatos que puede encontrar y reportar.
  - **Juicio/criterio:** influye en la calidad de la evaluación y precisión de la información que entrega.
- Los ojeadores tendrán coste de contratación, desplazamiento o asignación y mantenimiento, según el sistema económico del club.
- El número de ojeadores simultáneos y la duración de las misiones dependerán de reglas configurables del juego; no se fija aquí un límite copiado de FIFA.

### 14.2 Informes progresivos

- Los informes se completarán gradualmente a medida que avance el tiempo de juego.
- Un informe inicial podrá mostrar información parcial: posición, edad aproximada, perfil físico/técnico, atributos estimados y valoración orientativa.
- Los informes posteriores podrán precisar atributos, valoración general estimada, valor de mercado y expectativas económicas.
- La precisión dependerá de la capacidad de juicio del ojeador, del tiempo dedicado y de la información disponible.
- La información no confirmada se mostrará como rango o estimación; no se presentará como dato exacto.
- El usuario podrá seguir investigando a un candidato, descartarlo o añadirlo a una lista de seguimiento.
- Cuando exista información suficiente, el candidato podrá pasar al proceso de negociación o contratación.

### 14.3 Captación de juveniles y cantera

- El club podrá asignar ojeadores juveniles a países o regiones y establecer la duración de sus misiones.
- La búsqueda podrá centrarse en perfiles amplios, como físicamente fuerte, técnico, creador de juego o defensivo, además de posiciones cuando proceda.
- Los informes juveniles llegarán periódicamente durante la misión e incluirán datos estimados de edad, perfil, posiciones, atributos, valoración actual y potencial en forma de rangos.
- La precisión de las estimaciones dependerá del juicio del ojeador y de la observación acumulada.
- El usuario podrá incorporar al jugador descubierto a la cantera, continuar observándolo o descartarlo.
- Desde la cantera se podrá desarrollar al jugador, promoverlo al primer equipo, cederlo cuando las reglas del modo lo permitan o liberarlo.
- Los jugadores juveniles generados serán propios de cada partida y se conservará su historial de desarrollo.

### 14.4 Flujo de decisión y responsabilidades

1. Definir la necesidad de plantilla o el perfil juvenil buscado.
2. Seleccionar ojeador, región y criterios de búsqueda.
3. Asignar presupuesto y duración.
4. Recibir informes parciales y revisar candidatos.
5. Ampliar la observación de los candidatos interesantes.
6. Añadirlos a seguimiento, incorporarlos a cantera o iniciar una negociación cuando proceda.
7. Registrar el resultado y el coste de la misión.

El presidente podrá aprobar presupuesto, contratación de ojeadores y estrategia general del departamento. El entrenador principal podrá solicitar perfiles por posición, estilo y necesidades tácticas y consultar informes para valorar su encaje deportivo. Si el usuario desempeña ambos cargos, podrá realizar ambas funciones. Los permisos concretos se definirán en la matriz de administración de la carrera.

### 14.5 Datos mínimos del sistema

Cada misión de ojeo debe registrar: identificador, tipo (profesional/juvenil), ojeador asignado, región o país, filtros, fecha de inicio, duración, coste, estado y candidatos descubiertos.

Cada informe debe registrar: jugador candidato, misión de origen, fecha, nivel de completitud, datos observados, rangos estimados, datos confirmados, observaciones y ojeador responsable.

Cada candidato debe poder añadirse a una lista de seguimiento con prioridad, notas internas y estado del proceso.

**Estado:** metodología de referencia aprobada por el usuario. Los límites numéricos, escalas, costes, duraciones, fórmulas de precisión y reglas económicas quedan pendientes de calibración. No se fija un máximo de ojeadores ni una escala definitiva por copiar los valores de FIFA.

## 15. Alcance del personal y fidelidad a FIFA 23

Esta sección aclara qué elementos corresponden realmente al Modo Carrera de FIFA 23 y cuáles son ampliaciones propias de Fútbol Nova. La referencia FIFA 23 se utiliza para reproducir métodos y flujos documentados, no para atribuirle puestos que no aparecen como personal contratable en ese modo.

### 15.1 Elementos documentados en FIFA 23 Modo Carrera

- **Mánager/entrenador:** figura central de la Carrera de mánager; toma decisiones sobre plantilla, alineación, entrenamientos, fichajes, relación con jugadores y objetivos de la directiva.
- **Ojeadores de jugadores profesionales:** se asignan a redes y reciben instrucciones de búsqueda por posición, edad, atributos/características y otros criterios. Los informes se completan progresivamente.
- **Ojeadores juveniles / personal de cantera:** se contratan y envían a misiones para descubrir jóvenes talentos; los informes incluyen estimaciones de nivel actual y potencial.
- **Analista de transferencias:** función del sistema de Carrera, no un empleado que el usuario contrate. Evalúa el impacto económico de las operaciones y el impacto del fichaje o venta sobre la plantilla y la profundidad por posición.
- **Directiva:** establece expectativas y evalúa el desempeño del mánager en ámbitos como resultados, finanzas, desarrollo juvenil y exposición de marca. No debe modelarse como un empleado individual del cuerpo técnico.

### 15.2 Funciones de FIFA 23 que Fútbol Nova debe reproducir como sistemas

- Red global de ojeo para profesionales.
- Red de captación juvenil y cantera.
- Instrucciones configurables de búsqueda.
- Experiencia y juicio diferenciados para los ojeadores.
- Informes parciales y completos con estimaciones que ganan precisión.
- Lista de seguimiento y paso de candidato a negociación.
- Evaluación económica de fichajes, ventas y cesiones.
- Evaluación del impacto deportivo de altas y bajas sobre la profundidad de plantilla.
- Evaluación de objetivos de directiva y estado de confianza.
- Visibilidad contextual de contratos próximos a vencer, profundidad de plantilla y jóvenes prometedores.

### 15.3 Ampliaciones propias de Fútbol Nova

Los siguientes puestos ya propuestos se mantienen como ampliaciones de Fútbol Nova inspiradas en la estructura real de un club profesional, pero no se afirmará que son puestos contratables del Modo Carrera de FIFA 23:
- Segundo entrenador, asistentes, preparadores físicos y entrenador de porteros.
- Médico, fisioterapeuta, rehabilitador y nutricionista.
- Director de ojeadores y analistas de rendimiento.
- Psicólogo deportivo y otros especialistas que se aprueben posteriormente.

Fútbol Nova podrá convertir estas ampliaciones en personal contratable con contratos, salarios, atributos, disponibilidad y efectos simulados. Cada efecto deberá tener reglas propias verificables y equilibradas.

### 15.4 Regla de documentación

En todas las futuras decisiones de personal:
1. Identificar primero si la función está presente en FIFA 23 Carrera.
2. Si está presente, documentar su flujo real y adaptarlo sin copiar recursos protegidos.
3. Si no está presente, marcarla explícitamente como ampliación de Fútbol Nova.
4. No convertir un sistema automático de FIFA (por ejemplo, el analista de transferencias) en un empleado contratable sin indicarlo como ampliación.
5. No introducir puestos ni efectos nuevos como confirmados hasta que el usuario los apruebe.

**Estado:** criterio de fidelidad a FIFA 23 aprobado como regla de trabajo. La lista de puestos ampliados de Fútbol Nova se conserva como propuesta de diseño; no implica que FIFA 23 permita contratarlos.

## 16. Referencia ampliada: EA SPORTS FC 26 Modo Carrera

A partir de esta actualización, FIFA 23 deja de ser la única referencia. Fútbol Nova utilizará también EA SPORTS FC 26 como referencia de sistemas y evolución del Modo Carrera. Cuando una función exista en ambos, se tomará como base la versión más completa y reciente; cuando difieran, se documentará la diferencia antes de decidir qué adaptación corresponde.

### 16.1 Personal técnico y gestión de entrenadores

- **Mercado de entrenadores:** contemplar movimientos dinámicos de entrenadores entre clubes, cambios de puesto y decisiones de contratación o destitución de los clubes controlados por la IA.
- **Perfil del entrenador:** registrar identidad, historial, visión y enfoque táctico, compatibilidad con la filosofía del club y valoración interna dinámica cuando el sistema la utilice.
- **Ascenso del segundo entrenador:** permitir que un asistente pueda asumir temporal o permanentemente el puesto principal cuando las circunstancias de la carrera lo justifiquen.
- **Contratación de entrenadores por departamentos:** organizar el personal técnico por áreas deportivas y permitir contratar, transferir o reasignar entrenadores.
- **Conocimiento táctico:** modelar el conocimiento del entrenador en relación con los sistemas, tácticas y roles que domina.
- **Desarrollo de futbolistas:** el personal técnico puede acelerar el desarrollo de atributos vinculados a su departamento y, cuando se aplique el sistema de roles, ayudar a mejorar la familiaridad de los jugadores con roles tácticos compatibles.
- **Progresión del personal:** permitir que la experiencia, resultados y uso del personal contribuyan a su crecimiento profesional, sin fijar todavía fórmulas ni escalas.

### 16.2 Ojeo y análisis basado en datos

- Los informes de ojeadores de jugadores profesionales y juveniles deberán incluir también una estimación del potencial, expresada como rango mientras exista incertidumbre.
- En ligas que el juego simule con mayor profundidad, conservar estadísticas de temporadas anteriores para contextualizar el rendimiento.
- Las estadísticas históricas podrán apoyar la evaluación de fichajes, la detección de jugadores revelación y el análisis de regularidad.
- Desde un informe de ojeo se podrá consultar la ficha estadística completa del jugador cuando los datos estén disponibles.
- Las estadísticas de jugadores deberán poder filtrarse por temporada y competición e incluir calificaciones medias cuando corresponda.
- Las evaluaciones deberán distinguir entre datos observados, históricos, estimados y potencial proyectado.

### 16.3 Simulación del mundo futbolístico

- Al crear una carrera, permitir configurar qué ligas adicionales tendrán simulación detallada, además de la competición principal.
- Como referencia de FC 26, contemplar hasta cinco ligas adicionales seleccionables; este límite es una referencia de diseño y podrá modificarse si las pruebas de rendimiento de Fútbol Nova lo requieren.
- La profundidad de simulación afectará a la disponibilidad de estadísticas, seguimiento de jugadores, actividad del mercado y evolución de clubes y entrenadores.
- Los clubes controlados por la IA podrán cambiar de entrenador y adaptar su enfoque táctico de acuerdo con el nuevo técnico.
- Mantener una simulación reducida para ligas no seleccionadas, si es necesaria para el rendimiento, sin presentar estadísticas inexistentes como datos completos.

### 16.4 Eventos y cambios de contexto

- Incorporar eventos inesperados de carrera que puedan afectar al club a corto o largo plazo, por ejemplo problemas financieros, lesiones acumuladas o situaciones internas.
- Los eventos deberán ser configurables al crear la carrera y sus consecuencias deberán explicarse antes de que el usuario tome decisiones importantes.
- El sistema podrá generar cambios en objetivos, presupuesto, disponibilidad de jugadores y estabilidad del puesto del entrenador, siempre respetando las reglas de la partida.

### 16.5 Regla de prioridad entre referencias

1. EA SPORTS FC 26 será la referencia principal para las funciones de Carrera que estén documentadas en su versión.
2. FIFA 23 seguirá siendo referencia complementaria para sistemas que FC 26 no haya sustituido o que estén mejor documentados allí.
3. Las funciones de FC 25, como familiaridad de roles y conocimiento táctico del cuerpo técnico, solo se incorporarán como continuidad cuando sean compatibles con la documentación y funcionamiento de FC 26; se marcarán como heredadas o pendientes de verificación si no hay confirmación explícita.
4. Las ampliaciones propias de Fútbol Nova se etiquetarán como tales.
5. No copiar nombres comerciales, textos, interfaz, código ni recursos protegidos de EA.

**Estado:** FC 26 aprobado como referencia adicional y prioritaria para el Modo Carrera. Los sistemas descritos quedan documentados como requisitos de diseño; los límites, fórmulas, escalas y costes de Fútbol Nova se definirán y probarán por separado.

## 17. Base deportiva modular, ligera y operación offline

La instalación principal de Fútbol Nova priorizará un tamaño reducido. Incluirá solo un conjunto pequeño de ligas ficticias y **ninguna selección nacional**. El resto del contenido se distribuirá en módulos opcionales descargables. El objetivo de escala de **20.000 o más futbolistas ficticios** se refiere al catálogo ampliable del juego y sus módulos, no a la cantidad que deba instalarse de inicio.

### 17.1 Contenido de la instalación principal
- Incluir exactamente **10 ligas nacionales ficticias** en la instalación principal, una inspirada en la estructura deportiva de cada país elegido por el usuario: **Cuba, España, Francia, Italia, Alemania, Portugal, Inglaterra, Brasil, Estados Unidos y Argentina**.
- Esta lista queda fijada como las diez ligas del paquete base; no sustituir países ni añadir una selección nacional al paquete inicial sin autorización del usuario.
- Cada liga reproducirá, tras documentar y verificar sus reglas vigentes, el formato deportivo propio de su competición de referencia: número de participantes, calendario, puntuación, desempates, fases o grupos, playoffs, ascensos/descensos y clasificación a torneos continentales cuando corresponda. No imponer un número uniforme de clubes ni un formato idéntico a todas.
- Los clubes, jugadores, escudos, nombres comerciales y demás elementos identificativos serán ficticios y originales, salvo que Nova obtenga autorización o licencia.
- **Regla universal de nombres regionales:** el nombre visible de cada club debe incluir el nombre reconocible de la región geográfica a la que pertenece. Se aplicará a todos los clubes de las diez ligas base y a los clubes de cualquier módulo futuro.
- La región podrá ser una provincia, comunidad autónoma, departamento, estado, ciudad u otra división territorial pertinente al país y a la identidad del club. Se utilizará la división geográfica adecuada, sin imponer una misma clase de región a todos los países.
- Si existen varios clubes de una misma región, cada uno deberá conservar el nombre regional y añadir un distintivo ficticio para diferenciarlo; no se eliminará ni abreviará la referencia regional hasta hacerla irreconocible.
- Los nombres serán originales y no copiarán denominaciones comerciales o marcas de clubes reales. La asociación geográfica no implica licencia ni afiliación con una entidad real. La referencia al país y a las reglas competitivas no autoriza copiar marcas, identidades ni bases de datos oficiales.
- **Regla de denominación de clubes para las diez ligas:** cada club llevará el nombre de la región geográfica a la que representa o pertenece (por ejemplo, provincia, ciudad o región, según la organización territorial y futbolística del país). Esta regla se aplicará por igual a Cuba, España, Francia, Italia, Alemania, Portugal, Inglaterra, Brasil, Estados Unidos y Argentina. Los nombres y distintivos serán originales y no copiarán marcas de clubes reales.
- No instalar ni habilitar selecciones nacionales en el paquete inicial.
- La cantidad de clubes y jugadores por liga se ajustará a las reglas verificadas de cada competición y se optimizará para el tamaño de descarga, memoria y rendimiento en Android.
- El paquete principal debe contener todos los datos y recursos esenciales para jugar sus competiciones sin conexión.
- No descargar datos adicionales silenciosamente ni exigir conexión durante el inicio o el juego.

### 17.2 Módulos de contenido descargable
- Cada liga o conjunto de ligas podrá distribuirse como un módulo independiente.
- Las selecciones nacionales se distribuirán mediante módulos específicos de selecciones; ninguna se incluirá por defecto en la instalación principal.
- Los módulos podrán incluir los datos estrictamente necesarios: competición, clubes o selecciones, plantillas, jugadores, calendarios, reglas, recursos visuales y dependencias declaradas.
- El usuario podrá elegir qué módulos descargar e instalar; podrá conservar solo los que utilice.
- Cada módulo declarará identificador único, versión, tamaño, contenido, dependencias, compatibilidad con la versión del juego y procedencia.
- La instalación, actualización, desactivación y eliminación de módulos deberá validar dependencias y proteger las partidas guardadas.
- Si una carrera utiliza contenido de un módulo que luego no está disponible, el juego informará qué contenido falta y ofrecerá reinstalarlo; nunca borrará ni corromperá el guardado.
- La descarga requiere conexión, pero una vez instalado el módulo, su contenido jugable funcionará sin Internet.

### 17.3 Originalidad de los datos
- Todos los jugadores deben ser personajes ficticios originales, no versiones renombradas de futbolistas reales.
- Crear nombres, apellidos, fechas de nacimiento, nacionalidades, rasgos físicos, perfiles, atributos, historiales y estadísticas originales.
- No reutilizar fotografías, escaneos faciales, likeness, biografías, ratings ni datos extraídos de bases de datos propietarias.
- Evitar combinaciones de nombre, nacionalidad, club, posición y atributos que hagan que un jugador ficticio sea identificable como una persona real.
- Los clubes, selecciones, ligas, estadios, equipaciones y competiciones también deberán ser originales o estar debidamente autorizados; las denominaciones y marcas protegidas no se copian sin licencia.
- No duplicar identidades al distribuir jugadores entre módulos. Cada futbolista tendrá un ID estable y único, aunque aparezca cedido o inscrito en más de una competición.

### 17.4 Catálogo ampliable de jugadores
- El catálogo completo, sumando la instalación principal y los módulos disponibles, tendrá como objetivo de planificación **20.000 o más futbolistas ficticios**.
- Los jugadores se repartirán entre primeros equipos, reservas, cantera y agentes libres de las ligas y módulos que realmente existan.
- Las selecciones solo tendrán plantillas cuando el módulo correspondiente esté instalado.
- Definir proporciones por región, liga, edad y posición en un plan de generación separado; no inventar una distribución final antes de aprobarla.
- Fútbol Nova no utilizará competiciones femeninas. No se crearán ligas, copas, torneos ni módulos de competiciones femeninas.
- La generación procedural debe producir perfiles plausibles y variados, evitando plantillas repetitivas o atributos idénticos en masa.
- La meta de 20.000+ no significa que todos los registros deban cargarse en memoria: usar índices y carga bajo demanda.

### 17.5 Datos locales y funcionamiento sin Internet
- La instalación principal y cada módulo instalado se almacenarán localmente.
- Las consultas de jugadores, plantillas, atributos, contratos, estadísticas e historial no dependerán de una API remota.
- Las carreras podrán crear jugadores juveniles ficticios localmente y persistir su evolución en el guardado.
- El mercado, cesiones, retiros, generación de juveniles y cambios de club serán simulados por la lógica local.
- No habrá comprobaciones online obligatorias, DRM dependiente de red ni bloqueo por perder conexión.
- Las funciones de sincronización o servicios online serán opcionales y nunca bloquearán el juego base ni el contenido ya instalado.
- El formato de datos tendrá versión, validación, migraciones y mecanismos de recuperación ante archivos dañados.

### 17.6 Rendimiento y almacenamiento
- Mantener el paquete inicial reducido y separar los datos de cada módulo para que no sea necesario instalar ligas o selecciones no deseadas.
- Usar carga bajo demanda, índices por ID/club/posición/edad/competición y consultas paginadas para evitar cargar todos los perfiles detallados en memoria.
- Separar datos estáticos del catálogo (identidad, atributos base, nacionalidad) de datos dinámicos de carrera (forma, condición, contrato, lesión, estadísticas y progresión).
- Mantener los recursos visuales de gran tamaño separados de los registros tabulares; permitir variantes visuales ligeras o generación procedural cuando sea apropiado.
- Medir tamaño de instalación, RAM, tiempo de búsqueda, carga de plantillas y guardado tanto con el paquete principal como con varios módulos instalados.
- La meta de 20.000+ solo se considerará cumplida cuando exista un catálogo completo, sin duplicados, validado y probado; el tamaño final del paquete inicial se medirá por separado.

**Estado:** quedan aprobadas las diez ligas nacionales del paquete base (Cuba, España, Francia, Italia, Alemania, Portugal, Inglaterra, Brasil, Estados Unidos y Argentina), sin selecciones nacionales ni competiciones femeninas. La documentación y verificación de las reglas vigentes de cada competición, los clubes ficticios, los módulos adicionales, el tamaño de cada paquete y el catálogo ampliable de 20.000+ jugadores siguen pendientes de planificación y pruebas.


## 18. Liga Nacional de Fútbol de Cuba — formato documentado de referencia (edición 2025)

**Alcance y cautela:** esta ficha reproduce el formato observado y documentado para el Campeonato Nacional de Liga de Cuba 2025 (109.ª edición). No debe presentarse automáticamente como reglamento vigente de 2026 ni como formato invariable de otras temporadas. Antes de etiquetar una temporada del juego como oficial/vigente, se deberá contrastar con el reglamento o convocatoria oficial de esa edición. Las fuentes consultadas describen el formato y los resultados, pero no proporcionan el texto íntegro de todas las disposiciones reglamentarias.

### 18.1 Participantes y fase de Apertura
- Participaron 16 equipos representativos de las provincias y territorios cubanos, distribuidos en cuatro grupos de cuatro equipos según proximidad geográfica.
- La fase de grupos se disputó en formato de todos contra todos dentro de cada grupo, con calendario de ida y vuelta ampliado a cuatro enfrentamientos por pareja: 12 partidos programados por equipo, seis como local y seis como visitante.
- La clasificación produjo cuatro ganadores de grupo y cuatro segundos puestos.
- Los cuatro ganadores de grupo obtuvieron plaza para el Clausura.
- Los dos mejores ganadores de grupo disputaron el título del Apertura en un único partido.
- Los cuatro segundos puestos disputaron dos eliminatorias Play-In: segundo del grupo A contra segundo del B, y segundo del C contra segundo del D. Cada eliminatoria se jugó a doble partido. En el empate global documentado entre Ciego de Ávila y Santiago de Cuba se resolvió directamente mediante tanda de penaltis, sin prórroga. No generalizar esta disposición a otras ediciones sin verificar su convocatoria.

### 18.2 Fase Clausura
- Participaron seis equipos: los cuatro ganadores de grupo del Apertura y los dos vencedores del Play-In.
- Se disputó una liguilla de una sola vuelta, todos contra todos, con cinco partidos por equipo.
- Los dos primeros de la tabla clasificaron a la final del Clausura.
- Los equipos situados tercero y cuarto disputaron un partido por el tercer puesto.
- La final y el partido por el tercer puesto se documentan a partido único. El partido por el tercer puesto de 2025 terminó empatado y se resolvió por penaltis.

### 18.3 Datos reglamentarios que no deben inventarse
- Las fuentes consultadas no permiten certificar el texto oficial completo sobre puntuación, orden íntegro de desempates, sanciones administrativas, inscripción de jugadores, sustituciones, criterios disciplinarios, calendario de fechas ni reglas de ascenso/descenso.
- En 2025 se observan decisiones de desempate por enfrentamientos directos en tablas de grupo; un proveedor de resultados enumera diferencia de goles, goles a favor y victorias como criterios generales, pero no se ha localizado una convocatoria oficial que confirme el orden normativo completo. Por tanto, el motor no debe fijar un orden de desempate definitivo basándose únicamente en esa fuente secundaria.
- No se ha confirmado un sistema de ascenso/descenso para esta edición. No crear divisiones inferiores ni ascensos/descensos ficticios como si fueran reglas oficiales.
- Cuando falte una regla oficial verificable, la ficha de la competición la marcará como **pendiente de verificación**. No se rellenarán vacíos con reglas genéricas de otras ligas.

### 18.4 Adaptación de datos a Fútbol Nova
- Los participantes del juego serán clubes ficticios originales que representen las regiones/territorios correspondientes, conforme a la regla global de nombres regionales. La estructura territorial y el formato competitivo no autorizan copiar marcas, escudos, plantillas ni identidades comerciales reales.
- La identidad ficticia de los clubes no alterará el número de participantes, la composición de grupos, el calendario, el sistema de clasificación ni las fases descritas para la edición de referencia.
- Los nombres de los grupos y las relaciones territoriales se documentarán junto con la temporada concreta. La asignación geográfica deberá ser coherente con la distribución regional utilizada por la competición de referencia.
- En la configuración de esta liga oficial, el jugador podrá personalizar únicamente opciones permitidas por el reglamento o ajustes de experiencia ajenos a la integridad competitiva. No podrá cambiar el número de equipos, grupos, partidos, rondas, clasificación ni formato de las finales.
- Una versión con estructura modificada solo podrá ofrecerse como torneo personalizado y nunca como Campeonato Nacional de Cuba oficial.

**Estado:** formato 2025 documentado como referencia histórica. Reglamento íntegro y vigencia para temporadas posteriores pendientes de confirmación oficial. No implica implementación ni cambios de pantallas, escenas o navegación.


## 19. Liga española de Primera División — reglamento y calendario oficial 2026/2027

**Fuente normativa principal:** Circular RFEF n.º 84, temporada 2026/2027, que publica las Normas Reguladoras y Bases de Competición de Primera y Segunda División, aprobadas el 18 de junio de 2026 y notificadas el 30 de junio de 2026. **Fuente de calendario:** calendario oficial de Primera División publicado por la RFEF el 30 de junio de 2026. Esta ficha identifica expresamente la temporada utilizada; no se deben reutilizar sus fechas como si fueran las de temporadas futuras.

### 19.1 Formato de Primera División
- 16 clubes participantes en un único grupo.
- 30 jornadas.
- Sistema de liga a doble vuelta: cada club se enfrenta dos veces a cada rival, una como local y otra como visitante.
- Puntuación: tres puntos por victoria, uno por empate y cero por derrota.
- El club que termine primero es campeón.
- Los clubes clasificados en los puestos 18.º, 19.º y 20.º descienden a Segunda División.
- Las plazas de clasificación para competiciones UEFA se asignan conforme al número y los criterios que establezca la normativa UEFA aplicable a esa temporada; no fijar plazas permanentes en los datos del juego.

### 19.2 Desempates al final del campeonato
**Empate entre dos clubes**, en este orden excluyente:
1. Mayor diferencia de goles en los partidos disputados entre los dos clubes.
2. Mayor diferencia de goles en el total de la competición.
3. Mayor número de goles a favor en el total de la competición.
4. Mejor clasificación en los criterios de juego limpio.
5. Partido de desempate en campo neutral designado por la RFEF, oído el parecer de LALIGA y de los clubes afectados.

**Empate entre más de dos clubes**, en este orden excluyente:
1. Mejor puntuación obtenida en los partidos disputados únicamente entre los clubes empatados.
2. Mayor diferencia de goles en esos enfrentamientos directos.
3. Mayor diferencia de goles en el total de la competición.
4. Mayor número de goles a favor en el total de la competición.
5. Mejor clasificación en los criterios de juego limpio.
6. Partido de desempate en campo neutral designado por la RFEF, oído el parecer de LALIGA y de los clubes afectados.

La aplicación de los criterios debe seguir el orden y las condiciones de la Circular 84, sin sustituirlos por reglas de otras ligas.

### 19.3 Calendario oficial de referencia 2026/2027
- Inicio programado: **16 de agosto de 2026**, Jornada 1.
- Última jornada programada: **30 de mayo de 2027**, Jornada 38.
- El calendario publicado por la RFEF distribuye las 38 jornadas entre esas fechas e incluye jornadas intersemanales y pausas. El juego deberá almacenar la fecha oficial de cada jornada, no generar intervalos semanales uniformes.
- La fecha de cada encuentro y su horario pueden estar sujetos a ajustes oficiales. Las modificaciones publicadas por RFEF/LALIGA prevalecerán sobre el calendario inicial.
- Para una carrera iniciada en otra temporada, el motor deberá cargar el calendario oficial de esa temporada cuando esté publicado. No debe desplazar el inicio al día en que el usuario crea la partida ni inventar un calendario alternativo.

### 19.4 Datos de clubes y adaptación ficticia
- Fútbol Nova utilizará 20 clubes ficticios originales para representar la estructura de la Primera División.
- Cada nombre visible incluirá una referencia reconocible a su región geográfica, conforme a la regla universal de nombres regionales. Si hay varios clubes de una misma región, cada uno tendrá un distintivo ficticio adicional.
- La ficción de nombres, escudos, jugadores y recursos no cambia las 20 plazas, el formato de 38 jornadas, el sistema de puntos, el calendario ni las reglas clasificatorias.
- No se copiarán nombres comerciales, escudos, plantillas, fotografías, marcas ni otros elementos protegidos de clubes reales.
- La asignación de los 20 clubes ficticios a las plazas deportivas debe conservar la estructura de calendario de la competición, sin presentar identidades ficticias como clubes reales.

### 19.5 Configuración permitida en el modo Ligas
- Antes de iniciar, el jugador podrá configurar únicamente detalles permitidos por las bases oficiales o que no alteren la integridad de la competición, como dificultad, controles, cámara y presentación.
- No podrá cambiar participantes, número de jornadas, ida y vuelta, puntuación, criterios de desempate, fechas oficiales, ascensos/descensos ni plazas clasificatorias.
- Cualquier competición con reglas alteradas deberá identificarse como torneo personalizado y no como Primera División española oficial.

**Estado:** formato, sistema de puntos, criterios de desempate, descenso y fechas de referencia 2026/2027 documentados a partir de la normativa y el calendario oficiales publicados. Las fechas y reglas de cada temporada futura deberán actualizarse únicamente desde sus publicaciones oficiales. No implica implementación ni cambios de pantallas, escenas o navegación.


## 20. Registro maestro de ligas y copas oficiales — investigación conjunta

**Regla de aplicación:** este registro centraliza las diez ligas nacionales del paquete base y las copas nacionales principales asociadas. Los datos de una temporada solo se consideran definitivos cuando proceden del reglamento y calendario oficiales de esa misma edición. Una página informativa o un calendario general no sustituye las bases completas de competición. Los elementos no confirmados permanecen pendientes; no se completan mediante suposiciones.

### 20.1 España
- **Liga base:** Primera División. La ficha de la sección 19 documenta como referencia 2026/2027 el formato de 20 clubes, 38 jornadas, ida/vuelta, puntuación, desempates, descensos y calendario.
- **Copa principal:** Copa de S.M. el Rey. Deben cargarse las bases de competición de la RFEF de la temporada correspondiente: equipos admitidos, rondas, exenciones, sorteo, sede/localía, partido único o doble partido, prórroga, penaltis y final. El calendario general RFEF 2026/2027 está publicado, pero el reglamento específico de la Copa debe vincularse por separado antes de cerrar la ficha.
- Fuente oficial de calendario general: https://rfef.es/es/noticias/Spanish-football-unveils-the-calendars-for-the-2026-27-season

### 20.2 Francia
- **Liga base:** Ligue 1. Para 2026/2027 el calendario oficial publicado por LFP establece inicio el 21 de agosto de 2026, 34.ª y última jornada el 29 de mayo de 2027, pausa invernal tras la jornada 14, reanudación en jornada 15 y play-off de permanencia/promoción entre el 16.º de Ligue 1 y el ganador de los play-offs de Ligue 2 a doble partido los días 3 y 6 de junio de 2027. El calendario de partidos está publicado; el reglamento completo debe regir número de clubes, puntos, desempates, descenso y elegibilidad.
- **Copa principal:** Coupe de France. Pendiente de vincular las bases FFF 2026/2027 completas y su calendario de rondas; no inferir el formato desde temporadas anteriores.
- Fuentes oficiales: https://www.lfp.fr/article/ligue-1-mc-donald-s-le-calendrier-de-la-saison-2026-2027 y https://ligue1.com/en/articles/l1_article_3812-

### 20.3 Italia
- **Liga base:** Serie A. El calendario oficial 2026/2027 fija inicio el 23 de agosto de 2026 y final el 30 de mayo de 2027. La composición, número de clubes, sistema de puntos, desempates, descenso y clasificación europea se deben tomar de las Norme Organizzative Interne Federali y del reglamento de competición de la temporada, no deducirse únicamente de las fechas.
- **Copa principal:** Coppa Italia Frecciarossa. Fechas oficiales 2026/2027 publicadas: preliminar 9 de agosto de 2026; treintaidosavos 16 de agosto; dieciseisavos 2 de septiembre (fecha de reserva 15 de septiembre); octavos 2 y 16 de diciembre (reserva 13 de enero); cuartos 3 y 10 de febrero de 2027; semifinales ida 3 de marzo y vuelta 21 de abril; final 19 de mayo de 2027. El reglamento de la edición determina participantes, emparejamientos, localía y resolución de empates.
- Fuentes oficiales: https://www.legaseriea.it/serie-a/news/le-date-della-stagione-2026-2027 y https://images.legaseriea.it/image/private/fl_attachment/prd/gereett2fnj7hcgsmgfi.pdf

### 20.4 Alemania
- **Liga base:** Bundesliga. El calendario oficial 2026/2027 anuncia el primer partido para el 28 de agosto de 2026 y publica el listado completo de encuentros. El reglamento DFL de la temporada debe confirmar formalmente número de participantes, jornadas, puntos, desempates, descenso y promoción.
- **Copa principal:** DFB-Pokal. El modo oficial de DFB establece 64 participantes y eliminatorias; los partidos empatados tras el tiempo reglamentario se deciden con prórroga de dos tiempos de 15 minutos y, si persiste el empate, tanda de penaltis. El cuadro inicial combina clubes de Bundesliga/2. Bundesliga con equipos amateurs clasificados, bajo reglas de sorteo y localía descritas por DFB. Fechas marco 2026/2027: primera ronda 21–24 de agosto y 1–2 de septiembre de 2026; segunda ronda 27–28 de octubre; octavos 1–2 de diciembre; cuartos 2–3 y 9–10 de febrero de 2027; semifinales 20–21 de abril; final 29 de mayo de 2027.
- Fuentes oficiales: https://www.bundesliga.com/en/bundesliga/news/2026-27-fixture-lists-now-available-38068, https://www.dfb.de/maenner/wettbewerbe/dfb-pokal/modus y https://www.dfb.de/maenner/wettbewerbe/dfb-pokal/rahmentermine

### 20.5 Portugal
- **Liga base:** Liga Portugal Betclic. Liga Portugal publica el Comunicado Oficial 01 de 2026/2027, el Regulamento das Competições y el calendario oficial de las competiciones profesionales. La documentación de temporada debe consultarse conjuntamente; no fijar participantes, puntos, desempates, descensos o play-offs hasta incorporar las disposiciones exactas de esos documentos.
- **Copas:** Taça de Portugal y Taça da Liga. Se deben documentar por separado desde los reglamentos oficiales FPF/Liga Portugal de 2026/2027, incluidos acceso, rondas, sorteo, localía, desempates y calendario. No tratar sus formatos como intercambiables.
- Fuentes oficiales: https://www.ligaportugal.pt/pages/estatutos-regulamentos y https://www.ligaportugal.pt/backoffice/assets/Comunicado_Oficial_n_357_Calendarios_das_Competicoes_Profissionais_2026_27_3b82c06381.pdf

### 20.6 Inglaterra
- **Liga base:** Premier League. La temporada 2026/2027 consta de 380 partidos: 20 clubes juegan contra cada uno de los otros 19 dos veces, una en casa y otra fuera. El calendario oficial publicado comienza el viernes 21 de agosto de 2026. Las fechas de los partidos pueden cambiar por programación oficial; el juego debe incorporar las modificaciones verificadas. El reglamento completo de temporada determina puntos, desempates, descenso y clasificación europea.
- **Copa principal:** Emirates FA Cup. Fechas oficiales 2026/2027: ronda extra preliminar 8 de agosto de 2026; preliminar 22 de agosto; clasificatorias 5 y 19 de septiembre, 3 y 17 de octubre; primera ronda propiamente dicha 7 de noviembre; segunda 5 de diciembre; tercera 9 de enero de 2027; cuarta 13 de febrero; quinta 6 de marzo; cuartos 3 de abril; semifinales 24 de abril; final 22 de mayo. La inclusión de clubes y las reglas de repetición/prórroga/penaltis se regirán por las reglas de FA de la edición.
- Fuentes oficiales: https://www.premierleague.com/en/news/4675097/all-380-fixtures-for-2026-27, https://www.premierleague.com/en/news/4324541/how-the-premier-league-fixture-list-is-compiled y https://www.thefa.com/competitions/thefacup/round-dates

### 20.7 Brasil
- **Liga base:** Campeonato Brasileiro Série A. La CBF anunció para 2026 inicio el 28 de enero, final el 2 de diciembre y mantenimiento del formato vigente. Para programar una temporada de Fútbol Nova deben incorporarse el REC (Regulamento Específico da Competição), la tabela básica y el calendario oficial de esa edición; el anuncio de fechas por sí solo no basta para certificar número de participantes, rondas, desempates, descenso y clasificación continental.
- **Copa principal:** Copa do Brasil. La CBF publicó para 2026 un REC propio, plan general y tabla básica: 126 clubes, nueve fases, fechas base de primera fase 18 y 19 de febrero y final prevista para el 6 de diciembre de 2026. Deben aplicarse las reglas exactas del REC sobre entrada por fases, emparejamientos, localía y resolución de eliminatorias.
- Fuentes oficiales: https://www.cbf.com.br/a-cbf/por-dentro-da-cbf/informes-cbf/a/cbf-anuncia-novo-calendario-do-futebol-profissional-masculino y https://www.cbf.com.br/futebol-brasileiro/noticias/campeonato-brasileiro/serie-a/cbf-divulga-tabela-basica-plano-geral-de-acoes-e-regulamento-especifico-da-copa-do-brasil-2026

### 20.8 Argentina
- **Liga base:** Primera División / Torneos LPF. Existe un Reglamento de Torneos LPF 2026 publicado por AFA que debe tratarse como fuente normativa primaria de esa edición. Antes de completar el motor deben extraerse todos sus artículos y anexos, porque la estructura anual puede incluir más de una fase o torneo y no debe simplificarse a una liga europea de ida/vuelta.
- **Copa principal:** Copa Argentina. Pendiente de incorporar el reglamento y calendario oficial AFA de la edición concreta, con clasificación, rondas, sedes, prórroga/penaltis y fechas.
- Fuente normativa localizada: https://assets1.afa.com.ar/2026/BOLETINES/Boletin-Resoluciones-6818---Complementario-01---Reglamento-Torneos-LPF-Primera-2026.pdf

### 20.9 Estados Unidos
- **Liga base:** Major League Soccer (MLS). La competición debe modelarse a partir de las Competition Guidelines, calendario y reglamento oficiales de la temporada concreta. No aplicar automáticamente el formato de temporadas anteriores: el número de clubes, conferencias, calendario regular, clasificación a playoffs, series, desempates y final deben verificarse para cada edición.
- **Copas:** U.S. Open Cup y Leagues Cup solo se incorporarán si se define su inclusión en el catálogo de competiciones; sus reglamentos y participantes son independientes de MLS y no se deben simular como fases de la liga.
- **Estado de fuentes:** pendiente de incorporar documentación primaria MLS/US Soccer 2026 y calendario oficial completo antes de marcar esta ficha como cerrada.

### 20.10 Cuba
- **Liga base:** Campeonato Nacional de Fútbol. La sección 18 documenta la edición 2025 como referencia histórica: Apertura por grupos, Play-In y Clausura de seis equipos. No se ha confirmado aquí un reglamento íntegro ni un calendario oficial posterior que permita afirmar que el formato 2025 sigue vigente.
- **Copas:** no añadir una copa nacional como competición oficial hasta localizar convocatoria, reglamento y calendario oficial de la edición correspondiente.
- **Estado de fuentes:** pendiente de verificar el reglamento y calendario oficial de la temporada concreta; no extrapolar automáticamente la edición 2025.

### 20.11 Reglas comunes para las copas
- Cada copa tendrá su propio reglamento y calendario, independiente de la liga del mismo país.
- Se deben registrar todos los niveles de acceso, plazas, exenciones, rondas, sorteos, cabezas de serie, localía, ida/vuelta o partido único, prórroga, tanda de penaltis, reglas disciplinarias y criterios de desempate tal como figuren en las bases de esa edición.
- No se debe asumir que todas las copas usan el mismo formato ni que una eliminatoria empatada siempre tiene prórroga.
- Las fechas marco se almacenarán como calendario oficial; las fechas y horas de cada partido se actualizarán cuando el organismo publique los emparejamientos y la programación detallada.
- Si el calendario o reglamento cambia durante la temporada, la versión oficial más reciente prevalecerá y quedará registrada con fecha de actualización.

**Estado del registro:** investigación conjunta iniciada y fuentes primarias localizadas para las diez ligas base y varias copas nacionales. Las secciones con datos expresos de calendario/formato quedan documentadas como referencias de sus respectivas temporadas; las reglas completas de competición y las fuentes aún no verificadas permanecen explícitamente pendientes. Este registro no autoriza a presentar datos incompletos como reglas oficiales ni implica implementación en Godot.


## 21. Supercopas, trofeos equivalentes y copas de nueva creación

**Regla general:** el catálogo debe incluir todas las supercopas nacionales oficiales que correspondan a los diez países base, además de los trofeos oficiales equivalentes que la federación/organizador defina como títulos entre campeones. Cada edición se ejecutará con su reglamento específico, no con una plantilla genérica. Los participantes se calculan a partir de los campeones/subcampeones de las competiciones que indique el reglamento; si un mismo club ocupa varias plazas, se aplica exactamente el criterio oficial de sustitución. Las fechas y sedes solo se fijan cuando el organizador las publica.

### 21.1 España — Supercopa de España
- **Estado:** competición oficial confirmada.
- **Formato documentado por RFEF para la edición 2025/2026:** cuatro clubes: los dos finalistas de Copa del Rey y los dos primeros clasificados de Primera División; si hay duplicidad, se mantienen los finalistas de Copa y las plazas de liga pasan a los siguientes clasificados hasta completar cuatro.
- **Sistema:** Final Four, dos semifinales y final, todas a partido único. Empate al final del tiempo reglamentario: tanda de cinco penaltis por equipo; si persiste, muerte súbita. No se añade prórroga en la regla localizada.
- **Pendiente:** sustituir/confirmar estas bases con las circulares RFEF específicas de cada edición posterior antes de marcarla como vigente.
- Fuente oficial: https://rfef.es/sites/default/files/pdf/circulares/102_con_anexos_20250624.pdf

### 21.2 Francia — Trophée des Champions
- **Estado:** competición oficial confirmada.
- **Participantes según el reglamento LFP localizado:** campeón de Ligue 1 de la temporada anterior y campeón de Coupe de France. Si el mismo club gana ambas, participa el segundo de Ligue 1. Si el campeón de Copa no es profesional o sus compromisos europeos impiden disputar el partido, la plaza se asigna al segundo de Ligue 1.
- **Sistema localizado:** un partido, normalmente en campo neutral; 90 minutos y, si hay empate, tanda de penaltis directa, sin prórroga. El campeón de liga figura como equipo local a efectos organizativos.
- **Pendiente:** validar el reglamento LFP específico de la edición 2026/2027 y registrar fecha/sede oficiales de esa edición. La página LFP de 2026/2027 confirma la continuidad del Trophée des Champions, pero no sustituye las bases completas.
- Fuentes: https://www.lfp.fr/assets/24_25_Reglement_Trophee_Champions_25_06_2024_d634c79a20.pdf y https://www.lfp.fr/article/la-lfp-et-decathlon-devoilent-le-ballon-du-trophee-des-champions-2026

### 21.3 Italia — Supercoppa Italiana
- **Estado:** competición oficial confirmada; el formato puede cambiar por edición.
- **Formato de cuatro equipos documentado por Lega Serie A:** campeones y subcampeones de Serie A y Coppa Italia; cuando coinciden plazas, se incorporan los siguientes equipos mejor clasificados de Serie A. Ese formato consta de dos semifinales y una final en tres días.
- **Edición 2026:** anuncio oficial de partido único entre Inter y Lazio el 22 de diciembre de 2026 en San Siro. En caso de empate tras 90 minutos, se juegan dos tiempos extra de 15 minutos y, si persiste, penaltis.
- **Regla de implementación:** el motor no debe fijar permanentemente ni el formato de cuatro equipos ni el partido único; debe leer la normativa/decisión oficial de cada edición.
- Fuentes: https://img.legaseriea.it/vimages/64ca8e48/INTERNATIONAL%20MEDIA%20RIGHTS_GENERAL%20TERMS%20AND%20CONDITIONS%20OF%20THE%20LICENSE%20AGREEMENT.pdf y https://www.inter.it/en/news/supercoppa-italiana-inter-lazio-22-december-2026-san-siro

### 21.4 Alemania — DFL-Supercup
- **Estado:** competición oficial confirmada.
- **Participantes:** campeón alemán de Bundesliga y ganador de DFB-Pokal de la temporada anterior. Si un mismo club gana ambos títulos, participa el subcampeón de Bundesliga.
- **Sistema:** un partido; sede y fecha fijadas por DFL. Empate al final del tiempo reglamentario: penaltis directos, sin prórroga.
- **Regla disciplinaria específica localizada:** las tarjetas amarillas de este partido no se registran para generar suspensiones.
- Fuente oficial: https://media.dfl.de/sites/2/2026/03/Spielordnung-SpOL-2026-03-06-Stand.pdf (Spielordnung DFL, §7, versión 06-03-2026).

### 21.5 Portugal — Supertaça Cândido de Oliveira
- **Estado:** competición oficial confirmada.
- **Participantes 2026/2027:** campeón del Campeonato Nacional da I Divisão y ganador de Taça de Portugal de la temporada anterior. Si un club gana ambas, se enfrenta al finalista derrotado de Taça de Portugal. Si un clasificado no cumple requisitos o renuncia, se aplican los reemplazos del artículo 11 del reglamento FPF.
- **Sistema:** partido único en recinto neutral, fecha y hora fijadas por FPF.
- **Desempate:** 30 minutos de prórroga (dos partes de 15); si continúa el empate, tanda de penaltis.
- **Fuentes oficiales:** https://www.fpf.pt/DownloadDocument.ashx?id=32632 (Regulamento Supertaça 2026/2027, arts. 9–14).

### 21.6 Inglaterra — FA Community Shield
- **Estado:** competición oficial confirmada.
- **Participantes:** campeón de la Premier League de la temporada anterior y titular de la FA Cup. Si el campeón de liga también gana la FA Cup, se aplica la plaza de sustitución prevista por FA; el reglamento oficial permite a FA determinar otro club si procede.
- **Sistema:** partido único al inicio o cerca del inicio de la temporada doméstica; sede y fecha las determina The FA. Duración 90 minutos; empate: penaltis directos, sin prórroga.
- **Equipación:** el reglamento obliga a usar la equipación local salvo similitud/confusión; entonces se usa visitante o combinación, con sorteo si no hay acuerdo. Este principio deportivo no concede derechos de reproducción de escudos o uniformes.
- **Fuente oficial:** https://www.thefa.com/~/media/978792AF8BBE4927AA4583437A7DF882.ashx (Rules of the Football Association Community Shield, reglas 9–26). La fecha y sede de cada edición se verificarán en el anuncio anual de FA.

### 21.7 Brasil — Supercopa do Brasil / Supercopa Rei
- **Estado:** competición oficial confirmada.
- **Participantes edición 2026:** campeón del Campeonato Brasileiro Série A 2025 y campeón de Copa do Brasil 2025. Si un mismo club obtiene ambas plazas, participa el subcampeón de Série A.
- **Sistema 2026:** partido único. Empate: tanda de penaltis directa, sin prórroga. La CBF determina sede y organización.
- **Regla de implementación:** aplicar el REC de cada temporada, ya que plazas, elegibilidad y detalles pueden variar.
- **Fuente oficial:** https://stcbfsiteprdimgbrs.blob.core.windows.net/img-site/cdn/REC_SUPERCOPA_DO_BRASIL_2026_8634b6b9ec.pdf (REC Supercopa do Brasil 2026, arts. 1–11).

### 21.8 Argentina — Supercopa Argentina, Supercopa Internacional y Trofeo de Campeones
- **Estado:** el reglamento AFA/LPF 2026 reconoce expresamente las tres competiciones/títulos relacionados; no reducirlas a una sola supercopa.
- **Supercopa Argentina 2027 (reglamento LPF 2026):** un partido en cancha neutral entre el campeón del Trofeo de Campeones LPF 2026 y el campeón de Copa Argentina 2026. Si coinciden, participa el subcampeón del Trofeo de Campeones. Empate tras 90 minutos: prórroga de 30 minutos (dos tiempos de 15) y después penaltis.
- **Supercopa Internacional 2027:** partido único en estadio neutral internacional entre el campeón del Trofeo de Campeones LPF 2026 y el Campeón de Liga 2026. Si coinciden, participa el segundo equipo de la Tabla General 2026. Empate: 30 minutos de prórroga y luego penaltis. La condición organizativa de local corresponde al campeón del Trofeo de Campeones.
- **Trofeo de Campeones 2026:** final única entre campeones del Apertura y Clausura 2026; si un mismo club gana ambos, aplicar el mecanismo de desempate/reemplazo del propio reglamento, no inventar un rival.
- **Recopa de Campeones:** el reglamento 2026 prevé una serie de tres partidos entre los campeones de Supercopa Argentina, Supercopa Internacional y Copa Argentina. Registrar como competición oficial LPF diferenciada y seguir su artículo 31.
- **Fuente oficial:** https://assets1.afa.com.ar/2026/BOLETINES/Boletin-Resoluciones-6818---Complementario-01---Reglamento-Torneos-LPF-Primera-2026.pdf (arts. 20–23 y 29–31).

### 21.9 Estados Unidos — sin supercopa nacional doméstica equivalente confirmada
- **Copa nacional oficial:** Lamar Hunt U.S. Open Cup; se mantiene como copa nacional, con formato propio de cada edición.
- **Campeones Cup:** competición oficial internacional MLS–Liga MX entre el campeón vigente de MLS Cup y el campeón de Campeón de Campeones de Liga MX. No debe etiquetarse como supercopa nacional de Estados Unidos ni confundirse con la U.S. Open Cup.
- **Supercopa Nova de Estados Unidos:** crear como competición original de Fútbol Nova, no oficial, si el catálogo exige una supercopa para cada país. Propuesta inicial: campeón de MLS Cup contra campeón de U.S. Open Cup; si coincide el club, aplicar una plaza de reemplazo basada en el mejor clasificado de la temporada regular que aún no esté clasificado. Partido único neutral, 90 minutos y penaltis directos, sin prórroga, salvo que el diseño final se identifique expresamente como reglas propias de Fútbol Nova. Esta propuesta no se atribuirá a US Soccer ni a MLS.
- Fuentes para distinguir competiciones: https://www.mlssoccer.com/news/inter-miami-cf-to-host-2026-michelob-ultra-campeones-cup-on-september-16-at-nu-stadium-in-miami y https://www.ussoccer.com/stories/2025/12/format-schedule-participating-teams-finalized-for-2026-lamar-hunt-us-open-cup

### 21.10 Cuba — copa y supercopa originales de Fútbol Nova cuando no exista competición oficial verificable
- **Estado oficial:** no se ha localizado todavía un reglamento vigente y verificable de una copa nacional masculina ni de una supercopa nacional cubana para la temporada objetivo. No presentar una competición creada por el juego como oficial de la Federación Cubana.
- **Copa Nacional de Cuba — Fútbol Nova:** crear una copa nacional masculina ficticia, con entrada de clubes según niveles nacionales ficticios, rondas eliminatorias, sorteo y sede conforme a un reglamento propio de Fútbol Nova. Aplicar las Reglas de Juego IFAB y las normas disciplinarias/organizativas cubanas que puedan verificarse. La estructura exacta se documentará como reglamento original del juego, no como reglamento oficial cubano.
- **Supercopa de Cuba — Fútbol Nova:** partido único entre el campeón del Campeonato Nacional y el campeón de la Copa Nacional de Cuba. Si el mismo club gana ambos, el rival será el subcampeón de Copa. Sede neutral. 90 minutos; empate, prórroga de 30 minutos y después penaltis. Este es un formato original propuesto para el juego, no una regla atribuida a la federación cubana.
- **Condición:** si en el futuro aparece una copa o supercopa oficial cubana con reglamento publicado, la competición oficial sustituirá la propuesta de Fútbol Nova o se conservará la propuesta solo como modo personalizado.

### 21.11 Registro y control de versiones de supercopas
Cada supercopa guardará: país, nombre oficial o etiqueta «Fútbol Nova», organizador, temporada, competiciones clasificatorias, reglas de sustitución por duplicidad, número de participantes, cuadro/fases, sede, fecha, duración, prórroga, penaltis, disciplina, elegibilidad, fuente, artículos aplicados, versión, fecha de revisión y estado (verificado, provisional o personalizado). Las reglas de una edición no se copiarán automáticamente a la siguiente.

**Estado del inventario:** las supercopas oficiales de España, Francia, Italia, Alemania, Portugal, Inglaterra, Brasil y Argentina están identificadas. La verificación debe mantenerse por edición. Estados Unidos no tiene una supercopa doméstica nacional equivalente identificada; Campeones Cup es transfronteriza. Para Cuba, la copa y supercopa propuestas se etiquetan como competiciones originales del juego hasta que exista fuente oficial verificable.

## 22. Verificación de derechos de escudos, uniformes y elementos de identidad de clubes

### 22.1 Principio obligatorio
No se asumirá que un escudo, uniforme, nombre, logotipo o combinación visual es de libre uso por el mero hecho de aparecer en Internet, ser antiguo, no mostrar ©, no estar registrado en una búsqueda inicial o pertenecer a un club amateur. La ausencia de un registro localizado no demuestra por sí sola que no existan derechos. Cada activo requiere comprobación individual y documental antes de incorporarse a una versión distribuible.

### 22.2 Auditoría por club y por activo
Para cada club y temporada, crear una ficha independiente para:
- Escudo/crest, emblemas secundarios, mascota, monogramas y marcas denominativas.
- Uniforme local, visitante y alternativo, incluidos patrones gráficos, paneles, franjas y detalles distintivos.
- Logotipos del fabricante, patrocinadores, liga, copa, federación, patrocinadores de manga, insignias y tipografías.
- Nombre oficial, apodos, lemas y cualquier elemento que pueda funcionar como marca.
- Fotografías, renders, texturas, archivos vectoriales y modelos 3D usados como referencia o recurso final.

### 22.3 Comprobaciones mínimas
- Identificar al titular aparente y a los posibles titulares conjuntos: club, federación, liga, fabricante, patrocinador, diseñador o fotógrafo.
- Consultar registros oficiales pertinentes según territorios de distribución: WIPO Global Brand Database/Madrid Monitor, EUIPO eSearch plus y TMview, USPTO Trademark Search y oficinas nacionales de marcas. Revisar marcas denominativas, figurativas, diseños registrados y titulares; guardar fecha, consulta y resultado.
- Comprobar por separado derechos de autor sobre ilustraciones, escudos, patrones, fotografías y diseños; marcas no registradas, derechos sobre diseños, contratos/licencias y restricciones de uso comercial.
- Verificar permisos o licencias por escrito, alcance territorial, plataforma, duración, modificaciones permitidas, sublicencia y uso promocional.
- Registrar URL de la fuente, captura/archivo de evidencia, titular, jurisdicción, clase/registro si existe, conclusión, responsable y fecha de revisión.
- Repetir la auditoría si cambia el uniforme, escudo, patrocinador, fabricante, titular o territorio de distribución.

### 22.4 Decisión de uso
- **Autorizado/licencia válida:** se puede utilizar el activo dentro del alcance exacto del permiso.
- **Dominio público o libre uso comprobado:** se puede utilizar solo después de documentar la base legal, jurisdicción y alcance. No inferir dominio público por antigüedad o ausencia de registro.
- **Protegido, dudoso, conflicto o sin evidencia suficiente:** no se incorpora el activo real; se genera un diseño original.
- **Marca de tercero dentro del uniforme:** fabricante, patrocinadores, marcas de competición y distintivos se revisan por separado; la autorización del club no implica autorización de terceros.
- **Material de referencia:** puede estudiarse para identificar colores generales e historia visual, pero descargar una imagen no concede derechos para incluirla en el juego.

### 22.5 Diseños alternativos originales
Cuando no exista autorización clara, crear un escudo y uniformes originales que:
- Conserven los colores tradicionales del club y la asociación cromática general que el usuario desea mantener.
- Puedan inspirarse en la historia, geografía, cultura y símbolos públicos de la región, siempre con elementos gráficos creados desde cero.
- No reproduzcan ni calquen la silueta del escudo, monogramas, mascotas, símbolos, composición, tipografía, patrón distintivo, marcas, patrocinadores ni detalles que generen confusión con el original.
- Sean suficientemente diferentes en conjunto para evitar asociación engañosa o apariencia de producto oficial.
- No usen logotipos de fabricantes, patrocinadores ni parches oficiales sin permiso independiente.
- Incluyan en la ficha el origen de los colores, descripción de diferencias y archivos fuente originales.

### 22.6 Estados de auditoría
Usar exactamente uno de estos estados: «Pendiente de investigar», «Coincidencia/registro localizado», «Protección confirmada», «Licencia/autorización documentada», «Uso libre documentado» o «Diseño original requerido». No usar el estado «Libre» solo porque no se encontró un resultado. No publicar ni empaquetar activos con estado pendiente, dudoso o protegido sin licencia.

**Fuentes institucionales de consulta:** WIPO — https://www.wipo.int/en/web/sports/branding y https://www.wipo.int/en/web/sports/international-trademark-system-and-brands ; EUIPO — https://www.euipo.europa.eu/es/search ; los registros nacionales de marcas y derechos de autor aplicables. Esta sección establece un flujo de diligencia debida, no constituye una opinión legal definitiva.


## 23. Ampliación de las ligas nacionales: hasta el tercer nivel

### 23.1 Regla global de cobertura
El paquete base de cada uno de los diez países incluirá, siempre que exista una competición masculina nacional verificable, las categorías de **primera, segunda y tercera división**. La cobertura no se limitará a la máxima categoría. Se mostrarán las denominaciones oficiales y se respetarán las estructuras reales, incluidos grupos paralelos, afiliaciones directas/indirectas, licencias, restricciones de ascenso, promociones, play-offs, descensos y sustituciones administrativas.

- «Tercera división» significa el tercer escalón efectivo del sistema masculino de ligas de clubes del país, no necesariamente una competición cuyo nombre incluya «Tercera».
- Si el tercer escalón se divide en grupos regionales o ramas paralelas, se incluirán todas las ramas necesarias para representar el nivel completo; no se elegirá arbitrariamente una sola.
- Los clubes y plantillas seguirán siendo ficticios y originales, con nombres regionales propios de Fútbol Nova. Los resultados y movimientos de ascenso/descenso se simularán sobre las reglas oficiales.
- Las divisiones inferiores podrán tener más clubes y requerir paquetes de datos adicionales. El paquete descargable no alterará la cobertura lógica ni exigirá conexión una vez instalado.
- La participación, elegibilidad, licencias, estadios, requisitos económicos, cupos de extranjeros/sub-edad y criterios de ascenso se tomarán del reglamento de cada temporada. No se garantizará un ascenso deportivo cuando la normativa real lo condicione a licencia o admisión.
- Las ligas regionales situadas por debajo del tercer nivel no se incluirán automáticamente en el paquete base; podrán incorporarse en módulos futuros.
- Si no existe una tercera categoría nacional única o no se puede confirmar una competición vigente, se documentará la particularidad y se dejará pendiente o se creará una competición **Fútbol Nova** claramente identificada como ficticia. Nunca se presentará una liga inventada como oficial.

### 23.2 España
1. **Primera División** — nivel 1.
2. **Segunda División** — nivel 2.
3. **Primera Federación** — nivel 3, organizada en dos grupos de ámbito estatal.
4. La Segunda Federación (nivel 4) y Tercera Federación (nivel 5) quedan fuera del alcance base, salvo módulo futuro.
- Fuente normativa RFEF: https://rfef.es/sites/default/files/2025-11/20251112_Reglamento_de_Competiciones_2025.pdf
- Bases oficiales: https://rfef.es/es/federacion/bases-de-competicion-202526
- La RFEF reconoce Primera, Segunda y Primera Federación como competiciones oficiales masculinas de ámbito estatal. Se deberá cargar el reglamento y calendario específico 2026/27 de Primera Federación antes de cerrar sus cifras, grupos, play-offs y descensos.

### 23.3 Francia
1. **Ligue 1** — nivel 1.
2. **Ligue 2** — nivel 2.
3. **Ligue 3** — nivel 3 desde 2026/27; sustituye al antiguo Championnat National, con 18 clubes, grupo único y 34 jornadas ida/vuelta.
- Para 2026/27 ascienden directamente los dos primeros a Ligue 2; los puestos 3.º a 6.º disputan play-offs y el ganador juega una promoción/relegación a ida y vuelta contra el 16.º de Ligue 2; los tres últimos descienden al National 1.
- La denominación cambia desde 2026/27: el antiguo National 2 pasa a llamarse National 1 y el antiguo National 3 pasa a llamarse National 2.
- Fuentes oficiales: https://www.fff.fr/article/16778-la-fff-officialise-la-ligue-3-professionnelle.html ; https://www.fff.fr/article/17022-le-calendrier-2026-2027-est-servi.html ; reglamento 2026/27: https://media.fff.fr/uploads/documents/partie-3-reglement-du-championnat-de-l3.pdf
- Aplicar el reglamento oficial de cada temporada; no fijar estas cifras para futuras ediciones sin revisión.

### 23.4 Italia
1. **Serie A** — nivel 1.
2. **Serie B** — nivel 2.
3. **Serie C** — nivel 3, organizada en tres grupos territoriales.
- Según las Norme Organizzative Interne FIGC consultadas, los campeones de cada grupo ascienden directamente a Serie B y una cuarta plaza se decide mediante play-offs. La clasificación al play-off incluye puestos de los tres grupos y está sujeta a las reglas de la Coppa Italia Serie C y a las condiciones de admisión.
- Fuente FIGC: https://figc.it/media/264649/tit3_noif_art_da47a70_-aggiornato-al-cu228-del-27-03-2025-seg-gen.pdf
- La composición de grupos, número de participantes, play-outs, descensos y requisitos de licencia debe obtenerse del reglamento Lega Pro/FIGC de la temporada seleccionada. La norma general no sustituye las bases anuales.

### 23.5 Alemania
1. **Bundesliga** — nivel 1.
2. **2. Bundesliga** — nivel 2.
3. **3. Liga** — nivel 3, 20 clubes.
- La admisión depende del procedimiento de licencia del DFB; un club que obtenga plaza deportiva puede no ser admitido si no cumple las condiciones reglamentarias.
- El sistema de ascenso/descenso, incluidos los puestos directos y la promoción/relegación, se cargará desde el Statut der 3. Liga y la Spielordnung vigentes de la temporada, sin asumir que la clasificación deportiva por sí sola garantiza la plaza.
- Fuentes oficiales: https://assets.dfb.de/uploads/000/328/561/original_Heft_02_Statut_3_Liga_20251219.pdf ; https://www.dfb.de/news/teilnehmerfeld-der-3-liga-steht-fest-havelse-rueckt-fuer-1860-nach

### 23.6 Portugal
1. **Liga Portugal Betclic** — nivel 1.
2. **Liga Portugal 2** — nivel 2.
3. **Liga 3** — nivel 3, organizada por la Federação Portuguesa de Futebol.
- La Liga 3 no debe omitirse por el hecho de que la Liga Portugal gestione principalmente las dos primeras categorías. La estructura, fases, grupos, subida a Liga Portugal 2, play-offs y descensos deben seguir el Regulamento da Liga 3 de FPF de cada edición.
- Fuentes institucionales para validar y descargar las bases: https://www.fpf.pt/pt/Institucional/Regulamentos ; https://www.ligaportugal.pt/pages/estatutos-regulamentos
- **Pendiente de consolidación:** extraer y registrar el reglamento FPF específico 2026/27 y su calendario; no completar de memoria el número de clubes, fases o criterios de desempate.

### 23.7 Inglaterra
1. **Premier League** — nivel 1.
2. **EFL Championship** — nivel 2.
3. **EFL League One** — nivel 3.
- La tercera categoría no es National League: National League corresponde al quinto escalón. El motor debe modelar los play-offs de ascenso y descensos de League One según el reglamento EFL de cada temporada, así como los requisitos de admisión y movimientos entre EFL y National League.
- Fuentes institucionales: https://www.efl.com/ ; https://www.thefa.com/football-rules-governance/competition-rules
- **Pendiente de consolidación:** registrar el reglamento EFL 2026/27 completo y verificar los cupos y formato anual de play-offs antes de marcar la temporada como cerrada.

### 23.8 Brasil
1. **Campeonato Brasileiro Série A** — nivel 1.
2. **Série B** — nivel 2.
3. **Série C** — nivel 3.
- Cambio de formato oficial anunciado por CBF: Série C mantiene 20 participantes en 2026; pasa a 24 en 2027 y a 28 en 2028. Para 2026 descienden dos clubes a Série D; en 2027 se mantiene el descenso de dos.
- La edición 2026 fue anunciada del 5 de abril al 25 de octubre. CBF publicó REC, tabla básica y plan general de acciones específicos.
- Fuentes oficiales: https://www.cbf.com.br/futebol-brasileiro/noticias/detalhes/competicoes-campeonato-brasileiro-serie-b/cbf-publica-documentos-tecnicos-da-serie-c-de-2026 ; https://www.cbf.com.br/a-cbf/por-dentro-da-cbf/comissao-dopagem/autorizacao-de-uso-terapeutico/cbf-anuncia-novo-calendario-do-futebol-profissional-masculino ; https://www.cbf.com.br/futebol-brasileiro/noticias/campeonato-brasileiro-serie-c/a/titulo-do-maringa-encerra-ultima-serie-c-com-20-clubes
- La Serie C debe usar las fases de cada REC anual; no asumir un formato de grupo único permanente ante la ampliación anunciada.

### 23.9 Estados Unidos
1. **Major League Soccer (MLS)** — nivel 1 del itinerario de competición profesional de primera categoría.
2. **USL Championship** — nivel 2 en la estructura de referencia.
3. **USL League One** — nivel 3 en la estructura de referencia.
- **Advertencia estructural importante:** el fútbol profesional estadounidense no tiene un sistema general de ascenso y descenso entre MLS y USL equivalente al de las pirámides europeas. La clasificación por niveles es una referencia de jerarquía competitiva, no una conexión automática de promoción/relegación. La admisión depende de franquicias, licencias y decisiones de las ligas.
- La USL League One no debe generar ascensos automáticos a USL Championship o MLS. Los movimientos entre categorías solo se simularán si existe un mecanismo oficial aplicable a la competición/temporada.
- Fuente de referencia para la estructura: https://www.ussoccer.com/ ; las reglas y participantes se verificarán en las Competition Guidelines oficiales de MLS/USL de cada temporada.
- **Pendiente:** incorporar enlaces directos a reglamentos y calendario oficiales 2026 de USL Championship y USL League One, y documentar sus formatos anuales antes de dar por terminada la ficha.

### 23.10 Argentina
1. **Primera División / Liga Profesional** — nivel 1.
2. **Primera Nacional** — nivel 2.
3. **Tercer nivel con dos ramas paralelas**, no una liga única:
   - **Primera B Metropolitana**, para el ámbito de clubes directamente afiliados a AFA.
   - **Torneo Federal A**, organizado por el Consejo Federal, para clubes indirectamente afiliados.
- Ambas ramas deben representarse como rutas del tercer escalón, manteniendo sus propias zonas, formatos, licencias, ascensos, descensos y mecanismos de clasificación. No fusionar sus clubes en una tabla común ni inventar un play-off entre ambas salvo que la normativa de esa edición lo establezca.
- Fuentes institucionales para reglamentos y resoluciones: https://www.afa.com.ar/ y https://www.afa.com.ar/es/pages/consejo-federal
- **Pendiente:** incorporar los reglamentos específicos 2026 de Primera Nacional, Primera B Metropolitana y Torneo Federal A, y sus calendarios oficiales. La estructura exacta de grupos y ascensos se mantendrá sin definir hasta completar esa extracción.

### 23.11 Cuba
- El Campeonato Nacional de Primera División se mantiene como nivel 1 del catálogo cubano cuando la Federación Cubana publique y confirme su edición.
- No se ha verificado una segunda y tercera división nacional masculina estables, activas y reglamentadas para la temporada objetivo. No se inventarán nombres ni ascensos oficiales.
- Para el contenido ficticio de Fútbol Nova se han creado 32 clubes con nombres distintivos, sede cubana, preferencias tácticas propias, personalidad institucional y paletas/escudos/uniformes originales. Sus nombres se contrastaron preliminarmente con catálogos públicos actuales e históricos; no se consideran una certificación legal definitiva. Detalles y perfiles: `CUBA_LEAGUES.md` y `data/cuba_leagues.json`.
- **Pendiente de fuente primaria:** consultar cada año a la Federación Cubana de Fútbol y autoridades deportivas nacionales para confirmar si existen Campeonato Nacional de Segunda División, tercera categoría, ligas provinciales o torneos de clasificación que constituyan formalmente esos niveles.
- Si no hay competición oficial vigente, Fútbol Nova podrá ofrecer una **Segunda División de Cuba — Fútbol Nova** y una **Tercera División de Cuba — Fútbol Nova**, con clubes ficticios y reglamentos originales del juego, claramente marcadas como competiciones personalizadas/no oficiales. No se presentarán como competiciones de la FCF.

### 23.12 Verificación, fuentes y temporadas
Para cada categoría se almacenarán país, nivel, denominación oficial, organizador, temporada, participantes, grupos, calendario, formato, puntuación, desempates, ascensos, descensos, play-offs, licencias, restricciones de elegibilidad, reglamento, URL, fecha de publicación, última revisión y estado de verificación. Los datos de una temporada anterior no se copiarán como vigentes sin contrastarlos con la nueva normativa.

**Estado de cobertura:** España, Francia, Italia, Alemania, Portugal, Inglaterra, Brasil, Estados Unidos y Argentina tienen identificada una competición o estructura de tercer nivel. Cuba queda pendiente de confirmación oficial; solo podrá completarse con una competición ficticia identificada como Fútbol Nova si no existe una tercera división nacional verificable.


## 24. Plantillas generadas y calibración de fuerza real

El catálogo inicial cubano cuenta con 32 clubes ficticios de Segunda y Tercera División. Se generaron 22 jugadores por club, 704 futbolistas ficticios en total. Los datos se encuentran en:
- `data/players/cuba_second_division.json`
- `data/cuba_players.json` (Tercera División, grupos occidental y oriental)

La estructura compacta de cada jugador contiene identidad estable, nombre, fecha y edad, nacionalidad independiente del club, lugar de nacimiento, posiciones, pie preferido, medidas físicas, valoración estimada, potencial y 35 atributos. El orden de los atributos está declarado en el arreglo `attribute_keys` de cada archivo. Los datos son ficticios y reproducibles mediante semilla; no proceden de futbolistas reales.

### Calibración
La fuerza del jugador no se determina únicamente por nacionalidad. El modelo debe combinar, con pesos versionados y normalización separada:
- fuerza internacional del país según ranking FIFA masculino;
- rendimiento continental de sus clubes/asociaciones (coeficientes UEFA cuando aplique);
- rankings globales de clubes y modelos Elo, guardando cobertura y metodología;
- nivel real de la liga y de la división;
- rendimiento reciente del club y contexto económico/deportivo;
- edad, posición, desarrollo y rol del jugador.

Los rankings de selecciones no son rankings de ligas. Los coeficientes UEFA no cubren todos los países. IFFHS y los modelos Elo tienen coberturas y metodologías distintas. No se deben tratar como una escala común ni inventar valores cuando falten datos.

### Probabilidad de nacionalidad
La probabilidad de futbolistas nacionales aumenta cuando baja el nivel competitivo del país y de la división. Disminuye cuando la liga tiene mayor fuerza, mercado internacional y capacidad de captación. Se ajusta por restricciones de inscripción y mercados regionales plausibles. La nacionalidad nunca se infiere del nombre ni del club: se guarda como dato independiente; el nombre y el lugar de nacimiento siguen las convenciones del país de nacimiento.

**Estado:** generación inicial de Cuba completada; el resto de los países se generará cuando sus catálogos de clubes ficticios estén creados. La valoración general y los pesos definitivos siguen pendientes de calibración y pruebas.
