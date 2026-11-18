extends SceneTree

const CLUBS_PATH := "res://data/usa_clubs_2026.json"
const COMPETITIONS_PATH := "res://data/usa_leagues_2026.json"

func _initialize() -> void:
	var errors := PackedStringArray()
	var clubs_data := _read_json(CLUBS_PATH, errors)
	var competitions_data := _read_json(COMPETITIONS_PATH, errors)
	var clubs: Array = clubs_data.get("clubs", [])
	var competitions: Array = competitions_data.get("competitions", [])
	if clubs.size() != 72:
		errors.append("USA debe contener 72 clubes de 2026.")
	var expected_counts := [30, 25, 17]
	if competitions.size() != 3:
		errors.append("USA debe contener MLS, USL Championship y USL League One.")
	var club_ids := {}
	for club in clubs:
		var club_id := str(club.get("id", ""))
		if club_id.is_empty() or club_ids.has(club_id):
			errors.append("ID de club USA vacío o duplicado: " + club_id)
		club_ids[club_id] = true
	for index in range(mini(competitions.size(), 3)):
		var competition: Dictionary = competitions[index]
		var team_ids: Array = competition.get("team_ids", [])
		if team_ids.size() != expected_counts[index]:
			errors.append("Número de clubes incorrecto en " + str(competition.get("id", "")))
		if str(competition.get("format", "")) != "custom_schedule_pending":
			errors.append("No se debe asumir un calendario de doble vuelta para " + str(competition.get("id", "")))
		for team_id in team_ids:
			if not club_ids.has(str(team_id)):
				errors.append("Competición referencia club ausente: " + str(team_id))
	if errors.is_empty():
		print("USA 2026: 72 clubes y tres competiciones verificadas; plantillas se generan por separado.")
		quit(0)
	else:
		for error in errors:
			push_error(error)
		quit(1)

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
