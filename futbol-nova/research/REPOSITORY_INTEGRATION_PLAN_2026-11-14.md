# Fútbol Nova — auditoría e integración selectiva de repositorios
**Fecha:** 14-11-2026  
**Estado:** investigación consolidada y plan de adaptación; integración jugable, compilación y pruebas todavía pendientes.

## 1. Decisión de alcance
La instrucción del propietario autoriza investigar el conjunto de repositorios ya encontrados y adaptar las funciones que mejoren el realismo, la calidad y el atractivo de Fútbol Nova. Se mantiene la decisión anterior de no copiar proyectos completos ni importar assets sin verificar sus derechos. Esta autorización no convierte un repositorio externo en dependencia obligatoria ni prueba que una función esté implementada.

El proyecto canónico es `proyectos/juegos/futbol-nova/`. El README vigente indica que el prototipo es mínimo y que la fase actual consiste en recopilar y verificar datos antes de integrar pantallas. Por tanto, esta auditoría incorpora el diseño técnico y la hoja de integración, no simula una integración jugable inexistente.

## 2. Auditoría de los 20 repositorios

| # | Fuente | Funciones aprovechables | Decisión técnica para Fútbol Nova | Riesgo / condición |
|---|---|---|---|---|
| 01 | [blurz17/blurz-native-football-](https://github.com/blurz17/blurz-native-football-) | Entrenamiento, HUD táctil, cámara de jugador, motor nativo, perfilado móvil, física ODE | Usar como referencia de controles móviles, escenas de entrenamiento y perfilado; comparar su enfoque nativo con Godot antes de considerar una extensión | Está basado en GameplayFootball y usa SDL2/OpenGL ES/ODE/JNI; auditar procedencia, licencia, modelos y assets por separado. No mezclar dos motores de render |
| 02 | [FaustionLeeon/League-Soccer](https://github.com/FaustionLeeon/League-Soccer) | 22 jugadores, física con giro/viento/rebote, IA, árbitro, faltas, fuera de juego, repeticiones, carreras y gestión | Referencia funcional principal para contratos de eventos de partido, reglas, carrera, scouting, cantera, finanzas, pruebas headless y localización | Apache-2.0 declarada, pero README indica linaje GameplayFootball/Google Research Football. La URL de clonación apunta a awest813/League-Soccer; fijar repo/commit exacto y revisar NOTICE, dependencias y assets. No hay soporte Android declarado |
| 03 | [Tobilion/footysim](https://github.com/Tobilion/footysim) | Simulación espacial 11v11, agentes, geometría real de campo, xG, atributos, eventos, calibración | Usar como banco de calibración estadística y referencia de decisiones por geometría; contrastar distribución de tiros, xG, pases, faltas, distancia y posesión | Python headless, solo dos commits visibles y sin licencia abierta clara confirmada. Tiene brechas: offside, córneres, saque de banda y disparidad excesiva entre equipos desiguales. No copiar código ni distribuir datos hasta aclarar licencia |
| 04 | [DeltaBitsSystem/FootballEngine](https://github.com/DeltaBitsSystem/FootballEngine) | F# offline determinista, simulación 2D a 40 Hz, percepción limitada, steering, táctica, influencia territorial, xG/xA, mapas, scouting, cantera, moral, editor de balón parado y mods JSON | Adaptar ideas de percepción, mapa de influencia, explicación causal del resultado, scouting, roles y herramientas de táctica | GPL-3.0 declarada y proyecto WIP. No integrar fragmentos de código sin decidir compatibilidad GPL; preferir implementación original |
| 05 | [openfootball/players](https://github.com/openfootball/players) + [openfootball/leagues](https://github.com/openfootball/leagues) | Datos públicos de jugadores por país y catálogo de ligas/copas | Usar como semillas de catálogo y validación de nombres/posiciones/competición; normalizar IDs y fechas | CC0 declarado. Datos incompletos o no necesariamente actuales; no asumir que la base contiene plantillas completas o ratings |
| 06 | [matyuschenko/fifa-wc2026-players](https://github.com/matyuschenko/fifa-wc2026-players) | 1.248 jugadores, 48 selecciones, posición, nombre de camiseta, club, nacimiento y altura | Usar como snapshot auxiliar para validar estructura de plantillas internacionales y nombres de camiseta | CC BY 4.0 con atribución; snapshot fechado 10-09-2026, no es una API viva. Verificar datos y no inferir rating |
| 07 | [footballcsv/cache.footballsquads](https://github.com/footballcsv/cache.footballsquads) | Dorsales, nombres, nacionalidad, posición, altura, peso, nacimiento, lugar y club anterior | Fuente auxiliar para pruebas de importación, comparación de dorsales y campos físicos | Repo declara CC0, pero copia el contenido de FootballSquads y conserva errores/typos originales. Revisar derechos y exactitud del origen antes de redistribuir; no tratarlo como verdad oficial |
| 08 | [openfootball/worldcup.json](https://github.com/openfootball/worldcup.json) | Historial de Mundiales, calendarios, resultados, XI, banquillo, cambios, penaltis, tarjetas y árbitros | Alimentar archivo histórico y validadores de estructura de torneos internacionales; importar snapshots offline | CC0 declarado. Verificar cobertura por año; los minutos son cadenas para soportar añadido (p. ej. 90+4) |
| 09 | [openfootball/clubs](https://github.com/openfootball/clubs) + [sorrentmutie/WorldSoccerStadiums](https://github.com/sorrentmutie/WorldSoccerStadiums) | Clubes, años de fundación, nombres alternativos y datos de unos 4.887 estadios | Usar como catálogo de candidatos, alias y estadios, con deduplicación por país/ciudad/coordenadas | Openfootball declara CC0. WorldSoccerStadiums README dice public domain pero metadatos GitHub indican MIT; resolver discrepancia antes de redistribuir. Coordenadas/capacidad incompletas |
| 10 | [hudl/open-data (StatsBomb)](https://github.com/hudl/open-data) | Eventos de partido, pases, tiros, regates, alineaciones y 360 freeze frames en partidos seleccionados | Usar en investigación offline para calibrar eventos, modelos de presión y mapas de opciones; crear métricas agregadas propias | Sus términos limitan el uso a investigación/interés genuino y piden atribución/logo al publicar análisis. No tratarlo como licencia general de redistribución dentro del juego comercial |
| 11 | [ML-KULeuven/socceraction](https://github.com/ML-KULeuven/socceraction) | Conversión SPADL, VAEP y Expected Threat (xT) | Adaptar fórmulas/ideas de evaluación de acciones a estadísticas postpartido y feedback de entrenamiento; recalibrar con datos propios | MIT; biblioteca Python, no componente Godot listo. Citar investigación si se usa; no ejecutar en tiempo real en cada móvil |
| 12 | [michaltomczykowski/godot-ai-animation-toolkit](https://github.com/michaltomczykowski/godot-ai-animation-toolkit) | Presets, edición/limpieza de clips, AnimationTree, IK, springs, poses y movimiento humanoide procedural con pies plantados | Usar como referencia de pipeline de animación, transiciones, root motion, poses y herramientas de inspección; escoger runtime mínimo | Verificar LICENSE, versión exacta y herramientas de IA/editor; no asumir que todas las operaciones son runtime o exportables a Android |
| 13 | [GodotModding/godot-mod-loader](https://github.com/GodotModding/godot-mod-loader) | Carga de mods GDScript, dependencias, perfiles, activación y desactivación | Adoptar formato de paquetes/manifiestos, dependencias y perfiles como referencia para módulos de Fútbol Nova | CC0 declarado y soporte Godot 3.x/4.x en README; no ejecutar scripts externos sin sandbox lógico, firma/hash, permisos, allowlist y revisión Nova Guard |
| 14 | [IUXGames/EasyStore](https://github.com/IUXGames/EasyStore) | Slots, secciones, caché, autosave, escritura asíncrona, migraciones y resolución de conflictos | Adoptar arquitectura de backends desacoplados, cola asíncrona, slots, migraciones y conflictos; conectar un backend Nova Nexus propio | MIT, Godot 4.4+. Backend Steam Cloud depende de GodotSteam; no se usa en Android. Revisar cifrado y consistencia; no asumir que su sync resuelve todos los casos de nube |
| 15 | [ddevetak/football-dataset-zh](https://github.com/ddevetak/football-dataset-zh) | 76.991 partidos, 92 ligas/42 países (snapshot indicado 2023–2026), marcadores, HT y minutos | Fuente auxiliar de calendarios/resultados históricos para pruebas de simulación y balance de ligas | CC BY 4.0 y atribución a football-charts.com; snapshot con cobertura desigual, no usar como feed en vivo ni inferir eventos que no contiene |
| 16 | [SkillCorner/opendata](https://github.com/SkillCorner/opendata) | Tracking de 10 fps, balón/jugadores, fases, eventos dinámicos, métricas físicas y 3D pose de 29 articulaciones en dos partidos | Usar como conjunto de investigación para entrenar/calibrar desmarques, distancia, presión, ocupación de espacios y sincronización corporal | MIT declarado para repo y petición de crédito SkillCorner; muestra pequeña, solo 10 partidos y rendimiento filtrado >60 min. Coordenadas/eventos requieren normalización; no usar como base de jugadores universal |
| 17 | [foxssake/netfox](https://github.com/foxssake/netfox) + [albertok/godot-rocket-league](https://github.com/albertok/godot-rocket-league) | Sincronización, predicción, interpolación y pruebas de rollback de física | Reservar para fase online futura; empezar por arquitectura cliente-servidor y sincronización de estado autoritativo, sin rollback en la primera versión | Netfox MIT; Rocket League MIT, pero demo requiere Godot con Stepping PR o Blazium. No es plug-and-play para Godot estable ni Android |
| 18 | [kS222138/TCA_Weather_System](https://github.com/kS222138/TCA_Weather_System) | Cielo, lluvia, niebla, viento, precipitación, humedad/terreno y LOD | Diseñar clima por perfiles escalables que afecten visibilidad, vuelo del balón y estado del campo solo cuando esté activo en la competición | MIT, Godot 4.6+. El README indica adaptación móvil en roadmap v1.5; usar primero clima simplificado propio y medir GPU/memoria |
| 19 | [Reshiramoo/chirp](https://github.com/Reshiramoo/chirp) | Eventos de audio, variaciones, capas, límites de voces, timelines musicales, ducking, snapshots y emisores 2D/3D | Usar para diseñar sistema de eventos de audio, mezcla por contexto, ambiente de grada, golpeos, silbato y comentarios | MIT, Godot 4.6+; README advierte que exportaciones y dispositivos móviles aún no están probados. Cada archivo musical/voz requiere licencia propia |
| 20 | [AverageDrafter/MultiNode-Plugin](https://github.com/AverageDrafter/MultiNode-Plugin) | Instancing masivo, nodos espaciales y optimización de objetos repetidos | Evaluar para público, asientos, vallas, vegetación y elementos repetidos del estadio; usar MultiMesh nativo si basta | MIT, Godot 4.6, Open Alpha, extensión C++/SCons. Riesgo de ABI y compilación Android; benchmark antes de adoptar |

## 3. Referencias adicionales ya aprobadas o documentadas
Estas fuentes también forman parte de la investigación previa y deben coordinarse con la auditoría principal:

- [AKM-8byte/FreeKick](https://github.com/AKM-8byte/FreeKick) — MIT, Godot 4.7.2. Entrenamiento de tiros libres, contacto, perfiles físicos, barrera, portero, IK y siete cámaras. Ya existen helpers originales en Fútbol Nova para gesto de balón parado, vuelo, barrera, reacción de portero, IK y cámaras; siguen desconectados del motor y sin pruebas.
- [RobinNunkesser/gd-godot-crazy-cage-football](https://github.com/RobinNunkesser/gd-godot-crazy-cage-football) — referencia aprobada para abstracción de entrada, cámara, contactos, máquina de estados, localización y asignación de mandos. Excluir jaula, personajes esféricos y potenciadores arcade. Verificar MIT y assets.
- [thedivergentai/Game-Dev-Agentic-Skills](https://github.com/thedivergentai/Game-Dev-Agentic-Skills) — guía deportiva aprobada para principios de física, validación arbitral, IA y formaciones. LGPL-3.0 declarada; preferir reimplementación original y auditar cada fragmento.
- [Youngermaster/Street-Kickoff](https://github.com/Youngermaster/Street-Kickoff) — control contextual del balón independiente, aprobado conceptualmente. La licencia debe verificarse antes de copiar código.
- [zocram4cc/GodotFootball](https://github.com/zocram4cc/GodotFootball) — arquitectura táctica/determinista aprobada conceptualmente. Apache-2.0 declarada, pero excluir dependencias y recursos de PES 2021 y revisar NOTICE/procedencia.
- [MathewHDYT/Godot-Data-Manager](https://github.com/MathewHDYT/Godot-Data-Manager) — ideas de integridad/gestión de archivos aprobadas. MIT, pero API antigua de Godot 2; rediseñar para Godot 4.
- [monxa/GodotIK](https://github.com/monxa/GodotIK) — FABRIK/IK aprobado para estudio. MIT y Godot 4.3+ declarado; auditar GDExtension y ABI Android.
- [Godot Engine PCK docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_pcks.html) — evaluar paquetes de contenido externos con manifiesto, hash, firma, versión, dependencias y rollback.
- La investigación previa incluye además fuentes para datos de fútbol y reglas FIFA. No asumir que una licencia de software cubre datos, marcas, imagen de jugadores, música, comentarios o assets de terceros.

## 4. Arquitectura original que se recomienda construir

### A. Núcleo determinista de partido
Un único modelo de estado y eventos para partido jugado y partido simulado. El núcleo no debe depender de escenas, cámara ni HUD. Registrar semilla, versión de reglas y paso temporal para reproducir errores. Separar reloj de renderizado, física y decisiones de IA.

Submódulos:
1. Geometría de campo y coordenadas normalizadas.
2. Balón físico: masa, gravedad, fricción, restitución, resistencia, spin/Magnus y contacto.
3. Movimiento de futbolista: aceleración, frenado, giro, velocidad máxima, orientación corporal, equilibrio y fatiga.
4. Control contextual del balón: distancia, orientación, velocidad relativa, pie/cuerpo, primer toque y ventana de liberación tras pase/tiro.
5. Colisiones/contactos: pie, pierna, torso y cabeza; sin penetraciones ni posesión artificial.
6. Acciones: pase, pase al espacio, centro, tiro, conducción, regate, entrada, despeje, cabezazo y protección.
7. Portero: lectura, retraso, posicionamiento, salto, blocaje/desvío y recuperación con error humano configurable.
8. Reglas/árbitro: gol solo tras validación geométrica completa; fuera de juego, faltas, manos según regla elegida, tarjetas, ventaja, VAR opcional, lesiones y todos los reinicios.
9. Máquina de estados: preparación, calentamiento, saque, juego, interrupción, gol, celebración, descanso, prórroga, penaltis y final.
10. Eventos normalizados como fuente única para estadísticas, comentarios, audio, repeticiones, logros y guardado.

### B. IA de fútbol
- Percepción local y conocimiento parcial para agentes individuales.
- Roles y formación con posiciones objetivo dinámicas, no puntos fijos.
- Ataque: amplitud, profundidad, apoyos, desmarques, tercer hombre, cambios de orientación, ocupación de área y líneas de pase.
- Defensa: presión coordinada, coberturas, compactación, basculación, línea defensiva, temporización y protección de espacios.
- Transiciones ofensivas/defensivas y reacción al marcador/minuto.
- Evaluación de riesgo de pase/tiro, espacio, orientación corporal, presión rival, pie dominante y fatiga.
- Ajustes de entrenador con límites; no teletransportar ni forzar acciones físicamente imposibles.
- Dificultad basada en decisiones, percepción y tiempos de reacción, no en alterar injustamente atributos o reglas.
- Mapas de influencia, calor, presión y zonas de amenaza como herramientas de análisis, no necesariamente visibles durante el juego.

### C. Física, animación y presentación
- Un solo modelo de balón compartido entre partido y entrenamiento; FreeKick informa los perfiles, no crea un segundo balón incompatible.
- Animaciones base por estado y locomoción; IK selectivo para contacto de pie, pierna de apoyo y portero.
- Root motion y AnimationTree solo tras comparar con movimiento dirigido por física.
- Cámara contextual independiente del resultado deportivo.
- Clima opcional con perfiles bajo/medio/alto; el viento y la humedad solo afectan al balón/superficie cuando estén habilitados por el modo.
- Audio por eventos y buses; prioridad, límites de voces, ducking, variaciones y volumen por categoría.
- Público y objetos repetidos mediante MultiMesh/instancing antes de incorporar una extensión nativa.
- Repeticiones mediante buffer circular de snapshots/eventos y cámaras, no grabación de vídeo.

### D. Datos y mundo futbolístico
- IDs internos estables para países, asociaciones, clubes, estadios, jugadores, competiciones y temporadas.
- Separar nombre, alias, país de nacimiento, ciudadanía, selección elegible, club actual y nombre de camiseta.
- Importadores JSON/CSV con validación, deduplicación, procedencia, fecha, licencia y confianza.
- Snapshot offline versionado. Actualizaciones futuras mediante paquetes verificados; el juego base sigue offline.
- Datos reales solo para los campos que se puedan usar legítimamente. Si falta información, generar datos ficticios coherentes y etiquetarlos como generados.
- No copiar ratings, caras, escudos, equipaciones, nombres protegidos, audio ni likeness de jugadores sin derechos.
- El catálogo de ligas/clubes/estadios se normaliza y valida antes de generar calendario; no asumir que un dataset es completo o actual.

### E. Manager, Leyenda y economía
- Motor de temporada desacoplado del 3D, con simulación rápida basada en fuerza, forma, táctica, fatiga, localía, calendario y disponibilidad.
- Misma interfaz de resultado/eventos para partido jugado y simulado.
- Gestión de plantillas, contratos, fichajes, préstamos, scouting, academia, staff, instalaciones, moral, química y lesiones.
- Finanzas con libro mayor trazable, activos/pasivos, obligaciones, valoración dinámica y dividendos únicamente distribuibles.
- Vida social, patrimonio, propiedad y acciones separados de los salarios del jugador/entrenador.
- Canteras y competiciones juveniles por estructura nacional; elegibilidad y límites de edad.
- Amistosos sujetos a aceptación, disponibilidad, sede y condiciones económicas acordadas.

### F. Guardados y módulos
- Adaptar principios EasyStore/Data Manager: slots, secciones, cache, escritura atómica, operaciones asíncronas, integridad, backup y migraciones.
- Cinco espacios por modo según requisitos existentes; slot 1 para autoguardado, 2–5 manuales.
- Snapshot consistente en punto seguro; confirmar guardado solo tras completar y verificar escritura.
- Backend local siempre; sincronización Nova Nexus opcional y autenticada. Resolver conflictos con versión, timestamps y decisión explícita cuando no sea seguro elegir automáticamente.
- Paquetes modulares con manifiesto: ID, versión, tipo, tamaño, hash, firma, motor mínimo, dependencias, permisos, capacidades, licencia y procedencia.
- No ejecutar GDScript de terceros sin revisión y permisos; preferir módulos de datos/recursos. Nova Guard valida, firma y puede bloquear/revocar.
- Retirar módulos sin corromper partidas; advertir si un guardado depende de contenido ausente.

### G. Online futuro
- No empezar multijugador hasta tener partidos locales estables y deterministas.
- Primera fase online: cuenta, sincronización de progreso y contenido descargable.
- Después: servidor autoritativo para partidos, validación de entradas, latencia/interpolación y reconexión.
- Rollback solo si el núcleo físico puede repetir determinísticamente el estado en dispositivos diferentes y las pruebas lo justifican.
- No confiar en resultados, monedas o estadísticas enviados por el cliente.

## 5. Funciones que más pueden atraer y retener usuarios
Prioridad de producto, sin convertir el juego en pay-to-win:
1. Partido táctil satisfactorio: primer toque, conducción contextual, pases con intención, tiros con curva, portero convincente y controles configurables.
2. Carrera profunda y persistente: Manager y Leyenda con historias emergentes, objetivos, contratos, cantera, mercado y selecciones.
3. Identidad y personalización: crear clubes, equipaciones originales, tácticas, estadios y perfiles; compartir paquetes seguros.
4. Contenido amplio offline: ligas, copas, temporadas, datos y modos base disponibles sin conexión.
5. Progresión justa: entrenamiento, habilidades y objetivos medibles; cosméticos sin ventaja deportiva.
6. Repeticiones y análisis: mejores jugadas, mapa de calor, xG/xT, calificaciones explicables y evolución del jugador.
7. Presentación viva: público reactivo, comentarios localizados, clima opcional, celebraciones y audio contextual.
8. Accesibilidad móvil: interfaz adaptable, controles ajustables, calidad gráfica escalable, modo batería/rendimiento y tutorial interactivo.
9. Comunidad segura: módulos y ligas creadas por usuarios con verificación, atribución, compatibilidad, valoración y posibilidad de desactivar.
10. Online opcional y progresivo: rankings/amistosos después de asegurar antitrampas y estabilidad.

No añadir anuncios intrusivos, pagos que alteren ratings, cajas aleatorias de pago ni bloqueo del juego base offline. Medir retención, FPS, crashes y uso de funciones para decidir futuras prioridades.

## 6. Orden de implementación recomendado

**Fase 0 — investigación y contratos (ahora):**
- Fijar versiones y licencias; crear matriz de procedencia.
- Cerrar modelos de datos y contratos de eventos.
- Diseñar pruebas de calibración y métricas.
- Confirmar versión Godot estable compatible con Android; no adoptar plugins que requieran 4.6/4.7 sin comprobar el proyecto.

**Fase 1 — prototipo técnico reproducible:**
- Proyecto Godot limpio, escena de campo, jugador, balón y pruebas automatizadas.
- Movimiento y control contextual; pase/tiro; contacto y colisiones.
- Un partido reducido y después 11v11 con IA básica.
- Verificar en Android real antes de añadir contenido pesado.

**Fase 2 — partido realista:**
- Física, portero, árbitro, reinicios, faltas y fuera de juego.
- IA táctica colectiva y percepción individual.
- Eventos, estadísticas, replay y audio.
- FreeKick se conecta a los mismos servicios del partido.

**Fase 3 — datos y carreras:**
- Importación/validación de clubes, jugadores, ligas, estadios y resultados.
- Simulación de temporada, Manager, Leyenda, scouting, cantera, contratos y finanzas.
- Guardado versionado y migraciones.

**Fase 4 — contenido y presentación:**
- Animación/IK, cámaras, clima, sonido, estadio y público escalables.
- Editor de equipos/competiciones y paquetes de contenido verificados.
- Localización, accesibilidad, tutorial y personalización.

**Fase 5 — online y expansión:**
- Nova Nexus, sync y catálogo de módulos.
- Servidores autoritativos y multijugador solo tras pruebas de determinismo y red.

## 7. Puertas de calidad obligatorias
No marcar un sistema como integrado hasta:
- Código en el repositorio y conectado a su consumidor real.
- Pruebas unitarias e integración aprobadas.
- Prueba de escena/prototipo en Godot.
- Prueba Android en al menos un dispositivo objetivo de gama baja y uno medio.
- Métricas de FPS, memoria, CPU, temperatura y tamaño de descarga.
- Revisión de licencia, assets, dependencias y seguridad.
- Documentación de límites conocidos y procedimiento de desactivación/rollback.

## 8. Riesgos y decisiones técnicas
- La mayoría de referencias Godot encontradas piden Godot 4.6 o 4.7, mientras la versión de Fútbol Nova aún no está fijada. No instalar plugins hasta elegir una versión estable y verificar exportación Android.
- El proyecto MultiNode requiere extensión C++; netfox rollback requiere variantes especiales; EasyStore Steam no es una solución cloud Android; Chirp y Weather reconocen limitaciones móviles. Priorizar GDScript/Godot nativo y perfilar antes de añadir GDExtensions.
- El motor de partido no debe depender de datasets propietarios ni conexión permanente.
- Las licencias de código no cubren automáticamente modelos, música, comentarios, marcas, nombres, fotos ni datasets.
- La investigación de repositorios no sustituye las pruebas de juego ni la calibración con partidos de referencia.

## 9. Estado real
- FreeKick: helpers originales ya añadidos; conexión al motor/HUD, pruebas y validación Android pendientes.
- Propuestas 01–03: aprobadas anteriormente para adaptar sus funciones; todavía no equivalen a integración completa.
- Propuestas 04–20: esta instrucción general autoriza la investigación y selección técnica de funciones útiles, pero se aplican las restricciones de licencia y compatibilidad de esta auditoría.
- Referencias Crazy Cage Football, Game-Dev-Agentic-Skills, Street-Kickoff, GodotFootball, Godot Data Manager e GodotIK: aprobaciones/conceptos previos documentados; no todas tienen código integrado.
- Prototipo actual: una cancha simple, un jugador controlable, un balón, HUD de prueba y detección elemental de gol. No hay todavía partido 11v11, menú funcional, guardados conectados, temporadas ni validación Android.

**Conclusión:** construir un núcleo propio en Godot, modular y offline-first; usar los repositorios como referencias especializadas, no como una mezcla de motores. El mayor salto de calidad vendrá del control del balón, IA colectiva, reglas completas, carreras profundas, datos confiables, repeticiones y rendimiento móvil estable.


## 10. Búsqueda suplementaria de repositorios — 14-11-2026

La búsqueda adicional en repositorios públicos de GitHub encontró una referencia útil que no figuraba en la tabla principal:

| Fuente | Capacidades verificadas | Aplicación recomendada | Licencia y límites |
|---|---|---|---|
| [ecrou-exact/Global-Soccer-Manager](https://github.com/ecrou-exact/Global-Soccer-Manager) | Motor Python por cadenas de posesión y fases; ratings de ataque/defensa; matchup táctico; probabilidad determinista por semilla; tempo, presión y marcaje; fatiga; momentos de brillantez; localía y clima; faltas, tarjetas, lesiones y sustituciones automáticas; pruebas estadísticas | Referencia prioritaria para mejorar la simulación rápida de temporadas/Modo Manager y diseñar un catálogo de eventos más rico. Adaptar de forma selectiva sus ideas de trade-offs tácticos, fatiga y eventos a GDScript. Mantener `NovaMatchContract` como contrato canónico y no sustituir el partido 3D por este motor textual | Apache-2.0 confirmada en GitHub. Si se porta código, incluir copia de la licencia, conservar avisos de copyright/atribución y NOTICE si existe, y marcar claramente los archivos modificados. Proyecto Python 3.12, temprano, sin cliente 3D; última actividad de push observada: 29-07-2026. Auditar dependencias y pruebas antes de portar |

### Fuentes examinadas y descartadas para copia directa

- [richardschembri/GodotBasic3DFootball](https://github.com/richardschembri/GodotBasic3DFootball): ejemplo GDScript de fútbol 3D muy básico, con controles locales para dos jugadores. Su último push observado es de 2018 y GitHub no informa una licencia. No copiar scripts, escenas ni assets; como máximo, estudiar conceptos generales de movimiento y física.
- [ryan-haskell/godot-soccer-demo](https://github.com/ryan-haskell/godot-soccer-demo) y [ktawaststjerna/godot-ball-game](https://github.com/ktawaststjerna/godot-ball-game): prototipos Godot pequeños/antiguos sin licencia abierta confirmada en los metadatos consultados. No integrar código ni recursos.
- [krimshi/godot-soccer](https://github.com/krimshi/godot-soccer): proyecto 2D bajo MIT; no aporta una ventaja clara al prototipo 3D actual. Puede quedar como referencia secundaria de juego 2D, no como dependencia.

### Revisión de referencias ya registradas

- [Tobilion/footysim](https://github.com/Tobilion/footysim) ya estaba incluido en la auditoría principal. Se volvió a verificar: ofrece un modelo espacial 11v11 y boxscores por jugador, pero el campo `license` de GitHub es `null`. Por tanto, solo usar sus resultados públicos y documentación como referencia de diseño/calibración; no copiar código ni datos hasta obtener permiso o una licencia válida.
- [ZOXEXIVO/open-football](https://github.com/ZOXEXIVO/open-football) ya estaba en `SOURCES.md`. Se confirma como simulador autónomo de clubes, ligas, jugadores, fichajes, finanzas y partidos, bajo Apache-2.0. Su arquitectura Rust y enfoque de simulación mundial pueden orientar el Modo Manager, pero no es un motor Godot de control directo.
- [openfootmanager/openfootmanager](https://github.com/openfootmanager/openfootmanager) y [FlavioMili/Player12](https://github.com/FlavioMili/Player12) continúan como referencias GPL-3.0 ya documentadas; no se recomienda copiar código si Fútbol Nova no adopta expresamente las obligaciones GPL.

### Decisión resultante

La búsqueda suplementaria no cambia la arquitectura propuesta. La mejor combinación sigue siendo: motor de partido original en Godot para el juego controlable; contrato/eventos únicos para partido y estadísticas; simulación rápida separada para Manager; datos y recursos con procedencia/licencia verificadas. Global Soccer Manager es una fuente adicional útil para el simulador de temporada; FootySim queda limitado a referencia no reutilizable hasta aclarar su licencia.
