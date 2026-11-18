# Fútbol Nova — Selector de camisetas

**Referencia archivada:** `assets/references/kit-selection-reference.jpg` (JPEG optimizado, 480 × 270 px). El adjunto original recibido fue PNG de 1920 × 1080 px; esta copia reducida está archivada para consulta. El PNG original aún está pendiente de incorporar.

## Dirección visual

- Fondo negro limpio, con título del modo centrado en la parte superior.
- Dos siluetas de futbolistas a los lados, una para cada equipo.
- Zona central dividida en dos paneles: HOME y AWAY.
- Mostrar tres equipaciones por equipo: anterior, seleccionada y siguiente.
- La camiseta seleccionada debe ser mayor, centrada y claramente destacada; las laterales se muestran más pequeñas y atenuadas.
- Flechas a ambos lados del grupo de equipaciones para indicar navegación horizontal.
- Mantener el contraste entre panel activo y no activo, con tipografía deportiva condensada.
- Mostrar dificultad de IA y jugador/perfil en la parte superior; controles de seleccionar y volver en la parte inferior.

## Interacción táctil y mando

- El usuario puede deslizar horizontalmente sobre la camiseta o grupo de camisetas del equipo que desea cambiar.
- Un deslizamiento a la izquierda/derecha cambia únicamente la equipación del equipo tocado, sin alterar la selección del rival.
- Las flechas y los controles del mando realizan la misma acción.
- Al tocar una camiseta lateral, esta pasa al centro con una transición breve y se convierte en la selección activa.
- Evitar que un gesto iniciado fuera del panel de un equipo cambie accidentalmente el otro equipo.
- Mantener una respuesta visual y háptica opcional al cambiar de equipación.
- Validar disponibilidad de equipaciones y evitar duplicados no permitidos por las reglas del modo.

## Adaptación a Android

- En horizontal, conservar dos paneles lado a lado y siluetas laterales cuando el ancho lo permita.
- En vertical, apilar los paneles HOME y AWAY, reducir las siluetas a miniaturas o mostrarlas como vista previa secundaria.
- Mantener camisetas grandes y gestos táctiles fáciles de ejecutar.
- Respetar zonas seguras, notch, barras del sistema y escalado de texto.
- La navegación por deslizamiento debe coexistir con accesibilidad: botones visibles para anterior/siguiente y etiquetas accesibles.

## Reglas de contenido

- Utilizar equipaciones propias, licenciadas o autorizadas para el juego. La captura es referencia de composición e interacción, no permiso para redistribuir camisetas, escudos, marcas o patrocinadores de terceros.
- Permitir personalización de local y visitante según las reglas de cada competición.
- En partidos donde los colores se confundan, advertirlo y sugerir una equipación alternativa.

## Criterios de aceptación

1. Se ven los paneles local y visitante.
2. Cada panel presenta una camiseta seleccionada y vistas previas de las adyacentes.
3. Deslizar horizontalmente sobre un equipo cambia solo ese equipo.
4. Flechas, toque directo y mando permiten la misma navegación.
5. La equipación seleccionada queda claramente destacada.
6. La interfaz se adapta a Android horizontal y vertical.
7. El diseño conserva legibilidad y áreas táctiles cómodas.
8. No se publican recursos de terceros sin autorización.

## Pendientes

- Incorporar también el PNG original de 1920 × 1080, conservando la copia optimizada archivada.
- Crear un mockup original de Fútbol Nova con equipaciones autorizadas.
- Conectar selector con el catálogo de equipaciones, reglas de competición y persistencia de selección.
