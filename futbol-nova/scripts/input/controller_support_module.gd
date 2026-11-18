extends Node
class_name NovaControllerSupportModule

signal controller_connected(device_id: int, device_name: String)
signal controller_disconnected(device_id: int)
signal module_state_changed(enabled: bool, message: String)

const PACKAGE_ID := "controller_support"
const PROFILE_FILE := "controller_profiles.json"
const REQUIRED_ACTIONS := ["move_left", "move_right", "move_forward", "move_back", "pass_ball", "shoot_ball", "skill_action", "pressure_action", "ui_accept", "ui_cancel", "ui_left", "ui_right", "ui_up", "ui_down"]

var enabled := false
var active_device_ids: Array[int] = []
var profile: Dictionary = {}
var deadzone := 0.18
var _bound_events: Array[Dictionary] = []

func _ready() -> void:
	if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.connect(_on_joy_connection_changed)
	if ContentPackages.has_signal("package_installed") and not ContentPackages.package_installed.is_connected(_on_package_installed):
		ContentPackages.package_installed.connect(_on_package_installed)
	_load_installed_module()

func _on_package_installed(package_id: String, _installed_path: String) -> void:
	if package_id == PACKAGE_ID:
		_load_installed_module()

func refresh_module() -> void:
	_load_installed_module()

func _load_installed_module() -> void:
	_clear_bound_events()
	enabled = false
	active_device_ids.clear()
	profile.clear()
	if not ContentPackages.is_package_installed(PACKAGE_ID):
		module_state_changed.emit(false, "Módulo de mando no instalado")
		return
	var installed: Dictionary = ContentPackages.get_installed_packages().get(PACKAGE_ID, {})
	var root := str(installed.get("installed_path", ""))
	if root.is_empty() or not root.begins_with("user://futbol_nova/packages/") or root.contains(".."):
		module_state_changed.emit(false, "Ruta del módulo no válida")
		return
	var config_path := root.path_join(PROFILE_FILE)
	if not FileAccess.file_exists(config_path):
		module_state_changed.emit(false, "Falta controller_profiles.json")
		return
	var file := FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		module_state_changed.emit(false, "No se pudo leer la configuración del mando")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary) or not (parsed.get("profiles", {}) is Dictionary):
		module_state_changed.emit(false, "Configuración del mando inválida")
		return
	var selected := str(parsed.get("default_profile", "generic_gamepad"))
	var profiles: Dictionary = parsed.get("profiles", {})
	if not profiles.has(selected) or not (profiles[selected] is Dictionary):
		module_state_changed.emit(false, "No existe el perfil predeterminado")
		return
	profile = profiles[selected]
	var settings: Dictionary = parsed.get("settings", {})
	deadzone = clampf(float(settings.get("left_stick_deadzone", 0.18)), 0.05, 0.45)
	var actions: Dictionary = profile.get("actions", {})
	for action_name in REQUIRED_ACTIONS:
		if not actions.has(action_name) or not (actions[action_name] is Dictionary):
			module_state_changed.emit(false, "Falta una asignación obligatoria: " + action_name)
			return
		var config: Dictionary = actions[action_name]
		if not _is_valid_binding(config):
			module_state_changed.emit(false, "Asignación inválida: " + action_name)
			return
	_bind_profile(actions)
	enabled = true
	for device_id in Input.get_connected_joypads():
		_register_device(device_id)
	module_state_changed.emit(true, "Módulo de mando activo")

func _is_valid_binding(config: Dictionary) -> bool:
	match str(config.get("type", "")):
		"axis":
			return int(config.get("axis", -1)) >= 0 and int(config.get("axis", -1)) <= 9 and absf(float(config.get("sign", 0))) == 1.0
		"button":
			return int(config.get("button", -1)) >= 0 and int(config.get("button", -1)) <= 63
	return false

func _bind_profile(actions: Dictionary) -> void:
	_clear_bound_events()
	for action_name in actions.keys():
		var action := str(action_name)
		if not InputMap.has_action(action):
			InputMap.add_action(action, deadzone)
		else:
			InputMap.action_set_deadzone(action, deadzone)
		var config: Dictionary = actions[action_name]
		var event: InputEvent
		if str(config.get("type", "")) == "axis":
			var motion := InputEventJoypadMotion.new()
			motion.axis = int(config.get("axis", 0))
			motion.axis_value = float(config.get("sign", 1))
			event = motion
		else:
			var button := InputEventJoypadButton.new()
			button.button_index = int(config.get("button", 0))
			event = button
		InputMap.action_add_event(action, event)
		_bound_events.append({"action": action, "event": event})

func _clear_bound_events() -> void:
	for item in _bound_events:
		var action := str(item.get("action", ""))
		if InputMap.has_action(action):
			InputMap.action_erase_event(action, item.get("event"))
	_bound_events.clear()

func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if not enabled:
		return
	if connected:
		_register_device(device_id)
	else:
		active_device_ids.erase(device_id)
		controller_disconnected.emit(device_id)

func _register_device(device_id: int) -> void:
	if not active_device_ids.has(device_id):
		active_device_ids.append(device_id)
		controller_connected.emit(device_id, Input.get_joy_name(device_id))

func get_status() -> Dictionary:
	return {
		"enabled": enabled,
		"connected_count": active_device_ids.size(),
		"devices": active_device_ids.duplicate(),
		"profile": str(profile.get("display_name", "Mando estándar"))
	}
