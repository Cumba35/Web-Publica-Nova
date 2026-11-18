extends RefCounted
class_name NovaCompetitionCalendarBuilder

static func build_second_division_playoff(ordered_team_ids: Array, competition_id: String = "cuba_segunda_division_nova", season_id: String = "season_1") -> Array:
	if ordered_team_ids.size() < 6:
		return []
	var third := str(ordered_team_ids[2])
	var fourth := str(ordered_team_ids[3])
	var fifth := str(ordered_team_ids[4])
	var sixth := str(ordered_team_ids[5])
	var fixtures: Array = []
	fixtures.append_array(_two_leg_tie(competition_id, season_id, "playoff_sf_1", third, sixth, 1))
	fixtures.append_array(_two_leg_tie(competition_id, season_id, "playoff_sf_2", fourth, fifth, 3))
	fixtures.append_array(_two_leg_tie(competition_id, season_id, "playoff_final", "winner:playoff_sf_1", "winner:playoff_sf_2", 5))
	return fixtures

static func build_third_division_promotion_playoff(group_a: Array, group_b: Array, competition_id: String = "cuba_tercera_division_nova", season_id: String = "season_1") -> Array:
	# Los campeones de grupo ascienden directamente; los subcampeones disputan
	# una eliminatoria a doble partido por la tercera plaza de ascenso.
	if group_a.size() < 2 or group_b.size() < 2:
		return []
	return _two_leg_tie(competition_id, season_id, "promotion_playoff_third_place", str(group_a[1]), str(group_b[1]), 1)

# Compatibilidad temporal con versiones que llamaban Final Four al playoff.
static func build_third_division_final_four(group_a: Array, group_b: Array, competition_id: String = "cuba_tercera_division_nova", season_id: String = "season_1") -> Array:
	return build_third_division_promotion_playoff(group_a, group_b, competition_id, season_id)

static func build_copa_de_cuba(team_records: Array, competition_id: String = "copa_de_cuba_nova", season_id: String = "season_1") -> Dictionary:
	var teams: Array = []
	var seen := {}
	for record in team_records:
		if not record is Dictionary:
			continue
		var team_id := str(record.get("id", ""))
		if team_id.is_empty() or seen.has(team_id):
			continue
		seen[team_id] = true
		teams.append({"id": team_id, "level": int(record.get("division_level", record.get("competition_level", 99)))})
	if teams.size() < 2:
		return {"ok": false, "rounds": [], "errors": ["Se necesitan al menos dos clubes"]}
	teams.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.level) != int(b.level):
			return int(a.level) < int(b.level)
		return str(a.id) < str(b.id))
	var bracket_size := 1
	while bracket_size < teams.size():
		bracket_size *= 2
	var byes := bracket_size - teams.size()
	var preliminary_teams := teams.slice(byes)
	var preliminary_ties: Array = []
	var advancing_slots: Array = []
	var rounds: Array = []
	if byes > 0:
		for i in range(int(preliminary_teams.size() / 2)):
			var tie_number := preliminary_ties.size() + 1
			var opposite_index := preliminary_teams.size() - 1 - i
			preliminary_ties.append(_cup_tie(competition_id, season_id, "preliminary", tie_number, preliminary_teams[i], preliminary_teams[opposite_index], false))
			advancing_slots.append("winner:cup_preliminary_%02d" % tie_number)
		for team in teams.slice(0, byes):
			advancing_slots.append(str(team.id))
		var bye_ids: Array[String] = []
		for bye_team in teams.slice(0, byes):
			bye_ids.append(str(bye_team.id))
		rounds.append({"round_id": "preliminary", "ties": preliminary_ties, "bye_team_ids": bye_ids, "two_legs": false})
	else:
		for team in teams:
			advancing_slots.append(str(team.id))
	var round_index := 0
	while advancing_slots.size() > 1:
		var name := _round_name(advancing_slots.size())
		var ties: Array = []
		for i in range(0, advancing_slots.size(), 2):
			if i + 1 >= advancing_slots.size():
				break
			var tie_number := ties.size() + 1
			var tie_id := "cup_%s_%02d" % [name, tie_number]
			var team_a := str(advancing_slots[i])
			var team_b := str(advancing_slots[i + 1])
			if name == "semifinals":
				ties.append_array(_two_leg_tie(competition_id, season_id, tie_id, team_a, team_b, round_index + 2))
			elif name == "final":
				ties.append(_single_tie(competition_id, season_id, "cup_final", team_a, team_b, round_index + 2, true))
			else:
				var cup_fixture := _single_tie(competition_id, season_id, tie_id, team_a, team_b, round_index + 2, false)
				cup_fixture["home_advantage_rule"] = "lower_division_team_hosts"
				ties.append(cup_fixture)
		rounds.append({"round_id": name, "ties": ties, "two_legs": name == "semifinals"})
		var next_slots: Array = []
		if name == "semifinals":
			for tie_index in range(int(ties.size() / 2)):
				next_slots.append("winner:" + str(ties[tie_index * 2].get("tie_id", "")))
		else:
			for tie in ties:
				next_slots.append("winner:" + str(tie.get("tie_id", "")))
		advancing_slots = next_slots
		round_index += 1
		if name == "final":
			break
	return {"ok": true, "team_count": teams.size(), "bracket_size": bracket_size, "bye_count": byes, "rounds": rounds, "errors": []}

static func _two_leg_tie(competition_id: String, season_id: String, tie_id: String, team_a: String, team_b: String, start_round: int) -> Array:
	var first := _single_tie(competition_id, season_id, tie_id, team_a, team_b, start_round, false, 1)
	var second := _single_tie(competition_id, season_id, tie_id, team_b, team_a, start_round + 1, false, 2)
	first["fixture_id"] = "%s_%s_%s_leg1" % [competition_id, season_id, tie_id]
	second["fixture_id"] = "%s_%s_%s_leg2" % [competition_id, season_id, tie_id]
	for fixture in [first, second]:
		fixture["aggregate_score"] = true
		fixture["extra_time_on_level_aggregate"] = true
		fixture["penalties_if_still_level"] = true
	return [first, second]

static func _single_tie(competition_id: String, season_id: String, tie_id: String, home_id: String, away_id: String, round_number: int, neutral: bool, leg: int = 1) -> Dictionary:
	return {"fixture_id": "%s_%s_%s" % [competition_id, season_id, tie_id], "competition_id": competition_id, "season_id": season_id, "tie_id": tie_id, "round": round_number, "leg": leg, "home_team_id": home_id, "away_team_id": away_id, "neutral_venue": neutral, "extra_time_if_draw": true, "penalties_if_still_draw": true, "status": "scheduled"}

static func _cup_tie(competition_id: String, season_id: String, round_id: String, tie_number: int, team_a: Dictionary, team_b: Dictionary, neutral: bool) -> Dictionary:
	var home := team_a
	var away := team_b
	if not neutral and int(team_a.level) < int(team_b.level):
		home = team_b
		away = team_a
	return _single_tie(competition_id, season_id, "cup_%s_%02d" % [round_id, tie_number], str(home.id), str(away.id), 1, neutral)

static func _round_name(slot_count: int) -> String:
	match slot_count:
		32:
			return "round_of_32"
		16:
			return "round_of_16"
		8:
			return "quarterfinals"
		4:
			return "semifinals"
		2:
			return "final"
		_:
			return "preliminary"

static func build_supercopa_final_four(qualified_team_ids: Array, semifinal_pairs: Array = [], competition_id: String = "supercopa_de_cuba_nova", season_id: String = "season_1") -> Array:
	if qualified_team_ids.size() != 4:
		return []
	var pairs := semifinal_pairs.duplicate(true)
	if pairs.size() != 2:
		pairs = [[str(qualified_team_ids[0]), str(qualified_team_ids[3])], [str(qualified_team_ids[1]), str(qualified_team_ids[2])]]
	if pairs[0].size() != 2 or pairs[1].size() != 2:
		return []
	var fixtures := [
		_single_tie(competition_id, season_id, "supercup_semifinal_1", str(pairs[0][0]), str(pairs[0][1]), 1, true),
		_single_tie(competition_id, season_id, "supercup_semifinal_2", str(pairs[1][0]), str(pairs[1][1]), 1, true),
		_single_tie(competition_id, season_id, "supercup_final", "winner:supercup_semifinal_1", "winner:supercup_semifinal_2", 2, true)
	]
	for fixture in fixtures:
		fixture["extra_time_if_draw"] = false
		fixture["penalties_if_still_draw"] = true
	return fixtures
