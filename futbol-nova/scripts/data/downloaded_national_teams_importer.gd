extends RefCounted
class_name NovaDownloadedNationalTeamsImporter

const PLAYER_PROFILE = preload("res://scripts/data/player_profile.gd")

static func load_installed_packages(installed_index: Dictionary) -> Dictionary:
	var teams_by_id := {}
	var players_by_id := {}
	var imported_packages := 0
	var errors := PackedStringArray()
	for package_id in installed_index:
		var record: Dictionary = installed_index[package_id]
		if str(record.get("content_type", "")) != "national_teams":
			continue
		var root := str(record.get("installed_path", ""))
		var payload := _read_payload(root, str(package_id), errors)
		if payload.is_empty():
			continue
		if int(payload.get("schema_version", 0)) != 1 or str(payload.get("package_type", "")) != "national_teams":
			errors.append("Esquema de selecciones no compatible: " + str(package_id))
			continue
		var local_players := {}
		var local_teams := {}
		var valid := true
		for player in payload.get("players", []):
			if not player is Dictionary:
				valid = false
				errors.append("Jugador inválido en paquete de selecciones " + str(package_id))
				continue
			var player_id := str(player.get("id", ""))
			if player_id.is_empty() or local_players.has(player_id) or players_by_id.has(player_id):
				valid = false
				errors.append("ID de jugador de selección vacío o duplicado: " + player_id)
			for issue in PLAYER_PROFILE.validate(player):
				valid = false
				errors.append("Jugador " + player_id + ": " + str(issue))
			local_players[player_id] = player.duplicate(true)
		for national_team in payload.get("national_teams", []):
			if not national_team is Dictionary:
				valid = false
				errors.append("Selección nacional inválida en " + str(package_id))
				continue
			var team_id := str(national_team.get("id", ""))
			var roster: Array = national_team.get("player_ids", [])
			for field in ["name", "association_code", "confederation"]:
				if str(national_team.get(field, "")).is_empty():
					valid = false
					errors.append("Selección " + team_id + " sin campo " + field)
			if team_id.is_empty() or local_teams.has(team_id) or teams_by_id.has(team_id):
				valid = false
				errors.append("ID de selección nacional vacío o duplicado: " + team_id)
			if roster.size() < 11:
				valid = false
				errors.append("La selección " + team_id + " tiene menos de 11 jugadores")
			var seen := {}
			for player_id in roster:
				var key := str(player_id)
				if seen.has(key) or (not local_players.has(key) and not players_by_id.has(key)):
					valid = false
					errors.append("Plantilla de " + team_id + " contiene jugador duplicado o inexistente: " + key)
				seen[key] = true
			local_teams[team_id] = national_team.duplicate(true)
		if valid:
			for player_id in local_players:
				players_by_id[player_id] = local_players[player_id]
			for team_id in local_teams:
				teams_by_id[team_id] = local_teams[team_id]
			imported_packages += 1
	return {"ok": errors.is_empty(), "packages_imported": imported_packages, "national_teams_by_id": teams_by_id, "players_by_id": players_by_id, "errors": errors}

static func _read_payload(root: String, package_id: String, errors: PackedStringArray) -> Dictionary:
	for filename in ["national_teams_package.json", "content.json"]:
		var path := root.path_join(filename)
		if not FileAccess.file_exists(path):
			continue
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			errors.append("No se pudo abrir paquete nacional: " + package_id)
			return {}
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			return parsed
		errors.append("JSON inválido en paquete nacional: " + package_id)
		return {}
	errors.append("Falta national_teams_package.json o content.json en " + package_id)
	return {}
