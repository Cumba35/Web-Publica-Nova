extends RefCounted
class_name NovaDownloadRecommendationService

const LEAGUE_MANIFEST_PATH := "res://data/league_content_manifest.json"
const NATIONAL_TEAMS_MANIFEST_PATH := "res://data/national_teams_manifest.json"

static func get_startup_recommendations() -> Dictionary:
	var league_manifest := _read_json(LEAGUE_MANIFEST_PATH)
	var national_manifest := _read_json(NATIONAL_TEAMS_MANIFEST_PATH)
	if league_manifest.is_empty():
		return {"ok": false, "errors": ["No se pudo leer el manifiesto de ligas."], "leagues": [], "national_teams": {}}
	var policy: Dictionary = league_manifest.get("recommendation_policy", {})
	var ranked: Array = []
	for item in league_manifest.get("downloadable_leagues", []):
		if not item is Dictionary:
			continue
		var rank := int(item.get("rank", 0))
		if rank in policy.get("recommended_package_ranks", []):
			ranked.append(item.duplicate(true))
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("rank", 9999)) < int(b.get("rank", 9999)))
	var available: Array = []
	var preparing: Array = []
	for league in ranked:
		if bool(league.get("downloadable", false)) and str(league.get("content_status", "")) == "published":
			available.append(league)
		else:
			preparing.append(league)
	var national_module: Dictionary = national_manifest.get("module", {}).duplicate(true) if not national_manifest.is_empty() else {}
	var national_availability: Dictionary = national_manifest.get("availability", {}).duplicate(true) if not national_manifest.is_empty() else {"status": "manifest_missing", "published_packages": 0}
	var association_scope: Dictionary = national_manifest.get("scope", {}).duplicate(true) if not national_manifest.is_empty() else {}
	var available_count := available.size()
	var missing_count := maxi(0, int(policy.get("minimum_additional_leagues", 10)) - available_count)
	national_availability["target_associations"] = int(association_scope.get("target_associations", 211))
	national_availability["available_roster_packages"] = int(national_availability.get("published_packages", 0))
	return {
		"ok": true,
		"title": str(policy.get("title", "Descargas recomendadas")),
		"minimum_additional_leagues": int(policy.get("minimum_additional_leagues", 10)),
		"recommended_ranked_leagues": ranked,
		"available_leagues": available,
		"leagues_in_preparation": preparing,
		"recommended_leagues_available_count": available_count,
		"recommended_leagues_missing_count": missing_count,
		"national_teams": {"module": national_module, "availability": national_availability, "recommended": true, "target_associations": int(association_scope.get("target_associations", 211)), "available_packages": int(national_availability.get("published_packages", 0))},
		"message": "Recomendamos instalar al menos diez ligas adicionales (puestos 11–20) y todas las selecciones nacionales disponibles. Si faltan paquetes publicados, se informa claramente; nunca se presentan contenidos en preparación como descargas listas."
	}

static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}
