extends "res://scripts/players/anier_cumba.gd"
class_name MaximoPadilla

## Modelo 3D procedural inicial de Máximo Padilla.
## La fotografía original se conserva como referencia; este bloque geométrico
## no pretende sustituir un esculpido facial de alta fidelidad.

func _init() -> void:
	player_height_m = 1.80
	player_weight_kg = 75.0
	shirt_number = 30
	# MCD recuperador inspirado en el Casemiro del Real Madrid.
	move_speed = 7.2
	acceleration = 21.5
	pass_force = 5.9
	shot_force = 9.5
	tackle_reach_bonus = 0.18
	tackle_angle_bonus = 0.08


func _build_visual() -> void:
	visual_root = Node3D.new()
	visual_root.name = "MaximoPadillaVisual3D"
	add_child(visual_root)
	visual_root.scale = Vector3.ONE * (player_height_m / 1.71)
	# Cuerpo y equipación blaugrana de diseño inspirado en Barcelona.
	_add_capsule("torso", Vector3(0, 1.12, 0), Vector3(0.37, 0.48, 0.22), Color("#A51E3B"))
	_add_capsule("shirt_blue_panel", Vector3(0.13, 1.12, -0.012), Vector3(0.13, 0.46, 0.224), Color("#173B79"))
	_add_capsule("shirt_untucked_hem", Vector3(0, 0.91, -0.012), Vector3(0.355, 0.12, 0.225), Color("#A51E3B"))
	_add_capsule("shorts", Vector3(0, 0.82, 0), Vector3(0.34, 0.23, 0.22), Color("#172B55"))
	_add_capsule("neck", Vector3(0, 1.43, 0), Vector3(0.105, 0.13, 0.105), Color("#75452F"))
	_add_sphere("head", Vector3(0, 1.515, 0), Vector3(0.17, 0.15, 0.155), Color("#75452F"))
	_add_sphere("short_hair", Vector3(0, 1.665, 0.008), Vector3(0.17, 0.045, 0.155), Color("#171412"))
	# Rasgos faciales sencillos orientados hacia el frente (-Z), guiados por la foto.
	for side in [-1.0, 1.0]:
		_add_sphere("ear_%s" % side, Vector3(side * 0.166, 1.515, -0.004), Vector3(0.035, 0.052, 0.038), Color("#75452F"))
		_add_sphere("eye_white_%s" % side, Vector3(side * 0.061, 1.552, -0.143), Vector3(0.026, 0.014, 0.012), Color("#E8E3D8"))
		_add_sphere("eye_pupil_%s" % side, Vector3(side * 0.061, 1.552, -0.155), Vector3(0.009, 0.010, 0.006), Color("#171412"))
		_add_capsule("eyebrow_%s" % side, Vector3(side * 0.061, 1.581, -0.143), Vector3(0.033, 0.009, 0.009), Color("#171412"))
	_add_sphere("nose", Vector3(0, 1.505, -0.166), Vector3(0.026, 0.039, 0.028), Color("#75452F"))
	_add_capsule("mouth", Vector3(0, 1.452, -0.157), Vector3(0.037, 0.008, 0.009), Color("#4B2925"))
	# Cuello de la camiseta interior de compresión, visible alrededor del cuello.
	var neckline := MeshInstance3D.new()
	neckline.name = "inner_shirt_neckline"
	var ring := TorusMesh.new()
	ring.inner_radius = 0.085
	ring.outer_radius = 0.112
	neckline.mesh = ring
	neckline.position = Vector3(0, 1.425, 0)
	neckline.material_override = _material(Color("#E9E9E9"))
	visual_root.add_child(neckline)
	_limbs["inner_shirt_neckline"] = neckline
	for side in [-1.0, 1.0]:
		_add_capsule("upper_leg_%s" % side, Vector3(side * 0.105, 0.59, 0), Vector3(0.105, 0.31, 0.105), Color("#75452F"))
		_add_capsule("lower_leg_%s" % side, Vector3(side * 0.105, 0.25, 0), Vector3(0.075, 0.25, 0.075), Color("#75452F"))
		_add_capsule("long_sock_%s" % side, Vector3(side * 0.105, 0.39, -0.002), Vector3(0.079, 0.33, 0.079), Color("#172B55"))
		_add_box("shin_guard_%s" % side, Vector3(side * 0.105, 0.255, -0.078), Vector3(0.082, 0.235, 0.025), Color("#D9DDE3"))
		_add_box("boot_%s" % side, Vector3(side * 0.105, 0.055, -0.055), Vector3(0.13, 0.09, 0.24), Color("#171923"))
		_add_capsule("upper_arm_%s" % side, Vector3(side * 0.255, 1.19, 0), Vector3(0.075, 0.24, 0.075), Color("#A51E3B"))
		_add_capsule("forearm_%s" % side, Vector3(side * 0.29, 0.91, 0), Vector3(0.06, 0.19, 0.06), Color("#75452F"))
		# The compression sleeve is drawn last so it remains visible over the forearm.
		_add_capsule("inner_shirt_sleeve_%s" % side, Vector3(side * 0.29, 0.91, -0.002), Vector3(0.064, 0.198, 0.064), Color("#E9E9E9"))
		_add_sphere("hand_%s" % side, Vector3(side * 0.29, 0.76, 0), Vector3(0.055, 0.07, 0.045), Color("#75452F"))
	# Name and number are placed on the back (+Z); the player faces -Z.
	_add_back_text("shirt_number_30", "30", Vector3(0, 1.12, 0.226), 64)
	_add_back_text("shirt_name_padilla", "PADILLA", Vector3(0, 1.265, 0.226), 30)

func _add_back_text(node_name: String, value: String, pos: Vector3, size: int) -> void:
	var label := Label3D.new()
	label.name = node_name
	label.text = value
	label.font_size = size
	label.pixel_size = 0.0015
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color("#F5F5F5")
	label.outline_size = 5
	label.outline_modulate = Color("#172B55")
	label.position = pos
	label.rotation_degrees.y = 180.0
	visual_root.add_child(label)
	_limbs[node_name] = label
