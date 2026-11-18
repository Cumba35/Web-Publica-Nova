extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")

func _initialize() -> void:
	call_deferred("_run_acceptance_test")

func _run_acceptance_test() -> void:
	var failures := PackedStringArray()
	var game = MAIN_SCENE.instantiate()
	root.add_child(game)

	# The main scene builds its field, HUD, hub and match controller over several frames.
	for frame_index in range(40):
		await process_frame
		if game.game_hub != null and game.match_11v11_controller != null:
			break

	if game.game_hub == null:
		failures.append("La escena principal no creó el menú de juego.")
	if game.match_11v11_controller == null:
		failures.append("La escena principal no creó el motor de partido 11 contra 11.")
	if FootballData.registry == null:
		failures.append("El catálogo offline no creó el registro de clubes.")

	if game.game_hub != null:
		for page in ["home", "online", "modes", "settings"]:
			game.game_hub._open_main_page(page)
			await process_frame
			if game.game_hub.current_page != page:
				failures.append("No se pudo abrir la pantalla principal: " + page)
			if game.game_hub.content_box.get_child_count() == 0:
				failures.append("La pantalla principal está vacía: " + page)

		for category in ["Edición", "Módulos", "Música", "Juego", "Datos", "Controles", "Audio", "Gráficos", "Accesibilidad", "Administración", "Información"]:
			game.game_hub._open_settings_category(category)
			await process_frame
			if game.game_hub.current_subpage != category:
				failures.append("No se pudo abrir la categoría de configuración: " + category)
			if game.game_hub.content_box.get_child_count() == 0:
				failures.append("La categoría de configuración no muestra contenido: " + category)

		game.game_hub._show_home()
		await process_frame

	# Use the same pre-match screen and button path as a real player.
	if game.match_11v11_controller != null and FootballData.registry != null:
		game._open_pre_match_setup()
		await process_frame
		var setup = game.pre_match_setup
		if setup == null or not is_instance_valid(setup):
			failures.append("No se abrió la preparación del amistoso.")
		else:
			if setup._home_teams.item_count < 2 or setup._away_teams.item_count < 2:
				failures.append("La preparación no muestra al menos dos clubes elegibles.")
			if setup._start_button.disabled:
				failures.append("El botón Iniciar amistoso está bloqueado pese a existir dos clubes válidos.")
			var selected_home_id: String = str(setup._selected_team_id(setup._home_teams))
			var selected_away_id: String = str(setup._selected_team_id(setup._away_teams))
			var expected_home_name := str(FootballData.registry.teams_by_id.get(selected_home_id, {}).get("name", selected_home_id))
			var expected_away_name := str(FootballData.registry.teams_by_id.get(selected_away_id, {}).get("name", selected_away_id))
			if selected_home_id.is_empty() or selected_away_id.is_empty() or selected_home_id == selected_away_id:
				failures.append("La selección inicial no contiene dos clubes distintos.")
			else:
				setup._start_match()
				await process_frame
				var summary: Dictionary = game.match_11v11_controller.get_match_summary()
				if not bool(summary.get("active", false)):
					failures.append("El motor rechazó el amistoso iniciado desde la pantalla de preparación.")
				if int(summary.get("home_players", 0)) != 11:
					failures.append("El equipo local no quedó con once jugadores en el campo.")
				if int(summary.get("away_players", 0)) != 11:
					failures.append("El equipo visitante no quedó con once jugadores en el campo.")
				if int(summary.get("ai_players", 0)) != 21:
					failures.append("El partido no creó los 21 futbolistas de IA además del jugador controlado.")
				if game.player == null or not is_instance_valid(game.player):
					failures.append("El jugador controlado dejó de existir al iniciar el amistoso.")
				elif game.match_11v11_controller._player != game.player:
					failures.append("El motor conserva una referencia antigua en vez del futbolista controlado actual.")
				game.match_11v11_controller.set_match_paused(true)
				if game.player.is_physics_processing():
					failures.append("El jugador siguió moviéndose durante la pausa del partido.")
				game.match_11v11_controller.set_match_paused(false)
				if not game.player.is_physics_processing():
					failures.append("El jugador no recuperó sus controles al reanudar el partido.")
				game.match_11v11_controller._transfer_possession(game.player, true, "controlled_player")
				if not game.ball.freeze:
					failures.append("La prueba no pudo establecer la posesión previa al reinicio.")
				game.ball.freeze = false
				game.ball.sleeping = true
				if not game.ball.sleeping:
					failures.append("La prueba no pudo simular un balón dormido antes del reinicio.")
				game._reset_ball()
				if game.match_11v11_controller.has_controlled_possession():
					failures.append("El reinicio tras un gol conservó la posesión anterior.")
				if game.ball.freeze:
					failures.append("El balón quedó congelado después del reinicio.")
				if game.ball.sleeping:
					failures.append("El balón siguió dormido después del reinicio.")
				if game.ball.global_position.distance_to(Vector3(0.0, 0.35, 0.0)) > 0.01:
					failures.append("El balón no regresó al centro después del reinicio.")
				if str(summary.get("home_team_id", "")) != selected_home_id:
					failures.append("El motor no conservó el ID del club local seleccionado.")
				if str(summary.get("away_team_id", "")) != selected_away_id:
					failures.append("El motor no conservó el ID del club visitante seleccionado.")
				if str(game.home_team_display_name) != expected_home_name:
					failures.append("El HUD no muestra el nombre correcto del equipo local.")
				if str(game.away_team_display_name) != expected_away_name:
					failures.append("El HUD no muestra el nombre correcto del equipo visitante.")
				if game.match_clock_label == null or not game.match_clock_label.text.contains("PRIMER TIEMPO"):
					failures.append("El reloj del amistoso no muestra el primer tiempo.")

	if game.match_11v11_controller != null:
		game.match_11v11_controller.stop_match()
	game.queue_free()

	if not failures.is_empty():
		for failure in failures:
			push_error("FÚTBOL NOVA ACCEPTANCE: " + failure)
		quit(1)
		return
	print("FÚTBOL NOVA ACCEPTANCE: cuatro pantallas, once categorías y amistoso 11v11 superados.")
	quit(0)
