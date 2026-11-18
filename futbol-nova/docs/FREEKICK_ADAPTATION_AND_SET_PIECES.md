# Fútbol Nova — Adaptación FreeKick y control táctil de balón parado

**Fecha:** 14-11-2026  
**Estado:** primera integración de componentes reutilizables; conexión al motor completo y validación en Godot/Android pendientes.

## Referencia y licencia

Se aprobó estudiar [AKM-8byte/FreeKick](https://github.com/AKM-8byte/FreeKick), proyecto Godot con licencia MIT. Su autoría y licencia se registran aquí para trazabilidad. La licencia MIT permite reutilización bajo sus condiciones, incluida la conservación del aviso de copyright y licencia cuando se copie código. Para Fútbol Nova se eligió crear componentes propios inspirados en los conceptos documentados, no importar el proyecto, sus escenas, modelos, texturas, música ni scripts completos. Los assets y dependencias tienen que revisarse individualmente; la licencia del código no los cubre automáticamente.

Referencia: [repositorio FreeKick](https://github.com/AKM-8byte/FreeKick). La documentación pública describe física configurable, resistencia aerodinámica, efecto Magnus, contacto desplazado, barrera, reacción del portero, animación IK y repeticiones de siete cámaras.

## Componentes añadidos

- `scripts/set_piece_swipe_controller.gd`: control táctil/ratón reutilizable que captura un trazo, limita el número de puntos, normaliza la trayectoria, estima potencia a partir de longitud y duración y emite una señal tipada. Admite saque inicial, tiro libre directo/indirecto, penalti, córner, saque de puerta y saque de banda.
- `scripts/ball_flight_model.gd`: modelo original de paso físico con gravedad, resistencia aerodinámica, fuerza Magnus, decaimiento de giro y conversión inicial de gesto a velocidad/falso/altura.
- `docs/FREEKICK_ADAPTATION_AND_SET_PIECES.md`: contrato de integración y pruebas.

## Cómo se ejecutarán las jugadas a balón parado

El dedo dibuja la trayectoria sobre el área de control. El trazo completo, y no solo la dirección final, se conserva para que el motor de jugada pueda interpretar dirección, curvatura y elevación. La longitud y duración contribuyen a la potencia; las estadísticas del ejecutor, pierna, técnica, fatiga, posición del balón y reglas limitan el resultado.

El mismo reconocedor admite estos reinicios:
1. Saque inicial.
2. Tiro libre directo.
3. Tiro libre indirecto.
4. Penalti.
5. Saque de esquina.
6. Saque de puerta.
7. Saque de banda.

El tipo de jugada no altera el gesto básico; el adaptador de reglas valida la ejecución y aplica restricciones específicas. Por ejemplo, el saque de banda debe respetar la técnica legal de lanzamiento; el penalti parte de una posición fija; los tiros libres pueden añadir barrera y reglas de distancia; los córners y saques de puerta parten de sus zonas reglamentarias. No se permite que el gesto ignore reglas, fuera de juego o contactos legales.

## Funciones de FreeKick que se incorporarán al motor

| Función de referencia | Adaptación prevista en Fútbol Nova | Estado |
|---|---|---|
| Física de balón configurable | Perfil de masa, gravedad, arrastre, Magnus, giro, rebote y fricción | Núcleo aerodinámico inicial añadido; falta conectar perfiles y colisiones al balón real |
| Falso/Magnus y contacto | Curva según spin y punto de impacto | Modelo base añadido; falta calibrar con animación de pie y pruebas |
| Barrera | Formación y colocación según distancia, ángulo y número de defensores | Helper de posiciones añadido en `scripts/set_piece_defensive_setup.gd`; falta conectarlo al árbitro/escena |
| Portero | Lectura del vuelo, retraso de reacción, desplazamiento, salto, blocaje/desvío y dificultad | Perfil de dificultad y retardo de reacción inicial añadidos en `scripts/goalkeeper_reaction_model.gd`; falta trayectoria real, animación y colisiones |
| Animación IK | Resolver piernas/brazos según contacto, carrera y salto | Solver analítico de dos huesos añadido en `scripts/procedural_ik_solver.gd`; falta enlazarlo al esqueleto/animaciones |
| Repeticiones | Siete cámaras seleccionables sobre una misma captura temporal | Siete presets de cámara añadidos en `scripts/replay_camera_rig.gd`; falta sistema de grabación/reproducción temporal |
| Pruebas | Física determinista, gesto, colisiones, gol y repetición | Contrato de pruebas pendiente; aún no ejecutado en Godot |

## Contrato para conectar el gesto al partido

1. El árbitro/reglas anuncia el tipo de reinicio y habilita el control solo mientras el balón esté detenido.
2. El HUD llama a `set_restart_type()` con uno de los siete identificadores admitidos.
3. Al recibir `trajectory_committed`, el controlador del partido valida que el reinicio siga activo y que el ejecutor no haya sido sustituido/interrumpido.
4. El adaptador convierte el camino normalizado al plano local del campo y usa `BallFlightModel.swipe_to_launch()` para obtener velocidad y spin iniciales.
5. El motor aplica potencia, curva y elevación junto con atributos, animación y restricciones específicas del reinicio.
6. La ejecución solo se confirma después de que el motor acepte el lanzamiento. Un gesto cancelado o inválido no consume acción ni cambia el estado del partido.

## Pruebas de aceptación pendientes

- Reconocer trazos cortos/largos y curvas en diferentes tamaños y relaciones de aspecto.
- No duplicar eventos con multitáctil, liberación fuera del área, interrupciones o cambio de tipo de reinicio.
- Verificar que las siete jugadas usan el mismo control y aplican sus reglas particulares.
- Reproducir la misma trayectoria con la misma semilla y parámetros.
- Comparar curva con Magnus activado/desactivado y distintas velocidades/spin.
- Probar el gesto y el rendimiento en Android de gama baja, además de ratón para depuración.
- Validar barrera, portero, IK, repeticiones y sus siete cámaras cuando esos subsistemas se conecten.

**Importante:** los dos scripts añadidos son componentes reutilizables, no equivalen a un motor de partido completo. El prototipo actual sigue sin reglas completas ni ejecución de jugadas a balón parado; la integración del HUD con el árbitro, el balón y el controlador de partido es la siguiente fase.


## Helpers adicionales añadidos

- `scripts/set_piece_defensive_setup.gd`: posiciones de barrera respetando la distancia mínima y perfiles de dificultad para el portero.
- `scripts/goalkeeper_reaction_model.gd`: temporizador de reacción y compromiso con un punto de intercepción que debe suministrar el predictor de vuelo.
- `scripts/procedural_ik_solver.gd`: solución analítica reutilizable para una articulación de dos huesos.
- `scripts/replay_camera_rig.gd`: siete encuadres seleccionables para una futura repetición.

Estos helpers son piezas de infraestructura. No representan todavía una barrera animada, un portero que salta y detiene tiros, un personaje con IK conectado ni un sistema de repetición que graba y reproduce. Esas conexiones requieren el motor de partido completo.
