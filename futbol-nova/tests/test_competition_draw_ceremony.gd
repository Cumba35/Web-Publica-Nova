extends SceneTree

const CEREMONY = preload("res://scripts/ui/competition_draw_ceremony.gd")

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var ceremony = CEREMONY.new()
	root.add_child(ceremony)
	await process_frame
	var resolved_draw := [
		{"team_id": "club_a", "team_name": "Club A", "group": "A", "association": "ARG"},
		{"team_id": "club_b", "team_name": "Club B", "group": "B", "association": "BRA"},
		{"team_id": "club_c", "team_name": "Club C", "group": "C", "association": "CHI"}
	]
	ceremony.present_draw("Competición de prueba", resolved_draw)
	assert(ceremony.visible, "The draw ceremony must become visible")
	assert(ceremony.reveal_index == 1, "The ceremony must reveal the first draw result before waiting")
	assert(ceremony.skip_button.text == "SALTAR SORTEO", "The ceremony must expose a skip action")
	ceremony.skip_draw()
	assert(ceremony.finished, "Skipping must complete the presentation")
	assert(ceremony.reveal_index == resolved_draw.size(), "Skipping must reveal every remaining result")
	assert(ceremony.draw_result == resolved_draw, "Skipping must preserve the already resolved draw")
	assert(ceremony.result_list.get_child_count() == resolved_draw.size(), "Every resolved participant must remain visible after skipping")
	var first_row: PanelContainer = ceremony.result_list.get_child(0)
	var first_label: Label = first_row.get_child(0)
	assert(first_label.text.contains("Club A") and first_label.text.contains("Grupo A"), "Revealed rows must include the club and its group")
	assert(ceremony.skip_button.text == "CONTINUAR", "The completed ceremony must offer a continue action")
	ceremony.queue_free()
	await process_frame
	print("Competition draw ceremony tests passed")
	quit(0)
