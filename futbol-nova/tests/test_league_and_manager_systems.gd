extends SceneTree

const BallService = preload("res://scripts/competitions/league_ball_service.gd")
const AcademyService = preload("res://scripts/manager/club_academy_service.gd")
const BoardService = preload("res://scripts/manager/board_objectives_service.gd")
const CalendarBuilder = preload("res://scripts/simulation/competition_calendar_builder.gd")
const CareerService = preload("res://scripts/manager/manager_career_service.gd")

func _initialize() -> void:
	var failures := PackedStringArray()
	_test_league_ball(failures)
	_test_academy_rules(failures)
	_test_board_objectives(failures)
	_test_competition_calendars(failures)
	_test_manager_career(failures)
	if failures.is_empty():
		print("FUTBOL_NOVA_LEAGUE_MANAGER_TESTS: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_league_ball(failures: PackedStringArray) -> void:
	var catalog := BallService.load_catalog()
	if not BallService.validate_catalog(catalog).is_empty():
		failures.append("BallService: catálogo de balones inválido")
	var first := BallService.resolve_match_ball("cuba_national_league", "league", true)
	if not bool(first.get("ok", false)) or not bool(first.get("locked", false)):
		failures.append("BallService: el balón oficial de liga no está bloqueado")
	var cup := BallService.resolve_match_ball("cuba_national_league", "cup", true, "nova_classic_white")
	if not bool(cup.get("locked", false)) or str(cup.get("ball", {}).get("id", "")) != "nova_cuba_tropical":
		failures.append("BallService: la Copa oficial debe heredar y bloquear el balón de liga")
	var friendly := BallService.resolve_match_ball("cuba_national_league", "friendly", false, "nova_classic_white")
	if not bool(friendly.get("ok", false)) or bool(friendly.get("locked", true)):
		failures.append("BallService: el amistoso no permite elegir balón")

func _test_academy_rules(failures: PackedStringArray) -> void:
	var first := AcademyService.initial_state(1)
	var second := AcademyService.initial_state(2)
	var third := AcademyService.initial_state(3)
	if not bool(first.get("operational", false)):
		failures.append("Academy: Primera debe comenzar con cantera")
	if bool(second.get("operational", false)) or bool(third.get("operational", false)):
		failures.append("Academy: Segunda/Tercera no deben comenzar con cantera")
	var compliance := {"association_license": true, "facilities_or_contract": true, "qualified_staff": true, "safeguarding_approved": true, "youth_development_plan": true}
	var finances := {"available_cash": 100000.0, "startup_cost": 10000.0, "monthly_operating_cost": 5000.0, "required_reserve": 0.0}
	var allowed := AcademyService.activate_academy(3, finances, compliance)
	if not bool(allowed.get("ok", false)):
		failures.append("Academy: club solvente de Tercera debe poder crear cantera bajo reglas de Segunda")
	elif not is_equal_approx(float(allowed.get("finance_after", {}).get("available_cash", 0.0)), 90000.0):
		failures.append("Academy: no descontó el coste inicial de la tesorería")
	finances["available_cash"] = 1000.0
	var denied := AcademyService.activate_academy(2, finances, compliance)
	if bool(denied.get("ok", false)):
		failures.append("Academy: debe denegar academia sin financiación")

func _test_board_objectives(failures: PackedStringArray) -> void:
	var objectives := BoardService.create_default_objectives()
	var match_data := {"yellow_cards": 0, "red_cards": 0, "scored_first_half": true, "scored_second_half": true, "team_goals": 2, "opponent_goals": 1, "starting_lineup": [{"age": 22}, {"age": 24}, {"age": 19}]}
	var results := BoardService.evaluate_match(objectives, match_data)
	if int(results[0].progress) != 1 or int(results[1].progress) != 1 or int(results[2].progress) != 3:
		failures.append("BoardObjectives: no avanzó correctamente los objetivos de junta")
	var dirty := BoardService.evaluate_match(objectives, {"yellow_cards": 1, "red_cards": 0})
	if int(dirty[0].progress) != 0:
		failures.append("BoardObjectives: contó como limpio un partido con amarilla")
	var untracked_discipline := BoardService.evaluate_match(objectives, {"team_goals": 1, "opponent_goals": 0})
	if int(untracked_discipline[0].progress) != 0:
		failures.append("BoardObjectives: avanzó disciplina sin datos de tarjetas")

func _test_competition_calendars(failures: PackedStringArray) -> void:
	var second := ["s1", "s2", "s3", "s4", "s5", "s6", "s7"]
	var playoff := CalendarBuilder.build_second_division_playoff(second)
	if playoff.size() != 6:
		failures.append("Calendar: playoff de Segunda debe generar seis partidos a doble vuelta")
	var third := CalendarBuilder.build_third_division_promotion_playoff(["w1", "w2"], ["e1", "e2"])
	var supercup := CalendarBuilder.build_supercopa_final_four(["a", "b", "c", "d"])
	if supercup.size() != 3 or not bool(supercup[0].get("neutral_venue", false)) or not bool(supercup[2].get("neutral_venue", false)) or bool(supercup[0].get("extra_time_if_draw", true)) or not bool(supercup[0].get("penalties_if_still_draw", false)):
		failures.append("Calendar: Supercopa debe crear dos semifinales y final en sede neutral")
	if third.size() != 2 or int(third[0].get("leg", 0)) != 1 or int(third[1].get("leg", 0)) != 2 or not bool(third[0].get("aggregate_score", false)):
		failures.append("Calendar: subcampeones de Tercera deben disputar playoff de ascenso a doble partido")
	var records: Array = []
	for i in range(52):
		records.append({"id": "club_%02d" % i, "division_level": 1 if i < 16 else (2 if i < 32 else 3)})
	var cup := CalendarBuilder.build_copa_de_cuba(records)
	if not bool(cup.get("ok", false)) or int(cup.get("team_count", 0)) != 52:
		failures.append("Calendar: no pudo crear Copa de Cuba con 52 clubes")
	if int(cup.get("bye_count", 0)) != 12:
		failures.append("Calendar: Copa de Cuba debe repartir 12 exenciones para cuadro de 64")
	var rounds: Array = cup.get("rounds", [])
	if rounds.size() != 6:
		failures.append("Calendar: Copa de Cuba debe tener preliminar, R32, R16, cuartos, semis y final")
	elif rounds[4].ties.size() != 4:
		failures.append("Calendar: semifinales de Copa deben ser dos eliminatorias a doble partido")

func _test_manager_career(failures: PackedStringArray) -> void:
	var service = CareerService.new()
	root.add_child(service)
	var started: Dictionary = service.start_coach_career("club_test")
	if not bool(started.get("ok", false)):
		failures.append("ManagerCareer: no inició la carrera de entrenador")
		service.queue_free()
		return
	var result: Dictionary = service.process_match({"match_id": "match_1", "yellow_cards": 0, "red_cards": 0})
	if not bool(result.get("ok", false)) or int(result.get("objectives", [])[0].get("progress", 0)) != 1:
		failures.append("ManagerCareer: no actualizó progreso de objetivo tras partido")
	var duplicate: Dictionary = service.process_match({"match_id": "match_1", "yellow_cards": 0, "red_cards": 0})
	if bool(duplicate.get("ok", false)):
		failures.append("ManagerCareer: procesó dos veces el mismo partido")
	var state := service.get_career_state()
	if int(state.get("matches_managed", 0)) != 1:
		failures.append("ManagerCareer: el mismo partido incrementó dos veces el contador")
	for match_index in range(2, 5):
		service.process_match({"match_id": "match_%d" % match_index, "yellow_cards": 0, "red_cards": 0})
	var refreshed: Array = service.get_career_state().get("objectives", [])
	var active_ids := {}
	for objective in refreshed:
		var objective_id := str(objective.get("id", ""))
		if active_ids.has(objective_id):
			failures.append("ManagerCareer: duplicó un objetivo al renovarlo")
		active_ids[objective_id] = true
	if int(service.get_career_state().get("board_points", 0)) < 200:
		failures.append("ManagerCareer: no entregó la recompensa por completar objetivo")
	if not service.load_career():
		failures.append("ManagerCareer: no pudo cargar el guardado")
	service.queue_free()
