# Fútbol Nova — edición desde Godot en Android

**Proyecto:** Fútbol Nova  
**Motor fijado por el flujo de pruebas:** Godot 4.4.1  
**Plataforma objetivo:** Android ARM64  
**Proyecto Godot:** esta carpeta; abrir el archivo `project.godot` desde el editor.

## Preparación del repositorio

- El proyecto canónico ya es un proyecto Godot 4: contiene `project.godot`, la escena principal `scenes/main.tscn`, scripts GDScript, escenas, datos JSON, recursos y preset Android.
- El preset `Android` usa el identificador `com.nova.futbolnova`, arquitectura ARM64 y exporta una APK de depuración.
- El workflow `.github/workflows/futbol-nova-android-apk.yml` genera ahora dos artefactos: `futbol-nova-godot-source` (ZIP del proyecto editable) y `futbol-nova-android-debug` (APK, si las pruebas y exportación terminan correctamente).
- El ZIP de código excluye la caché local `.godot/`, archivos Git y compilaciones previas. Godot regenerará su caché al importar el proyecto.
- Los artefactos de Actions se conservan durante 14 días. El workflow es manual (`workflow_dispatch`).

## Obtener el proyecto editable desde el teléfono

1. Abre el workflow [Fútbol Nova — pruebas y APK Android](https://github.com/Cumba35/Nova-Workspace/actions/workflows/futbol-nova-android-apk.yml).
2. Pulsa **Run workflow**, selecciona `work/complete-futbol-nova-base` para descargar la versión de trabajo actual y confirma.
3. Espera a que GitHub inicie el trabajo. Cuando termine el paso **Upload Godot source project**, el artefacto de código estará disponible incluso si una etapa posterior de Android falla.
4. En la ejecución, descarga el artefacto `futbol-nova-godot-source`. GitHub entrega un ZIP de artefacto que contiene `FutbolNova-Godot-Source.zip`.
5. Extrae ambos ZIP hasta obtener una carpeta que contenga directamente `project.godot`.
6. Instala/abre Godot Editor para Android desde [la página oficial de Godot](https://godotengine.org/download/android/).
7. En el editor, usa **Importar** o **Abrir proyecto existente**, navega hasta la carpeta extraída y selecciona `project.godot`.
8. Espera a que termine la importación inicial de recursos. Después abre el proyecto y ejecuta la escena principal.

## Versión del motor

El workflow de pruebas y exportación utiliza Godot 4.4.1 y sus plantillas coincidentes. Para reproducir exactamente las comprobaciones, utiliza Godot 4.4.1. Si el editor Android instalado es una versión posterior, conserva primero el ZIP original sin modificar y trabaja sobre una copia: una versión nueva puede actualizar metadatos del proyecto y esos cambios podrían no ser compatibles con el flujo fijado en 4.4.1.

## Edición y sincronización

- La carpeta extraída es una copia de trabajo local; editarla no actualiza GitHub automáticamente.
- Antes de cada cambio importante, conserva una copia de seguridad.
- Después de editar, revisa los cambios y súbelos a las rutas correspondientes de `Cumba35/Nova-Workspace`, rama `main`.
- No subas la carpeta `.godot/`, APKs temporales ni cachés.
- No reemplaces archivos canónicos con prototipos web/PWA. Fútbol Nova continúa siendo el proyecto 3D Godot.
- Mantén la navegación común: **Atrás** abajo a la izquierda y **Siguiente** abajo a la derecha en las pantallas aplicables.

## Límites actuales

- La disponibilidad de la descarga depende de que GitHub Actions permita iniciar un runner. Se ha registrado previamente un bloqueo de facturación/límite de gasto de Actions; si continúa, GitHub no generará ningún artefacto hasta resolverlo.
- La preparación del ZIP no certifica que el proyecto compile ni que las pruebas pasen.
- No se ha confirmado todavía una ejecución satisfactoria de Godot 4.4.1 ni una prueba en un teléfono Android real.
- El juego sigue en desarrollo; el prototipo 11 contra 11 no equivale a un partido comercial completo.

