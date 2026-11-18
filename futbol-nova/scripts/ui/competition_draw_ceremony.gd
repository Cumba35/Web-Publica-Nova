extends Control
class_name NovaCompetitionDrawCeremony

signal ceremony_finished(result: Array)

const PANEL := Color("#12291d")
const PANEL_ALT := Color("#1b3827")
const LIME := Color("#c8f45a")
const MUTED := Color("#a8b7aa")
const WHITE := Color("#f4f7ef")

var competition_name := ""
var draw_result: Array = []
var reveal_index := 0
var result_list: VBoxContainer
var current_pick_label: Label
var progress_label: Label
var ball_label: Label
var skip_button: Button
var reveal_timer: Timer
var finished := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()
	visible = false

func _build_interface() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.008, 0.025, 0.015, 0.97)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var header := Label.new()
	header.text = "NOVA  /  CEREMONIA OFICIAL DEL SORTEO"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", LIME)
	layout.add_child(header)

	var title := Label.new()
	title.name = "CompetitionTitle"
	title.text = "SORTEO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", WHITE)
	layout.add_child(title)

	var stage := PanelContainer.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var stage_style := StyleBoxFlat.new()
	stage_style.bg_color = PANEL
	stage_style.border_color = Color(0.55, 0.78, 0.24, 0.8)
	stage_style.set_border_width_all(1)
	stage_style.set_corner_radius_all(18)
	stage_style.content_margin_left = 18
	stage_style.content_margin_right = 18
	stage_style.content_margin_top = 16
	stage_style.content_margin_bottom = 16
	stage.add_theme_stylebox_override("panel", stage_style)
	layout.add_child(stage)

	var stage_layout := VBoxContainer.new()
	stage_layout.add_theme_constant_override("separation", 10)
	stage.add_child(stage_layout)

	ball_label = Label.new()
	ball_label.text = "●"
	ball_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ball_label.add_theme_font_size_override("font_size", 58)
	ball_label.add_theme_color_override("font_color", LIME)
	stage_layout.add_child(ball_label)

	current_pick_label = Label.new()
	current_pick_label.text = "Preparando los bombos..."
	current_pick_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_pick_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_pick_label.add_theme_font_size_override("font_size", 21)
	current_pick_label.add_theme_color_override("font_color", WHITE)
	stage_layout.add_child(current_pick_label)

	progress_label = Label.new()
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_label.add_theme_color_override("font_color", MUTED)
	stage_layout.add_child(progress_label)

	var result_scroll := ScrollContainer.new()
	result_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_scroll.custom_minimum_size.y = 130
	stage_layout.add_child(result_scroll)

	result_list = VBoxContainer.new()
	result_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_list.add_theme_constant_override("separation", 5)
	result_scroll.add_child(result_list)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(footer)

	skip_button = Button.new()
	skip_button.text = "SALTAR SORTEO"
	skip_button.custom_minimum_size = Vector2(210, 48)
	skip_button.pressed.connect(skip_draw)
	footer.add_child(skip_button)

	reveal_timer = Timer.new()
	reveal_timer.one_shot = true
	reveal_timer.wait_time = 1.35
	reveal_timer.timeout.connect(_reveal_next)
	add_child(reveal_timer)

func present_draw(tournament_name: String, resolved_draw: Array) -> void:
	competition_name = tournament_name
	draw_result = resolved_draw.duplicate(true)
	reveal_index = 0
	finished = false
	visible = true
	skip_button.grab_focus()
	var title := find_child("CompetitionTitle", true, false) as Label
	if title != null:
		title.text = competition_name.to_upper() + "  /  SORTEO"
	for child in result_list.get_children():
		child.queue_free()
	current_pick_label.text = "Los bombos están preparados. Comienza la extracción."
	progress_label.text = "0 / %d equipos revelados" % draw_result.size()
	skip_button.disabled = draw_result.is_empty()
	if draw_result.is_empty():
		_finish_draw()
	else:
		_reveal_next()

func _reveal_next() -> void:
	if finished:
		return
	if reveal_index >= draw_result.size():
		_finish_draw()
		return

	var pick: Dictionary = draw_result[reveal_index] if draw_result[reveal_index] is Dictionary else {"team_name": str(draw_result[reveal_index])}
	var team_name := str(pick.get("team_name", pick.get("club_name", pick.get("name", pick.get("team_id", "Equipo")))))
	var group_name := str(pick.get("group", pick.get("group_name", "")))
	var pot_name := str(pick.get("pot", pick.get("pot_name", "")))
	var association := str(pick.get("association", pick.get("country", "")))
	var round_name := str(pick.get("round", ""))
	var destination := str(pick.get("destination", pick.get("pairing", "")))

	var details: Array[String] = []
	if not group_name.is_empty():
		details.append("Grupo " + group_name)
	if not round_name.is_empty():
		details.append(round_name.replace("_", " ").capitalize())
	if not destination.is_empty():
		details.append(destination)
	if not pot_name.is_empty():
		details.append(pot_name)
	if not association.is_empty():
		details.append(association)
	current_pick_label.text = team_name + ("\n" + " • ".join(details) if not details.is_empty() else "")
	progress_label.text = "%d / %d equipos revelados" % [reveal_index + 1, draw_result.size()]

	var row := PanelContainer.new()
	var row_style := StyleBoxFlat.new()
	row_style.bg_color = PANEL_ALT
	row_style.set_corner_radius_all(8)
	row_style.content_margin_left = 10
	row_style.content_margin_right = 10
	row_style.content_margin_top = 6
	row_style.content_margin_bottom = 6
	row.add_theme_stylebox_override("panel", row_style)
	var row_label := Label.new()
	row_label.text = "%02d   %s%s" % [reveal_index + 1, team_name, ("  →  " + " / ".join(details)) if not details.is_empty() else ""]
	row_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row_label.add_theme_font_size_override("font_size", 13)
	row_label.add_theme_color_override("font_color", WHITE)
	row.add_child(row_label)
	result_list.add_child(row)

	ball_label.rotation = 0.0
	ball_label.scale = Vector2.ONE
	var animation := create_tween()
	animation.tween_property(ball_label, "rotation", TAU, 0.65)
	animation.parallel().tween_property(ball_label, "scale", Vector2(1.25, 1.25), 0.32)
	animation.tween_property(ball_label, "scale", Vector2.ONE, 0.2)
	reveal_index += 1
	reveal_timer.start()

func skip_draw() -> void:
	if finished:
		return
	reveal_timer.stop()
	for index in range(reveal_index, draw_result.size()):
		var pick: Dictionary = draw_result[index] if draw_result[index] is Dictionary else {"team_name": str(draw_result[index])}
		var team_name := str(pick.get("team_name", pick.get("club_name", pick.get("name", pick.get("team_id", "Equipo")))))
		var group_name := str(pick.get("group", pick.get("group_name", "")))
		var round_name := str(pick.get("round", ""))
		var destination := str(pick.get("destination", pick.get("pairing", "")))
		var details: Array[String] = []
		if not group_name.is_empty():
			details.append("Grupo " + group_name)
		if not round_name.is_empty():
			details.append(round_name.replace("_", " ").capitalize())
		if not destination.is_empty():
			details.append(destination)
		var row := PanelContainer.new()
		var row_style := StyleBoxFlat.new()
		row_style.bg_color = PANEL_ALT
		row_style.set_corner_radius_all(8)
		row_style.content_margin_left = 10
		row_style.content_margin_right = 10
		row_style.content_margin_top = 6
		row_style.content_margin_bottom = 6
		row.add_theme_stylebox_override("panel", row_style)
		var row_label := Label.new()
		row_label.text = "%02d   %s%s" % [index + 1, team_name, ("  →  " + " / ".join(details)) if not details.is_empty() else ""]
		row_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row_label.add_theme_font_size_override("font_size", 13)
		row_label.add_theme_color_override("font_color", WHITE)
		row.add_child(row_label)
		result_list.add_child(row)
	reveal_index = draw_result.size()
	progress_label.text = "%d / %d equipos revelados" % [reveal_index, draw_result.size()]
	current_pick_label.text = "Resultado completo del sorteo"
	_finish_draw()

func _finish_draw() -> void:
	if finished:
		return
	finished = true
	skip_button.disabled = false
	reveal_timer.stop()
	skip_button.text = "CONTINUAR"
	skip_button.pressed.disconnect(skip_draw)
	skip_button.pressed.connect(_close_ceremony)
	current_pick_label.text = "Sorteo completado"
	progress_label.text = "%d / %d equipos revelados" % [draw_result.size(), draw_result.size()]
	ceremony_finished.emit(draw_result.duplicate(true))

func _close_ceremony() -> void:
	visible = false
	queue_free()
