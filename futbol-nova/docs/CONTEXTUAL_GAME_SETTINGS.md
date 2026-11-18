# Fútbol Nova — Ajustes contextuales del juego

## Objetivo
Los ajustes podrán abrirse desde el menú principal y desde los menús de cada modo. Cada punto de entrada mostrará únicamente las opciones válidas para el modo y el estado de juego actual. No mostrar controles que no tengan efecto en ese contexto.

## Referencias recibidas
- `assets/references/game-settings-match-reference.jpg`: captura de ajustes de partido, JPEG original 1536 × 863. El binario está pendiente de incorporarse al repositorio.
- `assets/references/game-settings-controller-reference.jpg`: captura de ajustes de controles, JPEG original 1536 × 863. El binario está pendiente de incorporarse al repositorio.

## Diseño visual
- Panel central ancho, fondo azul/gris oscuro.
- Encabezado de sección grande y destacado.
- Pestañas horizontales para categorías.
- Lista de opciones en filas alternas, con etiqueta a la izquierda y valor a la derecha.
- Selección actual en una franja lima de alto contraste.
- Valores modificables mediante flechas, selector o control apropiado.
- Descripción contextual de la opción enfocada en la parte inferior.
- Indicaciones de navegación, volver y restaurar valores predeterminados.
- Crear identidad gráfica, tipografía, iconos y recursos propios de Fútbol Nova; las capturas son referencias, no recursos para copiar literalmente.

## Categorías y opciones

### Partido
- Duración de cada tiempo.
- Dificultad de la IA.
- Comportamiento/competitividad de la IA.
- Dificultad basada en el jugador, si existe ese sistema.
- Perfil de atributos.
- Velocidad del juego.
- Reglas y condiciones del encuentro.

### Controles
- Perfil de mando y asignación de botones.
- Cambio de jugador y método de selección.
- Asistencia de pase raso.
- Asistencia de tiro.
- Asistencia de centros.
- Asistencia de pase elevado.
- Asistencia del portero.
- Sprint analógico.
- Bloqueo del receptor del pase.
- Vibración y sensibilidad, si son compatibles con el dispositivo.

Cada opción debe mostrar una descripción y los valores realmente admitidos por el motor. No ofrecer valores ficticios ni controles sin implementación.

## Acceso por modo

| Contexto | Opciones visibles |
|---|---|
| Menú principal | Preferencias globales, accesibilidad, audio, pantalla, idioma y controles generales |
| Partido rápido / amistoso | Ajustes de partido aplicables al encuentro y controles |
| Torneo / competición | Ajustes de partido permitidos por las reglas de la competición y controles |
| Modo Carrera / Manager | Preferencias de simulación, dificultad y controles pertinentes; reglas bloqueadas si la competición las fija |
| Modo Leyenda | Controles del jugador, cámara, dificultad y opciones de experiencia individual |
| Durante un partido | Solo opciones que puedan cambiarse sin romper la simulación; los cambios que exijan reinicio se indicarán y se aplicarán al siguiente encuentro |

La disponibilidad debe depender de capacidades reales del modo, no únicamente del nombre del modo. Si una opción no aplica, se oculta; si aplica pero está bloqueada por reglas, se muestra deshabilitada con explicación.

## Comportamiento y persistencia
- Distinguir preferencias globales de ajustes guardados por modo, competición o encuentro.
- Mostrar el valor vigente y previsualizar el nuevo valor antes de confirmar cuando corresponda.
- Guardar cambios explícitamente y conservarlos al reiniciar la aplicación.
- Restaurar valores predeterminados con confirmación.
- Permitir volver sin guardar y advertir si existen cambios pendientes.
- No alterar una partida en curso con cambios que requieran reinicio; programarlos para el siguiente encuentro.
- Soportar navegación táctil y mando compatible.

## Criterios de aceptación
1. Cada modo presenta únicamente opciones compatibles.
2. No hay filas vacías, duplicadas ni opciones sin efecto.
3. La selección se distingue claramente y es accesible.
4. Los cambios se guardan y sobreviven al cierre de la aplicación.
5. Restaurar valores solicita confirmación.
6. Las opciones bloqueadas explican el motivo.
7. Se verifica el funcionamiento de cada ajuste contra el motor real del juego.

## Propiedad intelectual
Las capturas se utilizan como referencia funcional y de composición. La interfaz final será original y no reutilizará logotipos, marcas ni activos protegidos de terceros.
