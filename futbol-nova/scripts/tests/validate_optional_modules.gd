extends SceneTree

const MANIFEST_PATH := "res://data/game_modules_manifest.json"
const CATALOG_PATH := "res://data/optional_modules_catalog.json"
const PROFILE_PATH := "res://modules/graphics_enhancements/graphics_profiles.json"
const ADAPTER_PATH := "res://scripts/graphics/graphics_enhancements_module.gd"
const MAIN_PATH := "res://scripts/main.gd"
const PACKAGE_MANAGER_PATH := "res://scripts/data/content_package_manager.gd"
const OPTIONAL_MODULES_UI_PATH := "res://scripts/ui/optional_modules_catalog.gd"
const CONTINENTAL_MODULE_REGISTRY_PATH := "res://modules/continental_competitions/module_registry.json"

func _initialize() -> void:
	var errors := PackedStringArray()
	var manifest := _read_json(MANIFEST_PATH, errors)
	var catalog := _read_json(CATALOG_PATH, errors)
	var profiles := _read_json(PROFILE_PATH, errors)
	_validate_eight_module_contracts(manifest, catalog, errors)
	_validate_continental_modules(errors)
	var graphics_module: Dictionary = {}
	for module in manifest.get("modules", []):
		if str(module.get("id", "")) == "futbol-nova-graphics-enhancements":
			graphics_module = module
	if graphics_module.is_empty():
		errors.append("Falta el agregado futbol-nova-graphics-enhancements.")
	else:
		if str(graphics_module.get("name", "")) != "Mejoras gráficas":
			errors.append("El nombre del agregado gráfico no coincide.")
		if str(graphics_module.get("package_id", "")) != "graphics_enhancements":
			errors.append("El ID del paquete gráfico no coincide.")
		if str(graphics_module.get("content_type", "")) != "graphics_module":
			errors.append("El agregado gráfico debe usar content_type=graphics_module.")
		if bool(graphics_module.get("downloadable", true)):
			errors.append("El módulo gráfico no debe ofrecerse antes de validar su paquete.")
	var catalog_found := false
	for module in catalog.get("modules", []):
		if str(module.get("id", "")) == "futbol-nova-graphics-enhancements":
			catalog_found = true
			if str(module.get("package", {}).get("package_id", "")) != "graphics_enhancements":
				errors.append("El catálogo unificado no referencia el paquete gráfico correcto.")
	if not catalog_found:
		errors.append("El módulo Mejoras gráficas no aparece en el catálogo de agregados.")
	var expected_tas_dependencies := ["caribbean_champions_league", "south_america_champions_league", "north_central_america_champions_league"]
	var catalog_modules := {}
	for item in catalog.get("modules", []):
		if item is Dictionary:
			catalog_modules[str(item.get("id", ""))] = item
	if not catalog_modules.has("american_super_champions_tas"):
		errors.append("Falta el TAS en el catálogo de módulos.")
	else:
		var tas_catalog: Dictionary = catalog_modules["american_super_champions_tas"]
		for dependency_id in expected_tas_dependencies:
			if not catalog_modules.has(dependency_id):
				errors.append("Falta una liga regional requerida por el TAS: " + dependency_id)
			if not tas_catalog.get("dependencies", []).has(dependency_id):
				errors.append("El catálogo TAS no declara la dependencia: " + dependency_id)
			if not tas_catalog.get("package", {}).get("dependencies", []).has(dependency_id):
				errors.append("El paquete TAS no declara la dependencia: " + dependency_id)
			if str(tas_catalog.get("package", {}).get("dependency_versions", {}).get(dependency_id, "")) != "1.0.0":
				errors.append("El paquete TAS no fija la versión requerida de " + dependency_id)
	var tas_manifest := _read_json("res://modules/continental_competitions/american_super_champions_tas/module.json", errors)
	for dependency_id in expected_tas_dependencies:
		if not tas_manifest.get("dependencies", []).has(dependency_id):
			errors.append("El manifiesto TAS no declara la dependencia: " + dependency_id)
		if str(tas_manifest.get("dependency_versions", {}).get(dependency_id, "")) != "1.0.0":
			errors.append("El manifiesto TAS no fija la versión requerida de " + dependency_id)
	if FileAccess.file_exists(OPTIONAL_MODULES_UI_PATH):
		var optional_ui_text := FileAccess.get_file_as_string(OPTIONAL_MODULES_UI_PATH)
		if not optional_ui_text.contains("_collect_module_downloads") or not optional_ui_text.contains("enqueue_packages(packages)"):
			errors.append("La interfaz no resuelve y encola las dependencias del TAS.")
	else:
		errors.append("No se encontró la interfaz de descarga de módulos.")
	if not FileAccess.file_exists(ADAPTER_PATH):
		errors.append("Falta el adaptador runtime de mejoras gráficas.")
	if not FileAccess.file_exists(MAIN_PATH):
		errors.append("Falta el script principal.")
	else:
		var main_text := FileAccess.get_file_as_string(MAIN_PATH)
		if not main_text.contains("GRAPHICS_MODULE.apply_to"):
			errors.append("El módulo gráfico no está conectado a la creación de iluminación.")
		if not main_text.contains("_open_optional_modules_catalog"):
			errors.append("El HUD no abre la pantalla de agregados.")
	if FileAccess.file_exists(PACKAGE_MANAGER_PATH):
		var manager_text := FileAccess.get_file_as_string(PACKAGE_MANAGER_PATH)
		if not manager_text.contains('"graphics_module"'):
			errors.append("El gestor de paquetes no admite graphics_module.")
		if not manager_text.contains('"input_extension"'):
			errors.append("El gestor de paquetes no admite input_extension para mandos.")
		if not manager_text.contains('"continental_competition_module"'):
			errors.append("El gestor de paquetes no admite módulos de competiciones continentales.")
		if not manager_text.contains("installed_dependencies.has(str(dependency_id))"):
			errors.append("El gestor no bloquea el TAS si una liga regional requerida falla.")
		if not manager_text.contains("required_dependencies.has(package_id)"):
			errors.append("El gestor permite desinstalar una liga que usa un módulo TAS instalado.")
		if not manager_text.contains("installed_version != required_version"):
			errors.append("El gestor no verifica la versión requerida de las ligas del TAS.")
	else:
		errors.append("No se encontró el gestor de paquetes.")
	var profile_map: Dictionary = profiles.get("profiles", {})
	var default_profile := str(profiles.get("default_profile", ""))
	if not profile_map.has(default_profile):
		errors.append("El perfil gráfico predeterminado no existe.")
	for profile_id in ["mobile_balanced", "high_quality", "battery_saver"]:
		if not profile_map.has(profile_id):
			errors.append("Falta el perfil gráfico: " + profile_id)
	if errors.is_empty():
		print("Fútbol Nova: agregado Mejoras gráficas, pantalla Agregados y gestor de paquetes validados estructuralmente.")
		quit(0)
	else:
		for error in errors:
			push_error(error)
		quit(1)


func _validate_eight_module_contracts(manifest: Dictionary, catalog: Dictionary, errors: PackedStringArray) -> void:
	var required_ids := [
		"futbol-nova-commentary",
		"futbol-nova-audio",
		"futbol-nova-stadiums",
		"futbol-nova-visual-enhancements",
		"futbol-nova-world-leagues",
		"futbol-nova-national-teams",
		"futbol-nova-extra-competitions",
		"futbol-nova-controller-support"
	]
	var required_fields := [
		"id", "name", "description", "version", "min_game_version",
		"platforms", "package_format", "download_url", "download_size_bytes",
		"checksum_sha256", "dependencies", "content_status", "downloadable"
	]
	var found := {}
	var catalog_modules := {}
	for item in catalog.get("modules", []):
		if item is Dictionary:
			catalog_modules[str(item.get("id", ""))] = item
	var controller_catalog := _read_json("res://data/controller_modules_catalog.json", errors)
	var controller_package: Dictionary = {}
	for item in controller_catalog.get("modules", []):
		if str(item.get("module_id", "")) == "controller_support":
			controller_package = item
	if controller_package.is_empty():
		errors.append("Falta el paquete fuente del módulo controller_support.")
	else:
		if str(controller_package.get("content_type", "")) != "input_extension":
			errors.append("El paquete de mandos debe declarar content_type=input_extension.")
		if str(controller_package.get("content_status", "")) != "testing" or bool(controller_package.get("downloadable", true)):
			errors.append("El paquete de mandos debe permanecer en pruebas y no descargable.")
	for module in manifest.get("modules", []):
		if not (module is Dictionary):
			errors.append("El manifiesto contiene una ficha de módulo inválida.")
			continue
		var module_id := str(module.get("id", ""))
		if not required_ids.has(module_id):
			continue
		found[module_id] = true
		var catalog_item: Dictionary = catalog_modules.get(module_id, {})
		if catalog_item.is_empty():
			errors.append("El módulo no está sincronizado en el catálogo de agregados: " + module_id)
		else:
			if str(catalog_item.get("status", "")) != str(module.get("status", "")):
				errors.append("El estado del manifiesto y el catálogo no coincide: " + module_id)
			if bool(catalog_item.get("downloadable", true)) != bool(module.get("downloadable", false)):
				errors.append("La disponibilidad de descarga no coincide entre catálogos: " + module_id)
			if catalog_item.get("dependencies", []) != module.get("dependencies", []):
				errors.append("Las dependencias no coinciden entre catálogos: " + module_id)
			if str(catalog_item.get("existing_system", "")) != str(module.get("existing_system", "")):
				errors.append("El sistema existente referenciado no coincide: " + module_id)
		for field in required_fields:
			if not module.has(field):
				errors.append("Falta el campo contractual " + field + " en " + module_id)
		if not (module.get("platforms", null) is Array) or not (module.get("dependencies", null) is Array):
			errors.append("Plataformas o dependencias tienen formato inválido en " + module_id)
		if not (module.get("publication_blockers", []) is Array) or module.get("publication_blockers", []).is_empty():
			errors.append("El módulo debe documentar sus bloqueos de publicación: " + module_id)
		if bool(module.get("downloadable", true)):
			errors.append("Un módulo sin validación de publicación aparece como descargable: " + module_id)
		if module_id == "futbol-nova-controller-support":
			if str(module.get("status", "")) != "testing" or str(module.get("content_status", "")) != "testing":
				errors.append("El módulo de mandos debe permanecer en pruebas.")
			if str(module.get("contract_state", "")) != "package_metadata_present_validation_pending":
				errors.append("El contrato de mandos no refleja metadatos existentes con validación pendiente.")
			if str(module.get("version", "")) != str(controller_package.get("version", "")):
				errors.append("La versión del paquete de mandos no coincide con su catálogo fuente.")
			if str(module.get("min_game_version", "")) != str(controller_package.get("required_game_version", "")):
				errors.append("La versión mínima del juego para mandos no coincide.")
			if str(module.get("package_format", "")) != str(controller_package.get("content_format", "")):
				errors.append("El formato del paquete de mandos no coincide.")
			if str(module.get("download_url", "")) != str(controller_package.get("download_url", "")) or not str(module.get("download_url", "")).begins_with("https://"):
				errors.append("La URL HTTPS del paquete de mandos no coincide con el catálogo fuente.")
			if int(module.get("download_size_bytes", 0)) != int(controller_package.get("download_size_bytes", -1)):
				errors.append("El tamaño del paquete de mandos no coincide.")
			if str(module.get("checksum_sha256", "")) != str(controller_package.get("checksum_sha256", "")) or str(module.get("checksum_sha256", "")).length() != 64:
				errors.append("El SHA-256 del paquete de mandos no coincide.")
			var optional_entry: Dictionary = catalog_modules.get(module_id, {})
			var optional_package: Dictionary = optional_entry.get("package", {})
			if optional_package.is_empty() or str(optional_package.get("checksum_sha256", "")) != str(module.get("checksum_sha256", "")):
				errors.append("El catálogo de agregados no contiene los metadatos íntegros del paquete de mandos.")
			for platform in module.get("platforms", []):
				if not controller_package.get("platforms", []).has(platform):
					errors.append("La plataforma del módulo de mandos no coincide con el catálogo fuente: " + str(platform))
		else:
			if str(module.get("content_status", "")) != str(module.get("status", "")):
				errors.append("content_status y status no coinciden en " + module_id)
			if str(module.get("contract_state", "")) != "metadata_contract_present_package_metadata_pending":
				errors.append("El estado contractual no identifica metadatos pendientes: " + module_id)
			if module.get("download_url", null) != null or module.get("checksum_sha256", null) != null:
				errors.append("No se deben inventar URL ni SHA-256 para " + module_id)
			if module.get("download_size_bytes", null) != null:
				errors.append("No se debe inventar el tamaño del paquete: " + module_id)
	for module_id in required_ids:
		if not found.has(module_id):
			errors.append("Falta el contrato del módulo opcional: " + module_id)

func _validate_continental_modules(errors: PackedStringArray) -> void:
	var registry := _read_json(CONTINENTAL_MODULE_REGISTRY_PATH, errors)
	var modules: Array = registry.get("modules", [])
	var expected := {
		"caribbean_champions_league": "caribbean_champions_league_nova",
		"south_america_champions_league": "south_america_champions_league_nova",
		"north_central_america_champions_league": "north_central_america_champions_league_nova",
		"american_super_champions_tas": "american_super_champions_tas",
		"european_club_competitions": "uefa_champions_league_nova",
		"african_club_competitions": "caf_champions_league_nova",
		"asian_club_competitions": "afc_champions_league_elite_nova",
		"oceania_club_competitions": "ofc_champions_league_nova",
		"global_club_competitions": "fifa_intercontinental_cup_nova"
	}
	var found := {}
	for entry in modules:
		if not entry is Dictionary:
			errors.append("El registro continental contiene un módulo inválido.")
			continue
		var module_id := str(entry.get("module_id", ""))
		var manifest_path := "res://modules/continental_competitions/" + str(entry.get("manifest", ""))
		if not expected.has(module_id) or found.has(module_id):
			errors.append("Módulo continental desconocido o duplicado: " + module_id)
			continue
		found[module_id] = true
		var manifest := _read_json(manifest_path, errors)
		if str(manifest.get("module_id", "")) != module_id:
			errors.append("El manifiesto no coincide con el ID registrado: " + module_id)
		if str(manifest.get("competition_id", "")) != str(expected[module_id]):
			errors.append("El ID de competición no coincide en el módulo: " + module_id)
		if module_id in ["caribbean_champions_league", "south_america_champions_league", "north_central_america_champions_league", "american_super_champions_tas"]:
			if str(manifest.get("module_boundary", "")) != "independent_competition_module" or not bool(manifest.get("offline_play", false)):
				errors.append("El módulo americano debe declarar su límite independiente y soporte offline: " + module_id)
			var engine_path := "res://" + str(manifest.get("engine", ""))
			if not FileAccess.file_exists(engine_path):
				errors.append("No existe el motor declarado por el módulo: " + engine_path)
			var config_path := str(manifest.get("configuration", "")).split("#")[0]
			if not config_path.is_empty() and not FileAccess.file_exists("res://" + config_path):
				errors.append("No existe la configuración declarada por el módulo: " + config_path)
		else:
			if str(manifest.get("category", "")) != "international_club_competition" or not bool(manifest.get("offline_play", false)):
				errors.append("El módulo global debe declarar categoría de clubes y soporte offline: " + module_id)
			var catalog_path := "res://" + str(manifest.get("catalog", ""))
			if not FileAccess.file_exists(catalog_path):
				errors.append("No existe el catálogo declarado por el módulo: " + catalog_path)
			var catalog := _read_json(catalog_path, errors)
			var found_competition := false
			for competition in catalog.get("competitions", []):
				if str(competition.get("id", "")) == str(expected[module_id]):
					found_competition = true
			if not found_competition:
				errors.append("El catálogo no contiene la competición principal de " + module_id)
	for module_id in expected:
		if not found.has(module_id):
			errors.append("Falta el módulo continental independiente: " + str(module_id))


func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("No existe el archivo: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		errors.append("JSON inválido: " + path)
		return {}
	return parsed
