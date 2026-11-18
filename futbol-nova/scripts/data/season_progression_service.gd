extends RefCounted
class_name NovaSeasonProgressionService

const SCHEDULER = preload("res://scripts/simulation/round_robin_scheduler.gd")
const PLAYER_STATISTICS = preload("res://scripts/data/player_statistics_service.gd")

# Construye ascensos y descensos solo cuando la configuración del juego los define
# expresamente. Los sistemas cerrados o con playoff no se adivinan.
static func build_promotion_relegation_plan(league_order: Array, standings_by_competition: Dictionary, rules_by_competition: Dictionary) -> Dictionary:
	if league_order.size() < 2:
		return {"ok": false, "error": "Se necesitan al menos dos divisiones relacionadas.", "moves": []}
	var moves: Array = []
	var seen_teams := {}
	for index in range(league_order.size() - 1):
		var upper_id := str(league_order[index])
		var lower_id := str(league_order[index + 1])
		if upper_id.is_empty() or lower_id.is_empty() or upper_id == lower_id:
			return {"ok": false, "error": "La jerarquía de divisiones contiene IDs inválidos.", "moves": []}
		if not standings_by_competition.has(upper_id) or not standings_by_competition.has(lower_id):
			return {"ok": false, "error": "Falta la clasificación de " + upper_id + " o " + lower_id + ".", "moves": []}
		var upper_table: Array = standings_by_competition[upper_id]
		var lower_table: Array = standings_by_competition[lower_id]
		var upper_rule: Dictionary = rules_by_competition.get(upper_id, {})
		var lower_rule: Dictionary = rules_by_competition.get(lower_id, {})
		if bool(upper_rule.get("closed_system", false)) or bool(lower_rule.get("closed_system", false)):
			return {"ok": false, "error": "Las competiciones cerradas no admiten ascensos/descensos automáticos.", "moves": []}
		if bool(upper_rule.get("promotion_requires_playoff", false)) or bool(lower_rule.get("promotion_requires_playoff", false)):
			return {"ok": false, "error": "La promoción requiere resolver el playoff antes de cerrar la temporada.", "moves": []}
		var relegation_count := int(upper_rule.get("relegation_slots", 0))
		var promotion_count := int(lower_rule.get("promotion_slots", 0))
		if relegation_count < 0 or promotion_count < 0 or relegation_count > upper_table.size() or promotion_count > lower_table.size():
			return {"ok": false, "error": "Número de plazas de ascenso/descenso no válido.", "moves": []}
		for place in range(promotion_count):
			var promoted_id := str(lower_table[place].get("team_id", ""))
			if promoted_id.is_empty() or seen_teams.has(promoted_id):
				return {"ok": false, "error": "Club ascendido vacío o repetido.", "moves": []}
			seen_teams[promoted_id] = true
			moves.append({"team_id": promoted_id, "from_competition_id": lower_id, "to_competition_id": upper_id, "movement": "promotion", "place": place + 1})
		for offset in range(relegation_count):
			var place_index := upper_table.size() - 1 - offset
			var relegated_id := str(upper_table[place_index].get("team_id", ""))
			if relegated_id.is_empty() or seen_teams.has(relegated_id):
				return {"ok": false, "error": "Club descendido vacío o repetido.", "moves": []}
			seen_teams[relegated_id] = true
			moves.append({"team_id": relegated_id, "from_competition_id": upper_id, "to_competition_id": lower_id, "movement": "relegation", "place": place_index + 1})
	return {"ok": true, "moves": moves, "movement_count": moves.size()}

static func build_next_season_fixtures(team_ids: Array, stage_id: String, season_id: String, double_round_robin: bool) -> Dictionary:
	if stage_id.is_empty() or season_id.is_empty() or team_ids.size() < 2:
		return {"ok": false, "error": "Fase, temporada o participantes no válidos.", "fixtures": []}
	var unique := {}
	for raw_id in team_ids:
		var team_id := str(raw_id)
		if team_id.is_empty() or unique.has(team_id):
			return {"ok": false, "error": "Club vacío o duplicado en la nueva temporada.", "fixtures": []}
		unique[team_id] = true
	var fixtures: Array = SCHEDULER.create_fixtures(team_ids, stage_id, season_id, double_round_robin)
	var expected := int(team_ids.size() * (team_ids.size() - 1) / 2)
	if double_round_robin:
		expected *= 2
	if fixtures.size() != expected:
		return {"ok": false, "error": "El calendario de la nueva temporada no está completo.", "fixtures": []}
	return {"ok": true, "fixtures": fixtures, "fixture_count": fixtures.size(), "season_id": season_id}

static func archive_player_season(players_by_id: Dictionary, season_id: String) -> Dictionary:
	if season_id.is_empty():
		return {"ok": false, "error": "Falta el identificador de temporada.", "players": players_by_id.duplicate(true)}
	var updated := players_by_id.duplicate(true)
	var archived_count := 0
	for player_id in updated:
		var player: Dictionary = PLAYER_STATISTICS.normalize_player(updated[player_id])
		var statistics: Dictionary = player.statistics
		var history: Array = statistics.get("season_history", []).duplicate(true)
		for entry in history:
			if str(entry.get("season_id", "")) == season_id:
				return {"ok": false, "error": "La temporada ya está archivada para el futbolista " + str(player_id) + ".", "players": players_by_id.duplicate(true)}
		var current: Dictionary = PLAYER_STATISTICS.normalize_totals(statistics.get("current_season", {}))
		if int(current.get("appearances", 0)) > 0:
			current["season_id"] = season_id
			history.append(current)
			statistics["season_history"] = history
			statistics["current_season"] = PLAYER_STATISTICS.empty_statistics()
			statistics["data_status"] = "registrado"
			player["statistics"] = statistics
			updated[player_id] = player
			archived_count += 1
	return {"ok": true, "players": updated, "archived_players": archived_count, "season_id": season_id}
