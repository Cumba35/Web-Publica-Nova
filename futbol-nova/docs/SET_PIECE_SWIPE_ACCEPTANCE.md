# Pruebas de aceptación — gestos de balón parado

## Reconocimiento táctil
- [ ] Acepta un trazo válido iniciado y terminado dentro del área.
- [ ] Rechaza toques sin desplazamiento y trazos inferiores al mínimo.
- [ ] Conserva el orden y la forma de la trayectoria.
- [ ] Limita muestras y memoria sin perder el punto inicial/final.
- [ ] Cancela de forma segura si cambia el tamaño del control.
- [ ] No duplica eventos con ratón o multitáctil.

## Tipos de reinicio
- [ ] Saque inicial.
- [ ] Tiro libre directo.
- [ ] Tiro libre indirecto.
- [ ] Penalti.
- [ ] Córner.
- [ ] Saque de puerta.
- [ ] Saque de banda.

## Física
- [ ] A mayor potencia válida, mayor velocidad inicial, dentro del límite.
- [ ] El trazo lateral modifica la curva mediante spin/Magnus.
- [ ] El trazo vertical modifica la elevación solicitada.
- [ ] La masa y los coeficientes no producen velocidades no finitas.
- [ ] Mismo estado inicial y mismos parámetros producen el mismo resultado.
- [ ] El motor de reglas puede rechazar el lanzamiento sin alterar el estado del balón.

**Estado:** lista creada; las pruebas deben ejecutarse cuando el proyecto se abra con la versión de Godot seleccionada.
