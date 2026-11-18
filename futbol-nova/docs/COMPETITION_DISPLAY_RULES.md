# Fútbol Nova — Convención global de iconos de competiciones

**Ámbito:** todas las ligas y copas del juego, en los diez países del paquete base.  
**Estado:** norma de presentación y catálogo inicial de denominaciones. No cambia reglamentos, formatos ni calendarios.

## 1. Regla obligatoria

Toda competición oficial verificada para la temporada cargada debe mostrar **✅ como primer carácter del nombre visible**. Ejemplos: **✅ Premier League**, **✅ Copa del Rey**, **✅ Campeonato Brasileiro Série A**.

El icono significa exclusivamente «competición oficial verificada». No significa que el partido esté confirmado, que el equipo esté clasificado ni que la competición esté disponible sin descargar.

- El prefijo se aplica en todos los lugares donde se muestre el nombre: selector, calendario, tabla, ficha, resultados, estadísticas, notificaciones y guardados.
- Se almacena el estado de verificación como dato estructurado; no se deduce por tener el icono.
- La verificación corresponde a una edición/temporada concreta. Antes de iniciar una nueva temporada se revisan nombre, organizador, bases, participantes y calendario.
- Una competición histórica, anunciada pero aún no reglamentada, o basada solo en una fuente secundaria no recibe el icono hasta completar la verificación.
- Las competiciones originales de Fútbol Nova, las personalizadas y las pendientes no llevan ✅. Deben indicar «Fútbol Nova», «Personalizada» o «Pendiente de verificación».
- El icono no sustituye la auditoría de marcas, escudos, uniformes, nombres comerciales o derechos de terceros.

## 2. Catálogo de competiciones oficiales con prefijo

Los nombres siguientes son los nombres visibles propuestos para la interfaz. El símbolo debe anteponerse exactamente como se muestra.

### España
- **Ligas:** ✅ Primera División; ✅ Segunda División; ✅ Primera Federación.
- **Copas:** ✅ Copa del Rey; ✅ Supercopa de España.

### Francia
- **Ligas:** ✅ Ligue 1; ✅ Ligue 2; ✅ Ligue 3 (desde la temporada 2026/27).
- **Copas:** ✅ Coupe de France; ✅ Trophée des Champions.

### Italia
- **Ligas:** ✅ Serie A; ✅ Serie B; ✅ Serie C.
- **Copas:** ✅ Coppa Italia; ✅ Coppa Italia Serie C; ✅ Supercoppa Italiana.

### Alemania
- **Ligas:** ✅ Bundesliga; ✅ 2. Bundesliga; ✅ 3. Liga.
- **Copas:** ✅ DFB-Pokal; ✅ DFL-Supercup.

### Portugal
- **Ligas:** ✅ Liga Portugal Betclic; ✅ Liga Portugal 2; ✅ Liga 3.
- **Copas:** ✅ Taça de Portugal; ✅ Supertaça Cândido de Oliveira.

### Inglaterra
- **Ligas:** ✅ Premier League; ✅ EFL Championship; ✅ EFL League One.
- **Copas:** ✅ FA Cup; ✅ FA Community Shield.

### Brasil
- **Ligas:** ✅ Campeonato Brasileiro Série A; ✅ Campeonato Brasileiro Série B; ✅ Campeonato Brasileiro Série C.
- **Copas:** ✅ Copa do Brasil; ✅ Supercopa do Brasil / Supercopa Rei (usar el nombre oficial de la edición correspondiente).

### Estados Unidos
- **Ligas:** ✅ Major League Soccer (MLS); ✅ USL Championship; ✅ USL League One.
- **Copas:** ✅ U.S. Open Cup.
- **Supercopa:** no se ha identificado una supercopa doméstica nacional equivalente. Campeones Cup es una competición internacional entre clubes de MLS y Liga MX, no debe etiquetarse como supercopa nacional de Estados Unidos. La Supercopa Nova de EE. UU., si se incluye, será ficticia y no llevará ✅.
- **Nota de estructura:** MLS y USL no forman una pirámide general de ascenso/descenso automático. El prefijo identifica el carácter oficial de cada competición, no una relación de promoción entre ellas.

### Argentina
- **Ligas:** ✅ Liga Profesional; ✅ Primera Nacional; ✅ Primera B Metropolitana; ✅ Torneo Federal A.
- **Copas y títulos oficiales:** ✅ Copa Argentina; ✅ Supercopa Argentina; ✅ Supercopa Internacional; ✅ Trofeo de Campeones; ✅ Recopa de Campeones.
- Primera B Metropolitana y Torneo Federal A son ramas paralelas del tercer nivel; no deben fusionarse en una sola tabla.

### Cuba
- **Liga:** ✅ Primera División de Cuba (o denominación federativa exacta de la edición vigente).
- **Segunda y tercera divisiones:** Segunda División de Cuba — Fútbol Nova; Tercera División de Cuba — Fútbol Nova. Son ficticias y no llevan ✅.
- **Copas:** Copa Nacional de Cuba — Fútbol Nova y Supercopa de Cuba — Fútbol Nova permanecen como propuestas originales no oficiales mientras no se encuentre y verifique un reglamento federativo vigente. No llevan ✅.

## 3. Estados de datos recomendados

Usar uno de estos valores en cada competición y temporada:

- `official_verified`: competición oficial y edición verificada; mostrar prefijo ✅.
- `official_pending_season`: competición oficial conocida, pero edición actual pendiente de reglamento/calendario; no mostrar ✅ hasta verificar la temporada.
- `fictional_nova`: competición original del juego; nunca mostrar ✅.
- `custom_user`: competición personalizada por el usuario; nunca mostrar ✅.
- `historical_only`: competición histórica sin vigencia confirmada; nunca mostrar ✅.

Campos mínimos:
`competition_id`, `country_code`, `display_name`, `organizer`, `season_id`, `status`, `official_badge`, `regulation_url`, `calendar_url`, `verified_at`.

Validación:
- `official_badge` solo puede ser `true` cuando `status == "official_verified"`.
- `display_name` empieza por «✅ » si y solo si `official_badge == true`.
- No permitir que una competición `fictional_nova`, `custom_user` o `historical_only` tenga `official_badge == true`.
- Si expira la revisión de temporada o se detecta una discrepancia oficial, cambiar a `official_pending_season` y retirar el prefijo hasta verificar.

## 4. Fuentes institucionales y control anual

Los reglamentos y calendarios se obtienen de las federaciones, ligas y organizadores oficiales correspondientes. Las fuentes específicas de cada país y competición se mantienen en `SPORTS_DATA_MODEL.md`, especialmente en las secciones de supercopas y niveles nacionales. Para Cuba, la afiliación institucional se puede contrastar en CFU: https://www.cfufootball.org/inside-cfu/member-associations/cuba/ ; el listado de competiciones cubanas de 2026 consultado muestra la Primera División, sin acreditar una segunda o tercera categoría nacional activa: https://www.national-football-teams.com/old/leagues/48/2026_2/Cuba.html .

**Límite:** este catálogo establece la convención y las competiciones base previstas; no certifica por sí solo los reglamentos de todas las ediciones futuras. Cada temporada debe superar la verificación documental antes de recibir el estado `official_verified`.
