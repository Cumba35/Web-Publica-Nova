extends RefCounted
class_name NovaTASMatchDecisionEngine

const REGULATION_MINUTES := 90
const EXTRA_TIME_PERIODS := 2
const EXTRA_TIME_MINUTES_PER_PERIOD := 15
const INITIAL_PENALTY_KICKS := 5

# Los partidos de grupo terminan tras 90 minutos y conservan el empate.
static func resolve_group_match(regulation_result: Dictionary) -> Dictionary:
	if not _is_valid_result(regulation_result):
		return {"ok": false, "error": "El resultado reglamentario del partido no es válido."}
	var resolved := regulation_result.duplicate(true)
	resolved["decision_method"] = "regulation"
	resolved["winner_team_id"] = ""
	resolved["draw_allowed"] = true
	resolved["extra_time"] = {"played": false}
	resolved["penalty_shootout"] = {"played": false}
	return {"ok": true, "result": resolved}

# La final solo se decide tras 90 minutos, 30 minutos de prórroga y,
# si persiste el empate, una tanda de penaltis.
static func resolve_championship_final(regulation_result: Dictionary, extra_time_goals: Dictionary, penalty_shootout: Dictionary = {}) -> Dictionary:
	if not _is_valid_result(regulation_result):
		return {"ok": false, "error": "El resultado reglamentario de la final no es válido."}
	var home_id := str(regulation_result.home_team_id)
	var away_id := str(regulation_result.away_team_id)
	var home_regulation := int(regulation_result.home_goals)
	var away_regulation := int(regulation_result.away_goals)
	var resolved := regulation_result.duplicate(true)
	resolved["regulation_score"] = {"home": home_regulation, "away": away_regulation}
	resolved["extra_time"] = {"played": false, "minutes": 0, "home_goals": 0, "away_goals": 0}
	resolved["penalty_shootout"] = {"played": false}
	resolved["final_score"] = {"home": home_regulation, "away": away_regulation}
	resolved["draw_allowed"] = false
	if home_regulation != away_regulation:
		resolved["decision_method"] = "regulation"
		resolved["winner_team_id"] = home_id if home_regulation > away_regulation else away_id
		return {"ok": true, "result": resolved}
	if not extra_time_goals.has("home") or not extra_time_goals.has("away"):
		return {"ok": false, "error": "La final empatada necesita registrar los goles de la prórroga."}
	var home_extra := int(extra_time_goals.home)
	var away_extra := int(extra_time_goals.away)
	if home_extra < 0 or away_extra < 0:
		return {"ok": false, "error": "Los goles de la prórroga no pueden ser negativos."}
	var home_after_extra := home_regulation + home_extra
	var away_after_extra := away_regulation + away_extra
	resolved["extra_time"] = {
		"played": true,
		"minutes": EXTRA_TIME_PERIODS * EXTRA_TIME_MINUTES_PER_PERIOD,
		"periods": EXTRA_TIME_PERIODS,
		"minutes_per_period": EXTRA_TIME_MINUTES_PER_PERIOD,
		"home_goals": home_extra,
		"away_goals": away_extra
	}
	resolved["final_score"] = {"home": home_after_extra, "away": away_after_extra}
	if home_after_extra != away_after_extra:
		resolved["decision_method"] = "extra_time"
		resolved["winner_team_id"] = home_id if home_after_extra > away_after_extra else away_id
		return {"ok": true, "result": resolved}
	if not penalty_shootout.has("home_score") or not penalty_shootout.has("away_score"):
		return {"ok": false, "error": "La final empatada tras la prórroga necesita una tanda de penaltis."}
	var home_penalties := int(penalty_shootout.home_score)
	var away_penalties := int(penalty_shootout.away_score)
	if home_penalties < 0 or away_penalties < 0 or home_penalties == away_penalties:
		return {"ok": false, "error": "La tanda debe tener marcadores no negativos y un ganador."}
	resolved["decision_method"] = "penalties"
	resolved["winner_team_id"] = home_id if home_penalties > away_penalties else away_id
	resolved["penalty_shootout"] = {
		"played": true,
		"home_score": home_penalties,
		"away_score": away_penalties,
		"kicks": penalty_shootout.get("kicks", []).duplicate(true) if penalty_shootout.get("kicks", []) is Array else []
	}
	return {"ok": true, "result": resolved}

# Simulación reproducible de los 30 minutos extra y de la tanda cuando hacen falta.
# El marcador reglamentario permanece intacto; el marcador definitivo y el ganador
# se guardan en campos separados para no contaminar las estadísticas de liga.
static func simulate_championship_final(regulation_result: Dictionary, home_team: Dictionary, away_team: Dictionary, seed: int = 1) -> Dictionary:
	if not _is_valid_result(regulation_result):
		return {"ok": false, "error": "El resultado reglamentario de la final no es válido."}
	if str(home_team.get("id", "")) != str(regulation_result.home_team_id) or str(away_team.get("id", "")) != str(regulation_result.away_team_id):
		return {"ok": false, "error": "Los perfiles de los clubes no corresponden a los participantes de la final."}
	if int(regulation_result.home_goals) != int(regulation_result.away_goals):
		return resolve_championship_final(regulation_result, {})
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var home_strength := clampf(float(home_team.get("strength", 50.0)), 1.0, 99.0)
	var away_strength := clampf(float(away_team.get("strength", 50.0)), 1.0, 99.0)
	var strength_difference := home_strength - away_strength
	var home_extra := _sample_poisson(rng, clampf(0.34 + strength_difference * 0.008, 0.08, 0.85))
	var away_extra := _sample_poisson(rng, clampf(0.34 - strength_difference * 0.008, 0.08, 0.85))
	var extra_time_goals := {"home": home_extra, "away": away_extra}
	var home_after_extra := int(regulation_result.home_goals) + home_extra
	var away_after_extra := int(regulation_result.away_goals) + away_extra
	if home_after_extra != away_after_extra:
		return resolve_championship_final(regulation_result, extra_time_goals)
	var penalties := _simulate_penalty_shootout(rng, home_strength, away_strength)
	return resolve_championship_final(regulation_result, extra_time_goals, penalties)

static func _simulate_penalty_shootout(rng: RandomNumberGenerator, home_strength: float, away_strength: float) -> Dictionary:
	var home_probability := clampf(0.76 + (home_strength - 50.0) * 0.0015, 0.68, 0.84)
	var away_probability := clampf(0.76 + (away_strength - 50.0) * 0.0015, 0.68, 0.84)
	var home_score := 0
	var away_score := 0
	var kicks: Array = []
	for round_index in range(INITIAL_PENALTY_KICKS):
		var home_scored := rng.randf() < home_probability
		var away_scored := rng.randf() < away_probability
		if home_scored:
			home_score += 1
		if away_scored:
			away_score += 1
		kicks.append({"round": round_index + 1, "home_scored": home_scored, "away_scored": away_scored, "sudden_death": false})
		var remaining := INITIAL_PENALTY_KICKS - round_index - 1
		if home_score > away_score + remaining or away_score > home_score + remaining:
			return {"home_score": home_score, "away_score": away_score, "kicks": kicks}
	var sudden_death_round := 0
	while home_score == away_score:
		sudden_death_round += 1
		var home_sudden_scored := rng.randf() < home_probability
		var away_sudden_scored := rng.randf() < away_probability
		if home_sudden_scored:
			home_score += 1
		if away_sudden_scored:
			away_score += 1
		kicks.append({"round": INITIAL_PENALTY_KICKS + sudden_death_round, "home_scored": home_sudden_scored, "away_scored": away_sudden_scored, "sudden_death": true})
	return {"home_score": home_score, "away_score": away_score, "kicks": kicks}

# Clasificación oficial del TAS: puntos, diferencia, goles a favor,
# enfrentamiento directo, juego limpio y sorteo reproducible.
static func get_ordered_tas_table(table: Dictionary, draw_seed: int = 1) -> Array:
	var rows: Array = []
	for team_id in table:
		var row: Dictionary = table[team_id].duplicate(true)
		row["team_id"] = str(row.get("team_id", team_id))
		rows.append(row)
	var head_to_head := _build_tas_head_to_head_metrics(table)
	var draw_lots := _build_tas_draw_lots(rows, head_to_head, draw_seed)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("points", 0)) != int(b.get("points", 0)):
			return int(a.get("points", 0)) > int(b.get("points", 0))
		if int(a.get("goal_difference", 0)) != int(b.get("goal_difference", 0)):
			return int(a.get("goal_difference", 0)) > int(b.get("goal_difference", 0))
		if int(a.get("goals_for", 0)) != int(b.get("goals_for", 0)):
			return int(a.get("goals_for", 0)) > int(b.get("goals_for", 0))
		var a_direct: Dictionary = head_to_head.get(str(a.team_id), {})
		var b_direct: Dictionary = head_to_head.get(str(b.team_id), {})
		if int(a_direct.get("points", 0)) != int(b_direct.get("points", 0)):
			return int(a_direct.get("points", 0)) > int(b_direct.get("points", 0))
		if int(a_direct.get("goal_difference", 0)) != int(b_direct.get("goal_difference", 0)):
			return int(a_direct.get("goal_difference", 0)) > int(b_direct.get("goal_difference", 0))
		if int(a_direct.get("goals_for", 0)) != int(b_direct.get("goals_for", 0)):
			return int(a_direct.get("goals_for", 0)) > int(b_direct.get("goals_for", 0))
		if int(a.get("disciplinary_points", 0)) != int(b.get("disciplinary_points", 0)):
			return int(a.get("disciplinary_points", 0)) < int(b.get("disciplinary_points", 0))
		return int(draw_lots.get(str(a.team_id), 0)) < int(draw_lots.get(str(b.team_id), 0)))
	for row in rows:
		row["tas_draw_lot"] = int(draw_lots.get(str(row.team_id), 0))
	return rows

static func _build_tas_head_to_head_metrics(table: Dictionary) -> Dictionary:
	var point_groups := {}
	for team_id in table:
		var points := int(table[team_id].get("points", 0))
		if not point_groups.has(points):
			point_groups[points] = []
		point_groups[points].append(str(team_id))
	var metrics := {}
	for team_id in table:
		metrics[str(team_id)] = {"points": 0, "goals_for": 0, "goals_against": 0, "goal_difference": 0}
	for points in point_groups:
		var tied: Array = point_groups[points]
		if tied.size() < 2:
			continue
		for team_id in tied:
			var team: Dictionary = table[team_id]
			var row: Dictionary = metrics[str(team_id)]
			for opponent_id in tied:
				if opponent_id == team_id:
					continue
				var direct: Dictionary = team.get("head_to_head", {}).get(opponent_id, {})
				row["points"] += int(direct.get("points", 0))
				row["goals_for"] += int(direct.get("goals_for", 0))
				row["goals_against"] += int(direct.get("goals_against", 0))
			row["goal_difference"] = int(row.goals_for) - int(row.goals_against)
			metrics[str(team_id)] = row
	return metrics

static func _build_tas_draw_lots(rows: Array, head_to_head: Dictionary, draw_seed: int) -> Dictionary:
	var tied_groups := {}
	for row in rows:
		var team_id := str(row.get("team_id", ""))
		var direct: Dictionary = head_to_head.get(team_id, {})
		var key := "%d|%d|%d|%d|%d|%d|%d" % [
			int(row.get("points", 0)),
			int(row.get("goal_difference", 0)),
			int(row.get("goals_for", 0)),
			int(direct.get("points", 0)),
			int(direct.get("goal_difference", 0)),
			int(direct.get("goals_for", 0)),
			int(row.get("disciplinary_points", 0))
		]
		if not tied_groups.has(key):
			tied_groups[key] = []
		tied_groups[key].append(team_id)
	var rng := RandomNumberGenerator.new()
	rng.seed = maxi(1, draw_seed)
	var lots := {}
	for key in tied_groups:
		var team_ids: Array = tied_groups[key].duplicate()
		for index in range(team_ids.size() - 1, 0, -1):
			var swap_index := rng.randi_range(0, index)
			var temp = team_ids[index]
			team_ids[index] = team_ids[swap_index]
			team_ids[swap_index] = temp
		for index in range(team_ids.size()):
			lots[str(team_ids[index])] = index + 1
	return lots

static func _sample_poisson(rng: RandomNumberGenerator, lambda_value: float) -> int:
	var limit := exp(-lambda_value)
	var product := 1.0
	var count := 0
	while product > limit and count < 12:
		count += 1
		product *= rng.randf()
	return maxi(0, count - 1)

static func _is_valid_result(result: Dictionary) -> bool:
	for field in ["home_team_id", "away_team_id", "home_goals", "away_goals", "status"]:
		if not result.has(field):
			return false
	if str(result.get("home_team_id", "")).is_empty() or str(result.get("away_team_id", "")).is_empty() or str(result.home_team_id) == str(result.away_team_id):
		return false
	if str(result.status) != "finished" or int(result.home_goals) < 0 or int(result.away_goals) < 0:
		return false
	return true
