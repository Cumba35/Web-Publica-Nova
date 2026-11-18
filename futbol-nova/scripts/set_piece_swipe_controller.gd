class_name SetPieceSwipeController
extends Control

## Captures one continuous finger/mouse stroke for every restart type.
## The caller decides whether the restart is currently legal and consumes the
## normalized path to build a pass/shot/throw trajectory.

signal trajectory_committed(set_piece_type: String, normalized_path: PackedVector2Array, power: float, gesture_duration: float)
signal gesture_cancelled(reason: String)

const SUPPORTED_TYPES := [
	"kickoff",
	"direct_free_kick",
	"indirect_free_kick",
	"penalty",
	"corner",
	"goal_kick",
	"throw_in"
]
const MIN_PATH_LENGTH := 0.045
const MAX_POINTS := 96
const MIN_DURATION := 0.06
const MAX_DURATION := 2.5

@export_enum("kickoff", "direct_free_kick", "indirect_free_kick", "penalty", "corner", "goal_kick", "throw_in")
var set_piece_type := "direct_free_kick"
@export_range(0.0, 1.0, 0.01) var minimum_power := 0.12
@export_range(0.0, 1.0, 0.01) var maximum_power := 1.0
@export_range(0.0, 1.0, 0.01) var duration_power_weight := 0.35
@export var draw_preview := true

var _tracking := false
var _pointer_id := -2
var _points := PackedVector2Array()
var _started_at_msec := 0
var _path_length := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)

func set_restart_type(value: String) -> bool:
	if not SUPPORTED_TYPES.has(value):
		return false
	cancel_gesture("restart_type_changed")
	set_piece_type = value
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if not _tracking and _inside(touch.position):
				_begin(touch.position, touch.index)
		elif _tracking and _pointer_id == touch.index:
			_finish(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _tracking and _pointer_id == drag.index:
			_append(drag.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse := event as InputEventMouseButton
		if mouse.pressed:
			if not _tracking and _inside(mouse.position):
				_begin(mouse.position, -1)
		elif _tracking and _pointer_id == -1:
			_finish(mouse.position)
	elif event is InputEventMouseMotion and _tracking and _pointer_id == -1:
		_append(event.position)

func _inside(viewport_point: Vector2) -> bool:
	var local := get_global_transform_with_canvas().affine_inverse() * viewport_point
	return Rect2(Vector2.ZERO, size).has_point(local)

func _to_local(viewport_point: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * viewport_point

func _begin(viewport_point: Vector2, pointer: int) -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	_tracking = true
	_pointer_id = pointer
	_started_at_msec = Time.get_ticks_msec()
	_path_length = 0.0
	_points = PackedVector2Array()
	_append(viewport_point)
	queue_redraw()
	get_viewport().set_input_as_handled()

func _append(viewport_point: Vector2) -> void:
	if not _tracking:
		return
	var local := _to_local(viewport_point)
	var normalized := Vector2(
		clampf(local.x / size.x, 0.0, 1.0),
		clampf(local.y / size.y, 0.0, 1.0)
	)
	if not _points.is_empty():
		var previous := _points[_points.size() - 1]
		var distance := previous.distance_to(normalized)
		if distance < 0.004:
			return
		_path_length += distance
	if _points.size() < MAX_POINTS:
		_points.append(normalized)
	else:
		# Keep the first point and replace alternating samples to bound memory.
		_points[_points.size() - 1] = normalized
	queue_redraw()
	get_viewport().set_input_as_handled()

func _finish(viewport_point: Vector2) -> void:
	if not _tracking:
		return
	_append(viewport_point)
	var duration := clampf(float(Time.get_ticks_msec() - _started_at_msec) / 1000.0, MIN_DURATION, MAX_DURATION)
	var valid := _points.size() >= 2 and _path_length >= MIN_PATH_LENGTH
	var path := _points.duplicate()
	var distance_power := clampf(_path_length / 0.85, 0.0, 1.0)
	var speed_power := clampf(0.55 / duration, 0.0, 1.0)
	var power := clampf(
		lerpf(distance_power, speed_power, duration_power_weight),
		minimum_power,
		maximum_power
	)
	_reset()
	if valid:
		trajectory_committed.emit(set_piece_type, path, power, duration)
	else:
		gesture_cancelled.emit("gesture_too_short")

func cancel_gesture(reason: String = "cancelled") -> void:
	if _tracking:
		_reset()
		gesture_cancelled.emit(reason)

func _reset() -> void:
	_tracking = false
	_pointer_id = -2
	_points = PackedVector2Array()
	_path_length = 0.0
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _tracking:
		cancel_gesture("control_resized")

func _draw() -> void:
	if not draw_preview or _points.size() < 2:
		return
	for index in range(1, _points.size()):
		var a := Vector2(_points[index - 1].x * size.x, _points[index - 1].y * size.y)
		var b := Vector2(_points[index].x * size.x, _points[index].y * size.y)
		draw_line(a, b, Color(0.20, 0.88, 1.0, 0.95), 5.0, true)
