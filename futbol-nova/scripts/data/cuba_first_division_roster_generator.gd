extends RefCounted
class_name NovaCubaFirstDivisionRosterGenerator

# Deprecated runtime generator.
# The canonical 20 x 22 First Division rosters are committed in
# res://data/players/cuba_first_division.json and loaded by
# NovaCubaRosterImporter. Do not generate a second copy of those IDs.

static func generate_for_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "players_added": 0, "teams_completed": 0, "errors": ["Registro no disponible"]}
	var teams_completed := 0
	var teams_found := 0
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		if str(team.get("country_id", "")) != "CUB" or int(team.get("division_level", 0)) != 1:
			continue
		teams_found += 1
		if team.get("player_ids", []).size() == 22:
			teams_completed += 1
	if teams_found == 16 and teams_completed == 16:
		return {"ok": true, "players_added": 0, "teams_completed": 16, "already_imported": true, "source": "data/players/cuba_first_division.json", "errors": []}
	return {"ok": false, "players_added": 0, "teams_completed": teams_completed, "errors": ["La generación en runtime está desactivada. Importa data/players/cuba_first_division.json mediante NovaCubaRosterImporter."]}
