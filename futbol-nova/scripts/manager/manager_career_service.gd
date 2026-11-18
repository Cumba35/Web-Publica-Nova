extends Node
class_name NovaManagerCareerService

signal career_started(state: Dictionary)
signal objectives_updated(objectives: Array)
signal objective_completed(objective: Dictionary)
signal board_confidence_changed(value: int)
signal career_warning(message: String)

const OBJECTIVES = preload("res://scripts/manager/board_objectives_service.gd")
const SAVE_PATH := "user://manager_career.json"
const CONFIDENCE_MIN := 0
const CONFIDENCE_MAX := 100
const DISMISSAL_THRESHOLD := 20

var career: Dictionary = {}
var objective_rotation_index := 0

func start_coach_career(club_id: String, initial_confidence: int = 60) -> Dictionary:
	if club_id.strip_edges().is_empty():
		return {"ok": false, "error": "Selecciona un club para iniciar la carrera"}
	career = {
		"schema_version": "1.0.0",
		"role": "coach",
		"club_id": club_id,
		"board_confidence": clampi(initial_confidence, CONFIDENCE_MIN, CONFIDENCE_MAX),
		"board_points": 0,
		"matches_managed": 0,
		"objectives": OBJECTIVES.create_default_objectives(),
		"completed_objectives": [],
		"last_match_id": "",
		"processed_match_ids": [],
		"status": "active"
	}
	objective_rotation_index = 0
	var saved := save_career()
	career_started.emit(career.duplicate(true))
	return {"ok": saved, "career": career.duplicate(true)}

func process_match(match_data: Dictionary) -> Dictionary:
	if career.is_empty() or str(career.get("role", "")) != "coach":
		return {"ok": false, "error": "No hay una carrera de entrenador activa"}
	var match_id := str(match_data.get("match_id", match_data.get("fixture_id", "")))
	if match_id.is_empty():
		return {"ok": false, "error": "El resultado necesita un identificador único de partido"}
	var processed: Array = career.get("processed_match_ids", [])
	if processed.has(match_id):
		return {"ok": false, "error": "Este partido ya fue procesado"}
	var before: Array = career.get("objectives", [])
	var after := OBJECTIVES.evaluate_match(before, match_data)
	var completed_now: Array = []
	var next_objectives: Array = []
	for i in range(after.size()):
		var objective: Dictionary = after[i]
		var was_completed := bool(before[i].get("completed", false))
		if bool(objective.get("completed", false)) and not was_completed:
			completed_now.append(objective.duplicate(true))
			career["board_points"] = int(career.get("board_points", 0)) + int(objective.get("reward", 0))
			career["board_confidence"] = clampi(int(career.get("board_confidence", 60)) + 3, CONFIDENCE_MIN, CONFIDENCE_MAX)
			career["completed_objectives"].append(objective.duplicate(true))
			objective_completed.emit(objective.duplicate(true))
			next_objectives.append(_next_objective(str(objective.get("id", "")), next_objectives))
		else:
			next_objectives.append(objective)
	career["objectives"] = next_objectives
	career["matches_managed"] = int(career.get("matches_managed", 0)) + 1
	career["last_match_id"] = match_id
	processed.append(match_id)
	career["processed_match_ids"] = processed
	career["board_confidence"] = clampi(int(career.get("board_confidence", 60)), CONFIDENCE_MIN, CONFIDENCE_MAX)
	if int(career.board_confidence) <= DISMISSAL_THRESHOLD:
		career_warning.emit("La confianza de la junta es crítica. Tu puesto está en peligro.")
	if not completed_now.is_empty():
		objectives_updated.emit(next_objectives.duplicate(true))
	board_confidence_changed.emit(int(career.board_confidence))
	var saved := save_career()
	return {"ok": saved, "completed": completed_now, "objectives": next_objectives.duplicate(true), "board_confidence": int(career.board_confidence), "board_points": int(career.board_points)}

func apply_board_review(delta: int, reason: String) -> Dictionary:
	if career.is_empty():
		return {"ok": false, "error": "No hay carrera activa"}
	career["board_confidence"] = clampi(int(career.get("board_confidence", 60)) + delta, CONFIDENCE_MIN, CONFIDENCE_MAX)
	career["last_board_review"] = {"delta": delta, "reason": reason, "confidence": career.board_confidence}
	if int(career.board_confidence) <= DISMISSAL_THRESHOLD:
		career_warning.emit("La junta puede destituirte por falta de confianza.")
	board_confidence_changed.emit(int(career.board_confidence))
	save_career()
	return {"ok": true, "confidence": int(career.board_confidence), "dismissal_risk": int(career.board_confidence) <= DISMISSAL_THRESHOLD}

func get_career_state() -> Dictionary:
	return career.duplicate(true)

func save_career() -> bool:
	if career.is_empty():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(career, "\t"))
	if file.get_error() != OK:
		return false
	if get_tree() != null and get_tree().root.has_node("FootballDatabase"):
		return FootballDatabase.save_career_record("manager_active", career)
	return true

func load_career() -> bool:
	var parsed: Variant = null
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary and get_tree() != null and get_tree().root.has_node("FootballDatabase"):
		var backup_record: Dictionary = FootballDatabase.get_career_record("manager_active")
		if not backup_record.is_empty():
			parsed = backup_record
	if not parsed is Dictionary:
		return false
	if not parsed is Dictionary or str(parsed.get("schema_version", "")) != "1.0.0" or str(parsed.get("role", "")) != "coach":
		return false
	career = parsed
	return true

func _next_objective(completed_id: String, active_objectives: Array) -> Dictionary:
	var pool := OBJECTIVES.create_rotation_pool()
	var active_ids: Array[String] = []
	for active in active_objectives:
		active_ids.append(str(active.get("id", "")))
	objective_rotation_index = (objective_rotation_index + 1) % pool.size()
	for offset in range(pool.size()):
		var index := (objective_rotation_index + offset) % pool.size()
		var candidate: Dictionary = pool[index]
		var candidate_id := str(candidate.get("id", ""))
		if candidate_id != completed_id and not active_ids.has(candidate_id):
			objective_rotation_index = index
			return candidate.duplicate(true)
	for candidate in pool:
		if str(candidate.get("id", "")) == completed_id:
			return candidate.duplicate(true)
	return {}
