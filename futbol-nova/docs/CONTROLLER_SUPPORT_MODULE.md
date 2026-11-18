# Módulo de mando externo — Fútbol Nova

**Estado:** adaptador integrado en el arranque, pantalla de estado/configuración y navegación de menú conectadas; validación Godot y pruebas físicas pendientes. El paquete aún no se publica para descarga hasta completar esas pruebas.

## Referencias de diseño (patrones, no copia)

- **EA SPORTS FC Mobile:** tomar como referencia la separación entre controles de movimiento, acciones contextuales y tutorial de gestos. Fútbol Nova conservará su propio esquema táctil.
- **eFootball:** tomar como referencia los perfiles de control, ayuda contextual y ajustes de sensibilidad.
- **Dream League Soccer:** tomar como referencia la accesibilidad de controles sencillos en pantalla pequeña y la posibilidad de jugar sesiones rápidas.
- **Godot Engine:** usar InputMap para abstraer acciones, InputEventJoypadButton/InputEventJoypadMotion para botones y ejes, y Input.get_connected_joypads() para detectar dispositivos.

No se copiarán código, marcas, escudos, imágenes, pantallas exactas, animaciones ni recursos propietarios de esos juegos. Solo se adoptan patrones generales de experiencia de usuario y mecánicas conocidas.

## Funcionamiento modular

1. El jugador instala el paquete de contenido `controller_support` desde el catálogo de módulos.
2. El paquete aporta `controller_profiles.json` con perfiles y asignaciones configurables.
3. El juego comprueba la instalación y activa el módulo de entrada incluido en el núcleo.
4. Sin paquete instalado, el juego mantiene los controles táctiles y teclado actuales; el módulo no activa entradas de mando.
5. Al conectar/desconectar un mando durante la partida, el módulo actualiza el estado sin reiniciar el juego.
6. La pantalla Mando externo muestra si el módulo está activo, el número de dispositivos y el perfil seleccionado.
7. El foco inicial de las tarjetas y la acción de volver permiten navegar con cruceta cuando el perfil está activo.

El código ejecutable del adaptador está en el proyecto base para que el juego no tenga que descargar código ejecutable arbitrario. El módulo descargable habilita el adaptador mediante perfiles de configuración validados.

## Asignación inicial genérica

| Entrada | Acción |
|---|---|
| Stick izquierdo | Movimiento del futbolista |
| A / Cruz / botón inferior | Pase / aceptar |
| B / Círculo / botón derecho | Disparo / cancelar |
| X / Cuadrado / botón izquierdo | Habilidad |
| Y / Triángulo / botón superior | Presión |
| Cruceta | Navegación por menús |
| Stick derecho | Cámara (reservado para integración posterior) |
| Start / Options | Pausa (pendiente de conectar) |

Las asignaciones se consideran valores iniciales genéricos. El usuario podrá reasignarlas y guardar perfiles por dispositivo. Las etiquetas A/B/X/Y cambian entre mandos Xbox y PlayStation; la interfaz debe mostrar glifos detectados o etiquetas neutrales (Inferior/Derecha/Izquierda/Superior).

## Ajustes

- Zona muerta independiente para cada stick.
- Sensibilidad.
- Invertir ejes.
- Reasignación de botones.
- Vibración opcional solo cuando el dispositivo y la plataforma la soporten.
- Mostrar nombre del mando y estado de conexión.
- Restaurar perfil predeterminado.
- Probar botones y ejes en una pantalla de diagnóstico.

## Compatibilidad y límites

Godot documenta soporte para mandos en Android, Windows, macOS, Linux, iOS y Web. En Android usa una implementación de entrada distinta de la ruta SDL de escritorio, por lo que algunos mandos pueden comportarse de forma diferente. No prometer compatibilidad universal: probar modelos Bluetooth y USB reales, distintos fabricantes y versiones Android.

Fuentes técnicas:
- https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html
- https://docs.godotengine.org/en/latest/classes/class_input.html
- https://docs.godotengine.org/en/latest/classes/class_inputeventjoypadbutton.html

## Archivos

- `modules/controller_support/module.json`
- `modules/controller_support/controller_profiles.json`
- `scripts/input/controller_support_module.gd`
- `tests/test_controller_support.gd`

## Integración realizada en esta fase

- Adaptador comprueba el paquete instalado y valida todas las acciones requeridas antes de activar entradas.
- Se corrige la doble notificación de conexión del mismo dispositivo.
- La interfaz muestra estado del módulo y dispositivos conectados.
- Se añade navegación de retorno al inicio mediante `ui_cancel`.
- La descarga sigue bloqueada mientras `content_status` no sea `published`; no se debe saltar la validación de Godot ni la prueba física para habilitarla.

## Aceptación

- El paquete ausente deja el juego táctil intacto.
- El paquete instalado activa las asignaciones.
- Conectar y desconectar un mando se detecta en caliente.
- El stick izquierdo mueve el jugador sin exceder velocidad diagonal.
- Pase, disparo, habilidad, presión y navegación funcionan.
- Dos mandos distintos pueden mapearse y remapearse.
- La desconexión no deja acciones atascadas.
- Pruebas físicas Android y pruebas Godot automatizadas pasan.
