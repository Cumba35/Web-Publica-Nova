# Competiciones internacionales de clubes — Fútbol Nova

## Alcance mundial
El catálogo `data/international_club_competitions.json` reúne las competiciones de clubes de las seis confederaciones reconocidas por FIFA y torneos intercontinentales. Es un módulo separado de los torneos de selecciones.

## Competiciones americanas
- Liga de Campeones del Caribe (fundación registrada: 2020).
- Liga de Campeones de Sudamérica (fundación registrada: 2020).
- Liga de Campeones de Norteamérica y Centroamérica (fundación registrada: 2020).
- Torneo Americano de Supercampeones (TAS; fundación registrada: 2021 y dependiente de las tres ligas regionales).

## Otras regiones y torneos globales
- **Europa / UEFA:** UEFA Champions League, UEFA Europa League y UEFA Conference League.
- **África / CAF:** CAF Champions League y CAF Confederation Cup.
- **Asia / AFC:** AFC Champions League Elite, AFC Champions League Two y AFC Challenge League.
- **Oceanía / OFC:** OFC Champions League.
- **Intercontinentales / FIFA:** FIFA Intercontinental Cup y FIFA Club World Cup.

## Módulos independientes
El índice `modules/continental_competitions/module_registry.json` registra módulos para las ligas americanas y TAS, además de módulos agrupados para Europa, África, Asia, Oceanía y torneos globales. Cada manifiesto enumera los IDs de competiciones que administra.

## Reglas
1. Todos los participantes deben usar IDs del registro global de clubes.
2. Las plazas se asignan a partir de resultados finales verificados de ligas y copas nacionales y de competiciones continentales.
3. Un club no puede ocupar dos plazas en una misma edición de la misma competición.
4. Cada edición debe guardar temporada, participantes, sorteo, calendario, resultados, clasificación/llaves, campeón e historial.
5. Los partidos deben pasar por el resolvedor compartido y persistencia de temporada.
6. La ceremonia audiovisual común presenta los sorteos ya resueltos; saltarla no cambia el resultado.
7. El formato, número de plazas, fechas y criterios de cada edición deben auditarse contra los reglamentos oficiales de esa temporada. El catálogo no fija plazas ni calendarios que no hayan sido verificados.

## Estado de implementación
**Registrado:** 15 competiciones, cinco módulos globales nuevos y presentación en el navegador de Ligas y Copas.

**Pendiente de jugabilidad:** motores específicos por confederación, asignación de plazas a partir de las ligas reales, calendarios oficiales por temporada, validación de plantillas y conexión completa de fixtures/resultados. Por tanto, las nuevas competiciones globales se muestran como entradas de catálogo y no como torneos ya jugables.

## Referencias de reglamentos
- UEFA lista sus competiciones de clubes y documenta la fase liga común de 36 equipos para Champions, Europa y Conference: https://www.uefa.com/running-competitions/our-competitions/clubs/ y https://www.uefa.com/uefachampionsleague/news/02a8-216eb10b789e-0768c05cf31b-1000--champions-league-europa-league-and-conference-league-leag/
- FIFA reconoce seis confederaciones continentales: AFC, CAF, Concacaf, CONMEBOL, OFC y UEFA.
