extends Node3D
class_name NovaMatch11v11Controller

## Lightweight first-stage 11v11 local match controller.
## Uses procedural low-poly actors and throttled tactical decisions for mobile.
## This is a playable foundation, not yet a complete rules/referee simulation.

signal match_started(home_players: int, away_players: int)
signal match_paused(paused: bool)
signal possession_changed(player_id: String, home_team: bool)
signal foul_committed(player_id: String, team_id: String, severity: String)
signal match_clock_updated(phase: String, elapsed_seconds: float, remaining_seconds: float, added_seconds: int)
signal period_break_reached(phase: String)
signal added_time_started(phase: String, added_seconds: int)
signal penalty_shootout_pending
signal match_finished(phase: String)

const REALISM_MODULE = preload("res://scripts/modules/realism_module.gd")
const MATCH_CLOCK_STATE = preload("res://scripts/gameplay/match_clock_state_machine.gd")

const FIELD_HALF_WIDTH := 34.0
const FIELD_HALF_LENGTH := 52.5
const AI_DECISION_INTERVAL := 0.20
const PLAYER_RADIUS := 0.24
const PLAYER_HEIGHT := 1.75

const FORMATION_433 := [
	{"role": "GK", "x": 0.0, "z": 47.0},
	{"role": "LB", "x": -22.0, "z": 32.0},
	{"role": "LCB", "x": -7.0, "z": 36.0},
	{"role": "RCB", "x": 7.0, "z": 36.0},
	{"role": "RB", "x": 22.0, "z": 32.0},
	{"role": "DM", "x": -10.0, "z": 19.0},
	{"role": "CM", "x": 0.0, "z": 14.0},
	{"role": "AM", "x": 10.0, "z": 8.0},
	{"role": "LW", "x": -18.0, "z": -9.0},
	{"role": "ST", "x": 0.0, "z": -16.0},
	{"role": "RW", "x": 18.0, "z": -9.0}
]

var _player: CharacterBody3D
var _ball: RigidBody3D
var _actors: Array[Dictionary] = []
var _decision_clock := 0.0
var _controlled_tackle_cooldown := 0.0
var _possession_owner: Node3D
var _possession_is_controlled := false
var _active := false
var _paused := false
var _realism_profile: Dictionary = {}
var _match_clock_state: Dictionary = {}
var _home_team_id := "nova_home"
var _away_team_id := "nova_away"
var _team_colors := {
	"home": Color("#D92E3A"),
	"away": Color("#E7E9EF")
}

static func build_lineup(team_id: String, home_team: bool, player_ids: Array = []) -> Array[Dictionary]:
	if team_id.is_empty() or (not player_ids.is_empty() and player_ids.size() != 11):
		return []
	var lineup: Array[Dictionary] = []
	for index in range(FORMATION_433.size()):
		var slot: Dictionary = FORMATION_433[index]
		var z_value := float(slot.z) if home_team else -float(slot.z)
		var player_id := str(player_ids[index]) if not player_ids.is_empty() else "%s_%02d" % [team_id, index + 1]
		if player_id.is_empty():
			return []
		lineup.append({
			"player_id": player_id,
			"team_id": team_id,
			"role": str(slot.role),
			"position": Vector3(float(slot.x), 0.0, z_value),
			"home_team": home_team,
			"shirt_number": index + 1
		})
	return lineup

static func can_control_ball(distance: float, ball_height: float, ball_speed: float) -> bool:
	return distance >= 0.0 and distance <= 1.15 and ball_height >= 0.0 and ball_height <= 1.1 and ball_speed <= 4.0

static func is_ball_in_defensive_third(ball_z: float, home_team: bool, threshold: float = 22.0) -> bool:
	var own_goal_direction := 1.0 if home_team else -1.0
	return ball_z * own_goal_direction > threshold

static func is_ball_in_attacking_third(ball_z: float, home_team: bool, threshold: float = 22.0) -> bool:
	var attack_direction := -1.0 if home_team else 1.0
	return ball_z * attack_direction > threshold

static func forward_progress(origin_z: float, target_z: float, home_team: bool) -> float:
	var attack_direction := -1.0 if home_team else 1.0
	return (target_z - origin_z) * attack_direction


static func goalkeeper_clear_direction(home_team: bool, ball_x: float) -> Vector3:
	var attack_direction := -1.0 if home_team else 1.0
	var clear_side := -1.0 if ball_x >= 0.0 else 1.0
	return Vector3(clear_side * 0.72, 0.42, attack_direction).normalized()

static func evaluate_tackle(attacker_position: Vector3, attacker_forward: Vector3, target_position: Vector3, target_forward: Vector3, reach: float = 1.7, facing_threshold: float = 0.15) -> Dictionary:
	var separation := target_position - attacker_position
	var distance := separation.length()
	if distance > reach or distance < 0.001:
		return {"in_range": false, "foul": false, "success": false, "distance": distance}
	var facing := attacker_forward.normalized().dot(separation.normalized()) if attacker_forward.length_squared() > 0.001 else -1.0
	var attacker_is_behind := target_forward.length_squared() > 0.001 and target_forward.normalized().dot((attacker_position - target_position).normalized()) < -0.25
	var dangerous_contact := attacker_is_behind and distance <= 1.05
	return {"in_range": true, "foul": dangerous_contact, "success": not dangerous_contact and facing >= facing_threshold, "distance": distance}

static func validate_lineups(home_lineup: Array, away_lineup: Array) -> bool:
	if home_lineup.size() != 11 or away_lineup.size() != 11:
		return false
	var ids := {}
	for player_data in home_lineup + away_lineup:
		if not (player_data is Dictionary):
			return false
		var player_id := str(player_data.get("player_id", ""))
		if player_id.is_empty() or ids.has(player_id):
			return false
		ids[player_id] = true
		if not (player_data.get("position") is Vector3):
			return false
	return true

func start_match(controlled_player: CharacterBody3D, match_ball: RigidBody3D, match_settings: Dictionary = {}) -> Dictionary:
	if controlled_player == null or match_ball == null:
		return {"ok": false, "error": "Falta el futbolista controlado o el balón."}
	stop_match()
	_realism_profile = REALISM_MODULE.load_profile()
	_controlled_tackle_cooldown = 0.0
	_player = controlled_player
	_player.set_physics_process(true)
	_ball = match_ball
	_clear_ball_possession()
	var home_team_id := str(match_settings.get("home_team_id", "nova_home"))
	var away_team_id := str(match_settings.get("away_team_id", "nova_away"))
	var home_player_ids: Array = match_settings.get("home_player_ids", [])
	var away_player_ids: Array = match_settings.get("away_player_ids", [])
	if home_team_id == away_team_id:
		return {"ok": false, "error": "El equipo local y el visitante deben ser diferentes."}
	if (not home_player_ids.is_empty() and home_player_ids.size() != 11) or (not away_player_ids.is_empty() and away_player_ids.size() != 11):
		return {"ok": false, "error": "Cada equipo debe aportar exactamente once identificadores de titulares."}
	var home_lineup := build_lineup(home_team_id, true, home_player_ids)
	var away_lineup := build_lineup(away_team_id, false, away_player_ids)
	if not validate_lineups(home_lineup, away_lineup):
		return {"ok": false, "error": "Las alineaciones 11 contra 11 no superaron la validación."}
	_home_team_id = home_team_id
	_away_team_id = away_team_id
	_player.global_position = home_lineup[9].position
	_player.rotation.y = 0.0
	for index in range(home_lineup.size()):
		if index == 9:
			continue
		_create_ai_actor(home_lineup[index])
	for player_data in away_lineup:
		_create_ai_actor(player_data)
	_match_clock_state = MATCH_CLOCK_STATE.create_state(match_settings)
	_active = true
	_paused = false
	_decision_clock = AI_DECISION_INTERVAL
	match_started.emit(11, 11)
	return {"ok": true, "home_players": 11, "away_players": 11, "controlled_player_id": home_lineup[9].player_id}

func stop_match() -> void:
	_active = false
	_paused = false
	for actor in _actors:
		var node: Node3D = actor.get("node")
		if is_instance_valid(node):
			node.queue_free()
	_actors.clear()
	_match_clock_state.clear()
	_clear_ball_possession()
	if is_instance_valid(_player):
		_player.set_physics_process(true)
	_player = null
	_ball = null

func set_match_paused(value: bool) -> void:
	_paused = value
	if is_instance_valid(_player):
		_player.set_physics_process(not _paused)
	match_paused.emit(_paused)

func set_match_score(home_score: int, away_score: int) -> void:
	if not _match_clock_state.is_empty():
		_match_clock_state = MATCH_CLOCK_STATE.set_score(_match_clock_state, home_score, away_score)

func reset_ball_for_restart(position: Vector3 = Vector3(0.0, 0.35, 0.0)) -> void:
	_clear_ball_possession()
	if not is_instance_valid(_ball):
		return
	_ball.freeze = false
	_ball.sleeping = false
	_ball.linear_velocity = Vector3.ZERO
	_ball.angular_velocity = Vector3.ZERO
	_ball.global_position = position
	_ball.reset_physics_interpolation()

func set_clock_interruption(reason: String, active: bool) -> void:
	if not _match_clock_state.is_empty():
		_match_clock_state = MATCH_CLOCK_STATE.set_interruption(_match_clock_state, reason, active)

func continue_after_period_break() -> bool:
	if _match_clock_state.is_empty():
		return false
	var result: Dictionary = MATCH_CLOCK_STATE.continue_after_break(_match_clock_state)
	if not bool(result.get("ok", false)):
		return false
	_match_clock_state = result.state
	_paused = false
	if is_instance_valid(_player):
		_player.set_physics_process(true)
	match_paused.emit(false)
	return true

func get_clock_summary() -> Dictionary:
	return _match_clock_state.duplicate(true)

func is_match_active() -> bool:
	return _active

func has_controlled_possession() -> bool:
	return _possession_is_controlled and is_instance_valid(_possession_owner)

func release_controlled_ball(direction: Vector3, power: float = 7.0) -> bool:
	if not has_controlled_possession() or not is_instance_valid(_ball):
		return false
	if direction.length_squared() < 0.001:
		return false
	_clear_ball_possession()
	_ball.apply_central_impulse(direction.normalized() * clampf(power, 1.0, 14.0))
	return true

func get_match_summary() -> Dictionary:
	var home_count := 1 if is_instance_valid(_player) else 0
	var away_count := 0
	for actor in _actors:
		if bool(actor.get("home_team", false)):
			home_count += 1
		else:
			away_count += 1
	return {
		"active": _active,
		"paused": _paused,
		"home_players": home_count,
		"away_players": away_count,
		"ai_players": _actors.size(),
		"stage": "11v11_prototype",
		"home_team_id": _home_team_id,
		"away_team_id": _away_team_id,
		"match_phase": str(_match_clock_state.get("phase", "not_started")),
		"clock_remaining_seconds": MATCH_CLOCK_STATE.get_remaining_seconds(_match_clock_state) if not _match_clock_state.is_empty() else 0.0
	}

func _physics_process(delta: float) -> void:
	if not _active or not is_instance_valid(_ball):
		return
	if not _paused:
		_update_match_clock(delta)
	if _paused or not _active:
		return
	_decision_clock -= delta
	_controlled_tackle_cooldown = maxf(0.0, _controlled_tackle_cooldown - delta)
	var make_decision := _decision_clock <= 0.0
	if make_decision:
		_decision_clock = AI_DECISION_INTERVAL
	_update_actors(delta, make_decision)
	_update_ball_possession()

func _update_match_clock(delta: float) -> void:
	if _match_clock_state.is_empty():
		return
	var result: Dictionary = MATCH_CLOCK_STATE.tick(_match_clock_state, delta)
	_match_clock_state = result.state
	var phase := str(_match_clock_state.get("phase", ""))
	for event_name in result.events:
		match str(event_name):
			"added_time_started":
				added_time_started.emit(phase, int(_match_clock_state.get("added_seconds", 0)))
			"half_time_reached", "extra_time_half_time_reached":
				set_match_paused(true)
				period_break_reached.emit(phase)
			"extra_time_started":
				print("Fútbol Nova: comienza la prórroga.")
			"penalty_shootout_pending":
				_active = false
				set_match_paused(true)
				penalty_shootout_pending.emit()
				match_finished.emit("penalty_shootout")
			"full_time_reached":
				_active = false
				set_match_paused(true)
				match_finished.emit("full_time")
	match_clock_updated.emit(
		phase,
		float(_match_clock_state.get("elapsed_seconds", 0.0)),
		MATCH_CLOCK_STATE.get_remaining_seconds(_match_clock_state),
		int(_match_clock_state.get("added_seconds", 0))
	)

func _update_ball_possession() -> void:
	if not is_instance_valid(_ball):
		return
	if is_instance_valid(_possession_owner):
		var foot_offset := _possession_owner.global_transform.basis * Vector3(0.0, 0.18, -0.62)
		_ball.global_position = _possession_owner.global_position + foot_offset
		_ball.linear_velocity = Vector3.ZERO
		_ball.angular_velocity = Vector3.ZERO
		return
	if _ball.freeze:
		_ball.freeze = false
	if not can_control_ball(0.0, _ball.global_position.y, _ball.linear_velocity.length()):
		return
	var nearest_owner: Node3D
	var nearest_distance := INF
	if is_instance_valid(_player):
		var controlled_distance := _player.global_position.distance_to(_ball.global_position)
		if can_control_ball(controlled_distance, _ball.global_position.y, _ball.linear_velocity.length()):
			nearest_owner = _player
			nearest_distance = controlled_distance
	for actor_data in _actors:
		var actor: Node3D = actor_data.node
		if not is_instance_valid(actor):
			continue
		var distance := actor.global_position.distance_to(_ball.global_position)
		if can_control_ball(distance, _ball.global_position.y, _ball.linear_velocity.length()) and distance < nearest_distance:
			nearest_distance = distance
			nearest_owner = actor
	if nearest_owner == null:
		return
	_possession_owner = nearest_owner
	_possession_is_controlled = nearest_owner == _player
	possession_changed.emit("controlled_player" if _possession_is_controlled else str(nearest_owner.name), _possession_is_controlled)
	_ball.freeze = true
	_ball.global_position = nearest_owner.global_position + nearest_owner.global_transform.basis * Vector3(0.0, 0.18, -0.62)
	_ball.linear_velocity = Vector3.ZERO
	_ball.angular_velocity = Vector3.ZERO

func _clear_ball_possession() -> void:
	_possession_owner = null
	_possession_is_controlled = false
	if is_instance_valid(_ball):
		_ball.freeze = false
	possession_changed.emit("", false)

func attempt_controlled_tackle() -> Dictionary:
	if _controlled_tackle_cooldown > 0.0:
		return {"attempted": false, "success": false, "foul": false, "reason": "cooldown"}
	if not _active or not is_instance_valid(_player) or not is_instance_valid(_possession_owner) or _possession_owner == _player:
		return {"attempted": false, "success": false, "foul": false}
	var target := _possession_owner
	var reach := 1.7 + float(_player.get("tackle_reach_bonus"))
	var facing_threshold := maxf(0.05, 0.15 - float(_player.get("tackle_angle_bonus")))
	var result := evaluate_tackle(_player.global_position, -_player.global_transform.basis.z, target.global_position, -target.global_transform.basis.z, reach, facing_threshold)
	if not bool(result.get("in_range", false)):
		return {"attempted": false, "success": false, "foul": false, "reason": "out_of_range"}
	_controlled_tackle_cooldown = 0.75
	if bool(result.get("foul", false)):
		foul_committed.emit("controlled_player", _home_team_id, "serious")
		return {"attempted": true, "success": false, "foul": true, "severity": "serious"}
	if bool(result.get("success", false)):
		_transfer_possession(_player, true, "controlled_player")
		return {"attempted": true, "success": true, "foul": false}
	return {"attempted": true, "success": false, "foul": false, "reason": "poor_angle"}

func _transfer_possession(new_owner: Node3D, home_team: bool, player_id: String) -> void:
	_possession_owner = new_owner
	_possession_is_controlled = new_owner == _player
	if is_instance_valid(_ball):
		_ball.freeze = true
		_ball.linear_velocity = Vector3.ZERO
		_ball.angular_velocity = Vector3.ZERO
		_ball.global_position = new_owner.global_position + new_owner.global_transform.basis * Vector3(0.0, 0.18, -0.62)
	possession_changed.emit(player_id, home_team)

func _try_ai_tackle(actor_index: int, actor_data: Dictionary) -> void:
	if not is_instance_valid(_possession_owner) or _possession_owner == actor_data.node or float(actor_data.get("tackle_cooldown", 0.0)) > 0.0:
		return
	var actor: Node3D = actor_data.node
	var owner_home := _possession_owner == _player
	if not owner_home:
		for owner_data in _actors:
			if owner_data.node == _possession_owner:
				owner_home = bool(owner_data.home_team)
				break
	if bool(actor_data.home_team) == owner_home:
		return
	var result := evaluate_tackle(actor.global_position, -actor.global_transform.basis.z, _possession_owner.global_position, -_possession_owner.global_transform.basis.z)
	if not bool(result.get("in_range", false)):
		return
	actor_data.tackle_cooldown = 1.35
	if bool(result.get("foul", false)):
		foul_committed.emit(str(actor_data.player_id), str(actor_data.team_id), "serious")
	elif bool(result.get("success", false)):
		_transfer_possession(actor, bool(actor_data.home_team), str(actor_data.player_id))
	_actors[actor_index] = actor_data

func _create_ai_actor(player_data: Dictionary) -> void:
	var actor := Node3D.new()
	actor.name = str(player_data.player_id)
	actor.position = player_data.position
	actor.add_to_group("match_players")
	var is_home := bool(player_data.home_team)
	var kit_color: Color = _team_colors.home if is_home else _team_colors.away
	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = PLAYER_RADIUS
	body_mesh.height = PLAYER_HEIGHT
	body.mesh = body_mesh
	body.position.y = PLAYER_HEIGHT * 0.5
	body.material_override = _make_material(kit_color)
	actor.add_child(body)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.15
	head_mesh.height = 0.30
	head.mesh = head_mesh
	head.position.y = PLAYER_HEIGHT + 0.12
	head.material_override = _make_material(Color("#805039"))
	actor.add_child(head)
	var shorts := MeshInstance3D.new()
	var shorts_mesh := BoxMesh.new()
	shorts_mesh.size = Vector3(0.43, 0.22, 0.29)
	shorts.mesh = shorts_mesh
	shorts.position.y = 0.48
	shorts.material_override = _make_material(Color("#18202B") if is_home else Color("#253A68"))
	actor.add_child(shorts)
	add_child(actor)
	_actors.append({
		"node": actor,
		"player_id": str(player_data.player_id),
		"team_id": str(player_data.team_id),
		"home_team": is_home,
		"role": str(player_data.role),
		"home_position": player_data.position,
		"target": player_data.position,
		"speed": 5.0 if str(player_data.role) != "GK" else 4.2,
		"stamina": 100.0,
		"kick_cooldown": 0.0,
		"tackle_cooldown": 0.0
	})

func _update_actors(delta: float, make_decision: bool) -> void:
	for index in range(_actors.size()):
		var actor_data: Dictionary = _actors[index]
		var actor: Node3D = actor_data.node
		if not is_instance_valid(actor):
			continue
		actor_data.kick_cooldown = maxf(0.0, float(actor_data.kick_cooldown) - delta)
		actor_data.tackle_cooldown = maxf(0.0, float(actor_data.get("tackle_cooldown", 0.0)) - delta)
		if make_decision:
			actor_data.target = _choose_target(index, actor_data)
			_actors[index] = actor_data
			_try_ai_ball_action(index, actor_data)
			_try_ai_tackle(index, actor_data)
			actor_data = _actors[index]
		var target: Vector3 = actor_data.target
		var current := actor.global_position
		var horizontal_target := Vector3(target.x, current.y, target.z)
		var distance_to_target := current.distance_to(horizontal_target)
		var actor_is_moving := distance_to_target > 0.08
		actor_data.stamina = REALISM_MODULE.update_stamina(float(actor_data.get("stamina", 100.0)), actor_is_moving, delta, _realism_profile)
		var fatigue_multiplier := REALISM_MODULE.movement_speed_multiplier(float(actor_data.stamina), _realism_profile)
		var next_position := current.move_toward(horizontal_target, float(actor_data.speed) * fatigue_multiplier * delta)
		# Separación cinemática ligera: evita que los modelos se superpongan
		# sin introducir 21 cuerpos físicos costosos en el móvil.
		next_position += _calculate_separation(index) * delta
		next_position.x = clampf(next_position.x, -FIELD_HALF_WIDTH + 0.6, FIELD_HALF_WIDTH - 0.6)
		next_position.z = clampf(next_position.z, -FIELD_HALF_LENGTH + 0.6, FIELD_HALF_LENGTH - 0.6)
		actor.global_position = next_position
		var direction := horizontal_target - current
		if direction.length_squared() > 0.02:
			actor.rotation.y = atan2(-direction.x, -direction.z)
		_actors[index] = actor_data

func _calculate_separation(actor_index: int) -> Vector3:
	var source: Node3D = _actors[actor_index].node
	if not is_instance_valid(source):
		return Vector3.ZERO
	var offset := Vector3.ZERO
	for other_index in range(_actors.size()):
		if other_index == actor_index:
			continue
		var other: Node3D = _actors[other_index].node
		if not is_instance_valid(other):
			continue
		var difference := source.global_position - other.global_position
		difference.y = 0.0
		var distance := difference.length()
		if distance > 0.001 and distance < 0.85:
			offset += difference.normalized() * ((0.85 - distance) * 2.2)
	if is_instance_valid(_player):
		var player_difference := source.global_position - _player.global_position
		player_difference.y = 0.0
		var player_distance := player_difference.length()
		if player_distance > 0.001 and player_distance < 0.85:
			offset += player_difference.normalized() * ((0.85 - player_distance) * 2.2)
	return offset.limit_length(2.0)

func _choose_target(actor_index: int, actor_data: Dictionary) -> Vector3:
	var home_team := bool(actor_data.home_team)
	var base: Vector3 = actor_data.home_position
	var ball_position := _ball.global_position
	var tactical_shift := Vector3(clampf(ball_position.x * 0.14, -5.0, 5.0), 0.0, clampf(ball_position.z * 0.12, -7.0, 7.0))
	var target := base + tactical_shift
	if str(actor_data.role) == "GK":
		var attack_sign := -1.0 if home_team else 1.0
		var own_goal_z := 49.0 if home_team else -49.0
		var in_defensive_third := is_ball_in_defensive_third(ball_position.z, home_team)
		var step_out := 0.0
		if in_defensive_third:
			var depth := clampf((absf(ball_position.z) - 22.0) / 27.0, 0.0, 1.0)
			step_out = depth * 5.5
		var keeper_x := clampf(ball_position.x * 0.42, -5.0, 5.0)
		var keeper_z := own_goal_z + attack_sign * step_out
		return Vector3(keeper_x, 0.0, keeper_z)
	var nearest_index := _nearest_teammate_to_ball(home_team)
	if nearest_index == actor_index and Vector2(ball_position.x, ball_position.z).distance_to(Vector2(base.x, base.z)) < 29.0:
		var attack_sign := -1.0 if home_team else 1.0
		target = Vector3(ball_position.x, 0.0, ball_position.z + attack_sign * 1.25)
	return Vector3(clampf(target.x, -FIELD_HALF_WIDTH + 2.0, FIELD_HALF_WIDTH - 2.0), 0.0, clampf(target.z, -FIELD_HALF_LENGTH + 3.0, FIELD_HALF_LENGTH - 3.0))

func _nearest_teammate_to_ball(home_team: bool) -> int:
	var nearest_index := -1
	var nearest_distance := INF
	for index in range(_actors.size()):
		if bool(_actors[index].home_team) != home_team:
			continue
		var actor: Node3D = _actors[index].node
		if not is_instance_valid(actor):
			continue
		var distance := actor.global_position.distance_squared_to(_ball.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	if is_instance_valid(_player) and home_team:
		var player_distance := _player.global_position.distance_squared_to(_ball.global_position)
		if player_distance < nearest_distance:
			return -1
	return nearest_index


func _try_ai_ball_action(actor_index: int, actor_data: Dictionary) -> void:
	if float(actor_data.kick_cooldown) > 0.0:
		return
	var actor: Node3D = actor_data.node
	var owns_ball := _possession_owner == actor
	# La IA solo puede pasar o despejar después de adquirir el control;
	# evita que golpee el balón antes de que se resuelva el primer toque.
	if not owns_ball:
		return
	var home_team := bool(actor_data.home_team)
	if str(actor_data.role) == "GK":
		if actor.global_position.distance_to(_ball.global_position) > 2.0 or _ball.global_position.y > 2.4:
			return
		# Atajada/despeje básico: el portero desvía hacia una zona lateral y segura.
		var clear_direction := goalkeeper_clear_direction(home_team, _ball.global_position.x)
		if owns_ball:
			_clear_ball_possession()
		else:
			_ball.freeze = false
		_ball.apply_central_impulse(clear_direction * 10.5)
		actor_data.kick_cooldown = 1.8
		_actors[actor_index] = actor_data
		return
	var attack_sign := -1.0 if home_team else 1.0
	var attacking_third := is_ball_in_attacking_third(_ball.global_position.z, home_team)
	var pass_target := _find_forward_pass_target(actor_index, home_team)
	var impulse_direction: Vector3
	var force: float
	if pass_target != Vector3.INF:
		# Pase raso dirigido a un compañero adelantado y cercano.
		impulse_direction = (pass_target - _ball.global_position + Vector3.UP * 0.08).normalized()
		force = 7.2
	else:
		# Sin línea de pase clara: progresión/ despeje hacia campo rival.
		impulse_direction = Vector3(-_ball.global_position.x * 0.035, 0.10, attack_sign).normalized()
		force = 8.8 if attacking_third else 4.6
	if owns_ball:
		_clear_ball_possession()
	else:
		_ball.freeze = false
	_ball.apply_central_impulse(impulse_direction * force)
	actor_data.kick_cooldown = 1.25
	_actors[actor_index] = actor_data

func _find_forward_pass_target(actor_index: int, home_team: bool) -> Vector3:
	var origin: Vector3 = _actors[actor_index].node.global_position
	var best_score := -INF
	var best_position := Vector3.INF
	for index in range(_actors.size()):
		if index == actor_index or bool(_actors[index].home_team) != home_team:
			continue
		var teammate: Node3D = _actors[index].node
		if not is_instance_valid(teammate) or str(_actors[index].role) == "GK":
			continue
		var candidate := teammate.global_position
		var distance := origin.distance_to(candidate)
		var forward_gain := forward_progress(origin.z, candidate.z, home_team)
		if distance < 3.0 or distance > 19.0 or forward_gain < 1.0:
			continue
		if not _is_pass_lane_clear(origin, candidate, home_team):
			continue
		var score := forward_gain * 1.4 - distance * 0.35
		if score > best_score:
			best_score = score
			best_position = candidate + Vector3(0.0, 0.25, 0.0)
	# El jugador controlado también puede recibir pases del equipo local.
	if home_team and is_instance_valid(_player):
		var player_position := _player.global_position
		var player_distance := origin.distance_to(player_position)
		var player_forward_gain := forward_progress(origin.z, player_position.z, home_team)
		if player_distance >= 3.0 and player_distance <= 19.0 and player_forward_gain >= 1.0 and _is_pass_lane_clear(origin, player_position, home_team):
			var player_score := player_forward_gain * 1.4 - player_distance * 0.35
			if player_score > best_score:
				best_position = player_position + Vector3(0.0, 0.25, 0.0)
	return best_position

func _is_pass_lane_clear(origin: Vector3, destination: Vector3, passing_home_team: bool) -> bool:
	var segment := destination - origin
	var segment_length_squared := segment.length_squared()
	if segment_length_squared < 0.001:
		return false
	for opponent_data in _actors:
		if bool(opponent_data.home_team) == passing_home_team:
			continue
		var opponent: Node3D = opponent_data.node
		if not is_instance_valid(opponent):
			continue
		if is_point_blocking_pass(origin, destination, opponent.global_position):
			return false
	# El futbolista controlado también puede interceptar un pase del equipo rival.
	if is_instance_valid(_player) and not passing_home_team:
		if is_point_blocking_pass(origin, destination, _player.global_position):
			return false
	return true

static func is_point_blocking_pass(origin: Vector3, destination: Vector3, blocker_position: Vector3, clearance: float = 1.15) -> bool:
	var segment := destination - origin
	var segment_length_squared := segment.length_squared()
	if segment_length_squared < 0.001:
		return true
	var relative := blocker_position - origin
	var projection := clampf(relative.dot(segment) / segment_length_squared, 0.0, 1.0)
	var closest_point := origin + segment * projection
	return blocker_position.distance_to(closest_point) < clearance

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	return material
