extends SceneTree

const LegendService = preload("res://scripts/legend/legend_career_service.gd")
const MatchContract = preload("res://scripts/core/match_contract.gd")

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var service := LegendService.new()
	root.add_child(service)
	var invalid := service.start_career({"full_name": "Jugador Inválido", "age": 13, "primary_position": "MCO", "specialization": "velocista"})
	assert(not bool(invalid.get("ok", false)), "No se debe permitir crear un jugador menor de 14 años")

	var created := service.start_career({
		"full_name": "Jugador de Prueba",
		"nationality_id": "CUB",
		"age": 14,
		"primary_position": "MCO",
		"secondary_position": "MC",
		"preferred_foot": "right",
		"height_cm": 171,
		"weight_kg": 65,
		"specialization": "velocista"
	})
	assert(bool(created.get("ok", false)), "Debe crearse y guardarse un futbolista válido")
	var state: Dictionary = service.get_career_state()
	assert(str(state.get("status", "")) == "academy", "Un jugador de 14 años debe comenzar en cantera")
	assert(str(state.get("club_id", "")) == "", "El creador no debe asignar un club automáticamente")
	assert(int(state.player.get("attributes", {}).size()) == 35, "El jugador debe recibir los 35 atributos individuales")
	assert(state.player.get("attribute_groups", {}).size() == 7, "Los atributos deben estar agrupados en siete categorías")
	assert(not bool(service.accept_contract({"club_id": "club_test", "seasons": 2}).get("ok", false)), "Un jugador de 14 años no puede firmar contrato profesional")

	var match_result := service.record_match({
		"match_id": "legend_match_001",
		"appearances": 1,
		"starts": 1,
		"minutes": 75,
		"goals": 2,
		"assists": 1,
		"shots": 4,
		"shots_on_target": 3,
		"passes": 32,
		"passes_completed": 28,
		"team_goals": 3,
		"opponent_goals": 1,
		"dribbles": 5,
		"dribbles_completed": 4,
		"key_passes": 4,
		"chances_created": 2,
		"tackles": 3,
		"interceptions": 2,
		"recoveries": 5,
		"fouls": 1,
		"fouls_won": 2,
		"yellow_cards": 1,
		"red_cards": 0,
		"saves": 0,
		"clean_sheets": 0,
		"penalties_scored": 0,
		"penalties_missed": 0,
		"player_of_match": 1,
		"rating": 8.2
	})
	assert(bool(match_result.get("ok", false)), "Debe guardar las estadísticas de un partido")
	assert(int(service.get_career_state().career_stats.get("goals", 0)) == 2, "Los goles deben acumularse en la carrera")
	assert(int(service.get_career_state().career_stats.get("wins", 0)) == 1, "El resultado debe acumular una victoria")
	assert(int(service.get_career_state().career_stats.get("key_passes", 0)) == 4, "Debe acumular los pases clave")
	assert(int(service.get_career_state().career_stats.get("chances_created", 0)) == 2, "Debe acumular las ocasiones creadas")
	assert(int(service.get_career_state().career_stats.get("tackles", 0)) == 3, "Debe acumular las entradas")
	assert(int(service.get_career_state().career_stats.get("interceptions", 0)) == 2, "Debe acumular las intercepciones")
	assert(int(service.get_career_state().career_stats.get("recoveries", 0)) == 5, "Debe acumular las recuperaciones")
	assert(int(service.get_career_state().career_stats.get("fouls", 0)) == 1 and int(service.get_career_state().career_stats.get("fouls_won", 0)) == 2, "Debe acumular las faltas cometidas y recibidas")
	assert(int(service.get_career_state().career_stats.get("yellow_cards", 0)) == 1, "Debe acumular las tarjetas amarillas")
	assert(int(service.get_career_state().career_stats.get("player_of_match", 0)) == 1, "Debe acumular los premios al jugador del partido")
	assert(is_equal_approx(float(service.get_career_state().career_stats.get("average_rating", 0.0)), 8.2), "Debe calcular la valoración media de los partidos puntuados")
	assert(int(service.get_career_state().season_stats.get("wins", 0)) == 1, "La estadística de temporada debe registrar la victoria")
	assert(is_equal_approx(float(service.get_career_state().career_stats.get("dribble_success_rate", 0.0)), 80.0), "Debe calcular el porcentaje de regates completados")
	var substitute_result := service.record_match({"match_id": "legend_match_002", "appearances": 1, "starts": 0, "minutes": 15})
	assert(bool(substitute_result.get("ok", false)), "Debe guardar una aparición como suplente")
	assert(int(service.get_career_state().career_stats.get("substitute_appearances", 0)) == 1, "Debe contabilizar las apariciones como suplente")
	assert(not bool(service.record_match({"match_id": "legend_match_001", "appearances": 1}).get("ok", false)), "Un partido no puede contabilizarse dos veces")

	assert(bool(service.complete_season().get("ok", false)), "Debe poder cerrar la temporada")
	assert(service.get_career_state().get("season_history", []).size() == 1, "Debe conservar el resumen de la temporada cerrada")
	assert(int(service.get_career_state().season_history[0].statistics.get("goals", 0)) == 2, "El historial debe conservar los goles de la temporada")
	assert(bool(service.advance_season().get("ok", false)), "Un jugador de cantera debe poder avanzar a los 15 años")
	assert(int(service.get_career_state().player.get("age", 0)) == 15, "El jugador debe cumplir 15 años al avanzar de temporada")
	assert(str(service.get_career_state().get("status", "")) == "trial", "Al cumplir 15 debe pasar a pruebas")
	assert(bool(service.complete_season().get("ok", false)), "Debe poder cerrar la temporada de pruebas")
	var retired_young := service.retire_player()
	assert(bool(retired_young.get("ok", false)), "Debe poder retirarse al final de temporada sin contrato")
	assert(not bool(service.get_career_state().get("manager_unlocked", true)), "La retirada antes de los 20 no desbloquea Manager")

	var adult_created := service.start_career({
		"full_name": "Jugador Adulto",
		"nationality_id": "CUB",
		"age": 20,
		"primary_position": "MC",
		"preferred_foot": "both",
		"height_cm": 180,
		"weight_kg": 75,
		"specialization": "organizador"
	})
	assert(bool(adult_created.get("ok", false)), "Debe poder comenzar una carrera adulta")
	assert(bool(service.accept_contract({"club_id": "club_test", "seasons": 2, "weekly_salary": 1200}).get("ok", false)), "Un jugador de 15 años o más puede aceptar una oferta válida")
	assert(bool(service.complete_season().get("ok", false)), "Debe finalizar la primera temporada")
	assert(not bool(service.retire_player().get("ok", false)), "No puede retirarse con contrato vigente")
	assert(bool(service.advance_season().get("ok", false)), "Debe avanzar a la siguiente temporada")
	assert(int(service.get_career_state().player.get("age", 0)) == 21, "La edad debe avanzar al comenzar una nueva temporada")
	assert(bool(service.complete_season().get("ok", false)), "Debe finalizar la temporada contractual")
	assert(not bool(service.get_career_state().contract.get("active", true)), "El contrato debe expirar al cerrar su última temporada")
	assert(bool(service.retire_player().get("ok", false)), "Debe permitir la retirada tras finalizar el contrato")
	assert(bool(service.get_career_state().get("manager_unlocked", false)), "La retirada con 20 años o más debe desbloquear Manager")

	var veteran_created := service.start_career({
		"full_name": "Jugador Veterano",
		"nationality_id": "CUB",
		"age": 45,
		"primary_position": "MC",
		"preferred_foot": "right",
		"height_cm": 175,
		"weight_kg": 72,
		"specialization": "organizador"
	})
	assert(bool(veteran_created.get("ok", false)), "Debe poder crear un jugador de 45 años")
	assert(not bool(service.accept_contract({"club_id": "club_test", "seasons": 2}).get("ok", false)), "Un jugador de 45 años no puede firmar un contrato que exceda la edad máxima")
	assert(bool(service.accept_contract({"club_id": "club_test", "seasons": 1}).get("ok", false)), "Un jugador de 45 años puede aceptar como máximo una temporada")
	assert(bool(service.complete_season().get("ok", false)), "Debe finalizar la última temporada a los 45 años")
	assert(not bool(service.advance_season().get("ok", false)), "No se puede superar la edad máxima de 45 años")
	assert(bool(service.retire_player().get("ok", false)), "Debe poder retirarse al finalizar el contrato a los 45 años")
	var catalog_attributes := {}
	for attribute_key in LegendService.ATTRIBUTE_KEYS:
		catalog_attributes[attribute_key] = 63
	var catalog_player := {
		"id": "FN-PLAYER-CATALOG-TEST",
		"display_name": "Futbolista Nova de Prueba",
		"nationality_id": "ENG",
		"birth_date": service._birth_date_for_age(22),
		"primary_position": "MCO",
		"secondary_positions": ["MC"],
		"preferred_foot": "left",
		"height_cm": 178,
		"weight_kg": 72,
		"estimated_overall": 64,
		"potential": 78,
		"attributes": catalog_attributes,
		"club_id": "FN-CLUB-TEST",
		"club_name": "Club Nova de Prueba"
	}
	var catalog_started := service.start_career_from_catalog(catalog_player)
	assert(bool(catalog_started.get("ok", false)), "Debe iniciar una carrera con un jugador del catálogo Nova")
	var catalog_state: Dictionary = service.get_career_state()
	assert(str(catalog_state.player.get("source_player_id", "")) == "FN-PLAYER-CATALOG-TEST", "Debe conservar el ID del jugador original")
	assert(str(catalog_state.player.get("origin", "")) == "nova_catalog", "Debe identificar el origen del catálogo Nova")
	assert(str(catalog_state.get("club_id", "")) == "FN-CLUB-TEST", "Debe conservar el club original")
	assert(catalog_state.player.get("attributes", {}) == catalog_attributes, "Los 35 atributos originales no deben regenerarse ni modificarse")
	assert(int(catalog_state.player.get("overall", 0)) == 64 and int(catalog_state.player.get("potential", 0)) == 78, "Debe conservar media y potencial del catálogo")
	assert(str(catalog_state.player.get("preferred_foot", "")) == "left", "Debe conservar el pie hábil original")
	assert(bool(service.complete_season().get("ok", false)), "El jugador seleccionado debe poder finalizar su primera temporada")
	assert(bool(service.advance_season().get("ok", false)), "El jugador del catálogo debe poder continuar su carrera sin inventar un contrato")
	assert(int(service.get_career_state().player.get("age", 0)) == 23, "La edad del jugador del catálogo debe avanzar al comenzar una nueva temporada")
	assert(not bool(service.start_career_from_catalog({"id": "invalid"}).get("ok", false)), "Debe rechazar fichas de catálogo incompletas")


	var contract_state: Dictionary = MatchContract.create_match("legend_contract_match_001", "FN-CLUB-TEST", "FN-OPPONENT-TEST")
	assert(MatchContract.record_goal(contract_state, "FN-CLUB-TEST", "FN-PLAYER-CATALOG-TEST", 12), "El contrato debe registrar el gol del futbolista")
	assert(MatchContract.record_goal(contract_state, "FN-CLUB-TEST", "FN-PLAYER-CATALOG-TEST", 67), "El contrato debe registrar el segundo gol del equipo")
	assert(MatchContract.finish_match(contract_state, 90), "El contrato debe cerrar el partido")
	var finished_contract_result: Dictionary = MatchContract.to_result(contract_state)
	var bridged_match := service.record_match_from_contract(
		finished_contract_result,
		{
			"player_id": "FN-PLAYER-CATALOG-TEST",
			"appearances": 1,
			"starts": 1,
			"minutes": 90,
			"goals": 1,
			"assists": 1,
			"shots": 2,
			"shots_on_target": 1,
			"passes": 25,
			"passes_completed": 22,
			"rating": 8.0
		},
		"FN-CLUB-TEST"
	)
	assert(bool(bridged_match.get("ok", false)), "Debe convertir un resultado finalizado y las estadísticas del futbolista en un registro de Leyenda")
	assert(int(service.get_career_state().career_stats.get("goals", 0)) == 1, "El puente de partido debe acumular los goles del futbolista")
	assert(int(service.get_career_state().career_stats.get("wins", 0)) == 1, "El puente debe derivar el resultado desde el equipo del futbolista")
	assert(is_equal_approx(float(service.get_career_state().career_stats.get("pass_accuracy", 0.0)), 88.0), "El puente debe conservar y calcular la precisión de pase")
	var wrong_player_match := service.record_match_from_contract(
		{"match_id": "legend_contract_match_002", "status": "finished", "home_team_id": "FN-CLUB-TEST", "away_team_id": "FN-OPPONENT-TEST", "home_goals": 0, "away_goals": 0},
		{"player_id": "PLAYER-OTHER", "appearances": 1},
		"FN-CLUB-TEST"
	)
	assert(not bool(wrong_player_match.get("ok", false)), "No debe aceptar estadísticas pertenecientes a otro futbolista")
	var wrong_team_match := service.record_match_from_contract(
		{"match_id": "legend_contract_match_003", "status": "finished", "home_team_id": "FN-CLUB-TEST", "away_team_id": "FN-OPPONENT-TEST", "home_goals": 0, "away_goals": 0},
		{"player_id": "FN-PLAYER-CATALOG-TEST", "appearances": 1},
		"FN-OPPONENT-TEST"
	)
	assert(not bool(wrong_team_match.get("ok", false)), "No debe registrar estadísticas para un club distinto al del futbolista")


	print("FUTBOL_NOVA_LEGEND_CAREER_TESTS: PASS")
	quit(0)
