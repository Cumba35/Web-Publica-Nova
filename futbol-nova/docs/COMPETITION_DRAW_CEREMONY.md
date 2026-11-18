# Nova Fútbol — Ceremonia audiovisual de sorteos

## Objetivo

Todos los sorteos y cuadros de competición existentes utilizan una misma presentación animada dentro del juego, inspirada en las ceremonias de sorteos de FIFA. No se genera un archivo MP4: Godot reproduce una escena animada con extracción y revelación progresiva.

## Funcionamiento

1. El motor de competición calcula y valida el sorteo una sola vez.
2. El servicio guarda el resultado cuando corresponde y emite `draw_ceremony_requested`.
3. GameHub recibe el evento y abre `NovaCompetitionDrawCeremony`.
4. La ceremonia revela los equipos, grupos, rondas y rivales en secuencia.
5. **SALTAR SORTEO** detiene la animación, muestra inmediatamente todos los resultados restantes y conserva intacto el sorteo original.
6. Al terminar, el usuario pulsa **CONTINUAR**.

La presentación no genera ni modifica emparejamientos. Tampoco vuelve a sortear al saltarse la animación.

## Competiciones y operaciones conectadas

| Competición / operación | Datos mostrados |
|---|---|
| Liga de Campeones del Caribe | Sorteo de grupos, octavos y rondas eliminatorias |
| Liga de Campeones de Sudamérica | Sorteo de grupos |
| Liga de Campeones de Norteamérica y Centroamérica | Sorteo de grupos |
| Torneo Americano de Supercampeones | Grupos iniciales, grupo final y final |
| Copa de Cuba | Cuadro completo generado por rondas |
| Supercopa de Cuba | Semifinales y final |
| Playoff de Segunda División | Emparejamientos de ascenso |
| Playoff de Tercera División | Emparejamiento de ascenso |

Las ligas que utilizan un calendario todos-contra-todos no celebran sorteo de emparejamientos; el calendario se genera mediante el planificador de jornadas.

## Integración técnica

- Señal común: `FootballData.draw_ceremony_requested`.
- Presentación: `scripts/ui/competition_draw_ceremony.gd`.
- Adaptador de interfaz: `GameHub.present_competition_draw()`.
- Adaptador de edición: `GameHub.present_edition_draw()`.
- El servicio transforma los fixtures y emparejamientos ya resueltos en entradas de presentación.
- Los nombres de ambos clubes se obtienen del registro de clubes; se conserva el identificador como respaldo.

## Pruebas

- `tests/test_competition_draw_ceremony.gd`: comprueba apertura, revelación inicial, salto, conservación de resultados y botón de continuación.
- `tests/test_game_hub.gd`: comprueba que el evento del servicio abre la ceremonia desde GameHub.
- Ambas pruebas están incluidas en `.github/workflows/futbol-nova-android-apk.yml`.
- Estado de ejecución: pendiente de una ejecución CI con Godot 4.4.1.

## Límite conocido

La ceremonia es una animación interactiva en tiempo real dentro de Godot, no un vídeo MP4 pre-renderizado. Los métodos de creación de competición que generan un sorteo emiten el evento; las pantallas futuras que creen nuevos tipos de competición deberán utilizar el mismo evento en vez de crear una presentación paralela.

## Auditoría y corrección — 16 de noviembre de 2026

Se corrigieron dos defectos en los puntos de entrada de sorteos eliminatorios del Caribe:

- El sorteo de octavos y el de las rondas posteriores comprobaban al revés el indicador `ok`; podían emitir la ceremonia cuando el motor rechazaba el sorteo y retornaban antes de guardar el cuadro.
- Ahora ambos métodos detienen el flujo si el motor devuelve error, guardan primero la edición actualizada en el estado de temporada y solo después emiten la ceremonia. Así, la animación nunca anuncia un cuadro que no se haya guardado correctamente.

Se añadieron comprobaciones de regresión en `tests/test_game_hub.gd` para proteger el orden de validación, guardado y emisión. La prueba de ceremonia y la de GameHub continúan incluidas en el workflow Android.

**Cobertura comprobada por lectura de código:** Caribe (grupos y sorteos eliminatorios), Sudamérica y Norte/Centroamérica (sorteo inicial), TAS (grupos iniciales y progresión a grupo final/final), Copa y Supercopa de Cuba, y playoffs de ascenso de Segunda y Tercera. Los calendarios de liga todos-contra-todos no requieren sorteo. No se encontró todavía un flujo de creación de torneos personalizados conectado a la interfaz; cuando ese modo se implemente, deberá emitir la misma señal. La cobertura de competiciones que aún no tienen un flujo jugable no se considera completada.

**Validación:** los cambios se guardaron en GitHub. Las pruebas automatizadas están configuradas en CI, pero no se declara que hayan pasado hasta disponer de una ejecución satisfactoria del workflow con Godot 4.4.1.

## API común para torneos personalizados

Se añadió `FootballData.publish_resolved_competition_draw(competition_name, draw_result)`. Los módulos de torneos personalizados pueden publicar un sorteo ya validado y persistido mediante la misma señal que abre la ceremonia común. La API rechaza nombres vacíos, resultados vacíos y entradas de formato no admitido. No crea ni guarda emparejamientos: el motor del torneo debe guardar primero el resultado definitivo.
