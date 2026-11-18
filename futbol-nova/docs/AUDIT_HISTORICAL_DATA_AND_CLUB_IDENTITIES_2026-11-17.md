# Fútbol Nova — auditoría histórica, identidades y módulos

**Corte:** 17 de noviembre de 2026  
**Repositorio:** `Cumba35/Nova-Workspace`  
**Rama:** `main`  
**Fuentes principales:** datos y catálogos de `proyectos/juegos/futbol-nova/`  
**Propósito:** registrar el estado real después de los lotes de nombres, históricos y contratos de módulos. Esta auditoría no declara terminado lo que sigue sin evidencia o pruebas.

## 1. Archivo histórico de competiciones

Archivo: `data/competition_historical_reference.json`  
Auditoría de huecos: `data/historical_completion_audit_2026-11-17.json`

- **410 ediciones**, **50 fuentes** y 15 módulos/correspondencias de competición: 14 competiciones reales con ediciones y TAS como competición original de Nova sin historia real.
- **571 resultados y 1.618 goles** en siete ediciones con archivo de partidos.
- Solo **7 de 410 ediciones** tienen partidos cargados; **403** siguen sin archivo partido a partido.
- Solo 16 ediciones tienen fecha de final, 122 tienen subcampeón y marcador final, 14 tienen goleadores de temporada, 3 tienen estadísticas estructuradas y 6 tienen goleadores de final.
- Mapeos de identidades históricas reales a futbolistas ficticios aprobados: **0**. Se mantienen pendientes para las 410 ediciones.

### Cobertura partido a partido

| Competición y edición | Partidos | Goles | Cobertura |
|---|---:|---:|---|
| UEFA Champions League 2025/26 | 189 | 655 | Competición principal completa; clasificatorias y eventos individuales pendientes |
| UEFA Europa League 2025/26 | 189 | 512 | Competición principal completa; clasificatorias y eventos individuales pendientes |
| UEFA Conference League 2025/26 | 153 | 379 | Competición principal completa; clasificatorias y eventos individuales pendientes |
| CONMEBOL Libertadores 2025 | 29 | 47 | Solo eliminatorias |
| CAF Champions League 2025/26 | 2 | 3 | Solo los dos partidos de la final |
| CAF Confederation Cup 2025/26 | 2 | 2 | Solo los dos partidos de la final |
| AFC Champions League Elite 2025/26 | 7 | 20 | Solo cuartos, semifinales y final |
| **Total** | **571** | **1.618** | **3 archivos completos de competición principal y 4 parciales** |

Los partidos incluyen IDs estables, fechas, fases, equipos, goles y marcadores. Los globales, tandas y prórrogas se registran cuando la fuente los proporciona. La Conference League se contrastó con UEFA; la fase final AFC con fuentes oficiales de AFC; los lotes africanos y sudamericanos conservan sus fuentes específicas en el JSON.

### Cobertura de campos por competición

| Competición | Ediciones | Con marcador final | Con fecha final | Con goleadores de temporada |
|---|---:|---:|---:|---:|
| Caribbean Cup | 3 | 3 | 0 | 1 |
| CONMEBOL Libertadores | 66 | 66 | 1 | 0 |
| Concacaf Champions Cup | 59 | 2 | 2 | 2 |
| UEFA Champions League | 71 | 7 | 1 | 1 |
| UEFA Europa League | 55 | 7 | 1 | 1 |
| UEFA Conference League | 5 | 5 | 1 | 5 |
| CAF Champions League | 63 | 1 | 1 | 0 |
| CAF Confederation Cup | 23 | 23 | 1 | 0 |
| AFC Champions League Elite | 35 | 2 | 2 | 2 |
| AFC Champions League Two | 1 | 1 | 1 | 1 |
| AFC Challenge League | 1 | 1 | 1 | 0 |
| OFC Champions League | 25 | 1 | 1 | 0 |
| FIFA Intercontinental Cup | 2 | 2 | 2 | 0 |
| FIFA Club World Cup | 1 | 1 | 1 | 1 |

**Interpretación:** un marcador final no equivale a una temporada completa. Los datos ausentes se mantienen pendientes y no se completan por inferencia.

### Trabajo histórico pendiente

1. Importar los 403 archivos de edición que aún carecen de resultados completos, por lotes y con fuentes oficiales o de alta fiabilidad.
2. Completar fechas y sedes de finales, eliminatorias, partidos y fases de grupos.
3. Incorporar goleadores por partido, minuto, tipo de gol y asistencias solo cuando estén documentados.
4. Completar goleadores de temporada y estadísticas estructuradas por edición.
5. Auditar temporadas canceladas, cambios de formato, fusiones y sucesiones sin duplicar títulos.
6. Mantener el TAS separado: no se le inventa una historia real.
7. Vincular futbolistas históricos con identidades ficticias solo tras coincidencia individual inequívoca y aprobación explícita.

## 2. Clubes de las seis ligas base

Archivo: `data/base_league_clubs_2026.json`

Los 451 nombres provisionales fueron reemplazados por nombres ficticios originales y únicos. Se conservaron IDs, referencias de fuente, competición, temporada, división y estado de membresía.

| País | Clubes renombrados |
|---|---:|
| Brasil | 60 |
| Italia | 100 |
| Alemania | 56 |
| Francia | 54 |
| Portugal | 56 |
| Argentina | 125 |
| **Total** | **451** |

- Los 451 clubes conservan `player_ids=[]`: no se inventaron vínculos de jugadores.
- Las membresías siguen pendientes de auditoría con fuentes secundarias; el cambio de nombre no convierte los clubes en jugables ni aprueba sus plantillas.
- Registro de nombres: `data/club_identity_name_review_2026-11-17.json`.
- Validador: `tools/validate_club_identity_names.py`.

## 3. Inglaterra: 68 clubes

Archivo: `data/global_clubs.generated.json`

- Se revisaron y reemplazaron los 68 nombres de presentación con denominaciones ficticias originales.
- Se conservaron los IDs estables y los 22 perfiles ficticios asociados a cada club (1.496 referencias de jugadores en total).
- El alcance aprobado en esta etapa es el nombre de presentación ficticio; no equivale a autorización legal de marca ni a aprobación visual completa.
- Los 68 registros mantienen pendientes los escudos, equipaciones, revisión visual y liberación de marca. El estado de identidad visual no se declara aprobado.
- Registro de revisión: `data/club_identity_name_review_2026-11-17.json`.

## 4. Identidad de jugadores históricos

Los perfiles sintéticos del juego no son futbolistas profesionales reales. Los nombres reales de goleadores y jugadores históricos permanecen en el archivo de referencia. No se asocia un jugador real con un ID ficticio por compartir club, posición, nacionalidad o similitud de nombre.

**Estado:** sin mapeos aprobados. Para avanzar se requiere una correspondencia individual documentada, un alias ficticio original aprobado y la conservación del origen de cada dato.

## 5. Contratos de módulos opcionales

Se completó la estructura contractual de los ocho módulos iniciales en `data/game_modules_manifest.json` y se sincronizó con `data/optional_modules_catalog.json`.

- Narración y comentarios.
- Música y ambiente.
- Estadios adicionales.
- Gráficos avanzados.
- Ligas del Mundo.
- Selecciones nacionales.
- Copas y torneos adicionales.
- Compatibilidad ampliada con mandos.

Los ocho tienen todos los campos contractuales obligatorios y bloqueos de publicación específicos. Siete conservan metadatos de paquete nulos porque aún no existe un paquete real verificado. El módulo de mandos tiene metadatos respaldados (1.0.0, JSON, URL HTTPS, 1.623 bytes y SHA-256), pero permanece en `testing` y `downloadable=false` hasta revalidar integridad, Godot y mandos físicos Android Bluetooth/USB. Ninguna descarga fue habilitada.

Prueba ampliada: `scripts/tests/validate_optional_modules.gd`.

## 6. Validación y ejecución

Se añadieron o ampliaron:

- `tools/validate_club_identity_names.py`: conteos, IDs, unicidad de nombres, ledger, procedencia y estados de identidad.
- `tools/validate_historical_competitions.py`: IDs de partidos, fechas, equipos, goles, marcadores, fuentes y coherencia con estadísticas.
- `scripts/tests/validate_optional_modules.gd`: contratos de los ocho módulos, sincronización de catálogos, metadatos de mandos y bloqueo de descargas.
- `.github/workflows/futbol-nova-android-apk.yml`: incorpora los validadores Python antes de las pruebas Godot.
- `.github/workflows/futbol-nova-historical-data.yml`: conserva la validación automática del archivo histórico en los cambios de sus archivos monitorizados.

**No se declara PASS de Python, Godot, Android ni exportación APK en este corte:** no se ha observado un resultado exitoso de GitHub Actions para los últimos cambios. Los controles estructurales de JSON, conteos, unicidad, correspondencia de catálogos, fechas, marcadores y fuentes se verificaron leyendo los archivos de `main`; falta la ejecución real del workflow y las pruebas físicas.

## 7. Regla de publicación

Ningún módulo se ofrece para descargar hasta que exista el artefacto real, URL HTTPS comprobada, tamaño medido, SHA-256 verificado, derechos/procedencia revisados, compatibilidad aprobada y pruebas de instalación/desinstalación superadas. Los nombres ficticios no sustituyen la revisión de escudos, equipaciones, marcas ni derechos.

**Conclusión:** se completaron los nombres de 519 clubes, la estructura de ocho contratos, los metadatos respaldados del módulo de mandos y dos lotes históricos adicionales. La base histórica global, las membresías, las identidades visuales, los vínculos de jugadores y las pruebas de motor siguen pendientes; no se marcan como terminados sin evidencia.
