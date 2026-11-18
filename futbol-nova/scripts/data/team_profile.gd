extends RefCounted
class_name NovaTeamProfile

static func validate(team: Dictionary, require_full_roster: bool = false) -> PackedStringArray:
	var errors := PackedStringArray()
	for field in ["id", "name", "country_id", "player_ids"]:
		if not team.has(field):
			errors.append("Falta el campo obligatorio: " + field)
	if not errors.is_empty():
		return errors
	if str(team.id).strip_edges().is_empty() or str(team.name).strip_edges().is_empty() or str(team.country_id).strip_edges().is_empty():
		errors.append("id, name y country_id no pueden estar vacíos")
	if not team.player_ids is Array:
		errors.append("player_ids debe ser un array")
		return errors
	if require_full_roster and team.player_ids.size() < 11:
		errors.append("Una plantilla de partido necesita al menos 11 jugadores")
	var seen := {}
	for raw_id in team.player_ids:
		var player_id := str(raw_id)
		if player_id.is_empty() or seen.has(player_id):
			errors.append("ID de jugador vacío o duplicado: " + player_id)
		seen[player_id] = true
	return errors

static func validate_roster_references(team: Dictionary, players_by_id: Dictionary, minimum_players: int = 11) -> PackedStringArray:
	var errors := validate(team)
	if not errors.is_empty():
		return errors
	if team.player_ids.size() < minimum_players:
		errors.append("La plantilla no alcanza el mínimo de " + str(minimum_players) + " jugadores")
	for player_id in team.player_ids:
		if not players_by_id.has(str(player_id)):
			errors.append("Referencia a jugador inexistente: " + str(player_id))
	return errors
