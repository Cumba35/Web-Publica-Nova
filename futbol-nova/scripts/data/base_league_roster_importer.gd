extends RefCounted
class_name NovaBaseLeagueRosterImporter

const ROSTER_PATHS := [
	"res://data/players/esp_base_2026_27.json",
	"res://data/players/bra_base_2026.json",
	"res://data/players/ita_base_2026_27.json",
	"res://data/players/ger_base_2026_27.json",
	"res://data/players/fra_base_2026_27.json",
	"res://data/players/por_base_2026_27.json",
	"res://data/players/arg_base_2026.json",
	"res://data/players/usa_base_2026.json"
]

static func import_into_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "players_added": 0, "clubs_completed": 0, "errors": ["Registro no disponible"]}
	var errors := PackedStringArray()
	var records: Array = []
	var players_by_club := {}
	var expected_clubs := 0
	for path in ROSTER_PATHS:
		var data := _read_json(path, errors)
		if data.is_empty():
			continue
		var players: Array = data.get("players", [])
		for player in players:
			if not player is Dictionary:
				errors.append("Perfil inválido en " + path)
				continue
			var player_id := str(player.get("id", ""))
			var club_id := str(player.get("club_id", ""))
			if player_id.is_empty() or club_id.is_empty():
				errors.append("Perfil sin ID o club en " + path)
				continue
			if not registry.teams_by_id.has(club_id):
				errors.append("El jugador referencia un club no importado: " + club_id)
				continue
			if not players_by_club.has(club_id):
				players_by_club[club_id] = []
			players_by_club[club_id].append(player_id)
			records.append(player)
		expected_clubs += int(data.get("club_count", 0))
	if not errors.is_empty():
		return {"ok": false, "players_added": 0, "clubs_completed": 0, "errors": errors}
	var added := registry.register_players(records)
	if added != records.size():
		for error in registry.last_errors:
			errors.append(str(error))
		return {"ok": false, "players_added": added, "clubs_completed": 0, "errors": errors}
	var completed := 0
	for club_id in players_by_club:
		var ids: Array = players_by_club[club_id]
		if ids.size() != 22:
			errors.append("Plantilla incompleta para " + str(club_id) + ": " + str(ids.size()) + "/22")
			continue
		registry.teams_by_id[club_id]["player_ids"] = ids.duplicate()
		completed += 1
	return {"ok": errors.is_empty() and completed == expected_clubs, "players_added": added, "clubs_completed": completed, "clubs_expected": expected_clubs, "errors": errors}

static func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("No existe el archivo de plantillas: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("JSON de plantillas inválido: " + path)
		return {}
	return parsed
