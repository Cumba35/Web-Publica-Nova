extends Node
class_name NovaContinentalLeagueModuleService

const MODULE_INDEX_PATH := "res://data/continental_leagues/manifest.json"
const EXPECTED_CONFEDERATIONS := ["AFC", "CAF", "CONCACAF", "CONMEBOL", "OFC", "UEFA"]

var modules_by_code: Dictionary = {}
var last_errors: PackedStringArray = PackedStringArray()

func _ready() -> void:
	var result := load_modules()
	if not bool(result.get("ok", false)):
		push_error("No se pudieron cargar los módulos continentales: " + "; ".join(last_errors))

func load_modules() -> Dictionary:
	modules_by_code.clear()
	last_errors.clear()
	var index := _read_json(MODULE_INDEX_PATH)
	if index.is_empty():
		last_errors.append("No se pudo leer el índice de módulos continentales.")
		return _result()
	var entries: Array = index.get("modules", [])
	if int(index.get("confederation_count", 0)) != EXPECTED_CONFEDERATIONS.size():
		last_errors.append("El índice no declara las seis confederaciones.")
	var paths_by_code := {}
	for entry in entries:
		if not entry is Dictionary:
			last_errors.append("Entrada de módulo continental inválida.")
			continue
		var code := str(entry.get("code", ""))
		var path := str(entry.get("path", ""))
		if not EXPECTED_CONFEDERATIONS.has(code) or paths_by_code.has(code):
			last_errors.append("Código de confederación desconocido o duplicado: " + code)
			continue
		if not path.begins_with("res://data/continental_leagues/") or path.contains(".."):
			last_errors.append("Ruta de módulo no permitida: " + path)
			continue
		paths_by_code[code] = path
	var league_ids := {}
	var association_ids := {}
	for code in EXPECTED_CONFEDERATIONS:
		if not paths_by_code.has(code):
			last_errors.append("Falta la ruta del módulo " + code)
			continue
		var module := _read_json(str(paths_by_code[code]))
		if module.is_empty():
			last_errors.append("No se pudo cargar el módulo " + code)
			continue
		if str(module.get("module_type", "")) != "continental_league_catalog":
			last_errors.append("Tipo de módulo incorrecto: " + code)
		if str(module.get("confederation_code", "")) != code or not bool(module.get("independent", false)):
			last_errors.append("Identidad o independencia incorrecta: " + code)
		if not module.get("countries", null) is Array or not module.get("leagues", null) is Array:
			last_errors.append("Estructura de países/ligas inválida: " + code)
			continue
		for country in module.countries:
			if not country is Dictionary or str(country.get("confederation_code", "")) != code:
				last_errors.append("País mal asignado dentro del módulo " + code)
				continue
			var association_id := str(country.get("association_id", ""))
			if not association_id.is_empty():
				if association_ids.has(association_id):
					last_errors.append("Asociación duplicada entre módulos: " + association_id)
				association_ids[association_id] = code
		for league in module.leagues:
			if not league is Dictionary:
				last_errors.append("Registro de liga inválido en " + code)
				continue
			var league_id := str(league.get("id", ""))
			if league_id.is_empty() or league_ids.has(league_id):
				last_errors.append("ID de liga vacío o duplicado: " + league_id)
			league_ids[league_id] = code
			if str(league.get("country", "")).is_empty() or str(league.get("league_name", "")).is_empty():
				last_errors.append("Liga sin país o nombre en " + code)
			if str(league.get("confederation_code", "")) != code:
				last_errors.append("Liga asignada a otra confederación: " + league_id)
			if str(league.get("region_id", "")).is_empty():
				last_errors.append("Liga sin región geográfica: " + league_id)
		modules_by_code[code] = module.duplicate(true)
	return _result()

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		last_errors.append("No existe el archivo: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_errors.append("No se pudo abrir: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		last_errors.append("JSON inválido: " + path)
		return {}
	return parsed

func _result() -> Dictionary:
	var league_count := get_all_leagues().size()
	return {
		"ok": last_errors.is_empty() and modules_by_code.size() == EXPECTED_CONFEDERATIONS.size(),
		"module_count": modules_by_code.size(),
		"league_count": league_count,
		"country_count": get_total_country_records(),
		"errors": last_errors.duplicate()
	}

func get_module(confederation_code: String) -> Dictionary:
	return modules_by_code.get(confederation_code.to_upper(), {}).duplicate(true)

func get_leagues(confederation_code: String) -> Array:
	var code := confederation_code.to_upper()
	var result: Array = []
	for league in modules_by_code.get(code, {}).get("leagues", []):
		var record: Dictionary = league.duplicate(true)
		record["confederation_code"] = code
		result.append(record)
	return result

func get_all_leagues() -> Array:
	var result: Array = []
	for code in EXPECTED_CONFEDERATIONS:
		for league in modules_by_code.get(code, {}).get("leagues", []):
			var record: Dictionary = league.duplicate(true)
			record["confederation_code"] = code
			result.append(record)
	return result

func get_total_country_records() -> int:
	var total := 0
	for code in modules_by_code:
		total += modules_by_code[code].get("countries", []).size()
	return total

func get_summary() -> Dictionary:
	var summary := {}
	for code in EXPECTED_CONFEDERATIONS:
		var module: Dictionary = modules_by_code.get(code, {})
		summary[code] = {
			"name": str(module.get("name", "")),
			"countries": module.get("countries", []).size(),
			"leagues": module.get("leagues", []).size(),
			"status": str(module.get("module_status", "missing"))
		}
	return summary
