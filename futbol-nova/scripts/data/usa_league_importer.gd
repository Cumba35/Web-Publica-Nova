extends RefCounted
class_name NovaUSALeagueImporter

const CLUBS_PATH := "res://data/usa_clubs_2026.json"
const COMPETITIONS_PATH := "res://data/usa_leagues_2026.json"

static func import_into_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "teams_added": 0, "competitions_added": 0, "errors": ["Registro deportivo no disponible"]}
	var clubs_data := _read_json(CLUBS_PATH)
	var competitions_data := _read_json(COMPETITIONS_PATH)
	if clubs_data.is_empty() or competitions_data.is_empty():
		return {"ok": false, "teams_added": 0, "competitions_added": 0, "errors": ["No se pudieron cargar los catálogos estadounidenses de clubes y competiciones"]}
	var clubs_by_id: Dictionary = {}
	for club in clubs_data.get("clubs", []):
		if not club is Dictionary:
			continue
		var club_id := str(club.get("id", ""))
		if club_id.is_empty() or clubs_by_id.has(club_id):
			return {"ok": false, "teams_added": 0, "competitions_added": 0, "errors": ["ID estadounidense vacío o duplicado: " + club_id]}
		clubs_by_id[club_id] = club
	var errors := PackedStringArray()
	var teams_added := 0
	var competitions_added := 0
	for competition in competitions_data.get("competitions", []):
		if not competition is Dictionary:
			errors.append("Competición estadounidense inválida")
			continue
		var team_ids: Array[String] = []
		for raw_id in competition.get("team_ids", []):
			var club_id := str(raw_id)
			if not clubs_by_id.has(club_id):
				errors.append("Club no encontrado en catálogo USA: " + club_id)
				continue
			var club: Dictionary = clubs_by_id[club_id]
			var team := {
				"id": club_id,
				"name": str(club.get("display_name", club_id)),
				"country_id": "USA",
				"competition_id": str(competition.get("id", "")),
				"season": str(club.get("season", "2026")),
				"competition_level": int(competition.get("level", 0)),
				"division_level": int(competition.get("level", 0)),
				"group_id": "",
				"player_ids": [],
				"fictional": true,
				"identity": {"identity_type": "original_fictional_club", "reference_name": str(club.get("reference_name", ""))}
			}
			if registry.register_team(team):
				teams_added += 1
			elif not registry.teams_by_id.has(club_id):
				errors.append("No se pudo registrar el club USA: " + club_id)
			team_ids.append(club_id)
		var record := {
			"id": str(competition.get("id", "")),
			"name": str(competition.get("name", "Competición USA")),
			"country_id": "USA",
			"season": "2026",
			"level": int(competition.get("level", 0)),
			"format": str(competition.get("format", "custom_schedule_pending")),
			"team_ids": team_ids,
			"points": competition.get("points", {"win": 3, "draw": 1, "loss": 0}).duplicate(true),
			"tiebreakers": competition.get("tiebreakers", []).duplicate(true)
		}
		if registry.register_competition(record):
			competitions_added += 1
		elif not registry.competitions_by_id.has(str(record.id)):
			errors.append("No se pudo registrar competición USA: " + str(record.id))
	return {"ok": errors.is_empty() and teams_added == 72 and competitions_added == 3, "teams_added": teams_added, "competitions_added": competitions_added, "errors": errors}

static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}
