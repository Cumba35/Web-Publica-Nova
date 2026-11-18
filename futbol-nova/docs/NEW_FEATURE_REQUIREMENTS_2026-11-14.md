# Fútbol Nova — ampliación de requisitos (2026-11-14)

**Estado:** requisitos recibidos y documentados; pendientes de diseño detallado, revisión de coherencia y aprobación de decisiones abiertas.  
**Alcance:** economía, propiedad, vida social, carreras, cantera, competiciones juveniles, amistosos, convocatorias, interfaz, módulos, cuenta Nova Nexus, estadísticas, guardado y jugador insignia.  
**Regla de control:** documentar no significa implementar. Ninguna característica se marcará como disponible hasta que exista y supere pruebas.

## 1. Economía global y moneda

- Todas las ligas, clubes, selecciones, competiciones y modos usarán una única moneda interna.
- **La moneda sigue sin decidirse.** No fijar USD, EUR, CUP ni otra divisa hasta que el usuario lo apruebe.
- La moneda debe ser una configuración central del universo de juego, no un campo independiente por liga.
- Guardar cantidades en unidades enteras mínimas para evitar errores de redondeo; mostrar símbolo, separadores y formato localizado.
- Todos los contratos, salarios, premios, multas, fichajes, presupuestos, valoraciones de clubes, propiedades y transacciones personales usan la misma unidad.
- Separar finanzas del club y patrimonio personal. Registrar libro mayor con fecha, concepto, entidad, importe, saldo anterior/posterior y origen.
- Los valores económicos se recalculan con eventos trazables; no cambiar el valor de un club de forma arbitraria.

## 2. Valoración de clubes y mercado de acciones

El valor del club será dinámico y representará el valor económico de la entidad en una fecha concreta. El modelo considerará, como mínimo:

- Activos: estadio y terrenos, instalaciones, centro de entrenamiento, academia, equipamiento, derechos/activos comerciales y otros bienes del club.
- Valor económico de la plantilla y derechos contractuales de jugadores, con depreciación, duración de contratos y riesgo.
- Caja, inversiones y cuentas por cobrar.
- Deudas, obligaciones, salarios pendientes, impuestos, sanciones y multas.
- Ingresos recurrentes, patrocinio, entradas, premios, derechos audiovisuales y comercio.
- Gastos operativos, salarios, fichajes, mantenimiento, obras e inversiones.
- Rendimiento deportivo, categoría, reputación, asistencia, riesgo de descenso y estabilidad financiera.

La valoración mostrará fecha, desglose, metodología y rango de incertidumbre. Evitar contar dos veces activos o ingresos. El precio por acción será el valor patrimonial ajustado dividido por las acciones emitidas; las operaciones podrán añadir prima/descuento de mercado y costes explícitos.

### Propiedad y restricciones por modo

- El 51 % de las acciones otorga control mayoritario y condición de propietario mayoritario en el juego.
- Se podrá comprar cualquier porcentaje disponible, incluido el 100 %, como inversión.
- Los dividendos no equivalen al total de ganancias: solo se distribuyen beneficios aprobados después de obligaciones, reservas y necesidades de liquidez, en proporción a la participación.
- En Leyenda, el jugador podrá invertir en cualquier club aunque no juegue allí. Mientras siga siendo futbolista profesional activo, no podrá dirigir ni ocupar la presidencia de ningún club.
- En Manager, alcanzar el 51 % convierte al usuario en propietario mayoritario. Si mantiene contrato laboral/deportivo con otro club, no podrá reclamar la presidencia ni asumir funciones ejecutivas incompatibles. La inversión pasiva puede mantenerse.
- Separar los roles de accionista, propietario mayoritario, presidente, director ejecutivo y entrenador. La propiedad no concede automáticamente permisos de gestión deportiva.
- Añadir historial de accionistas, ofertas, adquisiciones, ventas, dividendos y cambios de valoración.

## 3. Salarios, contratos e ingresos personales

- En Manager y Leyenda, el usuario cobra el salario pactado en su contrato con el club/equipo correspondiente.
- Los contratos registran salario, frecuencia de pago, duración, primas, bonos, cláusulas, derechos de imagen si existen, impuestos/deducciones y condiciones de renovación.
- El calendario de pagos debe ser consistente y auditable.
- Un jugador que sea accionista podrá recibir dividendos separados de su salario.
- Un propietario no cobrará automáticamente todo el beneficio del club: solo dividendos distribuidos según su porcentaje.
- En Leyenda, salarios y bonificaciones se ingresan al patrimonio personal; en Manager, el salario del cargo se separa de las inversiones personales y de los beneficios del club.

## 4. Vida personal (Manager y Leyenda)

Crear una única pantalla llamada **Vida personal** dentro de ambos modos. Toda la información personal se reúne en esa misma pantalla, organizada mediante secciones internas o pestañas, sin repartir familia, relaciones, mensajes, agenda, actividades y patrimonio en pantallas independientes:

- Vivienda: alquiler, compra, venta, mejoras, mobiliario, mantenimiento y gastos.
- Vehículos: compra, venta, garaje, mantenimiento, seguro y costes de uso.
- Vestuario y apariencia: ropa, calzado, accesorios y artículos cosméticos.
- Ocio y experiencias: actividades, viajes y eventos, sujetos a calendario y presupuesto.
- Patrimonio: resumen de bienes, liquidez, deudas y gastos recurrentes.
- Relaciones/reputación: eventos y decisiones opcionales que puedan influir de forma moderada en popularidad, moral, imagen pública y relaciones.
- Familia y entorno: vínculos ficticios, llamadas, mensajes, acontecimientos personales y apoyo.
- Agenda personal: invitaciones, eventos, actividades, descanso y compromisos; mostrar conflictos con el calendario profesional.
- La pantalla adapta sus contenidos al rol: el futbolista gestiona relaciones de vestuario y carrera deportiva; el entrenador gestiona su entorno personal y el equilibrio con sus responsabilidades profesionales.
- Notificaciones de pagos, vencimientos, ofertas y mantenimiento.

La vida social debe respetar la situación económica y el calendario deportivo. No debe permitir gastar dinero no disponible ni conceder ventajas deportivas injustas por comprar artículos de lujo. Los artículos cosméticos no alterarán atributos salvo que se trate de equipamiento deportivo autorizado y equilibrado.

## 5. Modo Leyenda: edad, pruebas, cantera, contratos y retirada

- Edad mínima para crear jugador: 14 años. Edad máxima inicial: 45 años.
- Un jugador creado con 14 años comienza en cantera. No puede jugar profesionalmente, ser vendido ni cedido antes de cumplir 15.
- Al cumplir 15 puede firmar su primer contrato profesional si recibe y acepta una oferta válida.
- Un jugador creado con 15 años o más no se asigna automáticamente a un club: participa primero en una prueba/partido de evaluación ante observadores.
- Según rendimiento, posición, potencial y necesidades, los clubes interesados podrán presentar ofertas.
- Si el usuario elige empezar como canterano, realiza pruebas de cantera; solo clubes con academia/cantera operativa podrán presentar ofertas de cantera.
- Las pruebas evalúan rendimiento contextual, no solo goles: técnica, decisiones, trabajo defensivo, físico, disciplina, posición y nivel del rival.
- La retirada voluntaria se permite al final de una temporada cuando el jugador no tenga contrato vigente. La edad máxima jugable es 45 años; puede retirarse antes.
- Si se retira con 20 años o más, podrá iniciar carrera de Manager y desbloquear el conjunto de funciones de ese modo. La transición conservará historial y logros, pero creará una carrera de Manager coherente.
- La elegibilidad internacional se calcula con reglas configurables inspiradas en normativa vigente: nacionalidad, nacimiento, ascendencia/residencia cuando corresponda, apariciones oficiales y cambios de asociación permitidos. No basta con elegir libremente una selección si el jugador ya está vinculado internacionalmente.
- Convocatorias y titularidad dependen de nivel, forma, posición, rendimiento, competencia y decisiones del seleccionador.

### Compensación al club formador

Inspiración reglamentaria: FIFA distingue compensación por formación (primer registro profesional y ciertos traspasos hasta el final del año del 23.º cumpleaños, con condiciones) y mecanismo de solidaridad (hasta el 5 % de compensación de traspaso aplicable, distribuido entre clubes formadores por periodos de formación). No se debe representar esto como un porcentaje fijo que siempre cobra únicamente el último club.

Para Fútbol Nova:
- Mantener historial de academias y temporadas/años de formación por jugador, con fechas de alta y baja.
- Al primer contrato profesional, calcular una compensación de formación configurable según categoría/costes de formación, edad y temporadas registradas.
- En traspasos sujetos al mecanismo de solidaridad, reservar hasta el 5 % de la compensación y distribuirlo entre los clubes formadores elegibles según años de formación.
- En transferencias domésticas ficticias, aplicar una regla interna equivalente y transparente si se decide extender el mecanismo.
- Mostrar cálculo, beneficiarios y transacción en el historial financiero.
- La normativa real puede variar por asociación, jurisdicción y edición; verificar reglas antes de convertirlas en una regla universal del juego.

## 6. Modo Manager y selección nacional

- El usuario podrá dirigir un club y, además, una selección nacional.
- Las ofertas de clubes/selecciones dependen de resultados, objetivos, reputación, experiencia y calidad de la temporada; no se garantizan automáticamente.
- Los contratos y calendarios deben detectar conflictos entre partidos de club y selección.
- Convocatorias de futbolistas dependen de elegibilidad nacional y rendimiento.
- Separar el cargo de entrenador del de propietario/presidente, con permisos distintos.

## 7. Canteras y calendario de amistosos

- La configuración inicial garantiza academias operativas para todos los clubes de Primera División.
- Los clubes de Segunda, Tercera y categorías inferiores comienzan sin cantera ni equipos juveniles; para crear una academia deben superar los mismos requisitos reglamentarios y económicos definidos para Segunda.
- Ningún club de divisiones inferiores genera juveniles automáticamente antes de la aprobación de su academia.
- Las reglas de elegibilidad, protección juvenil y calendario se aplican de forma uniforme a todas las academias aprobadas.

- Los equipos de cantera tendrán competiciones propias: liga, copa, supercopa y torneos adicionales cuando la estructura de su país lo justifique.
- Cada competición juvenil se vincula a la asociación, país, región y estructura de divisiones del equipo profesional correspondiente.
- Las reglas juveniles deben contemplar edad, elegibilidad, límites de plantilla y ascenso al primer equipo.
- Todos los clubes podrán proponer amistosos de pretemporada.
- El entrenador decide cuántos amistosos propone y contra quién.
- El rival debe aceptar antes de confirmar el encuentro.
- Antes de programar, ambas partes acuerdan sede/localización, reparto de ingresos o garantía económica, gastos y condiciones del partido.
- El calendario valida disponibilidad, viajes, descanso y preparación física.

## 8. Nombre para comentarios

En el creador de Leyenda se podrá elegir un **nombre de comentario** que se utilizará cuando el usuario controle el balón o participe en eventos relevantes.
- El catálogo debe reflejar nombres realmente grabados/soportados por el paquete de audio.
- Si no existe una grabación exacta, mostrar alternativas disponibles o usar una pronunciación/sistema de llamada genérico; nunca prometer una voz inexistente.
- El nombre de comentario es independiente del nombre completo, nombre mostrado y nombre de uniforme.

## 9. Organización de pantallas de Manager y Leyenda

- Ambos modos tendrán grupos de pantallas con desplazamiento horizontal bidireccional y circular, coherente con el menú principal.
- Cada grupo contiene pantallas relacionadas y conserva su estado al navegar.
- Evitar pantallas sobrecargadas; usar resúmenes y accesos a detalles.
- Propuesta de agrupación inicial, sujeta a revisión:
  - Manager: Central; Equipo (plantilla, tácticas, entrenamiento); Competiciones (calendario, tabla, copa); Mercado (fichajes, contratos, ojeo); Club (finanzas, instalaciones, directiva, propiedad); Selección nacional; **Vida personal**; Estadísticas.
  - Leyenda: Central; Carrera (pruebas, contratos, calendario); Desarrollo (atributos, entrenamiento); Club (plantilla, rol, objetivos); Selección nacional; **Vida personal**; Inversiones (acciones y patrimonio); Estadísticas.
- Las pantallas de grupo no añaden nuevas pantallas raíz al menú principal de cuatro secciones.

## 10. Guardado automático y rendimiento

- El autoguardado también genera puntos de recuperación al pausar y cuando el partido se detiene de forma segura.
- Los guardados no deben bloquear el hilo de renderizado ni interrumpir la simulación.
- Capturar una instantánea consistente del estado en un punto seguro; serializar/escribir en segundo plano mediante cola controlada.
- Usar escritura atómica, verificación de integridad, versiones de esquema, copia del último guardado válido y recuperación ante cierre inesperado.
- Evitar escrituras redundantes: agrupar eventos muy próximos, aplicar debounce y priorizar el último estado confirmado sin perder el último punto de recuperación requerido.
- Mostrar un icono discreto de guardado en curso y una confirmación visual solo cuando la escritura termine y se verifique correctamente. Mostrar error recuperable si falla.
- No mostrar un éxito antes de confirmar la escritura.
- Medir latencia, uso de CPU/memoria e impacto en FPS en dispositivos objetivo.

## 11. Imagen de carga y pantalla Inicio

### Pantalla de carga
- Usará el retrato/imagen del jugador base que el propietario creará y aportará.
- La imagen no se inventará ni se sustituirá por un jugador genérico sin aprobación.

### Pantalla 1 / Inicio
- Con el módulo opcional **Pantallas interactivas** instalado, presentar escenas/animaciones del jugador base: poses, dominios, entrenamiento, tiros libres, penaltis, conducción y acciones de partido, con camisetas de Cuba.
- Sin el módulo, mostrar una imagen fija: duelo Cuba–Estados Unidos, minuto 90+3, marcador 2–2 antes del disparo; jugador base golpeando desde fuera del área, defensores rivales y portero lanzándose para detener el balón; estadio lleno y banderas de ambas selecciones ondeando.
- La escena será original y no reproducirá capturas, marcas ni recursos protegidos de otros juegos.
- El módulo será opcional; el juego base debe funcionar con la imagen fija.

## 12. Cuenta Nova Nexus y acceso a funciones

- Descargar módulos y jugar Online requerirá una cuenta Nova Nexus activa y autenticada.
- El juego base offline y los modos locales ya instalados seguirán funcionando sin conexión, salvo las funciones que dependan explícitamente de servicios online.
- Icono de usuario en la esquina superior izquierda del menú principal.
- Sin sesión: icono gris de silueta; al seleccionarlo, abrir el enlace oficial de Nova Nexus para iniciar sesión o registrarse.
- Con sesión: abrir panel de cuenta con nombre de usuario visible/editable según disponibilidad, perfil, privacidad, seguridad, estado de sincronización, juegos de Nova Apps y opciones de cuenta.
- Definir manejo de expiración de sesión, cierre de sesión, revocación, errores de red y modo sin conexión.
- No guardar contraseñas directamente en el juego. Usar autenticación segura y tokens protegidos según plataforma.

## 13. Menú 4: estadísticas y módulos

En Configuración (cuarta pantalla raíz) añadir:
- **Estadísticas:** estadísticas generales del juego y estadísticas independientes por modo. Resúmenes claros, comparaciones y filtros sencillos; no mezclar estadísticas de carreras diferentes.
- **Módulos:** catálogo instalado/disponible y categorías. Cada módulo muestra versión, tamaño, compatibilidad, dependencias, estado, permisos, origen y requisitos de Nova Nexus.

Categorías iniciales normalizadas (eliminar duplicado “gráfico/gráficos”):
1. Gráficos.
2. Música y canciones.
3. Realismo y simulación.
4. Plantillas y jugadores.
5. Ligas y competiciones.
6. Selecciones nacionales.
7. Habilidades y movimientos.
8. Estadios y ambientes.
9. Comentarios y audio.
10. Pantallas interactivas.
11. Herramientas y otros.

La arquitectura debe permitir añadir categorías. Los módulos deben ser versionados, verificables, instalables/desinstalables y declarar dependencias. Retirar un módulo no debe corromper partidas; si una partida depende de contenido ausente, advertir y ofrecer recuperación segura.

## 14. Perfil de jugador y creador de Leyenda

Los campos siguientes definen el perfil de ejemplo del jugador base, no valores que deban copiarse a todos los futbolistas generados:

| Campo | Valor del jugador base |
|---|---|
| Nombre completo | Anier Alejandro Cumbá Ibar |
| Nombre a mostrar | Anier Cumbá |
| Nombre en uniforme | Cumbá |
| Número favorito | 35 |
| País de nacimiento | Cuba |
| Selección preferida | Brasil, sujeto a elegibilidad y normativa internacional |
| Equipo favorito | Real Madrid (solo creador y ficha de jugador creado) |
| Primera posición | Mediocampista ofensivo |
| Segunda posición | Mediocampista central |
| Fecha de nacimiento | 14/04/2001 |
| Altura | 171 cm |
| Peso | 65 kg |
| Especialización | Velocista |

Reglas:
- El número favorito no se asigna automáticamente si ya está ocupado; el jugador debe ganárselo según disponibilidad y decisiones del equipo.
- La segunda posición debe pertenecer al mismo grupo/área funcional que la primera, según taxonomía posicional.
- Fecha de nacimiento con selector de calendario; unidades de altura y peso fijas en cm y kg.
- Especialización obligatoria en el creador; catálogo extensible: velocista, regateador, organizador, pasador, rematador, especialista en larga distancia, defensor, recuperador, físico, creador de juego, portero y otras que se definan.
- Para todos los jugadores generados se respetarán plantillas reales disponibles, cantidades, dorsales y niveles oficiales cuando exista información fiable y legalmente utilizable. Si faltan datos, usar el modelo ficticio y las reglas ya documentadas; no inventar que una cifra es oficial.
- El jugador base será el jugador insignia y tendrá una valoración global exactamente un punto superior al mejor jugador real identificado en la calibración vigente, dentro de la escala máxima del juego. Registrar fuente, fecha de corte, escala y cálculo. Si el mejor jugador real alcanza el máximo de la escala, revisar la escala o tratar la regla como pendiente; no exceder límites silenciosamente.
- El jugador insignia tendrá atributos individuales coherentes con su posición/especialización, no solo una media inflada.

## 15. Decisiones abiertas que requieren confirmación posterior

1. Moneda única: elegir nombre, símbolo y convención visual.
2. Fórmula exacta de valoración del club, reservas obligatorias y política de dividendos.
3. Porcentaje/tarifa interna de compensación de formación cuando la normativa FIFA no sea directamente aplicable.
4. Agrupación final y nombres de pantallas de Manager y Leyenda.
5. Frecuencia y reglas de eventos de Vida social y su impacto en reputación.
6. Escala máxima de valoración para permitir que el jugador insignia supere en un punto al mejor jugador real.
7. URL oficial de Nova Nexus que debe abrir el icono de usuario, si no está ya definida en la integración.
8. Arte original del jugador base: retrato de carga y modelo/imagen para Inicio.
9. Catálogo real de nombres disponibles para comentarios y licencias de voz.

## 16. Referencias públicas de investigación en GitHub (candidatas, no integradas)

Estas referencias se investigan como inspiración técnica. No copiar código, recursos, datos ni lógica protegida sin revisión de licencia, procedencia, dependencias, seguridad y compatibilidad. Cada integración requiere aprobación del propietario.

- `thedivergentai/Game-Dev-Agentic-Skills`, `skills/godot-genre-sports/SKILL.md`: guía de física de balón, efecto Magnus, IA por posiciones/formaciones, lógica arbitral y autoridad de validación. URL: https://github.com/thedivergentai/Game-Dev-Agentic-Skills/blob/main/skills/godot-genre-sports/SKILL.md
- `Youngermaster/Street-Kickoff`, `scripts/match/player_controller.gd`: controlador 3D con aceleración/frenado, giro y conducción mediante balón físico independiente y control por proximidad. URL: https://github.com/Youngermaster/Street-Kickoff/blob/master/scripts/match/player_controller.gd
- `zocram4cc/GodotFootball`, `docs/plans/godotfootball-foundation-plan.md`: arquitectura de motor de partido determinista, pruebas reproducibles y separación de motor de simulación respecto a interfaz. URL: https://github.com/zocram4cc/GodotFootball/blob/main/docs/plans/godotfootball-foundation-plan.md
- `sergiomanzur/issd-native`, `docs/GAMEPLAY_PHYSICS_ENGINE.md`: documentación técnica de movimiento, geometría de campo, aerodinámica, fricción y rebote del balón. Es una investigación/reconstrucción de un juego antiguo; usar solo conceptos generales y no incorporar código o tablas derivadas sin revisión. URL: https://github.com/sergiomanzur/issd-native/blob/master/docs/GAMEPLAY_PHYSICS_ENGINE.md
- Godot Engine docs, recurso de paquetes PCK: https://docs.godotengine.org/en/stable/tutorials/export/exporting_pcks.html — mecanismo oficial para cargar paquetes de contenido externos; evaluar para módulos descargables, con manifiestos, hashes, firmas y migraciones propios.

- `AKM-8byte/FreeKick` (MIT): módulo de entrenamiento de tiros libres con física configurable del balón (falso/efecto Magnus, resistencia, rebote), contacto de pie procedimental con IK, barrera y portero con tiempos de reacción, red física y repeticiones cinematográficas desde varias cámaras. Posible adaptación: ampliar el entrenamiento de Fútbol Nova y reutilizar patrones de prueba/calibración, tras auditar por separado código, dependencias y assets. No integrar el proyecto completo. URL: https://github.com/AKM-8byte/FreeKick — licencia MIT visible en el repositorio.

**Estado de las referencias:** las candidatas de esta lista se evalúan individualmente. Las propuestas aprobadas se detallan en las secciones 18–22; su aprobación no significa que estén implementadas.

## 17. Referencia reglamentaria para formación y solidaridad

- FIFA Clearing House, explicación oficial de training compensation y solidarity contribution: https://inside.fifa.com/transfer-system/clearing-house/regulations-and-explanatory-notes
- FIFA Regulatory Help Centre, mecanismo de solidaridad: https://support.fifatms.com/en/support/solutions/articles/7000097497
- FIFA Regulatory Help Centre, compensación por formación: https://support.fifatms.com/en/support/solutions/articles/7000097496

Las reglas y porcentajes deben comprobarse contra la edición aplicable antes de implementarse. La simulación podrá extender reglas equivalentes a transferencias domésticas ficticias, pero debe etiquetarlo como adaptación del juego.


## 19. Balones oficiales por liga y canteras en todas las divisiones

- Cada liga nacional tendrá un balón oficial propio, utilizado en Primera, Segunda, Tercera y todas las divisiones de esa misma estructura. Los partidos oficiales de liga lo asignan automáticamente; amistosos pueden permitir alternativas.
- Todos los clubes de Primera comienzan con cantera operativa. Los clubes de Segunda, Tercera y categorías inferiores comienzan sin cantera ni equipos juveniles. Podrán crear/activar una academia solo al cumplir los mismos requisitos de licencia de asociación, instalaciones o convenios, personal cualificado, protección juvenil, presupuesto y solvencia operativa establecidos para Segunda; no se rebajan los requisitos por competir en una división inferior.
- Las academias juveniles se conectarán a scouting, plantillas, calendarios, competiciones juveniles, promoción y compensación formativa.
- Investigar y utilizar preferentemente assets CC0/dominio público o diseños originales. La etiqueta CC0 de un archivo no demuestra ausencia de todos los derechos de diseño industrial/marca en todos los territorios; conservar procedencia y verificación por asset.
- Especificación: [Balones oficiales por liga y sistema de canteras](LEAGUE_BALLS_AND_YOUTH_ACADEMIES.md).

## 18. Propuesta aprobada para adaptar: control físico del balón por proximidad

**Origen de referencia:** `Youngermaster/Street-Kickoff`, archivo `scripts/match/player_controller.gd` (referencia de estudio; no copiar código ni parámetros sin verificar licencia y compatibilidad). URL: https://github.com/Youngermaster/Street-Kickoff/blob/master/scripts/match/player_controller.gd

**Decisión del propietario:** APROBADA para adaptar el concepto a Fútbol Nova. Esta aprobación autoriza el diseño y la futura implementación original; no autoriza copiar el código fuente del proyecto de referencia ni significa que la función esté integrada o probada.

### Comportamiento deseado en Fútbol Nova
- El balón seguirá siendo un objeto físico independiente; no quedará fijado rígidamente al jugador ni a un hueso.
- El control se calculará mediante distancia, orientación, velocidad relativa, superficie de contacto, estado de la animación y contexto del juego.
- En conducción normal, el jugador aplicará contactos/impulsos graduados para mantener el balón en una zona alcanzable delante o al costado del cuerpo.
- La aceleración, el sprint, los cambios bruscos de dirección y los giros afectarán la separación y la calidad del toque; los jugadores con mejores atributos y habilidades podrán controlar mejor, sin eliminar el riesgo de perder el balón.
- La posesión será contextual y podrá perderse automáticamente si el balón sale del alcance efectivo, un rival lo intercepta o un contacto lo desvía. No se dependerá de una bandera de posesión aislada como única fuente de verdad.
- Después de un pase o disparo se aplicará una ventana breve de liberación para impedir que el sistema de conducción absorba de nuevo el balón inmediatamente.
- El control táctil y los controles físicos deberán producir el mismo comportamiento de simulación.
- La mecánica respetará entradas, barridas, faltas, fueras de juego, animaciones, habilidades y reglas ya definidas; no otorgará posesión artificial ni permitirá atraer el balón a través de rivales.

### Adaptación y validación pendientes
- Diseñar parámetros por atributos, posición, pie dominante, fatiga, velocidad y tipo de toque; no copiar constantes del prototipo de referencia.
- Definir cómo se combinan el control de proximidad, los pases, los disparos, la protección y las técnicas de regate ya especificadas.
- Preparar pruebas reproducibles: conducción recta, giro de 90°/180°, sprint, frenado, primer toque, pérdida de balón, intercepción, pase y disparo.
- Medir estabilidad física y rendimiento en Android antes de aprobar el balance final.

**Estado:** concepto aprobado y documentado; diseño detallado pendiente; código no integrado; pruebas no realizadas.


## 19. Propuesta aprobada para adaptar: gestión e integridad de partidas guardadas

**Origen de referencia:** `MathewHDYT/Godot-Data-Manager`. URL: https://github.com/MathewHDYT/Godot-Data-Manager

**Decisión del propietario:** APROBADA para adaptar sus conceptos a Fútbol Nova. No autoriza copiar código automáticamente ni significa que el sistema esté integrado o probado.

**Licencia de referencia:** MIT (archivo `LICENSE` consultado). Si se reutiliza código en el futuro, conservar el aviso y las condiciones de licencia. Se prefiere una implementación original basada en los requisitos del juego.

### Capacidades verificadas
La documentación describe operaciones para crear y registrar archivos, leerlos, cambiar su ubicación, reemplazar o añadir contenido, comparar hashes y eliminar archivos registrados. También documenta errores de rutas incorrectas, archivos ausentes/corruptos, parámetros inválidos y archivos ya existentes.

**Compatibilidad:** el README declara Godot 2.0 y utiliza una API antigua de archivos. No debe incorporarse directamente al proyecto Godot 4.x; sus ideas deben rediseñarse y verificarse con APIs actuales.

### Adaptación aprobada para Fútbol Nova
- Administrador centralizado de guardados, con perfiles y espacios independientes para Manager, Leyenda y otras carreras.
- Operaciones diferenciadas para crear, leer, actualizar, añadir registros, verificar integridad, restaurar copias y eliminar guardados, con confirmaciones y validaciones.
- Errores claros y recuperables para fallos de lectura/escritura, falta de espacio, archivos incompletos, versiones incompatibles y datos corruptos.
- Hashes para detectar alteraciones o daños accidentales. Un hash por sí solo no garantiza autenticidad ni evita trampas; los datos sensibles requieren medidas adicionales.
- Evaluar compresión sin imponerla cuando el coste de CPU afecte a dispositivos Android modestos.
- Separar datos serializados del estado de escenas/nodos para evitar acoplar toda la carrera a la estructura visual.
- Versionado de esquema y migraciones para actualizar partidas antiguas de forma segura.
- Integración con el autoguardado ya especificado: instantánea coherente en un punto seguro, escritura fuera del hilo de renderizado mediante cola controlada, escritura atómica y conservación de la última copia válida.
- Confirmar el guardado solo después de terminar y verificar la escritura. Ante un error, conservar el último guardado válido y comunicar que el nuevo punto no se confirmó.
- No atribuir al repositorio de referencia guardado asíncrono, escritura atómica, copias rotativas o migraciones: son requisitos propios de Fútbol Nova que deberán diseñarse por separado.

### Diseño y pruebas pendientes
- Definir formato, estructura de carpetas, número de copias y política de retención.
- Diseñar cola de escritura e instantáneas sin bloquear la simulación.
- Definir cifrado y gestión de claves solo si existe una necesidad real; nunca incrustar claves estáticas en el juego.
- Probar cierres inesperados, falta de espacio, archivos truncados, hashes incorrectos, versiones antiguas, migraciones fallidas, restauración y múltiples perfiles.
- Medir tiempo de guardado, memoria/CPU e impacto en FPS en Android.

**Estado:** concepto aprobado y documentado; arquitectura detallada pendiente; código no integrado; pruebas no realizadas.


## 20. Propuesta aprobada para adaptar: cinemática inversa (IK) para animaciones corporales

**Origen de referencia:** `monxa/GodotIK`. URL: https://github.com/monxa/GodotIK

**Decisión del propietario:** APROBADA para adaptar sus funciones a Fútbol Nova. La aprobación autoriza diseñar una solución compatible e investigar la reutilización permitida; no significa que la extensión esté integrada, compilada para Android o probada.

**Licencia y compatibilidad declaradas:** el repositorio publica licencia MIT y describe una implementación FABRIK para Godot 4.3 o posterior basada en `SkeletonModifier3D`. La compatibilidad exacta debe contrastarse con la versión concreta de Godot utilizada por Fútbol Nova y con sus exportaciones Android.

### Capacidades de referencia revisadas
- Solución iterativa FABRIK para ajustar cadenas de huesos hacia posiciones objetivo.
- Efectores que definen cadenas de huesos y transformaciones objetivo.
- Restricciones personalizadas y límites de rotación.
- Suavizado y opción de estiramiento de huesos.
- Número de iteraciones configurable para equilibrar precisión y coste.
- Arquitectura mediante clases de raíz, efectores y restricciones; la referencia incluye implementación nativa/GDExtension.

### Adaptación aprobada para Fútbol Nova
- Usar IK como complemento de las animaciones existentes, nunca como sustituto general de las animaciones deportivas.
- Prioridad inicial: ajustar el pie y la pierna de apoyo/contacto al balón durante pases, disparos, controles y determinadas técnicas, respetando el objetivo de contacto y la ventana temporal de la animación.
- Aplicar IK de forma selectiva a porteros: alcance de manos en estiradas, blocajes, despejes y aterrizajes.
- Evaluar ajustes limitados de postura y extremidades en disputas físicas cuando mejoren el contacto sin deformar cuerpos ni atravesar rivales.
- Mantener animaciones base deterministas y utilizar IK solo cuando el contexto, la pose y la calidad del esqueleto lo permitan.
- Incorporar límites anatómicos/articulares y suavizado para evitar giros imposibles, vibraciones o cambios bruscos.
- Desactivar o reducir IK en jugadores lejanos, situaciones no visibles o dispositivos con presupuesto de rendimiento limitado; establecer niveles de calidad configurables.
- Garantizar equivalencia funcional entre controles táctiles y mandos: IK responde al estado de simulación y no al tipo de dispositivo de entrada.

### Límites, riesgos y validación pendientes
- Verificar la versión exacta de Godot: la referencia indica Godot 4.3+; no asumir compatibilidad automática con versiones anteriores.
- Auditar GDExtension, compilación C++, ABI y exportación Android (incluido arm64-v8a); considerar una alternativa GDScript/nativa integrada si la extensión complica la distribución.
- Comprobar licencias y avisos de cualquier código reutilizado; MIT no concede derechos sobre assets de terceros que pudiera incluir una demo.
- Validar esqueletos, nombres y jerarquías de huesos, retargeting, escala y animaciones de cada modelo.
- Medir coste de iteraciones y número de personajes simultáneos en Android; limitar jugadores con IK activo y ajustar calidad según rendimiento.
- Probar contactos de pie, piernas de apoyo, porteros, límites articulares, cambios de animación, colisiones, multijugador y comportamiento cuando falta un efector.
- Comparar la calidad visual y el rendimiento con IK activado/desactivado antes de decidir su configuración predeterminada.

**Estado:** concepto aprobado y documentado; diseño detallado pendiente; integración/compilación no realizadas; pruebas no realizadas.


## 21. Propuesta aprobada para adaptar: laboratorio de tiros libres y sistemas de entrenamiento

**Origen de referencia:** `AKM-8byte/FreeKick`. URL: https://github.com/AKM-8byte/FreeKick

**Decisión del propietario:** APROBADA para adaptar sus funciones a Fútbol Nova. Observaciones del propietario: sin observaciones. Esta aprobación permite diseñar la adaptación; no autoriza copiar el proyecto completo ni implica integración o pruebas.

**Licencia y versión revisadas:** el repositorio contiene licencia MIT (copyright 2026 Ahmet Kayra Maden) y solicita conservar el aviso de copyright y permiso en copias o partes sustanciales reutilizadas. Su README y `project.godot` identifican Godot 4.7/4.7.2. La compatibilidad con la versión concreta de Fútbol Nova debe verificarse antes de reutilizar código.

### Capacidades verificadas en los archivos consultados
- Escenario independiente de entrenamiento de tiros libres, con posiciones de balón configurables.
- Ajuste de dirección mediante selección/arrastre sobre la portería y selección del punto de contacto sobre el balón.
- Potencia de disparo graduable y efectos derivados del punto de impacto: altura, curva lateral y disparo de trayectoria irregular.
- Perfiles de física configurables para masa, radio, gravedad, rebote, fricción, resistencia, efecto Magnus y efecto de balón sin rotación estable.
- Barrera de uno a cinco defensores, con distancias y posiciones ajustables.
- Portero con niveles de dificultad y comportamiento de preparación, lectura, salto, aterrizaje y recuperación.
- Personaje procedural con IK de dos segmentos para piernas y brazos; el análisis del proyecto documenta la actualización de objetivos de IK y su relación con el contacto real del pie.
- Repeticiones cinematográficas desde siete ángulos y registro de datos del disparo.
- Tutorial interactivo y entradas de teclado/mandos en el proyecto de referencia.

### Adaptación aprobada para Fútbol Nova
- Incorporar un modo o sección de entrenamiento de tiros libres integrado en el menú de entrenamiento, sin sustituir el modo de partido.
- Permitir configurar distancia, posición lateral, número y colocación de defensores, dificultad del portero y perfil de práctica.
- Adaptar la selección del punto de contacto y la potencia para ofrecer disparos con distintas alturas, curvas y trayectorias, conservando los atributos, habilidades y controles propios de Fútbol Nova.
- Evaluar perfiles físicos como recursos configurables para pruebas y balance; el juego no debe cambiar arbitrariamente de perfil entre entrenamiento y partido.
- Adaptar la barrera y las respuestas del portero a las reglas, atributos, animaciones, colisiones y sistemas de IA de Fútbol Nova.
- Incorporar repeticiones de tiros libres y herramientas de análisis (dirección, potencia, contacto, velocidad, giro y resultado) cuando los datos puedan obtenerse de forma fiable.
- Usar el tutorial como referencia para una guía interactiva compatible con controles táctiles y mandos.
- Aprovechar pruebas automatizadas de física, contacto, colisiones, portero y rendimiento como modelo para la futura batería de pruebas de Fútbol Nova.
- Mantener separados los sistemas reutilizables del modo de entrenamiento y el simulador completo de partidos. La IK descrita aquí se coordinará con la propuesta 03, evitando implementar dos solucionadores incompatibles o duplicar trabajo.

### Límites, riesgos y validación pendientes
- No importar el proyecto completo: contiene escenas, modelos, interfaz, configuración y decisiones de diseño específicas de un entrenador de tiros libres, no de un simulador de partidos completo.
- Confirmar compatibilidad de APIs y escenas con la versión de Godot de Fútbol Nova; el proyecto de referencia está en Godot 4.7.2.
- Auditar cada archivo/asset que se pretenda reutilizar y mantener avisos MIT donde corresponda; verificar por separado los derechos de terceros sobre recursos incluidos.
- Reconciliar el modelo físico con el balón y los perfiles de Fútbol Nova para evitar discrepancias entre entrenamiento y partidos.
- Evitar que el modo de entrenamiento conceda goles o resultados garantizados: el desenlace debe surgir de la física, el portero, la barrera y las reglas del juego.
- Medir rendimiento en Android, especialmente física, efectos, repeticiones, cámaras, IK y múltiples personajes; ofrecer calidad escalable.
- Diseñar controles táctiles desde el inicio; no trasladar sin adaptación una interfaz pensada principalmente para teclado y ratón.
- Probar tiros con distintos contactos, distancias, perfiles, barreras, porteros, rebotes, colisiones, reinicios y repeticiones; comparar resultados entre dispositivos y tasas de fotogramas.

**Estado:** concepto aprobado y documentado; diseño detallado pendiente; código no integrado; pruebas no realizadas.


## 22. Propuesta aprobada para adaptar: simulación táctica y coordinación colectiva

**Origen de referencia:** `zocram4cc/GodotFootball`. URL: https://github.com/zocram4cc/GodotFootball

**Decisión del propietario:** APROBADA para investigar y adaptar las funciones tácticas independientes que sean útiles para Fútbol Nova. La instrucción del propietario autoriza incorporar sus principios y capacidades compatibles al diseño del juego. No autoriza importar el proyecto completo, depender de PES 2021 ni reutilizar código, datos o recursos protegidos de PES.

**Licencia y atribuciones revisadas:** el repositorio declara Apache License 2.0 y contiene NOTICE con atribuciones sobre componentes derivados de GameplayFootball/Google Research Football y aportes comunitarios. Cualquier reutilización futura debe auditar archivo por archivo la licencia, procedencia y avisos. La licencia del repositorio no concede derechos sobre contenido de PES ni sobre recursos externos que no distribuya.

### Capacidades y arquitectura identificadas
- Motor de partido orientado a simulación AI-vs-AI, con separación entre simulación y representación de Godot.
- La simulación se presenta como determinista/reproducible y separada en una librería headless, lo que puede inspirar pruebas repetibles y simulación de resultados sin renderizar cada partido.
- Sistemas tácticos y de comportamiento colectivo que pueden servir como referencia conceptual para decisiones de equipo, movimientos sin balón y coordinación.
- La integración del repositorio está fuertemente ligada a herramientas nativas: C++20, CMake, Ninja, zlib, SQLite3, Boost headers, Godot 4.7.2 y GDExtension.
- El README describe dependencias de instalación de PES 2021, ejecutable/memory dump y extracción de recursos del juego para la ejecución completa. Esas dependencias quedan expresamente excluidas de Fútbol Nova.

### Adaptación aprobada para Fútbol Nova
- Diseñar un **motor táctico independiente de la presentación visual**, con estados y decisiones expresados mediante datos y eventos del partido.
- Mejorar la coordinación de los once jugadores: ocupación racional de espacios, apoyos, desmarques, líneas de pase, coberturas, permutas, amplitud, profundidad y compactación.
- Adaptar comportamientos colectivos para fases de juego: ataque organizado, defensa organizada, presión, repliegue, transición ofensiva y transición defensiva.
- Incorporar roles e instrucciones coherentes con formación, posición, atributos, resistencia, habilidades, marcador, minuto, localía y estrategia del entrenador.
- Crear una capa de toma de decisiones con prioridades y límites claros: las tácticas orientan decisiones, pero no teletransportan jugadores, no fuerzan pases imposibles y no ignoran física, animaciones, colisiones, faltas o reglas.
- Compartir principios de decisión entre partidos jugados y simulación rápida de temporadas, pero permitir niveles de detalle diferentes. Los partidos no renderizados pueden resolver eventos mediante simulación estadística/táctica sin cargar escenas 3D completas.
- Añadir escenarios de prueba reproducibles para evaluar formaciones, presión, bloque bajo/alto, transiciones, superioridades, fatiga y comportamiento ante distintos marcadores.
- Registrar métricas tácticas útiles: recuperaciones, progresión, espacios concedidos, apoyos, líneas de pase, presión efectiva, ocasiones y transiciones. Evitar métricas que no puedan medirse de forma consistente.
- Integrar las decisiones del entrenador/Manager con el comportamiento colectivo, sin conceder al usuario control absoluto sobre acciones individuales fuera de los controles previstos.
- Mantener compatibilidad con los controles táctiles y mandos: el motor táctico debe funcionar igual independientemente del dispositivo de entrada.

### Exclusiones obligatorias y límites
- No exigir, descargar ni consultar una instalación de PES 2021, su ejecutable, memory dump ni sus archivos internos.
- No incluir modelos, texturas, esqueletos, animaciones, plantillas, datos, nombres de archivos extraídos ni valores reconstruidos de PES.
- No copiar código o tablas de ingeniería inversa de PES. Implementar modelos, datos, reglas y calibración originales, o usar datos con licencia y procedencia verificadas.
- No adoptar el stack C++20/GDExtension por defecto. Primero diseñar una implementación GDScript/Godot nativa o un núcleo pequeño y aislado; solo justificar C++ si mediciones reales demuestran que es necesario.
- No incorporar automáticamente dependencias de CMake, Boost, SQLite o bibliotecas específicas de PES. Evaluarlas por separado y solo si existe una necesidad comprobada.
- La arquitectura del repositorio de referencia es compleja para el objetivo Android y no se considera una dependencia lista para integrar.

### Diseño, compatibilidad y pruebas pendientes
- Identificar con lectura de código las rutinas concretas de lógica táctica independientes de PES antes de reutilizar cualquier fragmento; la aprobación actual cubre la adaptación conceptual.
- Diseñar interfaces de entrada/salida estables para el motor táctico: estado del partido, posiciones, atributos, fatiga, roles, instrucciones y eventos; salida de decisiones y objetivos, no control directo de nodos visuales.
- Definir determinismo, semillas, paso temporal y tolerancias para que las pruebas sean repetibles.
- Verificar compatibilidad con la versión exacta de Godot usada por Fútbol Nova; el repositorio de referencia declara Godot 4.7.2.
- Medir CPU, memoria, número de agentes y duración de simulaciones en Android de gama baja y media.
- Probar partidos 11 contra 11, diferentes formaciones, presión, repliegue, coberturas, transiciones, fatiga, expulsiones, cambios, lesiones y situaciones de ventaja/desventaja.
- Comparar simulación rápida y partidos renderizados para detectar resultados tácticos incoherentes.
- Auditar licencias, atribuciones y dependencias antes de cualquier reutilización de código.

**Estado:** adaptación conceptual aprobada y documentada; investigación de rutinas concretas independientes de PES pendiente; diseño detallado pendiente; código no integrado; compilación y pruebas no realizadas.


## 23. Propuesta aprobada para adaptar: controles multiplataforma, cámara, física y estados de partido

**Origen de referencia:** `RobinNunkesser/gd-godot-crazy-cage-football`. URL: https://github.com/RobinNunkesser/gd-godot-crazy-cage-football

**Decisión del propietario:** APROBADA para adaptar las funciones útiles. Observaciones: sin observaciones. La aprobación cubre el diseño y adaptación selectiva, no la importación completa del proyecto ni una afirmación de integración o pruebas.

**Referencia y licencia:** la propuesta fue presentada como proyecto Godot 4.7, versión 0.2.5 y licencia MIT. Antes de reutilizar cualquier archivo deberán volver a comprobarse el contenido exacto de LICENSE, los avisos, la procedencia de cada recurso y la compatibilidad con la versión de Godot usada por Fútbol Nova. No asumir que todos los assets de una demostración están cubiertos por la licencia del código.

### Funciones aprobadas para adaptar

- **Capa de entrada independiente del dispositivo:** definir acciones de juego una sola vez y mapearlas a controles táctiles, teclado y mandos. La simulación recibirá acciones normalizadas, no eventos específicos de una interfaz.
- **Cámaras de partido:** ofrecer seguimiento contextual del balón/jugador, cámara dinámica y cámara de retransmisión. La cámara no debe alterar la simulación ni ocultar información esencial al usuario.
- **Física y contactos:** estudiar detección de impactos, señales de contacto, materiales físicos, rebotes y prevención de atravesamientos. Integrar los resultados con el balón físico independiente y el control contextual aprobados en la propuesta 18; evitar sistemas de colisión duplicados.
- **Máquina de estados del encuentro:** separar estados y transiciones de calentamiento, preparación, saque inicial, juego activo, interrupciones, gol, celebración, reanudación, descanso y finalización. Las reglas y el árbitro tendrán autoridad sobre las transiciones válidas.
- **IA configurable:** separar jugadores controlados por usuario de agentes controlados por IA y ofrecer niveles de dificultad mediante parámetros y decisiones, sin alterar injustamente atributos ni reglas.
- **Respuesta audiovisual:** eventos de contacto y ambiente podrán activar sonidos, efectos visuales y respuesta de cámara. Los efectos serán opcionales/configurables y no interferirán con la lectura del juego ni el rendimiento.
- **Localización:** preparar textos, etiquetas y mensajes mediante claves traducibles, sin incrustar frases de interfaz en la lógica.
- **Asignación de mandos:** detectar dispositivos disponibles y permitir asignación/reasignación de controles, con alternativa táctil y manejo de desconexión durante una sesión.

### Exclusiones

- No adaptar la premisa de fútbol dentro de una jaula ni los personajes esféricos: no corresponden al simulador de fútbol de Fútbol Nova.
- Excluir potenciadores arcade como congelar rivales o magnetizar el balón.
- No copiar dimensiones, fuerzas, masas, velocidades ni otros parámetros físicos sin calibración propia.
- No importar escenas, interfaz, modelos o recursos del proyecto completo por defecto.
- No permitir que la cámara, los efectos o el dispositivo de entrada cambien resultados de la simulación.

### Integración con otros sistemas de Fútbol Nova

- La capa de entrada alimentará el sistema de controles táctiles, gestos, habilidades y mandos ya especificado.
- La física de contactos deberá coordinarse con el control contextual del balón (sección 18), las animaciones IK (sección 20), el laboratorio de tiros libres (sección 21) y el motor táctico (sección 22).
- Los estados de partido serán la fuente común para pausas, faltas, fueras de juego, goles, sustituciones, lesiones, reinicios y autoguardado seguro.
- Las cámaras y efectos respetarán los modos de visualización y el presupuesto de rendimiento de Android.

### Diseño y validación pendientes

- Leer y auditar los scripts concretos antes de elegir cualquier fragmento reutilizable; la aprobación actual no identifica todavía archivos concretos que deban copiarse.
- Verificar versión de Godot, APIs, licencia, avisos y derechos de cada recurso.
- Definir mapa de acciones, prioridades cuando se usan pantalla táctil y mando simultáneamente, reasignación y recuperación tras desconexión.
- Definir reglas de transición de estados y probar interrupciones, goles, pausas, reinicios y cierre inesperado.
- Probar contactos rasantes/aéreos, rebotes, colisiones simultáneas y altas velocidades junto con el modelo de balón propio.
- Medir latencia de entrada, estabilidad de cámara, CPU, memoria y FPS en Android de gama baja y media.
- Probar accesibilidad, localización, efectos desactivados, diferentes relaciones de aspecto y distintas configuraciones de mando.

**Estado:** adaptación conceptual aprobada y documentada; auditoría de archivos y diseño detallado pendientes; código no integrado; pruebas no realizadas.


## 24. Propuesta aprobada para adaptar: física deportiva, arbitraje, validación y comportamiento táctico

**Origen de referencia:** `thedivergentai/Game-Dev-Agentic-Skills`, guía `skills/godot-genre-sports/SKILL.md`. URL: https://github.com/thedivergentai/Game-Dev-Agentic-Skills

**Decisión del propietario:** APROBADA para adaptar las funciones útiles. Observaciones: sin observaciones. La aprobación es conceptual y no significa que los scripts de la guía estén integrados ni probados.

**Referencia y licencia:** el repositorio declara Godot 4.7+ y LGPL-3.0. La guía contiene patrones y ejemplos de implementación; antes de reutilizar cualquier código concreto se deberá verificar el archivo, autoría, avisos y obligaciones LGPL. La preferencia inicial será implementar patrones equivalentes con código original de Fútbol Nova.

### Funciones aprobadas para adaptar

- **Modelo físico del balón:** estudiar resistencia del aire, efecto Magnus, giro, rebotes y fricción para pases, centros, tiros libres y disparos. Mantener un único modelo físico coherente con el balón independiente y el control contextual ya especificados.
- **Colisiones corporales diferenciadas:** evaluar zonas de cabeza, torso y piernas para cabezazos, controles de pecho, bloqueos y contactos. Evitar añadir formas de colisión excesivas o incompatibles con las animaciones.
- **Validación arbitral de goles:** comprobar la posición y trayectoria del balón, cruce completo de la línea, estado válido del encuentro y reglas aplicables antes de actualizar el marcador.
- **Autoridad arbitral y fases:** centralizar decisiones y transiciones de juego para goles, interrupciones, reanudaciones y estados del encuentro, coordinándose con la máquina de estados aprobada en la sección 23.
- **IA táctica por formaciones:** asignar posiciones, responsabilidades y coberturas; limitar la presión simultánea a los jugadores adecuados para evitar que todo el equipo persiga el balón.
- **Porteros con reacción humana:** introducir tiempos de reacción y margen de error dependientes de atributos, ángulo, velocidad, visibilidad y contexto del disparo; evitar reflejos perfectos.
- **Sincronización de movimiento y animación:** estudiar root motion y AnimationTree para mejorar giros, aceleraciones, frenadas y golpeos, sin permitir que la animación viole colisiones o reglas físicas.
- **Predicción de líneas de pase:** usar consultas físicas y evaluación contextual para que la IA valore obstáculos, rivales, compañeros y riesgo antes de pasar.
- **Acciones contextuales:** interpretar entradas según posesión, distancia, orientación, estado del jugador y fase del partido; compartir controles solo cuando la acción resultante sea clara y accesible.
- **Precisión de simulación:** evaluar detección continua de colisiones e interpolación física para reducir atravesamientos y vibraciones. Cualquier cambio de frecuencia física se decidirá mediante mediciones en Android, no por adoptar automáticamente los valores sugeridos en la guía.

### Límites y exclusiones

- No adoptar automáticamente los fragmentos de ejemplo ni asumir que son código listo para producción.
- No aumentar la frecuencia física a 120/240 ticks por segundo sin medir CPU, batería, memoria y estabilidad; mantener una configuración adecuada al dispositivo.
- No permitir que una consulta visual o una validación del cliente sea la autoridad final de goles en partidas online. La autoridad de servidor se diseñará junto con el sistema online.
- No duplicar balón, árbitro, IA, estados ni controles ya cubiertos por otras propuestas.
- No garantizar que un disparo, pase o intervención del portero produzca un resultado predeterminado: atributos, física, contexto y azar controlado deben conservar influencia.

### Coordinación con Fútbol Nova

- Física del balón: se coordina con el control contextual de la sección 18 y la práctica de tiros libres de la sección 21.
- Formaciones, presión y coberturas: se coordinan con el motor táctico de la sección 22.
- Contactos y animaciones: se coordinan con IK de la sección 20 y con las colisiones y estados de la sección 23.
- Árbitro, goles e interrupciones: compartirán una autoridad lógica única con la máquina de estados del encuentro.
- Acciones contextuales: se conectarán con controles táctiles, gestos, habilidades y mandos, sin saltarse requisitos ni reglas.

### Diseño, auditoría y pruebas pendientes

- Auditar los scripts concretos de la guía y sus dependencias antes de considerar cualquier reutilización.
- Verificar licencia LGPL-3.0, avisos, atribuciones y obligaciones de distribución si se reutiliza código.
- Definir unidades, masas, coeficientes, límites de giro y perfiles de superficie mediante calibración propia.
- Probar colisiones y controles de cabeza/pecho/pie, trayectorias con efecto, rebotes y tiros de alta velocidad.
- Probar goles válidos/no válidos, balón que cruza parcialmente la línea, rebotes en postes, interrupciones y reanudaciones.
- Probar formaciones y comportamiento 11 contra 11, transiciones, coberturas, líneas de pase y decisiones de portero.
- Medir CPU, memoria, batería y FPS en Android de gama baja y media; evaluar frecuencia física e interpolación con perfiles de calidad.
- Verificar sincronización entre movimiento físico y animación, incluyendo interrupciones, faltas, choques y pérdida de equilibrio.
- Probar la futura autoridad online del servidor frente a resultados manipulados del cliente.

**Estado:** adaptación conceptual aprobada y documentada; auditoría de código y diseño detallado pendientes; código no integrado; pruebas no realizadas.

## 25. Propuesta aprobada para adaptar: gestión de clubes, fichajes y simulación de temporadas

**Origen de referencia:** `openfootmanager/openfootmanager`. URL: https://github.com/openfootmanager/openfootmanager

**Decisión del propietario (2026-11-14):** APROBADA para preparar la adaptación de las funciones útiles junto con las propuestas 01–07. No se autoriza importar el proyecto completo ni incorporar código GPL-3.0 sin una revisión legal y técnica específica. La decisión autoriza el diseño de capacidades equivalentes con implementación propia para Fútbol Nova.

**Tecnologías y licencia declaradas por la referencia:** Rust, React, TypeScript, Tailwind, Tauri y SQLite; licencia GPL-3.0 según el README/archivo de licencia del repositorio. La arquitectura de referencia no coincide con el cliente Godot de Fútbol Nova y no se adoptará como dependencia por defecto.

### Capacidades identificadas y aprobadas para adaptar

- **Gestión de plantilla:** profundidad por posición, roles, planificación de plantilla, disponibilidad y desarrollo de futbolistas.
- **Mercado de transferencias:** compra, venta, negociación y movimientos entre clubes, con ventanas, presupuestos, aceptación de ofertas y reglas de competición configurables.
- **Contratos:** salarios, duración, renovaciones, primas, cláusulas y condiciones. Los importes deberán utilizar la moneda única todavía pendiente de decisión y conectarse al sistema financiero documentado.
- **Entrenamiento:** planificación de sesiones y desarrollo de atributos, respetando edad, potencial, carga, resistencia, calendario, lesiones y recuperación.
- **Personal técnico:** entrenadores, preparadores y otros empleados con funciones, habilidades, contratos y costes coherentes.
- **Ojeadores:** búsqueda de talentos, informes con incertidumbre y evaluación de atributos/potencial según calidad del informe; no revelar automáticamente todos los datos ocultos.
- **Noticias dinámicas:** acontecimientos relevantes de clubes, jugadores, competiciones, fichajes, resultados y decisiones de temporada.
- **Bandeja de entrada:** comunicaciones contextuales de directiva, jugadores, agentes, representantes y personal; las respuestas y decisiones deben producir consecuencias verificables.
- **Simulación de partidos por eventos:** resolver encuentros no renderizados con un motor táctico/estadístico coherente con las reglas, plantillas, forma, fatiga, tácticas y nivel de los equipos. Compartir principios con el partido jugado, sin exigir cargar escenas 3D.
- **Persistencia de temporadas:** conservar ligas, plantillas, contratos, finanzas, historial y carreras mediante el administrador de guardados aprobado en la propuesta 02.
- **Internacionalización:** preparar textos, mensajes y noticias para traducción mediante claves, en coordinación con la localización aprobada en la propuesta 06.

### Adaptación y coordinación con Fútbol Nova

- Integrar estas funciones en los modos Manager y Entrenador, manteniendo separadas las responsabilidades de entrenador, propietario, presidente y director ejecutivo.
- Conectar fichajes, salarios, primas, contratos y gastos de personal con el libro mayor, los presupuestos y la valoración de clubes; no crear una economía paralela.
- Aplicar las reglas ya documentadas para propiedad accionarial, conflictos de interés, elegibilidad, edades, cantera y compensación de formación.
- El entrenamiento y desarrollo deberán respetar los atributos, habilidades, potencial y progresión del catálogo propio de Fútbol Nova.
- Los eventos de noticias y bandeja de entrada deberán originarse en hechos reales de la simulación y no generar resultados deportivos por sí mismos.
- La simulación rápida debe ser reproducible bajo una semilla/configuración definida y guardar los eventos necesarios para historial, estadísticas y auditoría.
- Usar los mismos datos fundamentales de clubes, jugadores, reglas y calendario en partidos jugados y simulados; las diferencias de nivel de detalle no deben producir contradicciones sistemáticas.
- Mantener la experiencia navegable en pantallas agrupadas de Manager y Entrenador y optimizada para Android.

### Límites, licencia y validación pendientes

- No portar directamente el stack Rust/React/Tauri/SQLite a Godot ni añadir dependencias solo por imitación.
- No copiar ni enlazar código GPL-3.0 al ejecutable de Fútbol Nova sin una revisión de compatibilidad de licencias, obligaciones de distribución, avisos y arquitectura de separación. Preferencia: implementación original basada en requisitos funcionales.
- Auditar por separado cualquier base de datos, nombre, imagen, escudo, texto o recurso externo; la licencia del código no concede derechos sobre contenido de terceros.
- Revisar el código fuente de cada subsistema antes de decidir si alguna idea requiere una adaptación más específica; las capacidades enumeradas proceden de la descripción funcional revisada y no equivalen a una auditoría completa de implementación.
- Diseñar el modelo de transferencias, contratos, salarios, staff, scouting, entrenamiento, noticias y simulación; definir reglas, estados, validaciones y transacciones antes de programar.
- Probar ventanas de fichajes, negociaciones rechazadas/aceptadas, presupuestos insuficientes, renovaciones, vencimientos, lesiones, cargas de entrenamiento, informes incompletos y conflictos de calendario.
- Validar que temporadas completas se simulen con coherencia, que las estadísticas cuadren y que los guardados sobrevivan a cierres inesperados y migraciones.
- Medir CPU, memoria, duración de simulación y tamaño de guardados en Android de gama baja y media.

**Estado:** concepto aprobado y documentado; diseño detallado pendiente; auditoría de código fuente pendiente; código no integrado; compilación y pruebas no realizadas.

## 26. Plan maestro de adaptación conjunta de las ocho propuestas aprobadas

**Decisión del propietario (2026-11-14):** las ocho propuestas 01–08 quedan aprobadas para preparar una adaptación selectiva a Fútbol Nova. Este plan ordena su diseño e integración futura; no declara que el código esté implementado, compilado o probado.

### 26.1 Principios de arquitectura

- Mantener Godot 4.x/GDScript como primera opción y seleccionar una versión estable exacta mediante prueba real de compatibilidad. No añadir C++, GDExtension, Rust, bibliotecas externas o servicios por imitación: cada dependencia requiere justificación técnica y medición.
- Mantener separados presentación, gameplay, física, reglas/árbitro, IA individual, IA táctica, simulación de temporadas, carreras/gestión y persistencia.
- Definir modelos de dominio y contratos de datos comunes para jugador, club, balón, partido, evento, competición, temporada, contrato, transferencia, entrenamiento y guardado.
- El estado del partido y sus eventos serán la fuente de verdad para marcador, estadísticas, comentarios, repeticiones, noticias y persistencia. Ningún HUD, animación o cámara modificará el resultado deportivo.
- El motor de partido en tiempo real y el simulador rápido de temporadas compartirán entidades, reglas fundamentales y contrato de resultado/eventos, pero podrán usar niveles de detalle distintos.
- Registrar semillas, versiones de reglas y parámetros de simulación para reproducir errores y comparar balance.
- Mantener los sistemas jugables en funcionamiento offline. Las funciones Nova Nexus/online serán capas separadas y no requisito para carreras locales ya instaladas.
- Diseñar desde el principio para controles táctiles y rendimiento Android; teclado y mando serán entradas alternativas a las mismas acciones normalizadas.

### 26.2 Mapa de las ocho propuestas

| Propuesta | Subsistema destino | Dependencias y coordinación |
|---|---|---|
| 01 Street Kickoff | Control contextual del balón y primer toque | Física del balón, movimiento, posesión, entradas y acciones |
| 02 Godot Data Manager | Persistencia, perfiles, integridad y recuperación | Todos los modos; respeta cinco espacios por modo y espacio 1 reservado al autoguardado |
| 03 GodotIK | Ajuste procedural de extremidades y contacto corporal | Animaciones, esqueleto, balón, porteros y rendimiento |
| 04 FreeKick | Entrenamiento y jugadas a balón parado | Física común, barrera, portero, IK, reglas y tutorial |
| 05 GodotFootball | Coordinación táctica colectiva y simulación reproducible | IA, formaciones, eventos, fatiga y simulador de temporadas; excluir dependencias PES |
| 06 Crazy Cage Football | Entrada multiplataforma, cámara, estados y contactos | Controles, árbitro, física, interfaz y accesibilidad; excluir elementos arcade |
| 07 Game Dev Agentic Skills | Física deportiva, colisiones, árbitro y validación | Balón único, estados, goles, IA, animación y autoridad online futura |
| 08 Openfoot Manager | Gestión de plantillas, mercado, contratos, entrenamiento, staff, scouting, noticias y simulación de temporada | Datos de clubes/jugadores, economía única, carreras, calendario, motor táctico y guardados |

### 26.3 Orden de diseño e integración

**Etapa A — contratos y reglas compartidas**
1. Definir entidades, identificadores, unidades, estados, eventos y esquemas JSON versionados.
2. Definir una autoridad única para fases del partido, faltas, fueras de juego, goles, sustituciones y reanudaciones.
3. Definir contratos compartidos entre partido renderizado y simulación rápida.
4. Resolver la versión de Godot y la matriz mínima de dispositivos Android.

**Etapa B — núcleo de partido**
1. Normalizar entradas táctiles, teclado y mando.
2. Completar movimiento, aceleración, frenado, giro y orientación.
3. Implementar balón físico independiente, contactos, primer toque, posesión y liberación tras pase/disparo.
4. Implementar colisiones y validación de gol por cruce completo de línea.
5. Implementar estados del encuentro y eventos arbitrales.
6. Añadir pase, tiro, regate, entrada, despeje y acciones contextuales con reglas y atributos.
7. Crear pruebas deterministas de física, contactos, colisiones, goles y reanudaciones.

**Etapa C — animación, porteros y presentación**
1. Integrar animaciones base y transiciones antes de añadir IK.
2. Añadir IK de forma selectiva para pie-balón, porteros y contactos que mejoren la lectura visual.
3. Añadir cámaras de retransmisión, dinámica, táctica y jugador como presentación desacoplada.
4. Añadir audio, efectos y localización sin cambiar la simulación.
5. Escalar o desactivar IK, efectos y actualizaciones de agentes según distancia y presupuesto de dispositivo.

**Etapa D — IA y simulación**
1. Implementar percepción y decisiones individuales.
2. Añadir roles, formaciones, apoyos, desmarques, coberturas, presión, repliegue y transiciones.
3. Crear simulación rápida de partidos no renderizados con semillas y eventos reproducibles.
4. Comparar estadísticas y tendencias entre partidos jugados y simulados.
5. Calibrar resultados con datos autorizados y modelos propios; no copiar bases de datos ni parámetros protegidos.

**Etapa E — entrenamiento**
1. Construir el modo de práctica con el mismo balón, portero, reglas y acciones del partido.
2. Añadir tiros libres configurables, barrera, contacto, potencia, curva y análisis de repetición.
3. Añadir tutoriales táctiles y mando.
4. Reutilizar IK y física compartidas; no crear un simulador paralelo.

**Etapa F — carreras y gestión**
1. Definir clubes, plantillas, calendario, reglas y estados de temporada.
2. Implementar contratos, salarios, transferencias, negociaciones y presupuestos.
3. Implementar entrenamiento, desarrollo, lesiones, recuperación y personal técnico.
4. Implementar scouting con información gradual e incertidumbre.
5. Implementar noticias y bandeja de entrada impulsadas por eventos verificables.
6. Integrar propiedad, accionariado, vida social y economía personal ya documentados, sin duplicar el libro mayor.
7. Usar simulación rápida para encuentros no jugados y conservar historial, estadísticas y resultados.

**Etapa G — persistencia y recuperación**
1. Aplicar el sistema de guardado común a partido, entrenamiento, Manager y Leyenda.
2. Mantener cinco espacios por modo: espacio 1 solo autoguardado; espacios 2–5 para operaciones manuales/copias.
3. Versionar esquemas y migraciones; validar integridad y conservar la última copia válida.
4. Guardar transacciones económicas, contratos, transferencias, eventos, semillas y versiones de reglas de manera coherente.
5. Probar cierre inesperado, falta de espacio, archivo corrupto, actualización de versión y restauración.

**Etapa H — validación Android y equilibrio**
1. Medir FPS, CPU, memoria, batería, latencia de entrada, carga de escenas y tiempo de simulación.
2. Probar 22 jugadores, colisiones simultáneas, IK, cámaras, lluvia/efectos si se habilitan y partidos largos.
3. Ofrecer niveles de calidad que reduzcan coste visual sin alterar reglas ni resultados.
4. Ejecutar pruebas de regresión para partidos, temporadas, transferencias, contratos, estadísticas y guardados.
5. No marcar una etapa como terminada hasta tener proyecto ejecutable y pruebas reproducibles.

### 26.4 Exclusiones y control de licencias

- No importar proyectos completos ni copiar recursos visuales, audio, modelos, animaciones, bases de datos o marcas.
- GodotFootball: excluir PES 2021, sus ejecutables, dumps, recursos extraídos, datos y cualquier material derivado no autorizado.
- Openfoot Manager: no incorporar código GPL-3.0 ni enlazarlo al juego sin análisis específico de obligaciones y compatibilidad; preferir implementación propia.
- GodotIK, FreeKick y Crazy Cage Football: comprobar licencia de cada archivo y procedencia de assets; conservar avisos cuando corresponda.
- Game Dev Agentic Skills: revisar LGPL-3.0 antes de reutilizar fragmentos; preferir patrones implementados de forma original.
- No asumir que una licencia de repositorio cubre dependencias, fuentes de datos o contenido de terceros.
- Mantener inventario de fuente, commit, archivo considerado, licencia, atribución, cambios y destino de cualquier fragmento que eventualmente se reutilice.

### 26.5 Criterios de aceptación global

- Una sola fuente de verdad para estado, reglas, goles y estadísticas.
- El balón se comporta de forma coherente en partido y entrenamiento.
- Los jugadores responden a atributos, fatiga, habilidades y contexto sin ignorar reglas.
- La IA colectiva genera decisiones comprensibles y reproducibles.
- La simulación rápida conserva coherencia con datos y reglas de los partidos jugados.
- Las operaciones de gestión producen transacciones y eventos auditables.
- Las noticias y comunicaciones reflejan sucesos reales del universo de juego.
- Los guardados se recuperan sin perder el último estado válido.
- La experiencia táctil es funcional y el rendimiento se mide en Android objetivo.
- Cada función se identifica con estado explícito: concepto aprobado, diseño detallado, código integrado, compilación correcta y pruebas superadas.

**Estado:** plan maestro de adaptación preparado y documentado; diseño detallado por subsistema pendiente; código no integrado; compilación y pruebas no realizadas.

## 27. Modo Leyenda — confianza del entrenador y rol deportivo

**Origen:** captura aportada por el usuario el 14-11-2026, titulada visualmente «CONFIANZA DEL ENTRENADOR». La captura muestra una barra de confianza con cuatro rangos, umbrales 200, 600, 1300 y 1500, y el valor actual ilustrado en 1500. Los rangos visibles son «Jugador suplente», «Jugador de» (el texto de la captura aparece truncado/incompleto), «Titular habitual» y «Jugador clave». El mensaje explica que una mayor confianza permite jugar más minutos.

**Requisito solicitado:** añadir esta función al Modo Leyenda. El futbolista deberá ganarse la confianza del entrenador para acceder a un puesto de suplente o titular. La titularidad no será automática por valoración general ni por reputación.

### 27.1 Escala inicial de referencia

Usar una puntuación interna de confianza entre 0 y 1500, con los siguientes hitos iniciales derivados de la captura:

| Puntuación | Rol de plantilla | Consecuencia esperada |
|---:|---|---|
| 0–199 | Fuera de la rotación / jugador con poca confianza | No tiene minutos garantizados; puede quedar fuera de convocatoria |
| 200–599 | Jugador suplente | Puede entrar desde el banquillo y competir por minutos |
| 600–1299 | Jugador de rotación / candidato a titular | Puede alternar titularidad y suplencia según rendimiento, competencia y táctica |
| 1300–1499 | Titular habitual | Alta probabilidad de iniciar partidos, sin garantía absoluta |
| 1500 | Jugador clave | Prioridad alta en la alineación y mayor responsabilidad deportiva |

**Nota de interpretación:** la captura muestra cuatro franjas visuales y los valores 200, 600, 1300 y 1500. La franja intermedia está rotulada de forma incompleta como «Jugador de». El nombre «Jugador de rotación / candidato a titular» es una propuesta funcional para completar esa etiqueta, pendiente de confirmación visual si el usuario aporta una captura más nítida. Los rangos 0–199 y la distinción 1300–1499/1500 concretan una escala continua para el juego; no deben presentarse como lectura literal de cada píxel.

### 27.2 Cómo se gana o pierde confianza

La confianza se actualizará después de entrenamientos, partidos y acontecimientos relevantes, mediante factores trazables:
- Rendimiento individual respecto al rol y a los objetivos asignados.
- Cumplimiento de instrucciones tácticas y responsabilidades posicionales.
- Esfuerzo, disciplina, puntualidad y actitud en entrenamientos, si esos sistemas están activos.
- Consistencia durante varios partidos, no solo una actuación aislada.
- Evolución de atributos y adaptación a la posición/estilo del equipo.
- Decisiones profesionales y cumplimiento de compromisos deportivos.
- Conversaciones, reuniones o promesas del entrenador cuando el sistema de interacción esté disponible.

Podrá disminuir por bajo rendimiento repetido, incumplir objetivos o instrucciones, indisciplina, ausencias injustificadas, mala condición por falta de preparación o conflictos deportivos con consecuencias documentadas. No reducirla arbitrariamente por un mal resultado colectivo si el rendimiento individual fue bueno.

### 27.3 Selección de titulares, suplentes y minutos

- La confianza influye en la probabilidad de convocatoria, titularidad, orden de entrada desde el banquillo y minutos esperados, pero no será el único factor.
- El entrenador evaluará también posición, compatibilidad táctica, atributos, forma, resistencia, lesiones, sanciones, calendario, rival y nivel de los competidores por el puesto.
- Un jugador con 1500 de confianza puede descansar, rotar o quedar fuera por lesión, sanción, táctica, condición física o reglas de plantilla. La puntuación no debe anular decisiones futbolísticas razonables.
- Un jugador con poca confianza podrá ganarse oportunidades mediante entrenamientos, suplencias y actuaciones destacadas.
- Los minutos disputados alimentan la evaluación de rendimiento, evitando un círculo injusto en el que la falta de minutos impida indefinidamente demostrar capacidad. Incluir oportunidades graduales, partidos de copa, amistosos, rotación y objetivos de entrenamiento.
- La confianza será específica de la relación jugador–entrenador/club. Un cambio de entrenador podrá conservar un historial y aplicar una evaluación inicial nueva o parcialmente heredada, según reputación y datos disponibles; no transferir automáticamente 1500 a otro entrenador.
- Las decisiones del seleccionador nacional, cuando corresponda, usarán una relación de confianza separada de la del entrenador del club.

### 27.4 Presentación en el hub de Leyenda

Mostrar en la sección de relación deportiva:
- Puntuación actual y máximo de la escala.
- Barra segmentada por rangos y etiqueta del rol actual.
- Tendencia reciente (sube, estable o baja) y motivo principal del cambio.
- Rol esperado, competencia por puesto y próximos objetivos para progresar.
- Minutos recientes, titularidades y apariciones como suplente, con período claramente indicado.

La interfaz deberá explicar que más confianza suele dar más minutos, sin prometer titularidad automática. Accesible con texto/iconos además del color.

### 27.5 Balance y protección contra abusos

- Actualizar la confianza con límites por evento y ponderación temporal; evitar subir al máximo por un solo partido o entrenamiento.
- La evaluación debe considerar minutos jugados: una buena actuación en pocos minutos tiene valor, pero no se extrapola como rendimiento completo sin cautela.
- No premiar estadísticas vacías ni penalizar roles de sacrificio (marcaje, cobertura, presión, creación) por no marcar goles.
- La puntuación no sustituye valoración general, forma, moral, potencial, condición ni atributos; son sistemas distintos.
- Definir curvas y pesos exactos durante el balance con pruebas, no fijarlos por intuición.
- Probar trayectorias de canterano, suplente, titular, jugador clave, cambio de club y cambio de entrenador; verificar que cada rol sea alcanzable y reversible.

**Estado:** función solicitada y aprobada para diseño; referencia visual registrada; escala inicial propuesta a partir de la captura; pesos y fórmulas de actualización pendientes de balance; código no integrado; pruebas no realizadas.

## 28. Modo Leyenda — relación personal con el entrenador

**Origen:** ampliación propuesta por el asistente después de documentar la confianza del entrenador (sección 27). **Decisión del propietario (2026-11-14):** APROBADA; el usuario indicó «Sí, me gusta eso, añádelo».

**Objetivo:** complementar la puntuación deportiva de confianza con una relación personal/de comunicación entre el futbolista y su entrenador. Las conversaciones, reuniones, objetivos y promesas permitirán comprender las decisiones del entrenador, resolver desacuerdos y recuperar confianza. La relación personal y la confianza deportiva estarán conectadas, pero serán variables distintas.

### 28.1 Componentes de la relación

- **Relación personal:** indicador independiente que refleja respeto, comunicación y entendimiento mutuo. No equivale a amistad ni garantiza minutos.
- **Confianza deportiva:** puntuación de 0 a 1500 descrita en la sección 27; refleja la valoración del entrenador sobre la contribución y fiabilidad futbolística del jugador.
- **Estado de comunicación:** asuntos pendientes, conversaciones recientes, compromisos aceptados y reuniones solicitadas.
- **Historial:** decisiones, promesas, objetivos, respuestas y consecuencias, con fecha/temporada y entrenador correspondiente.

La relación personal no debe modificar directamente los atributos del futbolista ni forzar alineaciones. Puede influir moderadamente en la disposición a dialogar, explicar decisiones o negociar objetivos; la selección deportiva sigue basada en rendimiento, posición, táctica, forma, condición, sanciones, lesiones y confianza deportiva.

### 28.2 Conversaciones y respuestas

- Permitir iniciar conversaciones desde el apartado de relación con el entrenador y responder a mensajes que el entrenador envíe.
- Ofrecer temas contextuales, por ejemplo: minutos de juego, posición, rendimiento reciente, entrenamiento, objetivos, estado físico, rol en la plantilla, contrato cuando corresponda y desacuerdos deportivos.
- Presentar respuestas seleccionables con tono y contenido claros: profesional/constructivo, ambicioso, neutral, preocupado o confrontativo. Las opciones disponibles dependerán del contexto y la personalidad del jugador/entrenador si esos rasgos existen.
- Las respuestas deben producir consecuencias moderadas y trazables; no habrá una opción universal que siempre aumente la relación o la confianza.
- Evitar diálogos repetitivos: registrar asuntos ya tratados, enfriar temas y variar respuestas según acontecimientos reales.
- No permitir que una conversación cambie resultados de partidos ya disputados, elimine sanciones válidas o anule reglas del club/competición.

### 28.3 Objetivos individuales

- El entrenador podrá proponer objetivos adecuados al rol, posición, nivel, minutos y calendario: mejorar un atributo, cumplir tareas tácticas, mantener condición, participar en cierto número de partidos o alcanzar indicadores de rendimiento pertinentes.
- Cada objetivo mostrará descripción, plazo, criterio verificable, progreso y consecuencia posible antes de aceptarse.
- El jugador podrá aceptar, rechazar o solicitar una renegociación cuando el contexto lo permita.
- Evaluar objetivos según oportunidades reales: no penalizar por no alcanzar una meta de minutos si el propio entrenador no dio oportunidades razonables, ni exigir goles a un defensor por defecto.
- Completar objetivos puede mejorar gradualmente la confianza deportiva y/o la relación personal; fallar repetidamente puede reducirlas de forma proporcional, con explicación.
- Los objetivos vencidos, cancelados por lesión, cambio de entrenador o modificación táctica deberán cerrarse con una razón explícita.

### 28.4 Promesas de minutos y rol

- El jugador podrá solicitar claridad o negociar expectativas: participación como suplente, oportunidades de rotación, titularidad en determinados encuentros o revisión del rol después de un período.
- Las promesas serán compromisos con plazo, condiciones y ámbito definidos; nunca garantía absoluta de jugar si hay lesión, sanción, pérdida de condición, suspensión, competencia legítima o cambios tácticos justificados.
- Antes de aceptar, el entrenador evaluará si la promesa es realista según plantilla, calendario, posición y nivel del jugador.
- Registrar promesa, fecha límite, partidos elegibles, oportunidades realmente disponibles y cumplimiento.
- Si el entrenador incumple sin causa razonable, podrá deteriorarse la relación personal y la confianza deportiva; si el jugador no cumple condiciones pactadas, se explicará el efecto.
- No permitir que el jugador acumule promesas incompatibles ni que se contabilicen partidos en los que no estaba disponible.

### 28.5 Reuniones y recuperación de confianza

- Permitir solicitar reuniones cuando haya asuntos significativos: pérdida de titularidad, descenso de confianza, desacuerdo táctico, promesa incumplida, vuelta de lesión o cambio de rol.
- Las reuniones deben ofrecer contexto, opciones y resultados; su disponibilidad y tono dependen del estado de la relación y de los eventos de carrera.
- Proponer planes concretos de recuperación: objetivos de entrenamiento, tareas de rol, período de evaluación y revisión pactada.
- La recuperación requiere acciones y rendimiento sostenido; una reunión por sí sola no restaura automáticamente confianza ni titularidad.
- Evitar reuniones ilimitadas: aplicar enfriamiento y limitar solicitudes repetidas sobre el mismo asunto hasta que haya novedades.
- Un cambio de entrenador crea una nueva relación personal. Se conserva el historial anterior como antecedente, pero no se transfiere automáticamente el nivel personal ni la confianza deportiva.

### 28.6 Interfaz y accesibilidad

En el hub de Leyenda incluir una sección «Entrenador» con:
- Indicador separado de relación personal y confianza deportiva.
- Mensajes y asuntos pendientes.
- Acciones para conversar, solicitar reunión y revisar objetivos.
- Promesas vigentes, condiciones, fechas y progreso.
- Historial breve de decisiones y razones de cambios.
- Avisos cuando una promesa u objetivo esté próximo a vencer.

Usar etiquetas, iconos y texto además del color. Los diálogos deben ser breves, legibles en Android y navegables con pantalla táctil y mando. No bloquear el acceso a otras pantallas por una conversación opcional.

### 28.7 Reglas de simulación y pruebas

- Los eventos de relación se guardarán como datos de carrera versionados y se integrarán con el sistema de guardados de la sección 19/propuesta 02.
- Toda consecuencia debe derivarse de un evento identificable y conservar motivo, fecha, entrenador y cambio aplicado.
- Separar las variables: relación personal, confianza deportiva, moral, forma, reputación y atributos. No sumar ni duplicar sus efectos.
- Probar promesas cumplidas/incumplidas, objetivos imposibles, lesiones, falta de minutos por decisión táctica, cambio de entrenador, cambio de club, diálogos repetidos, guardado/carga y temporadas completas.
- Verificar que las interacciones no permitan explotar la economía, conseguir titularidad garantizada o aumentar al máximo la confianza mediante conversaciones repetidas.

**Estado:** función aprobada y documentada; diseño conceptual definido; valores, umbrales, fórmulas y catálogo de diálogos pendientes de diseño detallado y balance; código no integrado; pruebas no realizadas.

## 29. Modo Leyenda — reacciones y dinámica del vestuario

**Origen:** ampliación propuesta para complementar la confianza y relación personal con el entrenador (secciones 27 y 28). **Decisión del propietario (2026-11-14):** APROBADA; el usuario indicó «Hazlo».

**Objetivo:** crear un vestuario vivo donde los compañeros reaccionen a las actuaciones, comportamiento profesional, liderazgo, relación con el entrenador y situación deportiva del jugador controlado. El sistema permitirá amistades, rivalidades deportivas, respeto, apoyo y tensiones con consecuencias graduales en la vida del equipo.

### 29.1 Relaciones individuales y clima colectivo

- Cada compañero relevante podrá mantener una relación individual con el jugador de Leyenda: respeto, confianza, cercanía/amistad y tensión/rivalidad deportiva.
- Mantener un indicador separado de cohesión o clima colectivo del vestuario. No reducir todas las relaciones a una sola puntuación.
- Las relaciones se desarrollan a partir de experiencias compartidas y eventos verificables: entrenamientos, partidos, apoyo mutuo, competencia por el puesto, acciones de liderazgo, conflictos y decisiones profesionales.
- Los compañeros tendrán personalidades y reacciones diferenciadas, pero los rasgos deberán ser ficticios y servir a la simulación, no estereotipos basados en datos sensibles.
- No es necesario simular con detalle a todos los futbolistas del mundo: priorizar compañeros del primer equipo, juveniles relevantes y futbolistas con interacción reciente; aplicar simulación agregada al resto para ahorrar recursos.

### 29.2 Reacciones al rendimiento y comportamiento

Los compañeros podrán reaccionar, de forma contextual y proporcional, a:
- Buenas actuaciones, regularidad, goles, asistencias, paradas y contribuciones defensivas o tácticas.
- Errores importantes, bajo rendimiento repetido o incumplimiento de responsabilidades, sin convertir un error aislado en conflicto permanente.
- Apoyo a un compañero, trabajo colectivo, generosidad en el campo y conducta profesional.
- Actitud en entrenamientos, disciplina, puntualidad y cumplimiento de compromisos, cuando estos sistemas estén activos.
- Competencia por titularidad, cambios de rol, llegada de fichajes y reparto de minutos.
- Relación con el entrenador, capitanía, reconocimiento del equipo y decisiones que afecten al grupo.
- Resultados colectivos y acontecimientos relevantes del club.

Las reacciones podrán expresarse mediante mensajes, comentarios, conversaciones, gestos o cambios graduales de relación. No todos los compañeros deben reaccionar a cada evento; evitar notificaciones excesivas.

### 29.3 Amistades y apoyo entre compañeros

- Las amistades podrán desarrollarse mediante entrenamientos compartidos, apoyo en momentos difíciles, convivencia y experiencias deportivas.
- Un compañero cercano podrá ofrecer apoyo, consejos, felicitaciones o conversaciones privadas; el jugador podrá corresponder o mantener distancia.
- La cercanía podrá mejorar moderadamente la cooperación y la disposición a apoyarse en situaciones narrativas, pero no otorgará bonificaciones deportivas automáticas ni garantizará pases.
- Las amistades pueden mantenerse, enfriarse o cambiar por transferencias, falta de contacto, conflictos o cambios de equipo.
- Permitir que el jugador apoye a compañeros suplentes, juveniles o recién llegados para integrarlos en el grupo.

### 29.4 Rivalidades deportivas y conflictos

- Las rivalidades podrán surgir por competencia directa por una posición, disputa de minutos, capitanía, reconocimiento o desacuerdos en el campo.
- Diferenciar rivalidad competitiva saludable de tensión o conflicto personal. Competir por un puesto no implica enemistad automática.
- Ofrecer respuestas y acciones para resolver tensiones: diálogo respetuoso, cooperación en entrenamiento, disculpa, apoyo público o mantener una postura profesional.
- Los conflictos deben tener causas identificables, evolución y posibilidad de resolución; no producir peleas ni sanciones arbitrarias.
- No permitir que una rivalidad fuerce errores, lesiones, sabotaje o desobediencia en el motor del partido. Cualquier efecto deportivo debe ser limitado, explicable y validado por las reglas de gameplay.

### 29.5 Liderazgo, capitanía y reconocimiento

- El liderazgo se desarrollará mediante consistencia, responsabilidad, apoyo a compañeros, profesionalidad, experiencia y confianza del grupo.
- El entrenador o club podrá considerar al jugador para funciones de liderazgo/capitanía según rendimiento, antigüedad, personalidad deportiva, relación con el grupo y reglas del equipo.
- **Requisito obligatorio de antigüedad:** un futbolista solo podrá ser nombrado capitán a partir de su segunda temporada en ese mismo club. La primera temporada completa en el club no habilita la capitanía, aunque tenga alto overall, liderazgo o popularidad. Al comenzar su segunda temporada en el club pasa a ser elegible, pero no recibe el brazalete automáticamente: debe cumplir además los criterios deportivos y de equipo. Un traspaso a otro club reinicia el cómputo de antigüedad para esta regla; una cesión o regreso deberá contabilizarse según el historial real de temporadas inscritas y se definirá en el diseño detallado. La regla se aplica a capitanía permanente y vicecapitanía; sustituciones temporales durante un partido por ausencia del capitán se resolverán mediante el orden de liderazgo del equipo sin convertir al jugador en capitán permanente.
- Ser capitán no dependerá exclusivamente del overall, popularidad o amistad con el entrenador.
- El jugador podrá ejercer liderazgo en situaciones narrativas: animar al equipo, apoyar a un compañero, mediar en un conflicto o asumir responsabilidad tras un mal resultado.
- Las acciones de liderazgo modificarán gradualmente el respeto y la cohesión cuando sean coherentes con el contexto; no garantizarán titularidad ni premios automáticos.

### 29.6 Interacciones e interfaz

En el hub de Leyenda incorporar una sección «Vestuario» con:
- Resumen del clima/cohesión del equipo.
- Compañeros destacados y relación individual resumida.
- Amistades, apoyos, rivalidades deportivas y tensiones relevantes.
- Mensajes o conversaciones pendientes.
- Estado de liderazgo/capitanía y reconocimiento del grupo.
- Eventos recientes y motivos de cambios en las relaciones.

Permitir abrir la ficha de un compañero relevante, conversar, felicitar, apoyar, disculparse o resolver un desacuerdo cuando el contexto lo habilite. Las interacciones serán opcionales, breves y adaptadas a pantalla táctil y mando. Agrupar avisos para no interrumpir partidos.

### 29.7 Equilibrio, continuidad y guardado

- Las relaciones evolucionarán lentamente; un único gol, error o diálogo no debe transformar drásticamente una amistad o rivalidad.
- No penalizar al jugador por decisiones de alineación que no controla, por ejemplo perder minutos por elección del entrenador; la frustración de un compañero debe atribuirse a causas coherentes.
- Evitar que popularidad o amistades sustituyan rendimiento, táctica, atributos, forma y condición.
- Mantener relaciones por compañero y club; al cambiar de club, conservar historial personal de antiguos compañeros y comenzar a desarrollar relaciones con el nuevo vestuario.
- Integrar eventos y estados al guardado versionado de carrera, con historial resumido y migraciones.
- Para compañeros fuera del grupo prioritario, usar actualizaciones agregadas y deterministas para controlar coste de CPU/memoria en Android.

### 29.8 Pruebas de aceptación

- Verificar que amistades y rivalidades tengan causas, progresión y resolución registradas.
- Comprobar que el clima colectivo no sea una suma simplista de relaciones individuales.
- Probar fichajes, cesiones, salidas, cambio de entrenador, capitanía, lesiones, suplencias y ascensos desde cantera.
- Confirmar que las interacciones no garanticen titularidad, goles, pases ni ventajas injustas.
- Confirmar que las reacciones sean variadas pero no excesivas, que los eventos se guarden/carguen y que la simulación agregada funcione en Android de gama baja.
- Verificar que todas las consecuencias deportivas sigan subordinadas a reglas, atributos, táctica y estado real del partido.

**Estado:** función aprobada y documentada; diseño conceptual definido; escalas, perfiles de personalidad, eventos y fórmulas pendientes de diseño detallado y balance; código no integrado; pruebas no realizadas.

## 30. Modo Leyenda — vida fuera del campo y actividades personales

**Origen:** ampliación propuesta para complementar las relaciones con entrenador y compañeros (secciones 27–29), además de los sistemas de vida social ya solicitados para los modos de carrera. **Decisión del propietario (2026-11-14):** APROBADA; el usuario pidió añadir estas funciones y estableció una regla adicional de antigüedad para la capitanía.

**Objetivo:** ampliar la carrera con actividades fuera del terreno de juego que permitan convivir, descansar, participar en acontecimientos del club y tomar decisiones personales. Estas actividades darán contexto y consecuencias moderadas a las relaciones, la recuperación física y la trayectoria profesional, sin convertirse en una obligación diaria ni desplazar el fútbol.

### 30.1 Actividades sociales con compañeros

- Aceptar o rechazar invitaciones de compañeros para actividades de convivencia en días y horarios disponibles.
- Proponer actividades entre compañeros o pequeños grupos: comidas, encuentros, paseos, celebraciones, actividades recreativas y reuniones privadas apropiadas al contexto.
- Las actividades podrán fortalecer amistades, respeto y cohesión o ayudar a resolver tensiones si las decisiones son coherentes con la situación.
- La participación será opcional; rechazar una invitación de forma respetuosa no debe provocar penalizaciones deportivas automáticas.
- Las invitaciones tendrán participantes, lugar, duración, coste si corresponde, fecha límite y posible efecto antes de confirmar.
- Evitar que todos los compañeros inviten constantemente; limitar frecuencia y priorizar relaciones/eventos relevantes.

### 30.2 Eventos del club y de la carrera

- Incorporar acontecimientos de equipo y club: presentaciones de temporada, reuniones de plantilla, celebraciones de victorias/títulos, actos de reconocimiento, despedidas, integración de fichajes y eventos comunitarios o institucionales ficticios.
- Los eventos estarán vinculados al calendario, resultados y acontecimientos reales de la carrera; no inventar títulos, logros ni noticias que no hayan ocurrido.
- Permitir interacciones breves con entrenador, compañeros y personal durante eventos, con opciones adecuadas al contexto.
- La asistencia podrá ser obligatoria solo para compromisos profesionales claramente establecidos por el club; los eventos sociales opcionales no bloquearán la progresión.
- Registrar fecha, participantes, decisiones y consecuencias para el historial de carrera.

### 30.3 Descanso, recuperación y rutina personal

- Incluir decisiones de descanso y recuperación fuera del campo, compatibles con el calendario de entrenamiento y partidos.
- Diferenciar descanso, recuperación guiada y actividad recreativa: cada opción tendrá duración y efectos coherentes sobre fatiga, condición y bienestar deportivo.
- No permitir que una actividad social sustituya mágicamente tratamiento médico, rehabilitación o descanso necesario.
- Evitar que las actividades personales consuman tiempo de forma opaca: mostrar siempre el coste de tiempo y el efecto previsto antes de confirmar.
- La planificación deberá respetar lesiones, restricciones médicas ficticias del juego, compromisos de entrenamiento, viajes y horarios de partido.

### 30.4 Decisiones personales y vida social

- Ofrecer decisiones personales de bajo riesgo narrativo vinculadas a convivencia, gestión del tiempo, compromisos del club y relaciones con compañeros.
- Integrar compras de casas, vehículos y artículos personales dentro del sistema económico/vida social ya solicitado para los modos de carrera, cuando el alcance del modo y sus recursos estén definidos.
- Mostrar precio, mantenimiento/costes recurrentes cuando proceda y consecuencias antes de una compra; no crear una moneda paralela.
- La vida social no debe exigir microtransacciones, conexión permanente ni compras con dinero real.
- Evitar inferir o representar datos sensibles del usuario real; todos los personajes, eventos y relaciones pertenecen al mundo ficticio de la carrera.

### 30.5 Consecuencias y equilibrio

- Las actividades podrán afectar de forma moderada y explicable a relaciones individuales, cohesión, descanso, fatiga y disponibilidad temporal.
- No conceder mejoras automáticas de overall, habilidades, confianza del entrenador o titularidad por asistir a eventos.
- Las consecuencias deportivas deben depender de hechos verificables: una actividad que reduzca tiempo de descanso puede afectar la recuperación; una convivencia positiva puede mejorar una relación, no aumentar atributos.
- Rechazar actividades no debe generar castigos arbitrarios. Incumplir compromisos profesionales aceptados sí puede tener consecuencias proporcionales y explicadas.
- Evitar cadenas de actividades repetibles para farmear amistad, moral, energía o dinero; aplicar límites de frecuencia y rendimientos decrecientes cuando sea necesario.
- Mantener compatibilidad con la agenda de entrenamiento, calendario, viajes, lesiones, contratos y compromisos de equipo.

### 30.6 Interfaz y guardado

Crear en el hub de Leyenda una sección «Vida social» con:
- Agenda próxima y disponibilidad.
- Invitaciones recibidas y respuestas pendientes.
- Actividades disponibles con participantes, duración, coste y consecuencias previstas.
- Eventos del club y recuerdos recientes.
- Opciones de descanso/recuperación fuera del entrenamiento.
- Resumen de relaciones relevantes y vínculos con la sección Vestuario.
- Historial de decisiones y gastos personales cuando aplique.

Guardar eventos, agenda, invitaciones, decisiones, gastos y consecuencias en el archivo versionado de carrera. Las actividades deberán poder resolverse sin conexión y usar datos compactos para Android.

### 30.7 Regla de capitanía y antigüedad en el club

- Un jugador solo podrá ser capitán permanente o vicecapitán a partir de su segunda temporada en el club actual.
- La primera temporada en el club no habilita para recibir el brazalete, independientemente de overall, liderazgo, amistad, reputación o confianza del entrenador.
- Al comenzar la segunda temporada en el mismo club, el jugador pasa a ser elegible; la elegibilidad no equivale a nombramiento automático.
- Para recibir el cargo deberá cumplir además los criterios deportivos, de liderazgo y de equipo definidos por el entrenador/club.
- Un cambio de club reinicia el cómputo para el requisito de capitanía permanente. El historial de temporadas anteriores se conserva, pero no cuenta como antigüedad en el nuevo club.
- Las sustituciones temporales del capitán durante un partido no cambian el nombramiento permanente ni anulan el requisito de antigüedad.
- La regla debe aplicarse de forma consistente a todos los jugadores de la simulación, no solo al futbolista controlado en Leyenda.

### 30.8 Pruebas de aceptación

- Probar invitaciones aceptadas/rechazadas, eventos de club, cambios de calendario, viajes, lesiones y actividades que compiten por tiempo.
- Verificar efectos sobre descanso, fatiga, relaciones y gastos; impedir recompensas duplicadas por repetir actividades.
- Confirmar que no asistir a eventos opcionales no perjudique injustamente la carrera.
- Verificar que la vida social no otorgue titularidad, atributos o habilidades de forma automática.
- Probar guardado/carga offline, cambios de club, cambio de temporada y continuidad de historial.
- Probar capitanía: temporada inicial inelegible; segunda temporada elegible; nombramiento sujeto a criterios; transferencia reinicia elegibilidad; vicecapitanía y sustituciones temporales respetan la regla.
- Medir coste de simulación y almacenamiento en Android de gama baja.

**Estado:** funciones aprobadas y documentadas; regla de capitanía desde la segunda temporada incorporada; diseño detallado de actividades, agenda, costes y efectos pendiente; código no integrado; pruebas no realizadas.

## 31. Modo Leyenda — familia y entorno personal

**Origen:** propuesta de ampliación de la vida fuera del campo, aprobada por el propietario (2026-11-13) mediante la instrucción «Añade esas funciones». La regla de capitanía desde la segunda temporada en el club se mantiene y se consolida en la sección 30.7.

**Objetivo:** dar al futbolista un entorno personal ficticio que aporte continuidad narrativa y apoyo fuera del fútbol, sin convertir la vida familiar en una obligación, una penalización constante ni un requisito para progresar.

### 31.1 Círculo familiar y contactos personales
- Crear un panel opcional de **Familia y entorno** dentro del hub de Leyenda, separado de Vestuario y Vida social.
- Incluir únicamente personajes ficticios configurados para esa carrera: familiares cercanos y contactos personales que el jugador decida mantener en su círculo.
- Mostrar nombre, vínculo, disponibilidad para contactar, acontecimientos compartidos y estado general de la relación; no exponer información íntima innecesaria.
- Permitir configurar o revisar los vínculos narrativos al iniciar la carrera cuando el flujo de creación lo permita. No exigir datos reales del usuario ni importar contactos del dispositivo.
- La estructura familiar no debe imponer una única composición: admitir distintas configuraciones narrativas y permitir que el jugador deje campos sin definir.

### 31.2 Llamadas, mensajes y comunicación
- Permitir recibir y enviar llamadas o mensajes ficticios en momentos apropiados del calendario: antes/después de partidos, durante descansos, viajes o acontecimientos personales.
- Las conversaciones tendrán opciones breves y contextuales: responder, posponer, agradecer, pedir consejo, compartir una noticia o mantener privacidad.
- Los mensajes podrán proceder de familiares o contactos previamente establecidos y tendrán contexto; evitar mensajes repetitivos o notificaciones constantes.
- Posponer o no responder a una comunicación ordinaria no provocará castigos deportivos automáticos. Solo compromisos explícitos aceptados podrán tener consecuencias narrativas proporcionadas.
- Los mensajes y llamadas no se realizarán mediante servicios reales ni requerirán conexión a Internet.

### 31.3 Acontecimientos personales y apoyo
- Incorporar acontecimientos ficticios apropiados a la etapa de carrera: cumpleaños, celebraciones, visitas, reuniones familiares, cambios de residencia, apoyo durante lesiones, hitos profesionales y momentos importantes del entorno.
- Permitir que el jugador elija participar, responder o mantener distancia, mostrando previamente el tiempo y los compromisos afectados.
- El entorno podrá ofrecer apoyo narrativo ante lesiones, suplencias, cambios de club, presión competitiva o decisiones profesionales; no concederá curaciones instantáneas, atributos, titularidad ni dinero gratuito.
- Los acontecimientos se generarán a partir del calendario y del historial real de la partida; no inventar logros, parentescos o sucesos como si hubieran ocurrido sin registrarlos.

### 31.4 Agenda y equilibrio con la carrera
- Integrar visitas, llamadas programadas y eventos personales con el calendario de entrenamientos, partidos, viajes, descanso y rehabilitación.
- Mostrar duración, disponibilidad, desplazamiento si corresponde y posibles conflictos antes de aceptar.
- Proteger los compromisos profesionales: el jugador no podrá confirmar actividades incompatibles con un partido o entrenamiento obligatorio sin que el juego explique la consecuencia.
- Las actividades personales serán opcionales y no deberán convertirse en una lista diaria de tareas obligatorias.
- Los efectos sobre bienestar narrativo, relaciones y descanso serán moderados, comprensibles y no sustituirán los sistemas deportivos o médicos.

### 31.5 Privacidad, accesibilidad y contenido
- Todos los familiares, contactos, mensajes y acontecimientos pertenecen al universo ficticio de la carrera; no acceder a contactos, mensajes, llamadas, fotografías ni datos personales reales del dispositivo.
- No solicitar ni almacenar datos sensibles reales del usuario. Los nombres y vínculos ficticios serán editables o aleatorios según las opciones del creador.
- Mantener diálogos respetuosos, adecuados a la edad del futbolista y sin contenido explícito.
- La interfaz y los diálogos estarán en español, con controles táctiles y mando, texto legible y notificaciones agrupadas.

### 31.6 Guardado y continuidad
- Guardar relaciones, contactos ficticios, mensajes relevantes, acontecimientos, decisiones y agenda en los datos versionados de la carrera.
- Mantener continuidad al cambiar de club y al pasar de temporada; el entorno personal no se reinicia por un traspaso.
- Permitir jugar y consultar este sistema completamente offline.
- Mantener el historial resumido para no inflar el tamaño de las partidas en Android.

### 31.7 Pruebas de aceptación
- Probar distintas configuraciones de familia y contactos, incluidos campos sin definir.
- Verificar mensajes, llamadas, respuestas, posposición, eventos y continuidad entre temporadas.
- Comprobar conflictos de agenda con partidos, entrenamientos, viajes, lesiones y descanso.
- Confirmar que ignorar comunicaciones ordinarias no cause penalizaciones deportivas arbitrarias.
- Verificar que no se accede a contactos ni datos reales del dispositivo y que el sistema funciona offline.
- Probar guardado/carga, migración de partidas y rendimiento en Android de gama baja.

**Estado:** función aprobada y documentada; alcance conceptual definido; catálogo de vínculos, eventos, diálogos y reglas de agenda pendiente de diseño detallado; código no integrado; pruebas no realizadas.

## 32. Pantalla única de Vida personal para Leyenda y Entrenador

**Origen:** instrucción del propietario (2026-11-14): reunir todo lo relacionado con la vida personal en una misma pantalla y añadir vida personal al Modo Entrenador. **Decisión:** APROBADA.

**Objetivo:** evitar que familia, relaciones, mensajes, agenda, actividades, descanso y patrimonio personal queden dispersos por distintas pantallas. Cada modo tendrá una sola pantalla principal «Vida personal», con secciones internas organizadas y contenido adaptado al papel del usuario en la carrera.

### 32.1 Regla de pantalla única
- En Modo Leyenda y Modo Entrenador habrá una única entrada principal denominada **Vida personal**.
- Todos los sistemas personales se consultan y administran desde esa pantalla: familia y entorno, relaciones personales, mensajes/llamadas, invitaciones, agenda, actividades, acontecimientos, descanso, vivienda, vehículos, artículos, patrimonio y gastos personales.
- Se permiten pestañas, filtros, tarjetas, listas o paneles dentro de la misma pantalla; no crear pantallas independientes para Familia, Vida social, Mensajes o Agenda.
- Los detalles breves podrán abrirse como panel superpuesto/modal dentro de Vida personal, conservando la pantalla como contexto y punto de retorno.
- No duplicar la misma información en Vestuario, Central, Club, Finanzas o Carrera. Esos apartados podrán mostrar resúmenes y accesos directos que abran la sección correspondiente dentro de Vida personal.

### 32.2 Organización común de Vida personal
La pantalla tendrá secciones internas adaptables:
- **Resumen:** próximos eventos, avisos importantes, estado general, agenda inmediata y accesos rápidos.
- **Familia y entorno:** vínculos ficticios, contactos personales, acontecimientos compartidos, visitas y apoyo.
- **Mensajes y llamadas:** comunicaciones ficticias, historial, respuestas, opción de posponer y privacidad.
- **Relaciones y convivencia:** amistades, relaciones personales, invitaciones, actividades con compañeros y eventos sociales. En Leyenda incluye relaciones del vestuario; en Entrenador incluye relaciones personales y sociales apropiadas al rol, sin convertirlas en una segunda gestión de plantilla.
- **Agenda y actividades:** citas, invitaciones, eventos, ocio, descanso y compromisos; mostrar duración, coste y conflictos de horario antes de confirmar.
- **Vivienda y bienes:** casas, vehículos, artículos, compras, ventas, mantenimiento y gastos recurrentes.
- **Patrimonio personal:** ingresos personales, liquidez, bienes, deudas y movimientos relevantes, conectado al libro mayor común y separado de las finanzas del club.
- **Historial:** decisiones, acontecimientos, comunicaciones relevantes y gastos.

### 32.3 Adaptación al Modo Leyenda
- Reunir en Vida personal las funciones previamente descritas en las secciones 28–31: relación personal con el entrenador, relaciones y convivencia con compañeros, familia, llamadas/mensajes, eventos, agenda, descanso y compras personales.
- La confianza deportiva con el entrenador, el rol de plantilla y los datos de rendimiento seguirán visibles en las áreas deportivas correspondientes; Vida personal podrá mostrar el contexto de conversaciones/promesas y abrir su detalle sin duplicar el indicador deportivo.
- La cohesión colectiva y las relaciones de vestuario se mantienen como sistemas deportivos/sociales; su interacción personal se consulta desde la sección Relaciones y convivencia de Vida personal.
- La pantalla no concede titularidad, capitanía, atributos ni habilidades por compras o relaciones. Se conservan todas las reglas aprobadas, incluida la elegibilidad de capitán/vicecapitán desde la segunda temporada en el club actual.

### 32.4 Adaptación al Modo Entrenador
- Añadir Vida personal como sección principal del hub de Entrenador, accesible junto a las demás áreas del modo.
- El entrenador podrá gestionar su familia y entorno ficticios, mensajes y llamadas, acontecimientos personales, invitaciones, actividades, agenda, descanso, vivienda, vehículos, artículos y patrimonio personal.
- Incorporar decisiones de conciliación entre vida personal y profesión: descanso, eventos familiares, compromisos sociales, viajes y obligaciones del club.
- Mostrar con antelación los conflictos con entrenamientos, ruedas de prensa, reuniones de directiva, viajes, ventanas de fichajes y partidos. La agenda debe permitir distinguir compromisos obligatorios de actividades opcionales.
- Las decisiones podrán influir moderadamente en bienestar narrativo, relaciones y disponibilidad del entrenador, pero no concederán victorias, fichajes, autoridad adicional ni mejoras tácticas automáticas.
- Mantener separados el salario/contrato personal del entrenador, su patrimonio e inversiones, y el presupuesto/tesorería del club. Toda transacción personal se registra en el libro mayor personal.
- Si el usuario desempeña el cargo de Presidente en una carrera de club, Vida personal sigue siendo su espacio privado; las finanzas, inversiones y decisiones institucionales permanecen en Club/Finanzas y no se mezclan con el patrimonio personal.

### 32.5 Navegación y experiencia de usuario
- Una sola pantalla principal por modo, con navegación interna táctil y compatible con mando.
- Usar tarjetas y filtros compactos, con prioridad para agenda, mensajes pendientes y acontecimientos próximos.
- Los accesos desde otras pantallas deben abrir Vida personal en la sección pertinente, no crear una copia del contenido.
- Agrupar notificaciones; no interrumpir partidos ni tareas críticas del modo.
- Toda la interfaz y los textos estarán en español; los datos y actividades estarán disponibles offline.

### 32.6 Persistencia y pruebas
- Compartir componentes de datos comunes cuando sea posible, con perfiles/roles distintos para Leyenda y Entrenador.
- Guardar relaciones, contactos ficticios, mensajes relevantes, eventos, agenda, actividades, bienes y movimientos personales en el registro versionado de la carrera.
- Mantener separados los guardados de modos distintos y evitar referencias cruzadas que permitan alterar las finanzas del club desde la pantalla personal.
- Probar que toda función personal se puede encontrar y administrar desde una única pantalla en ambos modos.
- Probar apertura de accesos directos desde otras áreas, navegación de retorno, filtros, paneles superpuestos y mandos/táctil.
- Probar conflictos de agenda, compromisos obligatorios/opcionales, economía personal, guardado/carga offline y rendimiento Android.

### 32.7 Estilo visual y distribución aprobados — estilo mixto

El usuario elige el **estilo mixto**: combinar una presentación visual basada en tarjetas con paneles compactos de información. Esta elección queda aprobada para la pantalla única de Vida personal de Leyenda y Entrenador.

- **Estructura:** cabecera con identidad del modo/personaje, saldo y resumen de estado; debajo, tarjetas visuales para las áreas personales y paneles compactos para información que requiere consulta frecuente.
- **Prioridad de contenido:** agenda próxima y avisos importantes visibles primero; mensajes recientes y relaciones relevantes a continuación; vivienda, vehículos, artículos y patrimonio en áreas organizadas de acceso directo.
- **Secciones internas:** Familia y entorno; Mensajes y llamadas; Relaciones; Agenda y actividades; Descanso y ocio; Vivienda; Vehículos; Vestuario y artículos; Patrimonio personal; Historial. La lista puede adaptarse al rol sin crear pantallas raíz separadas.
- **Navegación:** seleccionar una tarjeta abre su panel/sección dentro de la misma pantalla; permitir volver al resumen sin perder el contexto. Otras áreas del juego pueden ofrecer accesos directos que abran la sección correspondiente dentro de Vida personal.
- **Diseño táctil Android:** tarjetas con áreas de pulsación amplias, iconos redondeados y etiquetas claras; evitar tablas densas y controles pequeños. En pantallas estrechas, los paneles se apilan verticalmente y permiten desplazamiento.
- **Densidad adaptable:** en pantallas grandes se permiten columnas y paneles laterales; en móviles se prioriza una columna y tarjetas resumidas. No depender de animaciones pesadas.
- **Diferencia por rol:** Leyenda destaca relaciones de vestuario, carrera, descanso y actividades con compañeros; Entrenador destaca familia/entorno, agenda profesional-personal, eventos, invitaciones y patrimonio. Los datos deportivos y finanzas del club permanecen separados.
- **Accesibilidad:** texto legible, contraste suficiente, iconos acompañados de etiquetas y navegación compatible con mando además de táctil.

Esta elección fija la dirección visual, no un diseño pixel-perfect. Antes de programar todavía se debe elaborar el wireframe de móvil y definir componentes, estados vacíos, avisos, orden adaptable y reglas de agenda.

**Estado:** decisión aprobada y documentada; arquitectura de pantalla única y alcance para ambos modos definidos; componentes, estados, datos y reglas de agenda pendientes de especificación final; código no integrado; pruebas no realizadas.


## Corrección confirmada del perfil base — 14-11-2026

El usuario confirmó los siguientes datos oficiales del jugador personalizado `NOVA-PLAYER-0035`: nombre completo **Anier Alejandro Cumbá Ibar**, peso **65 kg** y selección preferida **Brasil**. Su país de nacimiento/nacionalidad registrada permanece Cuba; la selección preferida no elimina las comprobaciones de elegibilidad internacional. Estos valores sustituyen las versiones anteriores de la tabla del perfil.
