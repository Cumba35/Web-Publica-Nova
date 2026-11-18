extends SceneTree

const TAS = preload("res://scripts/simulation/tas_competition_engine.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	var edition_result := TAS.create_edition("2027", _qualifiers())
	if not bool(edition_result.get("ok", false)):
		_fail(edition_result.get("errors", []))
		return
	var edition: Dictionary = edition_result.edition
	if edition.get("draw_presentation", []).size() != 9:
		errors.append("La presentación del sorteo debe incluir los nueve clasificados del TAS.")
	if int(edition.get("participant_count", 0)) != 9 or int(edition.get("total_scheduled_matches", 0)) != 9:
		errors.append("La edición inicial debe tener nueve clubes y nueve partidos.")
	for group_id in ["A", "B", "C"]:
		var stage_id: String = "first_phase_group_" + str(group_id)
		var fixtures: Array = edition.fixtures_by_stage.get(stage_id, [])
		if fixtures.size() != 3:
			errors.append("Cada grupo debe tener tres partidos: " + group_id)
		for fixture in fixtures:
			if int(fixture.get("legs", 0)) != 1 or int(fixture.get("leg", 0)) != 1:
				errors.append("El TAS no puede generar ida y vuelta.")
			if str(fixture.get("match_system", "")) != "single_match":
				errors.append("Fixture sin formato de partido único.")
	if not errors.is_empty():
		_fail(errors)
		return
	edition = _finish_group_phase(edition)
	var advanced := TAS.advance_after_first_phase(edition)
	if not bool(advanced.get("ok", false)):
		_fail([advanced.get("error", "No se pudo avanzar al grupo final.")])
		return
	edition = advanced.edition
	for group_id in ["A", "B", "C"]:
		if not edition.get("tiebreak_draws_by_stage", {}).has("first_phase_group_" + group_id):
			errors.append("Falta el registro persistente de desempate del grupo " + group_id)
	if not errors.is_empty():
		_fail(errors)
		return
	if edition.fixtures_by_stage.final_group.size() != 3 or int(edition.total_scheduled_matches) != 12:
		_fail(["El grupo final debe añadir tres partidos únicos."])
		return
	for fixture in edition.fixtures_by_stage.final_group:
		if int(fixture.get("leg", 0)) != 1 or int(fixture.get("legs", 0)) != 1:
			_fail(["El grupo final debe jugarse a partido único."])
			return
	edition = _finish_final_group(edition)
	var final_stage := TAS.advance_to_championship_final(edition)
	if not bool(final_stage.get("ok", false)):
		_fail([final_stage.get("error", "No se pudo crear la final.")])
		return
	edition = final_stage.edition
	if not edition.get("tiebreak_draws_by_stage", {}).has("final_group"):
		_fail(["Falta el registro de desempate del grupo final."])
		return
	if edition.fixtures_by_stage.championship_final.size() != 1 or int(edition.total_scheduled_matches) != 13:
		_fail(["El TAS debe terminar con trece partidos, incluida una final única."])
		return
	var final_fixture: Dictionary = edition.fixtures_by_stage.championship_final[0]
	if int(final_fixture.get("leg", 0)) != 1 or int(final_fixture.get("legs", 0)) != 1:
		_fail(["La final debe disputarse a un solo encuentro."])
		return
	var all_fixtures: Array = TAS.get_all_fixtures(edition)
	if all_fixtures.size() != 13:
		_fail(["La edición completa debe contener exactamente trece fixtures."])
		return
	for fixture in all_fixtures:
		if int(fixture.get("leg", 0)) != 1 or int(fixture.get("legs", 0)) != 1 or str(fixture.get("match_system", "")) != "single_match":
			_fail(["Se detectó un fixture del TAS con más de un encuentro."])
			return
	var final_result := _result(final_fixture, 2, 1)
	final_result["winner_team_id"] = str(final_fixture.home_team_id)
	var applied := TAS.apply_result(edition, "championship_final", final_result)
	if not bool(applied.get("ok", false)):
		_fail([applied.get("error", "No se pudo registrar la final.")])
		return
	var completed := TAS.complete_edition(applied.edition)
	if not bool(completed.get("ok", false)) or str(completed.edition.get("status", "")) != "completed":
		_fail([completed.get("error", "La edición no se cerró correctamente.")])
		return
	print("TAS COMPETITION ENGINE TESTS: PASS · 13 partidos a partido único.")
	quit(0)

func _finish_group_phase(edition: Dictionary) -> Dictionary:
	var updated := edition.duplicate(true)
	for group_id in ["A", "B", "C"]:
		var stage_id: String = "first_phase_group_" + str(group_id)
		var teams: Array = updated.groups[group_id]
		for fixture in updated.fixtures_by_stage[stage_id].duplicate(true):
			var home_rank := teams.find(str(fixture.home_team_id))
			var away_rank := teams.find(str(fixture.away_team_id))
			var result := _result(fixture, 2, 0) if home_rank < away_rank else _result(fixture, 0, 2)
			var response := TAS.apply_result(updated, stage_id, result)
			if not bool(response.get("ok", false)):
				_fail([response.get("error", "Error al finalizar grupos.")])
				return {}
			updated = response.edition
	return updated

func _finish_final_group(edition: Dictionary) -> Dictionary:
	var updated := edition.duplicate(true)
	var teams: Array = updated.final_group_team_ids
	for fixture in updated.fixtures_by_stage.final_group.duplicate(true):
		var home_rank := teams.find(str(fixture.home_team_id))
		var away_rank := teams.find(str(fixture.away_team_id))
		var result := _result(fixture, 3, 0) if home_rank < away_rank else _result(fixture, 0, 3)
		var response := TAS.apply_result(updated, "final_group", result)
		if not bool(response.get("ok", false)):
			_fail([response.get("error", "Error al finalizar el grupo final.")])
			return {}
		updated = response.edition
	return updated

func _result(fixture: Dictionary, home_goals: int, away_goals: int) -> Dictionary:
	return {
		"fixture_id": str(fixture.fixture_id),
		"match_id": str(fixture.fixture_id),
		"home_team_id": str(fixture.home_team_id),
		"away_team_id": str(fixture.away_team_id),
		"home_goals": home_goals,
		"away_goals": away_goals,
		"status": "finished"
	}

func _qualifiers() -> Dictionary:
	return {
		"caribbean": [{"position": 1, "team_id": "CAR-1"}, {"position": 2, "team_id": "CAR-2"}, {"position": 3, "team_id": "CAR-3"}],
		"south_america": [{"position": 1, "team_id": "SAM-1"}, {"position": 2, "team_id": "SAM-2"}, {"position": 3, "team_id": "SAM-3"}],
		"north_and_central_america": [{"position": 1, "team_id": "NCA-1"}, {"position": 2, "team_id": "NCA-2"}, {"position": 3, "team_id": "NCA-3"}]
	}

func _fail(errors: Array) -> void:
	for error in errors:
		push_error(str(error))
	quit(1)
