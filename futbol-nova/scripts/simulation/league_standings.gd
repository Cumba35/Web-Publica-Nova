extends RefCounted
class_name NovaLeagueStandings

# Reglas basadas en el artículo 29 del Reglamento de Competiciones RFEF:
# doble vuelta: desempates directos; una vuelta: diferencia y goles generales primero.

static func create_table(team_ids: Array) -> Dictionary:
	var table := {}
	for raw_id in team_ids:
		var team_id := str(raw_id)
		if not team_id.is_empty() and not table.has(team_id):
			table[team_id] = {
				"team_id": team_id, "played": 0, "won": 0, "drawn": 0, "lost": 0,
				"goals_for": 0, "goals_against": 0, "goal_difference": 0, "points": 0,
				"disciplinary_points": 0, "head_to_head": {}
			}
	return table

static func apply_result(table: Dictionary, result: Dictionary) -> bool:
	for field in ["home_team_id", "away_team_id", "home_goals", "away_goals"]:
		if not result.has(field):
			return false
	var home_id := str(result.home_team_id)
	var away_id := str(result.away_team_id)
	if home_id == away_id or not table.has(home_id) or not table.has(away_id):
		return false
	var home_goals := int(result.home_goals)
	var away_goals := int(result.away_goals)
	if home_goals < 0 or away_goals < 0:
		return false
	var home: Dictionary = table[home_id]
	var away: Dictionary = table[away_id]
	home.played += 1
	away.played += 1
	home.disciplinary_points += maxi(0, int(result.get("home_disciplinary_points", 0)))
	away.disciplinary_points += maxi(0, int(result.get("away_disciplinary_points", 0)))
	home.goals_for += home_goals
	home.goals_against += away_goals
	away.goals_for += away_goals
	away.goals_against += home_goals
	var home_points := 1
	var away_points := 1
	if home_goals > away_goals:
		home.won += 1
		away.lost += 1
		home.points += 3
		home_points = 3
	elif home_goals < away_goals:
		away.won += 1
		home.lost += 1
		away.points += 3
		away_points = 3
	else:
		home.drawn += 1
		away.drawn += 1
	var home_h2h: Dictionary = home.head_to_head.get(away_id, {"points": 0, "goals_for": 0, "goals_against": 0})
	var away_h2h: Dictionary = away.head_to_head.get(home_id, {"points": 0, "goals_for": 0, "goals_against": 0})
	home_h2h.points += home_points
	home_h2h.goals_for += home_goals
	home_h2h.goals_against += away_goals
	away_h2h.points += away_points
	away_h2h.goals_for += away_goals
	away_h2h.goals_against += home_goals
	home.head_to_head[away_id] = home_h2h
	away.head_to_head[home_id] = away_h2h
	home.goal_difference = home.goals_for - home.goals_against
	away.goal_difference = away.goals_for - away.goals_against
	table[home_id] = home
	table[away_id] = away
	return true

static func get_ordered_table(table: Dictionary, single_round: bool = false) -> Array:
	var rows: Array = []
	for team_id in table:
		rows.append(table[team_id].duplicate(true))
	var mini_table := _build_mini_table_metrics(table)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.points != b.points:
			return a.points > b.points
		var a_metrics: Dictionary = mini_table.get(str(a.team_id), {})
		var b_metrics: Dictionary = mini_table.get(str(b.team_id), {})
		if single_round:
			if a.goal_difference != b.goal_difference:
				return a.goal_difference > b.goal_difference
			if a.goals_for != b.goals_for:
				return a.goals_for > b.goals_for
			if int(a_metrics.get("points", 0)) != int(b_metrics.get("points", 0)):
				return int(a_metrics.get("points", 0)) > int(b_metrics.get("points", 0))
			if int(a_metrics.get("goal_difference", 0)) != int(b_metrics.get("goal_difference", 0)):
				return int(a_metrics.get("goal_difference", 0)) > int(b_metrics.get("goal_difference", 0))
		else:
			if int(a_metrics.get("tied_count", 0)) == 2:
				if int(a_metrics.get("goal_difference", 0)) != int(b_metrics.get("goal_difference", 0)):
					return int(a_metrics.get("goal_difference", 0)) > int(b_metrics.get("goal_difference", 0))
			else:
				if int(a_metrics.get("points", 0)) != int(b_metrics.get("points", 0)):
					return int(a_metrics.get("points", 0)) > int(b_metrics.get("points", 0))
				if int(a_metrics.get("goal_difference", 0)) != int(b_metrics.get("goal_difference", 0)):
					return int(a_metrics.get("goal_difference", 0)) > int(b_metrics.get("goal_difference", 0))
			if a.goal_difference != b.goal_difference:
				return a.goal_difference > b.goal_difference
			if a.goals_for != b.goals_for:
				return a.goals_for > b.goals_for
		if a.disciplinary_points != b.disciplinary_points:
			return a.disciplinary_points < b.disciplinary_points
		return str(a.team_id) < str(b.team_id))
	return rows

static func _build_mini_table_metrics(table: Dictionary) -> Dictionary:
	var groups: Dictionary = {}
	for team_id in table:
		var points := int(table[team_id].get("points", 0))
		if not groups.has(points):
			groups[points] = []
		groups[points].append(str(team_id))
	var metrics := {}
	for points in groups:
		var tied: Array = groups[points]
		for team_id in tied:
			metrics[team_id] = {"points": 0, "goals_for": 0, "goals_against": 0, "goal_difference": 0, "tied_count": tied.size()}
		if tied.size() < 2:
			continue
		for team_id in tied:
			var team: Dictionary = table[team_id]
			var row: Dictionary = metrics[team_id]
			for opponent_id in tied:
				if opponent_id == team_id:
					continue
				var h2h: Dictionary = team.get("head_to_head", {}).get(opponent_id, {})
				row.points += int(h2h.get("points", 0))
				row.goals_for += int(h2h.get("goals_for", 0))
				row.goals_against += int(h2h.get("goals_against", 0))
			row.goal_difference = row.goals_for - row.goals_against
			metrics[team_id] = row
	return metrics
