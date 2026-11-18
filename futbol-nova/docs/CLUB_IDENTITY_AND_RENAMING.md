# Fútbol Nova — Política mundial de identidades ficticias de clubes

**Estado:** política aprobada para aplicar a todos los clubes que se incorporen al juego.  
**Alcance real de los datos actuales:** el catálogo deportivo inspeccionado contiene competiciones cubanas; no contiene todavía un inventario mundial completo. Por tanto, esta política no afirma que todos los clubes del mundo hayan sido investigados o renombrados.

## Objetivo

Conservar la sensación de identidad de cada club real de referencia —su ciudad, región, cultura futbolística y contexto— mediante clubes ficticios con nombres y recursos propios. La referencia real se conserva únicamente como dato interno de desarrollo, nunca como marca visible ni como afirmación de afiliación.

## Principio de creación

No basta con sustituir una palabra del nombre original, traducirlo o cambiar el sufijo. Tampoco se debe convertir automáticamente un apodo famoso en nombre de reemplazo: los apodos, lemas y símbolos deportivos también pueden estar protegidos o funcionar como identificadores comerciales.

La nueva denominación debe construirse desde una fuente independiente: geografía local, paisaje, fauna de uso común, patrimonio, industria, arquitectura o una idea evocativa original. Se conserva el vínculo cultural con la localidad, no la marca del club.

## Qué se conserva y qué se rehace

| Puede inspirar la identidad | Se crea de nuevo |
|---|---|
| Ciudad, región y gentilicio | Nombre distintivo del club |
| Historia local y geografía pública | Escudo, monograma y mascota |
| Contexto cultural general | Apodos y lemas propios |
| Tradición futbolística como contexto | Camisetas y patrones propios |
| Colores locales no exclusivos | Composición cromática no confundible |
| Categoría y fuerza deportiva aproximada | Estadio ficticio y marca comercial |

## Revisión de derechos

Para cada club se investigarán el nombre, variantes, apodos, lemas, escudo, mascota, colores/combinaciones, equipaciones y estadio. La búsqueda debe cubrir la oficina de marcas del país y, cuando corresponda, registros regionales e internacionales, además de las fuentes oficiales del club.

La WIPO explica que las marcas deportivas pueden incluir emblemas, nombres, lemas y otros signos; su Global Brand Database permite consultar millones de registros. La protección concreta depende de los registros, territorios, clases y derechos aplicables. La normativa de equipamiento de UEFA también trata el nombre, emblema, mascota, símbolo y apodo como identificaciones oficiales sujetas a requisitos de registro/autorización.

Una búsqueda sin coincidencias evidentes no garantiza que un nombre esté libre ni sustituye una revisión jurídica. Si aparece conflicto o similitud confundible, se genera otra identidad.

## Flujo obligatorio para cada club

1. Incorporar el club real de referencia al inventario interno, con país, ciudad, fuentes y fecha.
2. Investigar su identidad pública y detectar marcas, apodos y símbolos distintivos.
3. Extraer únicamente rasgos culturales/geográficos generales que puedan inspirar una creación independiente.
4. Generar varias denominaciones originales y descartar las que sean traducciones, variantes cercanas o evocaciones confundibles.
5. Revisar nombres actuales e históricos, abreviaturas, apodos y registros de marcas en territorios relevantes.
6. Crear desde cero escudo, mascota, paleta, equipaciones y estadio.
7. Registrar el estado de revisión y bloquear la publicación si queda un conflicto pendiente.
8. Mantener los metadatos de inspiración fuera de la interfaz del juego.

## Cobertura y honestidad del catálogo

El archivo de ligas que se inspeccionó actualmente corresponde a Cuba. Sus clubes ya usan nombres ficticios y diseños conceptuales originales. No se debe presentar esa cobertura como si incluyera todos los países.

La expansión mundial se hará por país, confederación y división, usando fuentes verificables y manteniendo un inventario de cobertura. No se inventarán clubes ni se afirmará que se han revisado todos los clubes existentes sin completar esa recopilación.

## Referencias de investigación

- WIPO, Sport and Branding: https://www.wipo.int/en/web/sports/branding
- WIPO, The International Trademark System and Sports Brands: https://www.wipo.int/en/web/sports/international-trademark-system-and-brands
- WIPO, Global Trademark Database: https://www.wipo.int/en/web/trademarks
- UEFA Equipment Regulations, Article 13: https://documents.uefa.com/r/kAuxpRxKhaqJDwAnTtB4CQ/YWuMgfinZk8_gwaH47Sjng
- UEFA Club Licensing and Financial Sustainability Regulations 2026, Article 61: https://documents.uefa.com/r/UEFA-Club-Licensing-and-Financial-Sustainability-Regulations-2026/Article-61-Licence-applicant-s-identity-history-and-legacy-Online?contentId=H6KEXv2JzXdGS4WhsOGIWw

**Nota:** documento de diseño y control editorial, no asesoramiento jurídico.


## Auditoría de identidades — 17 de noviembre de 2026

- `data/base_league_clubs_2026.json` contiene 451 clubes de seis países (BRA, ITA, GER, FRA, POR y ARG). Sus nombres provisionales fueron reemplazados por 451 denominaciones ficticias originales y únicas; se conservaron IDs y referencias de origen. Los registros mantienen `membership_catalogued_fictional_roster_pending` y `player_ids=[]`; no deben tratarse como clubes jugables ni como identidades completas aprobadas.
- `data/global_clubs.generated.json` contiene 68 clubes ingleses. Sus nombres de presentación fueron revisados y sustituidos por denominaciones ficticias originales. Los 68 siguen en `draft_review_required` porque la revisión de marca y los recursos visuales siguen pendientes; no son identidades completas aprobadas.
- Las plantillas inglesas inspeccionadas contienen perfiles ficticios sintéticos con `source_reference_id: null`; no representan futbolistas profesionales reales y no se pueden vincular a goleadores históricos por coincidencia de nombre o club.
- Se reforzó el importador para que un club global con revisión explícita no pase a `playable` hasta cumplir simultáneamente: `review_status=approved`, `trademark_review_status=reviewed_no_obvious_conflict` o `licensed`, y `visual_assets_original=true`. Los registros heredados sin gate explícito conservan su comportamiento anterior.
- Se añadieron pruebas de regresión para identidades en borrador, aprobadas y registros heredados. No se afirma que se hayan ejecutado en Godot.

### Trabajo todavía bloqueado

Se asignaron nombres ficticios originales a los 451 clubes y se revisaron los nombres de presentación de los 68 ingleses; el registro completo está en `data/club_identity_name_review_2026-11-17.json`. Esto no equivale a una búsqueda legal de marcas ni a aprobación de escudos/equipaciones. La auditoría de membresías y la vinculación de futbolistas históricos a IDs ficticios siguen pendientes. La política exige completar esas revisiones antes de publicar o hacer jugable el contenido.

## Actualización de nombres — 17 de noviembre de 2026

- Los 451 nombres provisionales de seis países fueron sustituidos por nombres ficticios originales únicos. Se conservan los IDs estables, `source_reference_id`, divisiones, temporadas y membresías. Los jugadores siguen sin asignarse.
- Los 68 nombres de presentación ingleses también fueron sustituidos y revisados. Se conservan sus 22 perfiles ficticios por club.
- Registro: `data/club_identity_name_review_2026-11-17.json`; validación automatizada: `tools/validate_club_identity_names.py`.
- Alcance: revisión de nombres de presentación solamente. No hay autorización legal de marca ni aprobación visual completa. Los 68 siguen `draft_review_required`; los 451 siguen pendientes de auditoría de membresía y roster. No se habilita jugabilidad por renombrar.

