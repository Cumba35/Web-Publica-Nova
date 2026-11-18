extends RefCounted
class_name NovaMatchSubstitutionRules

## Pure, deterministic substitution limits based on Fútbol Nova's GAME_DESIGN.md.

const REGULATION_SUBSTITUTIONS := 5
const REGULATION_WINDOWS := 3
const EXTRA_TIME_BONUS_SUBSTITUTIONS := 1
const EXTRA_TIME_BONUS_WINDOWS := 1
const FRIENDLY_SUBSTITUTIONS := 11
const VALID_PHASES := ["match", "half_time", "extra_time_half_time", "injury_stoppage", "before_penalties"]

static func create_team_state(is_friendly: bool = false, extra_time_enabled: bool = false) -> Dictionary:
	return {
		"friendly": is_friendly,
		"extra_time_enabled": extra_time_enabled,
		"substitutions_used": 0,
		"windows_used": 0,
		"window_ids": [],
		"substituted_player_ids": [],
		"dismissed_player_ids": [],
		"severely_injured_player_ids": []
	}

static func maximum_substitutions(state: Dictionary) -> int:
	if bool(state.get("friendly", false)):
		return FRIENDLY_SUBSTITUTIONS
	return REGULATION_SUBSTITUTIONS + (EXTRA_TIME_BONUS_SUBSTITUTIONS if bool(state.get("extra_time_enabled", false)) else 0)

static func maximum_windows(state: Dictionary) -> int:
	if bool(state.get("friendly", false)):
		return FRIENDLY_SUBSTITUTIONS
	return REGULATION_WINDOWS + (EXTRA_TIME_BONUS_WINDOWS if bool(state.get("extra_time_enabled", false)) else 0)

static func can_substitute(state: Dictionary, outgoing_player_id: String, incoming_player_id: String, window_id: String, phase: String = "match") -> Dictionary:
	if outgoing_player_id.is_empty() or incoming_player_id.is_empty() or outgoing_player_id == incoming_player_id:
		return {"ok": false, "reason": "invalid_player_ids"}
	if window_id.is_empty() or not VALID_PHASES.has(phase):
		return {"ok": false, "reason": "invalid_substitution_window"}
	if _contains_id(state.get("dismissed_player_ids", []), outgoing_player_id):
		return {"ok": false, "reason": "outgoing_player_dismissed"}
	if _contains_id(state.get("substituted_player_ids", []), outgoing_player_id):
		return {"ok": false, "reason": "outgoing_player_already_substituted"}
	if _contains_id(state.get("substituted_player_ids", []), incoming_player_id):
		return {"ok": false, "reason": "incoming_player_already_substituted"}
	if _contains_id(state.get("dismissed_player_ids", []), incoming_player_id):
		return {"ok": false, "reason": "incoming_player_dismissed"}
	if _contains_id(state.get("severely_injured_player_ids", []), incoming_player_id):
		return {"ok": false, "reason": "incoming_player_severely_injured"}
	var windows: Array = state.get("window_ids", [])
	var is_new_window := not windows.has(window_id)
	if int(state.get("substitutions_used", 0)) >= maximum_substitutions(state):
		return {"ok": false, "reason": "substitution_limit_reached"}
	if is_new_window and int(state.get("windows_used", 0)) >= maximum_windows(state):
		return {"ok": false, "reason": "window_limit_reached"}
	return {"ok": true, "new_window": is_new_window, "phase": phase}

static func apply_substitution(state: Dictionary, outgoing_player_id: String, incoming_player_id: String, window_id: String, phase: String = "match") -> Dictionary:
	var validation := can_substitute(state, outgoing_player_id, incoming_player_id, window_id, phase)
	if not bool(validation.get("ok", false)):
		return {"ok": false, "reason": str(validation.get("reason", "not_allowed"))}
	var updated := state.duplicate(true)
	updated["substitutions_used"] = int(updated.get("substitutions_used", 0)) + 1
	var windows: Array = updated.get("window_ids", []).duplicate()
	if bool(validation.get("new_window", false)):
		windows.append(window_id)
		updated["windows_used"] = int(updated.get("windows_used", 0)) + 1
	updated["window_ids"] = windows
	var substituted: Array = updated.get("substituted_player_ids", []).duplicate()
	substituted.append(outgoing_player_id)
	updated["substituted_player_ids"] = substituted
	return {"ok": true, "state": updated, "used_window": bool(validation.get("new_window", false))}

static func mark_player_dismissed(state: Dictionary, player_id: String) -> Dictionary:
	var updated := state.duplicate(true)
	var ids: Array = updated.get("dismissed_player_ids", []).duplicate()
	if not player_id.is_empty() and not ids.has(player_id):
		ids.append(player_id)
	updated["dismissed_player_ids"] = ids
	return updated

static func mark_player_severely_injured(state: Dictionary, player_id: String) -> Dictionary:
	var updated := state.duplicate(true)
	var ids: Array = updated.get("severely_injured_player_ids", []).duplicate()
	if not player_id.is_empty() and not ids.has(player_id):
		ids.append(player_id)
	updated["severely_injured_player_ids"] = ids
	return updated

static func _contains_id(values: Variant, player_id: String) -> bool:
	return values is Array and values.has(player_id)
