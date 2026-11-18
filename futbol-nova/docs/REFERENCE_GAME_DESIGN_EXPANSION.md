# Fútbol Nova — Ampliación de diseño basada en referencias de juegos

**Fecha:** 2026-11-14
**Objetivo:** completar decisiones funcionales todavía abiertas utilizando patrones generales observables en juegos de fútbol conocidos. No copiar código, assets, marcas, escudos, nombres de modos exclusivos ni pantallas exactas.

## 1. Referencias y qué se toma de ellas

### EA SPORTS FC Mobile
La página oficial presenta Skill Games para control del balón, tiro, agilidad y pase, además de controles contextuales y gestos. Fútbol Nova adopta retos cortos por habilidad con objetivos y puntuación, ejercicios repetibles, instrucciones visuales y variantes por dificultad y precisión.
Fuente: https://www.ea.com/games/ea-sports-fc/fc-mobile

### eFootball Mobile
Konami documenta tutoriales paso a paso y partidos de práctica, asistencia configurable y controles Bluetooth en partidos. Fútbol Nova adopta tutorial inicial por etapas, perfil de mando y tabla de comandos, comandos contextuales según ataque/defensa/balón parado y ajustes para ayudas automáticas.
Fuentes: https://www.konami.com/efootball/en/page/overview ; https://www.konami.com/efootball/en/page/mobile_controller
Diferencia deliberada: Konami indica que el mando móvil no navega sus menús. Fútbol Nova debe permitir mando también en menús, catálogos y ajustes.

### Dream League Soccer
La ficha oficial de App Store describe juego 3D y anuncia compatibilidad con mando. Fútbol Nova toma como referencia la importancia de un control sencillo, accesible y consistente en sesiones rápidas, sin asumir que todos los modelos funcionan igual.
Fuente: https://apps.apple.com/us/app/dream-league-soccer-2026/id1462911602

## 2. Detalles que se añaden a Fútbol Nova

### A. Ciclo común de cada ejercicio
1. Presentación: objetivo, duración opcional, controles y recompensa si existe.
2. Preparación: colocación de jugador, balón, portería, obstáculos o portero.
3. Ejecución: física compartida con el partido.
4. Evaluación: resultado observable, precisión, tiempo, intentos y faltas.
5. Resumen: puntuación, medalla, mejor marca y repetir/salir.

### B. Tutorial
- Lecciones desbloqueables en orden, con opción de repetir cualquier lección disponible.
- Indicador de botón/gesto actual que cambia según la última entrada detectada.
- La asistencia no ejecuta acciones por el jugador; solo explica o destaca el control.
- Se supera al cumplir un objetivo verificable.

### C. Tiro libre
- Ajustes independientes de dirección, altura, potencia y efecto.
- Vista previa aproximada de trayectoria opcional.
- Barrera editable: cantidad y separación de defensores.
- Portero con posicionamiento y reacción según atributos.
- Resumen de intentos, goles, tiros a puerta y precisión por zona.

### D. Penalti
- Modos: lanzador, portero, serie de cinco y práctica ilimitada.
- Ajustes de dirección, altura y potencia.
- Portero con anticipación probabilística basada en lectura, reflejos y colocación.
- Registro de goles, atajadas, tiros desviados y zonas elegidas.

### E. Práctica libre
- Sin cronómetro obligatorio.
- Reinicio rápido y selección de escenarios (solo balón, portero, defensores pasivos).
- Objetivos opcionales configurables que no interrumpen la sesión.

### F. Momentos / desafíos diarios
- Retos derivados de los mismos ejercicios: completar secuencia, marcar desde una zona, acertar a objetivos o alcanzar precisión mínima.
- ID estable por día y versión de reglas.
- Progreso guardado localmente; una sola reclamación por perfil y ciclo.
- Sincronización idempotente al volver a conectarse.
- La recompensa se define por datos del reto, no se hardcodea en la UI.

## 3. Módulo de mando externo
Archivos: modules/controller_support/module.json; modules/controller_support/controller_profiles.json; scripts/input/controller_support_module.gd; data/controller_modules_catalog.json; docs/CONTROLLER_SUPPORT_MODULE.md.
El módulo aporta perfiles y activa un adaptador de entrada del juego cuando el paquete está instalado. El código ejecutable permanece dentro del juego base; no se descarga ni ejecuta código arbitrario. El módulo permanece en pruebas hasta superar validación de Godot y pruebas físicas en Android.

## 4. Prioridad de implementación
1. Mando: instalar/desinstalar paquete, detectar conexión, mapear movimiento/pase/tiro y navegar menús.
2. Ejercicios: completar el bucle de práctica y evaluación compartido.
3. Tutorial: construir lecciones y seguimiento.
4. Desafíos diarios: definir plantillas, ciclos, persistencia y reclamación segura.
5. Ajustes: perfiles táctiles/mando, sensibilidad, zona muerta y remapeo.
6. Pruebas en Android con mandos Bluetooth y USB, incluyendo reconexión, desconexión y mandos con mapeo no estándar.

## 5. Criterio de compatibilidad
No declarar compatibilidad universal. Godot explica que Android utiliza una implementación de entrada distinta de la ruta SDL de escritorio y que el comportamiento puede variar. Mantener perfiles remapeables, zona muerta ajustable y pantalla de diagnóstico.
Fuente técnica: https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html
