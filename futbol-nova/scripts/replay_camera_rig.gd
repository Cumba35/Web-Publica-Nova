class_name ReplayCameraRig
extends RefCounted

## Seven original replay framing presets. A replay recorder supplies the
## ball/player focus and playback transform; this class only frames the shot.
const ANGLES := [
	{"id":"behind_kicker", "offset":Vector3(0.0, 2.2, 7.5), "fov":48.0},
	{"id":"side_low", "offset":Vector3(7.0, 1.2, 1.0), "fov":42.0},
	{"id":"side_high", "offset":Vector3(-8.0, 4.5, 0.0), "fov":52.0},
	{"id":"keeper_view", "offset":Vector3(0.0, 2.0, -7.0), "fov":46.0},
	{"id":"goal_corner", "offset":Vector3(4.0, 2.8, -4.5), "fov":44.0},
	{"id":"elevated_tactical", "offset":Vector3(0.0, 11.0, 2.0), "fov":58.0},
	{"id":"ball_follow", "offset":Vector3(1.8, 1.1, 3.8), "fov":40.0}
]

static func angle_count() -> int:
	return ANGLES.size()

static func angle_at(index: int) -> Dictionary:
	return ANGLES[clampi(index, 0, ANGLES.size() - 1)].duplicate(true)

static func apply_to_camera(camera: Camera3D, index: int, focus: Vector3) -> void:
	if camera == null:
		return
	var preset := angle_at(index)
	camera.global_position = focus + preset["offset"]
	camera.look_at(focus, Vector3.UP)
	camera.fov = float(preset["fov"])
