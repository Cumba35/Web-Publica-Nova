# Investigación de código abierto y evolución social de NOVA

Fecha de revisión: 2026-11-18
Repositorio de destino: https://github.com/Cumba35/Web-Publica-Nova
Rama: main

## Objetivo

Investigar proyectos públicos de GitHub que puedan mejorar la experiencia visual, accesibilidad, rendimiento y funciones sociales de las páginas NOVA. Reutilizar código solo después de comprobar licencia, mantenimiento, seguridad, dependencias y compatibilidad. Esta investigación es una hoja de ruta, no afirma que las funciones sociales estén ya desplegadas.

## Diagnóstico del portal actual

- El portal consta de una portada y micrositios HTML/CSS/JavaScript independientes con navegación global compartida.
- `assets/js/site-navigation.js` y `assets/js/account.js` aportan navegación, menú, sesión y edición básica de perfil mediante Supabase.
- `assets/js/supabase-client.js` inicializa un cliente Supabase con clave publishable. La clave publishable no debe confundirse con una clave secreta; las políticas RLS y los permisos del backend siguen siendo obligatorios.
- Nova Chat y Noticias Nova se presentan actualmente como fichas informativas; sus páginas indican que los servicios interactivos todavía no están habilitados.
- El portal está publicado como sitio estático en GitHub Pages. GitHub Pages no puede ejecutar por sí solo un backend, mantener sesiones de servidor ni guardar publicaciones privadas.
- La estructura existente permite añadir módulos JavaScript/CSS progresivamente sin reemplazar todo el portal por Next.js.

## Repositorios públicos revisados

### 1. ItsRealAJ/OpenSocial
- URL: https://github.com/ItsRealAJ/OpenSocial
- Uso potencial: inspiración y posible reutilización selectiva del algoritmo de recomendación y su interfaz explicativa.
- Elementos descritos por el proyecto: pipeline de candidatos, puntuación configurable, mezcla de publicaciones seguidas y descubiertas, diversidad de autores, frescura, controles de preferencias y explicación de por qué aparece cada publicación.
- Licencia: MIT; se leyó el archivo LICENSE de la rama principal el 2026-11-18.
- Compatibilidad: el proyecto está construido alrededor de Next.js y Supabase, mientras el portal NOVA actual es HTML/CSS/JavaScript estático. No conviene importar la aplicación completa. Adaptar únicamente lógica independiente tras revisar sus archivos y dependencias.
- Precaución: la demostración sin backend usa datos en memoria y no representa persistencia, autenticación ni aislamiento multiusuario de producción.

### 2. freed-project/freed
- URL: https://github.com/freed-project/freed
- Uso potencial: ideas de feed unificado, preferencias controladas por el usuario, almacenamiento local, sincronización selectiva y ranking configurable.
- Licencia: MIT; se leyó el archivo LICENSE de la rama principal el 2026-11-18.
- Compatibilidad: arquitectura grande basada en Rust, SQLite, PWA y aplicaciones nativas. No integrar el monorepo completo en el portal. Evaluar patrones de diseño y controles de privacidad como referencia.

### 3. AlohaSocial/social
- URL: https://github.com/AlohaSocial/social
- Uso potencial: referencia de funciones sociales maduras, perfiles, seguimiento, publicaciones, respuestas, reacciones, notificaciones, moderación y protocolos ActivityPub/AT Protocol.
- Licencia: no confirmada durante esta revisión; no copiar ni redistribuir código hasta localizar y revisar una licencia aplicable.
- Compatibilidad: aplicación integrada con Nextcloud y múltiples servicios externos. Es referencia arquitectónica, no una dependencia directa apropiada para el portal actual.

### 4. fediway/fediway
- URL: https://github.com/fediway/fediway
- Uso potencial: arquitectura de recomendación por etapas (fuentes de candidatos, filtros, puntuación, cuotas y diversidad).
- Licencia: no confirmada en esta revisión. No reutilizar código hasta verificarla.
- Compatibilidad: orientado al servidor Mastodon, Rust, PostgreSQL y Redis. Sus ideas pueden orientar un servicio propio; no es un módulo directo para GitHub Pages.

### 5. mitmedialab/gobo
- URL: https://github.com/mitmedialab/gobo
- Uso potencial: transparencia del feed, filtros configurables y explicación de contenido incluido/excluido.
- Licencia: no confirmada en esta revisión. No reutilizar código hasta verificarla.
- Compatibilidad: aplicación Flask/React; requiere adaptar arquitectura y revisar dependencias.

### 6. justin-theodorus/for-you
- URL: https://github.com/justin-theodorus/for-you
- Uso potencial: referencia para ranking explicable, filtros de diversidad y controles de preferencias.
- Licencia y dependencias: pendientes de revisión del repositorio antes de reutilizar código.
- Compatibilidad: demostración con backend y frontend propios; usar como referencia de diseño hasta completar auditoría.

## Funciones sociales propuestas para NOVA

### Experiencia de usuario
1. Perfil público con avatar, nombre visible, biografía, intereses y controles de privacidad.
2. Seguir/dejar de seguir usuarios y temas.
3. Publicaciones de texto, enlaces e imágenes; tipos adicionales solo cuando almacenamiento y moderación estén listos.
4. Reacciones, comentarios, respuestas, compartir y guardar publicaciones.
5. Feed «Siguiendo» cronológico y feed «Para ti» personalizado.
6. Descubrir personas, comunidades, temas, proyectos y aplicaciones NOVA.
7. Notificaciones dentro de la web y, en una fase posterior, notificaciones push con permiso explícito.
8. Bloquear, silenciar, denunciar y ocultar contenido.
9. Controles para elegir quién puede ver, responder o compartir cada publicación.
10. Ajustes para pausar la personalización, borrar historial de recomendaciones y consultar «¿Por qué veo esto?».

### Recomendaciones transparentes
El primer recomendador debe ser determinista, sencillo y auditable, sin necesitar entrenamiento de IA ni perfiles invasivos. Señales candidatas:
- Temas elegidos explícitamente por el usuario.
- Cuentas que el usuario sigue.
- Interacciones recientes, con límites y caducidad.
- Actualidad de la publicación.
- Calidad y seguridad del contenido, según reglas visibles.
- Diversidad de autores y temas para evitar feeds repetitivos.

Reglas de protección:
- Bloqueos, silencios y denuncias prevalecen sobre cualquier puntuación.
- No optimizar únicamente por tiempo de pantalla, polémica o cantidad de reacciones.
- No inferir atributos sensibles.
- No usar mensajes privados ni datos de otras aplicaciones como señales del recomendador.
- Permitir feed cronológico, controles de preferencias y explicación de cada recomendación.
- Incluir límites por autor, deduplicación y controles contra spam.

## Arquitectura recomendada

- Frontend: conservar el portal HTML/CSS/JavaScript y crear módulos compartidos aislados, por ejemplo `assets/js/social-feed.js`, `assets/js/social-profile.js` y hojas de estilo sociales, una vez revisada la compatibilidad.
- Identidad: reutilizar el proveedor de autenticación existente solo después de confirmar que la sesión y el identificador del usuario se validan en el backend.
- Datos: usar Supabase/PostgreSQL o un backend social dedicado con políticas de acceso por fila (RLS), claves foráneas, restricciones, índices y migraciones revisadas.
- Tablas conceptuales: perfiles públicos, preferencias, publicaciones, adjuntos, seguimientos, reacciones, comentarios, guardados, notificaciones, bloqueos, silencios, denuncias y eventos mínimos de recomendación.
- Seguridad: todas las escrituras y lecturas privadas deben aplicar autorización en servidor/base de datos; nunca confiar en ocultar botones en el navegador. Aplicar límites de frecuencia, validación de contenido, tamaño/tipo de archivos y protección contra abuso.
- Archivos: almacenar imágenes en un bucket privado o público según la visibilidad elegida, con límites y URLs controladas. No exponer credenciales de servicio.
- Moderación: cola de reportes, herramientas administrativas protegidas, registro de acciones y política de apelación.
- Rendimiento: paginación por cursor, carga diferida de imágenes, caché prudente y diseño móvil primero.
- Offline/PWA: evaluar manifiesto, service worker y caché solo para recursos públicos; nunca cachear respuestas privadas o tokens de sesión en cachés compartidas.

## Plan por etapas

1. **Auditoría técnica y legal:** revisar licencias, archivos de dependencias, seguridad, actividad y módulos concretos de cada candidato. Mantener un inventario de componentes aceptados/rechazados.
2. **Base social segura:** especificar modelo de datos, RLS, migraciones, moderación y límites de abuso; probar con cuentas de prueba.
3. **Perfiles y seguimiento:** implementar perfiles, privacidad y relaciones de seguimiento.
4. **Publicaciones e interacciones:** implementar feed cronológico, comentarios, reacciones, guardados y reportes.
5. **Feed Para ti:** incorporar ranking explicable, controles de usuario y pruebas de diversidad.
6. **Descubrimiento y notificaciones:** sugerencias de personas/temas/proyectos y notificaciones con permisos.
7. **Mejora visual general:** aplicar un sistema coherente de componentes, iconos, tarjetas, estados vacíos, microinteracciones, accesibilidad y rendimiento a los micrositios.
8. **Pruebas y publicación:** validar móvil/Android, accesibilidad, RLS, sesiones, carga, errores y GitHub Actions antes de anunciar cada función como activa.

## Mejoras visuales y técnicas transversales a evaluar

- Sistema de diseño NOVA con tokens de color, espaciado, tipografía, radios, sombras y estados.
- Tarjetas y botones consistentes, iconos redondeados y estados de foco/teclado.
- Skeletons, mensajes vacíos útiles, errores recuperables y confirmaciones accesibles.
- Navegación móvil compacta y búsqueda global.
- Optimización de imágenes, formatos modernos, carga diferida y tamaños adaptables.
- Metadatos Open Graph, tarjetas de compartir, sitemap y datos estructurados cuando correspondan.
- Auditoría de accesibilidad WCAG, contraste, navegación por teclado y movimiento reducido.
- Analítica respetuosa con la privacidad y sin rastreo de terceros innecesario.

## Política de almacenamiento y privacidad

Este repositorio público debe guardar código público, documentación técnica, decisiones de arquitectura, inventarios de licencias y configuraciones no secretas. **No debe guardar** publicaciones privadas, mensajes, perfiles privados, tokens, claves, historiales individuales, listas de contactos ni datos personales de usuarios. Esos datos pertenecen a la base de datos protegida y a los controles de privacidad del servicio.

La configuración de despliegue pública puede documentarse aquí, pero secretos y credenciales deben permanecer en el gestor seguro correspondiente. Las claves publishable del cliente no sustituyen las políticas RLS ni autorizan acceso a datos.

## Estado de esta revisión

- [x] Inspeccionada la estructura del portal NOVA y su navegación/cuenta compartidas.
- [x] Confirmado que las páginas Nova Chat y Noticias Nova siguen siendo informativas.
- [x] Identificado OpenSocial como candidato MIT útil para feed explicable.
- [x] Identificado Freed como referencia MIT para privacidad y feed controlable.
- [ ] Auditoría detallada de archivos y dependencias de cada candidato.
- [ ] Revisión completa de licencias pendientes.
- [ ] Diseño y revisión de esquema social y políticas RLS.
- [ ] Implementación de funciones sociales.
- [ ] Pruebas funcionales reales y despliegue.

No se han copiado archivos de terceros ni se ha activado una red social falsa. Esta documentación registra hallazgos y una ruta de integración segura.


## Actualización de implementación — 2026-11-18

- Se construyó el primer módulo NOVA Social en el portal estático y se conectó a las tablas sociales de Supabase.
- Se desplegó el esquema en NOVA-STAGING y en Nova-Nexus (producción) tras verificar aislamiento entre usuarios, visibilidad pública/seguidores, aceptación de solicitudes y bloqueo mediante pruebas transaccionales en staging.
- La moderación administrativa, notificaciones, adjuntos multimedia y conexiones federadas siguen fuera de esta primera entrega y no se presentan como funciones activas.
- La migración de perfiles oculta de los resultados de descubrimiento a cuentas bloqueadas.
