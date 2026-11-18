# Fútbol Nova — metodología de valoración de mercado de futbolistas

**Versión:** 1.0.0  
**Fecha de adopción:** 14-11-2026  
**Referencia principal:** Transfermarkt  
**Ámbito:** todos los futbolistas del juego: reales cuando su uso esté autorizado y ficticios/personalizados creados para Fútbol Nova.

## 1. Regla obligatoria

Transfermarkt será la referencia principal para estimar el valor de mercado de todos los futbolistas de Fútbol Nova. Esta regla se aplica a jugadores personalizados, plantillas generadas, fichajes, renovaciones y actualizaciones de temporada.

Los importes calculados por Fútbol Nova son **estimaciones propias inspiradas en el enfoque y los comparables de Transfermarkt**. Nunca se presentarán como valores oficiales publicados por Transfermarkt ni como precios garantizados de traspaso.

## 2. Qué significa el valor

Se estima el valor esperado del futbolista en el mercado en condiciones normales. No equivale automáticamente a:
- una oferta concreta;
- una cláusula de rescisión;
- el precio final de un traspaso;
- el coste total de una operación con variables;
- el salario o el valor contable del jugador.

Transfermarkt explica que sus valores no predicen el precio de una transferencia y que no se calculan mediante un algoritmo automático: combina modelos de referencia, comparación de mercado y evaluación de su comunidad y responsables de valoración.

## 3. Factores obligatorios

La estimación debe considerar, cuando existan datos verificables:

1. Edad y etapa de carrera.
2. Posición principal, posiciones secundarias y rol táctico.
3. Rendimiento individual: apariciones, titularidades, minutos, goles, asistencias y métricas específicas de posición.
4. Nivel de liga, división y competitividad del club.
5. Importancia del jugador en su plantilla y rendimiento colectivo del club.
6. Nivel internacional: convocatorias, partidos y rendimiento con su selección.
7. Potencial de desarrollo y trayectoria reciente.
8. Historial de lesiones y disponibilidad.
9. Duración y condiciones conocidas del contrato, salario y situación de mercado.
10. Demanda, interés documentado de clubes, reputación y proyección comercial cuando sea relevante.
11. Comparables de Transfermarkt de edad, posición, liga, nivel deportivo y contexto semejantes.
12. Fecha de corte de los datos y condiciones económicas del mercado.

No se inventarán estadísticas, contrato, salario, ofertas, lesiones, clubes actuales ni interés de equipos. Los datos desconocidos se marcan como no disponibles y reducen la confianza de la estimación.

## 4. Comparación con Transfermarkt

Para cada valoración:
- buscar futbolistas comparables en Transfermarkt;
- registrar nombre, posición, edad, club/competición, valor publicado y fecha de consulta;
- preferir comparables de la misma posición y de ligas de nivel semejante;
- utilizar varios comparables cuando haya datos suficientes, no un único jugador;
- justificar los ajustes por edad, rendimiento, potencial, minutos, contrato y nivel competitivo;
- guardar URL y fecha de consulta de las fuentes.

Los valores publicados por Transfermarkt son referencias externas fechadas: no se copian como si fueran el valor del jugador de Fútbol Nova. Las comparaciones entre temporadas deben respetar la fecha de cada valoración.

## 5. Escala y presentación

- Moneda estándar del mercado: euro (EUR).
- Usar importes redondeados y escalones coherentes con la magnitud del mercado, evitando precisión falsa.
- Guardar el importe numérico, moneda, fecha de valoración, versión de metodología, comparables, fuentes, confianza y justificación.
- Mantener separados valor de mercado, salario, cláusula y precio de traspaso.
- Actualizar la estimación al menos al cierre de cada temporada simulada y cuando ocurra un cambio deportivo o contractual importante.

## 6. Confianza

- **Alta:** edad, club, liga, contrato y estadísticas recientes confirmados; comparables directos suficientes.
- **Media:** perfil deportivo y contexto competitivos conocidos, pero faltan algunos datos secundarios o comparables exactos.
- **Baja:** faltan estadísticas, club contractual, liga, contrato o contexto de mercado; la cifra es provisional y debe revisarse.

La confianza no modifica por sí sola el importe: expresa la solidez de la evidencia disponible.

## 7. Jugadores ficticios y personalizados

Los jugadores ficticios no tienen una cotización real en Transfermarkt. Se comparan con futbolistas reales de perfil y nivel semejantes, sin atribuirles sus estadísticas ni copiar sus fichas. Los atributos y el GRL de Fútbol Nova sirven como indicadores internos del nivel jugable, pero no se convierten directamente en euros ni se tratan como estadísticas reales.

Cuando el club contractual, la liga o las estadísticas de un jugador ficticio no estén definidos, la valoración debe indicarse como provisional y con confianza reducida. El club favorito no se interpreta como club contractual.

## 8. Registro mínimo por futbolista

El registro de valoración debe conservar:
- `amount` y `currency`;
- `valuation_date`;
- `methodology_version`;
- `confidence`;
- `comparables` con sus valores y fechas de referencia;
- `sources` con URL y fecha de consulta;
- `rationale`;
- `limitations` y datos pendientes.

## 9. Fuentes metodológicas iniciales

- Transfermarkt, definición oficial del valor de mercado: https://www.transfermarkt.us/navigation/mwdefinition
- Transfermarkt, explicación del proceso y participación de la comunidad: https://www.transfermarkt.us/want-to-have-your-say-on-premier-league-market-values-get-involved-in-our-forum/view/news/453270
- Revisión académica sistemática de los determinantes de valoración: https://onlinelibrary.wiley.com/doi/full/10.1111/joes.12552

## 10. Control de integridad

- No presentar una estimación de Fútbol Nova como valor oficial de Transfermarkt.
- No confundir valor de mercado con tarifa de traspaso.
- No usar nacionalidad como penalización automática.
- No derivar euros directamente del GRL o POT.
- No inventar estadísticas, contratos ni clubes contractuales.
- Conservar la fecha y procedencia de cada comparable.
- Aplicar esta metodología a todos los futbolistas, no solo a los jugadores personalizados.


## 11. Salarios: consulta obligatoria de Transfermarkt

Transfermarkt también será la primera referencia externa para investigar el salario de todos los futbolistas, tanto reales como ficticios/personalizados. En cada ficha o actualización salarial se debe buscar la información disponible en Transfermarkt y registrar la fecha de consulta y la URL de la ficha o fuente concreta.

- Si Transfermarkt publica una estimación salarial, conservarla como **estimación atribuida a Transfermarkt**, con moneda, periodicidad y temporada/fecha cuando estén disponibles.
- Si la cifra procede de una estimación de terceros reproducida por Transfermarkt, identificarla como tal; no describirla como salario contractual confirmado.
- Si Transfermarkt no muestra salario o la información no puede verificarse, registrar «no disponible en Transfermarkt». No inventar ni deducir un salario a partir del valor de mercado.
- Contrastar, cuando sea posible, con fuentes oficiales del club, documentos contractuales o reportes periodísticos fiables. Mantener diferenciados salario bruto/neto, fijo/variable, semanal/mensual/anual y temporada de vigencia.
- Para jugadores ficticios sin salario real, usar Transfermarkt únicamente como referencia comparativa de futbolistas semejantes. Cualquier cifra creada por Fútbol Nova será una estimación interna explícita, con comparables, ajustes y nivel de confianza; nunca se atribuirá a Transfermarkt.
- El valor de mercado y el salario son variables independientes. No usar una conversión automática entre ambos.

El registro salarial debe guardar, cuando existan: importe, moneda, periodicidad, bruto/neto (si se conoce), temporada o vigencia, tipo de dato (confirmado/estimado), fuente, URL, fecha de consulta, comparables, confianza y limitaciones.
