# Fútbol Nova — Menú de pausa durante el partido

**Estado:** diseño funcional documentado; maqueta e implementación pendientes.  
**Referencia visual archivada:** `assets/references/pause-menu-reference.jpg` (JPEG optimizado, 384 × 216). El adjunto original recibido en el chat era de 1536 × 864; esta copia reducida se archivó para consulta visual. El original a resolución completa aún no está incorporado.  
**Ruta prevista:** [pause-menu-reference.jpg](../assets/references/pause-menu-reference.jpg).  
**Estado de archivo:** la referencia visual está guardada y verificada en GitHub. La copia archivada es una versión optimizada de menor resolución; conservar e incorporar también el original de 1536 × 864 cuando se disponga de un mecanismo de transferencia binaria adecuado. Consultar [el índice de referencias](../assets/references/README.md).

## Dirección visual

- El partido y el estadio permanecen visibles detrás del menú, con campo, gradas y ambiente del encuentro.
- Paneles grandes, rectangulares y semitransparentes en negro/grafito, con separadores y bordes discretos en verde lima.
- Tipografía deportiva sans-serif, gruesa, blanca y de alta legibilidad.
- La opción enfocada se resalta con un panel claro/blanco y texto negro; las no seleccionadas permanecen oscuras.
- Iconos simples, grandes y de bajo contraste en la zona derecha de cada panel.
- El menú ocupa la zona central sin ocultar por completo el contexto del partido.
- En el panel izquierdo se presenta el equipo controlado, la formación y una representación compacta de la alineación sobre un esquema de campo, con valoración de cada jugador y estilo táctico.
- Mantener la identidad visual propia de Fútbol Nova; la captura es referencia de composición y jerarquía, no para copiar marcas, logotipos ni recursos protegidos.

## Estructura de opciones

1. **Reanudar partido** — opción inicial seleccionada. Cierra el menú y continúa exactamente desde el estado pausado.
2. **Repetición instantánea** — abre la repetición reciente si el sistema está disponible. Si no, mostrarla deshabilitada o explicar que no está disponible; no simularla.
3. **Entrenador / Tácticas** — permite consultar y modificar formación, estilo táctico, instrucciones y sustituciones según las reglas del modo.
4. **Datos del partido** — marcador, tiempo, estadísticas, posesión, tiros, faltas, tarjetas, alineaciones y eventos.
5. **Configuración** — cámara, controles, audio, vibración, gráficos y accesibilidad.
6. **Abandonar partido** — solicita confirmación previa y explica las consecuencias para el modo/competición.

## Interacción y navegación

- Abrir mediante el botón de pausa del dispositivo/controlador o el botón táctil durante el partido.
- Congelar simulación, reloj, IA, balón, entradas, animaciones de juego y audio de ambiente. La música/interfaz puede continuar si la configuración lo permite.
- Navegación mediante mando, teclado o toque; al tocar un panel se enfoca y las acciones destructivas requieren confirmación.
- Reanudar es la opción predeterminada y debe ser fácil de alcanzar.
- En pantallas táctiles, usar áreas de toque amplias; no depender de hover.
- Al abandonar, mostrar «Continuar jugando» y «Abandonar».
- Al reanudar, restaurar el estado exacto, sin saltos de cámara ni entradas fantasma.

## Diseño adaptable — decisión de diseño

Se conserva la identidad y la jerarquía de la referencia, pero no se fuerza una copia rígida de su cuadrícula en todos los dispositivos.

- **Pantallas anchas (PC/tablet horizontal):** composición de dos zonas. Panel de equipo y alineación a la izquierda; seis acciones en cuadrícula 2 × 3 a la derecha. Estadio visible como fondo.
- **Android en horizontal:** mantener dos zonas cuando el ancho útil lo permita. Reducir el panel de alineación a una vista compacta y conservar botones grandes.
- **Android en vertical:** usar una cabecera compacta con escudo/nombre del equipo y formación; debajo, acciones en una lista de tarjetas de ancho completo, con icono y texto. La alineación se abre en un panel secundario o desplegable para no comprimir las acciones.
- **Selección activa:** tarjeta clara/blanca con texto oscuro; las demás en grafito con acento verde lima. Mantener contraste suficiente incluso sobre fondos luminosos.
- **Controles táctiles:** objetivos amplios, separación entre acciones y confirmación diferenciada para «Abandonar partido».
- **Adaptación:** respetar zonas seguras, notch, barras del sistema, orientación y distintas relaciones de aspecto; ofrecer escalado de texto y contraste accesible.
- **Regla de prioridad:** en móvil debe ser más fácil reanudar o elegir una acción sin tapar innecesariamente el campo; la fidelidad a la referencia nunca debe perjudicar legibilidad ni usabilidad.

## Criterios de aceptación

1. El fondo muestra el estadio y el partido congelado.
2. «Reanudar partido» aparece seleccionada por defecto.
3. La alineación muestra equipo, formación y jugadores legibles.
4. Las seis opciones están presentes y cada una abre su pantalla/acción.
5. Repetición instantánea solo se habilita cuando existe una repetición real.
6. La pausa detiene el estado del partido y el reloj no avanza.
7. Abandonar requiere confirmación y comunica consecuencias.
8. Navegación táctil, teclado y mando.
9. Al reanudar se recupera el estado exacto, sin duplicar entradas ni acciones.
10. Adaptación a Android y PC sin perder legibilidad.

## Pendientes

- Incorporar también el JPEG original de 1536 × 864, conservando la copia optimizada ya archivada.
- Diseñar el mockup propio de Fútbol Nova.
- Integrar pausa con simulación, IA, reloj, audio y animaciones.
- Conectar tácticas, datos, ajustes y replay.
- Definir consecuencias de abandonar por modo.
- Probar distintas resoluciones y métodos de entrada.
