extends CanvasLayer

signal training_mode_selected(mode_id: String)
signal match_11v11_requested
signal catalog_requested

const PANEL := Color("#12291d")
const PANEL_ALT := Color("#1b3827")
const LIME := Color("#c8f45a")
const MUTED := Color("#a8b7aa")
const WHITE := Color("#f4f7ef")
const TAS_SEASON_ID := "2027"
const MAIN_PAGES := ["home", "online", "modes", "settings"]
const DOWNLOAD_ICON := "⬇"
const SETTINGS_CATEGORIES := ["Edición", "Módulos", "Música", "Juego", "Datos", "Controles", "Audio", "Gráficos", "Accesibilidad", "Administración", "Información"]
const DRAW_CEREMONY_SCRIPT := preload("res://scripts/ui/competition_draw_ceremony.gd")
const INTERNATIONAL_COMPETITIONS_PATH := "res://data/international_club_competitions.json"

var root: Control
var content_box: VBoxContainer
var page_title: Label
var page_subtitle: Label
var status_label: Label
var page_indicator: Label
var back_navigation_button: Button
var next_navigation_button: Button
var current_page := "home"
var current_subpage := ""
var controller_status := {"enabled": false, "connected_count": 0, "devices": [], "profile": "Mando estándar"}
var touch_start := Vector2.ZERO
var touch_tracking := false
var touch_started_on_control := false
var legend_catalog_players: Array = []
var legend_catalog_list: VBoxContainer
var legend_catalog_search_input: LineEdit
var legend_catalog_position_filter: OptionButton
var legend_catalog_limit := 40
var legend_catalog_selected_player: Dictionary = {}
var legend_catalog_confirmation: ConfirmationDialog
var legend_owner_login_dialog: ConfirmationDialog
var legend_owner_email_input: LineEdit
var legend_owner_password_input: LineEdit
var legend_owner_login_status: Label
var active_draw_ceremony: NovaCompetitionDrawCeremony

func _ready() -> void:
	_build_shell()
	if not FootballData.draw_ceremony_requested.is_connected(_on_draw_ceremony_requested):
		FootballData.draw_ceremony_requested.connect(_on_draw_ceremony_requested)
	_show_home()

func _build_shell() -> void:
	root = Control.new()
	root.name = "GameHub"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)

	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.045, 0.028, 0.94)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var compact_layout := get_viewport().get_visible_rect().size.x < 700.0
	var horizontal_margin := 12 if compact_layout else 28
	var vertical_margin := 12 if compact_layout else 18
	margin.add_theme_constant_override("margin_left", horizontal_margin)
	margin.add_theme_constant_override("margin_right", horizontal_margin)
	margin.add_theme_constant_override("margin_top", vertical_margin)
	margin.add_theme_constant_override("margin_bottom", vertical_margin)
	root.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	layout.add_child(top)
	var brand := Label.new()
	brand.text = "NOVA  /  FÚTBOL"
	brand.add_theme_font_size_override("font_size", 22)
	brand.add_theme_color_override("font_color", LIME)
	top.add_child(brand)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	var nav := HFlowContainer.new()
	nav.add_theme_constant_override("h_separation", 8)
	nav.add_theme_constant_override("v_separation", 6)
	layout.add_child(nav)
	_add_main_nav(nav, "INICIO", "home")
	_add_main_nav(nav, DOWNLOAD_ICON + " ONLINE", "online")
	_add_main_nav(nav, DOWNLOAD_ICON + " MODOS", "modes")
	_add_main_nav(nav, "CONFIGURACIÓN", "settings")

	var separator := ColorRect.new()
	separator.custom_minimum_size.y = 2
	separator.color = Color(0.78, 0.96, 0.35, 0.8)
	layout.add_child(separator)

	page_title = Label.new()
	page_title.add_theme_font_size_override("font_size", 32)
	page_title.add_theme_color_override("font_color", WHITE)
	layout.add_child(page_title)
	page_subtitle = Label.new()
	page_subtitle.add_theme_font_size_override("font_size", 14)
	page_subtitle.add_theme_color_override("font_color", MUTED)
	layout.add_child(page_subtitle)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	content_box = VBoxContainer.new()
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_box.add_theme_constant_override("separation", 12)
	scroll.add_child(content_box)

	status_label = Label.new()
	status_label.custom_minimum_size.y = 22
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", MUTED)
	layout.add_child(status_label)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	layout.add_child(footer)

	back_navigation_button = _nav_button("ATRÁS")
	back_navigation_button.custom_minimum_size = Vector2(104, 44)
	back_navigation_button.pressed.connect(_navigate_back)
	footer.add_child(back_navigation_button)

	var footer_spacer_left := Control.new()
	footer_spacer_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer_left)

	page_indicator = Label.new()
	page_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	page_indicator.add_theme_color_override("font_color", LIME)
	page_indicator.add_theme_font_size_override("font_size", 13)
	footer.add_child(page_indicator)

	var footer_spacer_right := Control.new()
	footer_spacer_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer_right)

	next_navigation_button = _nav_button("SIGUIENTE")
	next_navigation_button.custom_minimum_size = Vector2(116, 44)
	next_navigation_button.pressed.connect(_navigate_next)
	footer.add_child(next_navigation_button)

func _add_main_nav(parent: Container, caption: String, page: String) -> void:
	var compact_layout := get_viewport().get_visible_rect().size.x < 700.0
	var button := _nav_button(caption)
	button.custom_minimum_size.x = 70 if compact_layout else 112
	button.add_theme_font_size_override("font_size", 10 if compact_layout else 13)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_open_main_page.bind(page))
	parent.add_child(button)

func _nav_button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(112, 40)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = PANEL_ALT
	normal.set_corner_radius_all(11)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("#2b4c32")
	button.add_theme_stylebox_override("hover", hover)
	return button

func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color(0.55, 0.78, 0.24, 0.75)
	style.set_border_width_all(1)
	style.set_corner_radius_all(15)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _clear_content() -> void:
	for child in content_box.get_children():
		child.queue_free()

func _update_header(title_text: String, subtitle_text: String) -> void:
	page_title.text = title_text
	page_subtitle.text = subtitle_text
	var page_names := ["INICIO", "ONLINE", "MODOS", "CONFIGURACIÓN"]
	var index := MAIN_PAGES.find(current_page)
	var compact_layout := get_viewport().get_visible_rect().size.x < 700.0
	if index >= 0:
		page_indicator.text = "%d/4 • %s" % [index + 1, page_names[index]] if compact_layout else "PANTALLA %d DE 4   •   %s" % [index + 1, page_names[index]]
	else:
		page_indicator.text = "SUBMENÚ"
	page_indicator.add_theme_font_size_override("font_size", 11 if compact_layout else 13)
	if back_navigation_button != null:
		back_navigation_button.disabled = current_page == "home" and current_subpage.is_empty()
	if next_navigation_button != null:
		next_navigation_button.disabled = false

func _open_main_page(page: String) -> void:
	current_page = page
	current_subpage = ""
	match page:
		"home": _show_home()
		"online": _show_online()
		"modes": _show_modes()
		"settings": _show_settings()

func _show_home() -> void:
	current_page = "home"
	current_subpage = ""
	_clear_content()
	_update_header("INICIO", "Juego base • Amistosos, ayuda y ajustes.")

	var welcome := _make_panel()
	content_box.add_child(welcome)
	var welcome_column := VBoxContainer.new()
	welcome_column.add_theme_constant_override("separation", 8)
	welcome.add_child(welcome_column)
	welcome_column.add_child(_label("FÚTBOL NOVA", 24, LIME))
	welcome_column.add_child(_label("La instalación base incluye partidos amistosos locales, ayuda y configuración general. Los demás modos se instalan como módulos independientes.", 14, MUTED))

	var friendly := _make_panel()
	content_box.add_child(friendly)
	var friendly_column := VBoxContainer.new()
	friendly_column.add_theme_constant_override("separation", 9)
	friendly.add_child(friendly_column)
	friendly_column.add_child(_label("PARTIDO AMISTOSO", 21, WHITE))
	var description := _label("Juega un amistoso local 11 contra 11. Configura la duración y las reglas disponibles antes del saque inicial.", 13, MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	friendly_column.add_child(description)
	var friendly_button := _nav_button("JUGAR AMISTOSO")
	friendly_button.custom_minimum_size.y = 48
	friendly_button.pressed.connect(func(): match_11v11_requested.emit())
	friendly_column.add_child(friendly_button)

	var help_panel := _make_panel()
	content_box.add_child(help_panel)
	var help_column := VBoxContainer.new()
	help_column.add_theme_constant_override("separation", 8)
	help_panel.add_child(help_column)
	help_column.add_child(_label("AYUDA", 19, WHITE))
	help_column.add_child(_label("Controles, reglas básicas, configuración de partido y guía para instalar módulos.", 13, MUTED))
	var help_button := _nav_button("ABRIR AYUDA")
	help_button.pressed.connect(_show_help)
	help_column.add_child(help_button)

	status_label.text = "Juego base listo • Partido amistoso local"
	_focus_first_action(friendly)


func _show_help() -> void:
	current_page = "home"
	current_subpage = "help"
	_clear_content()
	_update_header("AYUDA", "Guía del juego base Fútbol Nova.")
	_add_info_card("QUÉ INCLUYE EL JUEGO BASE", "Partidos amistosos locales, ayuda y ajustes generales. Los modos de carrera, competiciones y juego online no forman parte de la instalación base.")
	_add_info_card("CONTROLES EN ANDROID", "Usa el joystick táctil izquierdo para moverte. Los botones de acción permiten pasar, disparar y presionar. Mantén y desliza el control de habilidades para ejecutar gestos cuando estén disponibles.")
	_add_info_card("CONTROLES EN PC", "W, A, S y D: movimiento. F: pase. ESPACIO: disparo. G: presión. ESC: abrir o regresar al menú.")
	_add_info_card("PARTIDOS AMISTOSOS", "Desde Inicio puedes preparar un amistoso local. Antes del partido puedes elegir la duración de cada tiempo, el comportamiento del reloj y la prórroga. La tanda de penaltis sigue en desarrollo y todavía no se puede jugar.")
	_add_info_card("MÓDULOS DESCARGABLES", "Online, Modo Leyenda, Modo Entrenador, ligas, copas, torneos de selecciones y otros contenidos se instalan por separado desde Configuración > Módulos.")
	_add_info_card("INSTALACIÓN Y SEGURIDAD", "Descarga únicamente módulos publicados y compatibles con tu versión del juego. Cada paquete debe verificarse antes de instalarse.")
	status_label.text = "Ayuda del juego base"


func _claim_daily_reward() -> void:
	var result: Dictionary = MomentsService.claim_reward()
	status_label.text = "Recompensa añadida: %d puntos NOVA" % int(result.get("reward", 0)) if bool(result.get("ok", false)) else str(result.get("error", "No se pudo reclamar."))
	_show_home()

func _add_home_action(parent: VBoxContainer, caption: String, explanation: String, available: bool) -> void:
	var button := _nav_button(caption)
	button.disabled = not available
	button.tooltip_text = explanation
	parent.add_child(button)
	if not available:
		var note := _label(explanation, 12, MUTED)
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		parent.add_child(note)

func _show_online() -> void:
	current_page = "online"
	current_subpage = ""
	_clear_content()
	_update_header("ONLINE", "Módulo descargable • No forma parte del juego base.")
	_add_info_card(DOWNLOAD_ICON + " MULTIJUGADOR ONLINE", "Las partidas online, las salas, el emparejamiento, la sincronización y la selección de futbolistas requieren instalar el módulo Online. El juego base no incluye servicios de red.")
	_add_info_card("ESTADO DEL MÓDULO", "El módulo se mostrará como disponible únicamente cuando su paquete esté publicado, validado y sea compatible con esta versión.")
	var download := _nav_button(DOWNLOAD_ICON + " VER MÓDULOS DESCARGABLES")
	download.custom_minimum_size.y = 48
	download.pressed.connect(_request_catalog)
	content_box.add_child(download)
	status_label.text = "Online • Instalación opcional e independiente"


func _select_custom_player_for_online(player_id: String) -> void:
	var result: Dictionary = CustomPlayerRoster.select_for_online(player_id)
	status_label.text = "Jugador seleccionado para Online." if bool(result.get("ok", false)) else str(result.get("error", "No se pudo seleccionar el jugador."))
	_show_online()

func _clear_online_custom_player_selection() -> void:
	CustomPlayerRoster.clear_online_selection()
	_show_online()

func _show_modes() -> void:
	current_page = "modes"
	current_subpage = ""
	_clear_content()
	_update_header("MODOS", "Contenido adicional • Cada modo requiere su módulo.")
	_add_mode_card("ONLINE", "Partidas multijugador, salas y juego entre dispositivos.", "Módulo independiente • No incluido en el juego base.", "online")
	_add_mode_card("MODO LEYENDA", "Crea un futbolista y desarrolla su carrera hasta la retirada.", "Módulo independiente • No incluido en el juego base.", "legend")
	_add_mode_card("MODO ENTRENADOR", "Dirige un club, gestiona la plantilla y compite por temporadas.", "Módulo independiente • No incluido en el juego base.", "manager")
	_add_mode_card("LIGAS Y COPAS", "Competiciones nacionales, continentales e internacionales de clubes.", "Módulo independiente • No incluido en el juego base.", "leagues")
	_add_mode_card("TORNEOS DE SELECCIONES", "Copa Mundial, campeonatos continentales y clasificatorias.", "Módulo independiente • No incluido en el juego base.", "national_tournaments")
	_add_mode_card("TAS", "Torneo Americano de Supercampeones y sus competiciones clasificatorias.", "Módulo independiente • No incluido en el juego base.", "tas")
	_add_mode_card("CENTRO DE ENTRENAMIENTO", "Tutorial, tiros libres, penaltis y práctica libre.", "Módulo independiente • No incluido en el juego base.", "training")
	var catalog := _nav_button("ABRIR CATÁLOGO DE MÓDULOS")
	catalog.custom_minimum_size.y = 48
	catalog.pressed.connect(_request_catalog)
	content_box.add_child(catalog)
	status_label.text = "Los modos adicionales no se activan hasta instalar sus módulos."


func _add_mode_card(caption: String, description: String, state: String, _mode_id: String) -> void:
	var panel := _make_panel()
	content_box.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(copy)
	copy.add_child(_label(DOWNLOAD_ICON + "  " + caption, 19, WHITE))
	var detail := _label(description + "\n" + state, 13, MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(detail)
	var button := _nav_button(DOWNLOAD_ICON + " VER MÓDULO")
	button.pressed.connect(_request_catalog)
	row.add_child(button)


func _request_catalog() -> void:
	catalog_requested.emit()

func _continue_game() -> void:
	if ManagerCareer.load_career():
		_open_manager_career()
	elif LegendCareer.load_career():
		_open_legend_career()
	else:
		_show_new_game_menu()

func _show_new_game_menu() -> void:
	current_page = "home"
	current_subpage = "new_game"
	_clear_content()
	_update_header("NUEVA PARTIDA", "Elige un modo. Si ya existe una carrera guardada, se abrirá para no sobrescribirla.")
	_add_legend_entry_option("MODO ENTRENADOR", "Elige uno de los 725 clubes del juego base y dirige sus temporadas.", _open_manager_career)
	_add_legend_entry_option("MODO LEYENDA", "Crea tu propio futbolista o selecciona uno del catálogo.", _open_legend_career)
	var back := _nav_button("VOLVER A INICIO")
	back.pressed.connect(_show_home)
	content_box.add_child(back)
	status_label.text = "Las carreras se guardan localmente en este dispositivo."

func _start_3d_test_match() -> void:
	training_mode_selected.emit("free_practice")
	root.visible = false

func _show_league_browser() -> void:
	current_page = "modes"
	current_subpage = "league_browser"
	_clear_content()
	_update_header("LIGAS Y COPAS", "Competiciones locales disponibles para jugar y simular sin conexión.")
	if FootballData.registry == null or FootballData.registry.competitions_by_id.is_empty():
		_add_info_card("CATÁLOGO NO DISPONIBLE", "No se pudo inicializar la base de datos deportiva.")
		_add_settings_back_button()
		return
	var competition_ids: Array = FootballData.registry.competitions_by_id.keys()
	competition_ids.sort()
	for competition_id in competition_ids:
		var competition: Dictionary = FootballData.registry.competitions_by_id[competition_id]
		var team_count := int(competition.get("team_ids", []).size())
		var title_text := str(competition.get("name", competition.get("short_name", competition_id)))
		var country := str(competition.get("country_name", _country_display_name(str(competition.get("country_code", competition.get("country_id", ""))))))
		var panel := _make_panel()
		content_box.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		panel.add_child(row)
		var copy := VBoxContainer.new()
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.add_child(_label(title_text, 16, WHITE))
		copy.add_child(_label("%s • %d clubes" % [country, team_count], 12, MUTED))
		row.add_child(copy)
		var open_button := _nav_button("VER")
		open_button.custom_minimum_size.x = 88
		open_button.pressed.connect(_show_competition_detail.bind(str(competition_id)))
		row.add_child(open_button)
	_add_continental_competition_cards()
	var downloads := _nav_button("CATÁLOGO DE CONTENIDO DESCARGABLE")
	downloads.pressed.connect(_request_catalog)
	content_box.add_child(downloads)
	_add_settings_back_button()
	status_label.text = "%d competiciones cargadas" % competition_ids.size()

func _add_continental_competition_cards() -> void:
	var file := FileAccess.open(INTERNATIONAL_COMPETITIONS_PATH, FileAccess.READ)
	if file == null:
		_add_info_card("COMPETICIONES INTERNACIONALES", "No se pudo cargar el catálogo mundial de clubes.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		_add_info_card("COMPETICIONES INTERNACIONALES", "El catálogo mundial de clubes no tiene un formato válido.")
		return
	var region_names := {
		"caribbean_cfu": "CARIBE",
		"south_america": "SUDAMÉRICA",
		"north_and_central_america": "NORTE, CENTROAMÉRICA Y CARIBE",
		"americas": "AMÉRICA · TORNEO INTERREGIONAL",
		"europe": "EUROPA · UEFA",
		"africa": "ÁFRICA · CAF",
		"asia": "ASIA · AFC",
		"oceania": "OCEANÍA · OFC",
		"global": "INTERCONTINENTALES Y MUNDIALES"
	}
	var region_order := ["caribbean_cfu", "south_america", "north_and_central_america", "americas", "europe", "africa", "asia", "oceania", "global"]
	var grouped := {}
	for raw in parsed.get("competitions", []):
		if not raw is Dictionary:
			continue
		var item: Dictionary = raw
		var region := str(item.get("region", "global"))
		if not grouped.has(region):
			grouped[region] = []
		grouped[region].append(item)
	for region in region_order:
		if not grouped.has(region):
			continue
		var section := _make_panel()
		content_box.add_child(section)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 7)
		section.add_child(column)
		column.add_child(_label(str(region_names.get(region, region.to_upper())), 18, LIME))
		for item in grouped[region]:
			var name := str(item.get("name", item.get("id", "Competición")))
			var status := str(item.get("runtime_status", ""))
			var founding_year := int(item.get("founding_year", 0))
			var detail := "Fundada en %d" % founding_year if founding_year > 0 else "Año de fundación por verificar"
			if status != "":
				detail += " · " + ("Motor pendiente" if status.contains("pending") else "Catálogo registrado")
			column.add_child(_label(name, 14, WHITE))
			var sub := _label(detail, 11, MUTED)
			sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			column.add_child(sub)

func _show_national_team_tournaments() -> void:
	current_page = "modes"
	current_subpage = "national_tournaments"
	_clear_content()
	_update_header("TORNEOS DE SELECCIONES", "Competiciones FIFA y de las seis confederaciones · módulo separado de clubes.")
	var competitions: Array = NationalTeamCompetitions.get_all_competitions()
	if competitions.is_empty():
		_add_info_card("CATÁLOGO NO DISPONIBLE", "No se pudo cargar el módulo de torneos de selecciones.")
	else:
		var groups := {"FIFA": [], "UEFA": [], "CONMEBOL": [], "CONCACAF": [], "CAF": [], "AFC": [], "OFC": []}
		for competition in competitions:
			for confederation in competition.get("confederations", []):
				var key := str(confederation)
				if groups.has(key):
					groups[key].append(competition)
		for confederation in ["FIFA", "UEFA", "CONMEBOL", "CONCACAF", "CAF", "AFC", "OFC"]:
			var entries: Array = groups[confederation]
			if entries.is_empty():
				continue
			var panel := _make_panel()
			content_box.add_child(panel)
			var column := VBoxContainer.new()
			column.add_theme_constant_override("separation", 6)
			panel.add_child(column)
			column.add_child(_label("TORNEOS " + confederation, 17, LIME))
			for competition in entries:
				column.add_child(_label(str(competition.get("name", competition.get("id", ""))), 14, WHITE))
				var note := _label("Formato: %s · Plantillas y motor de partidos pendientes" % str(competition.get("format", "por definir")).replace("_", " "), 11, MUTED)
				note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				column.add_child(note)
	_add_info_card("REQUISITOS PARA JUGAR", "Las selecciones y sus jugadores deben proceder de paquetes oficiales verificados. El directorio de asociaciones no crea plantillas ni concede elegibilidad automáticamente.")
	_add_settings_back_button()
	status_label.text = "%d torneos registrados · jugabilidad pendiente de plantillas verificadas" % competitions.size()

func _on_draw_ceremony_requested(competition_name: String, resolved_draw: Array) -> void:
	present_competition_draw(competition_name, resolved_draw)

func present_competition_draw(competition_name: String, resolved_draw: Array) -> void:
	if active_draw_ceremony != null and is_instance_valid(active_draw_ceremony):
		if active_draw_ceremony.tree_exiting.is_connected(_on_draw_ceremony_exiting):
			active_draw_ceremony.tree_exiting.disconnect(_on_draw_ceremony_exiting)
		active_draw_ceremony.queue_free()
	active_draw_ceremony = DRAW_CEREMONY_SCRIPT.new() as NovaCompetitionDrawCeremony
	root.visible = true
	root.add_child(active_draw_ceremony)
	active_draw_ceremony.ceremony_finished.connect(_on_competition_draw_finished)
	active_draw_ceremony.tree_exiting.connect(_on_draw_ceremony_exiting)
	var presentation: Array = []
	for raw_entry in resolved_draw:
		if not raw_entry is Dictionary:
			presentation.append({"team_name": str(raw_entry)})
			continue
		var entry: Dictionary = raw_entry.duplicate(true)
		var team_id := str(entry.get("team_id", ""))
		if str(entry.get("team_name", "")).is_empty():
			var team: Dictionary = {}
			if FootballData.registry != null:
				team = FootballData.registry.teams_by_id.get(team_id, {})
			entry["team_name"] = str(team.get("name", team.get("short_name", team_id)))
		var opponent_id := str(entry.get("opponent_team_id", ""))
		if not opponent_id.is_empty() and str(entry.get("destination", "")).is_empty():
			var opponent: Dictionary = {}
			if FootballData.registry != null:
				opponent = FootballData.registry.teams_by_id.get(opponent_id, {})
			entry["destination"] = "vs " + str(opponent.get("name", opponent.get("short_name", opponent_id)))
		presentation.append(entry)
	active_draw_ceremony.present_draw(competition_name, presentation)

func present_edition_draw(competition_name: String, edition: Dictionary) -> void:
	var draw_presentation: Array = edition.get("draw_presentation", [])
	present_competition_draw(competition_name, draw_presentation)

func _on_competition_draw_finished(_resolved_draw: Array) -> void:
	status_label.text = "Sorteo completado · resultado oficial conservado"

func _on_draw_ceremony_exiting() -> void:
	active_draw_ceremony = null

func _country_display_name(country_code: String) -> String:
	match country_code.to_upper():
		"ENG", "ENGLAND":
			return "Inglaterra"
		"ESP", "SPAIN":
			return "España"
		"BRA", "BRAZIL":
			return "Brasil"
		"ITA", "ITALY":
			return "Italia"
		"GER", "GERMANY":
			return "Alemania"
		"FRA", "FRANCE":
			return "Francia"
		"POR", "PORTUGAL":
			return "Portugal"
		"ARG", "ARGENTINA":
			return "Argentina"
		"CUB", "CUBA":
			return "Cuba"
		"USA", "UNITED_STATES", "UNITED STATES":
			return "Estados Unidos"
		_:
			return country_code

func _show_tas_competition() -> void:
	current_page = "modes"
	current_subpage = "tas"
	_clear_content()
	_update_header("TORNEO AMERICANO DE SUPERCAMPEONES", "Edición 2027 · 13 encuentros, todos a partido único.")
	var edition: Dictionary = FootballData.get_tas_edition(TAS_SEASON_ID)
	if edition.is_empty():
		_add_info_card("EDICIÓN AÚN NO CREADA", "El motor TAS ya puede crear, guardar y avanzar una edición. Para iniciar la edición 2027 faltan los nueve clasificados oficiales: campeón, subcampeón y tercer lugar de cada una de las tres ligas regionales.")
		_add_info_card("FORMATO", "Primera fase: tres grupos de tres, una vuelta (9 partidos). Grupo final: los tres ganadores, una vuelta (3 partidos). Final: los dos primeros del grupo final (1 partido). Total: 13 partidos. Solo la final tiene prórroga y penaltis si hace falta.")
		_add_info_card("CLASIFICACIÓN", "El TAS no inventa participantes. Los clubes deben proceder de los resultados finales de las ligas de Campeones del Caribe, Sudamérica y Norteamérica y Centroamérica.")
		_add_settings_back_button()
		status_label.text = "Pendiente de clasificación regional"
		return
	var status := str(edition.get("status", ""))
	var status_names := {
		"first_phase": "Primera fase",
		"final_group": "Grupo final",
		"championship_final": "Final por el título",
		"completed": "Edición finalizada"
	}
	_add_info_card("ESTADO DE LA EDICIÓN", "%s · %d participantes · %d partidos programados" % [str(status_names.get(status, status)), int(edition.get("participant_count", 9)), int(edition.get("total_scheduled_matches", 0))])
	if status == "completed":
		var champion_id := str(edition.get("champion_team_id", ""))
		var champion: Dictionary = FootballData.registry.teams_by_id.get(champion_id, {}) if FootballData.registry != null else {}
		_add_info_card("CAMPEÓN DEL TAS", str(champion.get("name", champion.get("short_name", champion_id))))
	var stage_order := ["first_phase_group_A", "first_phase_group_B", "first_phase_group_C", "final_group", "championship_final"]
	var current_stage_complete := true
	var current_stage_ids: Array = []
	match status:
		"first_phase":
			current_stage_ids = ["first_phase_group_A", "first_phase_group_B", "first_phase_group_C"]
		"final_group":
			current_stage_ids = ["final_group"]
		"championship_final":
			current_stage_ids = ["championship_final"]
	for stage_id in stage_order:
		if not edition.get("fixtures_by_stage", {}).has(stage_id):
			continue
		var fixtures: Array = edition.fixtures_by_stage[stage_id]
		var stage_panel := _make_panel()
		content_box.add_child(stage_panel)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 6)
		stage_panel.add_child(column)
		column.add_child(_label(stage_id.replace("_", " ").to_upper(), 15, LIME))
		var table: Dictionary = edition.get("standings_by_stage", {}).get(stage_id, {})
		if not table.is_empty():
			var draw_offset := 0
			if stage_id == "first_phase_group_B":
				draw_offset = 1
			elif stage_id == "first_phase_group_C":
				draw_offset = 2
			elif stage_id == "final_group":
				draw_offset = 100
			var draw_seed := maxi(1, int(edition.get("draw_seed", 1)) + draw_offset)
			var ordered: Array = edition.get("ordered_standings_by_stage", {}).get(stage_id, []).duplicate(true)
			if ordered.is_empty():
				ordered = FootballData.get_ordered_tas_standings(table, draw_seed)
			for rank in range(ordered.size()):
				var row: Dictionary = ordered[rank]
				var team_id := str(row.get("team_id", ""))
				var team: Dictionary = FootballData.registry.teams_by_id.get(team_id, {}) if FootballData.registry != null else {}
				column.add_child(_label("%d. %s · %d pts · DG %d" % [rank + 1, str(team.get("short_name", team.get("name", team_id))), int(row.get("points", 0)), int(row.get("goal_difference", 0))], 12, WHITE))
		for fixture in fixtures:
			var home_id := str(fixture.get("home_team_id", ""))
			var away_id := str(fixture.get("away_team_id", ""))
			var home: Dictionary = FootballData.registry.teams_by_id.get(home_id, {}) if FootballData.registry != null else {}
			var away: Dictionary = FootballData.registry.teams_by_id.get(away_id, {}) if FootballData.registry != null else {}
			var line := "%s — %s" % [str(home.get("short_name", home.get("name", home_id))), str(away.get("short_name", away.get("name", away_id)))]
			if str(fixture.get("status", "scheduled")) == "finished":
				var result: Dictionary = fixture.get("result", {})
				var score: Dictionary = result.get("final_score", {})
				if score.is_empty():
					line += " · %d-%d" % [int(fixture.get("home_goals", 0)), int(fixture.get("away_goals", 0))]
				else:
					line += " · %d-%d" % [int(score.get("home", 0)), int(score.get("away", 0))]
					if bool(result.get("penalty_shootout", {}).get("played", false)):
						line += " (pen. %d-%d)" % [int(result.penalty_shootout.get("home_score", 0)), int(result.penalty_shootout.get("away_score", 0))]
				column.add_child(_label(line, 12, MUTED))
			else:
				column.add_child(_label(line + " · pendiente", 12, WHITE))
				if current_stage_ids.has(stage_id):
					current_stage_complete = false
					var play_button := _nav_button("SIMULAR PARTIDO")
					play_button.pressed.connect(_simulate_tas_fixture.bind(TAS_SEASON_ID, stage_id, fixture))
					column.add_child(play_button)
	if status in ["first_phase", "final_group", "championship_final"]:
		var advance_button := _nav_button("AVANZAR FASE")
		advance_button.disabled = not current_stage_complete
		advance_button.pressed.connect(_advance_tas_edition.bind(TAS_SEASON_ID))
		content_box.add_child(advance_button)
	_add_settings_back_button()
	status_label.text = "Edición TAS · guardado local · partidos únicos"

func _simulate_tas_fixture(season_id: String, stage_id: String, fixture: Dictionary) -> void:
	var result: Dictionary = FootballData.simulate_tas_fixture(season_id, stage_id, fixture)
	if not bool(result.get("ok", false)):
		status_label.text = str(result.get("error", "No se pudo simular el partido TAS."))
		return
	_show_tas_competition()

func _advance_tas_edition(season_id: String) -> void:
	var result: Dictionary = FootballData.advance_tas_edition(season_id)
	if not bool(result.get("ok", false)):
		status_label.text = str(result.get("error", "No se pudo avanzar la edición TAS."))
		return
	_show_tas_competition()

func _show_competition_detail(competition_id: String) -> void:
	current_page = "modes"
	current_subpage = "competition:" + competition_id
	_clear_content()
	var competition: Dictionary = FootballData.registry.competitions_by_id.get(competition_id, {})
	_update_header(str(competition.get("name", competition_id)), "Clasificación, calendario y simulación de jornadas.")
	var stage_ids: Array[String] = []
	for stage_variant in FootballData.fixtures_by_stage.keys():
		var stage_id := str(stage_variant)
		if stage_id == competition_id or stage_id.begins_with(competition_id + "_"):
			stage_ids.append(stage_id)
	stage_ids.sort()
	if stage_ids.is_empty():
		_add_info_card("CALENDARIO PENDIENTE", "Esta competición está en el catálogo, pero todavía no tiene una fase jugable generada.")
	for stage_id in stage_ids:
		var fixtures: Array = FootballData.get_fixtures(stage_id)
		var table: Array = FootballData.get_standings(stage_id)
		var stage_panel := _make_panel()
		content_box.add_child(stage_panel)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 7)
		stage_panel.add_child(column)
		column.add_child(_label(stage_id, 16, LIME))
		column.add_child(_label("CLASIFICACIÓN", 13, WHITE))
		for rank in range(table.size()):
			var standing: Dictionary = table[rank]
			var team_id := str(standing.get("team_id", ""))
			var team: Dictionary = FootballData.registry.teams_by_id.get(team_id, {})
			var team_name := str(team.get("name", team.get("short_name", team_id)))
			var line := "%02d  %s   PJ %d   DG %d   PTS %d" % [rank + 1, team_name, int(standing.get("played", 0)), int(standing.get("goal_difference", 0)), int(standing.get("points", 0))]
			column.add_child(_label(line, 12, WHITE))
		var pending_round := 0
		var next_fixtures: Array = []
		for fixture in fixtures:
			if str(fixture.get("status", "scheduled")) != "finished":
				var fixture_round := int(fixture.get("round", 0))
				if pending_round == 0 or fixture_round < pending_round:
					pending_round = fixture_round
		for fixture in fixtures:
			if next_fixtures.size() >= 5:
				break
			if pending_round > 0 and int(fixture.get("round", 0)) == pending_round:
				var home_id := str(fixture.get("home_team_id", ""))
				var away_id := str(fixture.get("away_team_id", ""))
				var home: Dictionary = FootballData.registry.teams_by_id.get(home_id, {})
				var away: Dictionary = FootballData.registry.teams_by_id.get(away_id, {})
				next_fixtures.append("%s — %s" % [str(home.get("short_name", home.get("name", home_id))), str(away.get("short_name", away.get("name", away_id)))])
		if pending_round > 0:
			column.add_child(_label("PRÓXIMA JORNADA: %d" % pending_round, 13, LIME))
			for fixture_line in next_fixtures:
				column.add_child(_label(str(fixture_line), 12, MUTED))
			var play_round := _nav_button("SIMULAR JORNADA %d" % pending_round)
			play_round.pressed.connect(_simulate_league_round.bind(stage_id, pending_round, competition_id))
			column.add_child(play_round)
		else:
			column.add_child(_label("TEMPORADA FINALIZADA", 13, LIME))
			column.add_child(_label("%d partidos completados" % fixtures.size(), 12, MUTED))
			var next_season := _nav_button("INICIAR SIGUIENTE TEMPORADA")
			next_season.pressed.connect(_start_next_league_season.bind(stage_id, competition_id))
			column.add_child(next_season)
			column.add_child(_label("Se mantienen los mismos clubes hasta que se integren y validen las reglas de ascenso y descenso de este país.", 11, MUTED))
	_add_settings_back_button()
	status_label.text = "%d fases • resultados guardados localmente" % stage_ids.size()

func _start_next_league_season(stage_id: String, competition_id: String) -> void:
	var fixtures: Array = FootballData.get_fixtures(stage_id)
	var current_season_number := 0
	for fixture in fixtures:
		var season_id := str(fixture.get("season_id", "season_1"))
		if season_id.begins_with("season_"):
			current_season_number = maxi(current_season_number, int(season_id.trim_prefix("season_")))
	var next_season_id := "season_%d" % (current_season_number + 1)
	var table: Dictionary = FootballData.standings_by_stage.get(stage_id, {})
	var team_ids: Array = table.keys()
	team_ids.sort()
	var double_round_robin := not bool(FootballData.single_round_stages.get(stage_id, false))
	var result: Dictionary = FootballData.start_next_season_for_stage(stage_id, next_season_id, team_ids, double_round_robin)
	var status_message := ""
	if bool(result.get("ok", false)):
		status_message = "Comienza %s con %d partidos." % [next_season_id, int(result.get("fixture_count", 0))]
	else:
		status_message = str(result.get("error", "No se pudo iniciar la nueva temporada."))
	_show_competition_detail(competition_id)
	status_label.text = status_message

func _simulate_league_round(stage_id: String, round_number: int, competition_id: String) -> void:
	var result: Dictionary = FootballData.simulate_round(stage_id, round_number)
	var status_message := ""
	if bool(result.get("ok", false)):
		_record_manager_league_results(result.get("results", []))
		status_message = "Jornada %d completada: %d partidos." % [round_number, int(result.get("simulated", 0))]
	else:
		status_message = str(result.get("error", "No se pudo simular la jornada."))
	_show_competition_detail(competition_id)
	status_label.text = status_message

func _record_manager_league_results(results: Array) -> void:
	var career: Dictionary = ManagerCareer.get_career_state()
	if career.is_empty() or str(career.get("role", "")) != "coach":
		return
	var club_id := str(career.get("club_id", ""))
	if club_id.is_empty() or FootballData.registry == null:
		return
	for result in results:
		var home_id := str(result.get("home_team_id", ""))
		var away_id := str(result.get("away_team_id", ""))
		if club_id != home_id and club_id != away_id:
			continue
		var is_home := club_id == home_id
		var manager_match: Dictionary = result.duplicate(true)
		manager_match["match_id"] = str(result.get("match_id", result.get("fixture_id", "")))
		manager_match["team_goals"] = int(result.get("home_goals", 0)) if is_home else int(result.get("away_goals", 0))
		manager_match["opponent_goals"] = int(result.get("away_goals", 0)) if is_home else int(result.get("home_goals", 0))
		var scored_first_half := false
		var scored_second_half := false
		for event in result.get("events", []):
			if str(event.get("type", "")) != "goal" or str(event.get("team_id", "")) != club_id:
				continue
			if int(event.get("minute", 0)) <= 45:
				scored_first_half = true
			else:
				scored_second_half = true
		manager_match["scored_first_half"] = scored_first_half
		manager_match["scored_second_half"] = scored_second_half
		var roster: Array = FootballData.registry.get_team_roster(club_id)
		var starting_lineup: Array = []
		for index in range(mini(11, roster.size())):
			starting_lineup.append(roster[index].duplicate(true))
		manager_match["starting_lineup"] = starting_lineup
		# Card objectives remain unchanged until disciplinary events are tracked by the match engine.
		ManagerCareer.process_match(manager_match)

func _open_manager_career() -> void:
	current_page = "modes"
	current_subpage = "manager_career"
	_clear_content()
	_update_header("MODO ENTRENADOR", "Gestiona un club y desarrolla tu carrera.")
	if ManagerCareer.load_career():
		_show_manager_dashboard()
		return
	var teams: Dictionary = FootballData.registry.teams_by_id if FootballData.registry != null else {}
	if teams.is_empty():
		_add_info_card("SIN CLUBES DISPONIBLES", "El catálogo de clubes no se ha inicializado; no se puede crear una carrera todavía.")
		_add_settings_back_button()
		return
	_add_info_card("NUEVA CARRERA", "Selecciona un club de la base de datos masculina para comenzar.")
	var selector := OptionButton.new()
	selector.name = "ManagerClubSelector"
	var team_ids: Array = teams.keys()
	team_ids.sort()
	for team_id in team_ids:
		var team: Dictionary = teams[team_id]
		var team_name := str(team.get("name", team.get("short_name", team_id)))
		selector.add_item(team_name)
		selector.set_item_metadata(selector.get_item_count() - 1, str(team_id))
	selector.select(0)
	content_box.add_child(selector)
	var start := _nav_button("INICIAR CARRERA")
	start.pressed.connect(_start_manager_career.bind(selector))
	content_box.add_child(start)
	_add_settings_back_button()
	status_label.text = "%d clubes disponibles" % teams.size()

func _start_manager_career(selector: OptionButton) -> void:
	if selector.get_item_count() == 0 or selector.selected < 0:
		return
	var club_id := str(selector.get_item_metadata(selector.selected))
	var result: Dictionary = ManagerCareer.start_coach_career(club_id)
	if bool(result.get("ok", false)):
		_show_manager_dashboard()
	else:
		_add_info_card("NO SE PUDO INICIAR", str(result.get("error", "Error al guardar la carrera.")))

func _show_manager_dashboard() -> void:
	_clear_content()
	_update_header("CARRERA DE ENTRENADOR", "Tu club, tus objetivos y tu progreso.")
	var state: Dictionary = ManagerCareer.get_career_state()
	var club_id := str(state.get("club_id", ""))
	var club: Dictionary = FootballData.registry.teams_by_id.get(club_id, {}) if FootballData.registry != null else {}
	_add_info_card("CLUB", str(club.get("name", club.get("short_name", club_id if not club_id.is_empty() else "Sin club"))))
	if FootballData.registry != null:
		var competition_ids: Array = FootballData.registry.competitions_by_id.keys()
		competition_ids.sort()
		for competition_id in competition_ids:
			var competition: Dictionary = FootballData.registry.competitions_by_id[competition_id]
			if competition.get("team_ids", []).has(club_id):
				var schedule_button := _nav_button("VER LIGA Y CALENDARIO")
				schedule_button.pressed.connect(_show_competition_detail.bind(str(competition_id)))
				content_box.add_child(schedule_button)
				break
	_add_info_card("CONFIANZA DE LA JUNTA", "%d / 100" % int(state.get("board_confidence", 0)))
	_add_info_card("PUNTOS DE JUNTA", str(state.get("board_points", 0)))
	_add_info_card("PARTIDOS DIRIGIDOS", str(state.get("matches_managed", 0)))
	var objectives: Array = state.get("objectives", [])
	for objective in objectives:
		var line := "%s — %d/%d" % [str(objective.get("title", objective.get("id", "Objetivo"))), int(objective.get("progress", 0)), int(objective.get("target", 0))]
		_add_info_card("OBJETIVO", line)
	_add_settings_back_button()
	status_label.text = "Carrera guardada localmente"


func _open_legend_career() -> void:
	current_page = "modes"
	current_subpage = "legend_career"
	if LegendCareer.load_career():
		_show_legend_dashboard()
	else:
		_show_legend_entry_menu()

func _show_legend_entry_menu() -> void:
	_clear_content()
	_update_header("MODO LEYENDA", "Elige cómo quieres comenzar tu carrera.")
	_add_info_card("DOS FORMAS DE JUGAR", "Crea un futbolista desde cero o selecciona uno de los jugadores incluidos en el catálogo oficial de Fútbol Nova. Los datos originales del catálogo no se modifican.")
	_add_legend_entry_option("CREAR JUGADOR", "Diseña tu propio futbolista y genera sus atributos iniciales.", _show_legend_creator)
	_add_legend_entry_option("ELEGIR JUGADOR", "Selecciona un futbolista creado por Nova, con su ficha, club y los 35 atributos originales.", _show_legend_catalog)
	_add_settings_back_button()

func _add_legend_entry_option(title_text: String, detail_text: String, callback: Callable) -> void:
	var panel := _make_panel()
	content_box.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(copy)
	copy.add_child(_label(title_text, 19, WHITE))
	var detail := _label(detail_text, 13, MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(detail)
	var button := _nav_button("SELECCIONAR")
	button.custom_minimum_size.x = 145
	button.pressed.connect(callback)
	row.add_child(button)

func _show_legend_catalog() -> void:
	current_subpage = "legend_catalog"
	_clear_content()
	_update_header("ELEGIR JUGADOR", "Catálogo de futbolistas creados por Nova.")
	legend_catalog_players.clear()
	if FootballData.registry == null or FootballData.registry.players_by_id.is_empty():
		_add_info_card("CATÁLOGO NO DISPONIBLE", "No se pudo cargar el registro de futbolistas. Vuelve a intentarlo cuando el catálogo deportivo esté inicializado.")
		_add_legend_back_button()
		return
	var owner_login := _nav_button("INICIAR SESIÓN DEL PROPIETARIO")
	owner_login.custom_minimum_size.x = 260
	owner_login.pressed.connect(_open_legend_owner_login)
	content_box.add_child(owner_login)
	var custom_players_file := FileAccess.open("res://data/custom_players.json", FileAccess.READ)
	if custom_players_file != null:
		var custom_players_data = JSON.parse_string(custom_players_file.get_as_text())
		if custom_players_data is Dictionary:
			for custom_player in custom_players_data.get("players", []):
				var custom_id := str(custom_player.get("id", ""))
				if custom_id not in ["NOVA-PLAYER-0035", "NOVA-PLAYER-0036"]:
					continue
				var owner_entry := {
					"id": custom_id,
					"display_name": str(custom_player.get("display_name", custom_player.get("name", "Jugador personalizado"))),
					"shirt_name": str(custom_player.get("shirt_name", custom_player.get("display_name", custom_player.get("name", "")))),
					"club_id": str(custom_player.get("club_id", "")),
					"club_name": str(custom_player.get("club_name", "Agente libre")),
					"nationality_id": str(custom_player.get("nationality", "CUB")),
					"primary_position": str(custom_player.get("position", "MC")),
					"secondary_positions": custom_player.get("secondary_positions", []),
					"age": int(custom_player.get("age", 0)),
					"estimated_overall": int(custom_player.get("overall", 0)),
					"potential": int(custom_player.get("potential", 0)),
					"attributes": custom_player.get("attributes", {}).duplicate(true),
					"birth_date": str(custom_player.get("birth_date", "")),
					"owner_restricted": true
				}
				if custom_player.has("height_cm"):
					owner_entry["height_cm"] = int(custom_player.height_cm)
				if custom_player.has("weight_kg"):
					owner_entry["weight_kg"] = int(custom_player.weight_kg)
				legend_catalog_players.append(owner_entry)
	for player_id in FootballData.registry.players_by_id:
		var source: Dictionary = FootballData.registry.players_by_id[player_id].duplicate(true)
		var errors: PackedStringArray = LegendCareer.validate_catalog_player(source)
		if not errors.is_empty():
			continue
		var club_id := str(source.get("club_id", ""))
		var club: Dictionary = FootballData.registry.teams_by_id.get(club_id, {})
		source["club_name"] = str(club.get("name", club.get("display_name", club_id)))
		if str(source["club_name"]).is_empty():
			source["club_name"] = "Agente libre"
		source["catalog_season"] = str(source.get("season", ""))
		legend_catalog_players.append(source)
	legend_catalog_players.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_overall := int(a.get("estimated_overall", 0))
		var b_overall := int(b.get("estimated_overall", 0))
		if a_overall != b_overall:
			return a_overall > b_overall
		return str(a.get("display_name", "")).naturalnocasecmp_to(str(b.get("display_name", ""))) < 0
	)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 10)
	content_box.add_child(filters)
	legend_catalog_search_input = LineEdit.new()
	legend_catalog_search_input.placeholder_text = "Buscar por nombre, club o nacionalidad"
	legend_catalog_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filters.add_child(legend_catalog_search_input)
	legend_catalog_search_input.text_changed.connect(_on_legend_catalog_search_changed)
	legend_catalog_position_filter = OptionButton.new()
	legend_catalog_position_filter.add_item("Todas las posiciones")
	legend_catalog_position_filter.set_item_metadata(0, "")
	for position in NovaLegendCareerService.POSITIONS:
		legend_catalog_position_filter.add_item(str(position))
		legend_catalog_position_filter.set_item_metadata(legend_catalog_position_filter.get_item_count() - 1, str(position))
	filters.add_child(legend_catalog_position_filter)
	legend_catalog_position_filter.item_selected.connect(_on_legend_catalog_position_changed)
	legend_catalog_list = VBoxContainer.new()
	legend_catalog_list.add_theme_constant_override("separation", 7)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 360
	scroll.add_child(legend_catalog_list)
	content_box.add_child(scroll)
	legend_catalog_limit = 40
	_refresh_legend_catalog_results()
	_add_legend_back_button()
	status_label.text = "%d futbolistas disponibles" % legend_catalog_players.size()

func _on_legend_catalog_search_changed(_value: String) -> void:
	legend_catalog_limit = 40
	_refresh_legend_catalog_results()

func _on_legend_catalog_position_changed(_index: int) -> void:
	legend_catalog_limit = 40
	_refresh_legend_catalog_results()

func _refresh_legend_catalog_results() -> void:
	if legend_catalog_list == null or not is_instance_valid(legend_catalog_list):
		return
	for child in legend_catalog_list.get_children():
		legend_catalog_list.remove_child(child)
		child.queue_free()
	var query := legend_catalog_search_input.text.strip_edges().to_lower() if legend_catalog_search_input != null else ""
	var selected_position := str(legend_catalog_position_filter.get_item_metadata(legend_catalog_position_filter.selected)) if legend_catalog_position_filter != null else ""
	var matches: Array = []
	for player in legend_catalog_players:
		if not selected_position.is_empty() and str(player.get("primary_position", "")) != selected_position:
			continue
		var searchable := "%s %s %s %s" % [
			str(player.get("display_name", "")), str(player.get("club_name", "")),
			str(player.get("nationality_id", "")), str(player.get("id", ""))
		]
		if not query.is_empty() and not searchable.to_lower().contains(query):
			continue
		matches.append(player)
	var visible_count := mini(legend_catalog_limit, matches.size())
	for index in range(visible_count):
		var player: Dictionary = matches[index]
		var panel := _make_panel()
		legend_catalog_list.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		panel.add_child(row)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var is_anier := bool(player.get("owner_restricted", false))
		var owner_access := NovaOwnerAccess.is_owner_authenticated()
		var title_color := WHITE if not is_anier or owner_access else Color("777f78")
		var detail_color := MUTED if not is_anier or owner_access else Color("68716a")
		info.add_child(_label(str(player.get("display_name", "Jugador Nova")), 16, title_color))
		if is_anier:
			info.add_child(_label("%s • %s • %s/%s • %d años • GRL %d" % [str(player.get("club_name", "Club")), str(player.get("nationality_id", "")), str(player.get("primary_position", "")), str(player.get("secondary_positions", [""])[0] if not player.get("secondary_positions", []).is_empty() else ""), int(player.get("age", 0)), int(player.get("estimated_overall", 0))], 12, detail_color))
		else:
			info.add_child(_label("%s • %s • %d años • %s • OVR %d" % [
				str(player.get("club_name", "Sin club")), str(player.get("nationality_id", "")),
				int(player.get("age_at_generation", player.get("age", 0))),
				str(player.get("primary_position", "")), int(player.get("estimated_overall", 0))
			], 12, detail_color))
		var choose := _nav_button("NO TIENES ACCESO" if is_anier and not owner_access else "ELEGIR")
		if is_anier and not owner_access:
			choose.disabled = true
			choose.add_theme_color_override("font_color", Color("858b86"))
		elif is_anier:
			choose.pressed.connect(_request_anier_owner_selection.bind(player))
		else:
			choose.pressed.connect(_request_legend_catalog_selection.bind(player))
		row.add_child(choose)
	if matches.is_empty():
		var empty := _label("No hay futbolistas que coincidan con la búsqueda.", 14, MUTED)
		legend_catalog_list.add_child(empty)
	if visible_count < matches.size():
		var more := _nav_button("CARGAR MÁS (%d RESTANTES)" % (matches.size() - visible_count))
		more.pressed.connect(_show_more_legend_catalog_players.bind(matches.size()))
		legend_catalog_list.add_child(more)
	if status_label != null:
		status_label.text = "Mostrando %d de %d futbolistas" % [visible_count, matches.size()]

func _show_more_legend_catalog_players(total: int) -> void:
	legend_catalog_limit = mini(total, legend_catalog_limit + 40)
	_refresh_legend_catalog_results()

func _open_legend_owner_login() -> void:
	if legend_owner_login_dialog == null:
		legend_owner_login_dialog = ConfirmationDialog.new()
		legend_owner_login_dialog.title = "IDENTIDAD NOVA"
		legend_owner_login_dialog.ok_button_text = "ENTENDIDO"
		legend_owner_login_dialog.confirmed.connect(func(): legend_owner_login_dialog.hide())
		legend_owner_login_status = _label("El acceso reservado al propietario se habilitará cuando la identidad nativa de NOVA esté integrada. Fútbol Nova no solicita contraseñas ni utiliza autenticación externa.", 12, MUTED)
		legend_owner_login_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		legend_owner_login_dialog.add_child(legend_owner_login_status)
		add_child(legend_owner_login_dialog)
	legend_owner_login_status.text = "El acceso reservado al propietario está pendiente de la integración de identidad NOVA. No se utiliza autenticación externa."
	legend_owner_login_dialog.popup_centered(Vector2i(480, 210))

func _submit_legend_owner_login() -> void:
	var result: Dictionary = await NovaOwnerAccess.sign_in_owner()
	if legend_owner_login_status != null:
		legend_owner_login_status.text = str(result.get("error", "La identidad nativa de NOVA aún no está integrada."))
	if legend_owner_login_dialog != null:
		legend_owner_login_dialog.popup_centered(Vector2i(480, 210))

func _request_anier_owner_selection(player: Dictionary) -> void:
	if not await NovaOwnerAccess.verify_owner_session():
		_refresh_legend_catalog_results()
		status_label.text = "El acceso reservado se habilitará cuando se integre la identidad nativa de NOVA."
		return
	legend_catalog_selected_player = player.duplicate(true)
	if str(player.get("id", "")) == "NOVA-PLAYER-0035":
		_add_info_card("ACCESO DE PROPIETARIO CONFIRMADO", "Anier Cumbá está reservado para tu cuenta. Su ficha de jugador todavía necesita completar los datos deportivos antes de iniciar su carrera.")
	else:
		_request_legend_catalog_selection(player)

func _request_legend_catalog_selection(player: Dictionary) -> void:
	legend_catalog_selected_player = player.duplicate(true)
	if legend_catalog_confirmation == null:
		legend_catalog_confirmation = ConfirmationDialog.new()
		legend_catalog_confirmation.title = "INICIAR MODO LEYENDA"
		legend_catalog_confirmation.confirmed.connect(_start_selected_legend_catalog_player)
		add_child(legend_catalog_confirmation)
	legend_catalog_confirmation.dialog_text = "¿Quieres comenzar una carrera con %s? Su ficha, club, edad y atributos originales se copiarán a tu carrera sin modificar el catálogo de Nova." % str(player.get("display_name", "este futbolista"))
	legend_catalog_confirmation.popup_centered()

func _start_selected_legend_catalog_player() -> void:
	if legend_catalog_selected_player.is_empty():
		return
	var result: Dictionary = LegendCareer.start_career_from_catalog(legend_catalog_selected_player)
	if bool(result.get("ok", false)):
		_show_legend_dashboard()
	else:
		var errors: PackedStringArray = result.get("errors", PackedStringArray())
		var lines := PackedStringArray()
		for error in errors:
			lines.append(str(error))
		_add_info_card("NO SE PUDO INICIAR LA CARRERA", "\n".join(lines) if not lines.is_empty() else str(result.get("error", "No se pudo guardar la carrera.")))

func _add_legend_back_button() -> void:
	var back := _nav_button("VOLVER")
	back.pressed.connect(_show_legend_entry_menu)
	content_box.add_child(back)

func _show_legend_creator() -> void:
	_clear_content()
	_update_header("MODO LEYENDA", "Crea tu futbolista. Edad inicial permitida: 14–45 años.")
	_add_info_card("INICIO DE CARRERA", "Con 14 años comienzas en cantera. Desde los 15 participas primero en pruebas; ningún club se asigna automáticamente.")
	var name_input := LineEdit.new()
	name_input.placeholder_text = "Nombre completo"
	name_input.custom_minimum_size.y = 42
	content_box.add_child(name_input)
	var nationality := LineEdit.new()
	nationality.text = "CUB"
	nationality.placeholder_text = "Código de nacionalidad"
	content_box.add_child(nationality)
	var age := SpinBox.new()
	age.min_value = 14
	age.max_value = 45
	age.value = 18
	age.step = 1
	_add_legend_field("Edad inicial", age)
	var position := OptionButton.new()
	for code in NovaLegendCareerService.POSITIONS:
		position.add_item(code)
	position.select(10)
	_add_legend_field("Posición principal", position)
	var secondary := OptionButton.new()
	secondary.add_item("Ninguna")
	secondary.set_item_metadata(0, "")
	for code in NovaLegendCareerService.POSITIONS:
		secondary.add_item(code)
	_add_legend_field("Segunda posición (misma zona)", secondary)
	var foot := OptionButton.new()
	foot.add_item("Derecho")
	foot.set_item_metadata(0, "right")
	foot.add_item("Izquierdo")
	foot.set_item_metadata(1, "left")
	foot.add_item("Ambos")
	foot.set_item_metadata(2, "both")
	_add_legend_field("Pie hábil", foot)
	var height := SpinBox.new()
	height.min_value = 130
	height.max_value = 220
	height.value = 175
	height.suffix = " cm"
	_add_legend_field("Altura", height)
	var weight := SpinBox.new()
	weight.min_value = 35
	weight.max_value = 150
	weight.value = 70
	weight.suffix = " kg"
	_add_legend_field("Peso", weight)
	var specialization := OptionButton.new()
	var specialization_labels := ["Velocista", "Regateador", "Organizador", "Pasador", "Rematador", "Larga distancia", "Defensor", "Recuperador", "Físico", "Creador", "Portero"]
	var specialization_ids := ["velocista", "regateador", "organizador", "pasador", "rematador", "larga_distancia", "defensor", "recuperador", "fisico", "creador", "portero"]
	for i in range(specialization_labels.size()):
		specialization.add_item(specialization_labels[i])
		specialization.set_item_metadata(i, specialization_ids[i])
	_add_legend_field("Especialización", specialization)
	var create := _nav_button("CREAR FUTBOLISTA")
	create.custom_minimum_size.x = 220
	create.pressed.connect(_create_legend_player.bind(name_input, nationality, age, position, secondary, foot, height, weight, specialization))
	content_box.add_child(create)
	_add_legend_back_button()
	status_label.text = "Los atributos iniciales se generan por posición y especialización."

func _add_legend_field(caption: String, control: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := _label(caption, 13, WHITE)
	label.custom_minimum_size.x = 190
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	content_box.add_child(row)

func _create_legend_player(name_input: LineEdit, nationality: LineEdit, age: SpinBox, position: OptionButton, secondary: OptionButton, foot: OptionButton, height: SpinBox, weight: SpinBox, specialization: OptionButton) -> void:
	var secondary_code := str(secondary.get_item_metadata(secondary.selected))
	var data := {
		"full_name": name_input.text,
		"display_name": name_input.text,
		"shirt_name": name_input.text,
		"nationality_id": nationality.text,
		"age": int(age.value),
		"primary_position": position.get_item_text(position.selected),
		"secondary_position": secondary_code,
		"preferred_foot": str(foot.get_item_metadata(foot.selected)),
		"height_cm": int(height.value),
		"weight_kg": int(weight.value),
		"specialization": str(specialization.get_item_metadata(specialization.selected))
	}
	var result: Dictionary = LegendCareer.start_career(data)
	if bool(result.get("ok", false)):
		var career_state: Dictionary = LegendCareer.get_career_state()
		var roster_result: Dictionary = CustomPlayerRoster.add_created_player(career_state.get("player", {}))
		if not bool(roster_result.get("ok", false)):
			_add_info_card("JUGADOR CREADO, REGISTRO ONLINE PENDIENTE", str(roster_result.get("error", "No se pudo guardar en la lista independiente de jugadores.")))
		_show_legend_dashboard()
	else:
		var errors: Array = result.get("errors", [])
		var error_lines := PackedStringArray()
		for item in errors:
			error_lines.append(str(item))
		_add_info_card("NO SE PUDO CREAR", "\n".join(error_lines) if not error_lines.is_empty() else str(result.get("error", "No se pudo guardar la carrera.")))

func _show_legend_dashboard() -> void:
	_clear_content()
	var state: Dictionary = LegendCareer.get_career_state()
	var player: Dictionary = state.get("player", {})
	var retired := bool(state.get("retired", false))
	_update_header("MODO LEYENDA", "%s • %s • Temporada %d" % [str(player.get("display_name", "Jugador")), str(state.get("status", "")).to_upper(), int(state.get("season", 1))])
	_add_info_card("FUTBOLISTA", "%s\nEdad: %d • %s • %s\nAltura: %d cm • Peso: %d kg • Pie: %s\nClub: %s" % [str(player.get("full_name", "")), int(player.get("age", 0)), str(player.get("nationality_id", "")), str(player.get("primary_position", "")), int(player.get("height_cm", 0)), int(player.get("weight_kg", 0)), str(player.get("preferred_foot", "")), str(state.get("club_name", "Sin club asignado"))])
	_add_info_card("VALORACIÓN Y DESARROLLO", "Media: %d • Potencial: %d • Condición: %d • Forma: %d • Moral: %d" % [int(player.get("overall", 0)), int(player.get("potential", 0)), int(player.get("condition", 0)), int(player.get("form", 0)), int(player.get("morale", 0))])
	var grouped: Dictionary = player.get("attribute_groups", {})
	for group_name in grouped:
		var values: Dictionary = grouped[group_name]
		var parts := PackedStringArray()
		for key in values:
			parts.append("%s %d" % [str(key).to_upper(), int(values[key])])
		_add_info_card("ATRIBUTOS · " + str(group_name).to_upper(), "   ".join(parts))
	_add_legend_statistics_card("ESTADÍSTICAS DE LA TEMPORADA %d" % int(state.get("season", 1)), state.get("season_stats", {}))
	_add_legend_statistics_card("ESTADÍSTICAS DE TODA LA CARRERA", state.get("career_stats", {}))
	_add_info_card("REGISTRO ESTADÍSTICO", "Se muestran todas las estadísticas de temporada y carrera guardadas. El puente de resultados está disponible; la acumulación automática requiere que el motor del Modo Leyenda lo invoque al finalizar cada partido.")
	var season_history: Array = state.get("season_history", [])
	if not season_history.is_empty():
		var history_lines := PackedStringArray()
		for season_record in season_history:
			var old_stats: Dictionary = season_record.get("statistics", {})
			history_lines.append("Temporada %d — PJ %d • G %d • A %d • V %d • E %d • D %d • Media %.2f" % [
				int(season_record.get("season", 0)), int(old_stats.get("appearances", 0)),
				int(old_stats.get("goals", 0)), int(old_stats.get("assists", 0)),
				int(old_stats.get("wins", 0)), int(old_stats.get("draws", 0)),
				int(old_stats.get("losses", 0)), float(old_stats.get("average_rating", 0.0))
			])
		_add_info_card("HISTORIAL DE TEMPORADAS", "\n".join(history_lines))
	var awards: Array = state.get("awards", [])
	var award_lines := PackedStringArray()
	for award in awards:
		award_lines.append("%s • Temporada %s" % [str(award.get("name", "Premio")), str(award.get("season", "?"))])
	_add_info_card("PREMIOS INDIVIDUALES", "\n".join(award_lines) if not award_lines.is_empty() else "Sin premios registrados.")
	var contract: Dictionary = state.get("contract", {})
	_add_info_card("SITUACIÓN CONTRACTUAL", "Club: %s\nContrato vigente: %s\nTemporada cerrada: %s" % [
		str(state.get("club_name", state.get("club_id", "Sin club asignado"))),
		"Sí" if bool(contract.get("active", false)) else "No",
		"Sí" if bool(state.get("season_complete", false)) else "No"
	])
	if retired:
		_add_info_card("CARRERA FINALIZADA", "Retirado a los %d años. Se conservan atributos, estadísticas, temporadas y premios." % int(player.get("age", 0)))
		if bool(state.get("manager_unlocked", false)):
			_add_legend_manager_transition()
	else:
		var can_retire := bool(state.get("season_complete", false)) and not bool(contract.get("active", false))
		var retire := _nav_button("RETIRARSE")
		retire.disabled = not can_retire
		retire.tooltip_text = "Disponible al finalizar la temporada y quedar sin contrato." if not can_retire else "Retirar definitivamente al futbolista."
		retire.pressed.connect(_confirm_legend_retirement)
		content_box.add_child(retire)
		if not can_retire:
			_add_info_card("REQUISITOS DE RETIRADA", "La retirada se habilita al finalizar una temporada y no tener contrato vigente. Edad máxima jugable: 45 años.")
		if not bool(state.get("season_complete", false)):
			var finish := _nav_button("FINALIZAR TEMPORADA")
			finish.pressed.connect(_finish_legend_season)
			content_box.add_child(finish)
		elif int(player.get("age", 0)) < 45 and (bool(contract.get("active", false)) or str(state.get("status", "")) in ["academy", "catalog_player"]):
			var next_season := _nav_button("COMENZAR SIGUIENTE TEMPORADA")
			next_season.pressed.connect(_advance_legend_season)
			content_box.add_child(next_season)
	_add_settings_back_button()
	status_label.text = "Carrera local guardada"

func _add_legend_statistics_card(title_text: String, stats: Dictionary) -> void:
	var rows := [
		["Partidos jugados", "appearances"], ["Titularidades", "starts"], ["Suplencias", "substitute_appearances"], ["Minutos jugados", "minutes"],
		["Victorias", "wins"], ["Empates", "draws"], ["Derrotas", "losses"],
		["Goles", "goals"], ["Asistencias", "assists"], ["Tiros", "shots"],
		["Tiros a puerta", "shots_on_target"], ["Pases intentados", "passes"],
		["Pases completados", "passes_completed"], ["Precisión de pase (%)", "pass_accuracy"],
		["Pases clave", "key_passes"], ["Ocasiones creadas", "chances_created"],
		["Regates intentados", "dribbles"], ["Regates completados", "dribbles_completed"],
		["Entradas", "tackles"], ["Intercepciones", "interceptions"], ["Recuperaciones", "recoveries"],
		["Faltas cometidas", "fouls"], ["Faltas recibidas", "fouls_won"],
		["Tarjetas amarillas", "yellow_cards"], ["Tarjetas rojas", "red_cards"],
		["Paradas", "saves"], ["Porterías imbatidas", "clean_sheets"],
		["Penaltis anotados", "penalties_scored"], ["Penaltis fallados", "penalties_missed"],
		["Jugador del partido", "player_of_match"], ["Valoración media", "average_rating"],
		["Goles por partido", "goals_per_appearance"], ["Asistencias por partido", "assists_per_appearance"],
		["Éxito en regates (%)", "dribble_success_rate"]
	]
	var lines := PackedStringArray()
	for item in rows:
		var value = stats.get(item[1], 0)
		var formatted := "%.1f" % float(value) if item[1] in ["pass_accuracy", "dribble_success_rate"] else ("%.2f" % float(value) if item[1] in ["average_rating", "goals_per_appearance", "assists_per_appearance"] else str(value))
		lines.append(str(item[0]) + ": " + formatted)
	_add_info_card(title_text, "\n".join(lines))

func _confirm_legend_retirement() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Confirmar retirada"
	dialog.dialog_text = "La retirada es definitiva. Se conservará el historial de tu futbolista. ¿Deseas continuar?"
	dialog.confirmed.connect(_retire_legend_player)
	add_child(dialog)
	dialog.popup_centered()

func _add_legend_manager_transition() -> void:
	_add_info_card("MODO ENTRENADOR DESBLOQUEADO", "La retirada con 20 años o más permite comenzar una carrera de Manager sin borrar el historial del futbolista.")
	var teams: Dictionary = FootballData.registry.teams_by_id if FootballData.registry != null else {}
	if teams.is_empty():
		_add_info_card("CLUBES NO DISPONIBLES", "No se ha inicializado el catálogo de clubes.")
		return
	var selector := OptionButton.new()
	var team_ids: Array = teams.keys()
	team_ids.sort()
	for team_id in team_ids:
		var team: Dictionary = teams[team_id]
		selector.add_item(str(team.get("name", team.get("short_name", team_id))))
		selector.set_item_metadata(selector.get_item_count() - 1, str(team_id))
	selector.select(0)
	content_box.add_child(selector)
	var start := _nav_button("INICIAR CARRERA DE ENTRENADOR")
	start.pressed.connect(_start_manager_after_legend.bind(selector))
	content_box.add_child(start)

func _start_manager_after_legend(selector: OptionButton) -> void:
	if selector.selected < 0:
		return
	var result: Dictionary = LegendCareer.start_manager_after_retirement(str(selector.get_item_metadata(selector.selected)))
	if bool(result.get("ok", false)):
		_open_manager_career()
	else:
		_add_info_card("NO SE PUDO INICIAR MANAGER", str(result.get("error", "Error al iniciar la carrera.")))

func _finish_legend_season() -> void:
	var result: Dictionary = LegendCareer.complete_season()
	if bool(result.get("ok", false)):
		_show_legend_dashboard()
	else:
		_add_info_card("NO SE PUDO CERRAR LA TEMPORADA", str(result.get("error", "")))

func _advance_legend_season() -> void:
	var result: Dictionary = LegendCareer.advance_season()
	if bool(result.get("ok", false)):
		_show_legend_dashboard()
	else:
		_add_info_card("NO SE PUDO INICIAR LA TEMPORADA", str(result.get("error", "")))

func _retire_legend_player() -> void:
	var result: Dictionary = LegendCareer.retire_player()
	if bool(result.get("ok", false)):
		_show_legend_dashboard()
	else:
		_add_info_card("NO SE PUDO COMPLETAR LA RETIRADA", str(result.get("error", "")))

func _add_settings_back_button() -> void:
	var back := _nav_button("VOLVER A MODOS")
	back.pressed.connect(_show_modes)
	content_box.add_child(back)

func _show_settings() -> void:
	current_page = "settings"
	current_subpage = ""
	_clear_content()
	_update_header("CONFIGURACIÓN", "Ajustes del juego y administración.")
	for category in SETTINGS_CATEGORIES:
		var button := _nav_button(category.to_upper())
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_open_settings_category.bind(category))
		content_box.add_child(button)
	status_label.text = "Selecciona una categoría para consultar su estado."

func _open_settings_category(category: String) -> void:
	current_subpage = category
	_clear_content()
	_update_header(category.to_upper(), "Configuración • " + category)
	match category:
		"Controles":
			_show_controller_content()
		"Información":
			_add_info_card("FÚTBOL NOVA", "Juego de fútbol masculino. Versión de desarrollo. Algunas funciones aún están en construcción.")
		"Datos":
			_add_info_card("DATOS Y GUARDADOS", "La base local ya guarda catálogos, resultados, temporadas y carreras. Incluye migraciones, copias de seguridad y recuperación. La validación automática de Godot está pendiente de que GitHub Actions asigne un ejecutor.")
		"Módulos":
			_add_info_card("MÓDULOS", "Abre el catálogo para consultar paquetes publicados, descargar contenido validado y administrar instalaciones.")
			var modules_button := _nav_button(DOWNLOAD_ICON + " ABRIR CATÁLOGO DE MÓDULOS")
			modules_button.pressed.connect(_request_catalog)
			content_box.add_child(modules_button)
		_:
			_add_info_card(category.to_upper(), "Este apartado está reservado y documentado. Sus controles se habilitarán cuando la función correspondiente esté implementada.")
	var back := _nav_button("VOLVER A CONFIGURACIÓN")
	back.pressed.connect(_show_settings)
	content_box.add_child(back)
	status_label.text = "Submenú: " + category

func _add_info_card(title_text: String, body_text: String) -> void:
	var panel := _make_panel()
	content_box.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	panel.add_child(column)
	column.add_child(_label(title_text, 18, LIME))
	var body := _label(body_text, 14, MUTED)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(body)

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _show_training() -> void:
	current_page = "home"
	current_subpage = "training"
	_clear_content()
	_update_header("CENTRO DE ENTRENAMIENTO", "Elige un ejercicio. Momentos permanece exclusivamente en Inicio.")
	_add_training_card("TUTORIAL", "Aprende movimiento, control, pase, tiro, defensa, regates y balón parado.", "tutorial", "LECCIONES")
	_add_training_card("TIRO LIBRE", "Practica faltas directas: distancia, ángulo, barrera, efecto y precisión.", "free_kick", "PRACTICAR")
	_add_training_card("PENALTI", "Elige lanzador, apunta, regula la potencia y ejecuta el disparo.", "penalty", "PRACTICAR")
	_add_training_card("PRÁCTICA LIBRE", "Entrena sin objetivos obligatorios: conduce, pasa y dispara.", "free_practice", "ENTRAR")
	status_label.text = "Entrenamiento • Fútbol masculino"
	_focus_first_action(content_box.get_child(0))

func _add_training_card(title_text: String, detail_text: String, mode_id: String, action_text: String) -> void:
	var panel := _make_panel()
	content_box.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)
	var accent := ColorRect.new()
	accent.custom_minimum_size = Vector2(6, 66)
	accent.color = LIME
	row.add_child(accent)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(copy)
	copy.add_child(_label(title_text, 19, WHITE))
	var detail := _label(detail_text, 13, MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(detail)
	var button := _nav_button(action_text)
	button.pressed.connect(_select_training_mode.bind(mode_id))
	row.add_child(button)

func _show_controller_settings() -> void:
	current_page = "settings"
	_open_settings_category("Controles")

func _show_controller_content() -> void:
	var panel := _make_panel()
	content_box.add_child(panel)
	var copy := VBoxContainer.new()
	copy.add_theme_constant_override("separation", 9)
	panel.add_child(copy)
	var state := _label("", 16, WHITE)
	state.name = "ControllerState"
	copy.add_child(state)
	var profile_label := _label("", 13, MUTED)
	profile_label.name = "ControllerProfile"
	copy.add_child(profile_label)
	var mapping := _label("Perfil estándar: stick izquierdo = movimiento · A/Cruz = pase · B/Círculo = tiro · X/Cuadrado = habilidad · Y/Triángulo = presión.", 13, MUTED)
	mapping.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(mapping)
	_refresh_controller_labels()

func set_controller_status(value: Dictionary) -> void:
	controller_status = value.duplicate(true)
	_refresh_controller_labels()

func _refresh_controller_labels() -> void:
	if content_box == null:
		return
	var state := content_box.find_child("ControllerState", true, false) as Label
	var profile_label := content_box.find_child("ControllerProfile", true, false) as Label
	if state == null or profile_label == null:
		return
	var active := bool(controller_status.get("enabled", false))
	var count := int(controller_status.get("connected_count", 0))
	state.text = ("MÓDULO ACTIVO" if active else "MÓDULO NO INSTALADO") + " · " + ("%d mando(s) conectado(s)" % count)
	profile_label.text = "Perfil: " + str(controller_status.get("profile", "Mando estándar"))

func _focus_first_action(container: Node) -> void:
	var buttons := container.find_children("*", "Button", true, false)
	if not buttons.is_empty():
		(buttons[0] as Button).grab_focus()

func _select_training_mode(mode_id: String) -> void:
	status_label.text = "Ejercicio seleccionado: " + mode_id.replace("_", " ").capitalize()
	training_mode_selected.emit(mode_id)
	root.visible = false

func open_home() -> void:
	root.visible = true
	_show_home()

func open_controller_settings() -> void:
	root.visible = true
	_show_controller_settings()

func _unhandled_input(event: InputEvent) -> void:
	if not root.visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_tracking = true
			var hovered_control := get_viewport().gui_get_hovered_control()
			touch_started_on_control = hovered_control != null and hovered_control != root
		else:
			if touch_tracking:
				var delta: Vector2 = event.position - touch_start
				touch_tracking = false
				if not touch_started_on_control and absf(delta.x) > 100.0 and absf(delta.x) > absf(delta.y) * 1.25 and current_subpage == "":
					_cycle_main_page(1 if delta.x < 0.0 else -1)
	elif event is InputEventJoypadButton and event.pressed and current_subpage == "":
		if event.button_index == JOY_BUTTON_DPAD_RIGHT:
			_cycle_main_page(1)
		elif event.button_index == JOY_BUTTON_DPAD_LEFT:
			_cycle_main_page(-1)

func _navigate_back() -> void:
	if not current_subpage.is_empty():
		match current_page:
			"home":
				_show_home()
			"online":
				_show_online()
			"modes":
				_show_modes()
			"settings":
				_show_settings()
		return
	if current_page != "home":
		_cycle_main_page(-1)


func _navigate_next() -> void:
	_cycle_main_page(1)


func _cycle_main_page(direction: int) -> void:
	var index := MAIN_PAGES.find(current_page)
	if index < 0:
		return
	index = posmod(index + direction, MAIN_PAGES.size())
	_open_main_page(MAIN_PAGES[index])

func _unhandled_key_input(event: InputEvent) -> void:
	if not root.visible or not event.pressed:
		return
	if event.is_action_pressed("ui_cancel"):
		if current_subpage == "training":
			_show_home()
		elif current_subpage == "manager_career":
			_show_modes()
		elif current_subpage != "":
			_show_settings()
		elif current_page != "home":
			_show_home()

