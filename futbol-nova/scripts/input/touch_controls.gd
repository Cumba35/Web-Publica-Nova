extends Control

const JOYSTICK_RADIUS := 76.0
const BUTTON_RADIUS := 39.0
const DEAD_ZONE := 0.14

var joystick_touch_id := -1
var joystick_vector := Vector2.ZERO
var action_touch_ids: Dictionary = {}
var pressed_actions: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_begin_touch(event.index, event.position)
		else:
			_end_touch(event.index)
		accept_event()
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_id:
			_update_joystick(event.position)
			accept_event()

func _joystick_center() -> Vector2:
	return Vector2(size.x * 0.16, size.y * 0.79)

func _button_layout() -> Dictionary:
	return {
		"pass_ball": {"center": Vector2(size.x * 0.73, size.y * 0.70), "label": "PASE"},
		"shoot_ball": {"center": Vector2(size.x * 0.89, size.y * 0.79), "label": "TIRO"},
		"skill_action": {"center": Vector2(size.x * 0.72, size.y * 0.91), "label": "TÉCNICA"},
		"pressure_action": {"center": Vector2(size.x * 0.89, size.y * 0.94), "label": "PRESIÓN"}
	}

func _begin_touch(index: int, position: Vector2) -> void:
	if position.distance_to(_joystick_center()) <= JOYSTICK_RADIUS * 1.55 and joystick_touch_id == -1:
		joystick_touch_id = index
		_update_joystick(position)
		queue_redraw()
		return
	var layout := _button_layout()
	for action in layout:
		var center: Vector2 = layout[action].center
		if position.distance_to(center) <= BUTTON_RADIUS * 1.35:
			action_touch_ids[index] = str(action)
			pressed_actions[str(action)] = true
			Input.action_press(str(action))
			queue_redraw()
			return

func _end_touch(index: int) -> void:
	if index == joystick_touch_id:
		joystick_touch_id = -1
		joystick_vector = Vector2.ZERO
		_update_direction_actions(Vector2.ZERO)
	if action_touch_ids.has(index):
		var action := str(action_touch_ids[index])
		action_touch_ids.erase(index)
		if not action_touch_ids.values().has(action):
			Input.action_release(action)
			pressed_actions.erase(action)
	queue_redraw()

func _update_joystick(position: Vector2) -> void:
	var offset := position - _joystick_center()
	joystick_vector = (offset / JOYSTICK_RADIUS).limit_length(1.0)
	if joystick_vector.length() < DEAD_ZONE:
		joystick_vector = Vector2.ZERO
	_update_direction_actions(joystick_vector)
	queue_redraw()

func _update_direction_actions(value: Vector2) -> void:
	_set_action_strength("move_left", maxf(0.0, -value.x))
	_set_action_strength("move_right", maxf(0.0, value.x))
	_set_action_strength("move_forward", maxf(0.0, -value.y))
	_set_action_strength("move_back", maxf(0.0, value.y))

func _set_action_strength(action: String, strength: float) -> void:
	if strength > 0.02:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)

func _draw() -> void:
	var center := _joystick_center()
	draw_circle(center, JOYSTICK_RADIUS, Color(0.02, 0.08, 0.05, 0.48))
	draw_arc(center, JOYSTICK_RADIUS, 0.0, TAU, 64, Color(0.80, 0.96, 0.35, 0.85), 3.0)
	draw_circle(center + joystick_vector * JOYSTICK_RADIUS * 0.62, 28.0, Color(0.78, 0.94, 0.34, 0.82))
	var layout := _button_layout()
	for action in layout:
		var data: Dictionary = layout[action]
		var button_center: Vector2 = data.center
		var active := bool(pressed_actions.get(str(action), false))
		var fill := Color(0.76, 0.92, 0.30, 0.88) if active else Color(0.02, 0.08, 0.05, 0.62)
		draw_circle(button_center, BUTTON_RADIUS, fill)
		draw_arc(button_center, BUTTON_RADIUS, 0.0, TAU, 48, Color(0.88, 0.98, 0.52, 0.95), 2.5)
		var label := str(data.label)
		var font := ThemeDB.fallback_font
		var font_size := 12 if label == "PRESIÓN" or label == "TÉCNICA" else 15
		var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(font, button_center + Vector2(-text_size.x / 2.0, font_size / 3.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.05, 0.10, 0.04, 1.0) if active else Color.WHITE)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_release_all()

func _release_all() -> void:
	joystick_touch_id = -1
	joystick_vector = Vector2.ZERO
	for action in ["move_left", "move_right", "move_forward", "move_back", "pass_ball", "shoot_ball", "skill_action", "pressure_action"]:
		Input.action_release(action)
	action_touch_ids.clear()
	pressed_actions.clear()
	queue_redraw()
