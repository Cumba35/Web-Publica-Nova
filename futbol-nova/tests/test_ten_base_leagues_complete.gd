extends SceneTree

const REGISTRY = preload("res://scripts/data/football_data_registry.gd")
const CUBA = preload("res://scripts/data/cuba_league_importer.gd")
const CUBA_ROSTERS = preload("res://scripts/data/cuba_roster_importer.gd")
const ENGLAND = preload("res://scripts/data/global_league_importer.gd")
const USA = preload("res://scripts/data/usa_league_importer.gd")
const BASE = preload("res://scripts/data/base_league_importer.gd")
const BASE_ROSTERS = preload("res://scripts/data/base_league_roster_importer.gd")
const PRE_MATCH = preload("res://scripts/ui/pre_match_setup.gd")
const MATCH_11V11 = preload("res://scripts/gameplay/match_11v11_controller.gd")
const SCHEDULER = preload("res://scripts/simulation/round_robin_scheduler.gd")

func _initialize() -> void:
	var registry = REGISTRY.new()
	var errors := PackedStringArray()
	var cuba: Dictionary = CUBA.import_into_registry(registry)
	if not bool(cuba.get("ok", false)):
		errors.append_array(PackedStringArray(cuba.get("errors", [])))
	var cuba_rosters: Dictionary = CUBA_ROSTERS.import_into_registry(registry)
	if not bool(cuba_rosters.get("ok", false)):
		errors.append_array(PackedStringArray(cuba_rosters.get("errors", [])))
	var england: Dictionary = ENGLAND.import_into_registry(registry)
	if not bool(england.get("ok", false)):
		errors.append_array(PackedStringArray(england.get("errors", [])))
	var usa: Dictionary = USA.import_into_registry(registry)
	if not bool(usa.get("ok", false)):
		errors.append_array(PackedStringArray(usa.get("errors", [])))
	var base: Dictionary = BASE.import_into_registry(registry)
	if not bool(base.get("ok", false)):
		errors.append_array(PackedStringArray(base.get("errors", [])))
	var base_rosters: Dictionary = BASE_ROSTERS.import_into_registry(registry)
	if not bool(base_rosters.get("ok", false)):
		errors.append_array(PackedStringArray(base_rosters.get("errors", [])))

	var expected_by_country := {
		"ENG": 68, "ESP": 82, "BRA": 60, "ITA": 100, "GER": 56,
		"FRA": 54, "POR": 56, "ARG": 125, "CUB": 52, "USA": 72
	}
	var actual_by_country := {}
	var playable_team_count := 0
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		var country := str(team.get("country_id", ""))
		actual_by_country[country] = int(actual_by_country.get(country, 0)) + 1
		var roster: Array = registry.get_team_roster(str(team_id))
		if roster.size() != 22:
			errors.append("Equipo no jugable por plantilla incompleta: %s (%d/22)" % [str(team_id), roster.size()])
			continue
		var starting_ids: Array[String] = PRE_MATCH.build_starting_eleven(roster)
		if starting_ids.size() != 11:
			errors.append("No se pudo construir un once inicial para: " + str(team_id))
			continue
		var lineup := MATCH_11V11.build_lineup(str(team_id), true, starting_ids)
		if lineup.size() != 11:
			errors.append("El equipo no pudo generar una alineación 11v11: " + str(team_id))
			continue
		var unique_ids := {}
		for player_id in starting_ids:
			if player_id.is_empty() or unique_ids.has(player_id):
				errors.append("Once inicial con ID vacío o duplicado: " + str(team_id))
			unique_ids[player_id] = true
		playable_team_count += 1

	for country in expected_by_country:
		var expected := int(expected_by_country[country])
		var actual := int(actual_by_country.get(country, 0))
		if actual != expected:
			errors.append(country + ": se esperaban " + str(expected) + " clubes y se importaron " + str(actual))
	if registry.teams_by_id.size() != 725:
		errors.append("Total de clubes incorrecto: " + str(registry.teams_by_id.size()) + "/725")
	if registry.players_by_id.size() != 15950:
		errors.append("Total de futbolistas incorrecto: " + str(registry.players_by_id.size()) + "/15950")
	if playable_team_count != 725:
		errors.append("Equipos que realmente pueden generar un once: " + str(playable_team_count) + "/725")
	if registry.competitions_by_id.size() != 31:
		errors.append("Se esperaban 31 competiciones de las diez ligas: " + str(registry.competitions_by_id.size()))

	var scheduled_competitions := 0
	for competition_id in registry.competitions_by_id:
		var competition: Dictionary = registry.competitions_by_id[competition_id]
		var seen := {}
		var team_ids: Array = competition.get("team_ids", [])
		for raw_team_id in team_ids:
			var team_id := str(raw_team_id)
			if seen.has(team_id):
				errors.append("Club duplicado en " + str(competition_id) + ": " + team_id)
			seen[team_id] = true
			if not registry.teams_by_id.has(team_id):
				errors.append("Club inexistente en " + str(competition_id) + ": " + team_id)
			elif registry.get_team_roster(team_id).size() != 22:
				errors.append("Club de competición sin plantilla jugable: " + team_id)
		if team_ids.size() < 2:
			errors.append("Competición sin suficientes equipos: " + str(competition_id))
			continue
		var fixtures: Array = SCHEDULER.create_fixtures(team_ids, str(competition_id), "test_2026", true)
		if fixtures.is_empty():
			errors.append("No se pudo generar calendario para: " + str(competition_id))
			continue
		var first_fixture: Dictionary = fixtures[0]
		var home_id := str(first_fixture.get("home_team_id", ""))
		var away_id := str(first_fixture.get("away_team_id", ""))
		if home_id == away_id or registry.get_team_roster(home_id).size() != 22 or registry.get_team_roster(away_id).size() != 22:
			errors.append("El primer partido de " + str(competition_id) + " no tiene dos equipos jugables.")
		else:
			var home_ids: Array[String] = PRE_MATCH.build_starting_eleven(registry.get_team_roster(home_id))
			var away_ids: Array[String] = PRE_MATCH.build_starting_eleven(registry.get_team_roster(away_id))
			var home_lineup := MATCH_11V11.build_lineup(home_id, true, home_ids)
			var away_lineup := MATCH_11V11.build_lineup(away_id, false, away_ids)
			if not MATCH_11V11.validate_lineups(home_lineup, away_lineup):
				errors.append("Partido 11 contra 11 inválido en " + str(competition_id))
			scheduled_competitions += 1

	if scheduled_competitions != registry.competitions_by_id.size():
		errors.append("Competiciones con calendario y primer partido validado: %d/%d" % [scheduled_competitions, registry.competitions_by_id.size()])
	if errors.is_empty():
		print("Ten base leagues playable: 725 clubs, 15,950 players, 22-player rosters, 725 valid starting elevens, and %d competitions with scheduled 11v11 fixtures." % scheduled_competitions)
		quit(0)
	else:
		for error in errors:
			push_error(str(error))
		quit(1)
