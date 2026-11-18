extends RefCounted
class_name NovaCubaRosterImporter

const FIRST_DIVISION_SOURCE := "res://data/players/cuba_first_division.json"
const SECOND_DIVISION_SOURCE := "res://data/players/cuba_second_division.json"
const THIRD_DIVISION_SOURCE := "res://data/cuba_players.json"

static func import_into_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "players_added": 0, "teams_linked": 0, "errors": ["Registro deportivo no disponible"]}
	var errors := PackedStringArray()
	var roster_files := [FIRST_DIVISION_SOURCE, SECOND_DIVISION_SOURCE, THIRD_DIVISION_SOURCE]
	var players_by_division := {}
	var teams_by_division := {}
	var players_to_register: Array = []
	var roster_by_team: Dictionary = {}
	var seen_player_ids: Dictionary = {}
	for source_path in roster_files:
		var parsed := _read_json(source_path, errors)
		if parsed.is_empty():
			continue
		var keys: Array = parsed.get("attribute_keys", [])
		if keys.size() != 35:
			errors.append("Catálogo de atributos inválido en " + source_path)
			continue
		for roster in parsed.get("rosters", []):
			if not roster is Dictionary:
				errors.append("Registro de plantilla inválido en " + source_path)
				continue
			var division_level := int(roster.get("division_level", 0))
			players_by_division[division_level] = int(players_by_division.get(division_level, 0)) + roster.get("players", []).size()
			teams_by_division[division_level] = int(teams_by_division.get(division_level, 0)) + 1
			var team_id := str(roster.get("club_id", ""))
			if team_id.is_empty() or roster_by_team.has(team_id):
				errors.append("Club sin ID o plantilla duplicada: " + team_id)
				continue
			var player_ids: Array[String] = []
			for raw_player in roster.get("players", []):
				if not raw_player is Dictionary:
					errors.append("Jugador inválido en plantilla " + team_id)
					continue
				var player_id := str(raw_player.get("id", ""))
				if player_id.is_empty() or seen_player_ids.has(player_id):
					errors.append("ID de jugador vacío o duplicado: " + player_id)
					continue
				var compact_attributes: Array = raw_player.get("attributes", [])
				if compact_attributes.size() != keys.size():
					errors.append("Jugador " + player_id + " no tiene 35 atributos")
					continue
				var attributes: Dictionary = {}
				for index in range(keys.size()):
					attributes[str(keys[index])] = int(compact_attributes[index])
				var player := {
					"id": player_id,
					"display_name": str(raw_player.get("name", "")),
					"nationality_id": str(raw_player.get("nationality", "")),
					"primary_position": str(raw_player.get("position", "")),
					"secondary_positions": raw_player.get("secondary_positions", []).duplicate(true),
					"preferred_foot": str(raw_player.get("preferred_foot", "right")),
					"birth_date": str(raw_player.get("birth_date", "")),
					"age_at_generation": int(raw_player.get("age", 0)),
					"birth_place": str(raw_player.get("birth_place", "")),
					"height_cm": int(raw_player.get("height_cm", 0)),
					"weight_kg": int(raw_player.get("weight_kg", 0)),
					"estimated_overall": int(raw_player.get("estimated_overall", 0)),
					"potential": int(raw_player.get("potential", 0)),
					"attributes": attributes,
					"generation_seed": int(raw_player.get("generation_seed", 0)),
					"skill_profile": raw_player.get("skill_profile", {}).duplicate(true),
					"economy": raw_player.get("economy", {}).duplicate(true),
					"club_id": team_id
				}
				players_to_register.append(player)
				player_ids.append(player_id)
				seen_player_ids[player_id] = true
			roster_by_team[team_id] = player_ids
	for team_id in roster_by_team:
		if not registry.teams_by_id.has(team_id):
			errors.append("La plantilla referencia un club inexistente: " + str(team_id))
	for team_id in roster_by_team:
		if registry.teams_by_id.has(team_id):
			registry.teams_by_id[team_id]["player_ids"] = roster_by_team[team_id].duplicate()
	var added := registry.register_players(players_to_register)
	var linked := 0
	for team_id in roster_by_team:
		if registry.teams_by_id.has(team_id) and registry.teams_by_id[team_id].player_ids.size() == 22:
			linked += 1
		else:
			errors.append("Plantilla incompleta para " + str(team_id))
	return {
		"ok": errors.is_empty() and added == players_to_register.size() and linked == roster_by_team.size(),
		"players_added": added,
		"teams_linked": linked,
		"rosters_loaded": roster_by_team.size(),
		"total_players": registry.players_by_id.size(),
		"missing_roster_teams": _teams_without_roster(registry),
		"players_by_division": players_by_division,
		"teams_by_division": teams_by_division,
		"errors": errors
	}

static func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("No existe el archivo de plantillas: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir el archivo de plantillas: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("JSON de plantillas inválido: " + path)
		return {}
	return parsed

static func _teams_without_roster(registry: NovaFootballDataRegistry) -> Array[String]:
	var missing: Array[String] = []
	for team_id in registry.teams_by_id:
		if registry.teams_by_id[team_id].get("player_ids", []).size() != 22:
			missing.append(str(team_id))
	return missing
