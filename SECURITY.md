# Política de seguridad de NOVA

## Clasificación de repositorios

- `Nova-Workspace` es el repositorio maestro privado y respaldo. No debe hacerse público.
- `Web-Publica-Nova` es un repositorio público: todo archivo, historial, rama y recurso que se publique aquí debe considerarse visible y copiable por cualquiera.
- Solo se publicará en el repositorio público código, documentación y recursos destinados expresamente a distribución pública.

## Secretos prohibidos en repositorios

Nunca guardar aquí contraseñas, claves maestras, claves privadas, tokens de acceso, credenciales de servicios, certificados privados, archivos .env reales, copias de bases de datos privadas ni datos personales. Usar GitHub Actions Secrets/Variables o un gestor de secretos externo para procesos de servidor. Los secretos nunca deben incluirse en HTML, JavaScript o aplicaciones cliente.

## Llave maestra NOVA

La llave maestra será creada y custodiada exclusivamente por el propietario, fuera de GitHub y fuera del código fuente. No debe enviarse por chats, issues, commits ni archivos del repositorio.

Diseño recomendado:
- Generar una clave aleatoria de alta entropía (mínimo 256 bits) o una frase secreta larga y única.
- Derivar claves de cifrado mediante Argon2id con sal aleatoria por archivo/registro, o usar una clave aleatoria de datos (DEK) protegida por la llave maestra (KEK).
- Cifrar datos privados con AES-256-GCM o XChaCha20-Poly1305, con nonce único y autenticación.
- Mantener la llave maestra y las copias de recuperación en un gestor de contraseñas y una copia offline segura.
- No cifrar código que deba ejecutarse en un navegador o dispositivo público esperando que así permanezca secreto: el cliente debe poder obtener el texto o la clave para ejecutarlo.
- Si se pierde la llave maestra sin una copia de recuperación, los datos cifrados podrían ser irrecuperables.

No se implementará una llave maestra dentro de este repositorio público. La implementación de cifrado se hará en el repositorio privado y solo después de definir qué datos se cifran y dónde se descifran.

## Controles de publicación

- Revisar cambios antes de publicarlos.
- Ejecutar escaneo automatizado de secretos y validaciones en cada pull request.
- Mantener dependencias y acciones actualizadas; fijar acciones a SHA completo cuando se adopte un flujo de producción.
- Proteger la rama principal desde la configuración de GitHub: exigir pull requests, comprobaciones aprobadas y bloquear force-push y borrado.
- Activar secret scanning y push protection si están disponibles para el plan y tipo de repositorio.
- Si un secreto llega a publicarse, revocarlo/rotarlo inmediatamente. Borrarlo del último commit no elimina su exposición del historial.

## Respuesta a incidentes

Ante una filtración: revocar credenciales, emitir nuevas claves, revisar logs y permisos, retirar el material expuesto y evaluar la limpieza del historial. No confiar en borrar el archivo como única medida.
