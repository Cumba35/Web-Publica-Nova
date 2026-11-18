extends RefCounted
class_name NovaCubaLeagueImporter

const DEFAULT_SOURCE := "res://data/cuba_leagues.json"
const ACADEMY_SERVICE = preload("res://scripts/manager/club_academy_service.gd")

static func import_into_registry(registry: NovaFootballDataRegistry, path: String = DEFAULT_SOURCE) -> Dictionary:
	if registry == null:
		return {"ok": false, "errors": ["Registro de datos no disponible"], "teams_added": 0, "competitions_added": 0}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "errors": ["No se pudo abrir " + path], "teams_added": 0, "competitions_added": 0}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.has("competitions") or not parsed.competitions is Array:
		return {"ok": false, "errors": ["El catálogo cubano no tiene una estructura válida"], "teams_added": 0, "competitions_added": 0}
	var errors := PackedStringArray()
	var teams_added := 0
	var competitions_added := 0
	for competition in parsed.competitions:
		if not competition is Dictionary:
			errors.append("Se omitió una competición con formato inválido")
			continue
		var clubs := _collect_clubs(competition)
		if clubs.is_empty():
			errors.append("La competición no contiene clubes: " + str(competition.get("id", "sin_id")))
			continue
		var team_ids: Array[String] = []
		for club in clubs:
			var team_id := str(club.get("id", ""))
			if team_id.is_empty():
				errors.append("Club sin ID en " + str(competition.get("id", "sin_id")))
				continue
			var team := {
				"id": team_id,
				"name": str(club.get("name", team_id)),
				"country_id": str(club.get("country_code", parsed.get("country_code", "CUB"))),
				"competition_id": str(competition.get("id", "")),
				"season": "2026",
				"competition_level": int(competition.get("level", 0)),
				"division_level": int(competition.get("level", 0)),
				"commercial_contracts": club.get("commercial_contracts", {}).duplicate(true) if club.get("commercial_contracts", {}) is Dictionary else {},
				"group_id": str(club.get("_group_id", "")),
				"player_ids": [],
				"fictional": bool(club.get("fictional", true)),
				"identity": club.get("identity", {}).duplicate(true) if club.get("identity", {}) is Dictionary else {},
				"academy": ACADEMY_SERVICE.initial_state(int(competition.get("level", 99)))
			}
			if registry.register_team(team):
				teams_added += 1
			elif not registry.teams_by_id.has(team_id):
				errors.append("No se pudo registrar el club: " + team_id)
			team_ids.append(team_id)
		var competition_record := {
			"id": str(competition.get("id", "")),
			"name": str(competition.get("display_name", competition.get("name", "Competición"))),
			"country_id": str(competition.get("country_code", parsed.get("country_code", "CUB"))),
			"season": "2026",
			"level": int(competition.get("level", 0)),
			"format": str(competition.get("format", {}).get("type", "custom")),
			"team_ids": team_ids,
			"points": competition.get("points", {"win": 3, "draw": 1, "loss": 0}).duplicate(true),
			"tiebreakers": competition.get("tiebreakers", []).duplicate(true)
		}
		if registry.register_competition(competition_record):
			competitions_added += 1
		elif not registry.competitions_by_id.has(str(competition_record.id)):
			errors.append("No se pudo registrar competición: " + str(competition_record.id))
	return {
		"ok": errors.is_empty() and competitions_added > 0,
		"teams_added": teams_added,
		"competitions_added": competitions_added,
		"team_count": registry.teams_by_id.size(),
		"competition_count": registry.competitions_by_id.size(),
		"errors": errors
	}

static func _collect_clubs(competition: Dictionary) -> Array:
	var clubs: Array = []
	if competition.get("clubs", []) is Array:
		for club in competition.get("clubs", []):
			if club is Dictionary:
				var copy: Dictionary = club.duplicate(true)
				copy["_group_id"] = ""
				clubs.append(copy)
	if competition.get("groups", []) is Array:
		for group in competition.get("groups", []):
			if not group is Dictionary or not group.get("clubs", []) is Array:
				continue
			for club in group.get("clubs", []):
				if club is Dictionary:
					var copy: Dictionary = club.duplicate(true)
					copy["_group_id"] = str(group.get("id", group.get("name", "")))
					clubs.append(copy)
	return clubs
