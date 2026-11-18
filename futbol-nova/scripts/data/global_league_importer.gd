extends RefCounted
class_name NovaGlobalLeagueImporter

const CLUBS_PATH := "res://data/global_clubs.generated.json"
const PLAYER_PATHS := [
	"res://data/players/england_premier_2026_27.json",
	"res://data/players/england_championship_2026_27.json",
	"res://data/players/england_league_one_2026_27.json"
]
const COMPETITIONS_PATH := "res://data/england_leagues.json"

static func import_into_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "clubs_added": 0, "players_added": 0, "competitions_added": 0, "errors": ["Registro deportivo no disponible"]}
	var errors := PackedStringArray()
	var clubs_data := _read_json(CLUBS_PATH, errors)
	var competitions_data := _read_json(COMPETITIONS_PATH, errors)
	if clubs_data.is_empty() or competitions_data.is_empty():
		return _result(false, 0, 0, 0, errors)
	var players_by_club: Dictionary = {}
	var player_records: Array = []
	for player_path in PLAYER_PATHS:
		var division_data := _read_json(str(player_path), errors)
		for player in division_data.get("players", []):
			player_records.append(player)
	for player in player_records:
		if not player is Dictionary:
			errors.append("Registro global de jugador inválido")
			continue
		var club_id := str(player.get("club_id", ""))
		if club_id.is_empty():
			errors.append("Jugador global sin club: " + str(player.get("id", "sin_id")))
			continue
		if not players_by_club.has(club_id):
			players_by_club[club_id] = []
		players_by_club[club_id].append(player)
	var clubs_added := 0
	for club in clubs_data.get("clubs", []):
		if not club is Dictionary:
			errors.append("Registro global de club inválido")
			continue
		var team_id := str(club.get("id", ""))
		var player_ids: Array[String] = []
		for player in players_by_club.get(team_id, []):
			player_ids.append(str(player.get("id", "")))
		var team := {
			"id": team_id,
			"name": str(club.get("display_name", team_id)),
			"country_id": str(club.get("country_code", "")),
			"competition_id": str(club.get("competition_id", "")),
			"competition_level": int(club.get("division_level", 0)),
			"division_level": int(club.get("division_level", 0)),
			"city": str(club.get("city", "")),
			"season": str(clubs_data.get("season", "2026-27")),
			"source_reference_id": str(club.get("source_reference_id", "")),
			"source_provenance": str(club.get("source_provenance", "")),
			"player_ids": player_ids,
			"fictional": true,
			"identity": {
				"identity_type": "original_fictional_club",
				"short_name": str(club.get("display_name", team_id)),
				"review_status": str(club.get("status", "draft_review_required")),
				"trademark_review_status": str(club.get("trademark_review_status", "not_reviewed")),
				"visual_assets_original": bool(club.get("visual_assets_original", false)),
				"visual": club.get("visual", {}).duplicate(true)
			}
		}
		if registry.register_team(team):
			clubs_added += 1
		elif not registry.teams_by_id.has(team_id):
			errors.append("No se pudo registrar el club global: " + team_id)
	var players_added := registry.register_players(player_records)
	if players_added != player_records.size():
		errors.append("No todos los jugadores globales superaron la validación del perfil")
	var competitions_added := 0
	for competition in competitions_data.get("competitions", []):
		if not competition is Dictionary:
			errors.append("Competición global inválida")
			continue
		var record := {
			"id": str(competition.get("id", "")),
			"name": str(competition.get("name", "Competición")),
			"country_id": str(competition.get("country_id", "ENG")),
			"level": int(competition.get("level", 0)),
			"format": str(competition.get("format", "single_group_double_round_robin")),
			"team_ids": competition.get("team_ids", []).duplicate(),
			"points": competition.get("points", {"win": 3, "draw": 1, "loss": 0}).duplicate(true),
			"tiebreakers": competition.get("tiebreakers", []).duplicate(),
			"promotion": competition.get("promotion", {}).duplicate(true) if competition.get("promotion", {}) is Dictionary else {},
			"relegation": competition.get("relegation", {}).duplicate(true) if competition.get("relegation", {}) is Dictionary else {}
		}
		if registry.register_competition(record):
			competitions_added += 1
		elif not registry.competitions_by_id.has(str(record.id)):
			errors.append("No se pudo registrar competición global: " + str(record.id))
	var rosters_valid: bool = registry.validate_team_rosters(22)
	if not rosters_valid:
		for error in registry.last_errors:
			errors.append(str(error))
	return _result(errors.is_empty(), clubs_added, players_added, competitions_added, errors)

static func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("No existe el archivo global: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir el archivo global: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("JSON global inválido: " + path)
		return {}
	return parsed

static func _result(ok: bool, clubs: int, players: int, competitions: int, errors: PackedStringArray) -> Dictionary:
	return {"ok": ok, "clubs_added": clubs, "players_added": players, "competitions_added": competitions, "errors": errors}
