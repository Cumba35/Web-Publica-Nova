# Módulos independientes de ligas continentales

## Objetivo

Separar el catálogo de ligas de Fútbol Nova en seis módulos de datos independientes, uno por confederación. La región geográfica sigue disponible como filtro secundario; no reemplaza la afiliación oficial a una confederación.

## Estructura

- `data/continental_leagues/manifest.json`: índice central.
- `data/continental_leagues/afc.json`
- `data/continental_leagues/caf.json`
- `data/continental_leagues/concacaf.json`
- `data/continental_leagues/conmebol.json`
- `data/continental_leagues/ofc.json`
- `data/continental_leagues/uefa.json`
- `scripts/data/continental_league_module_service.gd`: carga, consulta y validación de módulos.
- `tests/test_continental_league_modules.gd`: prueba estructural añadida al workflow Android.

## Cobertura del primer corte

| Módulo | Asociaciones/países catalogados | Ligas en catálogo |
|---|---:|---:|
| AFC | 46 | 15 |
| CAF | 54 | 9 |
| CONCACAF | 36 | 12 |
| CONMEBOL | 10 | 10 |
| OFC | 11 | 0 |
| UEFA | 55 | 54 |
| **Total** | **212 registros** | **100** |

Los países/asociaciones se toman del directorio FIFA del proyecto. El registro de Estados Unidos se añade a CONCACAF desde el catálogo de ligas ya existente, porque el directorio nacional actual no lo contiene; queda expresamente marcado para reconciliación. El total de 212 registros no debe confundirse con el directorio fuente de 211 asociaciones.

Las ligas provienen de `global_league_selection_100.json` y de `league_content_manifest.json`. Los módulos conservan país, nombre, ranking, origen, estado, y referencias de paquete cuando existen. No se inventan plantillas ni paquetes descargables.

## Contrato de módulo

Cada archivo contiene:
- `module_id`, `module_type`, `confederation_code` e `independent`.
- `countries`: asociaciones asignadas a esa confederación.
- `leagues`: catálogo propio con ID, país, nombre, procedencia, posición y estado.
- `module_status`: estado general del catálogo.

El servicio autoload `ContinentalLeagues` expone:
- `load_modules()`
- `get_module(confederation_code)`
- `get_leagues(confederation_code)`
- `get_all_leagues()`
- `get_summary()`

La validación comprueba que estén presentes las seis confederaciones, que no se repitan IDs de asociaciones ni de ligas entre módulos, que las asociaciones pertenezcan al módulo correcto y que las ligas tengan identidad mínima.

## Estado y límites

- La separación física, el índice, el cargador y la validación están implementados.
- El navegador de contenido consume los seis módulos y permite filtrar por confederación y región.
- El catálogo reúne 100 ligas únicas; no son 100 ligas jugables.
- La selección del juego base es la del manifiesto de contenido: ocho ligas del ranking principal más Cuba y Estados Unidos. El ranking IFFHS se conserva por separado en `global_league_tiers.json`.
- OFC está creado pero todavía no contiene ligas domésticas importadas.
- Las carreras y el importador global existente no se migran automáticamente a estos módulos en este primer corte.
- La importación de clubes, futbolistas, calendarios y reglas desde cada módulo, y su activación en el navegador de ligas, siguen pendientes de integración.
- El workflow de validación está configurado, pero no se declara aprobado hasta que se ejecute en Godot 4.4.1 y se obtenga un resultado exitoso.

## Prueba

```sh
godot --headless --path . --script res://tests/test_continental_league_modules.gd
```
