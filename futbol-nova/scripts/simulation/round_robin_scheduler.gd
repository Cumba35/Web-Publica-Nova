extends RefCounted
class_name NovaRoundRobinScheduler

static func create_fixtures(team_ids: Array, competition_id: String, season_id: String, double_round_robin: bool = true) -> Array:
	var teams: Array[String] = []
	var seen := {}
	for raw_id in team_ids:
		var team_id := str(raw_id)
		if not team_id.is_empty() and not seen.has(team_id):
			seen[team_id] = true
			teams.append(team_id)
	if teams.size() < 2:
		return []
	if teams.size() % 2 == 1:
		teams.append("__BYE__")
	var count := teams.size()
	var rounds := count - 1
	var half := int(count / 2)
	var rotation := teams.duplicate()
	var fixtures: Array = []
	var match_number := 1
	for round_index in range(rounds):
		for pair_index in range(half):
			var first: String = str(rotation[pair_index])
			var second: String = str(rotation[count - 1 - pair_index])
			if first == "__BYE__" or second == "__BYE__":
				continue
			var home_id: String = first
			var away_id: String = second
			if (round_index + pair_index) % 2 == 1:
				home_id = second
				away_id = first
			fixtures.append(_fixture(competition_id, season_id, match_number, round_index + 1, home_id, away_id, 1))
			match_number += 1
		var fixed: String = str(rotation[0])
		var tail: Array = rotation.slice(1)
		tail.push_front(tail.pop_back())
		rotation = [fixed]
		rotation.append_array(tail)
	if double_round_robin:
		var first_leg := fixtures.duplicate(true)
		for fixture in first_leg:
			fixtures.append(_fixture(competition_id, season_id, match_number, int(fixture.round) + rounds, str(fixture.away_team_id), str(fixture.home_team_id), 2))
			match_number += 1
	return fixtures

static func _fixture(competition_id: String, season_id: String, match_number: int, round_number: int, home_id: String, away_id: String, leg: int) -> Dictionary:
	return {"fixture_id": "%s_%s_%03d" % [competition_id, season_id, match_number], "competition_id": competition_id, "season_id": season_id, "round": round_number, "leg": leg, "home_team_id": home_id, "away_team_id": away_id, "status": "scheduled", "result": null}
