# Fútbol Nova — abrir y ejecutar en Godot

## Proyecto

- **Motor recomendado:** Godot 4.4.1 Standard (no .NET).
- **Carpeta del proyecto:** `proyectos/juegos/futbol-nova/`.
- **Archivo que debes abrir:** `project.godot`.
- **Escena principal:** `scenes/main.tscn`.
- **Renderizador:** GL Compatibility, configurado para escritorio y móvil.
- **Exportación Android:** preset `Android`, ARM64, paquete `com.nova.futbolnova`.

## Abrir desde un ordenador

1. Descarga el repositorio de Nova Workspace o clónalo desde GitHub.
2. Entra en `proyectos/juegos/futbol-nova/`.
3. Abre Godot 4.4.1 Standard.
4. Selecciona **Importar** o **Abrir proyecto existente**.
5. Selecciona el archivo `project.godot` de esa carpeta.
6. Espera a que Godot termine la importación inicial.
7. Abre el proyecto y pulsa **F6** para la escena actual o **F5** para ejecutar el proyecto desde su escena principal.

No selecciones la carpeta raíz de Nova Workspace: el proyecto Godot está dentro de `proyectos/juegos/futbol-nova/`.

## Abrir desde Android

1. Descarga el ZIP del repositorio y extráelo en el almacenamiento del teléfono.
2. Conserva la estructura de carpetas. Localiza `proyectos/juegos/futbol-nova/project.godot`.
3. Instala una versión de Godot Editor para Android compatible con Godot 4.4.1.
4. En Godot, importa/abre el proyecto seleccionando ese `project.godot`.
5. Espera a que se importen los recursos antes de ejecutar o editar.

Si el editor Android disponible es de una versión posterior, conserva una copia intacta del proyecto antes de permitir que el editor actualice archivos o metadatos.

## Obtener el ZIP limpio del proyecto

El workflow **Fútbol Nova - pruebas y APK Android** prepara el artefacto `futbol-nova-godot-source`. Cuando GitHub Actions esté habilitado:

1. Abre la pestaña Actions del repositorio.
2. Selecciona el workflow **Fútbol Nova - pruebas y APK Android**.
3. Pulsa **Run workflow** y elige la rama `work/complete-futbol-nova-base` para obtener esta versión de trabajo.
4. Descarga el artefacto `futbol-nova-godot-source`.
5. Extrae el ZIP de artefacto y luego `FutbolNova-Godot-Source.zip`.
6. Abre el `project.godot` de la carpeta extraída.

El paquete excluye `.godot/` y `build/`; Godot crea su caché local durante la primera importación. El artefacto de Actions se conserva durante 14 días.

## Ejecutar en escritorio

- Abre el proyecto y ejecuta con **F5**.
- La escena de arranque está declarada en `run/main_scene`.
- Para pruebas automatizadas desde terminal, usa Godot 4.4.1:

```bash
godot --headless --editor --path . --import --quit
godot --headless --path . --quit-after 5
```

Para ejecutar una prueba individual:

```bash
godot --headless --path . --script res://tests/test_game_hub.gd
```

## Exportar Android

1. Instala las plantillas de exportación correspondientes exactamente a tu versión de Godot.
2. Configura Android SDK/JDK siguiendo la documentación oficial de Godot.
3. Abre **Proyecto > Exportar** y selecciona el preset **Android**.
4. Configura las rutas de SDK y las credenciales de firma de depuración en el editor.
5. Exporta primero una APK de depuración para pruebas.

El preset está preparado para ARM64, pero la exportación requiere las plantillas y el SDK instalados. No se incluye ninguna clave privada de firma en el repositorio.

## Archivos que no debes subir a Git

- `.godot/`: caché generada por el editor.
- `build/`, APK y AAB: resultados de compilación.
- Archivos temporales y copias locales.

Estas exclusiones están configuradas en el `.gitignore` de esta carpeta.

## Estado y límites

La carpeta está estructurada como proyecto Godot y tiene una escena principal y un preset Android. Esto no certifica que todos los scripts y escenas estén libres de errores. La importación, las pruebas automatizadas, el arranque real y la exportación deben confirmarse ejecutando Godot 4.4.1.

El juego continúa en desarrollo. Los módulos de Online y otros modos no se convierten en funciones jugables por el hecho de abrir el proyecto en el editor.
