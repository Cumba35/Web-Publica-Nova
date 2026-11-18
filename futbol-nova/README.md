# Fútbol Nova — copia pública del proyecto

Esta carpeta contiene una copia del proyecto de videojuego **Fútbol Nova**, desarrollado con Godot 4.4.1. Incluye el proyecto importable, escenas, scripts GDScript, datos deportivos, módulos, documentación, herramientas y pruebas automatizadas.

## Abrir el proyecto

1. Descarga el repositorio público o abre esta carpeta desde GitHub.
2. Instala Godot **4.4.1 Standard**.
3. Importa la carpeta `futbol-nova/` seleccionando el archivo `project.godot`.
4. Ejecuta la escena principal `scenes/main.tscn`.

La guía completa está en [GAME_README.md](GAME_README.md) y [docs/GODOT_PROJECT_QUICK_START.md](docs/GODOT_PROJECT_QUICK_START.md).

## Pruebas

- Integridad de los archivos, hashes Git, JSON y CSV: `python3 tools/validate_public_copy.py`.
- Pruebas del motor Godot: workflow [Fútbol Nova — pruebas de copia pública](https://github.com/Cumba35/Web-Publica-Nova/actions/workflows/futbol-nova-public-copy.yml).
- La página pública del proyecto está en [Fútbol Nova](index.html).

## Alcance y exclusiones

Se copiaron todos los archivos de texto del proyecto maestro: código, escenas, datos, módulos, documentación, herramientas y pruebas. Se excluyen seis JPG de referencia visual interna/de terceros, porque no son recursos necesarios para iniciar el juego y no están aprobados para redistribución. La lista exacta está en [SOURCE-MIRROR.json](SOURCE-MIRROR.json).

Esta copia no convierte en jugables las funciones que siguen en desarrollo. El README original documenta el estado real del proyecto: el partido completo 11 contra 11 y varias integraciones todavía requieren implementación y validación.

## Fuente canónica

El desarrollo principal continúa en el repositorio privado [Cumba35/Nova-Workspace](https://github.com/Cumba35/Nova-Workspace), ruta `proyectos/juegos/futbol-nova/`. La copia pública es una instantánea y debe actualizarse desde esa fuente, nunca al revés.
