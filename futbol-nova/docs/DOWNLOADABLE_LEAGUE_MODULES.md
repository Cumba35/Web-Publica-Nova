# Distribución regional y módulo descargable de ligas

## Decisión de producto

Fútbol Nova tendrá un juego base y un módulo independiente de ligas mundiales adicionales.

- **Juego base:** selección propia de diez entradas registrada en `data/league_content_manifest.json`: Inglaterra, España, Brasil, Italia, Alemania, Francia, Portugal, Argentina, Cuba y Estados Unidos.
- **Módulo «Ligas del Mundo»:** las demás ligas del catálogo global, con navegación por confederación, región, país, división, competición y temporada.
- **Ranking de referencia:** `data/global_league_tiers.json` conserva el ranking IFFHS 2025 y determina la política general de divisiones; no decide por sí solo qué diez paquetes forman el juego base. Cuba y Estados Unidos son selecciones explícitas del proyecto; Países Bajos y Colombia permanecen como opciones futuras.
- El usuario podrá descargar una liga, varias ligas, todas las ligas de una región o todas las ligas publicadas.
- El módulo no obliga a descargar todo el catálogo. Los paquetes se instalan individualmente y funcionan sin conexión después de descargarse.

## Regiones del catálogo

1. Europa
2. Sudamérica
3. Norteamérica, Centroamérica y Caribe
4. África
5. Asia
6. Oceanía

Las regiones vacías son espacios de catálogo para futuras incorporaciones, no indican que ya existan paquetes descargables.

## Las diez ligas del juego base

| Puesto | País | Liga | Región |
|---:|---|---|---|
| 1 | Inglaterra | Premier League | Europa |
| 2 | España | LaLiga | Europa |
| 3 | Brasil | Brasileirão Série A | Sudamérica |
| 4 | Italia | Serie A | Europa |
| 5 | Alemania | Bundesliga | Europa |
| 6 | Francia | Ligue 1 | Europa |
| 7 | Portugal | Primeira Liga | Europa |
| 8 | Argentina | Liga Profesional | Sudamérica |
| 9 | Cuba | Sistema Nacional de Ligas de Cuba — Fútbol Nova | Norteamérica, Centroamérica y Caribe |
| 10 | Estados Unidos | Major League Soccer / USL Championship / USL League One | Norteamérica, Centroamérica y Caribe |

Los puestos 9 y 10 son plazas de selección del juego base, no los puestos 9 y 10 del ranking IFFHS. La política de divisiones se mantiene en `global_league_tiers.json`; Cuba conserva su sistema nacional de tres divisiones y Estados Unidos agrupa las tres competiciones registradas en el paquete base. La inclusión en el juego base no significa que todas las plantillas o clubes estén ya verificados.

## Catálogo inicial del módulo descargable

| Puesto | País | Liga | Región |
|---:|---|---|---|
| 11 | Turquía | Süper Lig | Europa |
| 12 | Bélgica | Jupiler Pro League | Europa |
| 13 | Arabia Saudita | Saudi Pro League | Asia |
| 14 | Ecuador | LigaPro | Sudamérica |
| 15 | Grecia | Super League | Europa |
| 16 | Egipto | Premier League | África |
| 17 | Chequia | First League | Europa |
| 18 | Japón | J1 League | Asia |
| 19 | Paraguay | Primera División | Sudamérica |
| 20 | Chipre | First Division | Europa |

Este listado es el primer catálogo planificado del módulo. Los paquetes se marcarán como descargables solo cuando tengan datos de temporada verificados, identificadores consistentes, fuentes y derechos de reutilización revisados, y pruebas de importación.

## Experiencia de descarga

La pantalla del módulo mostrará:
- Filtros por región, país, división y temporada.
- Tamaño estimado, versión y estado de cada paquete.
- Acciones para descargar una liga, selección múltiple, una región completa o todas las disponibles.
- Cola de descargas, pausa/reanudación, progreso, reintento y verificación SHA-256.
- Gestión de espacio: consultar almacenamiento ocupado y eliminar paquetes descargados.
- Estado: Disponible, Descargando, Instalado, Actualización disponible, En preparación o Error.

«Descargar todas» significa todas las ligas publicadas y compatibles en ese momento; no incluirá entradas que sigan en preparación.

## Contrato técnico

Archivo maestro: `data/league_content_manifest.json`.
Regiones: `data/league_regions.json`.

Cada paquete usa un identificador estable, temporada, versión, dependencias, tamaño, ruta de contenido, checksum y manifiesto de fuentes. La instalación debe ser atómica: no se registra un paquete como instalado hasta que se haya descargado, verificado y movido a su ubicación final.

El registro de contenido de Godot debe:
1. Leer el manifiesto local.
2. Detectar paquetes instalados y versiones.
3. Exponer solo las ligas instaladas al selector de competiciones.
4. Resolver IDs compartidos sin duplicar clubes, jugadores ni assets.
5. Mantener las partidas guardadas aunque el usuario desinstale un paquete; avisar si una carrera necesita contenido retirado.
6. Permitir jugar offline con los paquetes instalados.

## Estado real y límites

- Inglaterra y España tienen lotes catalogados en el repositorio, pero aún requieren validación de motor y otras verificaciones descritas en el estado global.
- Las otras ocho ligas base y las diez ligas iniciales del módulo son entradas de catálogo, no bases completas.
- Las demás asociaciones FIFA se incorporarán por región y país en fases posteriores.
- No se deben inventar clubes, plantillas, tamaños de descarga ni checksums. Un paquete no se publica como descargable hasta que el contenido exista y pase validaciones.
- Este cambio define la distribución y el contrato de contenido; la interfaz de descarga y el gestor de paquetes de Godot quedan como implementación técnica pendiente.


## Recomendación de descargas al iniciar

Al presentar el gestor de contenido, Fútbol Nova debe recomendar instalar **al menos diez ligas adicionales**, siguiendo estrictamente el ranking (puestos 11–20) y el orden del manifiesto. En el catálogo actual son Turquía, Bélgica, Arabia Saudita, Ecuador, Grecia, Egipto, Chequia, Japón, Paraguay y Chipre. La recomendación no es obligatoria: el usuario puede instalar una selección menor o continuar solo con el juego base.

La interfaz debe distinguir claramente entre paquetes publicados y paquetes en preparación. Actualmente estos diez paquetes están planificados, no publicados, por lo que no se deben mostrar botones de descarga activos hasta completar datos, procedencia, derechos y validación.

También se recomienda descargar **todas las selecciones nacionales disponibles** mediante el módulo independiente `futbol_nova_national_teams`. La recomendación incluye las seis confederaciones y tiene como objetivo habilitar partidos y torneos internacionales, además de carreras con selecciones. El catálogo mundial tiene como objetivo las 211 asociaciones FIFA; no implica que todas sus plantillas estén ya disponibles. Solo se habilitarán paquetes verificados y con derechos/procedencia documentados.

La lógica de esta recomendación está en `scripts/data/download_recommendation_service.gd`, expuesta por `NovaFootballDataService.get_download_recommendations()`. El manifiesto de selecciones nacionales es `data/national_teams_manifest.json`.


## Implementación Godot: primera versión del gestor

Se añadieron:
- `scripts/data/content_package_manager.gd`: cola persistente (autoload `ContentPackages`), descarga HTTPS, comprobación SHA-256, instalación en staging con cambio de nombre, extracción ZIP con protección contra rutas relativas peligrosas, índice local, cancelación, reintento, pausa/reanudación de la cola y desinstalación del paquete.
- `scripts/ui/league_download_catalog.gd`: catálogo en pantalla, filtro por las seis regiones, selección múltiple, descargar todas las ligas publicadas, descargar todas las selecciones nacionales publicadas, progreso, reintento y desinstalación con confirmación.
- `scripts/main.gd`: botón de acceso desde el HUD.
- `project.godot`: autoload persistente `ContentPackages`.

Cada entrada que se quiera publicar debe completar como mínimo `version`, `download_url` HTTPS, `download_size_bytes`, `checksum_sha256`, `content_format` (`zip` o `json`), `content_status=published` y `downloadable=true`. El instalador rechaza entradas sin esos requisitos. Los paquetes JSON pueden indicar `content_filename`.

**Límites de esta fase:** pausar detiene la cola después de la descarga activa, no suspende a mitad de transferencia; cancelar elimina el archivo temporal y el reintento comienza desde cero. El instalador guarda y verifica los archivos offline, pero la importación automática de cada formato de paquete al registro de clubes, jugadores, competiciones y su activación en el selector de carrera sigue pendiente. Las partidas guardadas no se eliminan al desinstalar contenido.

No se ha podido ejecutar Godot en este entorno. Por tanto, los scripts requieren una prueba de importación/ejecución en Godot 4 antes de considerar el gestor listo para producción.

### Validación automatizada del catálogo

Desde la carpeta `proyectos/juegos/futbol-nova`, ejecutar:

```sh
godot --headless --path . --script res://scripts/tests/validate_download_catalog.gd
```

La prueba comprueba el orden 1–10 y 11–20, las seis regiones, las seis confederaciones y que ningún paquete se marque como descargable sin URL HTTPS, tamaño y checksum. La prueba está añadida al repositorio, pero aún no se ha ejecutado porque este entorno no dispone del ejecutable Godot.


## Contrato de los archivos de contenido y activación

Los paquetes de liga deben incluir en la raíz `football_nova_package.json` (o `content.json`) con `schema_version: 1`, `package_type: "league"` y arrays `players`, `teams`, `competitions`. Cada jugador cumple `NovaPlayerProfile`; cada club incluye al menos 11 referencias de jugadores existentes; las competiciones referencian clubes incluidos o previamente registrados. El contrato está en `data/downloaded_package_schema_v1.json`.

Los paquetes de selecciones nacionales deben incluir `national_teams_package.json` (o `content.json`) con `schema_version: 1`, `package_type: "national_teams"`, arrays `players` y `national_teams`. Cada selección incluye `id`, `name`, `association_code`, `confederation` y `player_ids`. Contrato: `data/national_teams_package_schema_v1.json`.

En el arranque, `NovaFootballDataService` importa los paquetes de liga al registro deportivo y crea sus calendarios/tablones de clasificación junto con las competiciones ya existentes. La importación valida perfiles y referencias, evita IDs duplicados y revierte el lote cuando falla. Las selecciones se mantienen en un registro independiente para no confundir selecciones nacionales con clubes; consultar `get_downloaded_national_teams()` y `get_downloaded_national_team_roster(team_id)`.

El manifiesto nacional debe identificar cada paquete publicable con `content_type: "national_teams"`; los paquetes de liga usan `content_type: "league"`. Ambos deben incluir `version`, `download_url`, `download_size_bytes`, `checksum_sha256`, `content_format`, `content_status` y `downloadable`.


## Primer lote de datos regionales: temporada 2026/27

Se incorporó `data/imports/additional_league_club_membership_2026_27.json`, con la afiliación de primera división de los diez países recomendados (puestos 11–20 del ranking): Turquía, Bélgica, Arabia Saudita, Ecuador, Grecia, Egipto, Chequia, Japón, Paraguay y Chipre. El lote contiene 166 registros de clubes con IDs internos estables y URL/fuente por competición.

La cobertura de este lote es **solo la composición de primera división**. No debe interpretarse como diez paquetes jugables completos: no incluye plantillas de jugadores, cuerpos técnicos, árbitros, estadios verificados, ni divisiones inferiores. La afiliación está marcada como catalogada y pendiente de una segunda revisión de fuentes. Chequia se apoya por ahora en una fuente secundaria; se requiere confirmación federativa antes de publicar. Los nombres de clubes se guardan como datos de identificación; no se incluyen escudos, marcas gráficas ni fotografías.

Fuentes consultadas:
- TFF (Turquía), anuncio oficial de listas de clubes y plantillas profesionales 2026/27: https://www.tff.org/default.aspx?2707pg=27&ftxtID=51360&pageID=204
- Pro League (Bélgica), directorio oficial de clubes: https://www.proleague.be/jpl-clubs
- SAFF (Arabia Saudita), clubes de Premier Division 2026/27: https://www.saff.com.sa/en/teams.php?id=1&season=26
- LigaPro (Ecuador), tablas oficiales Serie A 2026: https://ligapro.ec/
- Super League Greece, equipos 2026/27: https://news.bet365.com/en-gb/article/super-league-greece-dates-teams-venues-and-format/2024120509515147373
- MEGA Sport (Egipto), tabla 2026/27 consultada el 13-11-2026: https://www.sport.mega-egy.com/en/tables/
- Czech First League, lista de participantes 2026/27 (fuente secundaria): https://en.wikipedia.org/wiki/Czech_First_League
- J.League (Japón), composición oficial de clubes 2026/27: https://www.jleague.jp/news/article/32852/
- APF (Paraguay), participantes oficiales de Copa de Primera 2026: https://www.apf.org.py/noticias/la-espera-termino-arranca-el-clausura
- Cyprus FA, competición y tabla oficial 2026/27: https://www.cfa.com.cy/En/competitions/68124755

## Directorio mundial de selecciones

Se añadió `data/national_association_directory.json` con 211 nombres de asociaciones miembro según el directorio oficial de FIFA: https://inside.fifa.com/associations. El archivo reserva IDs internos estables para el catálogo y marca por separado la asignación de confederación, la plantilla masculina/femenina y la revisión de derechos. No se generan futbolistas ni plantillas ficticias para rellenar huecos.

**Pendiente para activar selecciones jugables:** asignar confederación y códigos de asociación verificados, importar listas oficiales de convocados por fecha/competición, validar elegibilidad y posiciones, revisar derechos de uso y publicar paquetes con checksum. El directorio de 211 asociaciones es un catálogo de alcance, no un paquete de equipos ya jugables.


## Recomendación inicial y cobertura del catálogo (14-11-2026)

Al iniciar el juego, Fútbol Nova recomienda **las diez ligas siguientes por ranking (puestos 11–20)**, en ese orden, y recomienda instalar **todas las selecciones nacionales publicadas y verificadas**. La recomendación no bloquea el juego base. El usuario puede continuar sin descargas, elegir algunas o instalar todas las que estén disponibles.

La interfaz muestra el rango, país, competición y, cuando existe el lote de afiliación, el número de clubes catalogados. Los contenidos sin paquete completo siguen marcados como «En preparación» y no se pueden descargar. El servicio de recomendación devuelve el número de ligas disponibles y cuántas faltan para alcanzar el mínimo de diez.

### Avance de los diez campeonatos adicionales

Se añadió `data/imports/additional_league_club_membership_2026_27.json` con diez registros de primera división y **166 nombres de clubes**. Es un lote de afiliación preliminar, no son paquetes jugables y no incluye plantillas ni estadísticas de jugadores. Los registros de Turquía, Arabia Saudita, Japón y Chipre tienen referencia primaria oficial registrada; los otros seis requieren completar la segunda comprobación con la federación/organizador antes de elevar su estado.

Fuentes oficiales registradas:
- TFF, listas oficiales de plantillas y clubes profesionales 2026/27: https://www.tff.org/default.aspx?2707pg=20&ftxtID=51360&pageID=204
- Saudi Pro League, clubes de la temporada 2026/27: https://www.spl.com.sa/en
- J.League, directorio oficial J1: https://www.jleague.jp/en/j1/club/
- Cyprus Football Association, convocatoria oficial de la liga 2026/27 (14 clubes): https://www.cfa.com.cy/Gr/news/53532

### Selecciones nacionales

Se añadió un directorio de **211 asociaciones miembro FIFA**, comprobado contra la página oficial de FIFA: https://inside.fifa.com/associations. Es solo un directorio de nombres. Los códigos de asociación, asignación a confederaciones y plantillas senior masculina/femenina todavía requieren normalización y verificación. No se han creado jugadores ni plantillas ficticias para rellenar los huecos.

El módulo nacional recomienda todas las selecciones que lleguen a publicarse y verificarse. Actualmente hay **0 paquetes nacionales publicados**, por lo que el botón de descarga informa que aún no hay selecciones disponibles; no simula descargas.

### Condiciones antes de publicar

Para activar cualquier liga o selección como descarga se exige: listas de participantes y plantillas verificadas para la temporada, IDs estables, fuentes y derechos documentados, archivo de paquete válido, tamaño y SHA-256, publicación HTTPS y validación automatizada en Godot. El recuento de clubes por sí solo no hace que una liga sea jugable.


## Límite de creación de ligas (regla permanente)

La base de datos activa de Fútbol Nova puede contener **como máximo 100 ligas**. El manifiesto `data/league_content_manifest.json` define el límite (`database_limits.max_created_leagues=100`). Los países y ligas que queden fuera no se eliminan: permanecen como registros de catálogo/reserva con sus IDs, fuentes y estado de verificación. No se crean sus competiciones, divisiones, clubes ni plantillas mientras estén reservados. La importación de paquetes de ligas comprueba el límite antes de añadir sus competiciones; los paquetes que excedan el cupo se omiten sin borrar sus archivos instalados ni sus partidas guardadas. La prioridad de selección sigue el ranking de `global_league_tiers.json`.


## Separación por confederaciones — 16-11-2026

El catálogo se divide además por confederación FIFA, sin eliminar la navegación geográfica por región. Cada módulo mantiene su propia lista de asociaciones y ligas, con identificadores y estados de contenido independientes:

- AFC: `data/continental_leagues/afc.json`
- CAF: `data/continental_leagues/caf.json`
- CONCACAF: `data/continental_leagues/concacaf.json`
- CONMEBOL: `data/continental_leagues/conmebol.json`
- OFC: `data/continental_leagues/ofc.json`
- UEFA: `data/continental_leagues/uefa.json`

El índice es `data/continental_leagues/manifest.json`; el servicio de carga y validación es `scripts/data/continental_league_module_service.gd`, registrado como autoload `ContinentalLeagues`. La prueba estructural se ejecuta con `godot --headless --path . --script res://tests/test_continental_league_modules.gd`.

El primer corte contiene 100 ligas únicas tomadas del catálogo global de selección y del manifiesto de contenido actual. Son entradas de catálogo/investigación, no 100 competiciones jugables. La división queda: AFC 15, CAF 9, CONCACAF 12, CONMEBOL 10, OFC 0 y UEFA 54. OFC se mantiene como módulo válido vacío hasta importar datos domésticos verificados.

**Incidencia de fuente:** el directorio nacional actual declara 211 asociaciones, pero no incluye Estados Unidos. Como Estados Unidos ya forma parte del catálogo de ligas base, se añadió explícitamente al módulo CONCACAF con estado `directory_reconciliation_required`; no se presenta como una asociación verificada por ese directorio. Debe reconciliarse el registro fuente antes de afirmar cobertura FIFA completa.

La carga de estos catálogos no activa automáticamente ligas ni modifica las carreras. Una liga solo podrá entrar al motor jugable cuando sus clubes, plantillas, calendarios, reglas, fuentes/derechos y pruebas estén completos.


## Política de alojamiento NOVA (18-11-2026)
Las descargas instalables solo pueden alojarse en el repositorio GitHub autorizado Cumba35/Nova-Workspace, mediante raw.githubusercontent.com o GitHub Releases del mismo repositorio. No se permiten URLs de otros hosts ni redirecciones HTTP. Las fuentes web externas citadas en investigación no son endpoints de descarga del juego.
