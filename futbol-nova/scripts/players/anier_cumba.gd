extends "res://scripts/player_controller.gd"
class_name AnierCumba

## Anier Cumbá: 3D-only procedural character blockout.
## Height is calibrated to 1.71 world units. Replace the procedural visual
## with the final skinned likeness model when that asset is ready.

@export var player_height_m := 1.71
@export var player_weight_kg := 65.0
@export var shirt_number := 35

var visual_root: Node3D
var animation_driver: Node
var _limbs: Dictionary = {}
var _phase := 0.0

func _ready() -> void:
	_build_visual()
	var module_script := load("res://modules/nova_3d_animation/nova_3d_animation.gd")
	if module_script:
		animation_driver = module_script.new()
		add_child(animation_driver)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_phase += delta * (12.0 if Vector2(velocity.x, velocity.z).length() > 4.0 else 8.0)
	_update_procedural_pose()
	if animation_driver:
		var horizontal_speed := Vector2(velocity.x, velocity.z).length()
		var state := "idle"
		if horizontal_speed > 0.15:
			state = "sprint" if horizontal_speed > move_speed * 0.72 else "run"
		animation_driver.play_state(state)

func _build_visual() -> void:
	visual_root = Node3D.new()
	visual_root.name = "AnierVisual3D"
	add_child(visual_root)
	# Scale every generated dimension against the requested 171 cm height.
	var scale_factor := player_height_m / 1.71
	visual_root.scale = Vector3.ONE * scale_factor
	_add_capsule("torso", Vector3(0, 1.12, 0), Vector3(0.37, 0.48, 0.22), Color("#E9E9E9"))
	_add_capsule("shorts", Vector3(0, 0.82, 0), Vector3(0.34, 0.23, 0.22), Color("#F4F4F4"))
	# Untucked team shirt: extended hem sits visibly over the shorts waistband.
	_add_capsule("shirt_untucked_hem", Vector3(0, 0.91, -0.012), Vector3(0.355, 0.12, 0.225), Color("#E9E9E9"))
	_add_capsule("neck", Vector3(0, 1.43, 0), Vector3(0.105, 0.13, 0.105), Color("#75452F"))
	# Visible inner-shirt neckline around the neck; neutral blockout material follows the active team kit.
	var inner_shirt_neckline := MeshInstance3D.new()
	inner_shirt_neckline.name = "inner_shirt_neckline"
	var neckline_mesh := TorusMesh.new()
	neckline_mesh.inner_radius = 0.085
	neckline_mesh.outer_radius = 0.112
	neckline_mesh.rings = 24
	neckline_mesh.ring_segments = 8
	inner_shirt_neckline.mesh = neckline_mesh
	inner_shirt_neckline.position = Vector3(0, 1.425, 0)
	inner_shirt_neckline.material_override = _material(Color("#E9E9E9"))
	visual_root.add_child(inner_shirt_neckline)
	_limbs["inner_shirt_neckline"] = inner_shirt_neckline
	_add_sphere("head", Vector3(0, 1.515, 0), Vector3(0.17, 0.15, 0.155), Color("#805039"))
	_add_sphere("short_hair", Vector3(0, 1.665, 0.008), Vector3(0.17, 0.045, 0.155), Color("#171412"))
	_add_sphere("goatee", Vector3(0, 1.385, -0.142), Vector3(0.052, 0.065, 0.025), Color("#171412"))
	_add_sphere("moustache", Vector3(0, 1.445, -0.151), Vector3(0.07, 0.018, 0.018), Color("#171412"))
	for side in [-1.0, 1.0]:
		_add_capsule("upper_leg_%s" % side, Vector3(side * 0.105, 0.59, 0), Vector3(0.105, 0.31, 0.105), Color("#805039"))
		_add_capsule("lower_leg_%s" % side, Vector3(side * 0.105, 0.25, 0), Vector3(0.075, 0.25, 0.075), Color("#805039"))
		_add_box("boot_%s" % side, Vector3(side * 0.105, 0.055, -0.055), Vector3(0.13, 0.09, 0.24), Color("#C62828"))
		_add_box("boot_sole_%s" % side, Vector3(side * 0.105, 0.012, -0.055), Vector3(0.132, 0.018, 0.242), Color("#171923"))
		_add_box("boot_gold_design_%s" % side, Vector3(side * 0.105, 0.101, -0.055), Vector3(0.014, 0.006, 0.19), Color("#D4AF37"))
		_add_box("boot_black_design_%s" % side, Vector3(side * 0.105 + side * 0.052, 0.057, -0.055), Vector3(0.008, 0.035, 0.15), Color("#171923"))
		_add_box("shin_guard_%s" % side, Vector3(side * 0.105, 0.255, -0.078), Vector3(0.082, 0.235, 0.025), Color("#D9DDE3"))
		# Long team-kit socks cover the shin guards and extend above the knee.
		_add_capsule("long_sock_%s" % side, Vector3(side * 0.105, 0.39, -0.002), Vector3(0.079, 0.33, 0.079), Color("#E9E9E9"))
		_add_capsule("upper_arm_%s" % side, Vector3(side * 0.255, 1.19, 0), Vector3(0.075, 0.24, 0.075), Color("#E9E9E9"))
		_add_capsule("forearm_%s" % side, Vector3(side * 0.29, 0.91, 0), Vector3(0.06, 0.19, 0.06), Color("#805039"))
		# Long-sleeve inner shirt; neutral blockout color follows the active team kit at final material binding.
		# Snug compression fit: close to the forearm without a loose sleeve silhouette.
		_add_capsule("inner_shirt_sleeve_%s" % side, Vector3(side * 0.29, 0.91, -0.002), Vector3(0.0615, 0.195, 0.0615), Color("#E9E9E9"))
		_add_sphere("hand_%s" % side, Vector3(side * 0.29, 0.76, 0), Vector3(0.055, 0.07, 0.045), Color("#805039"))
		_add_sphere("glove_%s" % side, Vector3(side * 0.29, 0.76, -0.006), Vector3(0.061, 0.076, 0.052), Color("#171923"))
		_add_box("glove_red_detail_%s" % side, Vector3(side * 0.29, 0.785, -0.054), Vector3(0.07, 0.012, 0.006), Color("#C62828"))
		_add_box("glove_gold_detail_%s" % side, Vector3(side * 0.29, 0.765, -0.055), Vector3(0.07, 0.008, 0.006), Color("#D4AF37"))
	# Captain armband on the left upper arm. Neutral blockout material only:
	# replace it with the captain-armband design belonging to the active team.
	_add_box("captain_armband", Vector3(-0.255, 1.205, -0.078), Vector3(0.145, 0.045, 0.012), Color("#FFFFFF"))
	_add_box("shirt_35", Vector3(0, 1.18, -0.115), Vector3(0.14, 0.12, 0.012), Color("#171923"))
	_add_box("shirt_name", Vector3(0, 1.25, 0.115), Vector3(0.22, 0.035, 0.012), Color("#171923"))

func _add_sphere(label: String, pos: Vector3, dimensions: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	node.mesh = mesh
	node.scale = dimensions * 2.0
	node.position = pos
	node.material_override = _material(color)
	visual_root.add_child(node)
	_limbs[label] = node

func _add_capsule(label: String, pos: Vector3, dimensions: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	node.mesh = mesh
	node.scale = dimensions * 2.0
	node.position = pos
	node.material_override = _material(color)
	visual_root.add_child(node)
	_limbs[label] = node

func _add_box(label: String, pos: Vector3, dimensions: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	node.mesh = mesh
	node.scale = dimensions
	node.position = pos
	node.material_override = _material(color)
	visual_root.add_child(node)
	_limbs[label] = node

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material

func _update_procedural_pose() -> void:
	var speed := Vector2(velocity.x, velocity.z).length()
	var moving := speed > 0.15
	var swing := sin(_phase) * (0.42 if moving else 0.025)
	for side in [-1.0, 1.0]:
		var leg = _limbs.get("upper_leg_%s" % side)
		var arm = _limbs.get("upper_arm_%s" % side)
		if leg:
			leg.rotation.x = swing * side
		if arm:
			arm.rotation.x = -swing * side * 0.72
	var torso = _limbs.get("torso")
	if torso:
		torso.position.y = 1.12 + (absf(sin(_phase * 2.0)) * 0.025 if moving else 0.0)
