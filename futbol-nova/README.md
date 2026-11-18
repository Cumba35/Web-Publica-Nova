# Fútbol Nova — paquete público de datos base

Esta carpeta contiene una copia seleccionada de los datos deportivos necesarios para preparar la distribución de las diez ligas base de Fútbol Nova.

## Alcance

- Inglaterra
- España
- Brasil
- Italia
- Alemania
- Francia
- Portugal
- Argentina
- Cuba
- Estados Unidos

El paquete incluye catálogos de clubes y competiciones, manifiesto de contenido y plantillas ficticias de jugadores. Los archivos de plantillas identifican perfiles ficticios de Fútbol Nova; no deben presentarse como plantillas reales de clubes profesionales.

## Qué no contiene

Esta copia no incluye el código fuente del juego, scripts de compilación, credenciales, claves, secretos, partidas guardadas, datos privados de usuarios ni imágenes personales. El proyecto maestro permanece en el repositorio privado `Cumba35/Nova-Workspace`.

## Estructura

- `data/base_league_clubs_2026.json`: membresía de clubes de las ligas base.
- `data/*_leagues*.json`: catálogos de competiciones.
- `data/*_clubs*.json`: catálogos específicos de clubes.
- `data/players/`: perfiles ficticios por país/competición.
- `data/league_content_manifest.json`: manifiesto de distribución del contenido base.

## Integridad y mantenimiento

Los archivos se copiaron desde `proyectos/juegos/futbol-nova/data/` del repositorio privado. Esta carpeta es una copia de distribución de datos, no sustituye al repositorio maestro ni demuestra que el juego o sus diez ligas ya hayan superado las pruebas de ejecución.

Antes de redistribuir o comercializar el juego, revisar las fuentes, licencias y derechos de los datos de membresía de clubes y competiciones. Los nombres y referencias de fuentes conservados en los JSON permiten rastrear parte de esa procedencia.

No añadir aquí claves, contraseñas, tokens, archivos de configuración privada ni información personal.


## Auditoría de espejo público — 2026-11-18

- Fuente canónica: `Cumba35/Nova-Workspace`, rama `main`, commit `250af727fb2dccfae1571c29d08290416426f0ef`.
- Se compararon los hashes Git de los **23 archivos** publicados en `data/`; todos coinciden exactamente con `proyectos/juegos/futbol-nova/data/`.
- No hay archivos públicos de este paquete ausentes ni desactualizados respecto a la fuente.
- El inventario verificable está en [SOURCE-MIRROR.json](SOURCE-MIRROR.json).
- Se mantiene el alcance seleccionado: datos de las diez ligas base. No se copia el código Godot, scripts, pruebas, documentación interna, perfiles/imágenes personales ni secretos. El proyecto maestro continúa privado.
