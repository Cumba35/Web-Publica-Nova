# Pantalla principal — Modo Leyenda

## Referencia visual
- Archivo archivado: `assets/references/legend-mode-home-reference.jpg`
- Formato archivado: JPEG optimizado, 480 × 300 px.
- Adjunto original recibido: JPEG, 1536 × 960 px. El original a resolución completa aún debe incorporarse; no se sustituye por la copia optimizada.
- Estado: copia archivada y recuperada desde GitHub; SHA del blob: `7b85aea31e6e4637de56ded9c6bcfd5e3fe381c4`.

## Dirección visual y estructura
- Fondo azul con motivos gráficos deportivos y navegación por pestañas en la zona superior.
- Panel principal amplio a la izquierda para mostrar el contenido de la sección activa.
- Futbolista 3D de cuerpo completo a la derecha, con uniforme, apariencia y pose vinculados al jugador creado.
- Franja inferior con accesos a Desarrollo del jugador, Personalidad, Notificaciones, Mi carrera y Centro de plantilla.
- Cabecera de estado con nombre/club/entrenador, posición, valoración general, puntos de habilidad y saldo cuando corresponda.
- Indicadores de controles contextuales en la parte inferior.

## Comportamiento
- Las pestañas superiores cambian entre Central, Mi Pro, Temporada y Personalizar.
- Las tarjetas inferiores abren sus secciones; la activa se resalta visualmente.
- El panel principal cambia su título, descripción, estadísticas y acciones según la sección.
- La información debe reflejar el estado real de la carrera guardada: temporada, logros, estadísticas, plantilla, notificaciones y progresión.
- El jugador 3D debe actualizarse al cambiar apariencia, equipación, posición o personalización.
- Adaptar el diseño a pantallas móviles sin perder jerarquía: paneles apilables, navegación táctil y textos legibles.

## Nota de implementación
La captura sirve únicamente como referencia de composición y experiencia. Fútbol Nova tendrá interfaz, iconografía, tipografía y recursos gráficos propios; no se copiarán logotipos ni activos protegidos de terceros.

## Implementación funcional — 14-11-2026

- El Modo Leyenda se abre desde Modos y permite crear un futbolista de 14 a 45 años.
- El creador valida posiciones, compatibilidad de segunda posición, pie dominante, altura, peso y especialización. Los 35 atributos se generan por posición/especialización y se presentan agrupados.
- El servicio LegendCareer conserva la carrera en user://legend_career.json con copia de respaldo y esquema versionado.
- El panel presenta atributos, valoración, potencial, condición, forma, moral, estadísticas de temporada, estadísticas acumuladas, historial de temporadas y premios.
- La retirada aparece como acción del modo y solo se habilita al cerrar la temporada y no tener contrato vigente. La confirmación advierte que la retirada es definitiva.
- Al retirarse con 20 años o más se ofrece iniciar una carrera de Manager; el archivo de Leyenda se conserva por separado.
- La progresión de cantera a pruebas al cumplir 15 años está contemplada. Un jugador de 14 años no puede firmar contrato profesional.
- La duración de un contrato no puede extenderse más allá de la edad máxima jugable de 45 años.

## Límites de integración pendientes

- Los registros de estadísticas incluyen `record_match` y el puente `record_match_from_contract(match_result, player_match_stats, player_team_id)`. El puente valida el ID del futbolista, el equipo participante y el marcador final, y deriva el resultado del equipo para acumular las estadísticas. El motor de partidos de carrera todavía no invoca automáticamente el puente; no se deben presentar estadísticas de partidos reales hasta integrar ese emisor.
- Las pruebas ante observadores, ofertas de clubes, calendario competitivo, minutos/titularidad reales, progresión por entrenamiento y selecciones siguen pendientes.
- La ejecución de pruebas Godot y la validación Android deben confirmarse en CI/dispositivo antes de declarar el modo terminado.
