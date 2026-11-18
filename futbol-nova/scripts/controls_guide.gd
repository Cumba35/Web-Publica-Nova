extends CanvasLayer
## Guía global de controles. Se registra como Autoload para estar disponible en todos los modos.

var guide_button: Button
var overlay: Control
var guide_panel: PanelContainer
var content_box: VBoxContainer

func _ready() -> void:
	layer = 100
	_build_guide_button()
	_build_overlay()
	_build_guide_content()

func _build_guide_button() -> void:
	guide_button = Button.new()
	guide_button.name = "ControlsGuideButton"
	guide_button.text = "GUÍA"
	guide_button.tooltip_text = "Consultar botones, gestos y combinaciones"
	guide_button.anchor_left = 1.0
	guide_button.anchor_right = 1.0
	guide_button.offset_left = -116.0
	guide_button.offset_right = -16.0
	guide_button.offset_top = 16.0
	guide_button.offset_bottom = 58.0
	guide_button.z_index = 10
	guide_button.pressed.connect(_toggle_guide)
	add_child(guide_button)

func _build_overlay() -> void:
	overlay = Control.new()
	overlay.name = "ControlsGuideOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.015, 0.025, 0.055, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dim)

	guide_panel = PanelContainer.new()
	guide_panel.name = "GuidePanel"
	guide_panel.anchor_left = 0.035
	guide_panel.anchor_top = 0.045
	guide_panel.anchor_right = 0.965
	guide_panel.anchor_bottom = 0.955
	guide_panel.offset_left = 0.0
	guide_panel.offset_top = 0.0
	guide_panel.offset_right = 0.0
	guide_panel.offset_bottom = 0.0
	guide_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(guide_panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	guide_panel.add_child(outer)

	var header := HBoxContainer.new()
	outer.add_child(header)
	var title := Label.new()
	title.text = "GUÍA DE BOTONES Y GESTOS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "CERRAR"
	close_button.pressed.connect(_toggle_guide)
	header.add_child(close_button)

	var subtitle := Label.new()
	subtitle.text = "Consulta los controles y aprende qué hace cada combinación. Disponible desde cualquier modo. Algunas acciones se habilitarán a medida que se complete su integración en cada modo."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outer.add_child(subtitle)

	var scroll := ScrollContainer.new()
	scroll.name = "GuideScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(scroll)
	content_box = VBoxContainer.new()
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_box.add_theme_constant_override("separation", 8)
	scroll.add_child(content_box)

func _build_guide_content() -> void:
	_add_section("1. MOVIMIENTO")
	_add_entry("Joystick izquierdo", "Inclina poco para caminar y aumenta la inclinación para correr. La velocidad real depende de velocidad, aceleración, resistencia y fatiga. La diagonal no debe dar más velocidad que la línea recta.")

	_add_section("2. BOTÓN DE HABILIDADES Y REGATES")
	_add_entry("Toque o mantener — Auto pase", "Empuja el balón hacia delante y corre para alcanzarlo. Requiere Regate 25 y Control 30. Úsalo cuando tengas espacio libre delante.")
	_add_entry("Deslizar arriba — Sombrerito", "Levanta el balón por encima del rival e intenta continuar la jugada. Requiere Regate 58, Control 55 y Agilidad 48. El rival puede anticiparlo.")
	_add_entry("Deslizar abajo — Hueca/caño", "Intenta pasar el balón entre las piernas del rival o arrastrarlo por su zona de apoyo. Requiere Regate 52, Control 50 y Agilidad 45.")
	_add_entry("Deslizar izquierda — Elástica", "Amaga con un cambio rápido de dirección y sale hacia el espacio. Requiere Regate 78, Control 72, Agilidad 68 y Equilibrio 60.")
	_add_entry("Deslizar derecha — Bicicleta", "Realiza una finta de bicicleta y trata de salir del marcaje. Requiere Regate 48, Control 45 y Agilidad 50.")
	_add_entry("Derecha → abajo — Marsellesa", "Gira alrededor del balón para cambiar de lado y escapar de la presión. Requiere Regate 68, Control 65, Equilibrio 58 y Agilidad 62.")
	_add_entry("Izquierda → arriba — Elástica aérea", "Ejecuta una elástica con el balón elevado. Requiere Regate 86, Control 80, Agilidad 78 y Equilibrio 70.")
	_add_entry("Izquierda → abajo — Ruleta con caño", "Combina giro de ruleta con intento de pasar el balón entre las piernas del rival. Requiere Regate 74, Control 70, Equilibrio 65 y Agilidad 68.")
	_add_entry("Arriba → derecha — Croqueta", "Pasa el balón de un pie al otro y sale en diagonal. Requiere Regate 62, Control 60, Agilidad 58 y Equilibrio 52.")
	_add_entry("Arriba → izquierda — Finta de cuerpo", "Engaña con hombros y cadera para salir al lado contrario del movimiento del defensor. Requiere Regate 40, Agilidad 48 y Equilibrio 42.")
	_add_entry("Abajo → derecha — Arrastre atrás y salida", "Arrastra el balón hacia atrás con la planta y sale en diagonal derecha. Requiere Regate 38, Control 45 y Equilibrio 42.")
	_add_entry("Abajo → izquierda — Giro de protección", "Protege el balón con el cuerpo, gira y sale hacia la izquierda. Requiere Regate 45, Control 42, Equilibrio 55 y Fuerza 52.")
	_add_entry("Derecha → arriba — Amago de disparo", "Simula un disparo, cancela el golpeo y conduce hacia delante. Requiere Regate 43, Control 45 y Compostura 40.")

	_add_section("3. CÍRCULO — HABILIDAD AVANZADA")
	_add_entry("Cómo hacerlo", "Dibuja un círculo cerrado alrededor del botón de habilidades. El juego sortea una habilidad al azar entre las equipadas que cumplan sus requisitos y tengan el enfriamiento disponible.")
	_add_entry("Límite", "Cada futbolista puede activar como máximo 3 habilidades avanzadas por partido. El límite es individual y compartido entre sus habilidades equipadas; se reinicia al comenzar otro partido. Si no hay una habilidad válida, no se consume un uso.")
	_add_entry("Espacios por nivel general", "Menos de 70: 0 espacios. De 70 a 79: 1. De 80 a 90: 2. De 91 a 99: 3. Requisitos por estrellas: 1–2 estrellas desde 70; 3–4 desde 80; 5 estrellas desde 90.")

	_add_section("4. BOTÓN DE DISPARO")
	_add_entry("Toque o mantener", "Carga un disparo. Cuanto más mantengas, más potencia; al llegar al máximo se dispara automáticamente. La potencia alta reduce la precisión.")
	_add_entry("Deslizar izquierda o derecha", "Intenta un recorte hacia ese lado y dispara automáticamente al terminar. La carga previa determina la potencia del disparo.")
	_add_entry("Deslizar arriba", "Disparo picado: intenta elevar el balón por encima del portero. La precisión y la altura dependen de la técnica, postura, distancia y situación.")

	_add_section("5. BOTÓN DE PASE")
	_add_entry("Toque o mantener", "Pase raso cargado. Más tiempo aumenta la potencia y puede reducir la precisión.")
	_add_entry("Deslizar arriba", "Pase elevado. La carga determina el alcance y la potencia.")
	_add_entry("Deslizar izquierda o derecha", "Intenta un recorte hacia ese lado y después realiza un pase raso.")
	_add_entry("Deslizar abajo", "Pase atrás de tacón. Depende de orientación corporal, control y posición del compañero.")

	_add_section("6. BOTÓN DE PRESIÓN")
	_add_entry("Toque", "El jugador controlado presiona al rival con balón. No garantiza robarlo.")
	_add_entry("Mantener y deslizar arriba durante 1 segundo", "Solicita ayuda al compañero cercano mejor situado para cerrar o presionar. La ayuda depende de distancia, resistencia y posición táctica.")

	_add_section("7. CÓMO SE RESUELVEN LAS TÉCNICAS")
	_add_entry("Atributos mínimos", "Todos los mínimos indicados deben cumplirse para intentar la técnica. Están en escala de 1 a 99 y no se sustituyen por el nivel general ni por la nacionalidad.")
	_add_entry("El resultado no está garantizado", "Cumplir los mínimos permite intentar el movimiento, pero no asegura superar al defensor. También influyen fatiga, pierna hábil, postura, espacio, control del balón y respuesta del rival. Un fallo puede terminar en toque largo, bloqueo o pérdida de balón.")
	_add_entry("Combos", "Realiza las direcciones en el orden mostrado y completa la secuencia. Si cambias el orden, interrumpes el gesto o pierdes el control del balón, la combinación puede cancelarse.")

func _add_section(heading: String) -> void:
	var label := Label.new()
	label.text = heading
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.45, 0.82, 1.0))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_box.add_child(label)

func _add_entry(name: String, explanation: String) -> void:
	var label := Label.new()
	label.text = "• " + name + ": " + explanation
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 14)
	content_box.add_child(label)

func _toggle_guide() -> void:
	overlay.visible = not overlay.visible
	guide_button.visible = not overlay.visible
