# Fútbol Nova — APK de prueba para Android

## Objetivo

Crear una APK de depuración ARM64 para instalar y probar Fútbol Nova en Android, sin que el usuario tenga que instalar Godot ni programar desde el teléfono.

## Configuración verificada en GitHub

- Repositorio: `Cumba35/Nova-Workspace`.
- Rama: `main`.
- Proyecto: `proyectos/juegos/futbol-nova`.
- Workflow: `.github/workflows/futbol-nova-android-apk.yml`.
- Godot: 4.4.1, con plantillas de exportación Android.
- Android: ARM64, paquete `com.nova.futbolnova`.
- Artefacto de prueba: `futbol-nova-android-debug`.
- El workflow se inicia con cambios del proyecto en `main` o manualmente.

## Criterios de aceptación previos a exportar

1. La escena principal crea el campo, HUD, menú y controlador 11v11.
2. Las cuatro pantallas principales (Inicio, Online, Modos y Configuración) abren y muestran contenido.
3. El catálogo local aporta al menos dos clubes distintos con once titulares seleccionables.
4. La preparación crea dos alineaciones 4-3-3 válidas con once identificadores únicos por club.
5. El motor inicia el amistoso y crea 22 futbolistas: el jugador controlado y 21 futbolistas de IA.
6. El HUD identifica los equipos y muestra el reloj del primer tiempo.

Estos criterios se ejecutan en:
- `tests/test_game_hub.gd`
- `tests/test_match_11v11_foundation.gd`
- `tests/test_friendly_match_runtime.gd`

## Orden del workflow

1. Importar recursos.
2. Ejecutar las pruebas de aceptación del juego base.
3. Ejecutar una prueba de arranque de la escena.
4. Exportar la APK ARM64 y subir el artefacto.
5. Ejecutar la regresión extendida de ligas, temporadas, carreras, módulos y bases de datos.

La APK queda disponible como artefacto cuando se superan los criterios básicos y la exportación, aunque una prueba extendida posterior falle. El resultado global del workflow seguirá reflejando los fallos de regresión.

## Descargar e instalar desde Android

1. Abre [Fútbol Nova — pruebas y APK Android](https://github.com/Cumba35/Nova-Workspace/actions/workflows/futbol-nova-android-apk.yml).
2. Abre la ejecución más reciente de `main`.
3. Si no hay una ejecución nueva, pulsa **Run workflow** y selecciona `main`.
4. Espera a que aparezca el artefacto `futbol-nova-android-debug`.
5. Descarga y extrae el ZIP; instala `FutbolNova-debug.apk`.

## Bloqueo conocido de GitHub Actions

Las últimas ejecuciones fueron rechazadas antes de asignar un runner: `runner_id=0`, sin pasos ejecutados y sin logs de trabajo descargables. Esto ocurre antes de importar o compilar el proyecto, por lo que no demuestra un error de Godot ni puede corregirse modificando archivos del juego. Debe estar habilitada la facturación/límite de uso de GitHub Actions en la cuenta para que GitHub asigne el runner.

Hasta que una ejecución consiga runner, no se puede afirmar que la APK fue compilada ni que las pruebas pasaron.

## Límites funcionales de esta versión de prueba

- El modo amistoso 11v11 es el único modo de partido incluido en esta fase.
- Online muestra el estado del módulo, pero no ofrece partidas reales sin backend.
- Modos y catálogo permiten navegar y consultar contenido; los módulos no instalados no se presentan como jugables.
- Algunas categorías de Configuración siguen siendo informativas y no tienen controles persistentes.
- La tanda de penaltis, árbitro completo, porteros con IA avanzada, animaciones finales y reglas completas siguen fuera del alcance de esta APK de prueba.
- Se necesita una prueba física en Android para confirmar tacto, orientación, rendimiento y escalado visual.
