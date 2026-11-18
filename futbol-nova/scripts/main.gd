extends Node3D

const DOWNLOAD_CATALOG = preload("res://scripts/ui/league_download_catalog.gd")
const GAME_HUB = preload("res://scripts/ui/game_hub.gd")
const OPTIONAL_MODULES_CATALOG = preload("res://scripts/ui/optional_modules_catalog.gd")
const ANIER_PLAYER_SCENE = preload("res://scenes/players/anier_cumba.tscn")
const MAXIMO_PLAYER_SCENE = preload("res://scenes/players/maximo_padilla.tscn")
const CONTROLLER_MODULE = preload("res://scripts/input/controller_support_module.gd")
const GRAPHICS_MODULE = preload("res://scripts/graphics/graphics_enhancements_module.gd")
const MATCH_11V11_CONTROLLER = preload("res://scripts/gameplay/match_11v11_controller.gd")
const MATCH_RULES = preload("res://scripts/gameplay/match_rules.gd")
const TOUCH_CONTROLS = preload("res://scripts/input/touch_controls.gd")
const LOADING_SCREEN = preload("res://scripts/ui/loading_screen.gd")
const PRE_MATCH_SETUP = preload("res://scripts/ui/pre_match_setup.gd")

const FIELD_WIDTH := 68.0
const FIELD_LENGTH := 105.0
const GOAL_LINE_Z := 52.5

var player: CharacterBody3D
var ball: RigidBody3D
var score_home := 0
var score_away := 0
var home_team_display_name := "LOCAL"
var away_team_display_name := "VISITANTE"
var score_label: Label
var match_clock_label: Label
var continue_period_button: Button
var match_half_length_option: OptionButton
var match_clock_mode_option: OptionButton
var match_extra_time_check: CheckBox
var match_penalties_check: CheckBox
var match_start_button: Button
var gesture_hint_label: Label
var data_status_label: Label
var catalog_button: Button
var addons_button: Button
var game_hub: CanvasLayer
var catalog_overlay: CanvasLayer
var optional_modules_overlay: CanvasLayer
var controller_module: Node
var touch_controls: Control
var match_11v11_controller: Node3D
var match_camera: Camera3D
var pre_match_setup

func _ready() -> void:
	var loading_screen := LOADING_SCREEN.new()
	loading_screen.name = "NovaLoadingScreen"
	add_child(loading_screen)
	loading_screen.set_progress(5.0, "Preparando controles...")
	await get_tree().process_frame

	_setup_input()
	loading_screen.set_progress(15.0, "Configurando el entorno 3D...")
	await get_tree().process_frame

	_create_lighting()
	_create_pitch()
	_create_goals()
	loading_screen.set_progress(38.0, "Preparando el campo y las porterías...")
	await get_tree().process_frame

	_create_ball()
	_create_player()
	loading_screen.set_progress(58.0, "Cargando balón y futbolista...")
	await get_tree().process_frame

	_create_match_11v11_controller()
	_create_camera()
	loading_screen.set_progress(76.0, "Inicializando el sistema de partido...")
	await get_tree().process_frame

	_create_hud()
	_create_touch_controls()
	loading_screen.set_progress(90.0, "Construyendo las pantallas principales...")
	await get_tree().process_frame

	_create_game_hub()
	_create_controller_module()
	loading_screen.set_progress(100.0, "Fútbol Nova está listo.")
	await get_tree().process_frame
	await loading_screen.complete()

func _setup_input() -> void:
	_bind_key("move_forward", KEY_W)
	_bind_key("move_back", KEY_S)
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("pass_ball", KEY_F)
	_bind_key("shoot_ball", KEY_SPACE)
	_bind_key("pressure_action", KEY_G)
	if not InputMap.has_action("skill_action"):
		InputMap.add_action("skill_action")
	if not InputMap.has_action("pressure_action"):
		InputMap.add_action("pressure_action")
	if not InputMap.has_action("ui_accept"):
		InputMap.add_action("ui_accept")
	if not InputMap.has_action("ui_cancel"):
		InputMap.add_action("ui_cancel")

func _bind_key(action_name: String, key: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action_name, event)

func _create_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "MainSun"
	sun.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	sun.light_energy = 1.15
	add_child(sun)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.78, 0.86)
	env.ambient_light_energy = 0.55
	environment.environment = env
	add_child(environment)
	var graphics_result: Dictionary = GRAPHICS_MODULE.apply_to(environment, sun)
	if bool(graphics_result.get("ok", false)):
		print("Fútbol Nova: " + str(graphics_result.get("message", "Mejoras gráficas activadas.")))

func _create_pitch() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.name = "Pitch"
	add_child(floor_body)

	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(FIELD_WIDTH, FIELD_LENGTH)
	floor_mesh.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.10, 0.39, 0.18)
	grass.roughness = 1.0
	floor_mesh.material_override = grass
	floor_body.add_child(floor_mesh)

	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(FIELD_WIDTH, 1.0, FIELD_LENGTH)
	floor_collision.shape = floor_shape
	floor_collision.position.y = -0.5
	floor_body.add_child(floor_collision)

	_add_field_line(Vector3(0, 0.025, 0), Vector3(FIELD_WIDTH, 0.04, 0.12))
	_add_field_line(Vector3(0, 0.025, -FIELD_LENGTH / 2.0), Vector3(FIELD_WIDTH, 0.04, 0.12))
	_add_field_line(Vector3(0, 0.025, FIELD_LENGTH / 2.0), Vector3(FIELD_WIDTH, 0.04, 0.12))
	_add_field_line(Vector3(-FIELD_WIDTH / 2.0, 0.025, 0), Vector3(0.12, 0.04, FIELD_LENGTH))
	_add_field_line(Vector3(FIELD_WIDTH / 2.0, 0.025, 0), Vector3(0.12, 0.04, FIELD_LENGTH))
	_add_field_line(Vector3(0, 0.025, 0), Vector3(0.12, 0.04, FIELD_LENGTH))

	var center_circle := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 9.0
	torus.outer_radius = 9.12
	center_circle.mesh = torus
	center_circle.position.y = 0.04
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.92, 0.94, 0.88)
	center_circle.material_override = white
	add_child(center_circle)

func _add_field_line(at: Vector3, dimensions: Vector3) -> void:
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	line.mesh = mesh
	line.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.92, 0.94, 0.88)
	line.material_override = material
	add_child(line)

func _create_goals() -> void:
	_create_goal(-GOAL_LINE_Z, "home")
	_create_goal(GOAL_LINE_Z, "away")

func _create_goal(z_position: float, scoring_side: String) -> void:
	var goal_area := Area3D.new()
	goal_area.name = scoring_side.capitalize() + "GoalArea"
	var area_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(7.32, 2.44, 0.2)
	area_shape.shape = box
	goal_area.add_child(area_shape)
	goal_area.position = Vector3(0, 1.22, z_position + signf(z_position) * 0.55)
	goal_area.body_entered.connect(_on_goal_body_entered.bind(scoring_side))
	add_child(goal_area)

	for post_x in [-3.75, 3.75]:
		var post := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.09
		cylinder.bottom_radius = 0.09
		cylinder.height = 2.53
		post.mesh = cylinder
		post.position = Vector3(post_x, 1.265, z_position)
		_apply_white_material(post)
		add_child(post)

	var crossbar := MeshInstance3D.new()
	var bar_mesh := CylinderMesh.new()
	bar_mesh.top_radius = 0.09
	bar_mesh.bottom_radius = 0.09
	bar_mesh.height = 7.5
	crossbar.mesh = bar_mesh
	crossbar.rotation_degrees.z = 90.0
	crossbar.position = Vector3(0, 2.53, z_position)
	_apply_white_material(crossbar)
	add_child(crossbar)

func _apply_white_material(node: MeshInstance3D) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.96, 0.96, 0.92)
	node.material_override = material

func _create_ball() -> void:
	ball = RigidBody3D.new()
	ball.name = "MatchBall"
	ball.add_to_group("match_ball")
	ball.mass = 0.43
	ball.linear_damp = 0.45
	ball.angular_damp = 0.65
	ball.position = Vector3(0, 0.35, 0)

	var ball_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	ball_mesh.mesh = sphere
	var ball_material := StandardMaterial3D.new()
	ball_material.albedo_color = Color(0.96, 0.96, 0.90)
	ball_material.roughness = 0.55
	ball_mesh.material_override = ball_material
	ball.add_child(ball_mesh)

	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.22
	collision.shape = shape
	ball.add_child(collision)
	add_child(ball)

func _create_player() -> void:
	var selected_player_scene: PackedScene = MAXIMO_PLAYER_SCENE if home_team_display_name == "Litoral Barcelona" else ANIER_PLAYER_SCENE
	var anier_player := selected_player_scene.instantiate() as CharacterBody3D
	if anier_player == null:
		push_error("No se pudo instanciar la escena 3D del jugador seleccionado.")
		return

	anier_player.name = "ControlledPlayer"
	# La escena de Anier sitúa la cápsula de colisión a 0.855 m sobre el origen.
	# Por eso el origen del personaje debe quedar a nivel del césped.
	anier_player.position = Vector3(0, 0.0, 8.0)
	anier_player.connect("skill_action_requested", _on_player_skill_action_requested)
	anier_player.connect("pressure_action_requested", _on_player_pressure_action_requested)
	player = anier_player
	add_child(anier_player)

func _switch_controlled_player_for_selected_club() -> void:
	var should_use_maximo := home_team_display_name == "Litoral Barcelona"
	var desired_script = load("res://scripts/players/maximo_padilla.gd") if should_use_maximo else load("res://scripts/players/anier_cumba.gd")
	if player != null and player.get_script() == desired_script:
		return
	var old_position := player.global_position if player != null else Vector3(0, 0, 8)
	if player != null:
		player.queue_free()
	var scene: PackedScene = MAXIMO_PLAYER_SCENE if should_use_maximo else ANIER_PLAYER_SCENE
	var replacement := scene.instantiate() as CharacterBody3D
	if replacement == null:
		push_error("No se pudo cargar el modelo 3D del futbolista seleccionado.")
		return
	replacement.name = "ControlledPlayer"
	replacement.position = old_position
	replacement.connect("skill_action_requested", _on_player_skill_action_requested)
	replacement.connect("pressure_action_requested", _on_player_pressure_action_requested)
	player = replacement
	add_child(replacement)

func _create_camera() -> void:
	match_camera = Camera3D.new()
	match_camera.name = "MatchCamera"
	match_camera.position = Vector3(0, 25, 25)
	match_camera.rotation_degrees = Vector3(-43, 0, 0)
	match_camera.current = true
	add_child(match_camera)

func _create_match_11v11_controller() -> void:
	match_11v11_controller = MATCH_11V11_CONTROLLER.new()
	match_11v11_controller.name = "LocalMatch11v11Controller"
	match_11v11_controller.add_to_group("match_controller")
	add_child(match_11v11_controller)

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	score_label = Label.new()
	score_label.position = Vector2(24, 20)
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.text = "FÚTBOL NOVA   0 - 0"
	layer.add_child(score_label)

	match_clock_label = Label.new()
	match_clock_label.position = Vector2(500, 22)
	match_clock_label.add_theme_font_size_override("font_size", 24)
	match_clock_label.text = "PARTIDO SIN INICIAR"
	layer.add_child(match_clock_label)

	continue_period_button = Button.new()
	continue_period_button.position = Vector2(470, 320)
	continue_period_button.size = Vector2(340, 64)
	continue_period_button.text = "CONTINUAR"
	continue_period_button.visible = false
	continue_period_button.pressed.connect(_continue_match_after_period_break)
	layer.add_child(continue_period_button)

	if match_11v11_controller != null:
		match_11v11_controller.match_clock_updated.connect(_on_match_clock_updated)
		match_11v11_controller.period_break_reached.connect(_on_period_break_reached)
		match_11v11_controller.match_finished.connect(_on_match_finished)

	var help := Label.new()
	help.position = Vector2(24, 62)
	help.add_theme_font_size_override("font_size", 16)
	help.text = "WASD: mover   F: pase   ESPACIO: tiro   G: entrada"
	layer.add_child(help)

	gesture_hint_label = Label.new()
	gesture_hint_label.position = Vector2(24, 88)
	gesture_hint_label.add_theme_font_size_override("font_size", 13)
	gesture_hint_label.text = "Habilidades: reconocedor circular preparado"
	layer.add_child(gesture_hint_label)

	data_status_label = Label.new()
	data_status_label.position = Vector2(24, 112)
	data_status_label.add_theme_font_size_override("font_size", 13)
	var catalog_summary: Dictionary = FootballData.get_catalog_summary()
	if bool(catalog_summary.get("initialized", false)):
		data_status_label.text = "Catálogo offline: %d clubes • %d competiciones • %d partidos programados" % [int(catalog_summary.get("teams", 0)), int(catalog_summary.get("competitions", 0)), int(catalog_summary.get("scheduled_matches", 0))]
	else:
		data_status_label.text = "Catálogo offline: no disponible"
	layer.add_child(data_status_label)

	catalog_button = Button.new()
	catalog_button.text = "Ligas y selecciones descargables"
	catalog_button.position = Vector2(24, 145)
	catalog_button.pressed.connect(_open_download_catalog)
	layer.add_child(catalog_button)

	var hub_button := Button.new()
	hub_button.text = "Inicio / Entrenamiento"
	hub_button.position = Vector2(24, 185)
	hub_button.pressed.connect(_toggle_game_hub)
	layer.add_child(hub_button)

	addons_button = Button.new()
	addons_button.text = "Agregados / Módulos"
	addons_button.position = Vector2(24, 225)
	addons_button.pressed.connect(_open_optional_modules_catalog)
	layer.add_child(addons_button)

	match_half_length_option = OptionButton.new()
	match_half_length_option.position = Vector2(24, 305)
	match_half_length_option.add_item("3 min", 3)
	match_half_length_option.add_item("5 min", 5)
	match_half_length_option.add_item("6 min", 6)
	match_half_length_option.add_item("8 min", 8)
	match_half_length_option.add_item("10 min", 10)
	match_half_length_option.add_item("15 min", 15)
	match_half_length_option.add_item("20 min", 20)
	match_half_length_option.select(1)
	layer.add_child(match_half_length_option)

	match_clock_mode_option = OptionButton.new()
	match_clock_mode_option.position = Vector2(150, 305)
	match_clock_mode_option.add_item("Reloj continuo", 0)
	match_clock_mode_option.add_item("Reloj detenido", 1)
	match_clock_mode_option.select(0)
	layer.add_child(match_clock_mode_option)

	match_extra_time_check = CheckBox.new()
	match_extra_time_check.text = "Prórroga amistoso"
	match_extra_time_check.position = Vector2(330, 305)
	layer.add_child(match_extra_time_check)

	match_penalties_check = CheckBox.new()
	match_penalties_check.text = "Penaltis"
	match_penalties_check.position = Vector2(520, 305)
	layer.add_child(match_penalties_check)

	match_start_button = Button.new()
	match_start_button.text = "PREPARAR AMISTOSO"
	match_start_button.position = Vector2(24, 265)
	match_start_button.pressed.connect(_open_pre_match_setup)
	layer.add_child(match_start_button)

	var gesture_button := SkillGestureButton.new()
	gesture_button.anchor_left = 1.0
	gesture_button.anchor_top = 1.0
	gesture_button.anchor_right = 1.0
	gesture_button.anchor_bottom = 1.0
	gesture_button.offset_left = -210.0
	gesture_button.offset_top = -210.0
	gesture_button.offset_right = -16.0
	gesture_button.offset_bottom = -16.0
	gesture_button.circle_gesture_completed.connect(_on_skill_circle_gesture_completed)
	layer.add_child(gesture_button)

func _create_touch_controls() -> void:
	var touch_layer := CanvasLayer.new()
	touch_layer.name = "TouchControlsLayer"
	touch_layer.layer = 2
	touch_controls = TOUCH_CONTROLS.new()
	touch_controls.name = "VirtualTouchControls"
	touch_controls.visible = false
	touch_layer.add_child(touch_controls)
	add_child(touch_layer)

func _on_skill_circle_gesture_completed() -> void:
	gesture_hint_label.text = "Círculo reconocido. Evaluación contextual aún pendiente."

func _on_goal_body_entered(body: Node3D, scoring_side: String) -> void:
	if body != ball:
		return
	var goal_result: Dictionary = MATCH_RULES.classify_ball_exit(ball.global_position, false, FIELD_WIDTH * 0.5, FIELD_LENGTH * 0.5)
	if str(goal_result.get("restart", "")) != "goal":
		return
	var scoring_home := scoring_side == "home"
	if bool(goal_result.get("awarded_home", false)) != scoring_home:
		return
	if scoring_home:
		score_home += 1
	else:
		score_away += 1
	if match_11v11_controller != null:
		match_11v11_controller.set_match_score(score_home, score_away)
	score_label.text = "%s  %d - %d  %s" % [home_team_display_name, score_home, score_away, away_team_display_name]
	MomentsService.record_event("goal_scored", 1)
	_reset_ball()

func _reset_ball() -> void:
	if match_11v11_controller != null and match_11v11_controller.has_method("reset_ball_for_restart"):
		match_11v11_controller.reset_ball_for_restart(Vector3(0.0, 0.35, 0.0))
		return
	ball.freeze = false
	ball.sleeping = false
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.global_position = Vector3(0, 0.35, 0)
	ball.reset_physics_interpolation()

 
func _open_download_catalog() -> void:
	if is_instance_valid(catalog_overlay):
		return
	catalog_overlay = DOWNLOAD_CATALOG.new()
	catalog_overlay.name = "LeagueDownloadCatalog"
	catalog_overlay.tree_exited.connect(_on_catalog_exited)
	add_child(catalog_overlay)

func _on_catalog_exited() -> void:
	catalog_overlay = null


func _open_pre_match_setup() -> void:
	if is_instance_valid(pre_match_setup):
		return
	pre_match_setup = PRE_MATCH_SETUP.new()
	pre_match_setup.name = "FriendlyPreMatchSetup"
	pre_match_setup.match_requested.connect(_start_11v11_match)
	pre_match_setup.setup_closed.connect(_on_pre_match_setup_closed)
	pre_match_setup.tree_exited.connect(_on_pre_match_setup_exited)
	add_child(pre_match_setup)


func _on_pre_match_setup_closed() -> void:
	if game_hub != null:
		game_hub.open_home()


func _on_pre_match_setup_exited() -> void:
	pre_match_setup = null


func _create_game_hub() -> void:
	game_hub = GAME_HUB.new()
	game_hub.name = "GameHub"
	game_hub.training_mode_selected.connect(_on_training_mode_selected)
	game_hub.match_11v11_requested.connect(_open_pre_match_setup)
	game_hub.catalog_requested.connect(_open_download_catalog)
	add_child(game_hub)

func _on_training_mode_selected(mode_id: String) -> void:
	if match_11v11_controller != null:
		match_11v11_controller.stop_match()
	if match_half_length_option != null:
		match_half_length_option.visible = false
	if match_clock_mode_option != null:
		match_clock_mode_option.visible = false
	if match_extra_time_check != null:
		match_extra_time_check.visible = false
	if match_penalties_check != null:
		match_penalties_check.visible = false
	if match_start_button != null:
		match_start_button.visible = true
	_reset_ball()
	if touch_controls != null:
		touch_controls.visible = DisplayServer.is_touchscreen_available()
	match mode_id:
		"tutorial":
			player.global_position = Vector3(0, 0.0, 8.0)
			ball.global_position = Vector3(0, 0.35, 5.0)
			gesture_hint_label.text = "Tutorial: practica movimiento, control, pase y tiro."
		"free_kick":
			player.global_position = Vector3(0, 0.0, 27.0)
			ball.global_position = Vector3(0, 0.35, 22.0)
			gesture_hint_label.text = "Tiro libre: balón colocado frente a la portería."
		"penalty":
			player.global_position = Vector3(0, 0.0, 39.0)
			ball.global_position = Vector3(0, 0.35, 44.0)
			gesture_hint_label.text = "Penalti: balón colocado en el punto de penalti."
		"free_practice":
			player.global_position = Vector3(0, 0.0, 8.0)
			ball.global_position = Vector3(0, 0.35, 0.0)
			gesture_hint_label.text = "Práctica libre: campo abierto para entrenar."
	if score_label != null:
		score_label.text = "FÚTBOL NOVA   %d - %d" % [score_home, score_away]


func _toggle_game_hub() -> void:
	if match_11v11_controller != null and match_11v11_controller.is_match_active():
		match_11v11_controller.set_match_paused(true)
	if game_hub != null:
		game_hub.open_home()
	if touch_controls != null:
		touch_controls.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and game_hub != null and not game_hub.root.visible:
		if match_11v11_controller != null and match_11v11_controller.is_match_active():
			match_11v11_controller.set_match_paused(true)
		game_hub.open_home()
		if touch_controls != null:
			touch_controls.visible = false
		get_viewport().set_input_as_handled()


func _create_controller_module() -> void:
	controller_module = CONTROLLER_MODULE.new()
	controller_module.name = "OptionalControllerSupport"
	controller_module.module_state_changed.connect(_on_controller_module_state_changed)
	controller_module.controller_connected.connect(_on_controller_connected)
	controller_module.controller_disconnected.connect(_on_controller_disconnected)
	add_child(controller_module)

func _on_controller_module_state_changed(active: bool, message: String) -> void:
	if gesture_hint_label != null:
		gesture_hint_label.text = "Mando: " + message
	if game_hub != null:
		game_hub.set_controller_status(controller_module.get_status())

func _on_controller_connected(device_id: int, device_name: String) -> void:
	if gesture_hint_label != null:
		gesture_hint_label.text = "Mando conectado: " + device_name + " (#" + str(device_id) + ")"
	if game_hub != null:
		game_hub.set_controller_status(controller_module.get_status())

func _on_controller_disconnected(device_id: int) -> void:
	if gesture_hint_label != null:
		gesture_hint_label.text = "Mando desconectado (#" + str(device_id) + "). Controles táctiles disponibles."
	if game_hub != null:
		game_hub.set_controller_status(controller_module.get_status())


func _on_player_skill_action_requested() -> void:
	if gesture_hint_label != null:
		gesture_hint_label.text = "Solicitud de habilidad recibida. Sistema de técnicas en integración."

func _on_player_pressure_action_requested() -> void:
	if match_11v11_controller != null and match_11v11_controller.is_match_active():
		var result: Dictionary = match_11v11_controller.attempt_controlled_tackle()
		if bool(result.get("success", false)):
			gesture_hint_label.text = "¡Entrada limpia! Has recuperado el balón."
		elif bool(result.get("foul", false)):
			gesture_hint_label.text = "Falta: entrada peligrosa por detrás."
		elif str(result.get("reason", "")) == "poor_angle":
			gesture_hint_label.text = "Entrada fallida: mejora el ángulo de aproximación."
		else:
			gesture_hint_label.text = "Acércate al rival con balón para intentar robarlo."
	else:
		if gesture_hint_label != null:
			gesture_hint_label.text = "Presión disponible durante un partido 11 contra 11."


func _open_optional_modules_catalog() -> void:
	if is_instance_valid(optional_modules_overlay):
		return
	optional_modules_overlay = OPTIONAL_MODULES_CATALOG.new()
	optional_modules_overlay.name = "OptionalModulesCatalog"
	optional_modules_overlay.tree_exited.connect(_on_optional_modules_catalog_exited)
	add_child(optional_modules_overlay)

func _on_optional_modules_catalog_exited() -> void:
	optional_modules_overlay = null


func _start_11v11_match(match_overrides: Dictionary = {}) -> void:
	if match_11v11_controller == null or player == null or ball == null:
		gesture_hint_label.text = "No se pudo preparar el partido local."
		return
	var default_half_minutes := match_half_length_option.get_selected_id() if match_half_length_option != null else 5
	var selected_half_minutes := int(match_overrides.get("half_length_minutes", default_half_minutes))
	var default_clock_mode := "stopped" if match_clock_mode_option != null and match_clock_mode_option.get_selected_id() == 1 else "continuous"
	var selected_clock_mode := str(match_overrides.get("clock_mode", default_clock_mode))
	var allow_extra_time := bool(match_overrides.get("extra_time_enabled", match_extra_time_check != null and match_extra_time_check.button_pressed))
	var allow_penalties := bool(match_overrides.get("penalties_enabled", match_penalties_check != null and match_penalties_check.button_pressed))
	var match_settings := {
		"half_length_minutes": selected_half_minutes,
		"clock_mode": selected_clock_mode,
		"extra_time_enabled": allow_extra_time,
		"competition_allows_extra_time": allow_extra_time,
		"penalties_enabled": allow_penalties,
		"competition_allows_penalties": allow_penalties
	}
	match_settings.merge(match_overrides, true)
	# Seleccionar el modelo definitivo antes de entregar la referencia al motor.
	# Si se reemplaza después, el controlador conserva un CharacterBody3D liberado.
	home_team_display_name = str(match_overrides.get("home_team_name", "Equipo local"))
	away_team_display_name = str(match_overrides.get("away_team_name", "Equipo visitante"))
	_switch_controlled_player_for_selected_club()
	if player == null or not is_instance_valid(player):
		gesture_hint_label.text = "No se pudo preparar el futbolista controlado."
		return
	var result: Dictionary = match_11v11_controller.start_match(player, ball, match_settings)
	if not bool(result.get("ok", false)):
		gesture_hint_label.text = str(result.get("error", "No se pudo iniciar el partido."))
		return
	score_home = 0
	score_away = 0
	_reset_ball()
	if game_hub != null and game_hub.root != null:
		game_hub.root.visible = false
	if touch_controls != null:
		touch_controls.visible = DisplayServer.is_touchscreen_available()
	if match_camera != null:
		match_camera.position = Vector3(0.0, 72.0, 24.0)
		match_camera.rotation_degrees = Vector3(-68.0, 0.0, 0.0)
		match_camera.fov = 76.0
	score_label.text = "FÚTBOL NOVA   0 - 0   ·   11 vs 11"
	if match_clock_label != null:
		match_clock_label.text = "PRIMER TIEMPO  %02d:00" % selected_half_minutes
	if continue_period_button != null:
		continue_period_button.visible = false
	if match_half_length_option != null:
		match_half_length_option.visible = false
	if match_clock_mode_option != null:
		match_clock_mode_option.visible = false
	if match_extra_time_check != null:
		match_extra_time_check.visible = false
	if match_penalties_check != null:
		match_penalties_check.visible = false
	if match_start_button != null:
		match_start_button.visible = false
	if catalog_button != null:
		catalog_button.visible = false
	if addons_button != null:
		addons_button.visible = false
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.text = "%s  0 - 0  %s" % [home_team_display_name, away_team_display_name]
	gesture_hint_label.text = "Amistoso: %s vs %s. Controlas a %s." % [home_team_display_name, away_team_display_name, "Máximo Padilla" if home_team_display_name == "Litoral Barcelona" else "Anier Cumbá"]
	print("Fútbol Nova: partido local 11v11 iniciado con reloj por períodos.")

func _on_match_clock_updated(phase: String, _elapsed_seconds: float, remaining_seconds: float, _added_seconds: int) -> void:
	if match_clock_label == null:
		return
	var remaining := maxi(0, int(ceil(remaining_seconds)))
	match_clock_label.text = "%s  %02d:%02d" % [_match_phase_label(phase), int(remaining / 60), remaining % 60]

func _on_period_break_reached(phase: String) -> void:
	if continue_period_button == null:
		return
	continue_period_button.text = "CONTINUAR SEGUNDO TIEMPO" if phase == "half_time" else "CONTINUAR PRÓRROGA"
	continue_period_button.visible = true
	if gesture_hint_label != null:
		gesture_hint_label.text = "Descanso: revisa el partido y pulsa Continuar cuando estés listo."

func _continue_match_after_period_break() -> void:
	if match_11v11_controller != null and match_11v11_controller.continue_after_period_break():
		continue_period_button.visible = false

func _on_match_finished(phase: String) -> void:
	if continue_period_button != null:
		continue_period_button.visible = false
	if match_half_length_option != null:
		match_half_length_option.visible = false
	if match_clock_mode_option != null:
		match_clock_mode_option.visible = false
	if match_extra_time_check != null:
		match_extra_time_check.visible = false
	if match_penalties_check != null:
		match_penalties_check.visible = false
	if match_start_button != null:
		match_start_button.visible = true
	if catalog_button != null:
		catalog_button.visible = true
	if addons_button != null:
		addons_button.visible = true
	if match_clock_label != null:
		match_clock_label.text = "PENALTIS PENDIENTES" if phase == "penalty_shootout" else "FINAL DEL PARTIDO"
	if gesture_hint_label != null:
		gesture_hint_label.text = "La tanda de penaltis requiere su motor específico." if phase == "penalty_shootout" else "Partido finalizado."

func _match_phase_label(phase: String) -> String:
	match phase:
		"first_half":
			return "PRIMER TIEMPO"
		"second_half":
			return "SEGUNDO TIEMPO"
		"extra_time_first_half":
			return "PRÓRROGA 1"
		"extra_time_second_half":
			return "PRÓRROGA 2"
		"half_time":
			return "DESCANSO"
		"extra_time_half_time":
			return "DESCANSO PRÓRROGA"
		_:
			return "PARTIDO"

func _process(delta: float) -> void:
	if match_11v11_controller == null or not match_11v11_controller.is_match_active() or match_camera == null or ball == null:
		return
	var target := ball.global_position
	var desired_position := Vector3(target.x * 0.18, 72.0, target.z + 24.0)
	match_camera.position = match_camera.position.lerp(desired_position, clampf(delta * 1.6, 0.0, 1.0))
	match_camera.look_at(Vector3(target.x * 0.18, 0.0, target.z), Vector3.UP)
