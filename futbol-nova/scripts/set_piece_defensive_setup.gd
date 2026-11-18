class_name SetPieceDefensiveSetup
extends RefCounted

## Deterministic helpers for positioning a free-kick wall and tuning a keeper.
const MIN_WALL_DISTANCE := 9.15
const DIFFICULTY := {
	"easy": {"reaction_delay": 0.38, "run_speed": 1.35, "dive_speed": 2.4, "spin_reading": 0.25},
	"normal": {"reaction_delay": 0.23, "run_speed": 2.50, "dive_speed": 3.8, "spin_reading": 0.70},
	"hard": {"reaction_delay": 0.16, "run_speed": 3.50, "dive_speed": 5.1, "spin_reading": 0.85}
}

static func goalkeeper_profile(difficulty: String) -> Dictionary:
	return DIFFICULTY.get(difficulty.to_lower(), DIFFICULTY["normal"]).duplicate(true)

static func wall_positions(ball_position: Vector3, goal_center: Vector3, count: int, spacing: float = 0.58, minimum_distance: float = MIN_WALL_DISTANCE) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var safe_count := clampi(count, 0, 10)
	if safe_count == 0:
		return result
	var toward_goal := goal_center - ball_position
	toward_goal.y = 0.0
	if toward_goal.length_squared() < 0.001:
		return result
	var forward := toward_goal.normalized()
	var right := forward.cross(Vector3.UP).normalized()
	var distance := maxf(MIN_WALL_DISTANCE, minimum_distance)
	var center := ball_position + forward * distance
	for index in range(safe_count):
		var offset := float(index) - float(safe_count - 1) * 0.5
		result.append(center + right * offset * maxf(0.35, spacing))
	return result
