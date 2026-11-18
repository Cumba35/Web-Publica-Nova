extends RefCounted
class_name NovaMatchClockRules

## Pure timing rules taken from docs/GAME_DESIGN.md.
## Values are real seconds in the configured match clock, not wall-clock timestamps.

const HALF_LENGTHS_MINUTES := [3, 5, 6, 8, 10, 15, 20]
const EXTRA_TIME_BY_REGULAR_HALF := {
	3: 1,
	5: 2,
	6: 2,
	8: 3,
	10: 3,
	15: 5,
	20: 7
}

const CLOCK_STOPPED := "stopped"
const CLOCK_CONTINUOUS := "continuous"

static func is_valid_half_length(minutes: int) -> bool:
	return HALF_LENGTHS_MINUTES.has(minutes)

static func extra_time_half_minutes(regular_half_minutes: int) -> int:
	return int(EXTRA_TIME_BY_REGULAR_HALF.get(regular_half_minutes, 0))

static func period_length_seconds(minutes: int) -> int:
	return minutes * 60 if is_valid_half_length(minutes) else 0

static func calculate_added_time_seconds(clock_mode: String, regular_half_minutes: int, lost_seconds: float, period_index: int = 0) -> int:
	if not is_valid_half_length(regular_half_minutes):
		return 0
	var losses := maxi(0, int(ceil(lost_seconds)))
	if clock_mode == CLOCK_CONTINUOUS:
		# The product specification requires added time in every timed period.
		# One minute is the floor; actual losses can extend it without a fixed cap.
		return maxi(60, losses)
	if clock_mode != CLOCK_STOPPED:
		return 0
	# Stopped-clock mode always adds 1–3 minutes. Longer configured halves
	# and more interruptions increase the referee's autonomous allowance.
	var length_factor := 1 if regular_half_minutes <= 5 else (2 if regular_half_minutes <= 10 else 3)
	var loss_factor := int(ceil(float(losses) / 60.0))
	var period_factor := 1 if period_index >= 2 else 0
	var added_minutes := clampi(1 + int(loss_factor >= 2) + int(length_factor >= 3 and loss_factor >= 1) + period_factor, 1, 3)
	return added_minutes * 60

static func period_sequence(extra_time_enabled: bool, penalties_enabled: bool) -> Array[String]:
	var phases: Array[String] = ["first_half", "half_time", "second_half", "full_time"]
	if extra_time_enabled:
		phases.insert(3, "extra_time_first_half")
		phases.insert(4, "extra_time_half_time")
		phases.insert(5, "extra_time_second_half")
		phases.insert(6, "extra_time_end")
		if penalties_enabled:
			phases.append("penalty_shootout")
	return phases

static func can_start_extra_time(extra_time_enabled: bool, regulation_drawn: bool, competition_allows_it: bool) -> bool:
	return extra_time_enabled and regulation_drawn and competition_allows_it
