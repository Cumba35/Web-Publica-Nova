extends SceneTree

const Scheduler = preload("res://scripts/simulation/round_robin_scheduler.gd")
const Standings = preload("res://scripts/simulation/league_standings.gd")
const Simulator = preload("res://scripts/simulation/season_match_simulator.gd")
const Contract = preload("res://scripts/core/match_contract.gd")
const PlayerProfile = preload("res://scripts/data/player_profile.gd")
const TeamProfile = preload("res://scripts/data/team_profile.gd")
const Registry = preload("res://scripts/data/football_data_registry.gd")
const CubaImporter = preload("res://scripts/data/cuba_league_importer.gd")
const DataService = preload("res://scripts/data/football_data_service.gd")
const CompetitionRules = preload("res://scripts/simulation/competition_format_rules.gd")
const CommercialService = preload("res://scripts/manager/club_commercial_service.gd")

func _initialize() -> void:
	var failures := PackedStringArray()
	_test_scheduler(failures)
	_test_standings(failures)
	_test_match_reproducibility(failures)
	_test_profile_validation(failures)
	_test_cuba_catalog_import(failures)
	_test_data_service(failures)
	_test_competition_rules(failures)
	_test_commercial_economy(failures)
	if failures.is_empty():
		print("FUTBOL_NOVA_SHARED_FOUNDATION_TESTS: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_scheduler(failures: PackedStringArray) -> void:
	var fixtures := Scheduler.create_fixtures(["a", "b", "c", "d"], "league_1", "season_1", true)
	if fixtures.size() != 12:
		failures.append("Scheduler: 4 equipos ida/vuelta deben producir 12 partidos")
	var unique := {}
	for fixture in fixtures:
		if unique.has(fixture.fixture_id):
			failures.append("Scheduler: fixture_id duplicado")
		unique[fixture.fixture_id] = true

func _test_standings(failures: PackedStringArray) -> void:
	var table := Standings.create_table(["a", "b"])
	if not Standings.apply_result(table, {"home_team_id": "a", "away_team_id": "b", "home_goals": 2, "away_goals": 1}):
		failures.append("Standings: rechazó resultado válido")
	if int(table.a.points) != 3 or int(table.b.points) != 0:
		failures.append("Standings: puntos incorrectos tras victoria local")
	if int(table.a.head_to_head.b.points) != 3:
		failures.append("Standings: no registró el enfrentamiento directo")
	var tie_table := Standings.create_table(["x", "y", "z"])
	Standings.apply_result(tie_table, {"home_team_id": "x", "away_team_id": "y", "home_goals": 1, "away_goals": 0})
	Standings.apply_result(tie_table, {"home_team_id": "y", "away_team_id": "z", "home_goals": 1, "away_goals": 0})
	Standings.apply_result(tie_table, {"home_team_id": "z", "away_team_id": "x", "home_goals": 1, "away_goals": 0})
	var ordered := Standings.get_ordered_table(tie_table)
	if ordered.size() != 3 or str(ordered[0].team_id) != "x":
		failures.append("Standings: no resolvió la minitabla de empate")

func _test_match_reproducibility(failures: PackedStringArray) -> void:
	var fixture := {"fixture_id": "m1", "home_team_id": "a", "away_team_id": "b"}
	var home := {"id": "a", "strength": 62.0, "scorer_player_ids": ["a9"]}
	var away := {"id": "b", "strength": 55.0, "scorer_player_ids": ["b9"]}
	var first := Simulator.simulate(fixture, home, away, 20261114)
	var second := Simulator.simulate(fixture, home, away, 20261114)
	if first.is_empty() or second.is_empty():
		failures.append("Simulator: no generó resultado")
	elif first.home_goals != second.home_goals or first.away_goals != second.away_goals:
		failures.append("Simulator: la misma semilla no reproduce el marcador")
	if not Contract.validate_state(Contract.create_match("m1", "a", "b", 1)):
		failures.append("Contract: estado inicial no válido")

func _test_profile_validation(failures: PackedStringArray) -> void:
	var player := {"id": "p1", "display_name": "Jugador de prueba", "nationality_id": "CUB", "primary_position": "DC", "preferred_foot": "right", "attributes": {"pace": {"acceleration": 70, "sprint_speed": 72}}}
	if not PlayerProfile.is_valid(player):
		failures.append("PlayerProfile: rechazó un perfil válido")
	var team := {"id": "t1", "name": "Equipo de prueba", "country_id": "CUB", "player_ids": ["p1"]}
	if not TeamProfile.validate(team).is_empty():
		failures.append("TeamProfile: rechazó un equipo válido")

func _test_cuba_catalog_import(failures: PackedStringArray) -> void:
	var registry = Registry.new()
	var result: Dictionary = CubaImporter.import_into_registry(registry)
	if not bool(result.get("ok", false)):
		failures.append("Cuba importer: " + str(result.get("errors", [])))
	if int(result.get("team_count", 0)) != 52:
		failures.append("Cuba importer: se esperaban 52 clubes y se cargaron " + str(result.get("team_count", 0)))
	if int(result.get("competition_count", 0)) != 3:
		failures.append("Cuba importer: se esperaban 3 competiciones y se cargaron " + str(result.get("competition_count", 0)))

func _test_data_service(failures: PackedStringArray) -> void:
	var service = DataService.new()
	root.add_child(service)
	var summary: Dictionary = service.get_catalog_summary()
	if not bool(summary.get("initialized", false)):
		failures.append("DataService: no inicializó el catálogo offline")
	if not bool(summary.get("rules_loaded", false)):
		failures.append("DataService: no cargó el reglamento cubano")
	if service.get_fixtures("cuba_primera_division_nova").size() != 240:
		failures.append("DataService: Primera División debe tener 240 partidos de fase regular")
	var first_fixtures := service.get_fixtures("cuba_primera_division_nova")
	if first_fixtures.is_empty() or str(first_fixtures[0].get("official_ball_id", "")) != "nova_cuba_tropical":
		failures.append("DataService: el calendario oficial no asignó el balón de liga")
	for team_id in service.registry.teams_by_id:
		var team: Dictionary = service.registry.teams_by_id[team_id]
		var level := int(team.get("competition_level", 99))
		var academy: Dictionary = team.get("academy", {})
		if str(team_id).begins_with("CUB-") and level == 1 and not bool(academy.get("operational", false)):
			failures.append("DataService: club de Primera sin cantera inicial: " + str(team_id))
		if str(team_id).begins_with("CUB-") and level >= 2 and bool(academy.get("operational", false)):
			failures.append("DataService: club de división inferior inició con cantera: " + str(team_id))
	if service.get_fixtures("cuba_segunda_division_nova").size() != 240:
		failures.append("DataService: Segunda División debe tener 240 partidos de fase regular")
	if service.get_fixtures("cuba_tercera_division_nova_west").size() != 45:
		failures.append("DataService: Grupo Occidental de Tercera debe tener 45 partidos")
	if service.get_fixtures("cuba_tercera_division_nova_east").size() != 45:
		failures.append("DataService: Grupo Oriental de Tercera debe tener 45 partidos")
	var cuba_division_counts := {1: 0, 2: 0, 3: 0}
	for cuba_team_id in service.registry.teams_by_id:
		if str(cuba_team_id).begins_with("CUB-"):
			var division := int(service.registry.teams_by_id[cuba_team_id].get("division_level", 0))
			if cuba_division_counts.has(division):
				cuba_division_counts[division] += 1
	if cuba_division_counts != {1: 16, 2: 16, 3: 20}:
		failures.append("DataService: distribución cubana esperada 16/16/20, encontrada " + str(cuba_division_counts))
	var moved_clubs := {"CUB-S3-017": "Morón Deportivo", "CUB-S3-018": "Trinidad Colonial", "CUB-S3-019": "Baracoa FC", "CUB-S3-020": "Manzanillo Marítimo"}
	for moved_id in moved_clubs:
		if not service.registry.teams_by_id.has(moved_id) or str(service.registry.teams_by_id[moved_id].get("name", "")) != str(moved_clubs[moved_id]):
			failures.append("DataService: club regional transferido no está en Tercera: " + moved_id)
	var first_club_id := "CUB-S1-001"
	var first_kits := service.get_available_kits(first_club_id, 2026)
	if first_kits.has("third"):
		failures.append("DataService: tercera equipación desbloqueada sin contrato comercial")
	var first_roster: Array = service.registry.get_team_roster(first_club_id)
	if first_roster.is_empty() or not first_roster[0].has("economy"):
		failures.append("DataService: jugador generado de Primera sin valoración económica")
	if int(summary.get("teams", 0)) != 725:
		failures.append("DataService: se esperaban 52 clubes")
	if int(summary.get("players", 0)) != 15950:
		failures.append("DataService: se esperaban 1144 futbolistas en las 52 plantillas")
	if int(summary.get("teams_with_rosters", 0)) != 725:
		failures.append("DataService: se esperaban 52 plantillas completas")
	if int(summary.get("teams_missing_rosters", 0)) != 0:
		failures.append("DataService: quedaron clubes sin plantilla")
	for player_id in service.registry.players_by_id:
		var player: Dictionary = service.registry.players_by_id[player_id]
		var statistics: Dictionary = player.get("statistics", {})
		var career: Dictionary = statistics.get("career", {})
		if str(statistics.get("schema_version", "")) != "1.0.0" or int(career.get("appearances", -1)) != 0 or career.get("average_rating", 0.0) != null:
			failures.append("DataService: estadísticas comunes sin normalizar o no inicializadas para " + str(player_id))
	for team_id in service.registry.teams_by_id:
		var roster: Array = service.registry.get_team_roster(str(team_id))
		var level := int(service.registry.teams_by_id[team_id].get("competition_level", 99))
		if level >= 2 and roster.size() != 22:
			failures.append("DataService: plantilla incompleta en " + str(team_id))
		if level == 1 and roster.size() != 22:
			failures.append("DataService: plantilla de Primera incompleta: " + str(team_id))
	if int(summary.get("competitions", 0)) != 31:
		failures.append("DataService: se esperaban 3 competiciones")
	if int(summary.get("stages", 0)) != 40:
		failures.append("DataService: se esperaban 40 fases de liga con calendarios base y USA/Argentina")
	if int(summary.get("scheduled_matches", 0)) != 10965:
		failures.append("DataService: calendario total esperado de 10.965 partidos con calendarios USA/Argentina")
	var cup_calendar: Dictionary = service.build_copa_calendar()
	if not bool(cup_calendar.get("ok", false)) or int(cup_calendar.get("team_count", 0)) != 52:
		failures.append("DataService: no generó Copa de Cuba para los 52 clubes")
	if service.build_second_division_playoff().size() != 6:
		failures.append("DataService: no generó playoff de ascenso de Segunda")
	var third_promotion_playoff := service.build_third_division_promotion_playoff()
	if third_promotion_playoff.size() != 2 or int(third_promotion_playoff[0].get("leg", 0)) != 1 or int(third_promotion_playoff[1].get("leg", 0)) != 2:
		failures.append("DataService: no generó el playoff de ascenso de Tercera a doble partido")
	if service.build_supercopa_calendar([{"team_id": "a"}, {"team_id": "b"}, {"team_id": "c"}, {"team_id": "d"}], "a", "c").size() != 3:
		failures.append("DataService: no generó calendario de Supercopa")
	var persistent_stage := "database_integration_test_" + str(Time.get_ticks_usec())
	var team_ids: Array = service.registry.teams_by_id.keys()
	if team_ids.size() >= 2:
		var home_team_id := str(team_ids[0])
		var away_team_id := str(team_ids[1])
		var fixture := {
			"fixture_id": persistent_stage + "_match",
			"home_team_id": home_team_id,
			"away_team_id": away_team_id,
			"status": "scheduled"
		}
		service.fixtures_by_stage[persistent_stage] = [fixture]
		service.standings_by_stage[persistent_stage] = Standings.create_table([home_team_id, away_team_id])
		var simulated_result: Dictionary = service.simulate_fixture(persistent_stage, str(fixture.fixture_id), 20261114)
		if simulated_result.is_empty():
			failures.append("DataService: no simuló ni persistió el resultado del fixture")
		elif not FootballDatabase.has_match_result(str(simulated_result.get("match_id", ""))):
			failures.append("DataService: el resultado finalizado no llegó a FootballDatabase")
		elif service.simulate_fixture(persistent_stage, str(fixture.fixture_id), 20261114).size() > 0:
			failures.append("DataService: permitió simular dos veces el mismo fixture")
		var updated_table: Array = service.get_standings(persistent_stage)
		if updated_table.size() != 2 or int(updated_table[0].get("played", 0)) != 1 or int(updated_table[1].get("played", 0)) != 1:
			failures.append("DataService: la simulación no actualizó la clasificación de ambos clubes")
		var saved_lineups: Dictionary = simulated_result.get("lineups", {})
		if saved_lineups.get("home", []).size() != 11 or saved_lineups.get("away", []).size() != 11:
			failures.append("DataService: el partido simulado no registró once titulares por equipo.")
		else:
			for player_id in saved_lineups.home:
				var player_stats: Dictionary = service.registry.players_by_id[str(player_id)].get("statistics", {})
				if int(player_stats.get("career", {}).get("appearances", 0)) != 1 or int(player_stats.get("current_season", {}).get("minutes", 0)) != 90:
					failures.append("DataService: no actualizó estadísticas del titular " + str(player_id))
					break
		var rollover := service.start_next_season_for_stage(persistent_stage, "season_2", [home_team_id, away_team_id], true)
		if not bool(rollover.get("ok", false)) or int(rollover.get("fixture_count", 0)) != 2:
			failures.append("DataService: no inició una temporada nueva tras completar la fase.")
		else:
			var next_fixture: Dictionary = service.get_fixtures(persistent_stage)[0]
			var next_result: Dictionary = service.simulate_fixture(persistent_stage, str(next_fixture.fixture_id), 20261116)
			var saved_season: Dictionary = FootballDatabase.get_competition_state(persistent_stage)
			if next_result.is_empty() or str(saved_season.get("season_id", "")) != "season_2":
				failures.append("DataService: no persistió el resultado bajo el ID de la nueva temporada.")
		var round_stage := "simulation_round_test_" + str(Time.get_ticks_usec())
		var round_team_ids: Array = team_ids.slice(0, 4)
		service.fixtures_by_stage[round_stage] = Scheduler.create_fixtures(round_team_ids, round_stage, "season_1", false)
		service.standings_by_stage[round_stage] = Standings.create_table(round_team_ids)
		service.single_round_stages[round_stage] = true
		var round_result: Dictionary = service.simulate_round(round_stage, 1, 20261115)
		if not bool(round_result.get("ok", false)) or int(round_result.get("simulated", 0)) != 2:
			failures.append("DataService: no simuló todos los partidos de una jornada.")
		for row in service.get_standings(round_stage):
			if int(row.get("played", 0)) != 1:
				failures.append("DataService: la jornada simulada no actualizó a todos los participantes.")
	service.queue_free()

func _test_competition_rules(failures: PackedStringArray) -> void:
	var table := [
		{"team_id": "a"}, {"team_id": "b"}, {"team_id": "c"},
		{"team_id": "d"}, {"team_id": "e"}
	]
	var qualified := CompetitionRules.qualify_supercopa(table, "a", "c")
	if qualified.size() != 4 or qualified[0] != "a" or qualified[1] != "b" or qualified[2] != "c" or qualified[3] != "d":
		failures.append("CompetitionRules: clasificación Supercopa no eliminó duplicados o no completó plazas")
	var semifinal := CompetitionRules.create_semifinal_tie("a", "b")
	if int(semifinal.get("legs", 0)) != 2:
		failures.append("CompetitionRules: semifinal de Copa debe ser a doble partido")
	var supercopa_match := CompetitionRules.create_supercopa_match("a", "b", "semifinal")
	if bool(supercopa_match.get("extra_time", true)) or not bool(supercopa_match.get("penalties_if_draw", false)):
		failures.append("CompetitionRules: Supercopa debe ir directamente a penaltis tras empate")

func _test_commercial_economy(failures: PackedStringArray) -> void:
	var club := {
		"division_level": 1,
		"commercial_contracts": {
			"third_kit": {
				"status": "active",
				"start_season": 2026,
				"end_season": 2027,
				"design_rights": true,
				"sponsor_mark_rights": true,
				"approved_original_design": true
			}
		}
	}
	if not CommercialService.can_use_third_kit(club, 2026):
		failures.append("CommercialService: no desbloqueó tercera equipación con contrato válido")
	if CommercialService.can_use_third_kit(club, 2028):
		failures.append("CommercialService: mantuvo tercera equipación tras expirar el contrato")
	var kits := CommercialService.get_available_kits(club, 2026)
	if not kits.has("third"):
		failures.append("CommercialService: no incluyó tercera equipación en el selector")
	club["division_level"] = 2
	if CommercialService.can_use_third_kit(club, 2026):
		failures.append("CommercialService: permitió tercera equipación fuera de Primera")
	var value := CommercialService.estimate_player_market_value_eur({"estimated_overall": 70, "potential": 82, "age": 21, "position": "DC"}, 1)
	if value <= 0:
		failures.append("CommercialService: estimación de valor de jugador no válida")
	var fee := CommercialService.estimate_transfer_fee_eur(value, 1.2)
	if fee <= value:
		failures.append("CommercialService: no calculó precio negociado con factor superior a 1")
