extends RefCounted
class_name NovaSeasonMatchSimulator

const MATCH_MINUTES := 90
const SIMULATION_VERSION := "nova_quick_sim_1"

static func simulate(fixture: Dictionary, home_team: Dictionary, away_team: Dictionary, seed: int = 1) -> Dictionary:
	for field in ["fixture_id", "home_team_id", "away_team_id"]:
		if not fixture.has(field):
			return {}
	if str(home_team.get("id", "")) != str(fixture.home_team_id) or str(away_team.get("id", "")) != str(fixture.away_team_id):
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var home_strength := _team_strength(home_team)
	var away_strength := _team_strength(away_team)
	var home_xg := clampf(1.28 + (home_strength - away_strength) * 0.035 + 0.22, 0.15, 4.2) * _form_factor(home_team)
	var away_xg := clampf(1.08 + (away_strength - home_strength) * 0.035, 0.12, 4.0) * _form_factor(away_team)
	var home_goals := _sample_poisson(rng, home_xg)
	var away_goals := _sample_poisson(rng, away_xg)
	var state := NovaMatchContract.create_match(str(fixture.fixture_id), str(fixture.home_team_id), str(fixture.away_team_id), seed)
	if state.is_empty():
		return {}
	state.status = NovaMatchContract.STATUS_LIVE
	state.simulation_version = SIMULATION_VERSION
	state.statistics.home.shots = maxi(home_goals, rng.randi_range(3, 12))
	state.statistics.away.shots = maxi(away_goals, rng.randi_range(2, 11))
	state.statistics.home.shots_on_target = mini(int(state.statistics.home.shots), home_goals + rng.randi_range(1, 3))
	state.statistics.away.shots_on_target = mini(int(state.statistics.away.shots), away_goals + rng.randi_range(1, 3))
	state.statistics.home.passes_attempted = rng.randi_range(260, 560)
	state.statistics.away.passes_attempted = rng.randi_range(240, 540)
	state.statistics.home.passes_completed = int(state.statistics.home.passes_attempted * rng.randf_range(0.68, 0.91))
	state.statistics.away.passes_completed = int(state.statistics.away.passes_attempted * rng.randf_range(0.66, 0.90))
	state.statistics.home.fouls = rng.randi_range(5, 17)
	state.statistics.away.fouls = rng.randi_range(5, 18)
	state.statistics.home.corners = rng.randi_range(0, 9)
	state.statistics.away.corners = rng.randi_range(0, 9)
	state.statistics.home.offsides = rng.randi_range(0, 5)
	state.statistics.away.offsides = rng.randi_range(0, 5)
	state.statistics.home.possession_seconds = rng.randf_range(0.38, 0.62) * 5400.0
	state.statistics.away.possession_seconds = 5400.0 - state.statistics.home.possession_seconds
	for index in range(home_goals):
		NovaMatchContract.record_goal(state, str(fixture.home_team_id), _random_scorer(home_team, rng), rng.randi_range(1, 90))
	for index in range(away_goals):
		NovaMatchContract.record_goal(state, str(fixture.away_team_id), _random_scorer(away_team, rng), rng.randi_range(1, 90))
	state.events.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.minute) == int(b.minute):
			return int(a.sequence) < int(b.sequence)
		return int(a.minute) < int(b.minute))
	state.minute = MATCH_MINUTES
	NovaMatchContract.finish_match(state, MATCH_MINUTES)
	var result := NovaMatchContract.to_result(state)
	result["expected_goals"] = {"home": snappedf(home_xg, 0.01), "away": snappedf(away_xg, 0.01)}
	result["lineups"] = {
		"home": home_team.get("starting_player_ids", []).duplicate(),
		"away": away_team.get("starting_player_ids", []).duplicate()
	}
	result["source"] = "simulated"
	return result

static func _team_strength(team: Dictionary) -> float:
	return clampf(float(team.get("strength", 50.0)), 1.0, 99.0)

static func _form_factor(team: Dictionary) -> float:
	return clampf(float(team.get("form_factor", 1.0)), 0.75, 1.25)

static func _sample_poisson(rng: RandomNumberGenerator, lambda_value: float) -> int:
	var limit := exp(-lambda_value)
	var product := 1.0
	var count := 0
	while product > limit and count < 12:
		count += 1
		product *= rng.randf()
	return maxi(0, count - 1)

static func _random_scorer(team: Dictionary, rng: RandomNumberGenerator) -> String:
	var scorers = team.get("scorer_player_ids", [])
	if scorers is Array and not scorers.is_empty():
		return str(scorers[rng.randi_range(0, scorers.size() - 1)])
	return ""
