extends RefCounted
class_name NovaDownloadedLeagueImporter

const PACKAGE_FILE_CANDIDATES := ["football_nova_package.json", "content.json"]
const PLAYER_PROFILE = preload("res://scripts/data/player_profile.gd")
const TEAM_PROFILE = preload("res://scripts/data/team_profile.gd")
const LEAGUE_MANIFEST_PATH := "res://data/league_content_manifest.json"
const MAX_ACTIVE_LEAGUES := 100

static func import_installed_packages(registry: NovaFootballDataRegistry, installed_index: Dictionary) -> Dictionary:
	if registry == null:
		return {"ok": false, "packages_imported": 0, "competitions_added": 0, "teams_added": 0, "players_added": 0, "errors": ["Registro deportivo no disponible"]}
	var packages_imported := 0
	var competitions_added := 0
	var teams_added := 0
	var players_added := 0
	var errors := PackedStringArray()
	var skipped_over_limit := 0
	var active_league_count := registry.competitions_by_id.size()
	var league_limit := _get_active_league_limit()
	for package_id in installed_index:
		var record: Dictionary = installed_index[package_id]
		if str(record.get("content_type", "league")) != "league":
			continue
		var root := str(record.get("installed_path", ""))
		if root.is_empty():
			errors.append("Paquete sin ruta instalada: " + str(package_id))
			continue
		var payload := _read_package_payload(root, errors, str(package_id))
		if payload.is_empty():
			continue
		var validation := _validate_payload(payload, registry, str(package_id))
		if not bool(validation.get("ok", false)):
			for error in validation.get("errors", []):
				errors.append(str(error))
			continue
		var snapshot_players := registry.players_by_id.duplicate(true)
		var snapshot_teams := registry.teams_by_id.duplicate(true)
		var snapshot_competitions := registry.competitions_by_id.duplicate(true)
		var package_players: Array = payload.get("players", [])
		var package_teams: Array = payload.get("teams", [])
		var package_competitions: Array = payload.get("competitions", [])
		if active_league_count + package_competitions.size() > league_limit:
			skipped_over_limit += 1
			continue
		var added_players := registry.register_players(package_players)
		var package_ok := added_players == package_players.size()
		var added_teams := 0
		if package_ok:
			for source_team in package_teams:
				var team: Dictionary = source_team.duplicate(true)
				team["fictional"] = bool(team.get("fictional", false))
				if registry.register_team(team):
					added_teams += 1
				else:
					package_ok = false
					break
		var added_competitions := 0
		if package_ok:
			for competition in package_competitions:
				if registry.register_competition(competition):
					added_competitions += 1
				else:
					package_ok = false
					break
		if not package_ok:
			registry.players_by_id = snapshot_players
			registry.teams_by_id = snapshot_teams
			registry.competitions_by_id = snapshot_competitions
			errors.append("Importación cancelada y revertida para paquete " + str(package_id) + ". Revisa IDs duplicados, perfiles y referencias.")
			continue
		players_added += added_players
		teams_added += added_teams
		competitions_added += added_competitions
		active_league_count += added_competitions
		packages_imported += 1
	return {
		"ok": errors.is_empty(),
		"packages_imported": packages_imported,
		"competitions_added": competitions_added,
		"teams_added": teams_added,
		"players_added": players_added,
		"skipped_over_limit": skipped_over_limit,
		"active_league_count": active_league_count,
		"active_league_limit": league_limit,
		"errors": errors
	}

static func _read_package_payload(root: String, errors: PackedStringArray, package_id: String) -> Dictionary:
	for filename in PACKAGE_FILE_CANDIDATES:
		var path := root.path_join(filename)
		if not FileAccess.file_exists(path):
			continue
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			errors.append("No se pudo abrir el contenido del paquete " + package_id)
			return {}
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			return parsed
		errors.append("JSON de paquete inválido: " + package_id)
		return {}
	errors.append("El paquete " + package_id + " no contiene football_nova_package.json ni content.json")
	return {}

static func _validate_payload(payload: Dictionary, registry: NovaFootballDataRegistry, package_id: String) -> Dictionary:
	var errors := PackedStringArray()
	if int(payload.get("schema_version", 0)) != 1:
		errors.append("Versión de esquema no compatible en " + package_id + " (se requiere schema_version=1)")
	for field in ["players", "teams", "competitions"]:
		if not payload.get(field, null) is Array:
			errors.append("El paquete " + package_id + " debe incluir el array " + field)
	if not errors.is_empty():
		return {"ok": false, "errors": errors}
	var local_players := {}
	var merged_players := registry.players_by_id.duplicate(true)
	for player in payload.players:
		if player is Dictionary:
			merged_players[str(player.get("id", ""))] = player
	var local_teams := {}
	var local_competitions := {}
	for player in payload.players:
		if not player is Dictionary:
			errors.append("Perfil de jugador inválido en " + package_id)
			continue
		var player_id := str(player.get("id", ""))
		if player_id.is_empty() or local_players.has(player_id) or registry.players_by_id.has(player_id):
			errors.append("ID de jugador vacío o duplicado en " + package_id + ": " + player_id)
		local_players[player_id] = true
		for validation_error in PLAYER_PROFILE.validate(player):
			errors.append("Jugador " + player_id + ": " + str(validation_error))
	for team in payload.teams:
		if not team is Dictionary:
			errors.append("Perfil de club inválido en " + package_id)
			continue
		var team_id := str(team.get("id", ""))
		if team_id.is_empty() or local_teams.has(team_id) or registry.teams_by_id.has(team_id):
			errors.append("ID de club vacío o duplicado en " + package_id + ": " + team_id)
		local_teams[team_id] = true
		for validation_error in TEAM_PROFILE.validate_roster_references(team, merged_players, 11):
			errors.append("Club " + team_id + ": " + str(validation_error))
		for player_id in team.get("player_ids", []):
			if not local_players.has(str(player_id)) and not registry.players_by_id.has(str(player_id)):
				errors.append("Club " + team_id + " referencia jugador no incluido: " + str(player_id))
	for competition in payload.competitions:
		if not competition is Dictionary:
			errors.append("Competición inválida en " + package_id)
			continue
		var competition_id := str(competition.get("id", ""))
		if competition_id.is_empty() or local_competitions.has(competition_id) or registry.competitions_by_id.has(competition_id):
			errors.append("ID de competición vacío o duplicado en " + package_id + ": " + competition_id)
		local_competitions[competition_id] = true
		if not competition.get("team_ids", null) is Array or competition.get("team_ids", []).size() < 2:
			errors.append("Competición " + competition_id + " no tiene al menos dos clubes")
			continue
		for team_id in competition.team_ids:
			if not local_teams.has(str(team_id)) and not registry.teams_by_id.has(str(team_id)):
				errors.append("Competición " + competition_id + " referencia club no incluido: " + str(team_id))
	return {"ok": errors.is_empty(), "errors": errors}


static func _get_active_league_limit() -> int:
	if not FileAccess.file_exists(LEAGUE_MANIFEST_PATH):
		return MAX_ACTIVE_LEAGUES
	var file := FileAccess.open(LEAGUE_MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return MAX_ACTIVE_LEAGUES
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return MAX_ACTIVE_LEAGUES
	var configured := int(parsed.get("database_limits", {}).get("max_created_leagues", MAX_ACTIVE_LEAGUES))
	return clampi(configured, 1, MAX_ACTIVE_LEAGUES)
