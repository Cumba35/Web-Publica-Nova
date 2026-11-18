# Módulo Realista — diseño y alcance

**ID:** `futbol_nova_realism`  
**Ruta:** `scripts/modules/realism_module.gd` + paquete de datos independiente  
**Estado:** integración inicial del perfil de fatiga; el paquete descargable está en desarrollo y no se presenta como publicado.

## Objetivo

Ampliar la profundidad de la simulación sin hacer que el juego base dependa del módulo. El objetivo es que el juego base conserve reglas, tiempos, sustituciones, lesiones básicas y coherencia futbolística; varias de esas áreas siguen en desarrollo y no deben anunciarse como terminadas. Realista añade detalle configurable.

## Arquitectura

- El código adaptador permanece ligero dentro del proyecto para que el juego pueda detectar el módulo instalado.
- El perfil de configuración viaja como paquete JSON independiente, administrado por `ContentPackages`, con verificación de tamaño y SHA-256 antes de instalarse.
- Si el paquete no está instalado o su configuración no supera validación, el juego usa el comportamiento base.
- El módulo no requiere conexión durante el partido; una vez instalado funciona offline.
- El catálogo lo identifica como agregado independiente, en desarrollo y no descargable hasta que se publique un paquete real con URL, tamaño y SHA-256 verificados.

## Primera función conectada

Fatiga gradual de los futbolistas IA:
- La resistencia empieza en 100 y se reduce al desplazarse.
- La resistencia se recupera al descansar.
- La velocidad de desplazamiento disminuye gradualmente con la resistencia hasta el mínimo configurado.
- Los valores se limitan para impedir configuraciones corruptas o extremas.
- La lógica de fatiga está desactivada si Realista no está instalado; no cambia el comportamiento del juego base.

## Módulos de profundidad previstos

1. Biomecánica y movimiento: aceleración, desaceleración, equilibrio, giro, inercia y recuperación tras contacto.
2. Balón: variación de rebote, fricción, efecto, superficie y condiciones ambientales.
3. Fatiga: carga por sprint, presión, saltos, duelos y recuperación entre períodos/partidos.
4. Lesiones: tipos, gravedad, riesgo contextual, atención médica y tiempo de recuperación.
5. Arbitraje: perfiles, criterio, posicionamiento, precisión, ventaja y VAR.
6. IA táctica: líneas, coberturas, presión coordinada, cambios según marcador y tiempo.
7. Presentación: animaciones contextuales, repeticiones, cámaras y ambiente de estadio.

Cada ampliación se activará solo cuando esté implementada y probada. Los indicadores `*_enabled` del perfil no activan por sí solos funciones que todavía no existen.

## Compatibilidad y seguridad

- Mantener GDScript y recursos de bajo coste; no incorporar GDExtensions ni librerías nativas en esta fase.
- El paquete solo puede instalarse por HTTPS, con tamaño exacto y checksum SHA-256.
- No ejecutar código descargado; el contenido es JSON de datos, no scripts.
- La ruta instalada debe estar dentro de `user://futbol_nova/packages/`.
- No permitir valores fuera de límites.
- El paquete se queda en `in_development` hasta generar el ZIP/JSON de distribución y validar instalación, activación, desactivación y rendimiento en Android.

## Criterios de aceptación

- El juego arranca y juega normalmente sin el paquete.
- Un perfil válido activa fatiga y recuperación.
- Resistencia 100 no reduce la velocidad; 0 aplica solo el mínimo configurado.
- Valores inválidos desactivan el módulo de forma segura.
- Desinstalar el paquete restaura inmediatamente la lógica base en el siguiente inicio/partido.
- Ningún campo futuro se presenta como función disponible antes de implementarse.
