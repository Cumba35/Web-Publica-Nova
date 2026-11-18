extends Node
class_name NovaNationalTeamCompetitionCatalogService

const CATALOG_PATH := "res://data/international_national_team_competitions.json"
const REQUIRED_CONFEDERATIONS := ["AFC", "CAF", "CONCACAF", "CONMEBOL", "OFC", "UEFA"]

var competitions_by_id: Dictionary = {}
var last_errors: PackedStringArray = PackedStringArray()
var catalog_metadata: Dictionary = {}

func _ready() -> void:
	var result := load_catalog()
	if not bool(result.get("ok", false)):
		push_error("Catálogo de torneos de selecciones: " + "; ".join(last_errors))

func load_catalog() -> Dictionary:
	competitions_by_id.clear()
	last_errors.clear()
	catalog_metadata.clear()
	if not FileAccess.file_exists(CATALOG_PATH):
		last_errors.append("No existe " + CATALOG_PATH)
		return _result()
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		last_errors.append("No se pudo abrir el catálogo de torneos de selecciones.")
		return _result()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		last_errors.append("El catálogo de torneos de selecciones no es un objeto JSON.")
		return _result()
	catalog_metadata = parsed.duplicate(true)
	if not bool(parsed.get("separate_from_club_competitions", false)):
		last_errors.append("El catálogo debe estar separado de las competiciones de clubes.")
	var declared: Array = parsed.get("confederations", [])
	for code in REQUIRED_CONFEDERATIONS:
		if not declared.has(code):
			last_errors.append("Falta la confederación " + code)
	var ids := {}
	for entry in parsed.get("competitions", []):
		if not entry is Dictionary:
			last_errors.append("Hay una competición de selecciones con formato inválido.")
			continue
		var competition: Dictionary = entry
		var competition_id := str(competition.get("id", ""))
		if competition_id.is_empty() or ids.has(competition_id):
			last_errors.append("ID de competición vacío o duplicado: " + competition_id)
			continue
		ids[competition_id] = true
		if str(competition.get("name", "")).is_empty():
			last_errors.append("Competición sin nombre: " + competition_id)
		if str(competition.get("scope", "")) != "mens_senior_national_teams":
			last_errors.append("Ámbito no válido en " + competition_id)
		var confeds: Array = competition.get("confederations", [])
		if confeds.is_empty():
			last_errors.append("Competición sin confederación: " + competition_id)
		for code in confeds:
			if code != "FIFA" and not REQUIRED_CONFEDERATIONS.has(str(code)):
				last_errors.append("Confederación no reconocida en " + competition_id + ": " + str(code))
		if str(competition.get("draw_ceremony", "")) != "shared_nova_competition_draw_ceremony":
			last_errors.append("La competición no utiliza la ceremonia común: " + competition_id)
		competitions_by_id[competition_id] = competition.duplicate(true)
	if int(parsed.get("competition_count", -1)) != competitions_by_id.size():
		last_errors.append("El total declarado de competiciones no coincide con el catálogo.")
	return _result()

func get_competition(competition_id: String) -> Dictionary:
	return competitions_by_id.get(competition_id, {}).duplicate(true)

func get_competitions_for_confederation(confederation_code: String) -> Array:
	var result: Array = []
	var code := confederation_code.to_upper()
	for competition in competitions_by_id.values():
		if competition.get("confederations", []).has(code):
			result.append(competition.duplicate(true))
	return result

func get_all_competitions() -> Array:
	var result: Array = []
	for competition in competitions_by_id.values():
		result.append(competition.duplicate(true))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("name", "")) < str(b.get("name", "")))
	return result

func _result() -> Dictionary:
	return {
		"ok": last_errors.is_empty() and competitions_by_id.size() == int(catalog_metadata.get("competition_count", -1)),
		"competition_count": competitions_by_id.size(),
		"confederations": REQUIRED_CONFEDERATIONS.duplicate(),
		"errors": last_errors.duplicate()
	}
