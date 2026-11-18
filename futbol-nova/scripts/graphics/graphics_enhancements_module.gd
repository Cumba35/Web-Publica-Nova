extends RefCounted
class_name NovaGraphicsEnhancementsModule

const PACKAGE_ID := "graphics_enhancements"
const CONFIG_FILE := "graphics_profiles.json"
const INSTALL_ROOT := "user://futbol_nova/packages/"

static func apply_to(world: WorldEnvironment, sun: DirectionalLight3D) -> Dictionary:
	if world == null or world.environment == null or sun == null:
		return {"ok": false, "reason": "No se recibió el entorno 3D o la luz principal."}
	if not ContentPackages.is_package_installed(PACKAGE_ID):
		return {"ok": false, "reason": "El módulo Mejoras gráficas no está instalado."}
	var installed: Dictionary = ContentPackages.get_installed_packages().get(PACKAGE_ID, {})
	var root := str(installed.get("installed_path", ""))
	if not root.begins_with(INSTALL_ROOT) or root.contains(".."):
		return {"ok": false, "reason": "La ruta instalada del módulo no es válida."}
	var config_path := root.path_join(CONFIG_FILE)
	if not FileAccess.file_exists(config_path):
		return {"ok": false, "reason": "Falta graphics_profiles.json."}
	var file := FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": "No se pudo leer el perfil gráfico."}
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"ok": false, "reason": "El archivo de perfiles gráficos no contiene un objeto JSON."}
	var profiles: Dictionary = parsed.get("profiles", {})
	var selected := str(parsed.get("default_profile", "mobile_balanced"))
	if not profiles.has(selected) or not (profiles[selected] is Dictionary):
		return {"ok": false, "reason": "No existe el perfil gráfico predeterminado."}
	var profile: Dictionary = profiles[selected]
	var env := world.environment
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = clampf(float(profile.get("exposure", 1.0)), 0.75, 1.35)
	env.ambient_light_energy = clampf(float(profile.get("ambient_energy", 0.62)), 0.35, 1.0)
	sun.light_energy = clampf(float(profile.get("sun_energy", 1.2)), 0.75, 1.5)
	sun.shadow_enabled = bool(profile.get("shadows_enabled", true))
	sun.shadow_bias = clampf(float(profile.get("shadow_bias", 0.06)), 0.02, 0.15)
	sun.shadow_normal_bias = clampf(float(profile.get("shadow_normal_bias", 1.2)), 0.5, 2.5)
	var color_value := str(profile.get("sun_color", "#fff4e5"))
	if color_value.is_valid_html_color():
		sun.light_color = Color.from_string(color_value, Color.WHITE)
	return {"ok": true, "profile": selected, "message": "Mejoras gráficas activadas."}
