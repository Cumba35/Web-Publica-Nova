# Preparación del juego base para pruebas y navegación común

**Proyecto:** Fútbol Nova  
**Fecha de registro:** 2026-11-16  
**Estado:** pantalla de carga integrada y navegación inferior persistente implementadas; verificación Godot/Android pendiente.

## Decisiones confirmadas

1. Preparar el juego base para que pueda utilizarse en pruebas.
2. En todas las pantallas que utilicen navegación entre pasos, el botón **Atrás** debe permanecer en la esquina inferior izquierda y el botón **Siguiente** en la esquina inferior derecha.
3. La posición debe mantenerse en Android y PC, adaptándose a diferentes tamaños de pantalla y áreas seguras. Los controles no deben cubrir contenido importante ni quedar fuera de pantalla.
4. Esta disposición debe tratarse como una regla común de interfaz, no como un ajuste aislado de una pantalla.
5. No declarar el juego listo para pruebas ni terminado hasta ejecutar las comprobaciones correspondientes.

## Alcance de preparación pendiente

- Se auditaron la escena principal, el arranque, el menú y las pruebas existentes antes de integrar la pantalla de carga y la navegación inferior.
- La barra inferior común del menú principal ya presenta Atrás a la izquierda y Siguiente a la derecha; ampliar el patrón a futuros flujos por pasos.
- Verificar anclajes, márgenes, escalado, orientación y áreas seguras en ventanas de PC y pantallas Android; la interfaz aplica márgenes compactos en ventanas estrechas.
- Revisar los controles táctiles y de teclado/mando para que sean coherentes y no se solapen.
- Completar y verificar la base de partido: movimiento y respuesta de jugadores, balón y física, porteros, colisiones, IA, animaciones, reglas y ciclo completo de partido.
- Revisar rendimiento en dispositivos modestos, carga de recursos, guardado, recuperación de errores e instalación.
- Ejecutar pruebas automatizadas en Godot 4 y pruebas manuales en Android y PC; registrar resultados reales, errores y versión del motor.
- Actualizar README, hoja de ruta y esta nota en el mismo cambio que las implementaciones verificadas.

## Estado y límites conocidos

- La fuente canónica del proyecto está en `Cumba35/Nova-Workspace`, ruta `proyectos/juegos/futbol-nova/`.
- El proyecto canónico es un videojuego 3D basado en Godot 4.x. La versión exacta del motor debe confirmarse al ejecutar el proyecto.
- El README existente registra una primera escena de partido local 11 contra 11 en fase de prototipo y varios sistemas aún pendientes. La validación Godot/Android no debe darse por superada sin una ejecución comprobable.
- En una conversación anterior se generó un prototipo experimental separado en formato PWA 2D (`Nova-Futbol-Base-v0.1.0.zip`). Ese ZIP no se ha incorporado ni verificado dentro del repositorio canónico. No mezclar su código web con el proyecto Godot ni sustituir la fuente canónica sin una decisión expresa.
- El ZIP experimental incluía menú, selección de equipo, dificultad, duración, partido 2D simplificado, controles teclado/táctiles, marcador, reloj, pausa y resultado. No equivale al juego 3D canónico ni demuestra que el partido 11 contra 11 esté completo.

## Criterio de aceptación

La preparación se considerará completada cuando:
- Atrás y Siguiente aparezcan en las esquinas inferiores indicadas en todas las pantallas aplicables, tanto en Android como en PC.
- La navegación funcione sin perder el estado de pantalla ni bloquear el contenido.
- El proyecto abra y ejecute el flujo de prueba en Godot 4 sin errores bloqueantes.
- Las pruebas automatizadas y las pruebas manuales previstas tengan resultados registrados.
- Las limitaciones restantes estén documentadas y el proyecto no se etiquete como terminado si aún faltan sistemas esenciales.

## Próximo paso

Ejecutar el workflow de Godot 4.4.1, corregir cualquier error de análisis o prueba y comprobar la APK en Android. Las funciones de red y los modos de partido aún no completos deben seguir identificados como pendientes.
