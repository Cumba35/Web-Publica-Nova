extends SceneTree

const MODULE_SERVICE := preload("res://scripts/data/continental_league_module_service.gd")
const EXPECTED_CONFEDERATIONS := ["AFC", "CAF", "CONCACAF", "CONMEBOL", "OFC", "UEFA"]

func _initialize() -> void:
	var service = MODULE_SERVICE.new()
	var result: Dictionary = service.load_modules()
	var errors: PackedStringArray = result.get("errors", PackedStringArray())
	if not bool(result.get("ok", false)):
		for error in errors:
			push_error(str(error))
		quit(1)
		return
	if int(result.get("module_count", 0)) != EXPECTED_CONFEDERATIONS.size():
		push_error("No están cargados los seis módulos continentales.")
		quit(1)
		return
	if int(result.get("league_count", 0)) != 100:
		push_error("El primer corte debe contener 100 ligas únicas.")
		quit(1)
		return
	if int(result.get("country_count", 0)) != 212:
		push_error("El registro continental debe contener 212 asociaciones/registros, incluido el registro especial de Estados Unidos.")
		quit(1)
		return
	for code in EXPECTED_CONFEDERATIONS:
		var module: Dictionary = service.get_module(code)
		if module.is_empty() or str(module.get("confederation_code", "")) != code:
			push_error("Módulo ausente o mal asignado: " + code)
			quit(1)
			return
		for league in service.get_leagues(code):
			if str(league.get("id", "")).is_empty() or str(league.get("league_name", "")).is_empty():
				push_error("Liga sin identidad en el módulo " + code)
				quit(1)
				return
	var concacaf_countries: Array = service.get_module("CONCACAF").get("countries", [])
	var united_states_found := false
	for country in concacaf_countries:
		if str(country.get("country_code", "")) == "USA" or str(country.get("name", "")) == "United States":
			united_states_found = true
	if not united_states_found:
		push_error("Estados Unidos no está asociado al módulo CONCACAF.")
		quit(1)
		return
	for league in service.get_all_leagues():
		if str(league.get("confederation_code", "")).is_empty() or str(league.get("region_id", "")).is_empty():
			push_error("Cada liga debe identificar confederación y región.")
			quit(1)
			return
	if service.get_leagues("OFC").size() != 0:
		push_error("El módulo OFC debe conservar su catálogo vacío hasta importar ligas verificadas.")
		quit(1)
		return
	var browser_file := FileAccess.open("res://scripts/ui/league_download_catalog.gd", FileAccess.READ)
	if browser_file == null:
		push_error("No existe el navegador de ligas por confederación.")
		quit(1)
		return
	var browser_code := browser_file.get_as_text()
	if not browser_code.contains("ContinentalLeagues.get_all_leagues()") or not browser_code.contains("_confederation_filter"):
		push_error("El navegador no está conectado a los módulos y filtros continentales.")
		quit(1)
		return
	print("OK: seis módulos continentales independientes; %d ligas únicas catalogadas." % int(result.get("league_count", 0)))
	quit(0)
