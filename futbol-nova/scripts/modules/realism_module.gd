extends RefCounted
class_name NovaRealismModule

## Optional, data-driven realism package. The base game remains playable without it.

const PACKAGE_ID := "futbol_nova_realism"
const CONFIG_FILE := "realism_profile.json"
const INSTALL_ROOT := "user://futbol_nova/packages/"

static func load_profile() -> Dictionary:
	var inactive := {"enabled": false, "profile_id": "base_game"}
	if not ContentPackages.is_package_installed(PACKAGE_ID):
		return inactive
	var installed: Dictionary = ContentPackages.get_installed_packages().get(PACKAGE_ID, {})
	var root := str(installed.get("installed_path", ""))
	if not root.begins_with(INSTALL_ROOT) or root.contains(".."):
		return inactive
	var config_path := root.path_join(CONFIG_FILE)
	if not FileAccess.file_exists(config_path):
		return inactive
	var file := FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		return inactive
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return inactive
	if int(parsed.get("schema_version", 0)) != 1 or str(parsed.get("module_id", "")) != PACKAGE_ID:
		return inactive
	var profile: Dictionary = parsed.get("profile", {})
	if not validate_profile(profile):
		return inactive
	var result := profile.duplicate(true)
	result["enabled"] = true
	return result

static func validate_profile(profile: Dictionary) -> bool:
	if str(profile.get("profile_id", "")) != "realism_balanced":
		return false
	var drain := float(profile.get("movement_fatigue_per_second", -1.0))
	var recovery := float(profile.get("recovery_per_second", -1.0))
	var minimum_speed := float(profile.get("minimum_speed_multiplier", -1.0))
	if drain < 0.0 or drain > 3.0:
		return false
	if recovery < 0.0 or recovery > 3.0:
		return false
	if minimum_speed < 0.5 or minimum_speed > 1.0:
		return false
	return true

static func movement_speed_multiplier(stamina: float, profile: Dictionary) -> float:
	if not bool(profile.get("enabled", false)) or not bool(profile.get("fatigue_enabled", false)):
		return 1.0
	var minimum_speed := clampf(float(profile.get("minimum_speed_multiplier", 0.78)), 0.5, 1.0)
	return lerpf(minimum_speed, 1.0, clampf(stamina / 100.0, 0.0, 1.0))

static func update_stamina(stamina: float, is_moving: bool, delta: float, profile: Dictionary) -> float:
	if not bool(profile.get("enabled", false)) or not bool(profile.get("fatigue_enabled", false)):
		return clampf(stamina, 0.0, 100.0)
	var rate := float(profile.get("movement_fatigue_per_second", 0.10)) if is_moving else -float(profile.get("recovery_per_second", 0.16))
	return clampf(stamina - rate * maxf(0.0, delta), 0.0, 100.0)

static func get_status() -> Dictionary:
	var profile := load_profile()
	return {"enabled": bool(profile.get("enabled", false)), "profile_id": str(profile.get("profile_id", "base_game")), "package_id": PACKAGE_ID}
