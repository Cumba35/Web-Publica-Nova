# Fútbol Nova — requisitos mínimos de atributos para técnicas por gesto

**Fecha:** 13-11-2026  
**Escala de atributos:** 1–99

Cada técnica requiere niveles mínimos de atributos individuales. Los umbrales se basan en la dificultad técnica y coordinación que exige el movimiento en el fútbol real. Son valores de diseño de Fútbol Nova, no ratings oficiales ni mediciones científicas. Se evalúan todos los atributos indicados; basta con que uno esté por debajo para impedir la ejecución.

| Técnica | Regate | Otros mínimos |
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

## Reglas

- No se utiliza el overall como sustituto de los atributos técnicos. No hay bonificaciones ni penalizaciones por nacionalidad o posición.
- El reconocedor identifica el gesto; el controlador consulta los mínimos antes de iniciar la animación. Si falta un requisito, cancela la técnica sin ejecutar una acción alternativa accidental.
- Cumplir los mínimos permite intentar el movimiento, pero no garantiza completarlo ni superar al defensor.
- Fatiga, pierna hábil, postura, espacio, presión y atributos del defensor afectan el resultado.
- Los movimientos simples y de protección tienen umbrales menores; la elástica, la elástica aérea y las técnicas compuestas tienen umbrales mayores por su dificultad.

## Mapeo de atributos

| Clave de datos | Atributo |
|---|---|
| `drib` | Regate |
| `ctrl` | Control del balón |
| `agi` | Agilidad |
| `bal` | Equilibrio |
| `str` | Fuerza |
| `comp` | Compostura |

Los umbrales están centralizados también en `data/skills/common_gesture_techniques.json`, bajo `technique_requirements.thresholds` y `minimum_attributes` por técnica.

## Estado de integración

Los requisitos están definidos en los datos. Todavía falta que el controlador del partido aplique la comprobación antes de ejecutar cada gesto, y después validar los valores mediante pruebas jugables en Godot. No se considera aplicado en tiempo de juego hasta completar esas tareas.
