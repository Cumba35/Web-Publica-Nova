extends RefCounted
class_name NovaUSARosterGenerator

const POSITIONS := ["POR", "POR", "DFC", "DFC", "DFC", "DFC", "DFC", "LI", "LI", "LD", "LD", "MCD", "MCD", "MC", "MC", "MC", "MCO", "MI", "MD", "EI", "ED", "DC"]
const FIRST_NAMES := ["James","Liam","Noah","Oliver","Elijah","Mateo","Lucas","Ethan","Mason","Logan","Aiden","Jackson","Caleb","Carter","Daniel","Henry","Wyatt","Owen","Julian","Leo","Isaiah","Dylan","Adrian","Miles","Cameron","Jordan","Rafael","Diego","Andre","Malik","Kai","Evan"]
const SURNAMES := ["Miller","Johnson","Williams","Brown","Davis","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin","Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson","Walker","Young","Allen","King","Wright","Scott","Torres","Hill","Green","Adams","Baker","Nelson","Cruz","Rivera","Campbell","Mitchell","Roberts","Turner"]
const COMMERCIAL_SERVICE = preload("res://scripts/manager/club_commercial_service.gd")

static func generate_for_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "players_added": 0, "teams_completed": 0, "errors": ["Registro deportivo no disponible"]}
	var templates_by_position: Dictionary = {}
	for player in registry.players_by_id.values():
		var position := str(player.get("primary_position", ""))
		if not templates_by_position.has(position):
			templates_by_position[position] = []
		templates_by_position[position].append(player)
	var teams: Array[String] = []
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		if str(team.get("country_id", "")) == "USA":
			teams.append(str(team_id))
	teams.sort()
	if teams.size() != 72:
		return {"ok": false, "players_added": 0, "teams_completed": 0, "errors": ["Se esperaban 72 clubes USA y se encontraron " + str(teams.size())]}
	var pending: Array = []
	var roster_map: Dictionary = {}
	var used_names: Dictionary = {}
	for team_index in range(teams.size()):
		var team_id := teams[team_index]
		var team: Dictionary = registry.teams_by_id[team_id]
		var level := int(team.get("competition_level", 3))
		var ids: Array[String] = []
		for player_index in range(POSITIONS.size()):
			var position: String = str(POSITIONS[player_index])
			var templates: Array = templates_by_position.get(position, [])
			if templates.is_empty():
				return {"ok": false, "players_added": 0, "teams_completed": 0, "errors": ["No existe plantilla de atributos para " + position]}
			var template: Dictionary = templates[(team_index * 7 + player_index * 3) % templates.size()]
			var first: String = FIRST_NAMES[(team_index * 11 + player_index * 5) % FIRST_NAMES.size()]
			var surname: String = SURNAMES[(team_index * 13 + player_index * 7) % SURNAMES.size()]
			var name: String = first + " " + surname
			var suffix := 2
			while used_names.has(name.to_lower()):
				name = first + " " + surname + " " + str(suffix)
				suffix += 1
			used_names[name.to_lower()] = true
			var overall := clampi(68 - (level - 1) * 7 + ((team_index * 3 + player_index * 5) % 13) - 6, 42, 84)
			var attributes: Dictionary = {}
			var source_attributes: Dictionary = template.get("attributes", {})
			for key in source_attributes:
				attributes[str(key)] = clampi(int(source_attributes[key]) + overall - int(template.get("estimated_overall", 55)), 1, 99)
			var age := 18 + ((team_index * 5 + player_index * 3) % 17)
			var potential := clampi(overall + 3 + ((team_index + player_index) % 13), overall, 92)
			var player_id := "FN-USA-%03d-%02d" % [team_index + 1, player_index + 1]
			var player := {
				"id": player_id,
				"display_name": name,
				"nationality_id": "USA",
				"primary_position": position,
				"secondary_positions": [],
				"preferred_foot": "left" if (team_index + player_index) % 4 == 0 else "right",
				"birth_date": "%04d-%02d-%02d" % [2026 - age, 1 + ((team_index + player_index * 2) % 12), 1 + ((team_index * 3 + player_index * 5) % 27)],
				"age_at_generation": age,
				"birth_place": "United States",
				"height_cm": 180 + ((team_index * 3 + player_index * 7) % 15) if position == "POR" else 166 + ((team_index * 7 + player_index * 3) % 25),
				"weight_kg": 72 + ((team_index * 2 + player_index * 3) % 19) if position == "POR" else 61 + ((team_index * 5 + player_index * 2) % 26),
				"estimated_overall": overall,
				"potential": potential,
				"attributes": attributes,
				"generation_seed": 20261115 + team_index * 100 + player_index,
				"club_id": team_id,
				"fictional": true,
				"economy": {
					"market_value_eur_estimate": COMMERCIAL_SERVICE.estimate_player_market_value_eur({"estimated_overall": overall, "potential": potential, "age": age, "position": position}, level),
					"valuation_type": "fictional_game_estimate",
					"reference_framework": "Fútbol Nova internal model",
					"source": "Generated fictional player; not a real player valuation",
					"division_level": level,
					"valuation_confidence": "initial_low",
					"last_valuation_update": "2026-11-15"
				}
			}
			pending.append(player)
			ids.append(player_id)
		roster_map[team_id] = ids
	var added := registry.register_players(pending)
	var completed := 0
	for team_id in roster_map:
		registry.teams_by_id[team_id]["player_ids"] = roster_map[team_id].duplicate()
		if roster_map[team_id].size() == 22:
			completed += 1
	return {"ok": added == pending.size() and completed == 72, "players_added": added, "players_expected": pending.size(), "teams_completed": completed, "errors": registry.last_errors.duplicate()}
