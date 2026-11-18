extends Node
class_name NovaDailyMomentsService

signal challenge_updated(challenge: Dictionary)
signal reward_claimed(points: int)

const SAVE_PATH := "user://futbol_nova/moments_daily.json"
const CHALLENGES := [
	{"id": "daily_goal_1", "title": "Rompe el marcador", "description": "Marca al menos un gol en el campo de entrenamiento.", "event_type": "goal_scored", "target": 1, "reward": 50},
	{"id": "daily_goal_2", "title": "Doblete diario", "description": "Marca dos goles en el campo de entrenamiento.", "event_type": "goal_scored", "target": 2, "reward": 100},
	{"id": "daily_goal_3", "title": "Hat-trick Nova", "description": "Marca tres goles en el campo de entrenamiento.", "event_type": "goal_scored", "target": 3, "reward": 150}
]

var _state: Dictionary = {}

func _ready() -> void:
	_load_or_rotate()

func get_daily_challenge() -> Dictionary:
	_load_or_rotate()
	var result := _state.duplicate(true)
	result["completed"] = int(result.get("progress", 0)) >= int(result.get("target", 1))
	return result

func record_event(event_type: String, amount: int = 1) -> Dictionary:
	_load_or_rotate()
	_state = apply_event_to_state(_state, event_type, amount)
	_save()
	var result := get_daily_challenge()
	challenge_updated.emit(result)
	return result

func claim_reward() -> Dictionary:
	_load_or_rotate()
	var result := claim_reward_from_state(_state)
	if bool(result.get("ok", false)):
		_state = result.get("state", {}).duplicate(true)
		_save()
		reward_claimed.emit(int(result.get("reward", 0)))
	return result

func _load_or_rotate() -> void:
	var today := _today_key()
	if not _state.is_empty() and str(_state.get("date", "")) == today:
		return
	var previous_points := int(_state.get("total_points", 0))
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				previous_points = int(parsed.get("total_points", previous_points))
				if str(parsed.get("date", "")) == today:
					_state = parsed
					return
	_state = create_daily_state(today, previous_points)
	_save()

func _today_key() -> String:
	var date := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(date.year), int(date.month), int(date.day)]

func _save() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://futbol_nova"))
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_state, "\t"))

static func create_daily_state(date_key: String, total_points: int = 0) -> Dictionary:
	var day_number := 0
	for byte_value in date_key.to_utf8_buffer():
		day_number += int(byte_value)
	var challenge: Dictionary = CHALLENGES[day_number % CHALLENGES.size()].duplicate(true)
	challenge["date"] = date_key
	challenge["progress"] = 0
	challenge["claimed"] = false
	challenge["total_points"] = total_points
	challenge["schema_version"] = 1
	return challenge

static func apply_event_to_state(state: Dictionary, event_type: String, amount: int = 1) -> Dictionary:
	var updated := state.duplicate(true)
	if str(updated.get("event_type", "")) == event_type and not bool(updated.get("claimed", false)):
		updated["progress"] = mini(int(updated.get("target", 1)), int(updated.get("progress", 0)) + maxi(amount, 0))
	return updated

static func claim_reward_from_state(state: Dictionary) -> Dictionary:
	var updated := state.duplicate(true)
	if bool(updated.get("claimed", false)):
		return {"ok": false, "error": "La recompensa de hoy ya fue reclamada."}
	if int(updated.get("progress", 0)) < int(updated.get("target", 1)):
		return {"ok": false, "error": "Completa el desafío antes de reclamar la recompensa."}
	var reward := int(updated.get("reward", 0))
	updated["claimed"] = true
	updated["total_points"] = int(updated.get("total_points", 0)) + reward
	return {"ok": true, "reward": reward, "state": updated}
