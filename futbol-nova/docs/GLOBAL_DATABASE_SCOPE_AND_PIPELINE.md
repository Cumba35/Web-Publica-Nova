# Fútbol Nova — alcance de la base de datos mundial

**Corte de trabajo:** 14-11-2026  
**Estado general:** en construcción. No declarar completa hasta que todos los lotes superen validación de fuentes, relaciones, duplicados e importación Godot.

## Qué significa «base de datos completa»

El objetivo de producto es un universo de fútbol masculino profesional y semiprofesional jugable, organizado por asociación nacional, país/territorio, temporada, competición, división, grupo, club y plantilla. Se mantendrán además competiciones de copa, supercopas y torneos continentales cuando sus participantes y formatos estén verificados.

La referencia de cobertura institucional será el panorama de las 211 asociaciones miembro de FIFA. Esto no significa que FIFA proporcione plantillas individuales: su Professional Football Landscape publica datos agregados y no ofrece datos individuales de jugadores. Cada liga y plantilla requiere fuentes propias.

## Alcance de cobertura

1. Las 211 asociaciones miembro FIFA: registro de países/territorios y confederación.
2. Primera división nacional de cada asociación con competición activa.
3. Divisiones inferiores nacionales jugables, hasta el límite de niveles acordado para cada país.
4. Copas nacionales y supercopas.
5. Competiciones continentales: AFC, CAF, Concacaf, CONMEBOL, OFC y UEFA.
6. Clubes, estadios, ciudades, temporadas, grupos, reglas de puntuación, ascensos y descensos.
7. Plantillas de jugadores: datos personales deportivos, posición, pie, altura, edad, nacionalidad, atributos, potencial y relación club-temporada.
8. Árbitros y entrenadores cuando exista fuente fiable y licencia adecuada.
9. Historial de temporadas, resultados y tablas como fase posterior, con trazabilidad por partido.

## Regla de datos reales y ficticios

- Nunca presentar un jugador ficticio como profesional real.
- Nunca asignar jugadores a clubes por nacionalidad o por una lista de jugadores sin relación club-jugador explícita.
- Los registros reales incluyen fuente, fecha de consulta, temporada, nivel de confianza y estado de verificación.
- Los datos sin fuente válida quedan en cola de investigación, no se publican como verificados.
- Cuando falten jugadores para alcanzar la plantilla jugable, generar perfiles ficticios en un espacio separado y con `fictional: true`.
- Los escudos, equipaciones, nombres comerciales y marcas se revisan por separado. Se crearán diseños originales para el juego; no se copiarán logos ni equipaciones oficiales.
- Respetar licencias, términos de uso, derechos de bases de datos y privacidad. Una fuente visible públicamente no implica permiso de redistribución.

## Modelo de datos canónico

Entidades principales:
- `associations`: código, nombre, confederación, estado FIFA.
- `countries`: país/territorio, asociación, códigos ISO/FIFA.
- `seasons`: calendario, fechas y familia de temporada (año natural o dos años).
- `competitions`: país, tipo, nivel, formato, reglas y temporada.
- `competition_groups`: grupos y fases.
- `clubs`: ID estable, nombre de juego, nombre de referencia, ciudad y estado.
- `club_memberships`: club-competicón-temporada-grupo.
- `players`: ID estable, identidad, atributos deportivos y procedencia.
- `player_registrations`: jugador-club-temporada, dorsal, fechas y estado.
- `venues`: estadio, ciudad, capacidad y fuente.
- `competition_rules`: puntuación, desempates, ascensos, descensos y playoffs.
- `assets`: escudos/equipaciones originales, licencia, autoría y validación.
- `sources`: URL, editor, fecha de consulta, términos/licencia, campos respaldados y confianza.

## IDs y versiones

IDs estables y deterministas, no basados en nombres traducidos. Cambios de nombre no cambian el ID. Las relaciones de jugador con club se guardan por temporada para conservar traspasos e historial. No reutilizar IDs retirados.

## Pipeline de cada país

1. Confirmar temporada y estructura de competición en fuentes oficiales.
2. Confirmar todos los clubes, grupos y reglas.
3. Normalizar membresías con IDs estables y procedencia.
4. Recopilar plantillas con afiliación club-jugador explícita y derechos compatibles.
5. Completar solo huecos con perfiles ficticios claramente etiquetados.
6. Generar identidades visuales originales.
7. Ejecutar validadores de IDs, duplicados, conteos, grupos, plantillas, atributos, referencias y fuentes.
8. Integrar en Godot y ejecutar pruebas headless.
9. Marcar el lote como completo solo tras pasar todas las pruebas.

## Fuentes y límites conocidos

- FIFA Professional Football Landscape: referencia de panorama global institucional; datos agregados, no fichas individuales de futbolistas.
- Asociaciones nacionales, ligas y federaciones: fuentes primarias para temporadas, clubes, grupos y plantillas.
- Fuentes abiertas como OpenFootball pueden servir para descubrimiento e historial, pero no garantizan afiliación vigente ni cobertura total.
- Proveedores comerciales pueden ayudar a descubrir cobertura, pero no se copiarán sus datos sin licencia de reutilización.
- Los recuentos globales de terceros cambian y no son un estándar oficial; se usan solo como indicadores de escala, nunca como prueba de integridad.

## Estado de lotes al 14-11-2026

| País | Temporada | Clubes | Jugadores | Estado |
|---|---|---:|---:|---|
| Inglaterra | 2026/27 | 68 | 1.496 ficticios | Base provisional; membresías y plantillas reales requieren auditoría; motor pendiente |
| España | 2026/27 | 82 | 0 | Membresías catalogadas; identidades ficticias de juego y plantillas pendientes; motor pendiente |
| Otros países | Por confirmar | 0 | 0 | Pendientes |

**Importante:** Inglaterra y España no representan la base mundial terminada. Los 1.496 perfiles ingleses son ficticios. El lote español aún no tiene jugadores.

## Orden de ejecución

- Fase A: normalizar y validar Inglaterra y España; corregir discrepancias con listas oficiales y el modelo canónico.
- Fase B: completar los otros 18 países del primer grupo mundial ya configurado en `data/global_league_tiers.json`.
- Fase C: primera división de las restantes asociaciones FIFA con temporada activa.
- Fase D: divisiones inferiores, copas nacionales y torneos continentales.
- Fase E: historial, resultados, estadios, árbitros, entrenadores y mantenimiento estacional.

El trabajo se entrega por lotes versionados en GitHub. La palabra «completa» solo se utilizará cuando el registro de cobertura no tenga países/competiciones pendientes dentro del alcance aprobado y todos los lotes hayan pasado las pruebas automatizadas.

## Actualización de catálogo maestro y persistencia — 14 noviembre 2026

Se incorporó la primera base de datos runtime offline en Godot. Véase `DATABASE_IMPLEMENTATION.md`.

- Directorio institucional: 211 asociaciones FIFA catalogadas y asignadas a las seis confederaciones con fuentes oficiales; AFC 46, CAF 54, Concacaf 35, CONMEBOL 10, OFC 11 y UEFA 55.
- Clubes registrados en el catálogo maestro: 368 en las semillas actuales (52 Cuba, 68 Inglaterra, 82 España y 166 de diez ligas adicionales).
- Competiciones: 19 en los lotes actuales (3 Cuba, 3 Inglaterra, 3 España y 10 primeras divisiones adicionales).
- Futbolistas del registro jugable: 2.640 (1.144 Cuba y 1.496 ficticios Inglaterra).
- Clubes con plantillas cargadas en el registro jugable: 120 (Cuba e Inglaterra).
- España y las diez ligas adicionales permanecen en el catálogo maestro de referencia, sin plantillas completas. Sus clubes no deben aparecer como jugables hasta completar plantillas, fuentes, derechos y pruebas.
- El almacenamiento runtime persiste snapshots, resultados, calendarios, tablas, temporadas y copias de carreras con respaldo y migración de esquema.

Estos recuentos describen los datos semilla actuales, no una cobertura mundial completa. La ejecución del importador y la integridad en Godot 4.4.1 siguen pendientes de confirmación CI. Los paquetes de selecciones nacionales continúan sin publicarse hasta contar con convocatorias verificadas y derechos adecuados.
