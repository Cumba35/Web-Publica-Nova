# Módulos continentales de ligas

Cada confederación dispone de un módulo de datos independiente. Los módulos no comparten archivos de ligas y se cargan mediante `scripts/data/continental_league_module_service.gd`.

| Confederación | Archivo | Países/asociaciones catalogados | Ligas en catálogo |
|---|---|---:|---:|
| AFC | `afc.json` | 46 | 17 |
| CAF | `caf.json` | 54 | 10 |
| CONCACAF | `concacaf.json` | 36 | 13 |
| CONMEBOL | `conmebol.json` | 10 | 13 |
| OFC | `ofc.json` | 11 | 0 |
| UEFA | `uefa.json` | 55 | 64 |

El registro central es `manifest.json`. Cada liga conserva su identificador, país, nombre, procedencia, ranking y estado. El catálogo no declara automáticamente una liga como jugable ni descargable.

**Pendientes de datos:** el directorio de asociaciones no contiene actualmente a Estados Unidos; el módulo CONCACAF lo conserva por su presencia en el catálogo de ligas y marca la reconciliación como pendiente. OFC queda creado, pero sin ligas domésticas importadas. Los datos deben validarse antes de publicar paquetes o activar competiciones en carreras.
