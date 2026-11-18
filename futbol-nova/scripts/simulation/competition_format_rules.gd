extends RefCounted
class_name NovaCompetitionFormatRules

const RULES_PATH := "res://data/cuban_competition_rules.json"

static func load_rules(path: String = RULES_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

static func qualify_supercopa(league_table: Array, cup_champion: String, cup_runner_up: String) -> Array:
	var selected: Array[String] = []
	if not league_table.is_empty():
		_add_unique(selected, str(league_table[0].get("team_id", "")))
	if league_table.size() > 1:
		_add_unique(selected, str(league_table[1].get("team_id", "")))
	_add_unique(selected, cup_champion)
	_add_unique(selected, cup_runner_up)
	for row in league_table:
		if selected.size() >= 4:
			break
		_add_unique(selected, str(row.get("team_id", "")))
	return selected.slice(0, 4)

static func create_cup_tie(home_team_id: String, away_team_id: String, home_division_level: int, away_division_level: int, neutral_venue: bool = false) -> Dictionary:
	var actual_home := home_team_id
	var actual_away := away_team_id
	if not neutral_venue and home_division_level > 0 and away_division_level > 0:
		if home_division_level < away_division_level:
			actual_home = away_team_id
			actual_away = home_team_id
	return {
		"home_team_id": actual_home,
		"away_team_id": actual_away,
		"legs": 1,
		"neutral_venue": neutral_venue,
		"extra_time_if_draw": true,
		"penalties_if_still_draw": true
	}

static func create_semifinal_tie(team_a_id: String, team_b_id: String) -> Dictionary:
	return {
		"home_team_id": team_a_id,
		"away_team_id": team_b_id,
		"legs": 2,
		"neutral_venue": false,
		"aggregate_score": true,
		"extra_time_on_level_aggregate": true,
		"penalties_if_still_level": true
	}

static func create_supercopa_match(team_a_id: String, team_b_id: String, stage: String) -> Dictionary:
	return {
		"home_team_id": team_a_id,
		"away_team_id": team_b_id,
		"stage": stage,
		"legs": 1,
		"neutral_venue": true,
		"extra_time": false,
		"penalties_if_draw": true
	}

static func _add_unique(selected: Array[String], team_id: String) -> void:
	if not team_id.is_empty() and not selected.has(team_id):
		selected.append(team_id)
