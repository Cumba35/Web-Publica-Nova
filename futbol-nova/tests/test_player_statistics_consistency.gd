extends SceneTree

const STATISTICS = preload("res://scripts/data/player_statistics_service.gd")

func _initialize() -> void:
	var player := STATISTICS.normalize_player({
		"id": "TEST-PLAYER-001",
		"display_name": "Jugador de prueba",
		"nationality_id": "CUB",
		"primary_position": "MCO",
		"attributes": {}
	})
	var stats: Dictionary = player.statistics
	assert(stats.schema_version == "1.0.0")
	assert(stats.data_status == "sin_partidos_registrados")
	assert(stats.career.appearances == 0)
	assert(stats.current_season.goals == 0)
	assert(stats.career.average_rating == null)
	assert(stats.career.pass_accuracy == null)
	assert(stats.career.goals_per_appearance == null)
	assert(stats.career.assists_per_appearance == null)
	assert(stats.season_history.is_empty())

	var calculated := STATISTICS.normalize_totals({
		"appearances": 5,
		"goals": 2,
		"assists": 1,
		"passes": 100,
		"passes_completed": 80,
		"dribbles": 10,
		"dribbles_completed": 6,
		"rated_appearances": 2,
		"rating_total": 16.0
	})
	assert(is_equal_approx(float(calculated.goals_per_appearance), 0.4))
	assert(is_equal_approx(float(calculated.assists_per_appearance), 0.2))
	assert(is_equal_approx(float(calculated.pass_accuracy), 80.0))
	assert(is_equal_approx(float(calculated.dribble_success_rate), 60.0))
	assert(is_equal_approx(float(calculated.average_rating), 8.0))

	var players := {}
	var home_ids: Array[String] = []
	var away_ids: Array[String] = []
	for index in range(22):
		var home_player_id := "HOME-%02d" % index
		var away_player_id := "AWAY-%02d" % index
		players[home_player_id] = STATISTICS.normalize_player({"id": home_player_id, "primary_position": "POR" if index == 0 else "DC"})
		players[away_player_id] = STATISTICS.normalize_player({"id": away_player_id, "primary_position": "POR" if index == 0 else "DC"})
		if index < 11:
			home_ids.append(home_player_id)
			away_ids.append(away_player_id)
	var match_result := {
		"home_team_id": "HOME",
		"away_team_id": "AWAY",
		"home_goals": 2,
		"away_goals": 0,
		"minute": 90,
		"lineups": {"home": home_ids, "away": away_ids},
		"events": [
			{"type": "goal", "team_id": "HOME", "player_id": "HOME-01"},
			{"type": "goal", "team_id": "HOME", "player_id": "HOME-02"}
		]
	}
	var recorded: Dictionary = STATISTICS.record_match(players, match_result)
	assert(recorded.ok and int(recorded.updated_count) == 22)
	var scorer: Dictionary = recorded.players["HOME-01"].statistics
	assert(scorer.career.appearances == 1 and scorer.career.starts == 1 and scorer.career.minutes == 90)
	assert(scorer.career.wins == 1 and scorer.career.goals == 1)
	assert(scorer.current_season.appearances == 1 and scorer.current_season.goals == 1)
	var keeper: Dictionary = recorded.players["HOME-00"].statistics
	assert(keeper.career.clean_sheets == 1)
	assert(recorded.players["AWAY-00"].statistics.career.losses == 1)
	assert(recorded.players["HOME-11"].statistics.career.appearances == 0)
	var invalid_result := match_result.duplicate(true)
	invalid_result.lineups.home = home_ids.slice(0, 10)
	assert(not bool(STATISTICS.record_match(players, invalid_result).get("ok", false)))

	var anier_file := FileAccess.open("res://data/custom_players.json", FileAccess.READ)
	assert(anier_file != null)
	var custom_data: Dictionary = JSON.parse_string(anier_file.get_as_text())
	var anier: Dictionary = custom_data.players[0]
	assert(anier.id == "NOVA-PLAYER-0035")
	assert(anier.overall == 92 and anier.potential == 97)
	assert(anier.statistics.data_status == "sin_partidos_registrados")
	assert(anier.statistics.career.appearances == 0)
	assert(anier.statistics.career.average_rating == null)
	print("Player statistics consistency: PASS")
	quit(0)
