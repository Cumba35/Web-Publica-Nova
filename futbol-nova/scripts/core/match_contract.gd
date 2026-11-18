extends RefCounted
class_name NovaMatchContract

const SCHEMA_VERSION := "1.0.0"
const STATUS_SCHEDULED := "scheduled"
const STATUS_LIVE := "live"
const STATUS_FINISHED := "finished"
const STATUS_ABANDONED := "abandoned"
const EVENT_GOAL := "goal"
const EVENT_FULL_TIME := "full_time"

static func create_match(match_id: String, home_team_id: String, away_team_id: String, seed: int = 1) -> Dictionary:
	if match_id.is_empty() or home_team_id.is_empty() or away_team_id.is_empty() or home_team_id == away_team_id:
		return {}
	return {
		"schema_version": SCHEMA_VERSION,
		"match_id": match_id,
		"home_team_id": home_team_id,
		"away_team_id": away_team_id,
		"status": STATUS_SCHEDULED,
		"minute": 0,
		"added_time": 0,
		"score": {"home": 0, "away": 0},
		"seed": seed,
		"simulation_version": "nova_match_core_1",
		"events": [],
		"statistics": {
			"home": _empty_statistics(),
			"away": _empty_statistics()
		}
	}

static func _empty_statistics() -> Dictionary:
	return {"shots": 0, "shots_on_target": 0, "passes_attempted": 0, "passes_completed": 0, "fouls": 0, "corners": 0, "offsides": 0, "possession_seconds": 0.0}

static func append_event(state: Dictionary, event_type: String, minute: int, team_id: String = "", player_id: String = "", payload: Dictionary = {}) -> bool:
	if not validate_state(state) or event_type.is_empty() or minute < 0 or minute > 130:
		return false
	if not team_id.is_empty() and team_id != state.home_team_id and team_id != state.away_team_id:
		return false
	state.events.append({"sequence": state.events.size() + 1, "type": event_type, "minute": minute, "team_id": team_id, "player_id": player_id, "payload": payload.duplicate(true)})
	return true

static func record_goal(state: Dictionary, team_id: String, scorer_id: String, minute: int, own_goal: bool = false) -> bool:
	if not validate_state(state) or state.status == STATUS_FINISHED:
		return false
	if team_id != state.home_team_id and team_id != state.away_team_id:
		return false
	if not append_event(state, EVENT_GOAL, minute, team_id, scorer_id, {"own_goal": own_goal}):
		return false
	var side := "home" if team_id == state.home_team_id else "away"
	state.score[side] = int(state.score[side]) + 1
	return true

static func finish_match(state: Dictionary, minute: int) -> bool:
	if not validate_state(state) or minute < int(state.minute):
		return false
	state.minute = minute
	state.status = STATUS_FINISHED
	return append_event(state, EVENT_FULL_TIME, minute)

static func validate_state(state: Dictionary) -> bool:
	for key in ["schema_version", "match_id", "home_team_id", "away_team_id", "status", "minute", "score", "events", "statistics"]:
		if not state.has(key):
			return false
	if str(state.home_team_id).is_empty() or str(state.away_team_id).is_empty() or state.home_team_id == state.away_team_id:
		return false
	if not state.score is Dictionary or not state.score.has("home") or not state.score.has("away"):
		return false
	if int(state.score.home) < 0 or int(state.score.away) < 0:
		return false
	return state.events is Array and state.statistics is Dictionary

static func to_result(state: Dictionary) -> Dictionary:
	if not validate_state(state) or state.status != STATUS_FINISHED:
		return {}
	return {
		"schema_version": SCHEMA_VERSION,
		"match_id": state.match_id,
		"home_team_id": state.home_team_id,
		"away_team_id": state.away_team_id,
		"home_goals": int(state.score.home),
		"away_goals": int(state.score.away),
		"status": STATUS_FINISHED,
		"minute": int(state.minute),
		"seed": int(state.get("seed", 1)),
		"simulation_version": str(state.get("simulation_version", "unknown")),
		"events": state.events.duplicate(true),
		"statistics": state.statistics.duplicate(true)
	}
