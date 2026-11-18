extends SceneTree

const TasEngine = preload("res://scripts/simulation/tas_match_decision_engine.gd")
const CatalogPath := "res://data/international_club_competitions.json"

func _initialize() -> void:
	var failures := PackedStringArray()
	_test_catalog_rules(failures)
	_test_tas_tiebreak_order(failures)
	_test_group_draw_stays_draw(failures)
	_test_final_decided_in_regulation(failures)
	_test_final_decided_in_extra_time(failures)
	_test_final_decided_on_penalties(failures)
	_test_final_simulation_is_reproducible(failures)
	if failures.is_empty():
		print("TAS MATCH DECISION ENGINE TESTS: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_catalog_rules(failures: PackedStringArray) -> void:
	var file := FileAccess.open(CatalogPath, FileAccess.READ)
	if file == null:
		failures.append("No se encontró el catálogo internacional.")
		return
	var catalog = JSON.parse_string(file.get_as_text())
	if not catalog is Dictionary:
		failures.append("El catálogo internacional no contiene JSON válido.")
		return
	for competition in catalog.get("competitions", []):
		if str(competition.get("id", "")) != "american_super_champions_tas":
			continue
		var rules: Dictionary = competition.get("match_rules", {})
		if str(rules.get("fixture_format", "")) != "single_match":
			failures.append("El TAS debe disputar todos sus encuentros a partido único.")
		if int(rules.get("regulation_minutes", 0)) != 90:
			failures.append("El TAS debe tener 90 minutos reglamentarios.")
		if bool(rules.get("group_stage", {}).get("draws_allowed", false)) != true:
			failures.append("La primera fase debe permitir empates.")
		if bool(rules.get("final_group", {}).get("draws_allowed", false)) != true:
			failures.append("El grupo final debe permitir empates.")
		if int(rules.get("extra_time", {}).get("minutes_per_period", 0)) != 15 or int(rules.get("extra_time", {}).get("periods", 0)) != 2:
			failures.append("La final debe contemplar dos tiempos de prórroga de 15 minutos.")
		var tiebreakers: Array = competition.get("tiebreakers", {}).get("ordered_criteria", [])
		var expected := ["points", "overall_goal_difference", "overall_goals_scored", "head_to_head_points_goal_difference_and_goals_scored_among_tied_teams", "fair_play_fewer_disciplinary_points", "reproducible_recorded_random_draw"]
		if tiebreakers != expected:
			failures.append("El catálogo no conserva el orden aprobado de desempates del TAS.")
		return
	failures.append("El TAS no está registrado en el catálogo.")

func _test_tas_tiebreak_order(failures: PackedStringArray) -> void:
	var points_table := {
		"A": _standing_row("A", 9, 1, 2, 8),
		"B": _standing_row("B", 6, 99, 99, 0)
	}
	var points_order := TasEngine.get_ordered_tas_table(points_table, 77)
	if str(points_order[0].team_id) != "A":
		failures.append("El TAS debe priorizar puntos sobre los demás criterios.")

	var goal_difference_table := {
		"A": _standing_row("A", 6, 5, 10, 8),
		"B": _standing_row("B", 6, 4, 99, 0)
	}
	goal_difference_table["A"]["head_to_head"]["B"] = {"points": 0, "goals_for": 0, "goals_against": 2}
	goal_difference_table["B"]["head_to_head"]["A"] = {"points": 3, "goals_for": 2, "goals_against": 0}
	var goal_difference_order := TasEngine.get_ordered_tas_table(goal_difference_table, 77)
	if str(goal_difference_order[0].team_id) != "A":
		failures.append("La diferencia de goles general debe preceder al enfrentamiento directo.")

	var goals_scored_table := {
		"A": _standing_row("A", 6, 2, 8, 8),
		"B": _standing_row("B", 6, 2, 7, 0)
	}
	goals_scored_table["A"]["head_to_head"]["B"] = {"points": 0, "goals_for": 0, "goals_against": 1}
	goals_scored_table["B"]["head_to_head"]["A"] = {"points": 3, "goals_for": 1, "goals_against": 0}
	var goals_scored_order := TasEngine.get_ordered_tas_table(goals_scored_table, 77)
	if str(goals_scored_order[0].team_id) != "A":
		failures.append("Los goles a favor generales deben preceder al enfrentamiento directo.")

	var direct_table := {
		"A": _standing_row("A", 6, 2, 8, 8),
		"B": _standing_row("B", 6, 2, 8, 0)
	}
	direct_table["A"]["head_to_head"]["B"] = {"points": 3, "goals_for": 2, "goals_against": 1}
	direct_table["B"]["head_to_head"]["A"] = {"points": 0, "goals_for": 1, "goals_against": 2}
	var direct_order := TasEngine.get_ordered_tas_table(direct_table, 77)
	if str(direct_order[0].team_id) != "A":
		failures.append("El enfrentamiento directo debe decidir antes que el juego limpio.")

	var three_way_table := {
		"A": _standing_row("A", 6, 2, 8, 2),
		"B": _standing_row("B", 6, 2, 8, 2),
		"C": _standing_row("C", 6, 2, 8, 2)
	}
	three_way_table["A"]["head_to_head"] = {
		"B": {"points": 3, "goals_for": 2, "goals_against": 0},
		"C": {"points": 0, "goals_for": 0, "goals_against": 1}
	}
	three_way_table["B"]["head_to_head"] = {
		"A": {"points": 0, "goals_for": 0, "goals_against": 2},
		"C": {"points": 3, "goals_for": 3, "goals_against": 0}
	}
	three_way_table["C"]["head_to_head"] = {
		"A": {"points": 3, "goals_for": 1, "goals_against": 0},
		"B": {"points": 0, "goals_for": 0, "goals_against": 3}
	}
	var three_way_order := TasEngine.get_ordered_tas_table(three_way_table, 77)
	if str(three_way_order[0].team_id) != "B":
		failures.append("El desempate múltiple debe calcular una minitabla solo entre los clubes empatados.")

	var fair_play_table := {
		"A": _standing_row("A", 6, 2, 8, 1),
		"B": _standing_row("B", 6, 2, 8, 4)
	}
	var fair_play_order := TasEngine.get_ordered_tas_table(fair_play_table, 77)
	if str(fair_play_order[0].team_id) != "A":
		failures.append("El juego limpio debe favorecer al equipo con menos puntos disciplinarios.")

	var draw_table := {
		"A": _standing_row("A", 6, 2, 8, 2),
		"B": _standing_row("B", 6, 2, 8, 2)
	}
	var draw_first := TasEngine.get_ordered_tas_table(draw_table, 2027)
	var draw_second := TasEngine.get_ordered_tas_table(draw_table, 2027)
	if str(draw_first[0].team_id) != str(draw_second[0].team_id) or int(draw_first[0].get("tas_draw_lot", 0)) == 0 or int(draw_second[0].get("tas_draw_lot", 0)) == 0:
		failures.append("El sorteo final debe registrar lotes y ser reproducible con la misma semilla.")

func _standing_row(team_id: String, points: int, goal_difference: int, goals_for: int, disciplinary_points: int) -> Dictionary:
	return {
		"team_id": team_id,
		"points": points,
		"goal_difference": goal_difference,
		"goals_for": goals_for,
		"disciplinary_points": disciplinary_points,
		"head_to_head": {}
	}

func _test_group_draw_stays_draw(failures: PackedStringArray) -> void:
	var response := TasEngine.resolve_group_match(_regulation_result(1, 1))
	if not bool(response.get("ok", false)):
		failures.append("El motor rechazó un empate válido en fase de grupos.")
		return
	var result: Dictionary = response.result
	if str(result.get("winner_team_id", "")) != "" or str(result.get("decision_method", "")) != "regulation":
		failures.append("Un empate de grupos no debe producir ganador ni prórroga.")
	if bool(result.get("extra_time", {}).get("played", true)) or bool(result.get("penalty_shootout", {}).get("played", true)):
		failures.append("Un partido de grupo no debe jugar prórroga ni penaltis.")

func _test_final_decided_in_regulation(failures: PackedStringArray) -> void:
	var response := TasEngine.resolve_championship_final(_regulation_result(2, 1), {})
	if not bool(response.get("ok", false)):
		failures.append("El motor rechazó una final decidida en 90 minutos.")
		return
	var result: Dictionary = response.result
	if str(result.get("winner_team_id", "")) != "HOME" or str(result.get("decision_method", "")) != "regulation":
		failures.append("La final no reconoció al ganador del tiempo reglamentario.")
	if bool(result.get("extra_time", {}).get("played", true)):
		failures.append("No debe jugarse prórroga si la final ya tiene ganador.")

func _test_final_decided_in_extra_time(failures: PackedStringArray) -> void:
	var response := TasEngine.resolve_championship_final(_regulation_result(1, 1), {"home": 1, "away": 0})
	if not bool(response.get("ok", false)):
		failures.append("El motor rechazó una final decidida en la prórroga.")
		return
	var result: Dictionary = response.result
	if str(result.get("winner_team_id", "")) != "HOME" or str(result.get("decision_method", "")) != "extra_time":
		failures.append("La final no reconoció al ganador de la prórroga.")
	if int(result.get("extra_time", {}).get("minutes", 0)) != 30:
		failures.append("La prórroga debe durar 30 minutos.")

func _test_final_decided_on_penalties(failures: PackedStringArray) -> void:
	var response := TasEngine.resolve_championship_final(_regulation_result(1, 1), {"home": 0, "away": 0}, {"home_score": 5, "away_score": 4, "kicks": []})
	if not bool(response.get("ok", false)):
		failures.append("El motor rechazó una final decidida por penaltis.")
		return
	var result: Dictionary = response.result
	if str(result.get("winner_team_id", "")) != "HOME" or str(result.get("decision_method", "")) != "penalties":
		failures.append("La final no reconoció al ganador de los penaltis.")
	if not bool(result.get("penalty_shootout", {}).get("played", false)):
		failures.append("No quedó registrada la tanda de penaltis.")
	var invalid := TasEngine.resolve_championship_final(_regulation_result(0, 0), {"home": 0, "away": 0}, {"home_score": 3, "away_score": 3})
	if bool(invalid.get("ok", false)):
		failures.append("El motor permitió una tanda de penaltis sin ganador.")

func _test_final_simulation_is_reproducible(failures: PackedStringArray) -> void:
	var regulation := _regulation_result(0, 0)
	var home := {"id": "HOME", "strength": 65.0}
	var away := {"id": "AWAY", "strength": 58.0}
	var first := TasEngine.simulate_championship_final(regulation, home, away, 2027)
	var second := TasEngine.simulate_championship_final(regulation, home, away, 2027)
	if not bool(first.get("ok", false)) or not bool(second.get("ok", false)):
		failures.append("El motor no pudo simular la resolución de la final.")
		return
	var first_result: Dictionary = first.result
	var second_result: Dictionary = second.result
	if str(first_result.get("winner_team_id", "")) != str(second_result.get("winner_team_id", "")) or first_result.get("final_score", {}) != second_result.get("final_score", {}) or first_result.get("penalty_shootout", {}) != second_result.get("penalty_shootout", {}):
		failures.append("La resolución de la final no es reproducible con la misma semilla.")
	if int(first_result.get("home_goals", -1)) != 0 or int(first_result.get("away_goals", -1)) != 0:
		failures.append("El motor alteró el marcador reglamentario al resolver la final.")

func _regulation_result(home_goals: int, away_goals: int) -> Dictionary:
	return {
		"match_id": "TAS-FINAL-TEST",
		"home_team_id": "HOME",
		"away_team_id": "AWAY",
		"home_goals": home_goals,
		"away_goals": away_goals,
		"status": "finished"
	}
