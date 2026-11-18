# Integraciones externas de NOVA Social

Estado: diseño y requisitos documentados; conexiones directas no activadas.
Fecha: 2026-11-18

## Qué funciona hoy

- El botón «Compartir» de las publicaciones utiliza la hoja nativa de compartir del navegador/dispositivo cuando está disponible. El usuario elige manualmente Telegram, Instagram, Facebook, Discord u otra aplicación instalada.
- NOVA Social no solicita contraseñas de esas plataformas, no extrae mensajes privados y no publica en ellas sin una autorización explícita.

## Telegram

Para una conexión real:
1. Crear un bot desde BotFather y definir el nombre/usuario público.
2. Guardar el token del bot únicamente como secreto de Edge Functions/Vault de Supabase.
3. Configurar un endpoint HTTPS para webhooks y validar el secreto del webhook.
4. Vincular cuentas NOVA y Telegram mediante un código de un solo uso, con caducidad y uso único.
5. Solicitar consentimiento específico antes de enviar avisos o publicar en un canal/grupo. El bot solo puede actuar en los espacios donde se le haya añadido y autorizado.

No incluir tokens de bot en HTML, JavaScript público, repositorios ni variables visibles al navegador.

## Instagram y Facebook (Meta)

Para una conexión real:
1. Registrar una aplicación en Meta for Developers.
2. Configurar OAuth redirect URI, dominios y política de privacidad.
3. Solicitar solo los permisos de Graph API necesarios para el caso de uso concreto y completar las revisiones/verificaciones que Meta exija.
4. La publicación y administración de contenido de Instagram requiere cuentas profesionales compatibles y los activos de Meta correspondientes; no se debe prometer publicación automática en cuentas personales.
5. Guardar app secret y tokens de acceso en el almacén de secretos del backend, nunca en el frontend.
6. Implementar renovación, expiración, revocación, desconexión y borrado de tokens.

Instagram y Facebook deben tratarse como conectores distintos aunque compartan la plataforma de desarrolladores.

## Discord

Para una conexión real:
1. Crear una aplicación en Discord Developer Portal.
2. Registrar el OAuth2 redirect URI y seleccionar los scopes mínimos (por ejemplo, identidad básica cuando solo se vincula una cuenta).
3. Crear un bot solo si NOVA necesita operar dentro de servidores; pedir permisos mínimos y que el administrador del servidor lo autorice.
4. Guardar client secret y bot token en secretos del backend.
5. Permitir que el usuario desconecte la cuenta y revoque el consentimiento.

## Arquitectura de integración común

- OAuth y webhooks se procesan exclusivamente en Edge Functions verificadas con JWT o firma/secreto de webhook.
- El frontend nunca recibe secretos de proveedor ni tokens de larga duración.
- Registrar el consentimiento en `nova_integration_grants`: propietario, proveedor, finalidad, permisos, versión del consentimiento, fecha de concesión, expiración y revocación.
- Guardar credenciales en Supabase secrets/Vault, no en GitHub.
- Validar estado OAuth (CSRF), PKCE cuando corresponda, nonce, firmas de webhook, límites de frecuencia y permisos por usuario.
- Conexiones desconectables, permisos granulares, borrado de datos importados y registro de auditoría.
- El usuario elige por publicación qué plataforma puede recibir contenido; el valor predeterminado es no compartir automáticamente.
- No importar mensajes directos, contactos ni listas de amigos como señales del recomendador.

## Lo que falta para activar las conexiones

- Crear/confirmar las aplicaciones de desarrollador de cada proveedor.
- Confirmar quién será el propietario/administrador de cada aplicación y qué permisos se solicitarán.
- Introducir Client IDs y secretos de servidor en el gestor seguro de Supabase.
- Definir redirect URLs y webhooks de producción.
- Probar autorización, renovación, desconexión y revocación con cuentas de prueba.
- Obtener aprobación de cada plataforma cuando corresponda.

Hasta que esos requisitos estén listos, el portal muestra el estado como pendiente y solo ofrece compartir mediante la hoja del dispositivo. No hay integraciones API activas de Telegram, Instagram, Facebook o Discord.
