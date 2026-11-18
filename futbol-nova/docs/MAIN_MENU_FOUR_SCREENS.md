# Fútbol Nova — Menú principal de cuatro pantallas

**Estado:** arquitectura de juego base y módulos descargables definida. La pantalla 1 (Inicio) y la pantalla 4 (Configuración) pertenecen al juego base. Las pantallas 2 (Online) y 3 (Modos) son escaparates de módulos descargables; no habilitan funciones que no estén instaladas. Validación Godot/Android pendiente. No existe ni se mostrará Ultimate Team.

## Regla de distribución obligatoria

La instalación base debe funcionar por sí sola y limitarse a:
- Partidos amistosos locales.
- Ayuda del juego.
- Ajustes generales del juego.
- Gestión y descarga de módulos desde Configuración.

Todo lo demás se distribuye como módulos independientes instalables y desinstalables. No se debe mostrar un modo como jugable ni abrir su flujo interno si su módulo no está instalado y validado. El catálogo solo permite descargar paquetes publicados, verificados y compatibles; los módulos en desarrollo o sin paquete aparecen como no disponibles.

## Pantalla 1 — Inicio (juego base)

- **Partido amistoso:** entrada al partido local amistoso 11 contra 11 y sus opciones previas disponibles.
- **Ayuda:** controles de Android/PC, reglas básicas, configuración de amistosos y explicación de los módulos.
- No incluir accesos funcionales a Modo Leyenda, Modo Entrenador, Ligas, Copas, TAS, torneos de selecciones, entrenamiento independiente, Momentos o juego Online. Esos contenidos se instalan por separado.

## Pantalla 2 — Online (módulo descargable)

- Es una página informativa del módulo Multijugador Online.
- Muestra que salas, emparejamiento, sincronización y partidas entre dispositivos requieren el módulo Online.
- El botón conduce al catálogo de módulos.
- No debe abrir selección de jugadores, salas ni conexión en la instalación base.
- No fingir que existe un backend conectado.

## Pantalla 3 — Modos (módulos descargables)

Lista informativa con acceso al catálogo, sin ejecutar los modos desde el juego base:
- Multijugador Online.
- Modo Leyenda.
- Modo Entrenador.
- Ligas y Copas.
- Torneos de Selecciones.
- Torneo Americano de Supercampeones (TAS) y sus clasificatorias.
- Centro de Entrenamiento.

Cada tarjeta indica que es un módulo independiente y muestra el icono ⬇. El icono también aparece junto al nombre de cada módulo en el catálogo. El botón abre el catálogo; no inicia el modo. Los módulos no publicados permanecen en preparación o desarrollo.

## Pantalla 4 — Configuración (juego base)

La pantalla de Configuración pertenece al juego base. Incluye las categorías:
- Edición.
- Módulos.
- Música.
- Juego.
- Datos.
- Controles.
- Audio.
- Gráficos.
- Accesibilidad.
- Administración.
- Información.

Los ajustes generales que afectan al partido amistoso deben poder usarse sin instalar módulos. La sección Módulos abre el catálogo y permite gestionar únicamente paquetes compatibles. Los controles ampliados o mejoras opcionales pueden seguir siendo módulos, pero no deben impedir el uso de controles básicos del juego base.

## Navegación

- Las cuatro pantallas principales permanecen visibles en la barra de navegación: Inicio, ⬇ Online, ⬇ Modos y Configuración. Los iconos de Online y Modos señalan que sus contenidos requieren módulos. En móviles los botones reducen su ancho para mantener los cuatro accesos a la vista; en pantallas amplias conservan su tamaño normal.
- Todo contenido que requiera un módulo descargable muestra el icono ⬇ junto al nombre o a la acción del catálogo. El icono identifica el tipo de contenido; no significa que el paquete ya esté publicado ni que pueda descargarse. La acción de descarga solo se habilita si el paquete está publicado, validado y es compatible.
- Acceso directo entre las cuatro pantallas principales.
- Barra inferior persistente: Atrás a la izquierda y Siguiente a la derecha, con indicador de pantalla en el centro.
- En subpantallas, Atrás vuelve a la pantalla principal de su sección; Siguiente avanza a la siguiente sección principal.
- Gesto horizontal en la zona libre del menú y cruceta izquierda/derecha del mando; navegación circular.
- No cambiar de pantalla por gestos iniciados sobre controles internos.
- Indicador de pantalla actual (1 de 4), abreviado en ventanas estrechas para Android.
- Ayuda se abre como subpantalla de Inicio; Atrás regresa a Inicio.

## Distribución de módulos

El registro central está en `data/optional_modules_catalog.json`. Cada módulo debe declarar identificador estable, versión, plataformas, dependencias, estado de publicación, formato, compatibilidad y paquete verificable. No activar contenido por detectar solamente código fuente dentro del repositorio. Antes de publicar un módulo se requiere:
1. Separar sus scripts, escenas, datos y recursos del paquete base.
2. Construir el paquete descargable y registrar su manifiesto.
3. Validar dependencias, versión, integridad y licencia de recursos.
4. Probar instalación, activación, actualización y desinstalación.
5. Comprobar que el juego base sigue iniciando y jugando amistosos cuando el módulo no está instalado.

## Alcance

Fútbol masculino exclusivamente. No crear ni importar futbolistas, clubes, plantillas, selecciones o competiciones femeninas. No existe modo Femenino. No incluir Ultimate Team.

## Estado y limitaciones

El menú ya presenta Inicio con amistoso y ayuda; Online y Modos muestran contenidos descargables; Configuración conserva su catálogo de categorías y acceso a módulos. Se registraron módulos para Online, Leyenda, Entrenador, Ligas y Copas, Entrenamiento, Momentos y TAS. Sus paquetes todavía están en desarrollo/no publicados. El código y los datos de varios modos aún permanecen en el árbol fuente del proyecto: la separación física de esos recursos en paquetes descargables es una tarea pendiente y no debe darse por completada. La configuración también requiere completar y validar las opciones individuales de cada categoría.

## Criterios de aceptación pendientes de validar

1. Ejecutar pruebas con Godot 4.
2. Confirmar que Inicio solo permite amistosos y Ayuda.
3. Confirmar que Online y Modos solo abren el catálogo de módulos y no ejecutan modos.
4. Confirmar que Configuración y los ajustes del amistoso funcionan sin módulos.
5. Probar la instalación y retirada de cada módulo sin romper el juego base.
6. Verificar navegación táctil, mando, teclado, foco y escalado en Android y PC.
7. Construir y probar una APK base sin módulos adicionales.
