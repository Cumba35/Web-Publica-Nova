# Fútbol Nova — Modo Manager: gobierno, propiedad y creación de clubes

**Estado:** decisiones confirmadas por el usuario; diseño documentado, todavía no equivale a implementación ni a pruebas en Godot.
**Ámbito:** carrera Manager, clubes creados, estadios, infraestructuras, contratación y continuidad profesional.
**Regla de proceso:** antes de preguntar sobre cualquiera de estos sistemas, revisar este documento y los demás documentos relacionados del repositorio. No repetir decisiones ya confirmadas.

## 1. Modalidades de carrera Manager

El modo Manager tendrá dos perfiles de responsabilidad:

### Entrenador
Se centra en la gestión deportiva:
- Alineaciones, formaciones y tácticas.
- Entrenamientos y desarrollo de futbolistas.
- Convocatorias, titulares y sustituciones.
- Gestión deportiva de la plantilla y preparación de partidos.

### Presidente
Se centra en la administración y economía del club:
- Presupuestos, finanzas e inversiones.
- Contratación y despido de entrenadores.
- Fichajes y negociaciones desde la perspectiva directiva.
- Patrocinios y acuerdos comerciales.
- Construcción, mantenimiento y mejora de estadios e instalaciones.
- Planificación institucional y objetivos del club.

La selección entre Entrenador y Presidente determina las responsabilidades y acciones disponibles. Los permisos exactos que se delegan o comparten entre ambos perfiles deberán detallarse sin contradecir esta separación.

## 2. Formas de iniciar una carrera

Al comenzar una carrera, el usuario podrá:
1. Elegir cualquier club disponible.
2. Empezar sin equipo y buscar ofertas de trabajo.
3. Crear un club nuevo.

### Creación y sustitución de un club

- El usuario selecciona el país.
- El juego identifica el club más débil de ese país.
- El nuevo club sustituye al club de referencia en la competición; no se crea una copia adicional.
- El club original deja de existir como participante independiente en esa carrera.
- El nuevo club comienza en la división más baja disponible del país y ocupa la plaza competitiva del club sustituido, adaptando la estructura si fuera necesario.
- Hereda la misma plantilla del club sustituido: los mismos futbolistas, edades, posiciones, atributos, valoraciones y potencial. No se genera una plantilla nueva.
- El nivel deportivo y la base económica inicial corresponden al club utilizado como referencia, salvo ajustes que se definan expresamente más adelante.

## 3. Propiedad y personalización del club creado

- Al crear el club, el usuario será su propietario total (100 %).
- Tendrá el control de las decisiones administrativas y económicas propias del propietario, especialmente en el perfil Presidente.
- La propiedad no elimina la separación de funciones deportivas del perfil Entrenador.
- La personalización será completa: nombre y nombre corto, escudo, símbolos, colores, equipaciones local/visitante/alternativas, uniformes de portero, estadio, nombre del estadio, diseño de gradas, afición, banderas, cánticos, celebraciones, identidad y tradiciones.
- La personalización visual no mejorará automáticamente la calidad deportiva de la plantilla ni la economía inicial.

## 4. Identidad de clubes, selecciones y aficiones

Cada club y cada selección nacional tendrá identidad propia y diferenciada:
- Identidad visual, escudo/emblema, colores y equipaciones.
- Estadio propio asignado, cuando corresponda a su estructura.
- Afición con cánticos, banderas, celebraciones y comportamientos propios.
- Historia, tradiciones y rivalidades cuando esos datos estén definidos.

El público reaccionará dinámicamente a goles, ocasiones, faltas, rivalidades, resultados y acontecimientos del partido. La presentación y el ambiente deberán distinguir a cada equipo y selección, no limitarse a una multitud genérica.

Los clubes tendrán estadios propios y también existirán estadios neutrales para finales y torneos especiales.

## 5. Economía, nivel e infraestructuras

El tamaño, capacidad y nivel de las infraestructuras de cada equipo estarán determinados por dos factores:
- **Nivel económico:** recursos disponibles para construir, mantener y operar instalaciones.
- **Nivel general del equipo:** categoría e importancia deportiva del club o selección.

La evaluación de instalaciones podrá abarcar estadio, capacidad, césped, iluminación, marcador, gradas, vestuarios, zonas técnicas, entrenamiento, academia/cantera, servicios médicos y recuperación.

Las mejoras de infraestructuras se realizarán exclusivamente en el modo Manager. Serán decisiones de inversión del usuario y estarán limitadas por el presupuesto y la capacidad económica del club. No se mejorarán automáticamente fuera de la carrera Manager.

## 6. Propiedad y uso de estadios

El universo del juego admitirá diferentes situaciones:
- Estadio propiedad del propio club.
- Estadio de propiedad externa utilizado mediante alquiler o acuerdo.
- Otros acuerdos de uso compartido o mixto, cuando el caso del club lo justifique.

La propiedad y las obligaciones asociadas deberán reflejarse en finanzas, mantenimiento, contratos y permisos de mejora. No asumir que todo club es propietario de su estadio.

### Nombre y patrocinio del estadio
El nombre podrá:
- Ser elegido libremente por el usuario y cambiarse.
- Ser un nombre comercial acordado con un patrocinador a cambio de ingresos.

Los contratos de derechos de nombre tendrán condiciones y duración, cuyos parámetros se definirán al diseñar el sistema general de patrocinios.

### Ampliación de estadios
- Las ampliaciones se ejecutarán por etapas.
- Cada etapa requiere inversión y tiempo de construcción.
- Las obras podrán reducir temporalmente la capacidad o dejar zonas fuera de servicio.
- El proyecto estará condicionado por recursos, propiedad, permisos y capacidad económica.
- No habrá ampliación instantánea sin coste ni consecuencias.

## 7. Venta del club y continuidad profesional

El usuario podrá elegir conservar su club creado durante toda la carrera o ponerlo a la venta.

Si decide venderlo:
- Podrá recibir ofertas y negociar precio y condiciones.
- La valoración tendrá en cuenta economía, instalaciones, plantilla, reputación y resultados, además de los activos y obligaciones que se definan en el modelo financiero.
- Tras completar la venta, el usuario dejará de ser propietario.

Después de vender el club, abandonar un cargo o quedar sin equipo:
- Podrá aceptar una oferta y cambiar de club inmediatamente.
- Podrá esperar al final de la temporada para buscar otro destino.
- Podrá permanecer sin club mientras busca oportunidades.

## 8. Ofertas de trabajo

Las ofertas para entrenadores y presidentes considerarán un conjunto de factores:
- Resultados y rendimiento deportivo.
- Reputación y prestigio.
- Experiencia y trayectoria.
- Títulos y logros.
- Situación económica del club.
- Objetivos deportivos e institucionales.
- Compatibilidad entre el perfil del candidato y el proyecto.

Los requisitos y condiciones variarán según el cargo y las necesidades de cada club.

## 9. Contratos, renovaciones y despidos

El sistema contractual de entrenadores y presidentes incluirá:
- Duración del contrato.
- Salario, primas y bonificaciones.
- Cláusulas y condiciones.
- Negociación y renovación.
- Despidos justificados por contexto, objetivos, rendimiento y condiciones contractuales.
- Indemnizaciones por despido cuando correspondan.
- Renuncia voluntaria.
- Ofertas de otros clubes y negociación de salida.

No se tratarán los despidos como una acción arbitraria sin consecuencias contractuales.

## 10. Dificultad del modo Manager

El usuario confirmó que la configuración de dificultad del modo Manager **ya está definida**. No volver a preguntarla ni sustituirla por una nueva propuesta. Para conocer sus valores exactos, consultar el documento o configuración donde estén registrados; este documento no inventa ni duplica esos parámetros.

## 11. Clima, horario y sedes: decisiones vinculadas

- En partidos amistosos, el usuario podrá seleccionar las condiciones meteorológicas.
- En los demás modos, el clima podrá cambiar dinámicamente durante el encuentro.
- En amistosos, el usuario podrá elegir mañana, tarde, atardecer o noche.
- En competiciones oficiales, los horarios dependerán del calendario y programación de la competición.
- Los clubes tendrán estadios propios y se usarán estadios neutrales para finales y torneos especiales.
- Las condiciones meteorológicas y la iluminación deberán integrarse con la superficie, el estadio y la presentación del partido.

Los tipos concretos de fenómenos meteorológicos y su impacto físico quedan pendientes de especificación.

## 12. Objetivos de la junta para el perfil Entrenador

Cuando el usuario elige el perfil **Entrenador**, la junta directiva establece objetivos obligatorios a corto plazo y de temporada. El progreso se calcula automáticamente desde los partidos, competiciones, calendario, plantilla y eventos disciplinarios; el entrenador debe cumplir las metas para conservar y mejorar la confianza de la directiva.

- Los objetivos cortos se actualizan al completarse y pueden renovarse durante la temporada.
- Los objetivos de temporada se mantienen hasta su plazo o cierre de campaña.
- Las metas pueden abarcar resultados, rendimiento, disciplina, desarrollo juvenil y responsabilidades deportivas asignadas.
- La evaluación considera prioridad, dificultad, contexto y resultados globales. Fallar una meta secundaria no provoca despido automático.
- Una confianza baja puede producir advertencias, reuniones, revisión contractual y, si el contexto y el contrato lo justifican, despido con las consecuencias económicas correspondientes.
- El perfil Presidente actúa desde el gobierno del club y no se evalúa a sí mismo como entrenador. Si el usuario es propietario y elige Entrenador, la propiedad no lo exime de las metas deportivas.
- No conceder recompensas en una moneda no aprobada; cualquier pago futuro debe integrarse con la moneda única y el libro mayor del club.

Ver [Objetivos de la junta directiva y evaluación del entrenador](BOARD_OBJECTIVES_AND_MANAGER_EVALUATION.md) para reglas completas y pruebas de aceptación.

## 13. Registro de estado y límites

| Área | Estado |
|---|---|
| Modalidades Entrenador y Presidente | Definido a nivel funcional |
| Formas de iniciar carrera | Definido |
| Creación de club sustituyendo al más débil del país | Definido |
| Herencia exacta de la plantilla del club sustituido | Definido |
| Propiedad total del club creado | Definido |
| Personalización completa | Definido |
| Identidad propia de clubes, selecciones y aficiones | Definido |
| Infraestructuras según economía y nivel general | Definido |
| Mejoras de infraestructuras solo en Manager y mediante inversión | Definido |
| Propiedad de estadio propia o externa | Definido a nivel de modelos |
| Nombre libre o comercial del estadio | Definido |
| Ampliaciones por etapas con tiempo y posibles restricciones | Definido |
| Venta opcional y continuidad de carrera | Definido |
| Ofertas de trabajo según evaluación completa | Definido |
| Contratos completos para cargos de Manager | Definido a nivel de sistemas |
| Dificultad del Manager | Ya configurada; no reabrir |
| Lista de fenómenos meteorológicos y sus efectos | Pendiente |
| Cálculos detallados de valoración, obras, contratos y patrocinio | Pendiente de especificación |
| Implementación y pruebas en Godot/Android | No acreditadas por este documento |

**Importante:** este archivo registra decisiones de diseño. No afirma que las funciones estén programadas, integradas o probadas.
