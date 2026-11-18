# Módulo de torneos internacionales de selecciones — Fútbol Nova

## Alcance
Módulo independiente del fútbol de clubes. Incluye las seis confederaciones reconocidas por FIFA y torneos globales de selecciones masculinas absolutas.

## Catálogo inicial
- FIFA: Copa Mundial y clasificatorias de las seis confederaciones.
- UEFA: Campeonato Europeo y UEFA Nations League.
- CONMEBOL: Copa América.
- Concacaf: Copa Oro y Concacaf Nations League.
- CAF: Copa Africana de Naciones.
- AFC: Copa Asiática.
- OFC: Copa de Naciones de Oceanía.
- Intercontinental: Finalissima.

El catálogo se encuentra en `data/international_national_team_competitions.json`.

## Reglas de integridad
1. Las selecciones usan IDs propios; nunca IDs de clubes.
2. Los participantes deben pertenecer a asociaciones registradas en `data/national_association_directory.json`.
3. Los futbolistas requieren identidad global, convocatoria oficial y elegibilidad FIFA verificada.
4. No se crean plantillas automáticas a partir de nacionalidad.
5. Cada edición debe guardar participantes, sorteo, calendario, resultados, tablas y campeón.
6. La presentación de sorteos reutiliza `draw_ceremony_requested` y permite saltar la animación sin cambiar el resultado.

## Estado
El catálogo y el módulo están creados y registrados. La interfaz permite consultar las competiciones y sus confederaciones. No se consideran todavía jugables: el manifiesto de selecciones indica que no hay paquetes de plantillas publicados, por lo que quedan pendientes plantillas oficiales, reglas de clasificación por edición, motor de partidos de selecciones y persistencia de temporadas.
