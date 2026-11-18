extends RefCounted
class_name NovaPlayerStatisticsService

const SCHEMA_VERSION := "1.0.0"
const COUNTER_FIELDS := [
	"appearances", "starts", "substitute_appearances", "minutes",
	"wins", "draws", "losses", "goals", "assists", "shots", "shots_on_target",
	"passes", "passes_completed", "key_passes", "chances_created",
	"dribbles", "dribbles_completed", "tackles", "interceptions", "recoveries",
	"fouls", "fouls_won", "yellow_cards", "red_cards", "saves", "clean_sheets",
	"penalties_scored", "penalties_missed", "player_of_match", "rated_appearances"
]
const DERIVED_FIELDS := [
	"average_rating", "pass_accuracy", "dribble_success_rate",
	"goals_per_appearance", "assists_per_appearance"
]

static func empty_statistics() -> Dictionary:
	var result := {}
	for key in COUNTER_FIELDS:
		result[key] = 0
	for key in DERIVED_FIELDS:
		result[key] = null
	result["rating_total"] = 0.0
	return result

static func normalize_player(player: Dictionary) -> Dictionary:
	var normalized := player.duplicate(true)
	var root = normalized.get("statistics", {})
	if not root is Dictionary:
		root = {}
	var statistics: Dictionary = root.duplicate(true)
	statistics["schema_version"] = SCHEMA_VERSION
	var career = statistics.get("career", {})
	var season = statistics.get("current_season", {})
	statistics["career"] = normalize_totals(career if career is Dictionary else {})
	statistics["current_season"] = normalize_totals(season if season is Dictionary else {})
	if not statistics.get("season_history", []) is Array:
		statistics["season_history"] = []
	var has_recorded_matches := int(statistics["career"].get("appearances", 0)) > 0
	statistics["data_status"] = str(statistics.get("data_status", "registrado" if has_recorded_matches else "sin_partidos_registrados"))
	normalized["statistics"] = statistics
	return normalized

static func normalize_totals(source: Dictionary) -> Dictionary:
	var result := empty_statistics()
	for key in COUNTER_FIELDS:
		if source.has(key):
			result[key] = maxi(0, int(source[key]))
	if source.has("rating_total"):
		result["rating_total"] = maxf(0.0, float(source["rating_total"]))
	var appearances := int(result["appearances"])
	var passes := int(result["passes"])
	var dribbles := int(result["dribbles"])
	var rated := int(result["rated_appearances"])
	result["pass_accuracy"] = float(result["passes_completed"]) * 100.0 / float(passes) if passes > 0 else null
	result["dribble_success_rate"] = float(result["dribbles_completed"]) * 100.0 / float(dribbles) if dribbles > 0 else null
	result["goals_per_appearance"] = float(result["goals"]) / float(appearances) if appearances > 0 else null
	result["assists_per_appearance"] = float(result["assists"]) / float(appearances) if appearances > 0 else null
	result["average_rating"] = float(result["rating_total"]) / float(rated) if rated > 0 else null
	return result


# Registra únicamente participación que el motor de partido identifica de forma explícita.
# Los datos agregados de equipo no se reparten artificialmente entre futbolistas.
static func record_match(players_by_id: Dictionary, result: Dictionary) -> Dictionary:
	var lineups = result.get("lineups", {})
	if not lineups is Dictionary:
		return {"ok": false, "error": "El resultado no contiene alineaciones verificables."}
	var updated := players_by_id.duplicate(true)
	var home_id := str(result.get("home_team_id", ""))
	var away_id := str(result.get("away_team_id", ""))
	if home_id.is_empty() or away_id.is_empty() or home_id == away_id:
		return {"ok": false, "error": "Identificadores de equipos no válidos."}
	var home_goals := int(result.get("home_goals", 0))
	var away_goals := int(result.get("away_goals", 0))
	var goals_by_player := {}
	for event in result.get("events", []):
		if str(event.get("type", "")) != "goal":
			continue
		var scorer_id := str(event.get("player_id", ""))
		if not scorer_id.is_empty():
			goals_by_player[scorer_id] = int(goals_by_player.get(scorer_id, 0)) + 1
	var updated_ids := {}
	for side in ["home", "away"]:
		var team_id := home_id if side == "home" else away_id
		var player_ids = lineups.get(side, [])
		if not player_ids is Array or player_ids.size() != 11:
			return {"ok": false, "error": "La alineación de " + team_id + " no contiene once titulares."}
		for raw_player_id in player_ids:
			var player_id := str(raw_player_id)
			if player_id.is_empty() or not updated.has(player_id) or updated_ids.has(player_id):
				return {"ok": false, "error": "Futbolista ausente o duplicado en la alineación: " + player_id}
			updated_ids[player_id] = true
			var player: Dictionary = normalize_player(updated[player_id])
			var statistics: Dictionary = player.statistics
			var career: Dictionary = statistics.career
			var season: Dictionary = statistics.current_season
			var won: bool = (side == "home" and home_goals > away_goals) or (side == "away" and away_goals > home_goals)
			var drawn := home_goals == away_goals
			for totals in [career, season]:
				totals["appearances"] = int(totals.get("appearances", 0)) + 1
				totals["starts"] = int(totals.get("starts", 0)) + 1
				totals["minutes"] = int(totals.get("minutes", 0)) + int(result.get("minute", 90))
				if won:
					totals["wins"] = int(totals.get("wins", 0)) + 1
				elif drawn:
					totals["draws"] = int(totals.get("draws", 0)) + 1
				else:
					totals["losses"] = int(totals.get("losses", 0)) + 1
				var goals := int(goals_by_player.get(player_id, 0))
				totals["goals"] = int(totals.get("goals", 0)) + goals
				if side == "home" and away_goals == 0 or side == "away" and home_goals == 0:
					var position := str(player.get("primary_position", player.get("position", ""))).to_upper()
					if position in ["POR", "GK", "G"]:
						totals["clean_sheets"] = int(totals.get("clean_sheets", 0)) + 1
			statistics["career"] = normalize_totals(career)
			statistics["current_season"] = normalize_totals(season)
			statistics["data_status"] = "registrado"
			player["statistics"] = statistics
			updated[player_id] = player
	return {"ok": true, "players": updated, "updated_count": updated_ids.size()}
