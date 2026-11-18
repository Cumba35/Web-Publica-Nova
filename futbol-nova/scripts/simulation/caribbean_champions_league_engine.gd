extends RefCounted
class_name NovaCaribbeanChampionsLeagueEngine

const COMPETITION_ID := "caribbean_champions_league_nova"
const GROUP_IDS := ["A", "B", "C", "D"]
const TOTAL_TEAMS := 48
const GROUP_SIZE := 12
const SCHEDULER = preload("res://scripts/simulation/round_robin_scheduler.gd")
const STANDINGS = preload("res://scripts/simulation/league_standings.gd")

static func validate_slot_distribution(slots: Dictionary) -> Dictionary:
	var total := 0
	var errors: Array[String] = []
	for association_id in slots:
		var count := int(slots[association_id])
		if count < 0:
			errors.append("La asociación %s tiene una cantidad negativa de plazas." % str(association_id))
		total += count
	if total != TOTAL_TEAMS:
		errors.append("La distribución asigna %d de 48 plazas; faltan %d." % [total, TOTAL_TEAMS - total])
	return {"ok": errors.is_empty(), "assigned_slots": total, "unallocated_slots": maxi(0, TOTAL_TEAMS - total), "errors": errors}

static func qualify_participants(slot_distribution: Dictionary, domestic_tables: Dictionary) -> Dictionary:
	var slot_check := validate_slot_distribution(slot_distribution)
	if not bool(slot_check.ok):
		return {"ok": false, "participants": [], "errors": slot_check.errors}
	var participants: Array = []
	var seen := {}
	var errors: Array[String] = []
	for association_id in slot_distribution:
		var slots := int(slot_distribution[association_id])
		if slots == 0:
			continue
		var rows: Array = domestic_tables.get(str(association_id), [])
		var eligible: Array = []
		for row in rows:
			if not row is Dictionary:
				continue
			if int(row.get("division_level", 0)) == 1 and int(row.get("position", 0)) > 0:
				eligible.append(row)
		eligible.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("position", 9999)) < int(b.get("position", 9999)))
		if eligible.size() < slots:
			errors.append("La asociación %s necesita %d clubes elegibles de Primera y solo aporta %d." % [str(association_id), slots, eligible.size()])
			continue
		var unresolved_position_tie := false
		for index in range(mini(slots, eligible.size() - 1)):
			if int(eligible[index].get("position", 0)) == int(eligible[index + 1].get("position", 0)):
				unresolved_position_tie = true
		if unresolved_position_tie:
			errors.append("La asociación %s tiene un empate sin resolver en sus plazas de clasificación." % str(association_id))
			continue
		for index in range(slots):
			var row: Dictionary = eligible[index]
			var team_id := str(row.get("team_id", row.get("id", "")))
			if team_id.is_empty() or seen.has(team_id):
				errors.append("Club vacío o repetido en la clasificación: " + team_id)
				continue
			seen[team_id] = true
			participants.append({"team_id": team_id, "association_id": str(association_id), "domestic_position": int(row.get("position", index + 1)), "division_level": 1})
	if participants.size() != TOTAL_TEAMS:
		errors.append("La clasificación produjo %d participantes válidos; se necesitan 48." % participants.size())
	return {"ok": errors.is_empty(), "participants": participants, "errors": errors}

static func create_edition(season_id: String, participants: Array, neutral_final_venue: String, seed: int = 1) -> Dictionary:
	if season_id.strip_edges().is_empty():
		return {"ok": false, "errors": ["La edición necesita un identificador de temporada."]}
	if neutral_final_venue.strip_edges().is_empty():
		return {"ok": false, "errors": ["Debe confirmarse la sede neutral de la final antes de iniciar el torneo."]}
	if participants.size() != TOTAL_TEAMS:
		return {"ok": false, "errors": ["La edición necesita exactamente 48 clubes."]}
	var normalized: Array = []
	var seen := {}
	for participant in participants:
		if not participant is Dictionary:
			return {"ok": false, "errors": ["Participante con formato inválido."]}
		var team_id := str(participant.get("team_id", participant.get("id", "")))
		var association_id := str(participant.get("association_id", ""))
		if team_id.is_empty() or association_id.is_empty() or int(participant.get("division_level", 0)) != 1:
			return {"ok": false, "errors": ["Cada participante debe tener ID, asociación y pertenecer a Primera División."]}
		if seen.has(team_id):
			return {"ok": false, "errors": ["Club duplicado: " + team_id]}
		seen[team_id] = true
		normalized.append({"team_id": team_id, "association_id": association_id, "division_level": 1})
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var grouped_draw := _draw_groups_by_association(normalized, rng)
	if not bool(grouped_draw.get("ok", false)):
		return {"ok": false, "errors": grouped_draw.get("errors", ["No se pudo realizar el sorteo por asociación."])}
	var groups: Dictionary = grouped_draw.groups
	var draw_presentation: Array = []
	for group_id in GROUP_IDS:
		for team_id in groups[group_id]:
			var association_id := ""
			for participant in normalized:
				if str(participant.get("team_id", "")) == str(team_id):
					association_id = str(participant.get("association_id", ""))
					break
			draw_presentation.append({"team_id": str(team_id), "group": str(group_id), "association": association_id})
	var fixtures_by_group := {}
	var standings_by_group := {}
	for group_id in GROUP_IDS:
		var stage_id := COMPETITION_ID + "_" + str(group_id)
		var fixtures: Array = SCHEDULER.create_fixtures(groups[group_id], stage_id, season_id, false)
		if fixtures.size() != 66:
			return {"ok": false, "errors": ["No se pudo generar el calendario completo del grupo " + str(group_id) + "."]}
		fixtures_by_group[group_id] = fixtures
		standings_by_group[group_id] = STANDINGS.create_table(groups[group_id])
	return {
		"ok": true,
		"competition_id": COMPETITION_ID,
		"season_id": season_id,
		"status": "group_stage",
		"neutral_final_venue": neutral_final_venue.strip_edges(),
		"venue_confirmed_before_start": true,
		"participants": normalized,
		"groups": groups,
		"draw_presentation": draw_presentation,
		"fixtures_by_group": fixtures_by_group,
		"standings_by_group": standings_by_group,
		"playoff_fixtures": [],
		"round_of_16_pairings": [],
		"knockout_fixtures": {},
		"seed": seed,
		"errors": []
	}


static func _draw_groups_by_association(participants: Array, rng: RandomNumberGenerator) -> Dictionary:
	var groups := {"A": [], "B": [], "C": [], "D": []}
	var teams_by_association := {}
	for participant in participants:
		var association_id := str(participant.get("association_id", ""))
		if not teams_by_association.has(association_id):
			teams_by_association[association_id] = []
		teams_by_association[association_id].append(str(participant.get("team_id", "")))
	for association_id in teams_by_association:
		if teams_by_association[association_id].size() > GROUP_IDS.size():
			return {"ok": false, "errors": ["La asociación %s aporta más clubes que grupos; no es posible separarlos todos." % str(association_id)]}
		var association_teams: Array = teams_by_association[association_id]
		for team_index in range(association_teams.size() - 1, 0, -1):
			var team_swap := rng.randi_range(0, team_index)
			var team_temp = association_teams[team_index]
			association_teams[team_index] = association_teams[team_swap]
			association_teams[team_swap] = team_temp
		teams_by_association[association_id] = association_teams
	var association_ids: Array = teams_by_association.keys()
	association_ids.sort_custom(func(a, b):
		return teams_by_association[a].size() > teams_by_association[b].size()
	)
	var start := 0
	while start < association_ids.size():
		var finish := start + 1
		while finish < association_ids.size() and teams_by_association[association_ids[finish]].size() == teams_by_association[association_ids[start]].size():
			finish += 1
		for index in range(finish - 1, start, -1):
			var swap_index := rng.randi_range(start, index)
			var temp = association_ids[index]
			association_ids[index] = association_ids[swap_index]
			association_ids[swap_index] = temp
		start = finish
	for association_id in association_ids:
		var available_groups: Array = GROUP_IDS.duplicate()
		available_groups.sort_custom(func(a, b):
			return groups[a].size() < groups[b].size()
		)
		var team_ids: Array = teams_by_association[association_id]
		for index in range(team_ids.size()):
			var minimum_load: int = groups[available_groups[0]].size()
			var tied_groups: Array = []
			for group_id in available_groups:
				if groups[group_id].size() == minimum_load:
					tied_groups.append(group_id)
			if tied_groups.is_empty():
				return {"ok": false, "errors": ["No hay grupos disponibles para la asociación " + str(association_id)]}
			var selected_group: String = tied_groups[rng.randi_range(0, tied_groups.size() - 1)]
			groups[selected_group].append(str(team_ids[index]))
			available_groups.erase(selected_group)
	for group_id in GROUP_IDS:
		if groups[group_id].size() != GROUP_SIZE:
			return {"ok": false, "errors": ["El sorteo dejó el grupo %s con %d clubes en vez de 12." % [str(group_id), groups[group_id].size()]]}
	return {"ok": true, "groups": groups}

static func record_group_result(state: Dictionary, group_id: String, result: Dictionary, database: Node) -> Dictionary:
	if not state.get("groups", {}).has(group_id):
		return {"ok": false, "error": "Grupo inexistente."}
	var stage_id := COMPETITION_ID + "_" + group_id
	var fixtures: Array = state.fixtures_by_group.get(group_id, []).duplicate(true)
	var standings: Dictionary = state.standings_by_group.get(group_id, {}).duplicate(true)
	var match_id := str(result.get("match_id", result.get("fixture_id", "")))
	var fixture_index := -1
	for index in range(fixtures.size()):
		if str(fixtures[index].get("fixture_id", "")) == match_id:
			fixture_index = index
			break
	if fixture_index < 0 or str(fixtures[fixture_index].get("status", "scheduled")) == "finished":
		return {"ok": false, "error": "Partido inexistente o ya finalizado."}
	var fixture: Dictionary = fixtures[fixture_index]
	if str(fixture.get("home_team_id", "")) != str(result.get("home_team_id", "")) or str(fixture.get("away_team_id", "")) != str(result.get("away_team_id", "")):
		return {"ok": false, "error": "Los clubes del resultado no coinciden con el partido."}
	if not STANDINGS.apply_result(standings, result):
		return {"ok": false, "error": "Resultado inválido."}
	fixture["status"] = "finished"
	fixture["home_goals"] = int(result.get("home_goals", 0))
	fixture["away_goals"] = int(result.get("away_goals", 0))
	fixtures[fixture_index] = fixture
	if not database.commit_match_and_competition_state(stage_id, str(state.season_id), result, fixtures, standings):
		return {"ok": false, "error": "No se pudo guardar el resultado y la clasificación."}
	state.fixtures_by_group[group_id] = fixtures
	state.standings_by_group[group_id] = standings
	return {"ok": true, "fixture": fixture, "standings": STANDINGS.get_ordered_table(standings, true)}

static func build_playoff(state: Dictionary) -> Dictionary:
	var pairings := [["A4", "B5"], ["B4", "A5"], ["C4", "D5"], ["D4", "C5"]]
	var fixtures: Array = []
	for group_id in GROUP_IDS:
		var stage_fixtures: Array = state.fixtures_by_group.get(group_id, [])
		for fixture in stage_fixtures:
			if str(fixture.get("status", "scheduled")) != "finished":
				return {"ok": false, "errors": ["La fase de grupos todavía tiene partidos pendientes."]}
	var ordered := {}
	for group_id in GROUP_IDS:
		ordered[group_id] = STANDINGS.get_ordered_table(state.standings_by_group[group_id], true)
		if ordered[group_id].size() != GROUP_SIZE:
			return {"ok": false, "errors": ["Clasificación incompleta en el grupo " + str(group_id)]}
		for rank in range(5):
			if int(ordered[group_id][rank].get("points", 0)) == int(ordered[group_id][rank + 1].get("points", 0)):
				return {"ok": false, "errors": ["El grupo %s tiene un empate que afecta a los cinco primeros; deben confirmarse los criterios de desempate antes de clasificar." % str(group_id)]}
	for pairing in pairings:
		var home_group := str(pairing[0]).substr(0, 1)
		var home_rank := int(str(pairing[0]).substr(1)) - 1
		var away_group := str(pairing[1]).substr(0, 1)
		var away_rank := int(str(pairing[1]).substr(1)) - 1
		var team_a := str(ordered[home_group][home_rank].team_id)
		var team_b := str(ordered[away_group][away_rank].team_id)
		fixtures.append_array(_two_leg_tie(str(state.season_id), "playoff_%s_%s" % [pairing[0], pairing[1]], team_a, team_b))
	state["playoff_fixtures"] = fixtures
	state["playoff_pairings"] = pairings
	state["status"] = "playoff"
	return {"ok": true, "fixtures": fixtures, "direct_qualifiers": _direct_qualifiers(ordered)}

static func set_round_of_16_draw(state: Dictionary, pairings: Array) -> Dictionary:
	if pairings.size() != 8:
		return {"ok": false, "errors": ["El sorteo de octavos debe contener ocho eliminatorias."]}
	var seen := {}
	for pairing in pairings:
		if not pairing is Array or pairing.size() != 2:
			return {"ok": false, "errors": ["Cada eliminatoria debe contener dos clubes."]}
		for team_id in pairing:
			var id := str(team_id)
			if id.is_empty() or seen.has(id):
				return {"ok": false, "errors": ["Club vacío o repetido en el sorteo de octavos."]}
			seen[id] = true
	if seen.size() != 16:
		return {"ok": false, "errors": ["Octavos debe incluir 16 clubes distintos."]}
	var eligible := {}
	var ordered := {}
	for group_id in GROUP_IDS:
		ordered[group_id] = STANDINGS.get_ordered_table(state.standings_by_group.get(group_id, {}), true)
		if ordered[group_id].size() != GROUP_SIZE:
			return {"ok": false, "errors": ["Clasificación incompleta para validar los octavos."]}
		for rank in range(3):
			eligible[str(ordered[group_id][rank].team_id)] = true
	for pairing in state.get("playoff_pairings", []):
		var tie_id := "playoff_%s_%s" % [str(pairing[0]), str(pairing[1])]
		var resolution := resolve_two_leg_tie(state.get("playoff_fixtures", []), tie_id)
		if str(resolution.get("status", "")) != "decided":
			return {"ok": false, "errors": ["La repesca %s aún no tiene ganador confirmado." % tie_id]}
		eligible[str(resolution.winner_team_id)] = true
	if eligible.size() != 16:
		return {"ok": false, "errors": ["Se necesitan los 12 clasificados directos y los 4 ganadores de la repesca antes del sorteo."]}
	for team_id in seen:
		if not eligible.has(str(team_id)):
			return {"ok": false, "errors": ["El club %s no está clasificado para octavos." % str(team_id)]}
	for team_id in eligible:
		if not seen.has(str(team_id)):
			return {"ok": false, "errors": ["Falta un club clasificado en el sorteo de octavos: " + str(team_id)]}
	state["round_of_16_pairings"] = pairings.duplicate(true)
	state["status"] = "round_of_16_drawn"
	return {"ok": true, "pairings": state.round_of_16_pairings}

static func build_two_leg_round(season_id: String, round_id: String, pairings: Array) -> Array:
	var fixtures: Array = []
	for index in range(pairings.size()):
		var pairing = pairings[index]
		if not pairing is Array or pairing.size() != 2:
			return []
		fixtures.append_array(_two_leg_tie(season_id, "%s_%02d" % [round_id, index + 1], str(pairing[0]), str(pairing[1])))
	return fixtures

static func build_final(season_id: String, team_a: String, team_b: String, venue: String, venue_confirmed_before_start: bool) -> Dictionary:
	if team_a.is_empty() or team_b.is_empty() or team_a == team_b:
		return {"ok": false, "error": "Los finalistas no son válidos."}
	if venue.strip_edges().is_empty() or not venue_confirmed_before_start:
		return {"ok": false, "error": "La final requiere sede neutral confirmada antes del inicio del torneo."}
	return {"ok": true, "fixture": {
		"fixture_id": "%s_%s_final" % [COMPETITION_ID, season_id],
		"competition_id": COMPETITION_ID,
		"season_id": season_id,
		"tie_id": "final",
		"round": "final",
		"leg": 1,
		"home_team_id": team_a,
		"away_team_id": team_b,
		"neutral_venue": true,
		"venue": venue.strip_edges(),
		"status": "scheduled",
		"extra_time_if_draw": true,
		"penalties_if_still_draw": true
	}}

static func build_third_place(season_id: String, team_a: String, team_b: String, venue: String, venue_confirmed_before_start: bool) -> Dictionary:
	if team_a.is_empty() or team_b.is_empty() or team_a == team_b:
		return {"ok": false, "error": "Los participantes del partido por el tercer puesto no son válidos."}
	if venue.strip_edges().is_empty() or not venue_confirmed_before_start:
		return {"ok": false, "error": "El partido por el tercer puesto requiere la sede neutral confirmada del torneo."}
	return {"ok": true, "fixture": {
		"fixture_id": "%s_%s_third_place" % [COMPETITION_ID, season_id],
		"competition_id": COMPETITION_ID,
		"season_id": season_id,
		"tie_id": "third_place",
		"round": "third_place",
		"leg": 1,
		"home_team_id": team_a,
		"away_team_id": team_b,
		"neutral_venue": true,
		"venue": venue.strip_edges(),
		"status": "scheduled",
		"extra_time_if_draw": true,
		"penalties_if_still_draw": true
	}}

static func _direct_qualifiers(ordered: Dictionary) -> Array:
	var result: Array = []
	for group_id in GROUP_IDS:
		for index in range(3):
			result.append(str(ordered[group_id][index].team_id))
	return result

static func _two_leg_tie(season_id: String, tie_id: String, team_a: String, team_b: String) -> Array:
	var first_id := "%s_%s_%s_leg1" % [COMPETITION_ID, season_id, tie_id]
	var second_id := "%s_%s_%s_leg2" % [COMPETITION_ID, season_id, tie_id]
	return [
		{"fixture_id": first_id, "competition_id": COMPETITION_ID, "season_id": season_id, "tie_id": tie_id, "round": "playoff", "leg": 1, "home_team_id": team_a, "away_team_id": team_b, "aggregate_score": true, "extra_time_on_level_aggregate": true, "penalties_if_still_level": true, "status": "scheduled"},
		{"fixture_id": second_id, "competition_id": COMPETITION_ID, "season_id": season_id, "tie_id": tie_id, "round": "playoff", "leg": 2, "home_team_id": team_b, "away_team_id": team_a, "aggregate_score": true, "extra_time_on_level_aggregate": true, "penalties_if_still_level": true, "status": "scheduled"}
	]


static func record_knockout_result(state: Dictionary, fixture_bucket: String, result: Dictionary, database: Node) -> Dictionary:
	var fixtures: Array = state.get(fixture_bucket, []).duplicate(true)
	var match_id := str(result.get("match_id", result.get("fixture_id", "")))
	var fixture_index := -1
	for index in range(fixtures.size()):
		if str(fixtures[index].get("fixture_id", "")) == match_id:
			fixture_index = index
			break
	if fixture_index < 0 or str(fixtures[fixture_index].get("status", "scheduled")) == "finished":
		return {"ok": false, "error": "Partido eliminatorio inexistente o ya finalizado."}
	var fixture: Dictionary = fixtures[fixture_index]
	if str(fixture.get("home_team_id", "")) != str(result.get("home_team_id", "")) or str(fixture.get("away_team_id", "")) != str(result.get("away_team_id", "")):
		return {"ok": false, "error": "Los clubes del resultado no coinciden con la eliminatoria."}
	if str(result.get("status", "")) != "finished" or int(result.get("home_goals", -1)) < 0 or int(result.get("away_goals", -1)) < 0:
		return {"ok": false, "error": "El marcador eliminatorio no es válido."}
	fixture["status"] = "finished"
	fixture["home_goals"] = int(result.home_goals)
	fixture["away_goals"] = int(result.away_goals)
	fixture["decided_team_id"] = str(result.get("decided_team_id", ""))
	fixtures[fixture_index] = fixture
	var stage_id := COMPETITION_ID + "_" + fixture_bucket
	var state_snapshot := {"fixture_bucket": fixture_bucket}
	if not database.commit_match_and_competition_state(stage_id, str(state.season_id), result, fixtures, state_snapshot):
		return {"ok": false, "error": "No se pudo guardar el resultado eliminatorio."}
	state[fixture_bucket] = fixtures
	return {"ok": true, "fixture": fixture, "tie": resolve_two_leg_tie(fixtures, str(fixture.get("tie_id", "")))}

static func resolve_two_leg_tie(fixtures: Array, tie_id: String) -> Dictionary:
	var legs: Array = []
	for fixture in fixtures:
		if str(fixture.get("tie_id", "")) == tie_id:
			legs.append(fixture)
	if legs.is_empty():
		return {"ok": false, "status": "not_found"}
	for fixture in legs:
		if str(fixture.get("status", "scheduled")) != "finished":
			return {"ok": true, "status": "pending"}
	if legs.size() == 1:
		var single: Dictionary = legs[0]
		if int(single.home_goals) > int(single.away_goals):
			return {"ok": true, "status": "decided", "winner_team_id": str(single.home_team_id)}
		if int(single.home_goals) < int(single.away_goals):
			return {"ok": true, "status": "decided", "winner_team_id": str(single.away_team_id)}
		var single_decider := str(single.get("decided_team_id", ""))
		return {"ok": true, "status": "decided" if not single_decider.is_empty() else "awaiting_penalties", "winner_team_id": single_decider}
	if legs.size() != 2:
		return {"ok": false, "status": "invalid_leg_count"}
	var first: Dictionary = legs[0]
	var second: Dictionary = legs[1]
	var team_a := str(first.home_team_id)
	var team_b := str(first.away_team_id)
	var goals_a := int(first.home_goals) + int(second.away_goals)
	var goals_b := int(first.away_goals) + int(second.home_goals)
	if goals_a > goals_b:
		return {"ok": true, "status": "decided", "winner_team_id": team_a, "aggregate": [goals_a, goals_b]}
	if goals_b > goals_a:
		return {"ok": true, "status": "decided", "winner_team_id": team_b, "aggregate": [goals_b, goals_a]}
	var decider := str(second.get("decided_team_id", ""))
	return {"ok": true, "status": "decided" if not decider.is_empty() else "awaiting_extra_time_or_penalties", "winner_team_id": decider, "aggregate": [goals_a, goals_b]}

static func set_knockout_round(state: Dictionary, round_id: String, pairings: Array) -> Dictionary:
	if round_id not in ["round_of_16", "quarterfinals", "semifinals"]:
		return {"ok": false, "errors": ["Ronda eliminatoria no admitida."]}
	var expected_ties := 8 if round_id == "round_of_16" else (4 if round_id == "quarterfinals" else 2)
	if pairings.size() != expected_ties:
		return {"ok": false, "errors": ["Número de eliminatorias incorrecto para " + round_id]}
	var previous_round := "round_of_16" if round_id == "quarterfinals" else ("quarterfinals" if round_id == "semifinals" else "")
	if round_id == "round_of_16":
		if pairings != state.get("round_of_16_pairings", []):
			return {"ok": false, "errors": ["Los octavos deben respetar el sorteo registrado."]}
	elif not previous_round.is_empty():
		var previous_fixtures: Array = state.get("knockout_fixtures", {}).get(previous_round, [])
		var expected_winners := {}
		var previous_tie_count := 8 if previous_round == "round_of_16" else 4
		for tie_index in range(previous_tie_count):
			var tie_id := "%s_%02d" % [previous_round, tie_index + 1]
			var resolution := resolve_two_leg_tie(previous_fixtures, tie_id)
			if str(resolution.get("status", "")) != "decided":
				return {"ok": false, "errors": ["La eliminatoria %s todavía no tiene ganador." % tie_id]}
			expected_winners[str(resolution.winner_team_id)] = true
		var supplied := {}
		for pairing in pairings:
			for team_id in pairing:
				supplied[str(team_id)] = true
		if supplied.size() != expected_winners.size():
			return {"ok": false, "errors": ["La ronda no contiene exactamente a los ganadores de la fase anterior."]}
		for team_id in expected_winners:
			if not supplied.has(str(team_id)):
				return {"ok": false, "errors": ["Falta el ganador clasificado: " + str(team_id)]}
	var fixtures := build_two_leg_round(str(state.season_id), round_id, pairings)
	if fixtures.size() != expected_ties * 2:
		return {"ok": false, "errors": ["No se pudieron generar los partidos de " + round_id]}
	var all_teams := {}
	for pairing in pairings:
		for team_id in pairing:
			var id := str(team_id)
			if id.is_empty() or all_teams.has(id):
				return {"ok": false, "errors": ["Hay clubes vacíos o repetidos en " + round_id]}
			all_teams[id] = true
	state.knockout_fixtures[round_id] = fixtures
	state.status = round_id
	return {"ok": true, "fixtures": fixtures}

static func set_single_match_final(state: Dictionary, finalist_a: String, finalist_b: String) -> Dictionary:
	var semifinal_fixtures: Array = state.get("knockout_fixtures", {}).get("semifinals", [])
	var semifinal_winners := {}
	for tie_index in range(2):
		var resolution := resolve_two_leg_tie(semifinal_fixtures, "semifinals_%02d" % (tie_index + 1))
		if str(resolution.get("status", "")) != "decided":
			return {"ok": false, "error": "Las dos semifinales deben estar resueltas antes de crear la final."}
		semifinal_winners[str(resolution.winner_team_id)] = true
	if semifinal_winners.size() != 2 or not semifinal_winners.has(finalist_a) or not semifinal_winners.has(finalist_b):
		return {"ok": false, "error": "Los finalistas deben ser exactamente los ganadores de las semifinales."}
	var final_result := build_final(str(state.season_id), finalist_a, finalist_b, str(state.get("neutral_final_venue", "")), bool(state.get("venue_confirmed_before_start", false)))
	if not bool(final_result.get("ok", false)):
		return final_result
	var semifinal_losers: Array = []
	for tie_index in range(2):
		var tie_id := "semifinals_%02d" % (tie_index + 1)
		var tie_fixtures: Array = semifinal_fixtures.filter(func(item): return str(item.get("tie_id", "")) == tie_id)
		var winner_id := str(resolve_two_leg_tie(semifinal_fixtures, tie_id).get("winner_team_id", ""))
		if tie_fixtures.is_empty() or winner_id.is_empty():
			return {"ok": false, "error": "No se pudo identificar a los perdedores de ambas semifinales."}
		var first_leg: Dictionary = tie_fixtures[0]
		var team_a := str(first_leg.get("home_team_id", ""))
		var team_b := str(first_leg.get("away_team_id", ""))
		semifinal_losers.append(team_b if winner_id == team_a else team_a)
	var third_place_result := build_third_place(str(state.season_id), str(semifinal_losers[0]), str(semifinal_losers[1]), str(state.get("neutral_final_venue", "")), bool(state.get("venue_confirmed_before_start", false)))
	if not bool(third_place_result.get("ok", false)):
		return third_place_result
	state.knockout_fixtures["third_place"] = [third_place_result.fixture]
	state.knockout_fixtures["final"] = [final_result.fixture]
	state.status = "final"
	return {"ok": true, "fixture": final_result.fixture, "third_place_fixture": third_place_result.fixture}


static func set_knockout_tie_decision(fixtures: Array, tie_id: String, winner_team_id: String) -> Dictionary:
	var legs: Array = []
	for index in range(fixtures.size()):
		if str(fixtures[index].get("tie_id", "")) == tie_id:
			legs.append(index)
	if legs.is_empty() or legs.size() > 2:
		return {"ok": false, "error": "El identificador de eliminatoria no existe o tiene un número de partidos inválido."}
	var first: Dictionary = fixtures[legs[0]]
	if str(first.get("status", "")) != "finished":
		return {"ok": false, "error": "No se puede decidir una eliminatoria antes de finalizar sus partidos."}
	var team_a := str(first.get("home_team_id", ""))
	var team_b := str(first.get("away_team_id", ""))
	if winner_team_id not in [team_a, team_b]:
		return {"ok": false, "error": "El ganador indicado no pertenece a esta eliminatoria."}
	if legs.size() == 1:
		if int(first.get("home_goals", 0)) != int(first.get("away_goals", 0)):
			return {"ok": false, "error": "La decisión por penaltis solo procede si el partido termina empatado tras la prórroga."}
		first["decided_team_id"] = winner_team_id
		fixtures[legs[0]] = first
		return {"ok": true, "fixtures": fixtures, "resolution": resolve_two_leg_tie(fixtures, tie_id)}
	var second: Dictionary = fixtures[legs[1]]
	if str(second.get("status", "")) != "finished":
		return {"ok": false, "error": "No se puede decidir la eliminatoria antes de finalizar la vuelta."}
	var aggregate_a := int(first.get("home_goals", 0)) + int(second.get("away_goals", 0))
	var aggregate_b := int(first.get("away_goals", 0)) + int(second.get("home_goals", 0))
	if aggregate_a != aggregate_b:
		return {"ok": false, "error": "La decisión por penaltis solo procede si el marcador global sigue empatado tras la prórroga."}
	second["decided_team_id"] = winner_team_id
	fixtures[legs[1]] = second
	return {"ok": true, "fixtures": fixtures, "resolution": resolve_two_leg_tie(fixtures, tie_id)}
