# Fútbol Nova — guía para jugadores: botones, gestos y combinaciones

Esta es la guía de consulta dentro del juego. El botón **GUÍA** debe permanecer accesible desde todos los modos mediante el Autoload global `ControlsGuide` registrado en `project.godot`.

> **Estado del prototipo:** la guía y su acceso global están añadidos al proyecto. No significa que todas las acciones estén ya conectadas al controlador de partido. La integración de gestos direccionales, animaciones, físicas, comprobación de atributos y activación de habilidades sigue pendiente de pruebas en Godot y Android.

## Movimiento
- **Joystick izquierdo:** inclinación corta para caminar; mayor inclinación para correr. La velocidad final depende de atributos, resistencia y fatiga.

## Botón de habilidades y técnicas
| Gesto | Técnica | Resultado que se intenta |
|---|---|---|
| Toque/mantener | Auto pase | Empujar el balón hacia delante y correr para alcanzarlo |
| Arriba | Sombrerito | Elevar el balón por encima del rival |
| Abajo | Hueca/caño | Intentar pasar el balón entre las piernas o por la zona de apoyo |
| Izquierda | Elástica | Amagar un cambio rápido de dirección |
| Derecha | Bicicleta | Finta de bicicleta y salida |
| Derecha → abajo | Marsellesa | Giro alrededor del balón para cambiar de lado |
| Izquierda → arriba | Elástica aérea | Elástica con el balón elevado |
| Izquierda → abajo | Ruleta con caño | Giro de ruleta e intento de caño |
| Arriba → derecha | Croqueta | Pasar el balón de un pie al otro y salir en diagonal |
| Arriba → izquierda | Finta de cuerpo | Engañar con hombros/cadera y salir al lado contrario |
| Abajo → derecha | Arrastre atrás y salida | Arrastrar con la planta y salir en diagonal |
| Abajo → izquierda | Giro de protección | Proteger el balón, girar y salir a la izquierda |
| Derecha → arriba | Amago de disparo | Simular el tiro, cancelarlo y conducir hacia delante |

Las direcciones deben realizarse en el orden indicado. Una combinación incompleta, interrumpida o realizada en otro orden puede cancelarse.

### Requisitos mínimos por técnica
Escala de atributos 1–99. Deben cumplirse **todos** los valores de la fila para intentar el movimiento.

| Técnica | Regate | Otros atributos mínimos |
|---|---:|---|
| Auto pase | 25 | Control 30 |
| Sombrerito | 58 | Control 55, Agilidad 48 |
| Hueca/caño | 52 | Control 50, Agilidad 45 |
| Elástica | 78 | Control 72, Agilidad 68, Equilibrio 60 |
| Bicicleta | 48 | Control 45, Agilidad 50 |
| Marsellesa | 68 | Control 65, Equilibrio 58, Agilidad 62 |
| Elástica aérea | 86 | Control 80, Agilidad 78, Equilibrio 70 |
| Ruleta con caño | 74 | Control 70, Equilibrio 65, Agilidad 68 |
| Croqueta | 62 | Control 60, Agilidad 58, Equilibrio 52 |
| Finta de cuerpo | 40 | Agilidad 48, Equilibrio 42 |
| Arrastre atrás y salida | 38 | Control 45, Equilibrio 42 |
| Giro de protección | 45 | Control 42, Equilibrio 55, Fuerza 52 |
| Amago de disparo | 43 | Control 45, Compostura 40 |

Cumplir los mínimos permite intentar una técnica, pero no garantiza superar al defensor. También influyen fatiga, pierna hábil, postura, espacio, control del balón y respuesta del rival. El fallo puede producir un toque largo, bloqueo o pérdida de balón.

## Gesto circular: habilidad avanzada
Dibujar un círculo cerrado alrededor del botón de habilidades solicita una habilidad avanzada aleatoria entre las equipadas que cumplan sus condiciones y tengan el enfriamiento disponible. Si no hay ninguna elegible, no se ejecuta y no se consume uso.

- Máximo **3 activaciones por jugador y partido**, compartidas entre sus habilidades equipadas.
- El contador es individual y se reinicia al comenzar otro partido.
- No se eligen habilidades almacenadas que no estén equipadas.
- Las reglas contextuales, animaciones, interrupciones y enfriamientos siguen aplicándose.

### Espacios de habilidad avanzada
| Nivel general | Espacios |
|---:|---:|
| Menos de 70 | 0 |
| 70–79 | 1 |
| 80–90 | 2 |
| 91–99 | 3 |

Requisito por estrellas: 1–2 estrellas desde nivel 70; 3–4 estrellas desde nivel 80; 5 estrellas desde nivel 90.

## Botón de disparo
- **Toque/mantener:** cargar disparo; la potencia aumenta hasta el máximo y luego se dispara automáticamente. Más potencia puede reducir precisión.
- **Izquierda/derecha:** recorte hacia el lado elegido y disparo automático al terminar.
- **Arriba:** disparo picado.

## Botón de pase
- **Toque/mantener:** pase raso cargado.
- **Arriba:** pase elevado.
- **Izquierda/derecha:** recorte y pase raso.
- **Abajo:** pase atrás de tacón.

La carga aumenta potencia/alcance y puede reducir precisión. La selección del receptor depende de compañeros, rivales, líneas de pase y distancia.

## Botón de presión
- **Toque:** presión defensiva; no garantiza robo.
- **Mantener y deslizar arriba durante 1 segundo:** pedir ayuda al compañero cercano mejor situado. La respuesta depende de distancia, resistencia y posición táctica.

## Acceso desde todos los modos
El acceso se implementa como una capa global de interfaz, no como un botón añadido únicamente a la escena de partido. Por eso puede mostrarse encima de cualquier escena o modo que cargue el proyecto principal. Debe mantenerse visible y no bloquear controles cuando la guía esté cerrada.

## Estado de implementación
- Guía en pantalla: añadida mediante `scripts/controls_guide.gd`.
- Acceso global: registrado como Autoload `ControlsGuide` en `project.godot`.
- Catálogo de gestos y requisitos: definidos en los archivos JSON y documentación del proyecto.
- Reconocimiento secuencial, conexión con animaciones/físicas y aplicación runtime de umbrales: pendientes.
- No se ha ejecutado una prueba de motor Godot ni una prueba en dispositivo Android en este cambio.
