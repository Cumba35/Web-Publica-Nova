extends RefCounted
class_name NovaBaseLeagueImporter

const BASE_PATH := "res://data/base_league_clubs_2026.json"
const SPAIN_CLUBS_PATH := "res://data/spain_clubs_2026_27.json"
const SPAIN_LEAGUES_PATH := "res://data/spain_leagues_2026_27.json"

static func import_into_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "clubs_added": 0, "competitions_added": 0, "errors": ["Registro no disponible"]}
	var errors := PackedStringArray()
	var base := _read_json(BASE_PATH, errors)
	var spain_clubs := _read_json(SPAIN_CLUBS_PATH, errors)
	var spain_leagues := _read_json(SPAIN_LEAGUES_PATH, errors)
	if not errors.is_empty():
		return {"ok": false, "clubs_added": 0, "competitions_added": 0, "errors": errors}
	var clubs: Array = base.get("clubs", []).duplicate(true)
	clubs.append_array(spain_clubs.get("clubs", []))
	var competitions: Array = base.get("competitions", []).duplicate(true)
	competitions.append_array(spain_leagues.get("competitions", []))
	var club_map := {}
	for club in clubs:
		if not club is Dictionary:
			errors.append("Registro de club inválido")
			continue
		var club_id := str(club.get("id", ""))
		if club_id.is_empty() or club_map.has(club_id):
			errors.append("ID de club vacío o duplicado: " + club_id)
			continue
		club_map[club_id] = club
	var clubs_added := 0
	for club_id in club_map:
		var club: Dictionary = club_map[club_id]
		var team := {
			"id": club_id,
			"name": str(club.get("display_name", club_id)),
			"country_id": str(club.get("country_code", "")),
			"competition_id": str(club.get("competition_id", "")),
			"season": str(club.get("season", "2026-27")),
			"competition_level": int(club.get("division_level", 0)),
			"division_level": int(club.get("division_level", 0)),
			"group_id": str(club.get("group_id", "")),
			"player_ids": [],
			"fictional": true,
			"source_reference_id": str(club.get("source_reference_id", "")),
			"identity": {"identity_type": "original_fictional_club", "reference_name": str(club.get("reference_name", ""))}
		}
		if registry.register_team(team):
			clubs_added += 1
		elif not registry.teams_by_id.has(club_id):
			errors.append("No se pudo registrar club base: " + club_id)
	var competitions_added := 0
	for comp in competitions:
		if not comp is Dictionary:
			errors.append("Competición base inválida")
			continue
		var record := {
			"id": str(comp.get("id", "")),
			"name": str(comp.get("name", "Competición")),
			"country_id": str(comp.get("country_code", "")),
			"season": str(comp.get("season", "2026-27")),
			"level": int(comp.get("level", 0)),
			"format": str(comp.get("format", "grouped_league" if comp.get("groups", []).size() > 1 else "single_group_double_round_robin")),
			"team_ids": comp.get("team_ids", []).duplicate(true),
			"groups": comp.get("groups", []).duplicate(true),
			"points": {"win": 3, "draw": 1, "loss": 0},
			"tiebreakers": ["points", "goal_difference", "goals_for"]
		}
		if registry.register_competition(record):
			competitions_added += 1
		elif not registry.competitions_by_id.has(str(record.id)):
			errors.append("No se pudo registrar competición base: " + str(record.id))
	return {"ok": errors.is_empty(), "clubs_added": clubs_added, "competitions_added": competitions_added, "total_clubs": club_map.size(), "errors": errors}

static func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
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
