extends RefCounted
class_name NovaBoardObjectivesService

static func evaluate_match(objectives: Array, match_data: Dictionary) -> Array:
	var results: Array = []
	for objective in objectives:
		if not objective is Dictionary:
			continue
		var item: Dictionary = objective.duplicate(true)
		var type := str(item.get("type", ""))
		var target := int(item.get("target", 1))
		var progress := int(item.get("progress", 0))
		if type == "clean_disciplinary" and not match_data.has("yellow_cards") and not match_data.has("red_cards"):
			# Do not award discipline progress when the match engine has not tracked cards.
			progress = progress
		elif type == "clean_disciplinary" and (int(match_data.get("yellow_cards", 0)) > 0 or int(match_data.get("red_cards", 0)) > 0):
			progress = 0
		elif type == "start_under_age":
			progress = mini(target, _match_increment(type, match_data, item))
		else:
			progress = mini(target, progress + _match_increment(type, match_data, item))
		item["progress"] = progress
		item["completed"] = progress >= target
		item["status"] = "completed" if bool(item["completed"]) else "in_progress"
		results.append(item)
	return results

static func _match_increment(objective_type: String, match_data: Dictionary, objective: Dictionary) -> int:
	match objective_type:
		"clean_disciplinary":
			if not match_data.has("yellow_cards") and not match_data.has("red_cards"):
				return 0
			return 1 if int(match_data.get("yellow_cards", 0)) == 0 and int(match_data.get("red_cards", 0)) == 0 else 0
		"score_both_halves":
			return 1 if bool(match_data.get("scored_first_half", false)) and bool(match_data.get("scored_second_half", false)) else 0
		"start_under_age":
			var minimum := int(objective.get("minimum_players", 3))
			var max_age := int(objective.get("max_age_exclusive", 25))
			var count := 0
			for player in match_data.get("starting_lineup", []):
				if int(player.get("age", 99)) < max_age:
					count += 1
			return mini(minimum, count)
		"win_match":
			return 1 if int(match_data.get("team_goals", 0)) > int(match_data.get("opponent_goals", 0)) else 0
		"points":
			if int(match_data.get("team_goals", 0)) > int(match_data.get("opponent_goals", 0)):
				return 3
			if int(match_data.get("team_goals", 0)) == int(match_data.get("opponent_goals", 0)):
				return 1
			return 0
		_:
			return 0

static func create_default_objectives() -> Array:
	return [
		{"id": "discipline_4", "type": "clean_disciplinary", "title": "No recibir tarjetas amarillas ni rojas en 4 partidos", "target": 4, "progress": 0, "board_trust_impact": 3, "matches_remaining": 4, "period": "short_term"},
		{"id": "score_both_halves_6", "type": "score_both_halves", "title": "Marcar en ambas partes en 6 partidos", "target": 6, "progress": 0, "board_trust_impact": 4, "matches_remaining": 10, "period": "short_term"},
		{"id": "youth_start_3", "type": "start_under_age", "title": "Alinear al menos 3 jugadores menores de 25 años en un mismo partido", "target": 3, "progress": 0, "minimum_players": 3, "max_age_exclusive": 25, "board_trust_impact": 2, "matches_remaining": 5, "period": "short_term", "requires_operational_academy": false}
	]

static func create_rotation_pool() -> Array:
	return [
		{"id": "discipline_4", "type": "clean_disciplinary", "title": "No recibir tarjetas en 4 partidos", "target": 4, "progress": 0, "reward": 200, "period": "short_term"},
		{"id": "discipline_6", "type": "clean_disciplinary", "title": "No recibir tarjetas en 6 partidos", "target": 6, "progress": 0, "reward": 300, "period": "short_term"},
		{"id": "score_both_halves_6", "type": "score_both_halves", "title": "Marcar en ambas partes en 6 partidos", "target": 6, "progress": 0, "reward": 300, "period": "short_term"},
		{"id": "score_both_halves_4", "type": "score_both_halves", "title": "Marcar en ambas partes en 4 partidos", "target": 4, "progress": 0, "reward": 200, "period": "short_term"},
		{"id": "youth_start_3", "type": "start_under_age", "title": "Alinear al menos 3 titulares menores de 25 años", "target": 3, "progress": 0, "minimum_players": 3, "max_age_exclusive": 25, "reward": 100, "period": "short_term"},
		{"id": "win_3", "type": "win_match", "title": "Ganar 3 partidos", "target": 3, "progress": 0, "board_trust_impact": 3, "matches_remaining": 6, "period": "short_term"}
	]
