extends CharacterBody3D

signal skill_action_requested
signal pressure_action_requested

@export var move_speed := 7.5
@export var acceleration := 22.0
@export var gravity := 24.0
@export var pass_force := 5.5
@export var shot_force := 10.5
@export var tackle_reach_bonus := 0.0
@export var tackle_angle_bonus := 0.0

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if direction.length_squared() > 0.01:
		rotation.y = atan2(-direction.x, -direction.z)

	move_and_slide()

	if Input.is_action_just_pressed("pass_ball"):
		_kick_ball(pass_force)
	if Input.is_action_just_pressed("shoot_ball"):
		_kick_ball(shot_force)
	if Input.is_action_just_pressed("skill_action"):
		skill_action_requested.emit()
	if Input.is_action_just_pressed("pressure_action"):
		pressure_action_requested.emit()

func _kick_ball(force: float) -> void:
	var ball := get_tree().get_first_node_in_group("match_ball") as RigidBody3D
	if ball == null or global_position.distance_to(ball.global_position) > 2.4:
		return
	var forward := -global_transform.basis.z
	var direction := (forward * 0.7 + Vector3.UP * 0.08).normalized()
	var match_controller := get_tree().get_first_node_in_group("match_controller")
	if match_controller != null and match_controller.has_method("has_controlled_possession") and bool(match_controller.has_controlled_possession()):
		if match_controller.release_controlled_ball(direction, force):
			return
	ball.apply_central_impulse(direction * force)
