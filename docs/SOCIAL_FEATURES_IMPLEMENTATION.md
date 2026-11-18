# NOVA Social — implementación y estado

Fecha: 2026-11-18
Frontend: https://cumba35.github.io/Web-Publica-Nova/nova-social/
Repositorio: https://github.com/Cumba35/Web-Publica-Nova

## Funciones incluidas en la primera versión

- Inicio de sesión con la cuenta NOVA existente (Supabase Auth).
- Creación automática de perfil social inicial, editable por el usuario.
- Nombre de usuario, nombre visible, biografía, avatar HTTPS y perfil público/privado.
- Publicaciones de texto y enlaces HTTPS, con hasta ocho etiquetas y privacidad por publicación.
- Feed «Para ti», «Siguiendo» y «Más recientes».
- Reacciones tipo «Me gusta», comentarios, guardados y compartir enlaces.
- Búsqueda y descubrimiento de cuentas, seguir y dejar de seguir.
- Solicitudes de seguimiento para perfiles privados, con aceptación/rechazo, cancelación de solicitudes enviadas y opción de dejar de seguir.
- Bloqueo, eliminación recíproca del seguimiento, prevención de nuevas solicitudes entre cuentas bloqueadas y opción de desbloquear.
- Envío de reportes de publicaciones.
- Notificaciones internas por nuevos seguidores, solicitudes aceptadas, reacciones y comentarios; el usuario puede marcarlas como leídas.
- Sugerencias de personas ordenadas por coincidencia con los temas que el usuario eligió, cuando hay publicaciones públicas etiquetadas.
- Preferencias de temas y activación/desactivación de recomendaciones.

## Recomendador

El primer ranking es una heurística pequeña y auditable ejecutada en el navegador. Ordena candidatos visibles por:
1. Temas que el usuario eligió explícitamente.
2. Cuentas que el usuario sigue.
3. Frescura de la publicación.
4. Diversidad de autores (evita más de dos publicaciones seguidas del mismo autor).

Cada publicación explica el motivo general de su posición. Si el usuario desactiva la personalización o elige «Más recientes», se respeta el orden cronológico. El ranking no utiliza mensajes privados, datos de otras aplicaciones, atributos sensibles ni perfiles inferidos. No es un modelo de IA entrenado ni replica el algoritmo privado de Facebook o X.

## Modelo de datos

Las tablas sociales dedicadas se encuentran en el esquema `public` de Supabase:
- `nova_social_profiles`
- `nova_social_posts`
- `nova_social_follows`
- `nova_social_blocks`
- `nova_social_comments`
- `nova_social_reactions`
- `nova_social_bookmarks`
- `nova_social_preferences`
- `nova_social_reports`
- `nova_social_notifications`

No se duplicaron las tablas existentes de Nova Chat, reseñas de Nova Apps ni perfiles del directorio NOVA. Los perfiles sociales son una capa independiente para evitar cambiar el contrato de esos módulos.

## Seguridad aplicada

- RLS habilitado en las diez tablas sociales.
- Se revocaron los privilegios de `PUBLIC` y `anon`; las tablas sociales no son accesibles a visitantes sin sesión.
- Los usuarios autenticados solo pueden crear/editar su propio perfil, publicaciones y comentarios.
- Las relaciones de seguimiento solo son visibles para sus participantes.
- Los perfiles privados ocultan sus publicaciones a usuarios no aprobados.
- Los bloqueos se aplican a publicaciones y resultados de descubrimiento.
- Los reportes permiten insertar al usuario, pero no leer ni alterar la cola de moderación desde el cliente.
- Las notificaciones permiten SELECT solo al destinatario y UPDATE solo de `read_at`; no se concede INSERT al cliente. El trigger usa una función `SECURITY DEFINER` en esquema privado, con `search_path` vacío y sin permiso EXECUTE para roles de la API.
- Las notificaciones solo permiten lectura por destinatario y actualización de `read_at`; una función de trigger en esquema privado las crea. Su `search_path` está fijado y se revocó EXECUTE a roles API.
- Las relaciones entre usuarios no confían en campos editables de `user_metadata` para autorización.
- No se han puesto claves secretas, tokens ni datos personales en GitHub.

## Migraciones aplicadas

Los archivos SQL del repositorio conservan las versiones de migración del entorno `NOVA-STAGING`. En producción (`Nova-Nexus`) Supabase registró los mismos nombres con identificadores de versión distintos:
- `20261118210209_nova_social_foundation`
- `20261118210210_nova_social_fk_indexes`
- `20261118210224_nova_social_profile_block_visibility`
- `20261118210441_nova_social_visibility_and_reports`
- `20261118210812_nova_social_follow_block_guard`
- `20261118210938_nova_social_notifications`
- `20261118211007_nova_social_notification_function_permissions`
- `20261118211008_nova_social_comment_policy_fix`
- `20261118211147_nova_social_notification_fk_indexes`

Las nueve etapas se aplicaron en ambos entornos. La correspondencia por nombre es: `nova_social_foundation` (staging `20261118210209`, producción `20261118210042`); `nova_social_fk_indexes` (`20261118210210` / `20261118210127`); `nova_social_profile_block_visibility` (`20261118210224` / `20261118210222`); `nova_social_visibility_and_reports` (`20261118210441` / `20261118210440`); `nova_social_follow_block_guard` (`20261118210812` / `20261118210810`); `nova_social_notifications` (`20261118210938` / `20261118210935`); `nova_social_notification_function_permissions` (`20261118211007` / `20261118210944`); `nova_social_comment_policy_fix` (`20261118211008` / `20261118210956`); `nova_social_notification_fk_indexes` (`20261118211147` / `20261118211146`). El SQL se conserva en GitHub para reproducibilidad.

## Verificación realizada

En `NOVA-STAGING` se ejecutó `supabase/tests/nova_social_rls_test.sql` mediante una transacción que termina en `ROLLBACK`. Se comprobó:
- Un perfil privado no expone publicaciones antes de aprobar un seguidor.
- Un usuario no puede publicar en nombre de otra cuenta.
- La aceptación de una solicitud permite ver las publicaciones reservadas a seguidores.
- Las notificaciones de seguimiento, reacción y comentario se crean automáticamente; solo el destinatario puede leerlas y marcar su estado.
- Un bloqueo oculta las publicaciones entre ambas cuentas.

En producción se comprobó:
- Las nueve tablas existen y tienen RLS activado.
- `anon` no tiene privilegio de lectura.
- `authenticated` tiene solo las operaciones previstas; `nova_social_reports` permite únicamente INSERT al cliente.
- El asesor de salud no reportó problemas.
- El asesor de seguridad de Supabase no reportó hallazgos en la última revisión. No se modificó la configuración global de Auth.
- El asesor de rendimiento no mostró claves foráneas sociales sin índice; los avisos de índices no usados son informativos y se esperan en un módulo recién creado sin tráfico.

La validación de RLS no sustituye una prueba interactiva con dos cuentas reales ni la revisión visual en Chrome Android. Las notificaciones internas se consultan al cargar o al pulsar actualizar; aún no se habilitó Realtime ni push.

## Límites pendientes antes de considerar la red social completa

1. Moderación administrativa: panel privado para revisar reportes, ocultar contenido, suspender cuentas y registrar decisiones.
2. Notificaciones push con permisos explícitos y suscripciones en tiempo real; las notificaciones internas ya están implementadas y se consultan al cargar o actualizar.
3. Adjuntos de imagen/vídeo, bucket de Storage, límites de tamaño y revisión de contenido.
4. Edición de publicaciones/comentarios, respuestas anidadas y herramientas avanzadas de privacidad. Los comentarios de esta primera versión son lineales para evitar una política RLS recursiva.
5. Pruebas reales de Google OAuth, perfiles y publicaciones con dos cuentas de usuario.
6. Pruebas visuales y de accesibilidad en Android y otros navegadores.
7. Integraciones externas con Telegram, Instagram, Facebook y Discord: requieren registrar aplicaciones/bots, configurar callbacks y permisos OAuth, consentimiento de usuario y guardar secretos/tokens exclusivamente en el gestor seguro del backend. No se han activado ni se simulan.
8. Federación ActivityPub y sincronización entre plataformas, fuera de esta primera versión.
9. Nova Chat continúa siendo un módulo separado; la mensajería privada no se presenta como disponible en Nova Social.

## Publicación

GitHub Pages publica el código de frontend desde `main`. Cada cambio debe pasar la validación del sitio, el escaneo de secretos y el workflow de despliegue. No anunciar funciones como activas hasta que sus pruebas específicas hayan pasado.
