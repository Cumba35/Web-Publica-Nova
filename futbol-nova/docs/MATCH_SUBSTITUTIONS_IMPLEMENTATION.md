# Sustituciones — reglas implementadas y pendientes

Fuente vinculante: `docs/GAME_DESIGN.md`, sección 4.

## Reglas incorporadas en `scripts/gameplay/match_substitution_rules.gd`

- Partidos oficiales: cinco sustituciones y tres ventanas en tiempo reglamentario.
- Descanso cuenta como una ventana; varios cambios en el mismo `window_id` consumen una sola ventana.
- Prórroga añade una sustitución y una ventana (máximo seis y cuatro).
- Amistosos: hasta once sustituciones, sin el límite de ventanas oficiales.
- Los cambios por lesión consumen exactamente una sustitución y una ventana, igual que cualquier otro cambio.
- Un futbolista sustituido no puede volver; expulsados y lesionados graves no pueden entrar como suplentes.
- Antes de penaltis se puede cambiar si siguen disponibles las sustituciones y ventanas.
- Se validan identificadores, fase y ventana; cada operación devuelve una copia de estado para evitar mutaciones parciales.

## Límite actual

La lógica está probada como reglas puras, pero todavía no hay banco de suplentes, menú de pausa ni sustitución de nodos del partido 3D. Por tanto, no se declara disponible la sustitución en el partido jugable hasta integrar esos componentes.
