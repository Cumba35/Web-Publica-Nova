extends SceneTree

const RegionalEngine = preload("res://scripts/simulation/american_regional_champions_engine.gd")

func _initialize() -> void:
	var associations := ["ARG", "BOL", "BRA", "CHI", "COL", "ECU", "PAR", "PER", "URU", "VEN"]
	var participants := []
	for association in associations:
		for index in range(4):
			participants.append({"team_id": "%s_%02d" % [association, index + 1], "association_id": association, "division_level": 1})
	var validation := RegionalEngine.validate_participants(participants, associations)
	if not bool(validation.ok):
		failures_exit(validation.errors)
		return
	var windows := [
		{"date": "2026-10-10", "window_end": "2026-10-13"},
		{"date": "2026-10-24", "window_end": "2026-10-27"},
		{"date": "2026-11-07", "window_end": "2026-11-10", "blocked_dates": ["2026-11-09", "2026-11-10"]},
		{"date": "2026-11-21", "window_end": "2026-11-24"},
		{"date": "2026-12-05", "window_end": "2026-12-08"},
		{"date": "2026-12-19", "window_end": "2026-12-22"},
		{"date": "2027-01-16", "window_end": "2027-01-19"},
		{"date": "2027-01-30", "window_end": "2027-02-02"},
		{"date": "2027-02-13", "window_end": "2027-02-16"}
	]
	var edition := RegionalEngine.create_edition("south_america_champions_league_nova", "2026-2027", participants, associations, windows, 1234)
	if not bool(edition.get("ok", false)):
		failures_exit(edition.get("errors", []))
		return
	if edition.get("draw_presentation", []).size() != 40:
		failures_exit(["La presentación del sorteo debe incluir los 40 clubes ya asignados."])
		return
	var seen := {}
	for group_id in ["A", "B", "C", "D"]:
		var group_ids: Array = edition.groups[group_id]
		if group_ids.size() != 10:
			failures_exit(["Grupo %s no tiene diez clubes." % group_id])
			return
		var represented := {}
		for team_id in group_ids:
			var association_id := str(team_id).split("_")[0]
			represented[association_id] = true
		if represented.size() != 10:
			failures_exit(["Grupo %s no representa las diez asociaciones." % group_id])
			return
		var fixtures: Array = edition.fixtures_by_group[group_id]
		if fixtures.size() != 45:
			failures_exit(["Grupo %s no tiene 45 partidos." % group_id])
			return
		for fixture in fixtures:
			if str(fixture.get("scheduled_date", "")).is_empty() or int(fixture.get("matchday", 0)) < 1:
				failures_exit(["Fixture sin jornada o fecha de planificación."])
				return
			if str(fixture.get("scheduled_date", "")) in ["2026-11-09", "2026-11-10"]:
				failures_exit(["El motor asignó un partido dentro de la ventana FIFA bloqueada."])
			seen[str(fixture.fixture_id)] = true
	if seen.size() != 180:
		failures_exit(["La edición no genera 180 partidos únicos."])
		return
	var duplicate := participants.duplicate(true)
	duplicate[0].team_id = duplicate[1].team_id
	if bool(RegionalEngine.validate_participants(duplicate, associations).ok):
		failures_exit(["Se aceptó un club duplicado."])
		return
	print("FUTBOL_NOVA_AMERICAN_REGIONAL_ENGINE_TESTS: PASS")
	quit(0)

func failures_exit(errors: Array) -> void:
	for error in errors:
		push_error(str(error))
	quit(1)
