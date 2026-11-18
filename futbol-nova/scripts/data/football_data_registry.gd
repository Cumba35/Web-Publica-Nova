extends RefCounted
class_name NovaFootballDataRegistry

const PLAYER_STATISTICS = preload("res://scripts/data/player_statistics_service.gd")

var players_by_id: Dictionary = {}
var teams_by_id: Dictionary = {}
var competitions_by_id: Dictionary = {}
var last_errors: PackedStringArray = PackedStringArray()

func clear() -> void:
	players_by_id.clear()
	teams_by_id.clear()
	competitions_by_id.clear()
	last_errors.clear()

func load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		last_errors.append("No existe el archivo: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_errors.append("No se pudo abrir: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		last_errors.append("La raíz JSON debe ser un objeto: " + path)
		return {}
	return parsed

func register_players(records: Array) -> int:
	var added := 0
	for record in records:
		if not record is Dictionary:
			last_errors.append("Registro de jugador no es un objeto")
			continue
		var normalized_record: Dictionary = PLAYER_STATISTICS.normalize_player(record)
		var errors := NovaPlayerProfile.validate(normalized_record)
		if not errors.is_empty():
			for error in errors:
				last_errors.append("Jugador " + str(normalized_record.get("id", "sin_id")) + ": " + error)
			continue
		var player_id := str(normalized_record.id)
		if players_by_id.has(player_id):
			last_errors.append("ID de jugador duplicado: " + player_id)
			continue
		players_by_id[player_id] = normalized_record
		added += 1
	return added

func register_team(team: Dictionary) -> bool:
	var errors := NovaTeamProfile.validate(team)
	if not errors.is_empty():
		for error in errors:
			last_errors.append("Equipo " + str(team.get("id", "sin_id")) + ": " + error)
		return false
	var team_id := str(team.id)
	if teams_by_id.has(team_id):
		last_errors.append("ID de equipo duplicado: " + team_id)
		return false
	teams_by_id[team_id] = team.duplicate(true)
	return true

func validate_team_rosters(minimum_players: int = 11) -> bool:
	var valid := true
	for team_id in teams_by_id:
		var errors := NovaTeamProfile.validate_roster_references(teams_by_id[team_id], players_by_id, minimum_players)
		for error in errors:
			last_errors.append("Equipo " + str(team_id) + ": " + error)
			valid = false
	return valid

func register_competition(competition: Dictionary) -> bool:
	for field in ["id", "name", "team_ids", "format"]:
		if not competition.has(field):
			last_errors.append("Competición sin campo obligatorio: " + field)
			return false
	var competition_id := str(competition.id)
	if competition_id.is_empty() or competitions_by_id.has(competition_id):
		last_errors.append("ID de competición vacío o duplicado")
		return false
	if not competition.team_ids is Array or competition.team_ids.size() < 2:
		last_errors.append("Una competición necesita al menos dos equipos")
		return false
	for team_id in competition.team_ids:
		if not teams_by_id.has(str(team_id)):
			last_errors.append("La competición referencia un equipo inexistente: " + str(team_id))
			return false
	competitions_by_id[competition_id] = competition.duplicate(true)
	return true

func get_team_roster(team_id: String) -> Array:
	var roster: Array = []
	if not teams_by_id.has(team_id):
		return roster
	for player_id in teams_by_id[team_id].player_ids:
		if players_by_id.has(str(player_id)):
			roster.append(players_by_id[str(player_id)].duplicate(true))
	return roster

func export_catalog_snapshot() -> Dictionary:
	return {"schema_version": "1.0.0", "players": players_by_id.duplicate(true), "teams": teams_by_id.duplicate(true), "competitions": competitions_by_id.duplicate(true)}
