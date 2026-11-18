extends RefCounted
class_name NovaLeagueBallService

const BALL_CATALOG_PATH := "res://data/league_official_balls.json"

static func load_catalog(path: String = BALL_CATALOG_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary and parsed.get("schema_version", "") == "1.0.0" else {}

static func get_official_ball(league_id: String, catalog: Dictionary = {}) -> Dictionary:
	var source := catalog if not catalog.is_empty() else load_catalog()
	var leagues: Dictionary = source.get("leagues", {})
	if not leagues.has(league_id):
		return {}
	var ball: Dictionary = leagues[league_id].get("official_ball", {})
	if str(ball.get("id", "")).is_empty() or str(ball.get("asset_id", "")).is_empty():
		return {}
	return ball.duplicate(true)

static func resolve_match_ball(league_id: String, competition_type: String, is_official: bool, configured_ball_id: String = "", catalog: Dictionary = {}) -> Dictionary:
	var official_ball := get_official_ball(league_id, catalog)
	if is_official and competition_type in ["league", "cup", "supercup"]:
		if official_ball.is_empty():
			return {"ok": false, "error": "La liga no tiene balón oficial configurado"}
		return {"ok": true, "ball": official_ball, "locked": true, "source": "league_default_for_official_competition"}
	if not configured_ball_id.is_empty():
		var available: Array = (catalog if not catalog.is_empty() else load_catalog()).get("available_balls", [])
		for item in available:
			if str(item.get("id", "")) == configured_ball_id:
				return {"ok": true, "ball": item.duplicate(true), "locked": false, "source": "selected"}
	return {"ok": true, "ball": official_ball, "locked": false, "source": "league_default" if not official_ball.is_empty() else "engine_default"}

static func validate_catalog(catalog: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var leagues: Dictionary = catalog.get("leagues", {})
	for league_id in leagues:
		var ball: Dictionary = leagues[league_id].get("official_ball", {})
		if str(ball.get("id", "")).is_empty() or str(ball.get("asset_id", "")).is_empty():
			errors.append("Balón oficial incompleto para liga: " + str(league_id))
		if str(ball.get("license_status", "")) not in ["original", "verified_cc0", "verified_public_domain", "licensed"]:
			errors.append("Licencia no verificada para liga: " + str(league_id))
	return errors
