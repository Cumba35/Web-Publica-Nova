extends Node
class_name NovaFootballDataService

signal catalog_loaded(summary: Dictionary)
signal catalog_error(messages: PackedStringArray)
signal draw_ceremony_requested(competition_name: String, draw_result: Array)

const REGISTRY_SCRIPT = preload("res://scripts/data/football_data_registry.gd")
const CUBA_IMPORTER = preload("res://scripts/data/cuba_league_importer.gd")
const GLOBAL_IMPORTER = preload("res://scripts/data/global_league_importer.gd")
const MASTER_CATALOG_IMPORTER = preload("res://scripts/data/master_catalog_importer.gd")
const DOWNLOADED_LEAGUE_IMPORTER = preload("res://scripts/data/downloaded_league_importer.gd")
const DOWNLOADED_NATIONAL_IMPORTER = preload("res://scripts/data/downloaded_national_teams_importer.gd")
const CUBA_ROSTER_IMPORTER = preload("res://scripts/data/cuba_roster_importer.gd")
const USA_LEAGUE_IMPORTER = preload("res://scripts/data/usa_league_importer.gd")
const BASE_LEAGUE_IMPORTER = preload("res://scripts/data/base_league_importer.gd")
const BASE_ROSTER_IMPORTER = preload("res://scripts/data/base_league_roster_importer.gd")
const SCHEDULER = preload("res://scripts/simulation/round_robin_scheduler.gd")
const PRE_MATCH_SETUP = preload("res://scripts/ui/pre_match_setup.gd")
const STANDINGS = preload("res://scripts/simulation/league_standings.gd")
const COMPETITION_RULES = preload("res://scripts/simulation/competition_format_rules.gd")
const LEAGUE_BALLS = preload("res://scripts/competitions/league_ball_service.gd")
const ACADEMY_SERVICE = preload("res://scripts/manager/club_academy_service.gd")
const COMMERCIAL_SERVICE = preload("res://scripts/manager/club_commercial_service.gd")
const BOARD_OBJECTIVES = preload("res://scripts/manager/board_objectives_service.gd")
const CALENDAR_BUILDER = preload("res://scripts/simulation/competition_calendar_builder.gd")
const CARIBBEAN_CHAMPIONS_ENGINE = preload("res://scripts/simulation/caribbean_champions_league_engine.gd")
const AMERICAN_REGIONAL_CHAMPIONS_ENGINE = preload("res://scripts/simulation/american_regional_champions_engine.gd")
const MATCH_SIMULATOR = preload("res://scripts/simulation/season_match_simulator.gd")
const TAS_MATCH_DECISION_ENGINE = preload("res://scripts/simulation/tas_match_decision_engine.gd")
const TAS_COMPETITION_ENGINE = preload("res://scripts/simulation/tas_competition_engine.gd")
const PLAYER_STATISTICS = preload("res://scripts/data/player_statistics_service.gd")
const SEASON_PROGRESSION = preload("res://scripts/data/season_progression_service.gd")
const INTERNATIONAL_CLUB_CATALOG_PATH := "res://data/international_club_competitions.json"
const NATIONAL_ASSOCIATION_DIRECTORY_PATH := "res://data/national_association_directory.json"
const DOWNLOAD_RECOMMENDATIONS = preload("res://scripts/data/download_recommendation_service.gd")

var registry
var fixtures_by_stage: Dictionary = {}
var standings_by_stage: Dictionary = {}
var single_round_stages: Dictionary = {}
var tas_editions_by_season: Dictionary = {}
var initialized := false
var initialization_errors := PackedStringArray()
var initialization_failed := false
var competition_rules: Dictionary = {}
var league_ball_catalog: Dictionary = {}
var academy_rules: Dictionary = {}
var roster_import_summary: Dictionary = {}
var first_division_roster_summary: Dictionary = {}
var usa_import_summary: Dictionary = {}
var base_league_import_summary: Dictionary = {}
var base_roster_import_summary: Dictionary = {}
var global_import_summary: Dictionary = {}
var downloaded_import_summary: Dictionary = {}
var downloaded_national_summary: Dictionary = {}
var national_teams_by_id: Dictionary = {}
var national_players_by_id: Dictionary = {}
var national_associations: Array = []

func _ready() -> void:
	initialize_catalog()

func initialize_catalog() -> bool:
	initialized = false
	initialization_failed = false
	initialization_errors.clear()
	national_associations = _load_national_association_directory()
	registry = REGISTRY_SCRIPT.new()
	fixtures_by_stage.clear()
	standings_by_stage.clear()
	single_round_stages.clear()
	tas_editions_by_season.clear()
	competition_rules = COMPETITION_RULES.load_rules()
	league_ball_catalog = LEAGUE_BALLS.load_catalog()
	academy_rules = ACADEMY_SERVICE.load_rules()
	if competition_rules.is_empty():
		initialization_failed = true
		initialization_errors.append("No se pudo cargar data/cuban_competition_rules.json")
	var imported: Dictionary = CUBA_IMPORTER.import_into_registry(registry)
	if not bool(imported.get("ok", false)):
		initialization_failed = true
		for error in imported.get("errors", []):
			initialization_errors.append(str(error))
		catalog_error.emit(initialization_errors)
		return false
	roster_import_summary = CUBA_ROSTER_IMPORTER.import_into_registry(registry)
	if not bool(roster_import_summary.get("ok", false)):
		initialization_failed = true
		for error in roster_import_summary.get("errors", []):
			initialization_errors.append(str(error))
	first_division_roster_summary = {"players_added": int(roster_import_summary.get("players_by_division", {}).get(1, 0)), "teams_completed": int(roster_import_summary.get("teams_by_division", {}).get(1, 0)), "source": "data/players/cuba_first_division.json"}
	global_import_summary = GLOBAL_IMPORTER.import_into_registry(registry)
	if not bool(global_import_summary.get("ok", false)):
		initialization_failed = true
		for error in global_import_summary.get("errors", []):
			initialization_errors.append(str(error))
	usa_import_summary = USA_LEAGUE_IMPORTER.import_into_registry(registry)
	if not bool(usa_import_summary.get("ok", false)):
		initialization_failed = true
		for error in usa_import_summary.get("errors", []):
			initialization_errors.append("Ligas USA: " + str(error))
	base_league_import_summary = BASE_LEAGUE_IMPORTER.import_into_registry(registry)
	if not bool(base_league_import_summary.get("ok", false)):
		initialization_failed = true
		for error in base_league_import_summary.get("errors", []):
			initialization_errors.append("Ligas base: " + str(error))
	base_roster_import_summary = BASE_ROSTER_IMPORTER.import_into_registry(registry)
	if not bool(base_roster_import_summary.get("ok", false)):
		initialization_failed = true
		for error in base_roster_import_summary.get("errors", []):
			initialization_errors.append("Plantillas base guardadas: " + str(error))
	if not registry.validate_team_rosters(22):
		initialization_failed = true
		for error in registry.last_errors:
			initialization_errors.append("Validación final de plantillas: " + str(error))
	for team_id in registry.teams_by_id:
		var team_roster: Array = registry.get_team_roster(str(team_id))
		var starting_eleven: Array[String] = PRE_MATCH_SETUP.build_starting_eleven(team_roster)
		if team_roster.size() != 22 or starting_eleven.size() != 11:
			initialization_failed = true
			initialization_errors.append("Club no apto para jugar: %s (plantilla %d/22, once inicial %d/11)." % [str(team_id), team_roster.size(), starting_eleven.size()])
	if registry.teams_by_id.size() != 725:
		initialization_failed = true
		initialization_errors.append("Se esperaban 725 clubes base; encontrados " + str(registry.teams_by_id.size()))
	if registry.players_by_id.size() != 15950:
		initialization_failed = true
		initialization_errors.append("Se esperaban 15.950 perfiles de jugadores base; encontrados " + str(registry.players_by_id.size()))
	var installed_packages: Dictionary = ContentPackages.get_installed_packages()
	downloaded_import_summary = DOWNLOADED_LEAGUE_IMPORTER.import_installed_packages(registry, installed_packages)
	downloaded_national_summary = DOWNLOADED_NATIONAL_IMPORTER.load_installed_packages(installed_packages)
	national_teams_by_id = downloaded_national_summary.get("national_teams_by_id", {}).duplicate(true)
	national_players_by_id = downloaded_national_summary.get("players_by_id", {}).duplicate(true)
	if not bool(downloaded_national_summary.get("ok", true)):
		for error in downloaded_national_summary.get("errors", []):
			initialization_errors.append("Selecciones descargadas: " + str(error))
	if not bool(downloaded_import_summary.get("ok", true)):
		for error in downloaded_import_summary.get("errors", []):
			initialization_errors.append("Contenido descargado: " + str(error))
	for competition_id in registry.competitions_by_id:
		var competition: Dictionary = registry.competitions_by_id[competition_id]
		var format_id := str(competition.get("format", ""))
		if format_id == "custom_schedule_pending":
			# The official calendar is not imported yet. Keep the competition playable
			# with a clearly labelled, deterministic in-game single round robin.
			# This is a game calendar, not a claim that it matches the federation schedule.
			_build_stage(str(competition_id), str(competition_id), competition.team_ids, false)
		elif format_id == "two_regional_groups" or format_id == "grouped_league" or format_id == "two_groups_double_round_robin":
			_build_group_stages(str(competition_id), competition, format_id == "two_groups_double_round_robin")
		else:
			_build_stage(str(competition_id), str(competition_id), competition.team_ids, true)
		var saved_stage: Dictionary = FootballDatabase.get_competition_state(str(competition_id))
		if not saved_stage.is_empty() and saved_stage.get("fixtures", []) is Array and saved_stage.get("standings", {}) is Dictionary:
			fixtures_by_stage[str(competition_id)] = saved_stage.fixtures.duplicate(true)
			standings_by_stage[str(competition_id)] = saved_stage.standings.duplicate(true)
		for group_id in fixtures_by_stage.keys():
			if str(group_id).begins_with(str(competition_id) + "_") and str(group_id) != str(competition_id):
				var saved_group: Dictionary = FootballDatabase.get_competition_state(str(group_id))
				if not saved_group.is_empty() and saved_group.get("fixtures", []) is Array and saved_group.get("standings", {}) is Dictionary:
					fixtures_by_stage[str(group_id)] = saved_group.fixtures.duplicate(true)
					standings_by_stage[str(group_id)] = saved_group.standings.duplicate(true)
	var catalog_saved := FootballDatabase.save_catalog_snapshot(registry.export_catalog_snapshot())
	if not catalog_saved:
		initialization_failed = true
		initialization_errors.append("Base de datos: " + FootballDatabase.last_error)
	var master_result: Dictionary = MASTER_CATALOG_IMPORTER.build_catalog(registry)
	if bool(master_result.get("ok", false)):
		var master_catalog: Dictionary = master_result.catalog
		for national_team_id in national_teams_by_id:
			master_catalog["national_teams"].append(national_teams_by_id[national_team_id].duplicate(true))
		for national_player_id in national_players_by_id:
			master_catalog["national_players"].append(national_players_by_id[national_player_id].duplicate(true))
		if not FootballDatabase.save_master_catalog(master_catalog):
			initialization_failed = true
			initialization_errors.append("Catálogo maestro: " + FootballDatabase.last_error)
	else:
		initialization_failed = true
		for error in master_result.get("errors", []):
			initialization_errors.append("Catálogo maestro: " + str(error))
	initialized = not initialization_failed
	var summary := get_catalog_summary()
	if initialized:
		catalog_loaded.emit(summary)
	else:
		catalog_error.emit(initialization_errors)
	return initialized

func _build_group_stages(competition_id: String, competition: Dictionary, double_round_robin: bool = false) -> void:
	var grouped: Dictionary = {}
	for team_id in competition.team_ids:
		var team: Dictionary = registry.teams_by_id[str(team_id)]
		var group_id := str(team.get("group_id", ""))
		if group_id.is_empty():
			group_id = "ungrouped"
		if not grouped.has(group_id):
			grouped[group_id] = []
		grouped[group_id].append(str(team_id))
	for group_id in grouped:
		var stage_id := competition_id + "_" + str(group_id)
		_build_stage(stage_id, competition_id, grouped[group_id], double_round_robin)

func _build_stage(stage_id: String, competition_id: String, team_ids: Array, double_round_robin: bool) -> void:
	var fixtures: Array = SCHEDULER.create_fixtures(team_ids, stage_id, "season_1", double_round_robin)
	var competition: Dictionary = registry.competitions_by_id.get(competition_id, {})
	var country_id := str(competition.get("country_id", ""))
	var league_system_id := "cuba_national_league" if country_id == "CUB" else competition_id
	var official_ball := LEAGUE_BALLS.get_official_ball(league_system_id, league_ball_catalog)
	for fixture in fixtures:
		fixture["league_system_id"] = league_system_id
		fixture["official_ball_id"] = str(official_ball.get("id", ""))
		fixture["official_ball_asset_id"] = str(official_ball.get("asset_id", ""))
		fixture["calendar_type"] = "generated_single_round_robin" if not double_round_robin else "double_round_robin"
		fixture["official_calendar_verified"] = false
	fixtures_by_stage[stage_id] = fixtures
	standings_by_stage[stage_id] = STANDINGS.create_table(team_ids)
	single_round_stages[stage_id] = not double_round_robin

func get_database_summary() -> Dictionary:
	return FootballDatabase.get_summary()

func get_master_clubs_by_country(country_id: String) -> Array:
	var result: Array = []
	for club in FootballDatabase.database.get("master_catalog", {}).get("clubs", []):
		if str(club.get("country_id", "")) == country_id:
			result.append(club.duplicate(true))
	return result

func get_catalog_summary() -> Dictionary:
	var total_fixtures := 0
	for stage_id in fixtures_by_stage:
		total_fixtures += fixtures_by_stage[stage_id].size()
	return {
		"initialized": initialized,
		"database": FootballDatabase.get_summary(),
		"players": registry.players_by_id.size() if registry != null else 0,
		"teams_with_rosters": _count_teams_with_full_rosters(),
		"teams_missing_rosters": registry.teams_by_id.size() - _count_teams_with_full_rosters() if registry != null else 0,
		"first_division_players_imported": int(first_division_roster_summary.get("players_added", 0)),
		"first_division_teams_loaded": int(first_division_roster_summary.get("teams_completed", 0)),
		"roster_import_ok": bool(roster_import_summary.get("ok", false)),
		"global_import_ok": bool(global_import_summary.get("ok", false)),
		"global_clubs_added": int(global_import_summary.get("clubs_added", 0)),
		"global_players_added": int(global_import_summary.get("players_added", 0)),
		"downloaded_packages_imported": int(downloaded_import_summary.get("packages_imported", 0)),
		"downloaded_clubs_added": int(downloaded_import_summary.get("teams_added", 0)),
		"downloaded_players_added": int(downloaded_import_summary.get("players_added", 0)),
		"downloaded_competitions_added": int(downloaded_import_summary.get("competitions_added", 0)),
		"downloaded_national_packages_imported": int(downloaded_national_summary.get("packages_imported", 0)),
		"downloaded_national_teams": national_teams_by_id.size(),
		"fifa_member_associations_catalogued": national_associations.size(),
		"national_team_roster_packages_available": int(downloaded_national_summary.get("packages_imported", 0)),
		"teams": registry.teams_by_id.size() if registry != null else 0,
		"competitions": registry.competitions_by_id.size() if registry != null else 0,
		"stages": fixtures_by_stage.size(),
		"scheduled_matches": total_fixtures,
		"rules_loaded": not competition_rules.is_empty(),
		"errors": initialization_errors.duplicate()
	}

func get_fixtures(stage_id: String) -> Array:
	return fixtures_by_stage.get(stage_id, []).duplicate(true)

func get_standings(stage_id: String) -> Array:
	if not standings_by_stage.has(stage_id):
		return []
	return STANDINGS.get_ordered_table(standings_by_stage[stage_id], bool(single_round_stages.get(stage_id, false)))

# Simula y persiste un partido de liga completo. Solo acepta fixtures pendientes
# que pertenezcan a la fase solicitada.
func simulate_fixture(stage_id: String, fixture_id: String, seed: int = 0) -> Dictionary:
	if fixture_id.is_empty() or not fixtures_by_stage.has(stage_id) or registry == null:
		return {}
	var selected_fixture: Dictionary = {}
	for fixture in fixtures_by_stage[stage_id]:
		if str(fixture.get("fixture_id", "")) == fixture_id:
			selected_fixture = fixture
			break
	if selected_fixture.is_empty() or str(selected_fixture.get("status", "scheduled")) == "finished":
		return {}
	var home_id := str(selected_fixture.get("home_team_id", ""))
	var away_id := str(selected_fixture.get("away_team_id", ""))
	if not registry.teams_by_id.has(home_id) or not registry.teams_by_id.has(away_id):
		return {}
	var home_team := _build_simulation_team(home_id)
	var away_team := _build_simulation_team(away_id)
	var resolved_seed := seed
	if resolved_seed <= 0:
		resolved_seed = absi(hash(fixture_id))
	var result: Dictionary = MATCH_SIMULATOR.simulate(selected_fixture, home_team, away_team, resolved_seed)
	if result.is_empty() or not apply_match_result(stage_id, result):
		return {}
	return result

func simulate_round(stage_id: String, round_number: int, seed: int = 0) -> Dictionary:
	if not fixtures_by_stage.has(stage_id) or round_number < 1:
		return {"ok": false, "simulated": 0, "results": [], "error": "Fase o jornada no válida."}
	var results: Array = []
	var fixture_ids: Array[String] = []
	for fixture in fixtures_by_stage[stage_id]:
		if int(fixture.get("round", 0)) == round_number and str(fixture.get("status", "scheduled")) != "finished":
			fixture_ids.append(str(fixture.get("fixture_id", "")))
	for index in range(fixture_ids.size()):
		var fixture_seed := seed + index if seed > 0 else 0
		var result := simulate_fixture(stage_id, fixture_ids[index], fixture_seed)
		if result.is_empty():
			return {"ok": false, "simulated": results.size(), "results": results, "error": "No se pudo finalizar el fixture " + fixture_ids[index]}
		results.append(result)
	return {"ok": not results.is_empty(), "simulated": results.size(), "results": results, "error": "" if not results.is_empty() else "La jornada no tiene partidos pendientes."}

func _build_simulation_team(team_id: String) -> Dictionary:
	var team: Dictionary = registry.teams_by_id.get(team_id, {}).duplicate(true)
	var roster: Array = registry.get_team_roster(team_id)
	var total_overall := 0.0
	var scorer_ids: Array[String] = []
	var starting_ids: Array[String] = []
	var counted := 0
	for player in roster:
		if not player is Dictionary:
			continue
		var overall := float(player.get("estimated_overall", player.get("overall", 50.0)))
		total_overall += clampf(overall, 1.0, 99.0)
		counted += 1
		var player_id := str(player.get("id", ""))
		if starting_ids.size() < 11 and not player_id.is_empty():
			starting_ids.append(player_id)
		var position := str(player.get("primary_position", player.get("position", ""))).to_upper()
		if position not in ["POR", "GK", "G"] and not player_id.is_empty() and starting_ids.has(player_id):
			scorer_ids.append(player_id)
	team["strength"] = total_overall / float(counted) if counted > 0 else float(team.get("strength", 50.0))
	team["scorer_player_ids"] = scorer_ids
	team["starting_player_ids"] = starting_ids
	return team

func apply_match_result(stage_id: String, result: Dictionary) -> bool:
	if not standings_by_stage.has(stage_id) or not fixtures_by_stage.has(stage_id):
		return false
	var match_id := str(result.get("match_id", result.get("fixture_id", "")))
	if match_id.is_empty() or FootballDatabase.has_match_result(match_id):
		return false
	var standings_snapshot: Dictionary = standings_by_stage[stage_id].duplicate(true)
	var fixtures_snapshot: Array = fixtures_by_stage[stage_id].duplicate(true)
	var result_season_id := "season_1"
	if not STANDINGS.apply_result(standings_by_stage[stage_id], result):
		return false
	var fixture_found := false
	for index in range(fixtures_by_stage[stage_id].size()):
		var fixture: Dictionary = fixtures_by_stage[stage_id][index]
		if str(fixture.get("fixture_id", "")) == match_id:
			if str(fixture.get("home_team_id", "")) != str(result.get("home_team_id", "")) or str(fixture.get("away_team_id", "")) != str(result.get("away_team_id", "")):
				standings_by_stage[stage_id] = standings_snapshot
				fixtures_by_stage[stage_id] = fixtures_snapshot
				return false
			result_season_id = str(fixture.get("season_id", "season_1"))
			fixture["status"] = "finished"
			fixture["home_goals"] = int(result.get("home_goals", 0))
			fixture["away_goals"] = int(result.get("away_goals", 0))
			fixtures_by_stage[stage_id][index] = fixture
			fixture_found = true
			break
	if not fixture_found:
		standings_by_stage[stage_id] = standings_snapshot
		fixtures_by_stage[stage_id] = fixtures_snapshot
		return false
	var previous_players: Dictionary = registry.players_by_id.duplicate(true)
	var has_lineups := result.has("lineups")
	var statistics_result: Dictionary = PLAYER_STATISTICS.record_match(registry.players_by_id, result) if has_lineups else {"ok": false}
	if has_lineups and not bool(statistics_result.get("ok", false)):
		standings_by_stage[stage_id] = standings_snapshot
		fixtures_by_stage[stage_id] = fixtures_snapshot
		return false
	if bool(statistics_result.get("ok", false)):
		registry.players_by_id = statistics_result.players
		if not FootballDatabase.save_catalog_snapshot(registry.export_catalog_snapshot()):
			registry.players_by_id = previous_players
			standings_by_stage[stage_id] = standings_snapshot
			fixtures_by_stage[stage_id] = fixtures_snapshot
			return false
	var committed := FootballDatabase.commit_match_and_competition_state(stage_id, result_season_id, result, fixtures_by_stage[stage_id], standings_by_stage[stage_id])
	if not committed:
		registry.players_by_id = previous_players
		if bool(statistics_result.get("ok", false)):
			FootballDatabase.save_catalog_snapshot(registry.export_catalog_snapshot())
		standings_by_stage[stage_id] = standings_snapshot
		fixtures_by_stage[stage_id] = fixtures_snapshot
		return false
	return true

func get_competition_rules(competition_id: String) -> Dictionary:
	for league in competition_rules.get("leagues", []):
		if str(league.get("competition_id", "")) == competition_id:
			return league.duplicate(true)
	return {}

func get_cup_rules() -> Dictionary:
	return competition_rules.get("cup", {}).duplicate(true)

func get_supercopa_rules() -> Dictionary:
	return competition_rules.get("supercup", {}).duplicate(true)


func get_match_ball(league_id: String, competition_type: String, is_official: bool, selected_ball_id: String = "") -> Dictionary:
	return LEAGUE_BALLS.resolve_match_ball(league_id, competition_type, is_official, selected_ball_id, league_ball_catalog)

func get_initial_academy_state(division_level: int) -> Dictionary:
	return ACADEMY_SERVICE.initial_state(division_level, academy_rules)

func request_academy_activation(division_level: int, finances: Dictionary, compliance: Dictionary) -> Dictionary:
	return ACADEMY_SERVICE.activate_academy(division_level, finances, compliance, academy_rules)

func get_default_board_objectives() -> Array:
	return BOARD_OBJECTIVES.create_default_objectives()

func update_board_objectives(objectives: Array, match_data: Dictionary) -> Array:
	return BOARD_OBJECTIVES.evaluate_match(objectives, match_data)

func build_copa_calendar(season_id: String = "season_1") -> Dictionary:
	var records: Array = []
	if registry == null:
		return {"ok": false, "rounds": [], "errors": ["Catálogo deportivo no inicializado"]}
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		records.append({"id": str(team_id), "division_level": int(team.get("competition_level", 99))})
	var result: Dictionary = CALENDAR_BUILDER.build_copa_de_cuba(records, "copa_de_cuba_nova", season_id)
	if bool(result.get("ok", false)):
		var presentation: Array = []
		for round_data in result.get("rounds", []):
			for fixture in round_data.get("ties", []):
				presentation.append({
					"team_id": str(fixture.get("home_team_id", "")),
					"opponent_team_id": str(fixture.get("away_team_id", "")),
					"round": str(round_data.get("round_id", ""))
				})
		_emit_competition_draw("Copa de Cuba", presentation)
	return result

func build_second_division_playoff(season_id: String = "season_1") -> Array:
	var table := get_standings("cuba_segunda_division_nova")
	var ordered: Array = []
	for row in table:
		ordered.append(str(row.get("team_id", "")))
	var fixtures: Array = CALENDAR_BUILDER.build_second_division_playoff(ordered, "cuba_segunda_division_nova", season_id)
	_emit_competition_draw("Playoff de ascenso · Segunda División", _fixtures_to_draw_presentation(fixtures))
	return fixtures

func build_third_division_promotion_playoff(season_id: String = "season_1") -> Array:
	var west := get_standings("cuba_tercera_division_nova_west")
	var east := get_standings("cuba_tercera_division_nova_east")
	var west_ids: Array = []
	var east_ids: Array = []
	for row in west:
		west_ids.append(str(row.get("team_id", "")))
	for row in east:
		east_ids.append(str(row.get("team_id", "")))
	var fixtures: Array = CALENDAR_BUILDER.build_third_division_promotion_playoff(west_ids, east_ids, "cuba_tercera_division_nova", season_id)
	_emit_competition_draw("Playoff de ascenso · Tercera División", _fixtures_to_draw_presentation(fixtures))
	return fixtures

func build_third_division_final_four(season_id: String = "season_1") -> Array:
	return build_third_division_promotion_playoff(season_id)

func build_supercopa_calendar(league_table: Array, cup_champion: String, cup_runner_up: String, season_id: String = "season_1", semifinal_pairs: Array = []) -> Array:
	var qualified := COMPETITION_RULES.qualify_supercopa(league_table, cup_champion, cup_runner_up)
	var fixtures: Array = CALENDAR_BUILDER.build_supercopa_final_four(qualified, semifinal_pairs, "supercopa_de_cuba_nova", season_id)
	_emit_competition_draw("Supercopa de Cuba", _fixtures_to_draw_presentation(fixtures))
	return fixtures

func get_international_club_competitions() -> Array:
	if not FileAccess.file_exists(INTERNATIONAL_CLUB_CATALOG_PATH):
		return []
	var file := FileAccess.open(INTERNATIONAL_CLUB_CATALOG_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return []
	return parsed.get("competitions", []).duplicate(true)

func _count_teams_with_full_rosters() -> int:
	if registry == null:
		return 0
	var count := 0
	for team_id in registry.teams_by_id:
		if registry.teams_by_id[team_id].get("player_ids", []).size() == 22:
			count += 1
	return count

func get_available_kits(team_id: String, season: int) -> Array[String]:
	if registry == null or not registry.teams_by_id.has(team_id):
		return ["home", "away", "goalkeeper"]
	return COMMERCIAL_SERVICE.get_available_kits(registry.teams_by_id[team_id], season)

func estimate_player_market_value(player: Dictionary, division_level: int = 1) -> int:
	return COMMERCIAL_SERVICE.estimate_player_market_value_eur(player, division_level)

func get_team_commercial_contract(team_id: String, contract_type: String = "third_kit") -> Dictionary:
	if registry == null or not registry.teams_by_id.has(team_id):
		return {}
	var team: Dictionary = registry.teams_by_id[team_id]
	var contracts: Dictionary = team.get("commercial_contracts", {})
	return contracts.get(contract_type, {}).duplicate(true) if contracts.get(contract_type, {}) is Dictionary else {}


func get_download_recommendations() -> Dictionary:
	return DOWNLOAD_RECOMMENDATIONS.get_startup_recommendations()

 
func get_installed_content_packages() -> Dictionary:
	return ContentPackages.get_installed_packages()

func get_downloaded_content_import_summary() -> Dictionary:
	return downloaded_import_summary.duplicate(true)

func is_downloaded_league_package_installed(package_id: String) -> bool:
	return ContentPackages.is_package_installed(package_id)

 
func get_downloaded_national_teams() -> Array:
	var result: Array = []
	for team_id in national_teams_by_id:
		result.append(national_teams_by_id[team_id].duplicate(true))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("name", "")) < str(b.get("name", "")))
	return result

func get_downloaded_national_team_roster(team_id: String) -> Array:
	var result: Array = []
	if not national_teams_by_id.has(team_id):
		return result
	for player_id in national_teams_by_id[team_id].get("player_ids", []):
		if national_players_by_id.has(str(player_id)):
			result.append(national_players_by_id[str(player_id)].duplicate(true))
	return result

func get_downloaded_national_import_summary() -> Dictionary:
	return downloaded_national_summary.duplicate(true)

 
func _load_national_association_directory() -> Array:
	if not FileAccess.file_exists(NATIONAL_ASSOCIATION_DIRECTORY_PATH):
		initialization_errors.append("No se encontró el directorio de asociaciones FIFA.")
		return []
	var file := FileAccess.open(NATIONAL_ASSOCIATION_DIRECTORY_PATH, FileAccess.READ)
	if file == null:
		initialization_errors.append("No se pudo abrir el directorio de asociaciones FIFA.")
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.get("associations", []) is Array:
		initialization_errors.append("El directorio de asociaciones FIFA tiene un formato inválido.")
		return []
	return parsed.get("associations", []).duplicate(true)

func get_national_association_directory() -> Array:
	return national_associations.duplicate(true)

func get_national_associations_by_confederation(confederation_code: String) -> Array:
	var result: Array = []
	for association in national_associations:
		if str(association.get("confederation_code", "")) == confederation_code:
			result.append(association.duplicate(true))
	return result

func get_national_association_roster_status(association_id: String) -> Dictionary:
	for association in national_associations:
		if str(association.get("association_id", "")) == association_id:
			return {
				"association": association.duplicate(true),
				"playable": false,
				"roster_available": false,
				"note": "La asociación está catalogada; el equipo nacional será jugable cuando se publique su plantilla verificada."
			}
	return {}


func _has_national_team_for_association(association_code: String) -> bool:
	for team_id in national_teams_by_id:
		if str(national_teams_by_id[team_id].get("association_code", "")) == association_code:
			return true
	return false


# Devuelve un plan auditable de movimientos. Solo se ejecuta si el juego aporta
# jerarquía y reglas explícitas; nunca conecta sistemas cerrados por inferencia.
func build_promotion_relegation_plan(league_order: Array, standings_by_competition: Dictionary, rules_by_competition: Dictionary) -> Dictionary:
	return SEASON_PROGRESSION.build_promotion_relegation_plan(league_order, standings_by_competition, rules_by_competition)

# Aplica únicamente movimientos previamente calculados y validados por las reglas.
# Actualiza a la vez las listas de ambas competiciones y el nivel del club.
func apply_promotion_relegation_plan(moves: Array) -> Dictionary:
	if registry == null or moves.is_empty():
		return {"ok": false, "error": "No hay registro o movimientos que aplicar."}
	var previous_teams: Dictionary = registry.teams_by_id.duplicate(true)
	var previous_competitions: Dictionary = registry.competitions_by_id.duplicate(true)
	var moved_ids := {}
	for move in moves:
		var team_id := str(move.get("team_id", ""))
		var from_id := str(move.get("from_competition_id", ""))
		var to_id := str(move.get("to_competition_id", ""))
		if team_id.is_empty() or from_id.is_empty() or to_id.is_empty() or moved_ids.has(team_id):
			return {"ok": false, "error": "Movimiento vacío o repetido."}
		if not registry.teams_by_id.has(team_id) or not registry.competitions_by_id.has(from_id) or not registry.competitions_by_id.has(to_id):
			return {"ok": false, "error": "Club o competición inexistente en el movimiento de " + team_id + "."}
		var from_comp: Dictionary = registry.competitions_by_id[from_id]
		var to_comp: Dictionary = registry.competitions_by_id[to_id]
		if str(from_comp.get("country_id", "")) != str(to_comp.get("country_id", "")):
			return {"ok": false, "error": "No se permite trasladar un club entre países distintos."}
		if not from_comp.team_ids.has(team_id) or to_comp.team_ids.has(team_id):
			return {"ok": false, "error": "La afiliación actual no coincide para " + team_id + "."}
		moved_ids[team_id] = true
	for move in moves:
		var team_id := str(move.team_id)
		var from_id := str(move.from_competition_id)
		var to_id := str(move.to_competition_id)
		var from_comp: Dictionary = registry.competitions_by_id[from_id]
		var to_comp: Dictionary = registry.competitions_by_id[to_id]
		from_comp.team_ids.erase(team_id)
		to_comp.team_ids.append(team_id)
		registry.competitions_by_id[from_id] = from_comp
		registry.competitions_by_id[to_id] = to_comp
		var team: Dictionary = registry.teams_by_id[team_id]
		team["competition_id"] = to_id
		var target_level := int(to_comp.get("level", team.get("division_level", 1)))
		team["competition_level"] = target_level
		team["division_level"] = target_level
		registry.teams_by_id[team_id] = team
	if not FootballDatabase.save_catalog_snapshot(registry.export_catalog_snapshot()):
		registry.teams_by_id = previous_teams
		registry.competitions_by_id = previous_competitions
		return {"ok": false, "error": "No se pudieron guardar los ascensos y descensos: " + FootballDatabase.last_error}
	return {"ok": true, "moved_clubs": moved_ids.size(), "moves": moves.duplicate(true)}

# Inicia una nueva edición de una fase ya terminada, manteniendo los participantes
# actuales. Los movimientos de división deben resolverse antes con un plan explícito.
func start_next_season_for_stage(stage_id: String, next_season_id: String, team_ids: Array, double_round_robin: bool) -> Dictionary:
	if not fixtures_by_stage.has(stage_id) or not standings_by_stage.has(stage_id):
		return {"ok": false, "error": "La fase no existe."}
	for fixture in fixtures_by_stage[stage_id]:
		if str(fixture.get("status", "scheduled")) != "finished":
			return {"ok": false, "error": "No se puede cerrar una temporada con partidos pendientes."}
	var generated: Dictionary = SEASON_PROGRESSION.build_next_season_fixtures(team_ids, stage_id, next_season_id, double_round_robin)
	if not bool(generated.get("ok", false)):
		return generated
	var previous_fixtures: Array = fixtures_by_stage[stage_id].duplicate(true)
	var previous_standings: Dictionary = standings_by_stage[stage_id].duplicate(true)
	var previous_single_round := bool(single_round_stages.get(stage_id, false))
	fixtures_by_stage[stage_id] = generated.fixtures
	standings_by_stage[stage_id] = STANDINGS.create_table(team_ids)
	single_round_stages[stage_id] = not double_round_robin
	if not FootballDatabase.save_competition_state(stage_id, next_season_id, fixtures_by_stage[stage_id], standings_by_stage[stage_id]):
		fixtures_by_stage[stage_id] = previous_fixtures
		standings_by_stage[stage_id] = previous_standings
		single_round_stages[stage_id] = previous_single_round
		return {"ok": false, "error": "No se pudo guardar la nueva temporada: " + FootballDatabase.last_error}
	return {"ok": true, "stage_id": stage_id, "season_id": next_season_id, "fixture_count": generated.fixture_count}

# Archiva las estadísticas de temporada de todos los futbolistas y reinicia
# únicamente current_season; las cifras de carrera se conservan.
func archive_season_player_statistics(season_id: String) -> Dictionary:
	if registry == null:
		return {"ok": false, "error": "El registro de futbolistas no está disponible."}
	var archived: Dictionary = SEASON_PROGRESSION.archive_player_season(registry.players_by_id, season_id)
	if not bool(archived.get("ok", false)):
		return archived
	var previous_players: Dictionary = registry.players_by_id.duplicate(true)
	registry.players_by_id = archived.players
	if not FootballDatabase.save_catalog_snapshot(registry.export_catalog_snapshot()):
		registry.players_by_id = previous_players
		return {"ok": false, "error": "No se pudieron guardar las estadísticas archivadas: " + FootballDatabase.last_error}
	return {"ok": true, "season_id": season_id, "archived_players": int(archived.get("archived_players", 0))}


# Ligas de Campeones de Sudamérica y Norteamérica/Centroamérica.
# El llamador proporciona las diez asociaciones y las ventanas oficiales ya validadas.
func create_american_regional_champions_edition(competition_id: String, season_id: String, participants: Array, expected_associations: Array, matchday_windows: Array, seed: int = 1) -> Dictionary:
	if registry == null or season_id.is_empty():
		return {"ok": false, "errors": ["El registro de clubes o la temporada regional no están disponibles."]}
	if competition_id not in ["south_america_champions_league_nova", "north_central_america_champions_league_nova"]:
		return {"ok": false, "errors": ["La competición regional indicada no está habilitada para este motor."]}
	for participant in participants:
		if not participant is Dictionary:
			return {"ok": false, "errors": ["Participante regional con formato inválido."]}
		var participant_id := str(participant.get("team_id", participant.get("id", "")))
		if not registry.teams_by_id.has(participant_id):
			return {"ok": false, "errors": ["El club %s no está cargado en el catálogo jugable." % participant_id]}
		var registered_team: Dictionary = registry.teams_by_id[participant_id]
		if int(registered_team.get("division_level", registered_team.get("competition_level", 0))) != 1:
			return {"ok": false, "errors": ["El club %s no pertenece a Primera División." % participant_id]}
	var created: Dictionary = AMERICAN_REGIONAL_CHAMPIONS_ENGINE.create_edition(competition_id, season_id, participants, expected_associations, matchday_windows, seed)
	if not bool(created.get("ok", false)):
		return created
	var season_state: Dictionary = FootballDatabase.get_season_state(season_id)
	var regional_states: Dictionary = season_state.get("american_regional_champions_leagues", {})
	if regional_states.has(competition_id):
		return {"ok": false, "errors": ["Ya existe una edición regional de esa competición para la temporada."]}
	regional_states[competition_id] = created.duplicate(true)
	season_state["american_regional_champions_leagues"] = regional_states
	if not FootballDatabase.save_season_state(season_id, season_state):
		return {"ok": false, "errors": ["No se pudo guardar la edición regional: " + str(FootballDatabase.last_error)]}
	var competition_name := "Liga de Campeones de Sudamérica" if competition_id == "south_america_champions_league_nova" else "Liga de Campeones de Norteamérica y Centroamérica"
	_emit_competition_draw(competition_name, created.get("draw_presentation", []))
	return {"ok": true, "edition": created.duplicate(true)}

func get_american_regional_champions_edition(season_id: String, competition_id: String) -> Dictionary:
	var season_state: Dictionary = FootballDatabase.get_season_state(season_id)
	var regional_states: Dictionary = season_state.get("american_regional_champions_leagues", {})
	return regional_states.get(competition_id, {}).duplicate(true)

func _fixtures_to_draw_presentation(fixtures: Array) -> Array:
	var presentation: Array = []
	for fixture in fixtures:
		if not fixture is Dictionary:
			continue
		presentation.append({
			"team_id": str(fixture.get("home_team_id", "")),
			"opponent_team_id": str(fixture.get("away_team_id", "")),
			"round": str(fixture.get("tie_id", fixture.get("round", "")))
		})
	return presentation

func _pairings_to_draw_presentation(pairings: Array) -> Array:
	var presentation: Array = []
	for index in range(pairings.size()):
		var pairing: Variant = pairings[index]
		if pairing is Dictionary:
			var entry: Dictionary = pairing.duplicate(true)
			if not entry.has("team_id"):
				entry["team_id"] = str(entry.get("home_team_id", entry.get("team_a", "")))
			if not entry.has("opponent_team_id"):
				entry["opponent_team_id"] = str(entry.get("away_team_id", entry.get("team_b", "")))
			entry["round"] = str(entry.get("round", "Emparejamiento %d" % (index + 1)))
			presentation.append(entry)
		elif pairing is Array and pairing.size() >= 2:
			presentation.append({"team_id": str(pairing[0]), "opponent_team_id": str(pairing[1]), "round": "Emparejamiento %d" % (index + 1)})
		else:
			presentation.append({"team_name": str(pairing), "pairing": "Emparejamiento %d" % (index + 1)})
	return presentation

# API común para sorteos de torneos personalizados y módulos futuros.
# El llamador debe persistir y validar el sorteo antes de publicarlo.
func publish_resolved_competition_draw(competition_name: String, draw_result: Array) -> Dictionary:
	if competition_name.strip_edges().is_empty():
		return {"ok": false, "error": "El sorteo necesita un nombre de competición."}
	if draw_result.is_empty():
		return {"ok": false, "error": "No hay resultados de sorteo para presentar."}
	for entry in draw_result:
		if not entry is Dictionary and not entry is String:
			return {"ok": false, "error": "El resultado contiene una entrada de sorteo no válida."}
	_emit_competition_draw(competition_name, draw_result)
	return {"ok": true, "competition_name": competition_name, "entries": draw_result.size()}

func _emit_competition_draw(competition_name: String, draw_result: Array) -> void:
	if draw_result.is_empty():
		return
	draw_ceremony_requested.emit(competition_name, draw_result.duplicate(true))

# TAS: todos los encuentros son a partido único. Los partidos de grupos
# admiten empate; solo la final por el título se resuelve con prórroga y penaltis.
func create_tas_edition(season_id: String, qualifiers: Dictionary) -> Dictionary:
	if registry == null or season_id.is_empty():
		return {"ok": false, "error": "El registro deportivo o la temporada TAS no están disponibles."}
	if tas_editions_by_season.has(season_id) or not FootballDatabase.get_competition_state(_tas_storage_key(season_id)).is_empty():
		return {"ok": false, "error": "Ya existe una edición TAS para esa temporada."}
	var validation: Dictionary = TAS_COMPETITION_ENGINE.validate_qualifiers(qualifiers)
	if not bool(validation.get("ok", false)):
		return {"ok": false, "errors": validation.get("errors", [])}
	for region in ["caribbean", "south_america", "north_and_central_america"]:
		for qualifier in qualifiers.get(region, []):
			var team_id := str(qualifier.get("team_id", qualifier.get("id", "")))
			if not registry.teams_by_id.has(team_id):
				return {"ok": false, "error": "El club clasificado no existe en el registro jugable: " + team_id}
	var created: Dictionary = TAS_COMPETITION_ENGINE.create_edition(season_id, qualifiers)
	if not bool(created.get("ok", false)):
		return created
	var edition: Dictionary = created.edition
	if not _persist_tas_edition(edition):
		return {"ok": false, "error": "No se pudo guardar la edición TAS: " + str(FootballDatabase.last_error)}
	tas_editions_by_season[season_id] = edition.duplicate(true)
	_emit_competition_draw("Torneo Americano de Supercampeones (TAS)", edition.get("draw_presentation", []))
	return {"ok": true, "edition": edition.duplicate(true)}

func get_tas_edition(season_id: String) -> Dictionary:
	var edition: Dictionary = _load_tas_edition(season_id)
	return edition.duplicate(true)

func advance_tas_edition(season_id: String) -> Dictionary:
	var edition: Dictionary = _load_tas_edition(season_id)
	if edition.is_empty():
		return {"ok": false, "error": "No existe una edición TAS guardada para esa temporada."}
	var transition: Dictionary
	match str(edition.get("status", "")):
		"first_phase":
			transition = TAS_COMPETITION_ENGINE.advance_after_first_phase(edition)
		"final_group":
			transition = TAS_COMPETITION_ENGINE.advance_to_championship_final(edition)
		"championship_final":
			transition = TAS_COMPETITION_ENGINE.complete_edition(edition)
		"completed":
			return {"ok": false, "error": "La edición TAS ya está terminada."}
		_:
			return {"ok": false, "error": "Estado de edición TAS no reconocido."}
	if not bool(transition.get("ok", false)):
		return transition
	var updated: Dictionary = transition.edition
	if not _persist_tas_edition(updated):
		return {"ok": false, "error": "No se pudo guardar el avance del TAS: " + str(FootballDatabase.last_error)}
	tas_editions_by_season[season_id] = updated.duplicate(true)
	var stage_draw: Array = []
	var draw_title := ""
	if str(updated.get("status", "")) == "final_group":
		draw_title = "Torneo Americano de Supercampeones (TAS) · Grupo final"
		for team_id in updated.get("final_group_team_ids", []):
			stage_draw.append({"team_id": str(team_id), "group": "Final"})
	elif str(updated.get("status", "")) == "championship_final":
		draw_title = "Torneo Americano de Supercampeones (TAS) · Final"
		for team_id in updated.get("finalists", []):
			stage_draw.append({"team_id": str(team_id), "destination": "Final por el título"})
	if not stage_draw.is_empty():
		_emit_competition_draw(draw_title, stage_draw)
	return {"ok": true, "edition": updated.duplicate(true)}

func simulate_tas_fixture(season_id: String, stage_id: String, fixture: Dictionary, seed: int = 0) -> Dictionary:
	if registry == null or season_id.is_empty():
		return {"ok": false, "error": "El registro de clubes o la temporada TAS no están disponibles."}
	if stage_id not in ["first_phase_group_A", "first_phase_group_B", "first_phase_group_C", "final_group", "championship_final"]:
		return {"ok": false, "error": "La fase indicada no pertenece al formato del TAS."}
	var edition: Dictionary = _load_tas_edition(season_id)
	if edition.is_empty():
		return {"ok": false, "error": "No existe una edición TAS creada para esa temporada."}
	for field in ["fixture_id", "home_team_id", "away_team_id"]:
		if not fixture.has(field):
			return {"ok": false, "error": "El partido TAS no contiene todos los identificadores necesarios."}
	var fixture_id := str(fixture.fixture_id)
	var stored_fixture: Dictionary = {}
	for candidate in edition.get("fixtures_by_stage", {}).get(stage_id, []):
		if str(candidate.get("fixture_id", "")) == fixture_id:
			stored_fixture = candidate.duplicate(true)
			break
	if stored_fixture.is_empty():
		return {"ok": false, "error": "El fixture no pertenece a la fase y edición TAS indicadas."}
	if str(stored_fixture.get("status", "scheduled")) == "finished" or FootballDatabase.has_match_result(fixture_id):
		return {"ok": false, "error": "El partido TAS ya tiene un resultado guardado."}
	if str(stored_fixture.home_team_id) != str(fixture.home_team_id) or str(stored_fixture.away_team_id) != str(fixture.away_team_id):
		return {"ok": false, "error": "Los clubes no coinciden con el fixture registrado."}
	var home_id := str(stored_fixture.home_team_id)
	var away_id := str(stored_fixture.away_team_id)
	if not registry.teams_by_id.has(home_id) or not registry.teams_by_id.has(away_id):
		return {"ok": false, "error": "Faltan datos jugables de uno de los clubes del TAS."}
	var resolved_seed := seed if seed > 0 else absi(hash(fixture_id))
	var regulation_result: Dictionary = MATCH_SIMULATOR.simulate(stored_fixture, _build_simulation_team(home_id), _build_simulation_team(away_id), resolved_seed)
	if regulation_result.is_empty():
		return {"ok": false, "error": "No se pudo simular el partido reglamentario del TAS."}
	var decision: Dictionary
	if stage_id == "championship_final":
		decision = TAS_MATCH_DECISION_ENGINE.simulate_championship_final(regulation_result, _build_simulation_team(home_id), _build_simulation_team(away_id), resolved_seed)
	else:
		decision = TAS_MATCH_DECISION_ENGINE.resolve_group_match(regulation_result)
	if not bool(decision.get("ok", false)):
		return decision
	var result: Dictionary = decision.get("result", {})
	result["match_id"] = fixture_id
	result["fixture_id"] = fixture_id
	result["competition_id"] = "american_super_champions_tas"
	result["season_id"] = season_id
	result["stage_id"] = stage_id
	var applied: Dictionary = TAS_COMPETITION_ENGINE.apply_result(edition, stage_id, result)
	if not bool(applied.get("ok", false)):
		return applied
	var updated: Dictionary = applied.edition
	if not _persist_tas_edition(updated, result):
		return {"ok": false, "error": "No se pudo guardar el resultado y estado TAS: " + str(FootballDatabase.last_error)}
	tas_editions_by_season[season_id] = updated.duplicate(true)
	return {"ok": true, "result": result, "edition_status": str(updated.get("status", ""))}

func _tas_storage_key(season_id: String) -> String:
	return "american_super_champions_tas_" + season_id

func _load_tas_edition(season_id: String) -> Dictionary:
	if tas_editions_by_season.has(season_id):
		return tas_editions_by_season[season_id].duplicate(true)
	var stored: Dictionary = FootballDatabase.get_competition_state(_tas_storage_key(season_id))
	var wrapper: Dictionary = stored.get("standings", {})
	var edition: Dictionary = wrapper.get("tas_edition", {})
	if edition.is_empty():
		return {}
	tas_editions_by_season[season_id] = edition.duplicate(true)
	return edition.duplicate(true)

func _persist_tas_edition(edition: Dictionary, result: Dictionary = {}) -> bool:
	var season_id := str(edition.get("season_id", ""))
	if season_id.is_empty():
		return false
	var storage_key := _tas_storage_key(season_id)
	var fixtures: Array = TAS_COMPETITION_ENGINE.get_all_fixtures(edition)
	var payload := {"tas_edition": edition.duplicate(true)}
	if result.is_empty():
		return FootballDatabase.save_competition_state(storage_key, season_id, fixtures, payload)
	return FootballDatabase.commit_match_and_competition_state(storage_key, season_id, result, fixtures, payload)


func resolve_tas_group_result(regulation_result: Dictionary) -> Dictionary:
	return TAS_MATCH_DECISION_ENGINE.resolve_group_match(regulation_result)

func get_ordered_tas_standings(table: Dictionary, draw_seed: int = 1) -> Array:
	return TAS_MATCH_DECISION_ENGINE.get_ordered_tas_table(table, draw_seed)

func save_tas_standings(season_id: String, stage_id: String, table: Dictionary, draw_seed: int = 1) -> Dictionary:
	if season_id.is_empty() or stage_id not in ["first_phase_group_A", "first_phase_group_B", "first_phase_group_C", "final_group"]:
		return {"ok": false, "error": "La temporada o la fase de clasificación del TAS no son válidas."}
	if table.size() != 3:
		return {"ok": false, "error": "Cada grupo del TAS debe contener exactamente tres clubes."}
	var season_state: Dictionary = FootballDatabase.get_season_state(season_id)
	var tas_state: Dictionary = season_state.get("american_super_champions_tas", {})
	var standings_by_stage: Dictionary = tas_state.get("standings_by_stage", {})
	var ordered_by_stage: Dictionary = tas_state.get("ordered_standings_by_stage", {})
	var draw_records: Dictionary = tas_state.get("tiebreak_draws_by_stage", {})
	var previous_draw: Dictionary = draw_records.get(stage_id, {})
	var effective_seed := maxi(1, int(previous_draw.get("seed", draw_seed)))
	var ordered: Array = TAS_MATCH_DECISION_ENGINE.get_ordered_tas_table(table, effective_seed)
	var draw_lots := {}
	for row in ordered:
		draw_lots[str(row.get("team_id", ""))] = int(row.get("tas_draw_lot", 0))
	standings_by_stage[stage_id] = table.duplicate(true)
	ordered_by_stage[stage_id] = ordered.duplicate(true)
	draw_records[stage_id] = {"seed": effective_seed, "draw_lots": draw_lots, "criteria": "tas_ordered_tiebreakers"}
	tas_state["standings_by_stage"] = standings_by_stage
	tas_state["ordered_standings_by_stage"] = ordered_by_stage
	tas_state["tiebreak_draws_by_stage"] = draw_records
	season_state["american_super_champions_tas"] = tas_state
	if not FootballDatabase.save_season_state(season_id, season_state):
		return {"ok": false, "error": "No se pudo guardar la clasificación y el registro de desempate del TAS: " + str(FootballDatabase.last_error)}
	return {"ok": true, "season_id": season_id, "stage_id": stage_id, "ordered_standings": ordered, "draw_record": draw_records[stage_id]}

func resolve_tas_championship_final(regulation_result: Dictionary, extra_time_goals: Dictionary, penalty_shootout: Dictionary = {}) -> Dictionary:
	return TAS_MATCH_DECISION_ENGINE.resolve_championship_final(regulation_result, extra_time_goals, penalty_shootout)


# Liga de Campeones del Caribe: servicios de preparación, clasificación y persistencia.
func qualify_caribbean_champions_league(slot_distribution: Dictionary, domestic_tables: Dictionary) -> Dictionary:
	return CARIBBEAN_CHAMPIONS_ENGINE.qualify_participants(slot_distribution, domestic_tables)

func create_caribbean_champions_league_edition(season_id: String, participants: Array, neutral_final_venue: String, seed: int = 1) -> Dictionary:
	if registry == null:
		return {"ok": false, "errors": ["El registro de clubes no está inicializado."]}
	for participant in participants:
		var participant_id := str(participant.get("team_id", participant.get("id", ""))) if participant is Dictionary else ""
		if not registry.teams_by_id.has(participant_id):
			return {"ok": false, "errors": ["El club %s no está cargado en el catálogo jugable; importa su paquete de liga antes de iniciar." % participant_id]}
		var registered_team: Dictionary = registry.teams_by_id[participant_id]
		if int(registered_team.get("division_level", registered_team.get("competition_level", 0))) != 1:
			return {"ok": false, "errors": ["El club %s no pertenece a Primera División en el catálogo jugable." % participant_id]}
	var edition: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.create_edition(season_id, participants, neutral_final_venue, seed)
	if not bool(edition.get("ok", false)):
		return edition
	var season_state: Dictionary = FootballDatabase.get_season_state(season_id)
	season_state["caribbean_champions_league"] = edition
	if not FootballDatabase.save_season_state(season_id, season_state):
		return {"ok": false, "errors": ["No se pudo guardar la edición: " + str(FootballDatabase.last_error)]}
	_emit_competition_draw("Liga de Campeones del Caribe", edition.get("draw_presentation", []))
	return edition

func get_caribbean_champions_league_state(season_id: String) -> Dictionary:
	var saved: Dictionary = FootballDatabase.get_season_state(season_id)
	return saved.get("caribbean_champions_league", {}).duplicate(true)

func record_caribbean_group_result(season_id: String, group_id: String, result: Dictionary) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty():
		return {"ok": false, "error": "No existe una edición guardada para esa temporada."}
	var response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.record_group_result(edition, group_id, result, FootballDatabase)
	if bool(response.get("ok", false)):
		var saved: Dictionary = FootballDatabase.get_season_state(season_id)
		saved["caribbean_champions_league"] = edition
		if not FootballDatabase.save_season_state(season_id, saved):
			return {"ok": false, "error": "No se pudo actualizar la edición en el guardado de temporada."}
	return response

func build_caribbean_champions_league_playoff(season_id: String) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty():
		return {"ok": false, "errors": ["No existe una edición guardada."]}
	var response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.build_playoff(edition)
	if not bool(response.get("ok", false)):
		return response
	var saved: Dictionary = FootballDatabase.get_season_state(season_id)
	saved["caribbean_champions_league"] = edition
	if not FootballDatabase.save_season_state(season_id, saved):
		return {"ok": false, "errors": ["No se pudo guardar la repesca."]}
	return response

func set_caribbean_champions_league_round_of_16_draw(season_id: String, pairings: Array) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty():
		return {"ok": false, "errors": ["No existe una edición guardada."]}
	var response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.set_round_of_16_draw(edition, pairings)
	if not bool(response.get("ok", false)):
		return response
	var saved: Dictionary = FootballDatabase.get_season_state(season_id)
	saved["caribbean_champions_league"] = edition
	if not FootballDatabase.save_season_state(season_id, saved):
		return {"ok": false, "errors": ["No se pudo guardar el sorteo de octavos."]}
	_emit_competition_draw("Liga de Campeones del Caribe · Octavos de final", _pairings_to_draw_presentation(pairings))
	return response


func record_caribbean_knockout_result(season_id: String, fixture_bucket: String, result: Dictionary) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty():
		return {"ok": false, "error": "No existe una edición guardada."}
	if fixture_bucket not in ["playoff_fixtures", "round_of_16", "quarterfinals", "semifinals", "final"]:
		return {"ok": false, "error": "Fase eliminatoria no válida."}
	if fixture_bucket != "playoff_fixtures":
		var knockout: Dictionary = edition.get("knockout_fixtures", {})
		if not knockout.has(fixture_bucket):
			return {"ok": false, "error": "No existe el cuadro de esa ronda."}
		edition[fixture_bucket + "_fixtures"] = knockout[fixture_bucket]
		var response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.record_knockout_result(edition, fixture_bucket + "_fixtures", result, FootballDatabase)
		if not bool(response.get("ok", false)):
			return response
		edition.knockout_fixtures[fixture_bucket] = edition[fixture_bucket + "_fixtures"]
		edition.erase(fixture_bucket + "_fixtures")
		var saved_state: Dictionary = FootballDatabase.get_season_state(season_id)
		saved_state["caribbean_champions_league"] = edition
		if not FootballDatabase.save_season_state(season_id, saved_state):
			return {"ok": false, "error": "Resultado guardado, pero no se pudo actualizar el estado de temporada."}
		return response
	var playoff_response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.record_knockout_result(edition, "playoff_fixtures", result, FootballDatabase)
	if not bool(playoff_response.get("ok", false)):
		return playoff_response
	var saved: Dictionary = FootballDatabase.get_season_state(season_id)
	saved["caribbean_champions_league"] = edition
	if not FootballDatabase.save_season_state(season_id, saved):
		return {"ok": false, "error": "Resultado guardado, pero no se pudo actualizar el estado de temporada."}
	return playoff_response

func set_caribbean_knockout_round(season_id: String, round_id: String, pairings: Array) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty():
		return {"ok": false, "errors": ["No existe una edición guardada."]}
	var response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.set_knockout_round(edition, round_id, pairings)
	if not bool(response.get("ok", false)):
		return response
	var saved: Dictionary = FootballDatabase.get_season_state(season_id)
	saved["caribbean_champions_league"] = edition
	if not FootballDatabase.save_season_state(season_id, saved):
		return {"ok": false, "errors": ["No se pudo guardar el cuadro de " + round_id]}
	_emit_competition_draw("Liga de Campeones del Caribe · " + round_id.replace("_", " ").capitalize(), _pairings_to_draw_presentation(pairings))
	return response

func set_caribbean_champions_league_final(season_id: String, finalist_a: String, finalist_b: String) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty():
		return {"ok": false, "error": "No existe una edición guardada."}
	var response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.set_single_match_final(edition, finalist_a, finalist_b)
	if not bool(response.get("ok", false)):
		return response
	var saved: Dictionary = FootballDatabase.get_season_state(season_id)
	saved["caribbean_champions_league"] = edition
	if not FootballDatabase.save_season_state(season_id, saved):
		return {"ok": false, "error": "No se pudo guardar la final."}
	return response


func simulate_caribbean_champions_league_fixture(season_id: String, fixture_bucket: String, fixture_id: String, seed: int = 0) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty() or registry == null:
		return {"ok": false, "error": "No existe una edición guardada o el registro de clubes no está listo."}
	var fixtures: Array = []
	if fixture_bucket in ["A", "B", "C", "D"]:
		fixtures = edition.get("fixtures_by_group", {}).get(fixture_bucket, [])
	elif fixture_bucket == "playoff_fixtures":
		fixtures = edition.get("playoff_fixtures", [])
	else:
		fixtures = edition.get("knockout_fixtures", {}).get(fixture_bucket, [])
	var selected: Dictionary = {}
	for fixture in fixtures:
		if str(fixture.get("fixture_id", "")) == fixture_id:
			selected = fixture
			break
	if selected.is_empty() or str(selected.get("status", "scheduled")) == "finished":
		return {"ok": false, "error": "Partido no encontrado o ya finalizado."}
	var home_id := str(selected.get("home_team_id", ""))
	var away_id := str(selected.get("away_team_id", ""))
	if not registry.teams_by_id.has(home_id) or not registry.teams_by_id.has(away_id):
		return {"ok": false, "error": "Faltan datos jugables de uno de los clubes."}
	var resolved_seed := seed if seed > 0 else absi(hash(fixture_id))
	var result: Dictionary = MATCH_SIMULATOR.simulate(selected, _build_simulation_team(home_id), _build_simulation_team(away_id), resolved_seed)
	if result.is_empty():
		return {"ok": false, "error": "No se pudo simular el partido."}
	if fixture_bucket in ["A", "B", "C", "D"]:
		var group_result := record_caribbean_group_result(season_id, fixture_bucket, result)
		return {"ok": bool(group_result.get("ok", false)), "result": result, "details": group_result}
	var knockout_result := record_caribbean_knockout_result(season_id, fixture_bucket, result)
	return {"ok": bool(knockout_result.get("ok", false)), "result": result, "details": knockout_result}


func resolve_caribbean_knockout_tie(season_id: String, fixture_bucket: String, tie_id: String, winner_team_id: String) -> Dictionary:
	var edition := get_caribbean_champions_league_state(season_id)
	if edition.is_empty():
		return {"ok": false, "error": "No existe una edición guardada."}
	var fixtures: Array = []
	if fixture_bucket == "playoff_fixtures":
		fixtures = edition.get("playoff_fixtures", []).duplicate(true)
	else:
		fixtures = edition.get("knockout_fixtures", {}).get(fixture_bucket, []).duplicate(true)
	var response: Dictionary = CARIBBEAN_CHAMPIONS_ENGINE.set_knockout_tie_decision(fixtures, tie_id, winner_team_id)
	if not bool(response.get("ok", false)):
		return response
	if fixture_bucket == "playoff_fixtures":
		edition["playoff_fixtures"] = response.fixtures
	else:
		edition.knockout_fixtures[fixture_bucket] = response.fixtures
	var saved: Dictionary = FootballDatabase.get_season_state(season_id)
	saved["caribbean_champions_league"] = edition
	if not FootballDatabase.save_season_state(season_id, saved):
		return {"ok": false, "error": "No se pudo guardar la decisión de la eliminatoria."}
	return response
