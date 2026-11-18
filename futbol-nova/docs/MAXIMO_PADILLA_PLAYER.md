# Máximo Padilla Robert — jugador personalizado

![Fotografía de referencia de Máximo Padilla](../assets/players/maximo_padilla_reference.jpg)


**ID:** `NOVA-PLAYER-0036`  
**Proyecto:** Fútbol Nova  
**Datos canónicos:** `data/custom_players.json`  
**Fotografía de referencia:** `assets/players/maximo_padilla_reference.jpg`  
**Revisión:** 18-11-2026

## Identidad
| Campo | Valor |
|---|---|
| Nombre completo | Máximo Padilla Robert |
| Nombre en el juego | Máximo Padilla |
| Nombre del uniforme | PADILLA |
| Edad | 29 (sin inventar fecha de nacimiento) |
| País de nacimiento / nacionalidad | Cuba (CUB) |
| Selección nacional | Cuba |
| Selección favorita | Argentina (ARG) |
| Club solicitado | Barcelona |
| Club interno de Fútbol Nova | Litoral Barcelona (`FN-ESP-BARCELONA`) |
| Posición principal | MCD |
| Segunda posición | MC |
| Medias | Altas |
| Camiseta interior | Compresión, manga larga, como Anier |

## Valoración y medidas
GRL 94 y POT 97 son valores confirmados expresamente por el propietario; permanecen fijos aunque se ajusten los atributos base. Altura 180 cm y peso 75 kg son medidas provisionales usadas para el blockout 3D, no datos biográficos confirmados.

## Perfil de juego y estadísticas base
Máximo utiliza un perfil de **pivote único recuperador**, inspirado en el Casemiro de su etapa en el Real Madrid. No copia sus datos oficiales: son atributos de diseño propios de Fútbol Nova.

- **Defensa:** intercepciones 97, conciencia defensiva 97, entradas 97, barridas 94.
- **Físico y duelos:** fuerza 96, agresividad 95, resistencia 94, salto 91, cabeceo 91.
- **Distribución:** pase corto 88 y pase largo 92; prioriza el pase sencillo y los cambios diagonales.
- **Ataque:** regate 74, definición 70 y velocidad 76; no es un mediocampista de conducción explosiva.
- **Comportamiento táctico:** proteger el carril central delante de los centrales, anticipar líneas de pase, cubrir espacios de laterales, disputar segundas jugadas y evitar persecuciones o entradas tardías.
- **Ajustes en partido:** ritmo 7.2, aceleración 21.5, fuerza de pase 5.9, tiro 9.5, alcance adicional de entrada 0.18 y bonificación de ángulo 0.08.

La media general **94** y la proyección **97** no se recalculan ni se alteran con estos atributos.

## Referencia y modelo 3D
- Fotografía de referencia archivada como JPEG optimizado 200 × 356 px: `assets/players/maximo_padilla_reference.jpg`.
- Escena: `scenes/players/maximo_padilla.tscn`.
- Controlador: `scripts/players/maximo_padilla.gd`.
- Blockout procedural con cápsula de colisión de 180 cm, cabello muy corto, rasgos faciales básicos orientados al frente, tono de piel orientativo según la fotografía, equipación blaugrana inspirada en Barcelona, dorsal 30 y nombre PADILLA renderizados como texto 3D en la espalda, medias altas, espinilleras y mangas interiores blancas de compresión de manga larga visibles sobre los antebrazos.
- El blockout es un personaje 3D procedural inicial, no un escaneo ni un esculpido facial de alta fidelidad. La foto se conserva como referencia para mejorar el parecido.

## Valoración confirmada
- Media general (GRL): **94**.
- Proyección (POT): **97**.
- Ambas cifras fueron indicadas expresamente por el propietario el 18-11-2026. Los atributos individuales existentes se conservan y no se recalculan automáticamente.

## Integración
- [x] Ficha canónica en `data/custom_players.json`.
- [x] Fotografía guardada en el repositorio.
- [x] Escena 3D y controlador procedural creados.
- [x] Añadido a la plantilla `player_ids` de Litoral Barcelona en `data/spain_clubs_2026_27.json`.
- [x] Incluido en el catálogo del Modo Leyenda con verificación de sesión de propietario.
- [x] El amistoso cambia el personaje controlado a Máximo cuando Litoral Barcelona es el equipo local.
- [x] Edad declarada de 29 años aceptada sin fabricar una fecha exacta de nacimiento, también en el guardado de Modo Leyenda.
- [x] Escena con cápsula de colisión alineada a 180 cm.
- [x] Prueba automatizada añadida: `tests/test_maximo_padilla_profile.gd` y conectada al workflow Android.

## Validación pendiente
La prueba automatizada de perfil/escena/carrera está conectada antes de la exportación del APK. Aún no se ha ejecutado: los intentos de GitHub Actions fallan antes de asignar un runner (`runner_id=0`, sin pasos ejecutados), incluso tras reintentar el último job. Este entorno tampoco tiene Godot instalado. No se considera validado el APK ni el parecido facial hasta que el workflow pueda ejecutarse y se inspeccione el modelo dentro del juego.


## Política de recursos
Fútbol Nova no puede depender de servicios externos para autenticación, datos o contenido. El acceso de propietario se mantiene bloqueado hasta integrar identidad nativa NOVA; la foto y los datos del jugador permanecen como recursos propios versionados en el repositorio Workspace.
