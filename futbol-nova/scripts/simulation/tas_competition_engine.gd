extends RefCounted
class_name NovaTASCompetitionEngine

const GROUP_IDS := ["A", "B", "C"]
const REGIONS := ["caribbean", "south_america", "north_and_central_america"]
const SCHEDULER = preload("res://scripts/simulation/round_robin_scheduler.gd")
const STANDINGS = preload("res://scripts/simulation/league_standings.gd")
const TAS_RULES = preload("res://scripts/simulation/tas_match_decision_engine.gd")

const GROUP_ASSIGNMENT := {
	"A": {"caribbean": 1, "south_america": 2, "north_and_central_america": 3},
	"B": {"caribbean": 2, "south_america": 3, "north_and_central_america": 1},
	"C": {"caribbean": 3, "south_america": 1, "north_and_central_america": 2}
}

static func validate_qualifiers(qualifiers: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var seen := {}
	for region in REGIONS:
		var entries: Array = qualifiers.get(region, [])
		if entries.size() != 3:
			errors.append("La región %s debe aportar exactamente tres clubes." % region)
			continue
		var positions := {}
		for entry in entries:
			if not entry is Dictionary:
				errors.append("Clasificado inválido en " + region)
				continue
			var team_id := str(entry.get("team_id", entry.get("id", "")))
			var position := int(entry.get("position", 0))
			if team_id.is_empty() or position < 1 or position > 3 or positions.has(position):
				errors.append("Clasificado con ID o posición inválida en " + region)
				continue
			if seen.has(team_id):
				errors.append("Un club no puede ocupar dos plazas del TAS: " + team_id)
			seen[team_id] = true
			positions[position] = team_id
		for position in [1, 2, 3]:
			if not positions.has(position):
				errors.append("Falta el puesto %d de %s." % [position, region])
	return {"ok": errors.is_empty(), "errors": errors, "participant_count": seen.size()}

static func create_edition(season_id: String, qualifiers: Dictionary, draw_seed: int = 1) -> Dictionary:
	if season_id.is_empty():
		return {"ok": false, "errors": ["Falta la temporada del TAS."]}
	var validation := validate_qualifiers(qualifiers)
	if not bool(validation.ok):
		return {"ok": false, "errors": validation.errors}
	var groups := {"A": [], "B": [], "C": []}
	for group_id in GROUP_IDS:
		for region in REGIONS:
			var required_position := int(GROUP_ASSIGNMENT[group_id][region])
			for entry in qualifiers[region]:
				if int(entry.get("position", 0)) == required_position:
					groups[group_id].append(str(entry.get("team_id", entry.get("id", ""))))
					break
		if groups[group_id].size() != 3:
			return {"ok": false, "errors": ["No se pudo formar el grupo " + group_id + "."]}
	var draw_presentation: Array = []
	for group_id in GROUP_IDS:
		for region in REGIONS:
			var required_position := int(GROUP_ASSIGNMENT[group_id][region])
			for entry in qualifiers[region]:
				if int(entry.get("position", 0)) == required_position:
					draw_presentation.append({
						"team_id": str(entry.get("team_id", entry.get("id", ""))),
						"group": group_id,
						"association": region,
						"position": required_position
					})
					break
	var fixtures_by_stage := {}
	var standings_by_stage := {}
	for group_id in GROUP_IDS:
		var stage_id: String = "first_phase_group_" + str(group_id)
		var fixtures: Array = SCHEDULER.create_fixtures(groups[group_id], stage_id, season_id, false)
		if fixtures.size() != 3:
			return {"ok": false, "errors": ["El grupo %s no generó sus tres partidos a partido único." % group_id]}
		for fixture in fixtures:
			fixture["stage_id"] = stage_id
			fixture["phase"] = "first_phase"
			fixture["legs"] = 1
			fixture["match_system"] = "single_match"
		fixtures_by_stage[stage_id] = fixtures
		standings_by_stage[stage_id] = STANDINGS.create_table(groups[group_id])
	return {
		"ok": true,
		"competition_id": "american_super_champions_tas",
		"season_id": season_id,
		"draw_seed": maxi(1, draw_seed),
		"status": "first_phase",
		"fixture_format": "single_match",
		"participant_count": 9,
		"groups": groups,
		"draw_presentation": draw_presentation,
		"fixtures_by_stage": fixtures_by_stage,
		"standings_by_stage": standings_by_stage,
		"ordered_standings_by_stage": {},
		"tiebreak_draws_by_stage": {},
		"final_group_team_ids": [],
		"finalists": [],
		"champion_team_id": "",
		"total_scheduled_matches": 9,
		"errors": []
	}

static func apply_result(edition: Dictionary, stage_id: String, result: Dictionary) -> Dictionary:
	if not edition.get("fixtures_by_stage", {}).has(stage_id):
		return {"ok": false, "error": "La fase no existe en esta edición del TAS."}
	for field in ["fixture_id", "home_team_id", "away_team_id", "home_goals", "away_goals", "status"]:
		if not result.has(field):
			return {"ok": false, "error": "El resultado TAS está incompleto: " + field}
	if str(result.status) != "finished":
		return {"ok": false, "error": "Solo se pueden aplicar partidos finalizados."}
	if int(result.home_goals) < 0 or int(result.away_goals) < 0:
		return {"ok": false, "error": "El marcador del TAS no puede ser negativo."}
	if stage_id == "championship_final":
		var winner_id := str(result.get("winner_team_id", ""))
		if winner_id != str(result.home_team_id) and winner_id != str(result.away_team_id):
			return {"ok": false, "error": "La final del TAS debe registrar un ganador participante."}
	var updated := edition.duplicate(true)
	var fixtures: Array = updated.fixtures_by_stage[stage_id]
	var found := false
	for index in range(fixtures.size()):
		var fixture: Dictionary = fixtures[index]
		if str(fixture.get("fixture_id", "")) != str(result.fixture_id):
			continue
		if str(fixture.get("status", "scheduled")) == "finished":
			return {"ok": false, "error": "El partido TAS ya está finalizado."}
		if str(fixture.home_team_id) != str(result.home_team_id) or str(fixture.away_team_id) != str(result.away_team_id):
			return {"ok": false, "error": "Los clubes del resultado no coinciden con el fixture."}
		fixture["status"] = "finished"
		fixture["home_goals"] = int(result.home_goals)
		fixture["away_goals"] = int(result.away_goals)
		fixture["result"] = result.duplicate(true)
		fixtures[index] = fixture
		found = true
		break
	if not found:
		return {"ok": false, "error": "El fixture no pertenece a la fase indicada."}
	updated.fixtures_by_stage[stage_id] = fixtures
	if stage_id != "championship_final":
		var table: Dictionary = updated.standings_by_stage.get(stage_id, {})
		if not STANDINGS.apply_result(table, result):
			return {"ok": false, "error": "No se pudo actualizar la clasificación del TAS."}
		updated.standings_by_stage[stage_id] = table
	return {"ok": true, "edition": updated}

static func advance_after_first_phase(edition: Dictionary) -> Dictionary:
	if str(edition.get("status", "")) != "first_phase":
		return {"ok": false, "error": "La edición no está en la primera fase."}
	var winners: Array[String] = []
	var updated_ordered: Dictionary = edition.get("ordered_standings_by_stage", {}).duplicate(true)
	var updated_draws: Dictionary = edition.get("tiebreak_draws_by_stage", {}).duplicate(true)
	for group_id in GROUP_IDS:
		var stage_id: String = "first_phase_group_" + str(group_id)
		if not _stage_is_finished(edition, stage_id):
			return {"ok": false, "error": "Todavía hay partidos pendientes en el grupo " + group_id + "."}
		var table: Dictionary = edition.get("standings_by_stage", {}).get(stage_id, {})
		var draw_seed := maxi(1, int(edition.get("draw_seed", 1)) + GROUP_IDS.find(group_id))
		var ordered: Array = TAS_RULES.get_ordered_tas_table(table, draw_seed)
		if ordered.size() != 3:
			return {"ok": false, "error": "La tabla del grupo " + group_id + " está incompleta."}
		winners.append(str(ordered[0].team_id))
		updated_ordered[stage_id] = ordered.duplicate(true)
		updated_draws[stage_id] = _build_draw_record(ordered, draw_seed)
	var season_id := str(edition.get("season_id", ""))
	var fixtures: Array = SCHEDULER.create_fixtures(winners, "final_group", season_id, false)
	if fixtures.size() != 3:
		return {"ok": false, "error": "No se pudo crear el grupo final a partido único."}
	for fixture in fixtures:
		fixture["stage_id"] = "final_group"
		fixture["phase"] = "final_group"
		fixture["legs"] = 1
		fixture["match_system"] = "single_match"
	var updated := edition.duplicate(true)
	updated["fixtures_by_stage"]["final_group"] = fixtures
	updated["standings_by_stage"]["final_group"] = STANDINGS.create_table(winners)
	updated["final_group_team_ids"] = winners
	updated["ordered_standings_by_stage"] = updated_ordered
	updated["tiebreak_draws_by_stage"] = updated_draws
	updated["status"] = "final_group"
	updated["total_scheduled_matches"] = 12
	return {"ok": true, "edition": updated}

static func advance_to_championship_final(edition: Dictionary) -> Dictionary:
	if str(edition.get("status", "")) != "final_group":
		return {"ok": false, "error": "La edición no está en el grupo final."}
	if not _stage_is_finished(edition, "final_group"):
		return {"ok": false, "error": "El grupo final todavía tiene partidos pendientes."}
	var table: Dictionary = edition.get("standings_by_stage", {}).get("final_group", {})
	var draw_seed := maxi(1, int(edition.get("draw_seed", 1)) + 100)
	var ordered: Array = TAS_RULES.get_ordered_tas_table(table, draw_seed)
	if ordered.size() != 3:
		return {"ok": false, "error": "La clasificación del grupo final está incompleta."}
	var finalists := [str(ordered[0].team_id), str(ordered[1].team_id)]
	var fixtures: Array = SCHEDULER.create_fixtures(finalists, "championship_final", str(edition.get("season_id", "")), false)
	if fixtures.size() != 1:
		return {"ok": false, "error": "La final no se pudo generar como partido único."}
	for fixture in fixtures:
		fixture["stage_id"] = "championship_final"
		fixture["phase"] = "championship_final"
		fixture["legs"] = 1
		fixture["match_system"] = "single_match"
	var updated := edition.duplicate(true)
	updated["fixtures_by_stage"]["championship_final"] = fixtures
	updated["standings_by_stage"]["championship_final"] = STANDINGS.create_table(finalists)
	updated["finalists"] = finalists
	var ordered_by_stage: Dictionary = updated.get("ordered_standings_by_stage", {}).duplicate(true)
	var draws_by_stage: Dictionary = updated.get("tiebreak_draws_by_stage", {}).duplicate(true)
	ordered_by_stage["final_group"] = ordered.duplicate(true)
	draws_by_stage["final_group"] = _build_draw_record(ordered, draw_seed)
	updated["ordered_standings_by_stage"] = ordered_by_stage
	updated["tiebreak_draws_by_stage"] = draws_by_stage
	updated["status"] = "championship_final"
	updated["total_scheduled_matches"] = 13
	return {"ok": true, "edition": updated}

static func complete_edition(edition: Dictionary) -> Dictionary:
	if str(edition.get("status", "")) != "championship_final" or not _stage_is_finished(edition, "championship_final"):
		return {"ok": false, "error": "La final del TAS todavía no está finalizada."}
	var fixtures: Array = edition.fixtures_by_stage.championship_final
	if fixtures.size() != 1:
		return {"ok": false, "error": "La edición debe tener una sola final."}
	var result: Dictionary = fixtures[0].get("result", {})
	var winner_id := str(result.get("winner_team_id", ""))
	if winner_id.is_empty() or not edition.get("finalists", []).has(winner_id):
		return {"ok": false, "error": "La final no contiene un campeón válido."}
	var updated := edition.duplicate(true)
	updated["status"] = "completed"
	updated["champion_team_id"] = winner_id
	return {"ok": true, "edition": updated}

static func get_all_fixtures(edition: Dictionary) -> Array:
	var result: Array = []
	for stage_id in edition.get("fixtures_by_stage", {}):
		for fixture in edition.fixtures_by_stage[stage_id]:
			result.append(fixture.duplicate(true))
	return result

static func _build_draw_record(ordered: Array, draw_seed: int) -> Dictionary:
	var lots := {}
	for row in ordered:
		lots[str(row.get("team_id", ""))] = int(row.get("tas_draw_lot", 0))
	return {
		"seed": draw_seed,
		"draw_lots": lots,
		"criteria": ["points", "goal_difference", "goals_for", "head_to_head_points", "head_to_head_goal_difference", "head_to_head_goals_for", "fair_play", "seeded_draw"]
	}

static func _stage_is_finished(edition: Dictionary, stage_id: String) -> bool:
	var fixtures: Array = edition.get("fixtures_by_stage", {}).get(stage_id, [])
	if fixtures.is_empty():
		return false
	for fixture in fixtures:
		if str(fixture.get("status", "scheduled")) != "finished":
			return false
	return true
