# Fútbol Nova — Hoja de ruta

## Alcance confirmado del producto
- [x] Fútbol masculino exclusivamente; excluir jugadores, clubes, selecciones y competiciones femeninas.
- [x] Menú principal limitado a Inicio, Online, Modos y Configuración; sin categoría Femenino.

## Prioridad de producto — Juego base y módulos descargables

- [x] Definir el juego base como aplicación independiente: partidos amistosos locales, Ayuda y Configuración.
- [x] Limitar Inicio al acceso a amistosos y Ayuda.
- [x] Convertir Online y Modos en páginas de descubrimiento de módulos descargables.
- [x] Registrar en el catálogo los módulos Online, Leyenda, Entrenador, Ligas y Copas, Entrenamiento, Momentos y TAS.
- [ ] Completar las opciones funcionales de todas las categorías de Configuración.
- [ ] Separar físicamente scripts, escenas, datos y recursos de cada módulo del paquete base.
- [ ] Construir paquetes descargables firmados/verificables, con versión, dependencias y plataformas.
- [ ] Probar que la APK base funciona sin módulos instalados y permite jugar amistosos.
- [ ] Probar instalación, activación, actualización y desinstalación de módulos en Android y PC.

## Fase 0 — Fundación documental
- [x] Registrar el proyecto en Nova Workspace.
- [x] Definir modos y pilares de jugabilidad.
- [x] Investigar repositorios públicos y registrar fuentes.
- [x] Consolidar auditoría técnica de 20 repositorios y referencias adicionales.
- [x] Definir selección de funciones, riesgos de licencia y fases de adaptación.
- [ ] Auditar commits, licencias, dependencias y assets de cada fuente antes de reutilizar cualquier archivo.
- [x] Establecer política de no copiar código/assets sin revisión.
- [x] Documentar el menú principal confirmado de cuatro pantallas.
- [x] Documentar las reglas confirmadas de guardado automático/manual.
- [ ] Elegir versión estable de Godot tras prueba de compatibilidad.

## Fase 1 — Completar datos y especificaciones (sin integrar pantallas)
- [x] Crear catálogo maestro de datos por pantalla, modo, partido y ajustes.
- [x] Unificar el menú de cuatro pantallas y excluir Ultimate Team de los documentos vigentes.
- [x] Reunir referencias públicas de FIFA 23 para completar categorías de datos.
- [ ] Completar y verificar las referencias visuales originales pendientes.
- [ ] Cerrar el esquema de entidades deportivas, atributos y fórmulas de progresión.
- [ ] Verificar el catálogo de competiciones y reglamentos por temporada.
- [ ] Definir límites técnicos y validaciones de torneos personalizados.
- [ ] Definir esquema JSON, versionado y migraciones.


## Fase 1.5 — Base compartida de datos y competiciones
### Módulos continentales
- [x] Separar el catálogo mundial de ligas en seis módulos de confederación: AFC, CAF, CONCACAF, CONMEBOL, OFC y UEFA.
- [x] Consolidar duplicados entre el ranking mundial y el manifiesto de paquetes; 100 ligas únicas en el primer corte.
- [x] Añadir cargador, índice central, validación y filtros por confederación en el catálogo de contenido.
- [ ] Completar la importación de ligas domésticas que faltan; el módulo OFC está creado y aún no tiene ligas cargadas.
- [ ] Integrar cada módulo al importador deportivo y validar plantillas, calendarios y reglas por país.
- [x] Crear manifiestos independientes para Caribe, Sudamérica, Norteamérica y Centroamérica y TAS.
- [x] Registrar los módulos continentales en un catálogo separado.
- [x] Añadir pruebas del motor de decisión y del ciclo de vida del TAS al workflow Android manual.
- [x] Implementar los 13 encuentros del TAS a partido único, incluidos los tres grupos, el grupo final y la final.
- [x] Conectar creación de edición, simulación, tablas, avance de fases y persistencia del TAS a FootballDataService/FootballDatabase.
- [x] Añadir pantalla TAS en Modos con simulación de partidos y avance de fases.
- [ ] Conectar automáticamente los podios finales de las tres ligas regionales para generar los nueve clasificados.
- [ ] Ejecutar y superar las pruebas Godot 4.4.1 en GitHub Actions.
- [x] Registrar el grafo de dependencias del TAS: Caribe, Sudamérica y Norteamérica/Centroamérica.
- [x] Resolver las dependencias en una sola solicitud y encolarlas antes del TAS, con validación previa completa.
- [x] Bloquear la instalación del TAS si alguna liga requerida no quedó instalada.
- [x] Bloquear la desinstalación de una liga mientras haya un módulo instalado que dependa de ella.
- [x] Habilitar `continental_competition_module` en el gestor de paquetes de datos JSON/ZIP.
- [ ] Generar y publicar los cuatro paquetes reales con URL HTTPS, tamaño, SHA-256 y compatibilidad verificados.
- [ ] Completar la instalación/actualización dinámica de recursos de módulo y conectar las temporadas de todas las competiciones al ciclo de carrera.
- [ ] Validar las cuatro competiciones y sus dependencias ejecutando Godot 4.4.1 CI.

- [x] Crear contrato común versionado para estados, eventos y resultados de partidos.
- [x] Añadir validación inicial de perfiles de jugadores y equipos.
- [x] Añadir registro offline en memoria para jugadores, equipos y competiciones.
- [x] Ampliar el catálogo cubano a 52 clubes: 16 de Primera, 16 de Segunda y 20 de Tercera.
- [x] Definir reglas españolas adaptadas para las tres divisiones, Copa de Cuba y Supercopa de Cuba.
- [x] Implementar desempates por enfrentamientos directos y minitabla en la clasificación.
- [x] Registrar servicio de datos como autoload para inicializar catálogos, calendarios y tablas al arrancar.
- [x] Añadir generador de calendario todos-contra-todos con ida/vuelta.
- [x] Añadir tabla de clasificación con 3/1/0 y desempates españoles por enfrentamientos directos.
- [x] Añadir simulador rápido reproducible por semilla como baseline técnico.
- [x] Añadir script de pruebas iniciales.
- [ ] Confirmar ejecución satisfactoria del workflow Godot CI y corregir cualquier error de parser/runtime.
- [x] Añadir generadores de calendario para playoff de ascenso de Segunda, Final Four de Tercera, Copa de Cuba y Supercopa; pendiente probar en Godot y conectar resolución de ganadores a la temporada.
- [x] Importar el catálogo cubano ampliado de 52 equipos y tres competiciones.
- [ ] Localizar e importar el archivo fuente canónico de los 704 jugadores documentados.
- [ ] Validar todas las referencias e integridad del catálogo real.
- [ ] Unificar los resultados del partido 3D y del simulador de temporada con el contrato común.
- [x] Implementar base de datos JSON offline con esquema versionado, migración, respaldo, recuperación y escritura atómica.\n- [x] Persistir snapshots de catálogos, resultados, calendarios y clasificaciones; guardar respaldos de temporadas y carreras.\n- [ ] Confirmar pruebas de integridad y persistencia en Godot 4.4.1 CI.

## Fase 2 — Prototipo de entrenamiento 3D
- [x] Definir el centro con Tutorial, Tiro libre y Penalti; Momentos queda reservado a la tarjeta diaria de Inicio.
- [x] Especificar rotación diaria, recompensas idempotentes, modo offline y persistencia.
- [ ] Validar apertura y ejecución del proyecto en Godot 4.x.
- [ ] Proyecto compilable y escena de cancha.
- [x] Integrar base de joystick táctil virtual y botones de Pase, Tiro, Técnica y Presión en Android (validación física y progresión por atributos pendientes).
- [ ] Completar control progresivo con teclado, mando y joystick táctil vinculado a atributos.
- [ ] Gestos táctiles: carga, direcciones, secuencias y gesto circular.
- [ ] Regates básicos/intermedios, presión asistida y técnicas contextuales.
- [ ] Sistema de habilidades por tres niveles, inventario de hasta nueve en Modo Leyenda y asignación aleatoria al subir de nivel.
- [ ] Pase y disparo con carga de potencia, penalización de precisión y variantes gestuales.
- [ ] Balón físico con rebote y fricción.
- [ ] Cámara de seguimiento y HUD de entrenamiento.
- [ ] Pruebas de movimiento, colisión y respuesta del balón.

## Fase 3 — Interfaz y persistencia
- [x] Implementar shell de las cuatro pantallas principales y navegación circular; validar Godot/Android.
- [x] Habilitar Continuar/Nueva partida y abrir el prototipo 3D desde Inicio.
- [x] Añadir navegador de ligas y copas con clasificaciones, fixtures y simulación de jornadas guardada localmente.
- [x] Permitir iniciar la siguiente temporada cuando una fase termina, manteniendo los mismos participantes hasta integrar ascensos/descensos verificados.
- [x] Conectar resultados simulados del club elegido con partidos y objetivos compatibles de la carrera de Entrenador; no avanzar objetivos disciplinarios si el motor no registra tarjetas.
- [x] Conectar catálogo descargable desde Ligas y Copas y desde Configuración > Módulos.
- [x] Conectar el flujo inicial de carrera de Entrenador con clubes y guardado ManagerCareer.
- [x] Integrar desafío diario de Momentos en Inicio, con progreso persistente y reclamación única.
- [ ] Ejecutar y superar pruebas Godot CI; la cola actual falla antes de asignar ejecutor.
- [ ] Implementar categorías y submenús de Configuración.
- [x] Conectar Ligas y Copas y Módulos al catálogo de contenido descargable.
- [x] Conectar el modo Entrenador al servicio ManagerCareer y al catálogo de clubes.
- [x] Implementar servicio local de Momentos con rotación diaria, progreso por goles y recompensa idempotente.
- [ ] Implementar estados de disponibilidad para Online y modos aún no desarrollados.
- [ ] Implementar cinco espacios de guardado por modo, con espacio 1 reservado al autoguardado.
- [ ] Implementar gestión de espacios manuales 2–5, confirmaciones y recuperación segura.
- [ ] Pruebas de navegación, persistencia y recuperación tras cierre inesperado.

## Fase 4 — Partido jugable
- [ ] Dos equipos y 22 jugadores.
- [ ] IA de compañeros, rivales y porteros.
- [ ] Reglas, árbitro, faltas y fuera de juego.
- [ ] Sustituciones, tácticas y estadísticas.
- [ ] Cámara de retransmisión, audio y repeticiones.

## Fase 5 — Competiciones
- [x] Datos ficticios iniciales.
- [x] Catálogo de Primera División cubana (16 clubes, 30 jornadas).
- [x] Reglas base españolas adaptadas para Primera, Segunda, Tercera, Copa y Supercopa.
- [x] Añadir generadores funcionales de fixtures para playoffs, Final Four, Copa y Supercopa; pendiente integración del flujo de resultados y promoción.
- [ ] Conectar eliminatorias y clasificaciones con el motor de partidos.
- [x] Generar calendarios, tablas y desempates para las competiciones importadas y permitir simular jornadas desde el navegador local.
- [ ] Verificar reglamentos oficiales, ascensos/descensos, playoffs y cierre de temporada para cada sistema nacional.
- [ ] Copas, grupos, eliminatorias, prórrogas y penaltis.
- [ ] Temporadas, récords e historial.

## Preparación de partido y selector visual
- [x] Documentar pantalla de selección local/visitante, OVR, estadio, equipaciones, balón y restricciones de configuración oficial/no oficial.
- [ ] Implementar selector visual conectado a catálogos de equipos, estadios, balones y equipaciones.
- [ ] Aplicar precedencia de reglamento y bloqueos de ajustes en partidos oficiales.
- [ ] Probar cambios de apariencia aislados por encuentro y persistencia de configuración.

## Balones oficiales y canteras
- [x] Documentar un balón oficial por liga nacional, compartido por todas sus divisiones, con control de licencias y fuentes CC0/dominio público.
- [x] Definir cantera operativa inicial para Primera y ausencia de cantera en Segunda, Tercera e inferiores; mismas reglas de Segunda para solicitar su creación.
- [x] Crear catálogo JSON inicial de balones oficiales y servicio de resolución/licencia; pendiente crear texturas 3D finales y ampliar a cada liga nacional.
- [x] Adjuntar ID/asset del balón de liga a los fixtures oficiales de las divisiones cubanas; pendiente mostrarlo en el selector y cargar su textura 3D.
- [x] Importar el estado inicial de cantera en cada club: activa en Primera y ausente en Segunda/Tercera/inferiores.
- [x] Implementar auditoría común de licencia, instalaciones, personal, protección juvenil, plan juvenil, inversión inicial y seis meses de solvencia para crear cantera desde Segunda hacia abajo.
- [ ] Conectar equipos juveniles con competiciones, calendarios, scouting, promoción y libro mayor.
- [ ] Ejecutar pruebas de aceptación de balones, canteras, calendarios y carrera Manager en Godot CI; resolver fallos antes de marcarlo completado.

## Fase 6 — Manager / Entrenador
- [x] Documentar objetivos de junta a corto plazo y de temporada para el perfil Entrenador, evaluación contextual, confianza, consecuencias y pruebas de aceptación.
- [x] Implementar evaluación de objetivos cortos por resumen de partido (disciplina, goles en ambas partes y titulares sub-25); pendiente conectar todos los emisores del motor de partido real.
- [ ] Implementar pantalla Directiva y conectar botones, progreso, plazos e historial al servicio ManagerCareer.
- [x] Implementar estado de confianza, avisos de riesgo y revisión de junta en el servicio de carrera; pendientes reuniones, renovación y despido dentro de la interfaz.
- [ ] Plantillas, contratos y mercado.
- [ ] Entrenamiento, scouting, cantera y cuerpo técnico.
- [ ] Finanzas, instalaciones y directiva.
- [ ] Simulación de partidos no jugados.
- [ ] Guardado/carga de carrera.

## Fase 7 — Leyenda
- [x] Crear futbolista con validación de edad (14–45), posición, segunda posición compatible, pie, altura, peso y especialización.
- [x] Ofrecer dos entradas independientes: Crear jugador y Elegir jugador del catálogo Nova.
- [x] Mantener los jugadores creados por el usuario en un registro local independiente del catálogo oficial de Nova.
- [x] Mostrar jugadores personalizados en la selección de Online y guardar por separado el jugador elegido para futuras salas; conexión y salas multijugador siguen pendientes.
- [x] Buscar y filtrar futbolistas del registro deportivo de Nova por nombre, club, nacionalidad y posición, con listado paginado.
- [x] Iniciar carrera desde la ficha elegida conservando ID de origen, club, fecha de nacimiento, edad, posición, pie, media, potencial y los 35 atributos sin regenerarlos.
- [ ] Validar en Godot la navegación, selección, persistencia y conservación de los datos de catálogo.
- [x] Generar y mostrar los 35 atributos individuales agrupados, valoración, potencial, condición, forma y moral.
- [x] Mostrar estadísticas acumuladas de carrera y temporada.
- [x] Implementar cierre de temporada, expiración de contrato y retirada voluntaria solo sin contrato vigente.
- [x] Desbloquear y ofrecer desde la interfaz una nueva carrera de Manager al retirarse con 20 años o más, conservando el historial de Leyenda.
- [ ] Selector de fecha de nacimiento y pruebas/observadores con ofertas de cantera y profesionales.
- [ ] Conectar estadísticas del futbolista con los eventos reales del motor de partido (el servicio y su API ya existen; falta el motor de carrera).
- [ ] Progresión de atributos por entrenamiento, rendimiento y edad.
- [ ] Titularidad, minutos, rol, contratos, renovaciones y transferencias conectados al club.
- [ ] Objetivos, premios y carrera internacional.
- [ ] Interfaz completa de desarrollo, club, temporada, selección, vida personal e inversiones.
- [ ] Validar en Godot todas las reglas y pruebas de aceptación antes de considerar esta fase terminada.

## Fase 8 — Pulido y expansión
- [ ] Editor de equipos y competiciones.
- [ ] Modding JSON validado.
- [ ] Optimización gráfica y de IA.
- [ ] Pruebas de compatibilidad y controles.
- [ ] Evaluar adaptación a Android y multijugador.

**Criterio de avance:** cada fase debe compilar, superar sus pruebas y tener una demostración funcional antes de marcarse como completada. Documentar una función no equivale a implementarla ni a validarla.


## Fase 6 — APK de prueba y validación Android
- [x] Crear preset de exportación Android arm64 para Fútbol Nova.
- [x] Crear workflow manual de importación, smoke test y exportación de APK debug firmado con clave temporal.
- [ ] Ejecutar manualmente el workflow y descargar el artefacto APK.
- [ ] Instalar y probar en un teléfono Android real; verificar tacto, orientación, rendimiento, guardado y recuperación.
- [ ] Corregir errores de importación, parser, runtime o exportación detectados por el primer APK.
- [ ] Completar partido 11 contra 11 antes de presentar el juego como simulador de partidos completo.

## Pausa de automatizaciones
- [x] Retirar disparadores automáticos de los workflows de `.github/workflows/`; se mantienen solo ejecuciones manuales (`workflow_dispatch`).
- [ ] No reactivar automatizaciones sin autorización expresa del propietario.
