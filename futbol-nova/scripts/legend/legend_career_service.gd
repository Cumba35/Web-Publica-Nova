extends Node
class_name NovaLegendCareerService

signal career_started(state: Dictionary)
signal career_updated(state: Dictionary)
signal player_retired(state: Dictionary)

const SAVE_PATH := "user://legend_career.json"
const SCHEMA_VERSION := "1.0.0"
const MIN_AGE := 14
const MAX_AGE := 45
const POSITIONS := ["POR", "DFC", "LI", "LD", "CAI", "CAD", "MCD", "MC", "INTERIOR_IZQUIERDO", "INTERIOR_DERECHO", "MCO", "MI", "MD", "EI", "ED", "SD", "DC"]
const FEET := ["left", "right", "both"]
const SPECIALIZATIONS := ["velocista", "regateador", "organizador", "pasador", "rematador", "larga_distancia", "defensor", "recuperador", "fisico", "creador", "portero"]
const POSITION_GROUPS := {
	"goalkeeper": ["POR"],
	"defender": ["DFC", "LI", "LD", "CAI", "CAD"],
	"midfielder": ["MCD", "MC", "INTERIOR_IZQUIERDO", "INTERIOR_DERECHO", "MCO", "MI", "MD"],
	"forward": ["EI", "ED", "SD", "DC"]
}
const ATTRIBUTE_KEYS := ["acc", "spd", "attp", "fin", "shot", "long", "vol", "pen", "vis", "cross", "fk", "short", "longp", "curve", "agi", "bal", "react", "ctrl", "drib", "comp", "int", "head", "aware", "tack", "slide", "jump", "sta", "str", "agr", "dive", "hand", "kick", "ref", "gkspd", "gkpos"]
const ATTRIBUTE_GROUPS := {
	"Ritmo": ["acc", "spd"],
	"Tiro": ["attp", "fin", "shot", "long", "vol", "pen"],
	"Pase": ["vis", "cross", "fk", "short", "longp", "curve"],
	"Regate": ["agi", "bal", "react", "ctrl", "drib", "comp"],
	"Defensa": ["int", "head", "aware", "tack", "slide"],
	"Físico": ["jump", "sta", "str", "agr"],
	"Portería": ["dive", "hand", "kick", "ref", "gkspd", "gkpos"]
}
const SPECIALIZATION_BONUSES := {
	"velocista": {"acc": 8, "spd": 8, "agi": 4},
	"regateador": {"agi": 7, "ctrl": 7, "drib": 8, "bal": 4},
	"organizador": {"vis": 8, "short": 7, "longp": 7, "comp": 4},
	"pasador": {"short": 8, "longp": 8, "vis": 5, "cross": 4},
	"rematador": {"fin": 8, "shot": 7, "attp": 6, "head": 3},
	"larga_distancia": {"long": 8, "shot": 5, "curve": 5, "fk": 5},
	"defensor": {"tack": 8, "slide": 7, "aware": 6, "head": 4},
	"recuperador": {"int": 8, "tack": 6, "sta": 6, "agr": 4},
	"fisico": {"str": 8, "sta": 7, "jump": 6, "agr": 4},
	"creador": {"vis": 7, "ctrl": 6, "drib": 5, "curve": 4},
	"portero": {"dive": 8, "hand": 8, "ref": 7, "gkpos": 6, "gkspd": 5}
}

var career: Dictionary = {}

func start_career(player_data: Dictionary) -> Dictionary:
	return _start_career_internal(player_data, false)

func start_career_from_catalog(source_player: Dictionary) -> Dictionary:
	var errors := validate_catalog_player(source_player)
	if not errors.is_empty():
		return {"ok": false, "errors": errors}
	var birth_date := str(source_player.get("birth_date", ""))
	var age := int(source_player.get("age", _age_from_birth_date(birth_date)))
	var normalized := {
		"full_name": str(source_player.get("display_name", source_player.get("name", ""))),
		"display_name": str(source_player.get("display_name", source_player.get("name", ""))),
		"shirt_name": str(source_player.get("shirt_name", source_player.get("display_name", source_player.get("name", "")))),
		"nationality_id": str(source_player.get("nationality_id", source_player.get("nationality", ""))),
		"birth_date": birth_date,
		"age": age,
		"primary_position": str(source_player.get("primary_position", source_player.get("position", ""))),
		"secondary_positions": source_player.get("secondary_positions", []).duplicate(true),
		"preferred_foot": str(source_player.get("preferred_foot", "right")),
		"height_cm": int(source_player.get("height_cm", 175)),
		"weight_kg": int(source_player.get("weight_kg", 70)),
		"specialization": "catalogo_nova",
		"favorite_club": str(source_player.get("club_name", "")),
		"club_id": str(source_player.get("club_id", "")),
		"club_name": str(source_player.get("club_name", "")),
		"source_player_id": str(source_player.get("id", "")),
		"origin": "nova_catalog",
		"attributes": source_player.get("attributes", {}).duplicate(true),
		"estimated_overall": int(source_player.get("estimated_overall", source_player.get("overall", 0))),
		"potential": int(source_player.get("potential", source_player.get("estimated_overall", 50))),
		"catalog_season": str(source_player.get("season", ""))
	}
	return _start_career_internal(normalized, true)

func validate_catalog_player(player: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	if str(player.get("id", "")).strip_edges().is_empty():
		errors.append("El futbolista del catálogo no tiene un ID.")
	var name := str(player.get("display_name", player.get("name", ""))).strip_edges()
	if name.length() < 2:
		errors.append("El futbolista del catálogo no tiene un nombre válido.")
	var position := str(player.get("primary_position", player.get("position", "")))
	if not POSITIONS.has(position):
		errors.append("El futbolista tiene una posición no reconocida.")
	var birth_date := str(player.get("birth_date", ""))
	var age := int(player.get("age", _age_from_birth_date(birth_date)))
	if age < MIN_AGE or age > MAX_AGE:
		errors.append("El futbolista no está dentro del rango de edad jugable (14–45).")
	var attributes = player.get("attributes", {})
	if not attributes is Dictionary:
		errors.append("El futbolista no contiene sus atributos oficiales.")
	else:
		for key in ATTRIBUTE_KEYS:
			if not attributes.has(key):
				errors.append("Falta el atributo oficial: " + key)
			elif int(attributes[key]) < 1 or int(attributes[key]) > 99:
				errors.append("Atributo fuera de rango: " + key)
	if str(player.get("nationality_id", player.get("nationality", ""))).strip_edges().is_empty():
		errors.append("El futbolista no tiene nacionalidad.")
	if int(player.get("height_cm", 0)) < 130 or int(player.get("height_cm", 0)) > 220:
		errors.append("Altura del catálogo fuera de rango.")
	if int(player.get("weight_kg", 0)) < 35 or int(player.get("weight_kg", 0)) > 150:
		errors.append("Peso del catálogo fuera de rango.")
	return errors

func _start_career_internal(player_data: Dictionary, from_catalog: bool) -> Dictionary:
	if not career.is_empty() and not bool(career.get("retired", false)):
		return {"ok": false, "error": "Finaliza o retira la carrera actual antes de crear otra."}
	if not from_catalog:
		var errors := validate_creation_data(player_data)
		if not errors.is_empty():
			return {"ok": false, "errors": errors}
	var age := int(player_data.get("age", _age_from_birth_date(str(player_data.get("birth_date", "")))))
	var birth_date := str(player_data.get("birth_date", ""))
	if birth_date.is_empty() and not from_catalog:
		birth_date = _birth_date_for_age(age)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var position := str(player_data.get("primary_position", "MC"))
	var attributes: Dictionary = player_data.get("attributes", {}).duplicate(true) if from_catalog else _generate_attributes(position, str(player_data.get("specialization", "velocista")), age, rng)
	var overall := int(player_data.get("estimated_overall", 0)) if from_catalog else _calculate_overall(attributes, position)
	if overall <= 0:
		overall = _calculate_overall(attributes, position)
	var potential := int(player_data.get("potential", overall)) if from_catalog else mini(99, overall + rng.randi_range(5, 18) - maxi(0, age - 28))
	var player := {
		"id": "NOVA-LEGEND-" + str(Time.get_ticks_usec()),
		"source_player_id": str(player_data.get("source_player_id", "")),
		"origin": str(player_data.get("origin", "user_created")),
		"full_name": str(player_data.get("full_name", "")).strip_edges(),
		"display_name": str(player_data.get("display_name", player_data.get("full_name", ""))).strip_edges(),
		"shirt_name": str(player_data.get("shirt_name", player_data.get("full_name", ""))).strip_edges(),
		"nationality_id": str(player_data.get("nationality_id", "CUB")).strip_edges().to_upper(),
		"birth_date": birth_date,
		"age": age,
		"primary_position": position,
		"secondary_positions": player_data.get("secondary_positions", [str(player_data.get("secondary_position", ""))] if not str(player_data.get("secondary_position", "")).is_empty() else []).duplicate(true),
		"preferred_foot": str(player_data.get("preferred_foot", "right")),
		"height_cm": int(player_data.get("height_cm", 175)),
		"weight_kg": int(player_data.get("weight_kg", 70)),
		"specialization": str(player_data.get("specialization", "catalogo_nova" if from_catalog else "velocista")),
		"favorite_club": str(player_data.get("favorite_club", "")),
		"overall": overall,
		"potential": potential,
		"attributes": attributes,
		"attribute_groups": _group_attributes(attributes),
		"condition": 100,
		"form": 50,
		"morale": 60
	}
	var initial_club_id := str(player_data.get("club_id", "")) if from_catalog else ""
	var initial_status := "catalog_player" if from_catalog else ("academy" if age == 14 else "trial")
	career = {
		"schema_version": SCHEMA_VERSION,
		"mode": "legend",
		"player": player,
		"status": initial_status,
		"club_id": initial_club_id,
		"last_club_id": initial_club_id,
		"club_name": str(player_data.get("club_name", "")) if from_catalog else "",
		"catalog_season": str(player_data.get("catalog_season", "")),
		"contract": {"active": false, "club_id": "", "start_season": 0, "end_season": 0, "weekly_salary": 0},
		"season": 1,
		"season_complete": false,
		"seasons_played": 0,
		"season_history": [],
		"career_stats": _empty_statistics(),
		"season_stats": _empty_statistics(),
		"processed_match_ids": [],
		"history": [{"event": "career_created_from_nova_catalog" if from_catalog else "career_created", "age": age, "status": initial_status, "source_player_id": str(player_data.get("source_player_id", ""))}],
		"retired": false,
		"manager_unlocked": false
	}
	var saved := save_career()
	if saved:
		career_started.emit(get_career_state())
	return {"ok": saved, "career": get_career_state(), "error": "" if saved else "No se pudo guardar la carrera."}

func validate_creation_data(data: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var name := str(data.get("full_name", "")).strip_edges()
	if name.length() < 2:
		errors.append("Escribe el nombre del futbolista.")
	var age := int(data.get("age", _age_from_birth_date(str(data.get("birth_date", "")))))
	if age < MIN_AGE or age > MAX_AGE:
		errors.append("La edad inicial debe estar entre 14 y 45 años.")
	var position := str(data.get("primary_position", ""))
	if not POSITIONS.has(position):
		errors.append("Selecciona una posición principal válida.")
	var secondary := str(data.get("secondary_position", ""))
	if not secondary.is_empty() and (not POSITIONS.has(secondary) or _position_group(position) != _position_group(secondary)):
		errors.append("La segunda posición debe pertenecer a la misma zona funcional.")
	if not FEET.has(str(data.get("preferred_foot", "right"))):
		errors.append("Selecciona pie izquierdo, derecho o ambos.")
	var height := int(data.get("height_cm", 175))
	var weight := int(data.get("weight_kg", 70))
	if height < 130 or height > 220:
		errors.append("La altura debe estar entre 130 y 220 cm.")
	if weight < 35 or weight > 150:
		errors.append("El peso debe estar entre 35 y 150 kg.")
	if not SPECIALIZATIONS.has(str(data.get("specialization", ""))):
		errors.append("Selecciona una especialización.")
	if str(data.get("nationality_id", "CUB")).strip_edges().is_empty():
		errors.append("Indica la nacionalidad.")
	var birth_date := str(data.get("birth_date", ""))
	if not birth_date.is_empty() and _age_from_birth_date(birth_date) < 0:
		errors.append("La fecha de nacimiento no es válida.")
	return errors

func _position_group(position: String) -> String:
	for group_name in POSITION_GROUPS:
		if POSITION_GROUPS[group_name].has(position):
			return str(group_name)
	return ""

func _birth_date_for_age(age: int) -> String:
	var today := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(today.year) - age, int(today.month), int(today.day)]

func _age_from_birth_date(value: String) -> int:
	if value.is_empty():
		return -1
	var parts := value.split("-")
	if parts.size() != 3:
		return -1
	var year := int(parts[0])
	var month := int(parts[1])
	var day := int(parts[2])
	if year < 1900 or month < 1 or month > 12 or day < 1 or day > 31:
		return -1
	var today := Time.get_date_dict_from_system()
	var age := int(today.year) - year
	if int(today.month) < month or (int(today.month) == month and int(today.day) < day):
		age -= 1
	return age

func _generate_attributes(position: String, specialization: String, age: int, rng: RandomNumberGenerator) -> Dictionary:
	var base := clampi(48 + mini(8, int(maxi(0, age - 14) / 4)), 42, 60)
	var result := {}
	var bonuses: Dictionary = SPECIALIZATION_BONUSES.get(specialization, {})
	for key in ATTRIBUTE_KEYS:
		var value := base + rng.randi_range(-8, 8) + int(bonuses.get(key, 0))
		if position == "POR" and key in ["dive", "hand", "kick", "ref", "gkspd", "gkpos"]:
			value += 9
		elif position != "POR" and key in ["dive", "hand", "kick", "ref", "gkspd", "gkpos"]:
			value -= 12
		if age <= 17 and key in ["sta", "str", "agr"]:
			value -= 3
		result[key] = clampi(value, 1, 99)
	return result

func calculate_overall(attributes: Dictionary, position: String) -> int:
	return _calculate_overall(attributes, position)

func _calculate_overall(attributes: Dictionary, position: String) -> int:
	if position == "POR":
		var goalkeeper_keys := ["dive", "hand", "kick", "ref", "gkspd", "gkpos"]
		var goalkeeper_total := 0.0
		for key in goalkeeper_keys:
			goalkeeper_total += float(attributes.get(key, 1))
		return clampi(roundi(goalkeeper_total / float(goalkeeper_keys.size())), 1, 99)

	var weights: Dictionary = {}
	if position == "MCO":
		weights = {"acc":4,"spd":4,"attp":3,"fin":4,"shot":3,"long":2,"vol":1,"pen":1,"vis":10,"cross":1,"fk":1,"short":10,"longp":9,"curve":2,"agi":4,"bal":3,"react":5,"ctrl":8,"drib":5,"comp":6,"int":4,"head":1,"aware":3,"tack":3,"slide":1,"jump":1,"sta":4,"str":2,"agr":2}
	elif position == "MC":
		weights = {"acc":4,"spd":4,"attp":2,"fin":2,"shot":2,"long":2,"vol":1,"pen":1,"vis":8,"cross":2,"fk":1,"short":11,"longp":10,"curve":2,"agi":4,"bal":3,"react":6,"ctrl":7,"drib":4,"comp":6,"int":6,"head":1,"aware":5,"tack":4,"slide":2,"jump":1,"sta":5,"str":3,"agr":3}
	else:
		var outfield_keys := ATTRIBUTE_KEYS.slice(0, 29)
		var simple_total := 0.0
		for key in outfield_keys:
			simple_total += float(attributes.get(key, 50))
		return clampi(roundi(simple_total / float(outfield_keys.size())), 1, 99)

	var weighted_total := 0.0
	var total_weight := 0.0
	for key in weights:
		var weight := float(weights[key])
		weighted_total += float(attributes.get(key, 50)) * weight
		total_weight += weight
	if total_weight <= 0.0:
		return 1
	return clampi(roundi(weighted_total / total_weight), 1, 99)

func _group_attributes(attributes: Dictionary) -> Dictionary:
	var grouped := {}
	for group_name in ATTRIBUTE_GROUPS:
		var values := {}
		for key in ATTRIBUTE_GROUPS[group_name]:
			values[key] = int(attributes.get(key, 1))
		grouped[group_name] = values
	return grouped

func _empty_statistics() -> Dictionary:
	return {
		"appearances": 0, "starts": 0, "substitute_appearances": 0, "minutes": 0,
		"wins": 0, "draws": 0, "losses": 0,
		"goals": 0, "assists": 0, "shots": 0, "shots_on_target": 0,
		"passes": 0, "passes_completed": 0, "key_passes": 0, "chances_created": 0,
		"dribbles": 0, "dribbles_completed": 0, "tackles": 0, "interceptions": 0,
		"recoveries": 0, "fouls": 0, "fouls_won": 0, "yellow_cards": 0, "red_cards": 0,
		"saves": 0, "clean_sheets": 0, "penalties_scored": 0, "penalties_missed": 0,
		"player_of_match": 0, "average_rating": 0.0, "pass_accuracy": 0.0,
		"dribble_success_rate": 0.0, "goals_per_appearance": 0.0, "assists_per_appearance": 0.0,
		"rated_appearances": 0, "rating_total": 0.0
	}

func record_match(match_data: Dictionary) -> Dictionary:
	if career.is_empty() or bool(career.get("retired", false)):
		return {"ok": false, "error": "No hay una carrera activa."}
	if bool(career.get("season_complete", false)):
		return {"ok": false, "error": "La temporada ya terminó."}
	var match_id := str(match_data.get("match_id", "")).strip_edges()
	if match_id.is_empty():
		return {"ok": false, "error": "El partido necesita un identificador único."}
	var processed: Array = career.get("processed_match_ids", [])
	if processed.has(match_id):
		return {"ok": false, "error": "El partido ya fue registrado."}
	var stats: Dictionary = career.get("career_stats", _empty_statistics())
	var season_stats: Dictionary = career.get("season_stats", _empty_statistics())
	var numeric_keys := [
		"appearances", "starts", "minutes", "goals", "assists", "shots", "shots_on_target",
		"passes", "passes_completed", "key_passes", "chances_created", "dribbles",
		"dribbles_completed", "tackles", "interceptions", "recoveries", "fouls",
		"fouls_won", "yellow_cards", "red_cards", "saves", "clean_sheets",
		"penalties_scored", "penalties_missed", "player_of_match"
	]
	for key in numeric_keys:
		var amount := maxi(0, int(match_data.get(key, 0)))
		stats[key] = int(stats.get(key, 0)) + amount
		season_stats[key] = int(season_stats.get(key, 0)) + amount
	if int(match_data.get("appearances", 0)) > 0 and int(match_data.get("starts", 0)) <= 0:
		stats["substitute_appearances"] = int(stats.get("substitute_appearances", 0)) + 1
		season_stats["substitute_appearances"] = int(season_stats.get("substitute_appearances", 0)) + 1
	if int(match_data.get("appearances", 0)) > 0 and match_data.has("team_goals") and match_data.has("opponent_goals"):
		var goals_for := int(match_data.get("team_goals", 0))
		var goals_against := int(match_data.get("opponent_goals", 0))
		var outcome := "wins" if goals_for > goals_against else ("draws" if goals_for == goals_against else "losses")
		stats[outcome] = int(stats.get(outcome, 0)) + 1
		season_stats[outcome] = int(season_stats.get(outcome, 0)) + 1
	var appearances := maxf(1.0, float(stats.get("appearances", 0)))
	var season_appearances := maxf(1.0, float(season_stats.get("appearances", 0)))
	stats["goals_per_appearance"] = float(stats.get("goals", 0)) / appearances
	stats["assists_per_appearance"] = float(stats.get("assists", 0)) / appearances
	season_stats["goals_per_appearance"] = float(season_stats.get("goals", 0)) / season_appearances
	season_stats["assists_per_appearance"] = float(season_stats.get("assists", 0)) / season_appearances
	stats["pass_accuracy"] = 100.0 * float(stats.get("passes_completed", 0)) / maxf(1.0, float(stats.get("passes", 0)))
	season_stats["pass_accuracy"] = 100.0 * float(season_stats.get("passes_completed", 0)) / maxf(1.0, float(season_stats.get("passes", 0)))
	stats["dribble_success_rate"] = 100.0 * float(stats.get("dribbles_completed", 0)) / maxf(1.0, float(stats.get("dribbles", 0)))
	season_stats["dribble_success_rate"] = 100.0 * float(season_stats.get("dribbles_completed", 0)) / maxf(1.0, float(season_stats.get("dribbles", 0)))
	var rating := clampf(float(match_data.get("rating", 0.0)), 0.0, 10.0)
	if int(match_data.get("appearances", 0)) > 0 and rating > 0.0:
		var old_apps := int(stats.get("rated_appearances", 0))
		var old_total := float(stats.get("rating_total", 0.0))
		stats["rated_appearances"] = old_apps + 1
		stats["rating_total"] = old_total + rating
		stats["average_rating"] = (old_total + rating) / float(old_apps + 1)
		var season_apps := int(season_stats.get("rated_appearances", 0))
		var season_total := float(season_stats.get("rating_total", 0.0))
		season_stats["rated_appearances"] = season_apps + 1
		season_stats["rating_total"] = season_total + rating
		season_stats["average_rating"] = (season_total + rating) / float(season_apps + 1)
	processed.append(match_id)
	career["processed_match_ids"] = processed
	career["career_stats"] = stats
	career["season_stats"] = season_stats
	career["player"]["form"] = clampi(int(career.player.get("form", 50)) + (2 if rating >= 7.0 else (-2 if rating > 0.0 and rating < 5.5 else 0)), 0, 100)
	career["player"]["condition"] = clampi(int(career.player.get("condition", 100)) - maxi(0, int(match_data.get("minutes", 0)) / 12), 0, 100)
	var saved := save_career()
	if saved:
		career_updated.emit(get_career_state())
	return {"ok": saved, "statistics": stats.duplicate(true), "season_statistics": season_stats.duplicate(true), "error": "" if saved else "No se pudo guardar el partido."}


func record_match_from_contract(match_result: Dictionary, player_match_stats: Dictionary, player_team_id: String) -> Dictionary:
	if career.is_empty() or bool(career.get("retired", false)):
		return {"ok": false, "error": "No hay una carrera activa."}
	if str(match_result.get("status", "")) != "finished":
		return {"ok": false, "error": "Solo se pueden registrar partidos finalizados."}
	var match_id := str(match_result.get("match_id", "")).strip_edges()
	if match_id.is_empty():
		return {"ok": false, "error": "El resultado del partido no contiene un identificador."}
	var active_player_id := str(career.get("player", {}).get("id", ""))
	var source_player_id := str(career.get("player", {}).get("source_player_id", ""))
	var event_player_id := str(player_match_stats.get("player_id", "")).strip_edges()
	if event_player_id.is_empty() or (event_player_id != active_player_id and event_player_id != source_player_id):
		return {"ok": false, "error": "Las estadísticas no pertenecen al futbolista de esta carrera."}
	var home_team_id := str(match_result.get("home_team_id", "")).strip_edges()
	var away_team_id := str(match_result.get("away_team_id", "")).strip_edges()
	if player_team_id.is_empty() or (player_team_id != home_team_id and player_team_id != away_team_id):
		return {"ok": false, "error": "El equipo del futbolista no coincide con los participantes del partido."}
	var current_club_id := str(career.get("club_id", "")).strip_edges()
	if not current_club_id.is_empty() and current_club_id != player_team_id:
		return {"ok": false, "error": "El futbolista no pertenece al club indicado para este partido."}
	var home_goals_value = match_result.get("home_goals", null)
	var away_goals_value = match_result.get("away_goals", null)
	if not (home_goals_value is int or home_goals_value is float) or not (away_goals_value is int or away_goals_value is float):
		return {"ok": false, "error": "El marcador del partido no es válido."}
	var home_goals := int(home_goals_value)
	var away_goals := int(away_goals_value)
	if home_goals < 0 or away_goals < 0:
		return {"ok": false, "error": "El marcador no puede ser negativo."}
	var match_data := player_match_stats.duplicate(true)
	match_data["match_id"] = match_id
	match_data["team_goals"] = home_goals if player_team_id == home_team_id else away_goals
	match_data["opponent_goals"] = away_goals if player_team_id == home_team_id else home_goals
	return record_match(match_data)

func accept_contract(offer: Dictionary) -> Dictionary:
	if career.is_empty() or bool(career.get("retired", false)):
		return {"ok": false, "error": "No existe una carrera activa."}
	var age := int(career.player.get("age", 0))
	if age < 15:
		return {"ok": false, "error": "No puede firmar un contrato profesional antes de cumplir 15 años."}
	if bool(career.contract.get("active", false)):
		return {"ok": false, "error": "Ya existe un contrato vigente."}
	var club_id := str(offer.get("club_id", "")).strip_edges()
	var seasons := int(offer.get("seasons", 0))
	if club_id.is_empty() or seasons < 1 or seasons > mini(5, MAX_AGE - age + 1):
		return {"ok": false, "error": "La oferta debe ser válida y no puede superar la edad máxima jugable."}
	var salary := maxi(0, int(offer.get("weekly_salary", 0)))
	career["club_id"] = club_id
	career["last_club_id"] = club_id
	career["status"] = "professional"
	career["contract"] = {"active": true, "club_id": club_id, "start_season": int(career.season), "end_season": int(career.season) + seasons - 1, "weekly_salary": salary}
	career.history.append({"event": "contract_signed", "club_id": club_id, "season": career.season, "weekly_salary": salary})
	var saved := save_career()
	if saved:
		career_updated.emit(get_career_state())
	return {"ok": saved, "error": "" if saved else "No se pudo guardar el contrato."}

func complete_season() -> Dictionary:
	if career.is_empty() or bool(career.get("retired", false)):
		return {"ok": false, "error": "No hay una carrera activa."}
	if bool(career.get("season_complete", false)):
		return {"ok": false, "error": "La temporada ya está cerrada."}
	career["season_complete"] = true
	career["seasons_played"] = int(career.get("seasons_played", 0)) + 1
	var season_history: Array = career.get("season_history", [])
	season_history.append({"season": int(career.get("season", 1)), "statistics": career.get("season_stats", _empty_statistics()).duplicate(true)})
	career["season_history"] = season_history
	var contract: Dictionary = career.get("contract", {})
	if bool(contract.get("active", false)) and int(contract.get("end_season", 0)) <= int(career.season):
		contract["active"] = false
		career["contract"] = contract
		career["status"] = "free_agent"
	career.history.append({"event": "season_completed", "season": career.season})
	var saved := save_career()
	if saved:
		career_updated.emit(get_career_state())
	return {"ok": saved, "season_complete": true, "contract_active": bool(career.contract.get("active", false))}

func advance_season() -> Dictionary:
	if career.is_empty() or not bool(career.get("season_complete", false)) or bool(career.get("retired", false)):
		return {"ok": false, "error": "Primero debe finalizar la temporada actual."}
	var age := int(career.player.get("age", 0))
	if age >= MAX_AGE:
		return {"ok": false, "error": "El jugador alcanzó la edad máxima jugable de 45 años; debe retirarse."}
	var contract_active := bool(career.get("contract", {}).get("active", false))
	var academy_promotion := age == 14 and str(career.get("status", "")) == "academy" and not contract_active
	var catalog_continuation := str(career.get("status", "")) == "catalog_player" and not contract_active
	if not contract_active and not academy_promotion and not catalog_continuation:
		return {"ok": false, "error": "Necesitas aceptar una oferta de contrato para continuar la carrera profesional."}
	career["season"] = int(career.season) + 1
	career["season_complete"] = false
	career["season_stats"] = _empty_statistics()
	career.player["age"] = age + 1
	if academy_promotion:
		career["status"] = "trial"
	career.history.append({"event": "season_started", "season": career.season, "age": age + 1})
	var saved := save_career()
	if saved:
		career_updated.emit(get_career_state())
	return {"ok": saved, "season": int(career.season), "age": int(career.player.age)}

func retire_player() -> Dictionary:
	if career.is_empty() or bool(career.get("retired", false)):
		return {"ok": false, "error": "No hay una carrera activa."}
	if not bool(career.get("season_complete", false)):
		return {"ok": false, "error": "La retirada solo se permite al finalizar una temporada."}
	if bool(career.get("contract", {}).get("active", false)):
		return {"ok": false, "error": "No puedes retirarte mientras tengas un contrato vigente."}
	var age := int(career.player.get("age", 0))
	career["retired"] = true
	career["status"] = "retired"
	career["manager_unlocked"] = age >= 20
	career["retirement"] = {"age": age, "season": int(career.season), "last_club_id": str(career.get("last_club_id", "")), "manager_unlocked": age >= 20}
	career.history.append({"event": "player_retired", "age": age, "season": career.season})
	var saved := save_career()
	if saved:
		player_retired.emit(get_career_state())
	return {"ok": saved, "manager_unlocked": age >= 20, "error": "" if saved else "No se pudo guardar la retirada."}

func start_manager_after_retirement(club_id: String = "") -> Dictionary:
	if career.is_empty() or not bool(career.get("retired", false)) or not bool(career.get("manager_unlocked", false)):
		return {"ok": false, "error": "La carrera de Manager se desbloquea al retirarse con 20 años o más."}
	var target_club := club_id if not club_id.is_empty() else str(career.get("last_club_id", ""))
	if target_club.is_empty():
		return {"ok": false, "error": "Selecciona un club para iniciar tu carrera de entrenador."}
	if ManagerCareer.load_career():
		return {"ok": false, "error": "Ya existe una carrera de Manager guardada. Se ha protegido para no sobrescribirla."}
	return ManagerCareer.start_coach_career(target_club)

func get_player_statistics() -> Dictionary:
	if career.is_empty():
		return {}
	return {
		"player": career.player.duplicate(true),
		"career": career.get("career_stats", _empty_statistics()).duplicate(true),
		"season": career.get("season_stats", _empty_statistics()).duplicate(true),
		"attribute_groups": career.player.get("attribute_groups", {}).duplicate(true)
	}

func get_career_state() -> Dictionary:
	return career.duplicate(true)

func save_career() -> bool:
	if career.is_empty():
		return false
	var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(career, "\t"))
	file.flush()
	if file.get_error() != OK:
		file.close()
		return false
	file.close()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".bak"))
		var backup_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH), ProjectSettings.globalize_path(SAVE_PATH + ".bak"))
		if backup_error != OK:
			return false
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"), ProjectSettings.globalize_path(SAVE_PATH))
	if rename_error != OK:
		var backup_path := ProjectSettings.globalize_path(SAVE_PATH + ".bak")
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, ProjectSettings.globalize_path(SAVE_PATH))
		return false
	if get_tree() != null and get_tree().root.has_node("FootballDatabase"):
		return FootballDatabase.save_career_record("legend_active", career)
	return true

func load_career() -> bool:
	var parsed: Variant = null
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary and get_tree() != null and get_tree().root.has_node("FootballDatabase"):
		var backup_record: Dictionary = FootballDatabase.get_career_record("legend_active")
		if not backup_record.is_empty():
			parsed = backup_record
	if not parsed is Dictionary:
		return false
	if not parsed is Dictionary or str(parsed.get("schema_version", "")) != SCHEMA_VERSION or str(parsed.get("mode", "")) != "legend":
		return false
	if not (parsed.get("player", {}) is Dictionary) or not (parsed.get("career_stats", {}) is Dictionary):
		return false
	career = parsed
	return true
