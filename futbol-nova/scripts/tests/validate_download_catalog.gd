extends SceneTree

const LEAGUE_MANIFEST := "res://data/league_content_manifest.json"
const REGION_MANIFEST := "res://data/league_regions.json"
const NATIONAL_MANIFEST := "res://data/national_teams_manifest.json"
const LEAGUE_PACKAGE_SCHEMA := "res://data/downloaded_package_schema_v1.json"
const NATIONAL_PACKAGE_SCHEMA := "res://data/national_teams_package_schema_v1.json"
const ASSOCIATION_DIRECTORY := "res://data/national_association_directory.json"
const ADDITIONAL_MEMBERSHIP := "res://data/imports/additional_league_club_membership_2026_27.json"

func _initialize() -> void:
	var errors := PackedStringArray()
	var leagues := _read_json(LEAGUE_MANIFEST, errors)
	var regions := _read_json(REGION_MANIFEST, errors)
	var national := _read_json(NATIONAL_MANIFEST, errors)
	var league_schema := _read_json(LEAGUE_PACKAGE_SCHEMA, errors)
	var national_schema := _read_json(NATIONAL_PACKAGE_SCHEMA, errors)
	var associations := _read_json(ASSOCIATION_DIRECTORY, errors)
	var membership := _read_json(ADDITIONAL_MEMBERSHIP, errors)
	if not league_schema.get("required", []).has("competitions") or league_schema.get("properties", {}).get("package_type", {}).get("const", "") != "league":
		errors.append("El esquema de paquetes de ligas no define package_type=league y competitions.")
	if not national_schema.get("required", []).has("national_teams") or national_schema.get("properties", {}).get("package_type", {}).get("const", "") != "national_teams":
		errors.append("El esquema de selecciones nacionales no está completo.")
	var base: Array = leagues.get("base_leagues", [])
	var additional: Array = leagues.get("downloadable_leagues", [])
	var membership_leagues: Array = membership.get("leagues", [])
	var database_limits: Dictionary = leagues.get("database_limits", {})
	if int(database_limits.get("max_created_leagues", -1)) != 100:
		errors.append("La base activa debe tener un límite estricto de 100 ligas.")
	if str(database_limits.get("scope", "")) != "active_game_database_only":
		errors.append("El límite de 100 debe distinguir la base activa del catálogo reservado.")
	if str(database_limits.get("overflow_policy", "")).is_empty():
		errors.append("Falta la política para conservar ligas fuera del límite.")
	var total_membership_clubs := 0
	var association_ids := {}
	var association_names := {}
	if int(associations.get("association_count", -1)) != 211 or associations.get("associations", []).size() != 211:
		errors.append("El directorio FIFA debe contener exactamente 211 asociaciones.")
	for association in associations.get("associations", []):
		var association_id := str(association.get("association_id", ""))
		var association_name := str(association.get("fifa_name", ""))
		if association_id.is_empty() or association_ids.has(association_id):
			errors.append("ID de asociación FIFA vacío o duplicado: " + association_id)
		if association_name.is_empty() or association_names.has(association_name):
			errors.append("Nombre de asociación FIFA vacío o duplicado: " + association_name)
		association_ids[association_id] = true
		association_names[association_name] = true
	if membership_leagues.size() != 10:
		errors.append("El lote de afiliación debe contener las diez ligas recomendadas.")
	for league in membership_leagues:
		total_membership_clubs += league.get("clubs", []).size()
		if not str(league.get("source", {}).get("url", "")).begins_with("https://"):
			errors.append("Liga sin fuente HTTPS: " + str(league.get("country_code", "")))
		if league.get("clubs", []).size() != int(league.get("club_count", -1)):
			errors.append("El recuento de clubes no coincide en " + str(league.get("country_code", "")))
		var ids := {}
		for club in league.get("clubs", []):
			var club_id := str(club.get("id", ""))
			if club_id.is_empty() or ids.has(club_id):
				errors.append("ID de club vacío o duplicado en " + str(league.get("country_code", "")))
			ids[club_id] = true
	if base.size() != 10:
		errors.append("El juego base debe declarar exactamente diez ligas.")
	for index in range(base.size()):
		if int(base[index].get("rank", -1)) != index + 1:
			errors.append("El ranking de ligas base no está ordenado del 1 al 10.")
	if additional.size() < 10:
		errors.append("El módulo adicional debe recomendar al menos diez ligas.")
	for index in range(additional.size()):
		if int(additional[index].get("rank", -1)) != index + 11:
			errors.append("Las ligas adicionales no siguen el ranking desde el puesto 11.")
		var league: Dictionary = additional[index]
		if bool(league.get("downloadable", false)):
			if str(league.get("content_status", "")) != "published":
				errors.append("Una liga se marcó descargable sin estar publicada: " + str(league.get("package_id", "")))
			var package_url := str(league.get("download_url", ""))
			if not (package_url.begins_with("https://raw.githubusercontent.com/Cumba35/Nova-Workspace/") or package_url.begins_with("https://github.com/Cumba35/Nova-Workspace/releases/download/")):
				errors.append("Paquete publicado fuera del GitHub autorizado de NOVA: " + str(league.get("package_id", "")))
			if str(league.get("checksum_sha256", "")).length() != 64:
				errors.append("Paquete publicado sin SHA-256: " + str(league.get("package_id", "")))
			if int(league.get("download_size_bytes", 0)) <= 0:
				errors.append("Paquete publicado sin tamaño: " + str(league.get("package_id", "")))
	var expected_regions := ["europe", "south_america", "north_central_america_caribbean", "africa", "asia", "oceania"]
	var actual_regions: Array[String] = []
	for region in regions.get("regions", []):
		actual_regions.append(str(region.get("id", "")))
	for region_id in expected_regions:
		if not actual_regions.has(region_id):
			errors.append("Falta la región del catálogo: " + region_id)
	var expected_confederations := ["AFC", "CAF", "CONCACAF", "CONMEBOL", "OFC", "UEFA"]
	var national_confederations: Array = national.get("scope", {}).get("confederations", [])
	for confederation in expected_confederations:
		if not national_confederations.has(confederation):
			errors.append("Falta la confederación: " + confederation)
	var published_national := 0
	for package in national.get("packages", []):
		if bool(package.get("downloadable", false)) and str(package.get("content_status", "")) == "published":
			published_national += 1
			if str(package.get("content_type", "")) != "national_teams":
				errors.append("Paquete nacional publicado sin content_type=national_teams.")
	if published_national != int(national.get("availability", {}).get("published_packages", -1)):
		errors.append("El contador de selecciones publicadas no coincide con el catálogo.")
	if total_membership_clubs != 166:
		errors.append("El lote inicial debe contener 166 clubes de primera división.")
	if errors.is_empty():
		print("Fútbol Nova: catálogo regional válido; límite de 100 ligas activas, 10 ligas adicionales, 166 clubes catalogados y 211 asociaciones FIFA.")
		quit(0)
	else:
		for error in errors:
			push_error(error)
		quit(1)

func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("No existe el manifiesto: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir el manifiesto: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("JSON inválido: " + path)
		return {}
	return parsed
