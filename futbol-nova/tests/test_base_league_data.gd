extends SceneTree

const PLAYER_PROFILE = preload("res://scripts/data/player_profile.gd")
const BASE_CLUBS_PATH := "res://data/base_league_clubs_2026.json"
const SPAIN_CLUBS_PATH := "res://data/spain_clubs_2026_27.json"
const USA_CLUBS_PATH := "res://data/usa_clubs_2026.json"
const SPAIN_LEAGUES_PATH := "res://data/spain_leagues_2026_27.json"
const USA_LEAGUES_PATH := "res://data/usa_leagues_2026.json"

func _initialize() -> void:
	var errors := PackedStringArray()
	var base := _read_json(BASE_CLUBS_PATH, errors)
	var spain := _read_json(SPAIN_CLUBS_PATH, errors)
	var usa := _read_json(USA_CLUBS_PATH, errors)
	var spain_leagues := _read_json(SPAIN_LEAGUES_PATH, errors)
	var usa_leagues := _read_json(USA_LEAGUES_PATH, errors)
	var all_clubs := {}
	for club in base.get("clubs", []):
		_add_club(club, all_clubs, errors)
	for club in spain.get("clubs", []):
		_add_club(club, all_clubs, errors)
	for club in usa.get("clubs", []):
		_add_club(club, all_clubs, errors)
	for competition in base.get("competitions", []):
		_validate_competition(competition, all_clubs, errors)
	for competition in spain_leagues.get("competitions", []):
		_validate_competition(competition, all_clubs, errors)
	for competition in usa_leagues.get("competitions", []):
		_validate_competition(competition, all_clubs, errors)
	if all_clubs.size() != 605:
		errors.append("Se esperaban 605 clubes de España, USA y seis países adicionales; encontrados " + str(all_clubs.size()))
	for competition in base.get("competitions", []):
		if str(competition.get("id", "")) == "ARG-LP-2026" and str(competition.get("format", "")) != "custom_schedule_pending":
			errors.append("Argentina Liga Profesional debe esperar el calendario por fases.")
	var roster_paths := [
		"res://data/players/esp_base_2026_27.json",
		"res://data/players/bra_base_2026.json",
		"res://data/players/ita_base_2026_27.json",
		"res://data/players/ger_base_2026_27.json",
		"res://data/players/fra_base_2026_27.json",
		"res://data/players/por_base_2026_27.json",
		"res://data/players/arg_base_2026.json",
		"res://data/players/usa_base_2026.json"
	]
	var expected_counts := {"ESP": 82, "BRA": 60, "ITA": 100, "GER": 56, "FRA": 54, "POR": 56, "ARG": 125, "USA": 72}
	var all_player_ids := {}
	var total_players := 0
	for path in roster_paths:
		var data := _read_json(path, errors)
		var code := str(data.get("country_code", ""))
		var expected_clubs := int(expected_counts.get(code, 0))
		var players: Array = data.get("players", [])
		if expected_clubs == 0 or int(data.get("club_count", -1)) != expected_clubs:
			errors.append("Conteo de clubes incorrecto en " + path)
		if players.size() != expected_clubs * 22:
			errors.append("Conteo de jugadores incorrecto en " + path + ": " + str(players.size()))
		var by_club := {}
		for player in players:
			var player_id := str(player.get("id", ""))
			var club_id := str(player.get("club_id", ""))
			if player_id.is_empty() or all_player_ids.has(player_id):
				errors.append("ID de jugador vacío o duplicado: " + player_id)
			all_player_ids[player_id] = true
			if not all_clubs.has(club_id):
				errors.append("Plantilla apunta a club inexistente: " + club_id)
			if not by_club.has(club_id):
				by_club[club_id] = 0
			by_club[club_id] += 1
			var profile_errors: PackedStringArray = PLAYER_PROFILE.validate(player)
			for profile_error in profile_errors:
				errors.append(player_id + ": " + profile_error)
		if by_club.size() != expected_clubs:
			errors.append("Cantidad de clubes con plantilla incorrecta en " + path)
		for club_id in by_club:
			if int(by_club[club_id]) != 22:
				errors.append("Plantilla distinta de 22 jugadores: " + str(club_id))
		total_players += players.size()
	if total_players != 13310:
		errors.append("Se esperaban 13.310 perfiles guardados en los ocho nuevos archivos; encontrados " + str(total_players))
	if errors.is_empty():
		print("Base leagues: 605 clubs checked; 13,310 saved fictional profiles; 22 per club; unique IDs and valid player schema.")
		quit(0)
	else:
		for error in errors:
			push_error(error)
		quit(1)

func _add_club(club: Dictionary, all_clubs: Dictionary, errors: PackedStringArray) -> void:
	var club_id := str(club.get("id", ""))
	if club_id.is_empty() or all_clubs.has(club_id):
		errors.append("ID de club vacío o duplicado: " + club_id)
	all_clubs[club_id] = true

func _validate_competition(competition: Dictionary, all_clubs: Dictionary, errors: PackedStringArray) -> void:
	var team_ids: Array = competition.get("team_ids", [])
	if team_ids.size() < 2:
		errors.append("Competición sin suficientes clubes: " + str(competition.get("id", "")))
	for team_id in team_ids:
		if not all_clubs.has(str(team_id)):
			errors.append("Competición referencia club inexistente: " + str(team_id))

func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("No existe " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("JSON inválido: " + path)
		return {}
	return parsed
