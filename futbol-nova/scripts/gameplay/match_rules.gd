extends RefCounted
class_name NovaMatchRules

## Deterministic, engine-independent football rule geometry.
## attack_sign is -1 for attacks toward -Z and +1 for attacks toward +Z.

static func evaluate_offside_at_pass(attacker_position: Vector3, ball_position: Vector3, defender_positions: Array, attack_sign: float, active_involvement: bool = true, restart_type: String = "") -> Dictionary:
	if ["goal_kick", "throw_in", "corner"].has(restart_type):
		return {"offside_position": false, "offence": false, "reason": "restart_exemption"}
	if is_zero_approx(attack_sign) or defender_positions.size() < 2:
		return {"offside_position": false, "offence": false, "reason": "insufficient_data"}
	var direction := signf(attack_sign)
	var attacker_progress := attacker_position.z * direction
	var ball_progress := ball_position.z * direction
	if attacker_progress <= 0.0:
		return {"offside_position": false, "offence": false, "reason": "own_half"}
	var first_defender_progress := -INF
	var second_defender_progress := -INF
	for defender_position in defender_positions:
		if not (defender_position is Vector3):
			continue
		var progress: float = defender_position.z * direction
		if progress > first_defender_progress:
			second_defender_progress = first_defender_progress
			first_defender_progress = progress
		elif progress > second_defender_progress:
			second_defender_progress = progress
	if second_defender_progress == -INF:
		return {"offside_position": false, "offence": false, "reason": "insufficient_defenders"}
	var offside_position := attacker_progress > ball_progress and attacker_progress > second_defender_progress
	return {
		"offside_position": offside_position,
		"offence": offside_position and active_involvement,
		"active_involvement": active_involvement,
		"second_last_defender_progress": second_defender_progress,
		"attacker_progress": attacker_progress,
		"ball_progress": ball_progress,
		"reason": "active_offside" if offside_position and active_involvement else ("passive_position" if offside_position else "onside")
	}

static func classify_ball_exit(
	ball_position: Vector3,
	last_touch_home: bool,
	half_width: float = 34.0,
	half_length: float = 52.5,
	goal_half_width: float = 3.66,
	crossbar_height: float = 2.44,
	ball_radius: float = 0.22,
	previous_ball_position: Vector3 = Vector3.ZERO,
	has_previous_ball_position: bool = false
) -> Dictionary:
	var beyond_touchline := absf(ball_position.x) - ball_radius > half_width
	var beyond_goal_line := absf(ball_position.z) - ball_radius > half_length
	if not beyond_touchline and not beyond_goal_line:
		return {"restart": "in_play", "awarded_home": false, "position": ball_position}
	var exited_goal_line := beyond_goal_line
	if beyond_touchline and beyond_goal_line:
		if not has_previous_ball_position:
			return {"restart": "ambiguous_exit", "awarded_home": false, "position": ball_position, "reason": "previous_ball_position_required"}
		var touch_boundary := signf(ball_position.x) * (half_width + ball_radius)
		var goal_boundary := signf(ball_position.z) * (half_length + ball_radius)
		var touch_fraction := _boundary_crossing_fraction(previous_ball_position.x, ball_position.x, touch_boundary)
		var goal_fraction := _boundary_crossing_fraction(previous_ball_position.z, ball_position.z, goal_boundary)
		if touch_fraction == INF or goal_fraction == INF:
			return {"restart": "ambiguous_exit", "awarded_home": false, "position": ball_position, "reason": "invalid_crossing_segment"}
		exited_goal_line = goal_fraction <= touch_fraction
	if exited_goal_line:
		var defending_home := ball_position.z > 0.0
		var attacking_home := not defending_home
		if absf(ball_position.x) + ball_radius <= goal_half_width and ball_position.y - ball_radius >= 0.0 and ball_position.y + ball_radius <= crossbar_height:
			return {"restart": "goal", "awarded_home": attacking_home, "position": Vector3(0.0, 0.0, 0.0)}
		if last_touch_home == defending_home:
			var corner_x := signf(ball_position.x) * half_width
			var corner_z := signf(ball_position.z) * half_length
			return {"restart": "corner", "awarded_home": attacking_home, "position": Vector3(corner_x, 0.0, corner_z)}
		return {"restart": "goal_kick", "awarded_home": defending_home, "position": Vector3(0.0, 0.0, half_length * (1.0 if defending_home else -1.0) * 0.88)}
	var throw_x := clampf(ball_position.x, -half_width, half_width)
	var throw_z := clampf(ball_position.z, -half_length, half_length)
	return {"restart": "throw_in", "awarded_home": not last_touch_home, "position": Vector3(throw_x, 0.0, throw_z)}

static func _boundary_crossing_fraction(origin: float, destination: float, boundary: float) -> float:
	var movement := destination - origin
	if is_zero_approx(movement):
		return INF
	var fraction := (boundary - origin) / movement
	return fraction if fraction >= 0.0 and fraction <= 1.0 else INF
