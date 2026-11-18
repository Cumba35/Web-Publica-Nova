extends SceneTree

const PROGRESSION = preload("res://scripts/data/season_progression_service.gd")
const STATS = preload("res://scripts/data/player_statistics_service.gd")

func _initialize() -> void:
	var upper := [
		{"team_id": "A"}, {"team_id": "B"}, {"team_id": "C"}, {"team_id": "D"}
	]
	var lower := [
		{"team_id": "E"}, {"team_id": "F"}, {"team_id": "G"}, {"team_id": "H"}
	]
	var plan := PROGRESSION.build_promotion_relegation_plan(
		["tier_1", "tier_2"],
		{"tier_1": upper, "tier_2": lower},
		{"tier_1": {"relegation_slots": 2}, "tier_2": {"promotion_slots": 2}}
	)
	assert(plan.ok and plan.movement_count == 4)
	assert(plan.moves[0].team_id == "E" and plan.moves[0].to_competition_id == "tier_1")
	assert(plan.moves[1].team_id == "F" and plan.moves[1].to_competition_id == "tier_1")
	assert(plan.moves[2].team_id == "D" and plan.moves[2].to_competition_id == "tier_2")
	assert(plan.moves[3].team_id == "C" and plan.moves[3].to_competition_id == "tier_2")

	var closed_plan := PROGRESSION.build_promotion_relegation_plan(
		["mls", "usl"],
		{"mls": upper, "usl": lower},
		{"mls": {"closed_system": true}, "usl": {"promotion_slots": 2}}
	)
	assert(not closed_plan.ok)

	var fixtures := PROGRESSION.build_next_season_fixtures(["A", "B", "C", "D"], "tier_1", "2027", true)
	assert(fixtures.ok and fixtures.fixture_count == 12)
	var invalid_fixtures := PROGRESSION.build_next_season_fixtures(["A", "A"], "tier_1", "2027", false)
	assert(not invalid_fixtures.ok)

	var player := STATS.normalize_player({
		"id": "P1",
		"primary_position": "DC",
		"statistics": {
			"career": {"appearances": 2, "goals": 1},
			"current_season": {"appearances": 2, "starts": 2, "minutes": 180, "goals": 1}
		}
	})
	var archived := PROGRESSION.archive_player_season({"P1": player}, "2026")
	assert(archived.ok and archived.archived_players == 1)
	var updated: Dictionary = archived.players.P1.statistics
	assert(updated.career.appearances == 2 and updated.career.goals == 1)
	assert(updated.current_season.appearances == 0)
	assert(updated.season_history.size() == 1)
	assert(updated.season_history[0].season_id == "2026")
	assert(not PROGRESSION.archive_player_season(archived.players, "2026").ok)

	print("Season progression and rollover: PASS")
	quit(0)
