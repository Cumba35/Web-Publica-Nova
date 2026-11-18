# Fútbol Nova — Guardado automático y manual

**Estado:** reglas funcionales confirmadas; integración en el motor pendiente.

## Organización
- Cada modo de juego dispone de exactamente cinco espacios de guardado.
- Espacio 1: reservado exclusivamente para autoguardados.
- Espacios 2, 3, 4 y 5: guardados manuales y copias.
- Máximo: cinco espacios por modo y veinte espacios en total para los cuatro grupos de modos previstos. Los datos de cada modo permanecen separados y no se sobrescriben entre modos.

## Reglas del autoguardado
- Todo autoguardado se escribe en el espacio 1 del modo correspondiente.
- El usuario no puede seleccionar el espacio 1 como destino de un guardado manual ni de una copia.
- Los guardados manuales nunca sustituyen el autoguardado.
- La escritura debe ser segura: validar y completar el nuevo estado antes de reemplazar el contenido válido del espacio 1. Un fallo no debe dejar el guardado anterior inutilizable.
- Mantener el comportamiento de autoguardado y sus desencadenantes ya definidos en la configuración del proyecto; este documento no introduce desencadenantes nuevos.

## Gestión de espacios
- Mantener pulsado un espacio abre un menú lateral con: Renombrar, Copiar y Borrar.
- Renombrar cambia únicamente el nombre visible; no modifica el contenido de la partida.
- Copiar permite elegir como destino uno de los espacios manuales disponibles (2–5) del mismo modo.
- Si el destino ya contiene una partida, mostrar una confirmación clara antes de sobrescribirla. La confirmación debe identificar el destino y advertir que su contenido actual se reemplazará.
- Borrar requiere confirmación y nunca debe ofrecer borrar el espacio 1 reservado al autoguardado desde la gestión manual.
- No permitir copiar entre modos incompatibles ni restaurar una partida con una versión de datos no compatible sin migración validada.

## Datos mostrados
Cada espacio muestra nombre, modo, fecha/hora del último guardado, temporada/carrera o contexto y estado de compatibilidad. El espacio 1 se identifica como «Autoguardado» y los espacios 2–5 como «Manual». Los espacios vacíos se muestran claramente.

## Integridad y recuperación
- Usar formato versionado y migraciones explícitas.
- Verificar integridad antes de cargar.
- Conservar el último guardado válido ante interrupciones de escritura.
- No declarar una operación completada hasta que el motor confirme escritura/lectura.
- Advertir antes de cualquier operación que pueda reemplazar o perder datos.
- La interfaz debe permanecer coherente tras cerrar y volver a abrir el juego.

## Criterios de aceptación
1. Cada modo muestra cinco espacios y no más.
2. El espacio 1 solo recibe autoguardados.
3. Los espacios 2–5 admiten guardado manual y copia.
4. Mantener pulsado abre Renombrar, Copiar y Borrar.
5. Sobrescribir un destino ocupado exige confirmación.
6. Las operaciones no cruzan datos entre modos.
7. Un fallo durante el guardado no destruye el último estado válido.
8. Cargar verifica integridad y compatibilidad.
