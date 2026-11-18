extends RefCounted
class_name NovaMatchClockStateMachine

## Runtime match-period state machine. Uses the user's configured short match durations.
const MatchClockRules = preload("res://scripts/gameplay/match_clock_rules.gd")

static func create_state(settings: Dictionary = {}) -> Dictionary:
	var half_minutes := int(settings.get("half_length_minutes", 5))
	if not MatchClockRules.is_valid_half_length(half_minutes):
		half_minutes = 5
	var clock_mode := str(settings.get("clock_mode", MatchClockRules.CLOCK_CONTINUOUS))
	if not [MatchClockRules.CLOCK_STOPPED, MatchClockRules.CLOCK_CONTINUOUS].has(clock_mode):
		clock_mode = MatchClockRules.CLOCK_CONTINUOUS
	var state := {
		"active": true,
		"phase": "first_half",
		"half_length_minutes": half_minutes,
		"clock_mode": clock_mode,
		"elapsed_seconds": 0.0,
		"period_duration_seconds": MatchClockRules.period_length_seconds(half_minutes),
		"added_seconds": 0,
		"added_time_decided": false,
		"lost_seconds": 0.0,
		"period_index": 0,
		"awaiting_user": false,
		"interruption_reasons": [],
		"score_home": int(settings.get("score_home", 0)),
		"score_away": int(settings.get("score_away", 0)),
		"extra_time_enabled": bool(settings.get("extra_time_enabled", false)),
		"competition_allows_extra_time": bool(settings.get("competition_allows_extra_time", false)),
		"penalties_enabled": bool(settings.get("penalties_enabled", false)),
		"competition_allows_penalties": bool(settings.get("competition_allows_penalties", false))
	}
	return state

static func tick(state: Dictionary, delta: float) -> Dictionary:
	var updated := state.duplicate(true)
	var events: Array[String] = []
	if not bool(updated.get("active", false)) or bool(updated.get("awaiting_user", false)) or delta <= 0.0:
		return {"state": updated, "events": events}
	var interruptions: Array = updated.get("interruption_reasons", [])
	if str(updated.get("clock_mode", MatchClockRules.CLOCK_CONTINUOUS)) == MatchClockRules.CLOCK_STOPPED and not interruptions.is_empty():
		return {"state": updated, "events": events}
	updated["elapsed_seconds"] = float(updated.get("elapsed_seconds", 0.0)) + delta
	if str(updated.get("clock_mode", "")) == MatchClockRules.CLOCK_CONTINUOUS and not interruptions.is_empty():
		updated["lost_seconds"] = float(updated.get("lost_seconds", 0.0)) + delta
	var elapsed := float(updated.get("elapsed_seconds", 0.0))
	var duration := int(updated.get("period_duration_seconds", 0))
	if not bool(updated.get("added_time_decided", false)) and elapsed >= duration:
		var added := MatchClockRules.calculate_added_time_seconds(
			str(updated.get("clock_mode", MatchClockRules.CLOCK_CONTINUOUS)),
			int(updated.get("half_length_minutes", 5)),
			float(updated.get("lost_seconds", 0.0)),
			int(updated.get("period_index", 0))
		)
		updated["added_seconds"] = added
		updated["added_time_decided"] = true
		events.append("added_time_started")
	if elapsed >= duration + int(updated.get("added_seconds", 0)):
		_advance(updated, events)
	return {"state": updated, "events": events}

static func set_interruption(state: Dictionary, reason: String, active: bool) -> Dictionary:
	var updated := state.duplicate(true)
	if reason.is_empty():
		return updated
	var reasons: Array = updated.get("interruption_reasons", []).duplicate()
	if active and not reasons.has(reason):
		reasons.append(reason)
	elif not active:
		reasons.erase(reason)
	updated["interruption_reasons"] = reasons
	return updated

static func set_score(state: Dictionary, home_score: int, away_score: int) -> Dictionary:
	var updated := state.duplicate(true)
	updated["score_home"] = maxi(0, home_score)
	updated["score_away"] = maxi(0, away_score)
	return updated

static func continue_after_break(state: Dictionary) -> Dictionary:
	var updated := state.duplicate(true)
	if not bool(updated.get("active", false)) or not bool(updated.get("awaiting_user", false)):
		return {"ok": false, "state": updated, "reason": "not_waiting_for_user"}
	var phase := str(updated.get("phase", ""))
	if phase == "half_time":
		_start_period(updated, "second_half", 1, int(updated.get("half_length_minutes", 5)))
	elif phase == "extra_time_half_time":
		_start_period(updated, "extra_time_second_half", 3, MatchClockRules.extra_time_half_minutes(int(updated.get("half_length_minutes", 5))))
	else:
		return {"ok": false, "state": updated, "reason": "unknown_break"}
	updated["awaiting_user"] = false
	return {"ok": true, "state": updated}

static func get_remaining_seconds(state: Dictionary) -> float:
	var total := int(state.get("period_duration_seconds", 0)) + int(state.get("added_seconds", 0))
	return maxf(0.0, float(total) - float(state.get("elapsed_seconds", 0.0)))

static func _advance(state: Dictionary, events: Array[String]) -> void:
	match str(state.get("phase", "")):
		"first_half":
			state["phase"] = "half_time"
			state["awaiting_user"] = true
			events.append("half_time_reached")
		"second_half":
			if MatchClockRules.can_start_extra_time(
				bool(state.get("extra_time_enabled", false)),
				int(state.get("score_home", 0)) == int(state.get("score_away", 0)),
				bool(state.get("competition_allows_extra_time", false))
			):
				var regular_minutes := int(state.get("half_length_minutes", 5))
				_start_period(state, "extra_time_first_half", 2, MatchClockRules.extra_time_half_minutes(regular_minutes))
				events.append("extra_time_started")
			else:
				_finish_or_start_penalties(state, events)
		"extra_time_first_half":
			state["phase"] = "extra_time_half_time"
			state["awaiting_user"] = true
			events.append("extra_time_half_time_reached")
		"extra_time_second_half":
			_finish_or_start_penalties(state, events)
		_:
			_finish(state, events)

static func _finish_or_start_penalties(state: Dictionary, events: Array[String]) -> void:
	var drawn := int(state.get("score_home", 0)) == int(state.get("score_away", 0))
	if drawn and bool(state.get("penalties_enabled", false)) and bool(state.get("competition_allows_penalties", false)):
		state["phase"] = "penalty_shootout"
		state["active"] = false
		state["awaiting_user"] = false
		events.append("penalty_shootout_pending")
	else:
		_finish(state, events)

static func _finish(state: Dictionary, events: Array[String]) -> void:
	state["phase"] = "full_time"
	state["active"] = false
	state["awaiting_user"] = false
	events.append("full_time_reached")

static func _start_period(state: Dictionary, phase: String, period_index: int, minutes: int) -> void:
	state["phase"] = phase
	state["period_index"] = period_index
	state["elapsed_seconds"] = 0.0
	state["period_duration_seconds"] = minutes * 60
	state["added_seconds"] = 0
	state["added_time_decided"] = false
	state["lost_seconds"] = 0.0
	state["interruption_reasons"] = []
