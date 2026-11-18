extends SceneTree

const SERVICE = preload("res://scripts/data/national_team_competition_catalog_service.gd")

func _initialize() -> void:
	var service = SERVICE.new()
	var result: Dictionary = service.load_catalog()
	assert(bool(result.get("ok", false)), "National team tournament catalog must load without errors: " + str(result.get("errors", [])))
	assert(int(result.get("competition_count", 0)) == 16, "The catalog must contain all registered global and confederation tournaments")
	for code in ["AFC", "CAF", "CONCACAF", "CONMEBOL", "OFC", "UEFA"]:
		assert(not service.get_competitions_for_confederation(code).is_empty(), "Every FIFA confederation must have national tournaments: " + code)
	assert(service.get_competition("fifa_world_cup").size() > 0, "FIFA World Cup must be registered")
	assert(service.get_competition("uefa_nations_league").size() > 0, "UEFA Nations League must be registered")
	assert(service.get_competition("concacaf_nations_league").size() > 0, "Concacaf Nations League must be registered")
	assert(service.get_competition("finalissima").size() > 0, "Finalissima must be registered")
	service.free()
	print("National team competition catalog tests passed.")
	quit(0)
