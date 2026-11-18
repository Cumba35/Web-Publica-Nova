extends Node
class_name NovaCustomPlayerRosterService

const ROSTER_PATH := "user://custom_player_roster.json"
const SELECTION_PATH := "user://online_custom_player_selection.json"
const SCHEMA_VERSION := "1.0.0"
const PLAYER_STATISTICS = preload("res://scripts/data/player_statistics_service.gd")

var _players: Array = []
var _selected_online_player_id := ""
var _loaded := false

func _ready() -> void:
	_load_roster()
	_load_selection()

func add_created_player(player: Dictionary) -> Dictionary:
	if str(player.get("origin", "user_created")) != "user_created":
		return {"ok": false, "error": "Solo se pueden guardar aquí jugadores creados por el usuario."}
	var normalized_player: Dictionary = PLAYER_STATISTICS.normalize_player(player)
	var player_id := str(normalized_player.get("id", "")).strip_edges()
	var player_name := str(normalized_player.get("display_name", normalized_player.get("full_name", ""))).strip_edges()
	var attributes: Dictionary = normalized_player.get("attributes", {})
	if player_id.is_empty() or player_name.length() < 2 or attributes.size() != 35:
		return {"ok": false, "error": "La ficha personalizada está incompleta; se requieren identidad y 35 atributos."}
	_load_roster()
	for index in range(_players.size()):
		if str(_players[index].get("id", "")) == player_id:
			var previous_player: Dictionary = _players[index].duplicate(true)
			_players[index] = normalized_player.duplicate(true)
			if not _save_roster():
				_players[index] = previous_player
				return {"ok": false, "error": "No se pudo actualizar el jugador personalizado."}
			return {"ok": true, "player_id": player_id}
	_players.append(normalized_player.duplicate(true))
	if not _save_roster():
		_players.pop_back()
		return {"ok": false, "error": "No se pudo guardar el archivo independiente de jugadores personalizados."}
	return {"ok": true, "player_id": player_id}

func get_created_players() -> Array:
	_load_roster()
	return _players.duplicate(true)

func get_online_selected_player_id() -> String:
	_load_selection()
	return _selected_online_player_id

func get_online_selected_player() -> Dictionary:
	_load_roster()
	_load_selection()
	for player in _players:
		if str(player.get("id", "")) == _selected_online_player_id:
			return player.duplicate(true)
	return {}

func select_for_online(player_id: String) -> Dictionary:
	_load_roster()
	var found := false
	for player in _players:
		if str(player.get("id", "")) == player_id:
			found = true
			break
	if not found:
		return {"ok": false, "error": "Ese jugador no pertenece a tu lista de futbolistas creados."}
	var previous_selection := _selected_online_player_id
	_selected_online_player_id = player_id
	if not _save_selection():
		_selected_online_player_id = previous_selection
		return {"ok": false, "error": "No se pudo guardar la selección para Online."}
	return {"ok": true, "player_id": player_id}

func clear_online_selection() -> void:
	_selected_online_player_id = ""
	_save_selection()

func _load_roster() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(ROSTER_PATH):
		return
	var file := FileAccess.open(ROSTER_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and str(parsed.get("schema_version", "")) == SCHEMA_VERSION and parsed.get("players", []) is Array:
		_players = []
		for player in parsed.get("players", []):
			if player is Dictionary:
				_players.append(PLAYER_STATISTICS.normalize_player(player))

func _load_selection() -> void:
	if not _selected_online_player_id.is_empty() or not FileAccess.file_exists(SELECTION_PATH):
		return
	var file := FileAccess.open(SELECTION_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_selected_online_player_id = str(parsed.get("player_id", ""))
	if not _selected_online_player_id.is_empty() and get_online_selected_player().is_empty():
		_selected_online_player_id = ""

func _save_roster() -> bool:
	return _write_json_atomically(ROSTER_PATH, {"schema_version": SCHEMA_VERSION, "players": _players})

func _save_selection() -> bool:
	return _write_json_atomically(SELECTION_PATH, {"schema_version": SCHEMA_VERSION, "player_id": _selected_online_player_id})

func _write_json_atomically(path: String, data: Dictionary) -> bool:
	var temporary_path := path + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return false
	var absolute_path := ProjectSettings.globalize_path(path)
	var temporary_absolute := ProjectSettings.globalize_path(temporary_path)
	if FileAccess.file_exists(path):
		var backup_absolute := ProjectSettings.globalize_path(path + ".bak")
		if FileAccess.file_exists(path + ".bak"):
			DirAccess.remove_absolute(backup_absolute)
		var backup_error := DirAccess.rename_absolute(absolute_path, backup_absolute)
		if backup_error != OK:
			return false
	var rename_error := DirAccess.rename_absolute(temporary_absolute, absolute_path)
	if rename_error != OK:
		var backup_path := ProjectSettings.globalize_path(path + ".bak")
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, absolute_path)
		return false
	return true
