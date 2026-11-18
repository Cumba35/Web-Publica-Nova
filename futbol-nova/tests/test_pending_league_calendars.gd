extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	var failures := PackedStringArray()
	var service = root.get_node_or_null("FootballData")
	if service == null:
		failures.append("No se encontró el servicio FootballData.")
	else:
		if bool(service.initialization_failed):
			for error in service.initialization_errors:
				failures.append("Inicialización: " + str(error))
		for stage_id in service.fixtures_by_stage:
			var stage_fixtures: Array = service.get_fixtures(str(stage_id))
			var stage_table: Array = service.get_standings(str(stage_id))
			var expected_matches := int(stage_table.size() * (stage_table.size() - 1))
			if bool(service.single_round_stages.get(str(stage_id), false)):
				expected_matches = int(expected_matches / 2)
			if stage_fixtures.size() != expected_matches:
				failures.append("Calendario incompleto o desajustado en la fase " + str(stage_id))
			var stage_ids := {}
			for fixture in stage_fixtures:
				var fixture_id := str(fixture.get("fixture_id", ""))
				if fixture_id.is_empty() or stage_ids.has(fixture_id):
					failures.append("ID de fixture vacío o duplicado en " + str(stage_id))
				stage_ids[fixture_id] = true
				if not service.registry.teams_by_id.has(str(fixture.get("home_team_id", ""))) or not service.registry.teams_by_id.has(str(fixture.get("away_team_id", ""))):
					failures.append("Fixture con club no registrado en " + str(stage_id))
		var spain_group_stages := 0
		for stage_id in service.fixtures_by_stage:
			if str(stage_id).begins_with("ESP-PF-2026-27_"):
				spain_group_stages += 1
				if bool(service.single_round_stages.get(str(stage_id), true)) or service.get_fixtures(str(stage_id)).size() != 380:
					failures.append("Primera Federación española debe disputar doble vuelta en cada grupo de 20.")
		if spain_group_stages != 2:
			failures.append("Primera Federación española debe cargar dos grupos funcionales.")
		for competition_id in ["USA-MLS-2026", "USA-USLC-2026", "USA-USL1-2026", "ARG-LP-2026"]:
			var competition: Dictionary = service.registry.competitions_by_id.get(competition_id, {})
			if competition.is_empty():
				failures.append("No se registró la competición " + competition_id)
				continue
			var team_ids: Array = competition.get("team_ids", [])
			var fixtures: Array = service.get_fixtures(competition_id)
			var expected := int(team_ids.size() * (team_ids.size() - 1) / 2)
			if fixtures.size() != expected:
				failures.append("%s: calendario generado incompleto (%d/%d)" % [competition_id, fixtures.size(), expected])
			var played_by_team := {}
			var fixture_ids := {}
			for fixture in fixtures:
				var fixture_id := str(fixture.get("fixture_id", ""))
				var home_id := str(fixture.get("home_team_id", ""))
				var away_id := str(fixture.get("away_team_id", ""))
				if fixture_id.is_empty() or fixture_ids.has(fixture_id):
					failures.append("%s: ID de partido vacío o duplicado." % competition_id)
				fixture_ids[fixture_id] = true
				if home_id == away_id or not team_ids.has(home_id) or not team_ids.has(away_id):
					failures.append("%s: enfrentamiento con clubes inválidos." % competition_id)
				played_by_team[home_id] = int(played_by_team.get(home_id, 0)) + 1
				played_by_team[away_id] = int(played_by_team.get(away_id, 0)) + 1
				if str(fixture.get("calendar_type", "")) != "generated_single_round_robin":
					failures.append("%s: tipo de calendario no identificado." % competition_id)
				if bool(fixture.get("official_calendar_verified", true)):
					failures.append("%s: calendario generado marcado erróneamente como oficial." % competition_id)
			for team_id in team_ids:
				if int(played_by_team.get(str(team_id), 0)) != team_ids.size() - 1:
					failures.append("%s: calendario desequilibrado para %s." % [competition_id, str(team_id)])
			if not fixtures.is_empty():
				var first: Dictionary = fixtures[0]
				var invalid_result := {
					"match_id": str(first.fixture_id),
					"home_team_id": str(first.away_team_id),
					"away_team_id": str(first.home_team_id),
					"home_goals": 1,
					"away_goals": 0
				}
				if service.apply_match_result(competition_id, invalid_result):
					failures.append("%s: aceptó un resultado con clubes invertidos." % competition_id)
				var table: Array = service.get_standings(competition_id)
				for row in table:
					if int(row.get("played", 0)) != 0:
						failures.append("%s: un resultado rechazado alteró la clasificación." % competition_id)
	if failures.is_empty():
		print("PENDING LEAGUE CALENDARS: PASS — MLS, USL Championship, USL League One y Liga Profesional Argentina.")
		quit(0)
	for failure in failures:
		push_error(failure)
	quit(1)
