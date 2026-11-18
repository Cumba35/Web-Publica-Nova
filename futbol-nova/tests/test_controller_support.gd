extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/input/controller_support_module.gd")
	assert(script != null, "Controller module script must load")
	var module = script.new()
	root.add_child(module)
	await process_frame
	assert(not module.enabled, "Controller module must stay disabled without installed package")
	assert(module.get_status().connected_count == Input.get_connected_joypads().size())
	print("Controller module gating tests passed")
	quit(0)
