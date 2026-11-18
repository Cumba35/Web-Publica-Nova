extends SceneTree

const Match11v11 = preload("res://scripts/gameplay/match_11v11_controller.gd")
const MatchRules = preload("res://scripts/gameplay/match_rules.gd")
const MatchClock = preload("res://scripts/gameplay/match_clock_rules.gd")
const MatchClockState = preload("res://scripts/gameplay/match_clock_state_machine.gd")
const MatchSubs = preload("res://scripts/gameplay/match_substitution_rules.gd")
const RealismModule = preload("res://scripts/modules/realism_module.gd")
const PreMatchSetup = preload("res://scripts/ui/pre_match_setup.gd")

func _initialize() -> void:
	var failures := PackedStringArray()
	var home := Match11v11.build_lineup("home_test", true)
	var away := Match11v11.build_lineup("away_test", false)
	var selected_home_ids: Array[String] = []
	var selected_away_ids: Array[String] = []
	for index in range(11):
		selected_home_ids.append("club_home_player_%02d" % index)
		selected_away_ids.append("club_away_player_%02d" % index)
	var selected_home := Match11v11.build_lineup("club_home", true, selected_home_ids)
	var selected_away := Match11v11.build_lineup("club_away", false, selected_away_ids)
	var sample_roster := [
		{"id": "p_gk", "primary_position": "POR"},
		{"id": "p_lb", "primary_position": "LI"},
		{"id": "p_cb1", "primary_position": "DFC"},
		{"id": "p_cb2", "primary_position": "DFC"},
		{"id": "p_rb", "primary_position": "LD"},
		{"id": "p_dm", "primary_position": "MCD"},
		{"id": "p_cm", "primary_position": "MC"},
		{"id": "p_am", "primary_position": "MCO"},
		{"id": "p_lw", "primary_position": "EI"},
		{"id": "p_st", "primary_position": "DC"},
		{"id": "p_rw", "primary_position": "ED"}
	]
	var selected_eleven := PreMatchSetup.build_starting_eleven(sample_roster)
	if selected_eleven.size() != 11 or selected_eleven[0] != "p_gk" or selected_eleven[9] != "p_st":
		failures.append("PreMatchSetup: no construyó un once inicial de 4-3-3 según las posiciones de los jugadores")
	if Match11v11.build_lineup("club_home", true, selected_eleven).size() != 11:
		failures.append("PreMatchSetup: el once seleccionado no se pudo convertir en alineación de partido")
	if selected_home.size() != 11 or selected_away.size() != 11:
		failures.append("Match11v11: no creó alineaciones a partir de los jugadores seleccionados")
	elif str(selected_home[0].player_id) != selected_home_ids[0] or str(selected_away[10].player_id) != selected_away_ids[10]:
		failures.append("Match11v11: no conservó los identificadores reales de las plantillas elegidas")
	if not Match11v11.build_lineup("club_incomplete", true, selected_home_ids.slice(0, 10)).is_empty():
		failures.append("Match11v11: aceptó una plantilla inicial con menos de once titulares")
	if home.size() != 11:
		failures.append("Match11v11: el equipo local no contiene 11 jugadores")
	if away.size() != 11:
		failures.append("Match11v11: el equipo visitante no contiene 11 jugadores")
	if not Match11v11.is_ball_in_defensive_third(30.0, true):
		failures.append("Match11v11: el portero local no reconoce el balón en su propio tercio defensivo")
	if Match11v11.is_ball_in_defensive_third(-30.0, true):
		failures.append("Match11v11: el portero local confundió el tercio rival con su zona defensiva")
	if not Match11v11.is_ball_in_defensive_third(-30.0, false):
		failures.append("Match11v11: el portero visitante no reconoce el balón en su propio tercio defensivo")
	if Match11v11.is_ball_in_defensive_third(30.0, false):
		failures.append("Match11v11: el portero visitante confundió el tercio rival con su zona defensiva")
	if not Match11v11.is_ball_in_attacking_third(-30.0, true):
		failures.append("Match11v11: la IA local no reconoce el tercio de ataque hacia -Z")
	if Match11v11.is_ball_in_attacking_third(30.0, true):
		failures.append("Match11v11: la IA local confundió su tercio defensivo con el de ataque")
	if not Match11v11.is_ball_in_attacking_third(30.0, false):
		failures.append("Match11v11: la IA visitante no reconoce el tercio de ataque hacia +Z")
	if Match11v11.is_ball_in_attacking_third(-30.0, false):
		failures.append("Match11v11: la IA visitante confundió su tercio defensivo con el de ataque")
	if not is_equal_approx(Match11v11.forward_progress(0.0, -12.0, true), 12.0):
		failures.append("Match11v11: la IA local no calcula los pases hacia -Z como avance")
	if not is_equal_approx(Match11v11.forward_progress(0.0, 12.0, false), 12.0):
		failures.append("Match11v11: la IA visitante no calcula los pases hacia +Z como avance")
	if Match11v11.forward_progress(0.0, 12.0, true) > 0.0 or Match11v11.forward_progress(0.0, -12.0, false) > 0.0:
		failures.append("Match11v11: la IA considera avance un pase hacia su propia portería")
	var home_keeper_clear := Match11v11.goalkeeper_clear_direction(true, 5.0)
	var away_keeper_clear := Match11v11.goalkeeper_clear_direction(false, -5.0)
	if home_keeper_clear.z >= 0.0:
		failures.append("Match11v11: el portero local despeja hacia su propia portería en +Z")
	if away_keeper_clear.z <= 0.0:
		failures.append("Match11v11: el portero visitante despeja hacia su propia portería en -Z")
	if home_keeper_clear.y <= 0.0 or away_keeper_clear.y <= 0.0:
		failures.append("Match11v11: el despeje del portero no eleva el balón")
	if not Match11v11.validate_lineups(home, away):
		failures.append("Match11v11: rechazó dos alineaciones válidas")
	var ids := {}
	for player_data in home + away:
		var player_id := str(player_data.get("player_id", ""))
		if player_id.is_empty() or ids.has(player_id):
			failures.append("Match11v11: identificador vacío o duplicado: " + player_id)
		ids[player_id] = true
		var position: Vector3 = player_data.get("position", Vector3.ZERO)
		if absf(position.x) > 34.0 or absf(position.z) > 52.5:
			failures.append("Match11v11: posición fuera del terreno para " + player_id)
	if ids.size() != 22:
		failures.append("Match11v11: el total de identificadores únicos no es 22")
	for lineup in [home, away]:
		var goalkeeper_count := 0
		var striker_count := 0
		for player_data in lineup:
			if str(player_data.get("role", "")) == "GK":
				goalkeeper_count += 1
			if str(player_data.get("role", "")) == "ST":
				striker_count += 1
		if goalkeeper_count != 1 or striker_count != 1:
			failures.append("Match11v11: cada 4-3-3 debe incluir un portero y un delantero centro")
	for index in range(home.size()):
		var home_position: Vector3 = home[index].get("position", Vector3.ZERO)
		var away_position: Vector3 = away[index].get("position", Vector3.ZERO)
		if not is_equal_approx(home_position.x, away_position.x) or not is_equal_approx(home_position.z, -away_position.z):
			failures.append("Match11v11: la alineación visitante no está reflejada correctamente")
	if Match11v11.validate_lineups(home.slice(0, 10), away):
		failures.append("Match11v11: aceptó una alineación incompleta")
	var duplicate_away := away.duplicate(true)
	duplicate_away[0].player_id = home[0].player_id
	if Match11v11.validate_lineups(home, duplicate_away):
		failures.append("Match11v11: aceptó identificadores duplicados entre equipos")
	if not Match11v11.can_control_ball(1.0, 0.8, 3.5):
		failures.append("Match11v11: rechazó un balón alcanzable para el primer control")
	if Match11v11.can_control_ball(1.3, 0.8, 3.5):
		failures.append("Match11v11: permitió controlar un balón demasiado lejano")
	if Match11v11.can_control_ball(0.8, 1.3, 3.5):
		failures.append("Match11v11: permitió controlar un balón demasiado alto")
	if Match11v11.can_control_ball(0.8, 0.8, 4.5):
		failures.append("Match11v11: permitió controlar un balón demasiado rápido")
	if Match11v11.can_control_ball(0.8, -0.05, 2.0):
		failures.append("Match11v11: permitió controlar un balón por debajo del terreno")
	if Match11v11.can_control_ball(0.8, 0.8, 4.01):
		failures.append("Match11v11: el límite de velocidad permitió adquirir un balón rápido")
	var front_tackle := Match11v11.evaluate_tackle(Vector3.ZERO, Vector3(0, 0, -1), Vector3(0, 0, -1.2), Vector3(0, 0, 1))
	if not bool(front_tackle.get("success", false)):
		failures.append("Match11v11: no permitió una entrada frontal limpia en alcance")
	var poor_angle_tackle := Match11v11.evaluate_tackle(Vector3.ZERO, Vector3(1, 0, 0), Vector3(0, 0, -1.2), Vector3(0, 0, 1))
	if bool(poor_angle_tackle.get("success", false)):
		failures.append("Match11v11: permitió una entrada con orientación deficiente")
	var distant_tackle := Match11v11.evaluate_tackle(Vector3.ZERO, Vector3(0, 0, -1), Vector3(0, 0, -2.5), Vector3(0, 0, -1))
	if bool(distant_tackle.get("in_range", false)):
		failures.append("Match11v11: permitió una entrada fuera de alcance")
	var rear_foul := Match11v11.evaluate_tackle(Vector3(0, 0, 0.7), Vector3(0, 0, -1), Vector3.ZERO, Vector3(0, 0, -1))
	if not bool(rear_foul.get("foul", false)) or bool(rear_foul.get("success", false)):
		failures.append("Match11v11: no detectó una entrada peligrosa por detrás")
	var pass_origin := Vector3(0.0, 0.0, 0.0)
	var pass_target := Vector3(0.0, 0.0, -10.0)
	if Match11v11.is_point_blocking_pass(pass_origin, pass_target, Vector3(0.0, 0.0, -5.0)) == false:
		failures.append("Match11v11: no detectó un rival situado en la trayectoria del pase")
	if Match11v11.is_point_blocking_pass(pass_origin, pass_target, Vector3(5.0, 0.0, -5.0)):
		failures.append("Match11v11: marcó como bloqueado un pase con rival alejado")
	if Match11v11.is_point_blocking_pass(pass_origin, pass_origin, Vector3.ZERO) == false:
		failures.append("Match11v11: no rechazó un pase de longitud cero")

	var offside := MatchRules.evaluate_offside_at_pass(Vector3(0, 0, -30), Vector3(0, 0, -20), [Vector3(-4, 0, -25), Vector3(4, 0, -24), Vector3(0, 0, 5)], -1.0)
	if not bool(offside.get("offence", false)):
		failures.append("MatchRules: no detectó fuera de juego activo en el momento del pase")
	var passive_offside := MatchRules.evaluate_offside_at_pass(Vector3(0, 0, -30), Vector3(0, 0, -20), [Vector3(-4, 0, -25), Vector3(4, 0, -24)], -1.0, false)
	if not bool(passive_offside.get("offside_position", false)) or bool(passive_offside.get("offence", true)):
		failures.append("MatchRules: confundió posición de fuera de juego con infracción sin intervención")
	for restart_type in ["goal_kick", "throw_in", "corner"]:
		var exempt_offside := MatchRules.evaluate_offside_at_pass(Vector3(0, 0, -30), Vector3(0, 0, -20), [Vector3(-4, 0, -25), Vector3(4, 0, -24)], -1.0, true, restart_type)
		if bool(exempt_offside.get("offence", true)):
			failures.append("MatchRules: señaló fuera de juego tras reinicio exento: " + restart_type)
	var own_half := MatchRules.evaluate_offside_at_pass(Vector3(0, 0, 8), Vector3(0, 0, 2), [Vector3(-4, 0, -5), Vector3(4, 0, -4)], -1.0)
	if bool(own_half.get("offence", false)):
		failures.append("MatchRules: señaló fuera de juego en campo propio")
	var level_with_defender := MatchRules.evaluate_offside_at_pass(Vector3(0, 0, -24), Vector3(0, 0, -18), [Vector3(-4, 0, -24), Vector3(4, 0, -24)], -1.0)
	if bool(level_with_defender.get("offside_position", false)):
		failures.append("MatchRules: señaló fuera de juego estando a la misma altura del penúltimo defensor")
	var throw_in := MatchRules.classify_ball_exit(Vector3(35, 0, 12), true)
	if throw_in.restart != "throw_in" or bool(throw_in.awarded_home):
		failures.append("MatchRules: saque de banda no concedido al equipo contrario al último toque")
	var corner := MatchRules.classify_ball_exit(Vector3(10, 0, 53), true)
	if corner.restart != "corner" or bool(corner.awarded_home):
		failures.append("MatchRules: no concedió córner al ataque tras último toque del defensor local")
	var goal_kick := MatchRules.classify_ball_exit(Vector3(10, 0, 53), false)
	if goal_kick.restart != "goal_kick" or not bool(goal_kick.awarded_home):
		failures.append("MatchRules: no concedió saque de puerta al equipo defensor")
	var goal := MatchRules.classify_ball_exit(Vector3(0, 1, 53), false)
	if goal.restart != "goal" or bool(goal.awarded_home):
		failures.append("MatchRules: no reconoció gol válido hacia la portería local")
	var high_ball := MatchRules.classify_ball_exit(Vector3(0, 3.0, 53), false)
	if high_ball.restart != "goal_kick":
		failures.append("MatchRules: concedió gol a un balón que salió por encima del larguero")
	var below_ground_goal := MatchRules.classify_ball_exit(Vector3(0, -0.1, 53), false)
	if below_ground_goal.restart == "goal":
		failures.append("MatchRules: concedió gol a un balón por debajo de la superficie")
	var ball_not_fully_out := MatchRules.classify_ball_exit(Vector3(34.1, 0, 12), true)
	if ball_not_fully_out.restart != "in_play":
		failures.append("MatchRules: declaró fuera el balón antes de que cruzara completamente la línea")
	var ball_fully_out := MatchRules.classify_ball_exit(Vector3(34.23, 0, 12), true)
	if ball_fully_out.restart != "throw_in":
		failures.append("MatchRules: no detectó la salida completa del balón por la banda")
	var ball_hits_post := MatchRules.classify_ball_exit(Vector3(3.5, 1, 53), false)
	if ball_hits_post.restart == "goal":
		failures.append("MatchRules: concedió gol cuando el balón no cabe completamente entre los postes")
	var inside_boundary := MatchRules.classify_ball_exit(Vector3(34, 0, 52.5), true)
	if inside_boundary.restart != "in_play":
		failures.append("MatchRules: declaró fuera un balón que sigue sobre la línea de demarcación")
	var ambiguous_corner := MatchRules.classify_ball_exit(Vector3(35, 0, 53), true)
	if ambiguous_corner.restart != "ambiguous_exit":
		failures.append("MatchRules: no exigió la posición anterior cuando el balón salió por dos límites")
	var goal_line_first := MatchRules.classify_ball_exit(Vector3(35, 0, 60), true, 34.0, 52.5, 3.66, 2.44, 0.22, Vector3.ZERO, true)
	if goal_line_first.restart != "corner":
		failures.append("MatchRules: no concedió córner cuando la línea de meta se cruzó primero")
	var touchline_first := MatchRules.classify_ball_exit(Vector3(60, 0, 53), true, 34.0, 52.5, 3.66, 2.44, 0.22, Vector3.ZERO, true)
	if touchline_first.restart != "throw_in":
		failures.append("MatchRules: no concedió saque de banda cuando la línea lateral se cruzó primero")

	# Match clock rules from the original Fútbol Nova design.
	for half_minutes in [3, 5, 6, 8, 10, 15, 20]:
		if not MatchClock.is_valid_half_length(half_minutes):
			failures.append("MatchClock: rechazó una duración reglamentaria: " + str(half_minutes))
	if MatchClock.is_valid_half_length(4) or MatchClock.is_valid_half_length(90):
		failures.append("MatchClock: aceptó una duración no configurada")
	var expected_extra := {3: 1, 5: 2, 6: 2, 8: 3, 10: 3, 15: 5, 20: 7}
	for regular_minutes in expected_extra:
		if MatchClock.extra_time_half_minutes(regular_minutes) != expected_extra[regular_minutes]:
			failures.append("MatchClock: duración de prórroga incorrecta para " + str(regular_minutes) + " minutos")
	if MatchClock.period_length_seconds(5) != 300 or MatchClock.period_length_seconds(4) != 0:
		failures.append("MatchClock: conversión de duración del período incorrecta")
	var stopped_added := MatchClock.calculate_added_time_seconds(MatchClock.CLOCK_STOPPED, 5, 0.0, 0)
	if stopped_added < 60 or stopped_added > 180:
		failures.append("MatchClock: reloj detenido no añadió entre 1 y 3 minutos")
	var continuous_added := MatchClock.calculate_added_time_seconds(MatchClock.CLOCK_CONTINUOUS, 5, 247.0, 0)
	if continuous_added != 247:
		failures.append("MatchClock: reloj continuo no compensó exactamente el tiempo perdido")
	if MatchClock.calculate_added_time_seconds(MatchClock.CLOCK_CONTINUOUS, 5, 0.0, 0) != 60:
		failures.append("MatchClock: reloj continuo no garantizó el minuto mínimo de añadido")
	var long_continuous_added := MatchClock.calculate_added_time_seconds(MatchClock.CLOCK_CONTINUOUS, 20, 721.0, 1)
	if long_continuous_added != 721:
		failures.append("MatchClock: el reloj continuo aplicó un límite máximo indebido")
	if MatchClock.calculate_added_time_seconds("unknown", 5, 90.0, 0) != 0:
		failures.append("MatchClock: aceptó un método de reloj desconocido")
	if MatchClock.can_start_extra_time(true, true, true) != true:
		failures.append("MatchClock: no permitió prórroga cuando está habilitada, hay empate y la competición la permite")
	if MatchClock.can_start_extra_time(true, false, true) or MatchClock.can_start_extra_time(true, true, false):
		failures.append("MatchClock: inició prórroga sin empate o contra el reglamento de competición")
	var regular_phases := MatchClock.period_sequence(false, true)
	if regular_phases != ["first_half", "half_time", "second_half", "full_time"]:
		failures.append("MatchClock: secuencia reglamentaria básica incorrecta")
	var extra_phases := MatchClock.period_sequence(true, true)
	if extra_phases != ["first_half", "half_time", "second_half", "extra_time_first_half", "extra_time_half_time", "extra_time_second_half", "extra_time_end", "full_time", "penalty_shootout"]:
		failures.append("MatchClock: secuencia de prórroga y penaltis incorrecta")


	# Substitution limits and windows from GAME_DESIGN.md.
	var official_subs := MatchSubs.create_team_state(false, false)
	var sub_result := MatchSubs.apply_substitution(official_subs, "home_01", "bench_01", "first_half_window", "match")
	if not bool(sub_result.get("ok", false)):
		failures.append("MatchSubs: rechazó un cambio oficial válido")
	else:
		official_subs = sub_result.state
	sub_result = MatchSubs.apply_substitution(official_subs, "home_02", "bench_02", "first_half_window", "match")
	if not bool(sub_result.get("ok", false)) or int(sub_result.state.windows_used) != 1:
		failures.append("MatchSubs: cobró dos ventanas por dos cambios en la misma interrupción")
	else:
		official_subs = sub_result.state
	sub_result = MatchSubs.apply_substitution(official_subs, "home_03", "bench_03", "half_time", "half_time")
	if not bool(sub_result.get("ok", false)) or int(sub_result.state.windows_used) != 2:
		failures.append("MatchSubs: el descanso no contó como ventana")
	else:
		official_subs = sub_result.state
	sub_result = MatchSubs.apply_substitution(official_subs, "home_04", "bench_04", "second_half_window", "match")
	if not bool(sub_result.get("ok", false)) or int(sub_result.state.windows_used) != 3:
		failures.append("MatchSubs: no permitió la tercera ventana reglamentaria")
	else:
		official_subs = sub_result.state
	sub_result = MatchSubs.apply_substitution(official_subs, "home_05", "bench_05", "second_half_window", "match")
	if not bool(sub_result.get("ok", false)) or int(sub_result.state.substitutions_used) != 5:
		failures.append("MatchSubs: no permitió el quinto cambio en una ventana ya abierta")
	else:
		official_subs = sub_result.state
	if bool(MatchSubs.can_substitute(official_subs, "home_06", "bench_06", "late_window", "match").get("ok", false)):
		failures.append("MatchSubs: permitió una cuarta ventana en tiempo reglamentario")
	if bool(MatchSubs.can_substitute(official_subs, "home_06", "home_01", "second_half_window", "match").get("ok", false)):
		failures.append("MatchSubs: permitió que un jugador sustituido volviera al campo")
	var injured_state := MatchSubs.create_team_state(false, false)
	var injury_change := MatchSubs.apply_substitution(injured_state, "home_injured", "bench_fit", "injury_window", "injury_stoppage")
	if not bool(injury_change.get("ok", false)) or int(injury_change.state.substitutions_used) != 1 or int(injury_change.state.windows_used) != 1:
		failures.append("MatchSubs: una sustitución por lesión no consumió cambio y ventana")
	var extra_time_state := MatchSubs.create_team_state(false, true)
	for index in range(5):
		var window_name := "window_%d" % mini(index, 3)
		var extra_sub := MatchSubs.apply_substitution(extra_time_state, "starter_%d" % index, "reserve_%d" % index, window_name, "match")
		if not bool(extra_sub.get("ok", false)):
			failures.append("MatchSubs: rechazó uno de los cinco cambios antes de prórroga")
			break
		extra_time_state = extra_sub.state
	var sixth_sub := MatchSubs.apply_substitution(extra_time_state, "starter_6", "reserve_6", "window_3", "extra_time_half_time")
	if not bool(sixth_sub.get("ok", false)) or int(sixth_sub.state.substitutions_used) != 6 or int(sixth_sub.state.windows_used) != 4:
		failures.append("MatchSubs: no concedió el sexto cambio y cuarta ventana en prórroga")
	if bool(sixth_sub.get("ok", false)):
		var pre_penalty_sub := MatchSubs.apply_substitution(sixth_sub.state, "starter_7", "reserve_7", "before_penalties", "before_penalties")
		if bool(pre_penalty_sub.get("ok", false)):
			failures.append("MatchSubs: permitió cambio antes de penaltis después de agotar los límites")
	var friendly_state := MatchSubs.create_team_state(true, false)
	for index in range(11):
		var friendly_sub := MatchSubs.apply_substitution(friendly_state, "friendly_%d" % index, "friendly_bench_%d" % index, "friendly_window_%d" % index, "match")
		if not bool(friendly_sub.get("ok", false)):
			failures.append("MatchSubs: bloqueó una sustitución amistosa sin límite oficial")
			break
		friendly_state = friendly_sub.state
	if int(friendly_state.substitutions_used) != 11:
		failures.append("MatchSubs: no contabilizó los once cambios amistosos")
	var dismissed_state := MatchSubs.mark_player_dismissed(MatchSubs.create_team_state(), "sent_off")
	if bool(MatchSubs.can_substitute(dismissed_state, "starter", "sent_off", "window", "match").get("ok", false)):
		failures.append("MatchSubs: permitió sustituir a un jugador expulsado")
	var severe_state := MatchSubs.mark_player_severely_injured(MatchSubs.create_team_state(), "severely_injured")
	if bool(MatchSubs.can_substitute(severe_state, "starter", "severely_injured", "window", "match").get("ok", false)):
		failures.append("MatchSubs: permitió que un jugador gravemente lesionado entrara")

	# Realista optional module: no effect without package, bounded fatigue with package.
	var realism_profile := {"enabled": true, "profile_id": "realism_balanced", "fatigue_enabled": true, "movement_fatigue_per_second": 0.10, "recovery_per_second": 0.16, "minimum_speed_multiplier": 0.78}
	if not RealismModule.validate_profile(realism_profile):
		failures.append("Realista: rechazó un perfil válido")
	var invalid_realism_profile := realism_profile.duplicate(true)
	invalid_realism_profile.minimum_speed_multiplier = 1.4
	if RealismModule.validate_profile(invalid_realism_profile):
		failures.append("Realista: aceptó un multiplicador de velocidad fuera de límites")
	if not is_equal_approx(RealismModule.movement_speed_multiplier(100.0, realism_profile), 1.0):
		failures.append("Realista: redujo velocidad con resistencia completa")
	if RealismModule.movement_speed_multiplier(0.0, realism_profile) < 0.779:
		failures.append("Realista: no respetó el mínimo de velocidad configurado")
	if not is_equal_approx(RealismModule.update_stamina(100.0, true, 10.0, realism_profile), 99.0):
		failures.append("Realista: cálculo de fatiga por movimiento incorrecto")
	if not is_equal_approx(RealismModule.update_stamina(50.0, false, 1.0, realism_profile), 50.16):
		failures.append("Realista: recuperación durante descanso incorrecta")
	var base_profile := {"enabled": false, "fatigue_enabled": false}
	if not is_equal_approx(RealismModule.movement_speed_multiplier(0.0, base_profile), 1.0):
		failures.append("Realista: alteró el comportamiento base sin estar instalado")

	# Live clock state machine: real periods, interruption handling and user-controlled breaks.
	var default_clock_state := MatchClockState.create_state({"half_length_minutes": 4, "clock_mode": "invalid"})
	if int(default_clock_state.half_length_minutes) != 5 or int(default_clock_state.period_duration_seconds) != 300 or str(default_clock_state.clock_mode) != "continuous":
		failures.append("MatchClockState: no aplicó valores seguros para ajustes de reloj inválidos")
	var continuous_state := MatchClockState.create_state({"half_length_minutes": 3, "clock_mode": "continuous"})
	continuous_state = MatchClockState.set_interruption(continuous_state, "injury", true)
	var clock_tick: Dictionary = MatchClockState.tick(continuous_state, 30.0)
	continuous_state = clock_tick.state
	if not is_equal_approx(float(continuous_state.elapsed_seconds), 30.0) or not is_equal_approx(float(continuous_state.lost_seconds), 30.0):
		failures.append("MatchClockState: reloj continuo no contó la interrupción como tiempo perdido")
	continuous_state = MatchClockState.set_interruption(continuous_state, "injury", false)
	clock_tick = MatchClockState.tick(continuous_state, 150.0)
	continuous_state = clock_tick.state
	if int(continuous_state.added_seconds) != 30 or str(continuous_state.phase) != "first_half":
		failures.append("MatchClockState: no calculó el añadido continuo después de una interrupción")
	clock_tick = MatchClockState.tick(continuous_state, 30.0)
	continuous_state = clock_tick.state
	if str(continuous_state.phase) != "half_time" or not bool(continuous_state.awaiting_user):
		failures.append("MatchClockState: no detuvo el partido en el descanso")
	var waiting_tick: Dictionary = MatchClockState.tick(continuous_state, 90.0)
	if not is_equal_approx(float(waiting_tick.state.elapsed_seconds), float(continuous_state.elapsed_seconds)):
		failures.append("MatchClockState: avanzó el reloj mientras esperaba la decisión del usuario")
	var break_result: Dictionary = MatchClockState.continue_after_break(continuous_state)
	if not bool(break_result.get("ok", false)) or str(break_result.state.phase) != "second_half":
		failures.append("MatchClockState: no esperó la decisión del usuario para iniciar el segundo tiempo")
	var stopped_state := MatchClockState.create_state({"half_length_minutes": 3, "clock_mode": "stopped"})
	stopped_state = MatchClockState.set_interruption(stopped_state, "throw_in", true)
	clock_tick = MatchClockState.tick(stopped_state, 45.0)
	if not is_equal_approx(float(clock_tick.state.elapsed_seconds), 0.0):
		failures.append("MatchClockState: el reloj detenido avanzó durante una interrupción")
	stopped_state = MatchClockState.set_interruption(stopped_state, "throw_in", false)
	clock_tick = MatchClockState.tick(stopped_state, 180.0)
	stopped_state = clock_tick.state
	if int(stopped_state.added_seconds) < 60 or int(stopped_state.added_seconds) > 180:
		failures.append("MatchClockState: no añadió entre 1 y 3 minutos con reloj detenido")
	clock_tick = MatchClockState.tick(stopped_state, float(stopped_state.added_seconds))
	if str(clock_tick.state.phase) != "half_time":
		failures.append("MatchClockState: no cerró el período tras completar el añadido")
	var extra_state := MatchClockState.create_state({"half_length_minutes": 3, "clock_mode": "continuous", "extra_time_enabled": true, "competition_allows_extra_time": true, "penalties_enabled": true, "competition_allows_penalties": true})
	clock_tick = MatchClockState.tick(extra_state, 240.0)
	extra_state = clock_tick.state
	break_result = MatchClockState.continue_after_break(extra_state)
	extra_state = break_result.state
	clock_tick = MatchClockState.tick(extra_state, 240.0)
	extra_state = clock_tick.state
	if str(extra_state.phase) != "extra_time_first_half":
		failures.append("MatchClockState: no inició la prórroga cuando el empate y el reglamento lo permitían")
	clock_tick = MatchClockState.tick(extra_state, 120.0)
	extra_state = clock_tick.state
	if str(extra_state.phase) != "extra_time_half_time" or not bool(extra_state.awaiting_user):
		failures.append("MatchClockState: no detuvo el partido en el descanso de prórroga")
	break_result = MatchClockState.continue_after_break(extra_state)
	extra_state = break_result.state
	clock_tick = MatchClockState.tick(extra_state, 120.0)
	if str(clock_tick.state.phase) != "penalty_shootout" or not clock_tick.events.has("penalty_shootout_pending"):
		failures.append("MatchClockState: no derivó a penaltis cuando el reglamento lo exigía")
	var no_extra_state := MatchClockState.create_state({"half_length_minutes": 3, "clock_mode": "continuous"})
	clock_tick = MatchClockState.tick(no_extra_state, 240.0)
	no_extra_state = clock_tick.state
	break_result = MatchClockState.continue_after_break(no_extra_state)
	no_extra_state = break_result.state
	clock_tick = MatchClockState.tick(no_extra_state, 240.0)
	if str(clock_tick.state.phase) != "full_time":
		failures.append("MatchClockState: impuso prórroga sin autorización de la competición")

	if failures.is_empty():
		print("FUTBOL_NOVA_11V11_FOUNDATION_TESTS: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
