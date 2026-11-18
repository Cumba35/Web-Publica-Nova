class_name SkillGestureButton
extends Control

signal circle_gesture_completed

const MIN_START_RADIUS := 34.0
const MAX_START_RADIUS := 92.0
const MIN_PATH_POINTS := 12
const MIN_ANGLE_COVERAGE := 5.15
const MAX_CLOSURE_DISTANCE := 28.0
const MIN_AVERAGE_RADIUS := 40.0
const MAX_AVERAGE_RADIUS := 86.0
const MAX_RADIUS_VARIATION := 38.0

var _tracking := false
var _active_touch_id := -2
var _points: Array[Vector2] = []
var _start_point := Vector2.ZERO
var _last_angle := 0.0
var _signed_angle_total := 0.0
var _radius_min := INF
var _radius_max := 0.0
var _radius_sum := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(194.0, 194.0)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		var local_position := _to_local_position(touch.position)
		if touch.pressed:
			if not _tracking and _inside_control(local_position) and _begin_gesture(local_position):
				_active_touch_id = touch.index
				get_viewport().set_input_as_handled()
		elif _tracking and _active_touch_id == touch.index:
			if _inside_control(local_position):
				_add_gesture_point(local_position)
				_finish_gesture()
			else:
				_cancel_gesture()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _tracking and _active_touch_id == drag.index:
			var drag_position := _to_local_position(drag.position)
			if _inside_control(drag_position):
				_add_gesture_point(drag_position)
			else:
				_cancel_gesture()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_button := event as InputEventMouseButton
		var mouse_position := _to_local_position(mouse_button.position)
		if mouse_button.pressed:
			if not _tracking and _inside_control(mouse_position) and _begin_gesture(mouse_position):
				_active_touch_id = -1
				get_viewport().set_input_as_handled()
		elif _tracking and _active_touch_id == -1:
			if _inside_control(mouse_position):
				_add_gesture_point(mouse_position)
				_finish_gesture()
			else:
				_cancel_gesture()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _tracking and _active_touch_id == -1:
		var motion := event as InputEventMouseMotion
		var motion_position := _to_local_position(motion.position)
		if _inside_control(motion_position):
			_add_gesture_point(motion_position)
		else:
			_cancel_gesture()
		get_viewport().set_input_as_handled()

func _to_local_position(viewport_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * viewport_position

func _inside_control(point: Vector2) -> bool:
	return Rect2(Vector2.ZERO, size).has_point(point)

func _button_center() -> Vector2:
	return size * 0.5

func _begin_gesture(point: Vector2) -> bool:
	var radius := point.distance_to(_button_center())
	if radius < MIN_START_RADIUS or radius > MAX_START_RADIUS:
		return false
	_tracking = true
	_points.clear()
	_points.append(point)
	_start_point = point
	_last_angle = (point - _button_center()).angle()
	_signed_angle_total = 0.0
	_radius_min = radius
	_radius_max = radius
	_radius_sum = radius
	queue_redraw()
	return true

func _add_gesture_point(point: Vector2) -> void:
	if not _tracking:
		return
	if not _points.is_empty() and point.distance_to(_points[_points.size() - 1]) < 3.0:
		return
	_points.append(point)
	var offset := point - _button_center()
	var radius := offset.length()
	var angle := offset.angle()
	var angle_delta := wrapf(angle - _last_angle, -PI, PI)
	_signed_angle_total += angle_delta
	_last_angle = angle
	_radius_min = minf(_radius_min, radius)
	_radius_max = maxf(_radius_max, radius)
	_radius_sum += radius
	queue_redraw()

func _finish_gesture() -> void:
	if not _tracking:
		return
	var valid := false
	if _points.size() >= MIN_PATH_POINTS:
		var last_point: Vector2 = _points[_points.size() - 1]
		var average_radius := _radius_sum / float(_points.size())
		valid = (
			last_point.distance_to(_start_point) <= MAX_CLOSURE_DISTANCE
			and absf(_signed_angle_total) >= MIN_ANGLE_COVERAGE
			and average_radius >= MIN_AVERAGE_RADIUS
			and average_radius <= MAX_AVERAGE_RADIUS
			and (_radius_max - _radius_min) <= MAX_RADIUS_VARIATION
		)
	_cancel_gesture()
	if valid:
		circle_gesture_completed.emit()

func _cancel_gesture() -> void:
	_tracking = false
	_active_touch_id = -2
	_points.clear()
	_signed_angle_total = 0.0
	_radius_min = INF
	_radius_max = 0.0
	_radius_sum = 0.0
	queue_redraw()

func _draw() -> void:
	var center := _button_center()
	draw_circle(center, 31.0, Color(0.04, 0.12, 0.25, 0.94))
	draw_arc(center, 31.0, 0.0, TAU, 48, Color(0.25, 0.82, 1.0), 3.0, true)
	draw_string(ThemeDB.fallback_font, center + Vector2(-23.0, 5.0), "SKILL", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	draw_arc(center, 48.0, 0.0, TAU, 64, Color(0.20, 0.68, 0.92, 0.48), 2.0, true)
	if _points.size() > 1:
		for index in range(1, _points.size()):
			draw_line(_points[index - 1], _points[index], Color(0.25, 0.95, 1.0), 4.0, true)
	if not _tracking:
		draw_string(ThemeDB.fallback_font, Vector2(19.0, size.y - 8.0), "DIBUJA UN CÍRCULO", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.78, 0.90, 1.0))
