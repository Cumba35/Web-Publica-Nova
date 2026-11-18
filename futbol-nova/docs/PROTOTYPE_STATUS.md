# Fútbol Nova — estado del prototipo para APK de prueba

## Base del proyecto
- Proyecto Godot 4.4.1 con escena 3D principal.
- Exportación Android ARM64 configurada con identificador `com.nova.futbolnova`.
- Campo 3D, líneas, porterías, iluminación, balón físico, cámara y HUD creados desde la escena principal.
- Personaje controlable Anier Cumbá con modelo procedural temporal.
- Controles de teclado y capa de controles táctiles (joystick, pase, tiro, técnica y presión).

## Partido amistoso 11 contra 11
- Preparación de partido con selección de local y visitante.
- Solo admite clubes con plantillas válidas y diferentes.
- Once inicial 4-3-3 construido a partir de IDs de jugadores del catálogo.
- Controlador local instancia once futbolistas por equipo: Anier como jugador controlado y 21 jugadores de IA con modelos procedurales.
- IA táctica básica de movimiento, aproximación al balón, pase/tiro y entradas.
- Reloj por tiempos, descanso, continuación y marcador conectados al HUD.
- Opciones de duración y reloj disponibles en la preparación del amistoso.

## Pantallas principales
- Inicio: entrada al amistoso y ayuda.
- Online: información del estado de red y acceso al catálogo; no existe backend multijugador conectado.
- Modos: catálogo de modos/módulos, navegación de entrenamiento y accesos locales parciales.
- Configuración: once categorías navegables; controles, módulos, datos e información muestran estado. Varias categorías siguen siendo informativas.

## Pruebas automatizadas
- `tests/test_game_hub.gd`: navegación, pantallas y flujo de selección amistosa.
- `tests/test_match_11v11_foundation.gd`: validación de alineaciones y reglas básicas.
- `tests/test_friendly_match_runtime.gd`: escena principal, cuatro pantallas y creación real del amistoso 11v11.
- El workflow exporta y sube la APK después de superar las pruebas básicas; luego ejecuta la regresión extendida.

## Limitaciones conocidas
- Los modelos de los 21 futbolistas de IA son primitivas procedurales temporales; faltan modelos finales y animaciones completas.
- El sistema de porteros, árbitro, fueras de juego, faltas avanzadas, sustituciones y reglamento completo no está terminado.
- La tanda de penaltis todavía no tiene motor.
- Técnica y varias habilidades aparecen en los controles, pero sus evaluaciones contextuales siguen pendientes.
- El multijugador requiere un backend y un módulo que no están incluidos.
- Algunas opciones de configuración son solo informativas.
- La jugabilidad y el rendimiento deben probarse en un teléfono Android real.

## Bloqueo de compilación
Las ejecuciones recientes de GitHub Actions terminan antes de asignar un runner (`runner_id=0`, sin pasos ni logs). La cuenta debe tener habilitado el uso/facturación de Actions. No se afirma que exista una APK hasta que el workflow termine su exportación y suba el artefacto.
