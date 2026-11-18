# Economía, valoraciones y contratos comerciales — Fútbol Nova

## Transfermarkt como referencia
Transfermarkt define sus valores como estimaciones de valor esperado de mercado, no como el precio real que necesariamente se paga por un traspaso. Su metodología considera edad, perspectivas, rendimiento de club y selección, nivel deportivo y financiero de la liga, potencial, reputación, experiencia, lesiones, marketing, demanda, situación contractual y condiciones de mercado. También distingue el valor de mercado del precio final de transferencia.

Fútbol Nova usará ese marco como referencia de diseño, no copiará valores de Transfermarkt ni presentará las estimaciones de jugadores ficticios como datos de esa web. Solo se importarán valores reales cuando exista una base legal/licencia adecuada y se registre procedencia, fecha y moneda.

## Valoración dentro del juego
Cada futbolista tendrá:
- valor de mercado estimado;
- precio de traspaso negociado separado;
- salario y primas separados;
- años de contrato y cláusulas;
- historial de evolución del valor y fecha de actualización;
- nivel de confianza de la estimación.

La valoración tendrá en cuenta edad, posición, nivel general, potencial, rendimiento, minutos, lesiones, división, fuerza del club, reputación internacional, contrato, demanda y capacidad financiera de comprador/vendedor. Las posiciones tienen ajustes diferentes. Las actualizaciones se harán al cierre de temporada, a mitad de temporada y por eventos importantes.

Los parámetros iniciales se guardan en data/club_commercial_economy.json y son valores de balance del juego, no tasaciones reales. Se deben calibrar con pruebas económicas y evitar inflación o deflación descontrolada.

## Precios del resto de activos
Transfermarkt no proporciona una metodología de tasación para cada activo económico del juego. Por tanto:
- clubes: ingresos, deuda, activos, reputación, afición y rendimiento;
- estadios: capacidad, estado, coste de reposición y ubicación;
- entrenadores y personal: reputación, experiencia, salario y duración contractual;
- patrocinadores: alcance, audiencia, división, rendimiento y exclusividad;
- equipaciones: fabricación, distribución, derechos comerciales y demanda;
- entradas: demanda local, rival, competición, capacidad y poder adquisitivo simulado;
- instalaciones/canteras: inversión, mantenimiento y retorno deportivo esperado.

Estas son estimaciones propias de simulación y deben identificarse como tales.

## Tercera equipación mediante contrato comercial
Todos los clubes de Primera División pueden optar a una tercera equipación, pero no la reciben automáticamente. Se desbloquea para una temporada cuando:
1. existe contrato comercial activo con un patrocinador, proveedor o socio de equipamiento;
2. el contrato cubre explícitamente la producción y uso de la tercera equipación;
3. se han aprobado los derechos de diseño y de las marcas visibles;
4. el diseño es original o está autorizado;
5. se han cumplido los requisitos de inscripción de la competición.

El contrato guarda socio, temporadas, valor anual, presupuesto de producción, derechos de diseño y marca, estado y aprobación. Al expirar, el equipo no puede seleccionar esa tercera equipación en temporadas futuras, pero se conserva en el historial de uniformes.

La tercera equipación debe resolver conflictos de color, ofrecer una alternativa comercial y no ser simplemente un duplicado de local/visitante. Los clubes de Segunda y Tercera no tienen acceso inicial a este desbloqueo; se podrá ampliar mediante reglas de competición y ascenso en futuras versiones.

## Implementación técnica
ClubCommercialService:
- can_use_third_kit(club, season)
- get_available_kits(club, season)
- estimate_player_market_value_eur(player, division_level)
- estimate_transfer_fee_eur(market_value_eur, negotiation_factor)

La lógica se debe conectar al selector de equipaciones, contratos del modo Manager, presupuesto del club y mercado de transferencias. La mera existencia del campo de tercera equipación no equivale a integración funcional en Godot.

## Estado (14-11-2026)
- Política económica: documentada.
- Parámetros iniciales: incorporados en JSON.
- Servicio económico: creado con desbloqueo de tercera equipación y estimadores para jugadores, traspasos, salarios, clubes, entradas, patrocinios, equipaciones, estadios e instalaciones.
- 16 clubes de Primera cubana: campos de contrato y tercera equipación bloqueada incorporados.
- 704 futbolistas almacenados de Segunda y Tercera: estimaciones iniciales añadidas a sus registros.
- 352 futbolistas de Primera: el generador asigna estimación al crearlos.
- Importador de clubes y servicio de datos: conservan contratos y exponen equipaciones disponibles.
- Pruebas automatizadas: se añadieron casos; los últimos workflows no llegaron a ejecutar pasos de runner (job sin runner asignado), por lo que no hay resultado PASS verificable.
- Integración visual del selector, negociación de patrocinadores, presupuesto real de contratos y balance de economía por temporada: pendientes de ejecución y validación en Godot.
