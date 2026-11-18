extends CanvasLayer

const BACKGROUND := Color("#07140f")
const PANEL := Color("#10271c")
const LIME := Color("#c8f45a")
const WHITE := Color("#f4f7ef")
const MUTED := Color("#a8b7aa")

var overlay_root: Control
var progress_bar: ProgressBar
var message_label: Label
var percent_label: Label


func _ready() -> void:
	layer = 100
	_build_screen()
	set_progress(0.0, "Preparando Fútbol Nova...")


func _build_screen() -> void:
	overlay_root = Control.new()
	overlay_root.name = "LoadingOverlay"
	overlay_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay_root)

	var background := ColorRect.new()
	background.color = BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_root.add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 24.0
	center.offset_right = -24.0
	center.offset_top = 24.0
	center.offset_bottom = -24.0
	overlay_root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360.0, 230.0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = PANEL
	panel_style.border_color = Color("#496c36")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(18)
	panel_style.content_margin_left = 26.0
	panel_style.content_margin_right = 26.0
	panel_style.content_margin_top = 25.0
	panel_style.content_margin_bottom = 25.0
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)

	var brand := Label.new()
	brand.text = "NOVA"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_font_size_override("font_size", 19)
	brand.add_theme_color_override("font_color", LIME)
	content.add_child(brand)

	var title := Label.new()
	title.text = "FÚTBOL NOVA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 31)
	title.add_theme_color_override("font_color", WHITE)
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "EL FÚTBOL COMIENZA AQUÍ"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", MUTED)
	content.add_child(subtitle)

	var separator := ColorRect.new()
	separator.custom_minimum_size = Vector2(0, 2)
	separator.color = Color("#496c36")
	content.add_child(separator)

	message_label = Label.new()
	message_label.text = "Preparando recursos..."
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 13)
	message_label.add_theme_color_override("font_color", MUTED)
	content.add_child(message_label)

	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0, 13)
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false

	var bar_background := StyleBoxFlat.new()
	bar_background.bg_color = Color("#263b2c")
	bar_background.set_corner_radius_all(8)
	progress_bar.add_theme_stylebox_override("background", bar_background)

	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = LIME
	bar_fill.set_corner_radius_all(8)
	progress_bar.add_theme_stylebox_override("fill", bar_fill)
	content.add_child(progress_bar)

	percent_label = Label.new()
	percent_label.text = "0 %"
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent_label.add_theme_font_size_override("font_size", 12)
	percent_label.add_theme_color_override("font_color", LIME)
	content.add_child(percent_label)


func set_progress(value: float, message: String) -> void:
	if progress_bar == null:
		return

	var progress := clampf(value, 0.0, 100.0)
	progress_bar.value = progress
	message_label.text = message
	percent_label.text = "%d %%" % int(round(progress))


func complete() -> void:
	set_progress(100.0, "¡Todo listo!")

	var tween := create_tween()
	tween.tween_property(overlay_root, "modulate:a", 0.0, 0.35)
	await tween.finished
	queue_free()
