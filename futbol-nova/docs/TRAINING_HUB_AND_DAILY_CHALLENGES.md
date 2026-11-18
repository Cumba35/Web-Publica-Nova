# Fútbol Nova — Centro de entrenamiento y desafíos diarios

**Estado:** primera implementación de navegación y tarjetas guardada el 2026-11-14; validación en Godot/Android pendiente. El menú se construye desde `scripts/ui/game_hub.gd` y se integra en `scripts/main.gd`. El centro ofrece Tutorial, Tiro libre, Penalti y Práctica libre; las selecciones colocan el balón y al jugador en posiciones de práctica del campo 3D. La tarjeta Momentos aparece en Inicio, fuera del carrusel de entrenamiento, pero todavía es un marcador de posición: no hay reto/recompensa activa ni servicio de reclamación conectado. No declarar completo hasta añadir ciclos diarios, persistencia de progreso/reclamación, recompensa idempotente y pruebas.

## 1. Ubicación de las pantallas

El acceso **Entrenamiento** desde Inicio abre un centro con carrusel horizontal de tarjetas grandes, inspirado en la composición de las capturas del usuario, pero con identidad, textos, iconos, ilustraciones y recursos originales de Fútbol Nova.

Tarjetas del centro:
1. **Tutorial:** lecciones interactivas de movimiento, conducción, pase, tiro, defensa, regates y balón parado. Cada lección muestra objetivo, controles, demostración, práctica guiada y resultado.
2. **Tiro libre:** práctica repetible de faltas directas; elegir posiciones válidas fuera del área, distancia, ángulo, barrera y portero; cambiar técnica y reiniciar rápidamente.
3. **Penalti:** práctica repetible con selección de lanzador/portero, dirección, altura, potencia y técnica; series y estadísticas de acierto.
4. **Práctica libre:** espacio sin objetivos obligatorios para movimiento, conducción, regates, pases y tiros. Se incorpora como cuarta tarjeta cuando esté lista.

**Momentos NO pertenece al centro de entrenamiento.** Aparece en la **pantalla 1 — Inicio**, como tarjeta destacada de **Desafío diario**. Es una tarjeta de Inicio, no una quinta pantalla raíz.

## 2. Tarjeta de desafío diario (Momentos)

La tarjeta de Inicio muestra ilustración original, nombre y resumen del reto, dificultad, progreso, tiempo restante hasta el próximo ciclo, recompensa y estado (disponible, en curso, completado o reclamado). Al abrirla se presentan reglas, objetivo, progreso y botón de reclamar cuando se cumpla el reto. El jugador puede volver a Inicio sin perder el estado.

## 3. Rotación, persistencia y recompensas

- Publicar un desafío nuevo por ciclo diario; mostrar hora local del próximo cambio y conservar marca de tiempo inequívoca UTC.
- Un reto ya instalado puede jugarse offline. La rotación online puede actualizar el catálogo, pero no bloquear el reto local vigente.
- Cada reto tiene ID estable, ciclo, objetivo, parámetros, dificultad, reglas, versión y recompensa.
- Cada perfil reclama una sola vez por ID/ciclo. La concesión es atómica e idempotente.
- Completar offline deja resultado pendiente de sincronización; al recuperar conexión se sincroniza sin duplicar recompensas.
- Guardar progreso, finalización y reclamación ante cierres o reinicios.
- Cambiar manualmente la hora del teléfono no debe permitir reclamar repetidamente. Usar hora de servidor cuando exista; offline proteger el último ciclo confiable y reconciliar al sincronizar.
- No exigir compras, anuncios ni conexión constante para obtener recompensas.
- Recompensas permitidas en la economía normal: experiencia, puntos de entrenamiento o cosméticos desbloqueables. No crear moneda de pago ni ventajas competitivas injustas. Tipo y cantidad se configuran por reto; no se fija una cantidad hasta que sea aprobada.
- Admitir eventos especiales y dificultad progresiva, manteniendo el reto diario vigente destacado en Inicio.

## 4. Diseño e integración

- Carrusel horizontal de tarjetas grandes, foco claro y parte de la siguiente tarjeta visible.
- Títulos grandes, imagen deportiva central, fondo de estadio y acento de color; assets originales, sin copiar capturas, marcas, escudos, futbolistas ni recursos protegidos.
- Adaptar a Android horizontal/vertical, relaciones de aspecto y zonas seguras.
- Navegación táctil, mando y teclado cuando estén disponibles. Gestos dentro de controles no deben activar navegación raíz.
- Mostrar disponibilidad real. Actividades aún no implementadas aparecen como «Próximamente», nunca como jugables.
- Tutorial, tiro libre, penalti y práctica libre comparten física del balón, controlador, cámara y entrada.
- Retos diarios reutilizan esos ejercicios como escenarios parametrizados y registran resultados validados.
- La tarjeta diaria se muestra en Inicio; el centro de entrenamiento se abre desde Inicio y regresa al mismo contexto.

## 5. Criterios de aceptación

1. Inicio abre Entrenamiento.
2. El centro muestra Tutorial, Tiro libre y Penalti; Práctica libre se añade cuando sea funcional.
3. Las actividades jugables permiten reiniciar y salir.
4. Momentos aparece como tarjeta de desafío diario en Inicio, nunca en el carrusel de entrenamiento.
5. La tarjeta muestra objetivo, progreso, ciclo y recompensa.
6. Completar/reclamar persiste y no duplica recompensa.
7. Un reto instalado funciona offline y sincroniza después sin duplicados.
8. Rotación diaria no requiere conexión constante.
9. Escenas adaptables y pruebas de navegación, persistencia y accesibilidad superadas.
10. Ninguna actividad se marca funcional antes de ejecutarse y probarse en Godot.

## 6. Referencias

- Capturas aportadas por el usuario el 2026-11-14: Tutorial, Tiro libre, Penalti y tarjeta Momentos con cuenta atrás, estado y recompensa. Definen distribución, no assets para copiar.
## 6. Detalles de diseño ampliados tomando otros juegos como referencia

Los siguientes elementos son decisiones de diseño originales para Fútbol Nova inspiradas en patrones públicos de otros títulos, no reproducciones de sus recursos ni de su interfaz.

### Tutorial
- Ruta de lecciones cortas y secuenciales: movimiento, conducción, pase, tiro, defensa y balón parado.
- Cada lección tiene demostración, zona de práctica, instrucción contextual, intento del jugador, evaluación y repetición.
- Asistencia configurable: mostrar indicaciones completas, solo pistas o ninguna.
- La lección se considera superada por cumplir el objetivo observable, no por esperar un temporizador.
- Basado en el enfoque de tutorial paso a paso y partidos de práctica de eFootball.

### Desafíos de habilidad
- Ejercicios breves con objetivo visible, contador de intentos, puntuación y resultado.
- Variar entre precisión, conducción entre obstáculos, pases a zonas, tiros a objetivos y secuencias de controles.
- Medalla/rango por umbrales de rendimiento, no solo victoria/derrota.
- Repetición y comparación de la mejor marca personal.
- Inspiración general en Skill Games de EA SPORTS FC Mobile, con ejercicios de control, tiro, agilidad y pase.

### Tiro libre
- Ajustar dirección, altura, efecto y potencia por separado.
- Mostrar una trayectoria estimada antes del golpeo como ayuda opcional; no garantiza que el balón siga exactamente esa curva.
- Configurar barrera, distancia, ángulo y comportamiento del portero.
- Registrar precisión, goles, intentos y zonas de impacto.
- Basado en los controles de balón parado y la previsualización de trayectoria descritos públicamente por Konami para eFootball.

### Penalti
- Separar selección de lanzador, dirección, altura y potencia.
- Añadir serie de cinco lanzamientos, práctica libre ilimitada y modo portero.
- El guardameta puede variar la anticipación; no debe adivinar siempre la dirección.
- Registrar goles, atajadas, tiros fuera y porcentaje por zona.

### Práctica libre
- Campo sin cronómetro ni objetivos obligatorios.
- Reinicio rápido del balón, selector de balón quieto/en movimiento y objetivos opcionales.
- Cambiar entre práctica con portero, sin portero y con defensores pasivos.

### Accesibilidad y mando
- Mantener controles táctiles y mando simultáneamente; no forzar a desconectar uno para usar el otro.
- Ofrecer asistencia de controles, tamaño de botones, sensibilidad y zona muerta.
- Los menús deben poder navegarse con mando, no solo el partido.
- Cambiar indicaciones visuales entre botones táctiles, teclado y mando según la última entrada detectada.

## 7. Referencias

- EA SPORTS FC Mobile, sitio oficial: https://www.ea.com/games/ea-sports-fc/fc-mobile — Skill Games y ejercicios de control, tiro, agilidad y pase.
- eFootball, tutorial y descripción oficial: https://www.konami.com/efootball/en/page/overview — tutorial paso a paso, partidos de práctica y asistencia configurable.
- eFootball, manual oficial de mandos móviles: https://www.konami.com/efootball/en/page/mobile_controller — mandos Bluetooth probados, comandos de ataque/defensa y balón parado; Konami advierte que la compatibilidad de otros mandos no está garantizada y que los menús móviles no se controlan con mando. Fútbol Nova buscará permitir navegar también los menús.
- eFootball, actualización oficial de controles de balón parado: https://www.konami.com/efootball/en-us/page/v5/versioninfo_v5-00 — ajuste de dirección/altura, potencia, efecto y trayectoria estimada.
- Dream League Soccer 2026, ficha de App Store: https://apps.apple.com/us/app/dream-league-soccer-2026/id1462911602 — referencia de juego 3D y soporte de mando anunciado en la ficha.
