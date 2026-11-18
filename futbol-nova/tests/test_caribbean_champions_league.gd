extends SceneTree

const CaribbeanEngine = preload("res://scripts/simulation/caribbean_champions_league_engine.gd")
const CompetitionConfig = "res://data/caribbean_champions_league.json"

func _initialize() -> void:
	var failures := PackedStringArray()
	_test_slot_distribution(failures)
	_test_edition_and_group_calendars(failures)
	_test_playoff_and_final(failures)
	if failures.is_empty():
		print("CARIBBEAN CHAMPIONS LEAGUE TESTS: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_slot_distribution(failures: PackedStringArray) -> void:
	var config_file := FileAccess.open(CompetitionConfig, FileAccess.READ)
	if config_file == null:
		failures.append("No se encontró la configuración de Liga de Campeones del Caribe.")
		return
	var config = JSON.parse_string(config_file.get_as_text())
	if not config is Dictionary:
		failures.append("La configuración JSON de la competición no es válida.")
		return
	var slots: Dictionary = config.get("participants", {})
	if int(slots.get("total_clubs", 0)) != 48 or int(slots.get("currently_assigned_slots", 0)) != 48 or int(slots.get("unallocated_slots", 0)) != 0:
		failures.append("La configuración debe contener 48 plazas asignadas y ninguna pendiente.")
	var catalog_file := FileAccess.open("res://data/international_club_competitions.json", FileAccess.READ)
	if catalog_file == null:
		failures.append("No se encontró el catálogo de competiciones internacionales.")
	else:
		var catalog = JSON.parse_string(catalog_file.get_as_text())
		var found_caribbean := false
		if catalog is Dictionary:
			for competition in catalog.get("competitions", []):
				if str(competition.get("id", "")) == "caribbean_champions_league_nova" and str(competition.get("name", "")) == "Liga de Campeones del Caribe":
					found_caribbean = true
		if not found_caribbean:
			failures.append("La Liga de Campeones del Caribe no está registrada en el catálogo internacional.")
	var invalid_distribution := CaribbeanEngine.validate_slot_distribution({"association_1": 46})
	if bool(invalid_distribution.get("ok", true)):
		failures.append("El motor permitió iniciar una distribución de solo 46 plazas.")

func _test_edition_and_group_calendars(failures: PackedStringArray) -> void:
	var participants: Array = []
	var association_counts: Array = [3, 3, 3]
	for index in range(11):
		association_counts.append(2)
	for index in range(17):
		association_counts.append(1)
	var team_number := 1
	for association_index in range(association_counts.size()):
		for club_index in range(int(association_counts[association_index])):
			participants.append({
				"team_id": "CFU-TEST-%02d" % team_number,
				"association_id": "CFU-ASSOC-%02d" % (association_index + 1),
				"division_level": 1
			})
			team_number += 1
	var missing_venue := CaribbeanEngine.create_edition("2027", participants, "")
	if bool(missing_venue.get("ok", false)):
		failures.append("El motor permitió crear la edición sin sede neutral confirmada.")
	var edition: Dictionary = CaribbeanEngine.create_edition("2027", participants, "Estadio Neutral de Prueba", 2027)
	if not bool(edition.get("ok", false)):
		failures.append("No se pudo crear una edición válida: " + str(edition.get("errors", [])))
		return
	if edition.get("draw_presentation", []).size() != 48:
		failures.append("La ceremonia del sorteo debe recibir los 48 clubes ya asignados.")
	if edition.get("status", "") != "group_stage" or not bool(edition.get("venue_confirmed_before_start", false)):
		failures.append("La edición no quedó marcada correctamente como iniciada y con sede confirmada.")
	var total_fixtures := 0
	for group_id in ["A", "B", "C", "D"]:
		var team_ids: Array = edition.groups.get(group_id, [])
		var fixtures: Array = edition.fixtures_by_group.get(group_id, [])
		total_fixtures += fixtures.size()
		if team_ids.size() != 12:
			failures.append("El grupo %s no tiene 12 clubes." % group_id)
		var associations_in_group := {}
		for team_id in team_ids:
			for participant in edition.participants:
				if str(participant.team_id) == str(team_id):
					var association_id := str(participant.association_id)
					if associations_in_group.has(association_id):
						failures.append("El grupo %s contiene dos clubes de la misma asociación: %s." % [group_id, association_id])
					associations_in_group[association_id] = true
		if fixtures.size() != 66:
			failures.append("El grupo %s no tiene 66 partidos." % group_id)
		var appearances := {}
		for fixture in fixtures:
			appearances[str(fixture.home_team_id)] = int(appearances.get(str(fixture.home_team_id), 0)) + 1
			appearances[str(fixture.away_team_id)] = int(appearances.get(str(fixture.away_team_id), 0)) + 1
		for team_id in team_ids:
			if int(appearances.get(str(team_id), 0)) != 11:
				failures.append("El club %s no tiene 11 partidos de fase de grupos." % str(team_id))
	if total_fixtures != 264:
		failures.append("La fase de grupos debe generar 264 partidos, no %d." % total_fixtures)
	var duplicate_participants := participants.duplicate(true)
	duplicate_participants[47] = duplicate_participants[0].duplicate(true)
	if bool(CaribbeanEngine.create_edition("2027-duplicate", duplicate_participants, "Sede neutral").get("ok", false)):
		failures.append("El motor permitió un club duplicado.")

func _test_playoff_and_final(failures: PackedStringArray) -> void:
	var participants: Array = []
	for index in range(48):
		participants.append({"team_id": "CLUB-%02d" % (index + 1), "association_id": "ASSOC-%02d" % (index + 1), "division_level": 1})
	var edition: Dictionary = CaribbeanEngine.create_edition("2027-playoff", participants, "Sede Neutral")
	if not bool(edition.get("ok", false)):
		failures.append("No se pudo preparar la edición para probar la repesca.")
		return
	for group_id in ["A", "B", "C", "D"]:
		for fixture in edition.fixtures_by_group[group_id]:
			fixture["status"] = "finished"
		edition.fixtures_by_group[group_id] = edition.fixtures_by_group[group_id]
	var unresolved_playoff: Dictionary = CaribbeanEngine.build_playoff(edition)
	if bool(unresolved_playoff.get("ok", false)):
		failures.append("El motor clasificó clubes con empates sin criterio de desempate aprobado.")
	for group_id in ["A", "B", "C", "D"]:
		var table: Dictionary = edition.standings_by_group[group_id]
		var rank_index := 0
		for team_id in table.keys():
			var row: Dictionary = table[team_id]
			row["points"] = 100 - rank_index
			table[team_id] = row
			rank_index += 1
		edition.standings_by_group[group_id] = table
	var playoff: Dictionary = CaribbeanEngine.build_playoff(edition)
	if not bool(playoff.get("ok", false)):
		failures.append("No se generó la repesca con posiciones sin empate: " + str(playoff.get("errors", [])))
	elif playoff.get("fixtures", []).size() != 8 or playoff.get("direct_qualifiers", []).size() != 12:
		failures.append("La repesca debe tener 8 partidos y dejar 12 clasificados directos.")
	var playoff_fixtures: Array = playoff.get("fixtures", []).duplicate(true)
	for tie_index in range(4):
		var first_index := tie_index * 2
		var second_index := first_index + 1
		playoff_fixtures[first_index]["status"] = "finished"
		playoff_fixtures[first_index]["home_goals"] = 1
		playoff_fixtures[first_index]["away_goals"] = 0
		playoff_fixtures[second_index]["status"] = "finished"
		playoff_fixtures[second_index]["home_goals"] = 1
		playoff_fixtures[second_index]["away_goals"] = 0
		var tie_id := str(playoff_fixtures[first_index].tie_id)
		var winner_id := str(playoff_fixtures[first_index].home_team_id)
		var decision := CaribbeanEngine.set_knockout_tie_decision(playoff_fixtures, tie_id, winner_id)
		if not bool(decision.get("ok", false)):
			failures.append("No se pudo registrar la decisión de penaltis sin aplicar gol visitante.")
		else:
			playoff_fixtures = decision.fixtures
		edition["playoff_fixtures"] = playoff_fixtures
	var resolved := CaribbeanEngine.resolve_two_leg_tie(playoff_fixtures, str(playoff_fixtures[0].tie_id))
	if str(resolved.get("winner_team_id", "")) != str(playoff_fixtures[0].home_team_id):
		failures.append("La eliminatoria empatada no respetó la decisión explícita de penaltis.")
	edition["playoff_fixtures"] = playoff_fixtures
	var qualified: Array = playoff.get("direct_qualifiers", []).duplicate()
	for pairing in edition.playoff_pairings:
		var tie_id := "playoff_%s_%s" % [str(pairing[0]), str(pairing[1])]
		var tie_result := CaribbeanEngine.resolve_two_leg_tie(playoff_fixtures, tie_id)
		if str(tie_result.get("status", "")) == "decided":
			qualified.append(str(tie_result.winner_team_id))
	var round_of_16_pairs: Array = []
	for index in range(0, qualified.size(), 2):
		round_of_16_pairs.append([str(qualified[index]), str(qualified[index + 1])])
	var draw: Dictionary = CaribbeanEngine.set_round_of_16_draw(edition, round_of_16_pairs)
	if not bool(draw.get("ok", false)):
		failures.append("El sorteo de octavos no aceptó los 16 clasificados válidos: " + str(draw.get("errors", [])))
	var round_of_16: Dictionary = CaribbeanEngine.set_knockout_round(edition, "round_of_16", round_of_16_pairs)
	if not bool(round_of_16.get("ok", false)) or round_of_16.get("fixtures", []).size() != 16:
		failures.append("No se generaron los 16 partidos de octavos a doble partido.")
	var final_ok: Dictionary = CaribbeanEngine.build_final("2027-playoff", "FINAL-A", "FINAL-B", "Sede Neutral", true)
	if not bool(final_ok.get("ok", false)) or not bool(final_ok.get("fixture", {}).get("neutral_venue", false)) or int(final_ok.get("fixture", {}).get("leg", 0)) != 1:
		failures.append("La final no se generó como partido único en sede neutral.")
	var final_without_confirmation := CaribbeanEngine.build_final("2027-playoff", "FINAL-A", "FINAL-B", "Sede Neutral", false)
	if bool(final_without_confirmation.get("ok", false)):
		failures.append("El motor permitió una final sin sede confirmada antes del torneo.")
	var third_place_ok: Dictionary = CaribbeanEngine.build_third_place("2026-2027", "SEMI-LOSER-A", "SEMI-LOSER-B", "Sede Neutral", true)
	if not bool(third_place_ok.get("ok", false)) or str(third_place_ok.get("fixture", {}).get("round", "")) != "third_place" or not bool(third_place_ok.get("fixture", {}).get("neutral_venue", false)):
		failures.append("El partido por el tercer puesto no se generó como partido único en sede neutral.")
	var third_place_without_venue := CaribbeanEngine.build_third_place("2026-2027", "SEMI-LOSER-A", "SEMI-LOSER-B", "", false)
	if bool(third_place_without_venue.get("ok", false)):
		failures.append("El motor permitió el partido por el tercer puesto sin sede neutral confirmada.")
