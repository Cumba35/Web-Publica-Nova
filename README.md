# Web Pública Nova

Portal público de distribución del ecosistema NOVA.

- **Repositorio:** https://github.com/Cumba35/Web-Publica-Nova
- **Rama:** `main`
- **URL pública:** https://cumba35.github.io/Web-Publica-Nova/
- **Sitios:** portada + diez micrositios.
- **Repositorios fuente:** permanecen privados.

## Sitios publicados

1. [Nova Apps](https://cumba35.github.io/Web-Publica-Nova/nova-apps/)
2. [Nova E-commerce](https://cumba35.github.io/Web-Publica-Nova/nova-ecommerce/)
3. [Nova Bank](https://cumba35.github.io/Web-Publica-Nova/nova-bank/)
4. [Nova Novels](https://cumba35.github.io/Web-Publica-Nova/nova-novels/)
5. [Nova Nexus](https://cumba35.github.io/Web-Publica-Nova/nova-nexus/)
6. [Noticias Nova](https://cumba35.github.io/Web-Publica-Nova/noticias-nova/)
7. [Nova Chat](https://cumba35.github.io/Web-Publica-Nova/nova-chat/)
8. [Multimedia Nova](https://cumba35.github.io/Web-Publica-Nova/multimedia-nova/)
9. [NOVA IA](https://cumba35.github.io/Web-Publica-Nova/nova-ia/)
10. [Fútbol Nova](https://cumba35.github.io/Web-Publica-Nova/futbol-nova/)

Nova Workspace queda excluido del portal público.

## Estructura y diseño

- `index.html`: portada con nueve tarjetas y monogramas SVG propios.
- `assets/css/site.css`: estilos compartidos, responsive, acentos cromáticos por proyecto, foco de teclado y soporte para movimiento reducido.
- `assets/icons/`: favicon SVG independiente para cada proyecto.
- `assets/nova-mark.svg`: favicon general del portal.
- Cada micrositio conserva su propia ficha, enlaces de acceso y aviso de estado funcional.

## Donaciones

Todas las páginas públicas incluyen un acceso común a la sección de donaciones. La sección informa que las aportaciones serán voluntarias, sin beneficios para el donante, y que se podrá elegir anonimato ante NOVA o reconocimiento público opcional mediante nombre/seudónimo. **No hay checkout activo ni se solicitan datos de pago** hasta confirmar un proveedor legalmente compatible con la residencia del propietario en Cuba. El validador exige que las diez páginas mantengan el enlace global.

## Validación y despliegue

El workflow `.github/workflows/pages.yml`:
1. Ejecuta `python3 scripts/validate_site.py` para revisar las diez páginas, enlaces y recursos locales, anclas, metadatos básicos y controles de accesibilidad.
2. Busca patrones de secretos en los archivos públicos.
3. Publica el artefacto en GitHub Pages.
4. Comprueba por HTTPS la portada y las nueve rutas, exigiendo una respuesta correcta y un documento con `<title>`.

**Última versión comprobada:** commit `7bfbdf929bd388fbf3dc1502bfa1b85d1c7bb676`. El workflow [Deploy Web Publica Nova — run 43323743895](https://github.com/Cumba35/Web-Publica-Nova/actions/runs/43323743895) terminó con build, deploy y verificación HTTPS de las diez rutas correctos.

## Estado funcional y límites

Estas páginas son superficies públicas informativas y enlaces de acceso; no sustituyen los frontends autenticados ni crean servicios de backend por sí solas.

- Nova Apps enlaza al catálogo y a los apartados públicos de proyectos y recursos de usuarios.
- Nova E-commerce enlaza a la PWA existente. No se habilitan cobros ni pagos reales.
- Nova Bank enlaza a su frontend autenticado; no es un banco físico ni expone saldos u operaciones.
- Nova Novels mantiene WordPress como biblioteca pública activa. No se republican obras ni portadas hasta revisar derechos y atribución.
- Nova Nexus presenta el proyecto sin publicar paneles ni documentación interna.
- Noticias Nova no muestra titulares ficticios ni activa un feed hasta disponer de un flujo editorial verificado.
- Nova Chat permanece en desarrollo; no se presenta como mensajería operativa.
- Multimedia Nova publica un panel autenticado en `multimedia-nova/`; la API permanece en Railway y las conexiones Dropbox/Google requieren autorización individual. Las pruebas reales de carga/descarga siguen pendientes.
- NOVA IA es informativa; el backend administrativo no está aprobado para exposición pública hasta completar autenticación multiusuario y controles de seguridad.

No publicar repositorios fuente completos, archivos `.env`, claves, tokens, datos de usuarios, bases de datos, paneles administrativos ni documentación interna.

## Acceso público y estado de aplicaciones — 2026-11-12

- Las diez fichas públicas se publican desde este repositorio mediante GitHub Pages: portada, Nova Apps, Nova E-commerce, Nova Bank, Nova Novels, Nova Nexus, Multimedia Nova, NOVA IA, Nova Chat y Noticias Nova.
- Las fichas públicas son accesibles sin iniciar sesión y describen el alcance y el estado real de cada proyecto. No equivalen a que todas las aplicaciones interactivas estén desplegadas.
- Se retiraron botones que apuntaban a rutas de GitHub Pages de `Nova-APPS`, porque ese repositorio es privado y GitHub Pages no está actualmente habilitado allí. No se exponen repositorios privados ni paneles financieros/administrativos.
- Nova Apps, E-commerce, Bank y el panel web de Multimedia conservan avisos explícitos hasta que exista un despliegue público seguro y verificado. Nova Bank seguirá requiriendo acceso autenticado y permisos.
- Se añadió `sitemap.xml` y `robots.txt`; el validador comprueba que el sitemap contenga las diez rutas y rechaza enlaces hacia el despliegue no publicado de Nova Apps.
- Antes de publicar funciones interactivas, deben probarse autenticación, RLS, permisos por rol, configuración de dominios, formularios, API y flujos reales sin datos de producción.


## Multimedia Nova — panel público autenticado (2026-11-18)

- La ruta pública `multimedia-nova/` ahora contiene el panel de archivos integrado desde la versión funcional de `Cumba35/Nova-APPS`.
- Reutiliza el proyecto Supabase existente mediante su clave publishable (no es una clave secreta) y exige una sesión NOVA para consultar proveedores, archivos y realizar operaciones.
- El inicio de sesión con Google se redirige al sitio principal de Nova Apps para conservar el flujo OAuth ya establecido; después de iniciar sesión, se puede regresar al panel público.
- La interfaz incluye conexión/desconexión de Dropbox y Google Drive, selección de archivos, carga, descarga, listado y sincronización, según las rutas disponibles en la API.
- La API aplica autenticación y aislamiento por usuario; no se publican tokens OAuth ni credenciales privadas en este repositorio.
- Estado: código guardado y verificado en GitHub. El despliegue queda sujeto a las validaciones de GitHub Actions; todavía no se declara probada una sesión real ni una transferencia real de archivos.


### Despliegue del panel Multimedia Nova — 2026-11-18

- Commit de publicación: `5db5e4e8f8aee22f18d536cacfcdcd57b67338e9`.
- GitHub Actions: [Deploy Web Publica Nova — run 44355817460](https://github.com/Cumba35/Web-Publica-Nova/actions/runs/44355817460) terminó correctamente.
- Validaciones estructurales, espejo público de Fútbol Nova y escaneo de secretos: correctos.
- Verificación HTTPS automatizada de las diez rutas públicas: correcta.
- El panel Multimedia Nova ya está incluido en el artefacto publicado. Pendiente: prueba interactiva con una cuenta NOVA real, autorización OAuth de Dropbox y transferencia real de un archivo.


### Corrección del destino de inicio de sesión de Multimedia Nova — 2026-11-18

- Se corrigió el parámetro `redirectTo` del acceso Google: ahora vuelve a la ruta pública `https://cumba35.github.io/Web-Publica-Nova/multimedia-nova/`, no a `https://cumba35.github.io/Nova-APPS/` (repositorio privado que no debe usarse como URL pública).
- El cambio quedó en el archivo `multimedia-nova/index.html` mediante el commit `db403a2b8092e744a6c9bdd2410ae0c2576ba09a`.
- Pendiente validar que la URL exacta esté permitida en Supabase Auth Redirect URLs y completar una prueba real de Google OAuth desde Android. No se declara completada la autenticación hasta esa prueba.


## Menú global y cuenta — 2026-11-18

- Todas las páginas HTML deben cargar exactamente una vez `assets/js/site-navigation.js`, que incorpora el controlador compartido de cuenta y menú.
- El único control global para abrir el panel es el icono circular de usuario; la navegación antigua del encabezado permanece oculta para evitar controles duplicados.
- El panel agrupa Cuenta de usuario, Ajustes de esta página, apariencia clara/oscura, Otras páginas NOVA y Donaciones.
- El botón expone `aria-controls` y `aria-expanded`; Escape cierra el panel y devuelve el foco al botón.
- El validador comprueba el cargador compartido y rechaza botones de menú antiguos. El despliegue verifica también la ruta pública de Fútbol Nova.
- Límite de verificación: los workflows comprueban estructura, enlaces, despliegue HTTPS y secretos; no sustituyen una prueba interactiva con una cuenta real de Google/Supabase ni verifican cambios de perfil en producción.


### Endurecimiento del menú global — 2026-11-18 (continuación)

- El cambio de apariencia tolera que el navegador bloquee `localStorage`: el tema sigue aplicándose durante la página aunque no pueda persistirse.
- Los rótulos del control de apariencia indican la acción disponible (cambiar a claro/oscuro) y su estado se expone mediante `aria-pressed`.
- El modo claro incluye estilos específicos para Multimedia Nova y Fútbol Nova, además de los estilos generales del portal.
- La validación estática comprueba que el controlador compartido contiene inicio de sesión Google, edición de perfil, cierre de sesión, persistencia de tema, accesibilidad y cierre con Escape.
- Las pruebas de GitHub Actions no pueden sustituir una autorización OAuth real ni confirmar cambios de perfil en una cuenta del propietario; esa comprobación requiere una sesión interactiva autorizada.


## Investigación de código abierto y evolución social — 2026-11-18

- Se añadió el inventario de repositorios públicos revisados, estado de licencias, compatibilidad técnica, propuesta de red social estilo Facebook, recomendador transparente, arquitectura, privacidad y etapas de implementación: [docs/OPEN_SOURCE_RESEARCH_AND_SOCIAL_ROADMAP.md](docs/OPEN_SOURCE_RESEARCH_AND_SOCIAL_ROADMAP.md).
- La documentación distingue referencias de código que podrían reutilizarse de proyectos cuya licencia todavía no se ha confirmado. No se copió código de terceros ni se habilitaron funciones sociales sin backend y controles de acceso.
- Los datos personales, publicaciones, mensajes y actividad de usuarios deben permanecer en el backend protegido, nunca en este repositorio público.


## NOVA Social — primera versión funcional

- Se añadió `/nova-social/` con publicaciones de texto y enlaces HTTPS, etiquetas, privacidad de publicación, feed «Para ti», «Siguiendo» y cronológico.
- Incluye perfiles públicos/privados, seguir/dejar de seguir, solicitudes de seguimiento, reacciones, comentarios, guardados, compartir enlaces, bloqueo/desbloqueo, reportes y notificaciones internas.
- El recomendador inicial es heurístico y explicable: temas elegidos, cuentas seguidas, actualidad y diversidad de autores. No usa mensajes privados ni datos de otras aplicaciones.
- La base de datos usa tablas separadas y RLS; solo usuarios autenticados pueden consultar las tablas sociales. Los reportes se pueden enviar, pero la cola de moderación administrativa aún requiere su interfaz protegida.
- Migraciones de producción: `20261118210209_nova_social_foundation`, `20261118210210_nova_social_fk_indexes`, `20261118210224_nova_social_profile_block_visibility`, `20261118210441_nova_social_visibility_and_reports`, `20261118210812_nova_social_follow_block_guard`, `20261118210938_nova_social_notifications`, `20261118211007_nova_social_notification_function_permissions` y `20261118211008_nova_social_comment_policy_fix`.
- Pruebas de RLS ejecutadas en NOVA-STAGING con cuentas ficticias dentro de una transacción revertida; no se guardaron datos de prueba.
- La primera versión no habilita imágenes/vídeos, notificaciones push, mensajes privados, federación ActivityPub ni integraciones externas automáticas. Los bloqueos se pueden revisar y deshacer desde «Cuentas bloqueadas».
- Documentación técnica: [Social implementation](docs/SOCIAL_FEATURES_IMPLEMENTATION.md) y [Open-source research](docs/OPEN_SOURCE_RESEARCH_AND_SOCIAL_ROADMAP.md).
