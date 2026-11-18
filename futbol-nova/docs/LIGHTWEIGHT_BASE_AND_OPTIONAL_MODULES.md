# Fútbol Nova — juego base ligero y módulos opcionales

## Decisión aprobada
Fútbol Nova se distribuirá como **juego base ligero + módulos descargables independientes**. La ficha del juego aparecerá en Nova Apps y su ventana tendrá una sección **Agregados** con los módulos compatibles.

El manifiesto técnico es `data/game_modules_manifest.json`. Es la fuente de verdad para IDs, categorías, estados, dependencias y reglas de publicación.

## Qué permanece en el juego base
- Inicio, navegación, configuración, guardado y recuperación.
- Gestor de módulos y comprobación de integridad.
- Controles táctiles básicos y ajustes esenciales.
- Motor y recursos mínimos para iniciar y jugar la experiencia principal.
- Datos mínimos de competiciones que se decidan como parte de la experiencia inicial.
- Interfaz de módulos, errores y avisos de contenido faltante.

El juego base nunca debe exigir una descarga opcional para arrancar, abrir una partida guardada o completar una experiencia principal básica.

## Qué se separa
Los candidatos iniciales son narración/comentarios, música y ambiente, estadios adicionales, gráficos avanzados, ligas del mundo, selecciones nacionales, copas/torneos adicionales y perfiles ampliados de mandos. Las ligas y selecciones reutilizan los manifiestos ya existentes; no se duplican sus catálogos.

Los módulos se mantienen independientes y solo se muestran como instalables cuando el paquete real exista y supere las validaciones. Los elementos planificados se pueden mostrar como «En preparación», nunca con un botón de descarga activo.

## Formato y ciclo de vida
1. Usar JSON/ZIP de datos para los agregados actuales, con adaptadores pequeños incluidos en el juego base. Considerar PCK solo en una fase futura, después de validar firma, compatibilidad, carga de recursos y seguridad en Android.
2. Usar ZIP de datos para paquetes de datos cuando sea más adecuado; no ejecutar código descargado sin un proceso explícito de revisión y confianza.
3. Descargar por HTTPS a una carpeta temporal.
4. Verificar SHA-256, versión del juego, plataforma y dependencias.
5. Instalar de forma atómica y registrar el módulo como instalado solo después de superar las comprobaciones.
6. Activar/desactivar sin borrar datos de usuario.
7. Actualizar solo el módulo afectado. Al desinstalar, conservar guardados y advertir si una carrera necesita ese contenido.

Los tamaños se calcularán a partir de paquetes generados; no se inventan estimaciones.

## Experiencia Nova Apps
- La ficha oficial de Fútbol Nova se registra en `catalogo/recursos.json` con visibilidad de catálogo de desarrollo mientras siga sin superar compilación, pruebas y revisión de derechos.
- Dentro de la ficha, **Agregados** lista los módulos asociados.
- Cada agregado muestra nombre, función, versión, tamaño real, compatibilidad, dependencias y estado.
- Los módulos publicados ofrecen instalar/actualizar/desinstalar; los planificados muestran «En preparación».
- Publicar la ficha del juego no equivale a declarar que el juego está terminado ni habilita descargas que no existen.

## Optimización obligatoria
- Medir APK base, memoria en reposo, memoria durante partido, tiempo de arranque y almacenamiento de cada módulo.
- Comprimir texturas/audio; usar formatos y resoluciones adecuados al dispositivo.
- Evitar duplicar recursos entre base y módulos.
- Cargar bajo demanda y liberar recursos al salir de una función.
- Mantener un perfil móvil de bajo consumo como predeterminado.
- Los gráficos avanzados nunca deben ser requisito para jugar.
- Conservar una ruta offline para el juego base y los módulos instalados.

## Estado real y límites
Esta entrega configura la arquitectura y el catálogo, no afirma que los módulos ya sean paquetes instalables. El gestor existente `ContentPackages` ya descarga/verifica paquetes de contenido y los manifiestos de ligas/selecciones existen; la carga dinámica genérica de módulos PCK, la interfaz «Agregados» en Nova Apps y las pruebas Android todavía deben implementarse y validarse.

## Criterios de aceptación
- El juego base arranca y permite jugar sin Internet y sin instalar agregados.
- Desinstalar un módulo no daña guardados ni archivos base.
- Cada módulo se instala, verifica, actualiza y desinstala independientemente.
- Una actualización de módulo no fuerza una descarga completa del juego.
- Nova Apps relaciona el juego con sus agregados mediante IDs estables.
- Solo módulos con paquete, hash, compatibilidad y pruebas verificados se publican como descargables.
- CI registra tamaño del APK base y de cada agregado cuando se generen builds.


## Nuevo agregado: Mejoras gráficas
Se incorporó el módulo opcional **Mejoras gráficas** (`graphics_enhancements`). El adaptador base `scripts/graphics/graphics_enhancements_module.gd` permanece pequeño y solo aplica ajustes si el paquete de datos está instalado. En caso contrario, el juego usa su iluminación original y no bloquea el arranque.

El perfil móvil equilibrado ajusta el tonemapping, la exposición, la luz ambiental y las sombras direccionales dentro de límites seguros. Los perfiles de mayor calidad, efectos costosos y texturas HD no se fuerzan en móviles ni se incluyen en el juego base. El gestor acepta el nuevo tipo de paquete `graphics_module` y conserva HTTPS, tamaño exacto y SHA-256 obligatorios.

El módulo está registrado como «En desarrollo», no descargable: falta generar el paquete, medir su tamaño, ejecutar Godot/CI y comprobar calidad visual, consumo de memoria, FPS, temperatura y compatibilidad en Android. El catálogo no debe mostrarlo como instalación disponible hasta completar esas pruebas.


## Pantalla de agregados dentro del juego
La pantalla `scripts/ui/optional_modules_catalog.gd` lee `data/optional_modules_catalog.json`, lista módulos, muestra estados y ofrece descargar solo paquetes marcados como publicados o desinstalar módulos instalados. El HUD abre esta pantalla desde «Agregados / Módulos». Las descargas siguen usando el gestor `ContentPackages`, con comprobación de HTTPS, tamaño y SHA-256. Los módulos en desarrollo o pruebas no muestran botón de descarga.


## Dependencias entre módulos continentales

El TAS es un agregado compuesto y no se puede instalar por separado de las competiciones que lo clasifican. Sus dependencias obligatorias son:

1. `caribbean_champions_league` — Liga de Campeones del Caribe.
2. `south_america_champions_league` — Liga de Campeones de Sudamérica.
3. `north_central_america_champions_league` — Liga de Campeones de Norteamérica y Centroamérica.

Al solicitar TAS desde «Agregados», el gestor resuelve el grafo de dependencias, valida que todos los paquetes estén publicados y completos, y los añade a la cola en orden: las tres ligas primero y TAS al final. La cola descarga de forma secuencial, no simultánea, pero el usuario realiza una sola solicitud. Si una liga no está publicada o no supera la validación, el lote no se encola. Si una descarga regional falla durante la ejecución, el gestor impide que el TAS comience a instalarse.

Una vez instalado el TAS, el gestor registra sus dependencias y no permite desinstalar ninguna de las tres ligas mientras el TAS permanezca instalado. Las ligas regionales sí pueden instalarse y utilizarse de forma independiente si no se instala TAS.

La lógica ya está implementada en `optional_modules_catalog.gd` y `content_package_manager.gd`. Los paquetes reales siguen en desarrollo: hasta que cada ZIP tenga URL HTTPS, tamaño y SHA-256 verificados, la interfaz mantiene deshabilitada la descarga.

## Contratos de los ocho módulos iniciales — 17 noviembre 2026

Se completó la estructura contractual de los ocho módulos iniciales del manifiesto `data/game_modules_manifest.json`: Narración y comentarios, Música y ambiente, Estadios adicionales, Gráficos avanzados, Ligas del Mundo, Selecciones nacionales, Copas y torneos adicionales y Compatibilidad ampliada con mandos.

Cada ficha incluye los campos exigidos por `module_contract.required_fields`, conserva su ID, categoría, función, estado y dependencias, y declara expresamente los metadatos aún no disponibles. No se inventan versiones de paquete, versiones mínimas del juego, plataformas admitidas, formatos, URL, tamaños ni hashes. Las plataformas se dejan vacías hasta definir y probar la matriz real.

Los ocho contratos permanecen con `downloadable: false` y `publication_blockers` explica qué falta en cada uno. Ligas del Mundo y Selecciones nacionales apuntan a sus manifiestos existentes; no duplican sus catálogos ni convierten los directorios de datos en paquetes instalables. Los módulos de audio, estadios, gráficos avanzados, torneos adicionales y mandos requieren todavía definición/producción de contenido y pruebas específicas.

Se amplió `scripts/tests/validate_optional_modules.gd` para comprobar presencia de los campos contractuales, coherencia entre `status` y `content_status`, bloqueos de publicación y ausencia de URL, tamaño o SHA-256 inventados. La prueba estructural quedó guardada, pero no se declara ejecutada: Godot 4.4.1/CI todavía debe proporcionar una ejecución verificable.

**Importante:** completar el esquema contractual no significa que los módulos estén terminados ni habilita descargas. Solo se publicarán cuando exista el artefacto real y se superen todas las verificaciones de derechos, integridad, compatibilidad, instalación y desinstalación.

## Metadatos existentes del módulo de mandos — 17 noviembre 2026

El contrato `futbol-nova-controller-support` ya incorpora los metadatos comprobables del recurso `modules/controller_support/controller_profiles.json`: versión 1.0.0, versión mínima del juego 0.1.0, formato JSON, plataformas declaradas (Android, Windows, Linux y macOS), URL HTTPS, tamaño registrado de 1.623 bytes y SHA-256 tomado del catálogo fuente. El catálogo de agregados y `controller_modules_catalog.json` quedan sincronizados.

El módulo pasa a estado `testing`, pero conserva `downloadable: false`. La publicación sigue bloqueada hasta volver a comprobar la integridad del archivo, ejecutar la validación Godot y completar pruebas físicas con mandos Bluetooth y USB en Android. La existencia de un archivo de configuración no equivale a una validación de dispositivos ni autoriza la descarga pública.

