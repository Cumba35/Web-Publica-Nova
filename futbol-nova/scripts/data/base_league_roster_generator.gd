extends RefCounted
class_name NovaBaseLeagueRosterGenerator

const POSITIONS := ["POR","POR","DFC","DFC","DFC","DFC","LI","LI","LD","LD","MCD","MCD","MC","MC","MC","MCO","MI","MD","EI","ED","SD","DC"]
const FIRST_NAMES := ["Alex","Daniel","Lucas","Mateo","Gabriel","Samuel","David","Nicolas","Adrian","Marco","Leo","Martin","Diego","Rafael","Thiago","Andre","Julian","Elias","Victor","Bruno","Pablo","Ivan","Emilio","Tomas","Enzo","Milan","Noah","Luca","Hugo","Oscar","Felix","Joel"]
const LAST_NAMES := ["Garcia","Silva","Martin","Rossi","Muller","Moreau","Costa","Fernandez","Lopez","Santos","Schmidt","Dubois","Romero","Alvarez","Sousa","Weber","Conti","Pereira","Torres","Navarro","Bianchi","Mendes","Keller","Diaz","Herrera","Kovac","Fischer","Moreno","Vega","Serrano"]
const TARGET_COUNTRIES := ["ESP","BRA","ITA","GER","FRA","POR","ARG"]

static func generate_for_registry(registry: NovaFootballDataRegistry) -> Dictionary:
	if registry == null:
		return {"ok": false, "players_added": 0, "teams_completed": 0, "errors": ["Registro no disponible"]}
	var templates_by_position := {}
	for player in registry.players_by_id.values():
		var pos := str(player.get("primary_position", ""))
		if not templates_by_position.has(pos):
			templates_by_position[pos] = []
		templates_by_position[pos].append(player)
	var teams: Array[String] = []
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		var code := str(team.get("country_id", ""))
		if TARGET_COUNTRIES.has(code) and team.get("player_ids", []).is_empty():
			teams.append(str(team_id))
	teams.sort()
	var pending: Array = []
	var roster_map := {}
	var names_used := {}
	var errors := PackedStringArray()
	for team_index in range(teams.size()):
		var team_id := teams[team_index]
		var team: Dictionary = registry.teams_by_id[team_id]
		var code := str(team.get("country_id", ""))
		var level := int(team.get("division_level", 1))
		var player_ids: Array[String] = []
		for player_index in range(POSITIONS.size()):
			var pos: String = str(POSITIONS[player_index])
			var templates: Array = templates_by_position.get(pos, [])
			if templates.is_empty():
				errors.append("No existe plantilla de atributos para " + pos)
				continue
			var template: Dictionary = templates[(team_index * 11 + player_index * 3) % templates.size()]
			var first: String = FIRST_NAMES[(team_index * 7 + player_index * 5) % FIRST_NAMES.size()]
			var last: String = LAST_NAMES[(team_index * 13 + player_index * 3) % LAST_NAMES.size()]
			var name: String = first + " " + last
			var salt := 2
			while names_used.has(code + name.to_lower()):
				name = first + " " + last + " " + str(salt)
				salt += 1
			names_used[code + name.to_lower()] = true
			var overall := clampi(72 - (level - 1) * 6 + ((team_index * 3 + player_index * 5) % 13) - 6, 40, 88)
			var attributes := {}
			var source_attributes: Dictionary = template.get("attributes", {})
			for key in source_attributes:
				attributes[str(key)] = clampi(int(source_attributes[key]) + overall - int(template.get("estimated_overall", 55)), 1, 99)
			var age := 18 + ((team_index * 5 + player_index * 3) % 17)
			var player_id := "FN-P-" + code + "-BASE-%03d-%02d" % [team_index + 1, player_index + 1]
			pending.append({
				"id": player_id,
				"display_name": name,
				"nationality_id": code,
				"primary_position": pos,
				"secondary_positions": [],
				"preferred_foot": "left" if (team_index + player_index) % 4 == 0 else "right",
				"birth_date": "%04d-%02d-%02d" % [2026 - age, 1 + ((team_index + player_index) % 12), 1 + ((team_index * 3 + player_index) % 27)],
				"age_at_generation": age,
				"height_cm": 180 + ((team_index + player_index) % 15) if pos == "POR" else 166 + ((team_index * 3 + player_index) % 25),
				"weight_kg": 72 + ((team_index * 2 + player_index) % 19),
				"estimated_overall": overall,
				"potential": clampi(overall + 3 + ((team_index + player_index) % 13), overall, 94),
				"attributes": attributes,
				"club_id": team_id,
				"fictional": true,
				"identity_type": "original_fictional_player",
				"generation_seed": 20261115 + team_index * 100 + player_index,
				"source_provenance": "Fútbol Nova original fictional player profile; not a real professional player."
			})
			player_ids.append(player_id)
		roster_map[team_id] = player_ids
	if not errors.is_empty():
		return {"ok": false, "players_added": 0, "teams_completed": 0, "errors": errors}
	var added := registry.register_players(pending)
	var completed := 0
	for team_id in roster_map:
		registry.teams_by_id[team_id]["player_ids"] = roster_map[team_id].duplicate()
		if roster_map[team_id].size() == 22:
			completed += 1
	return {"ok": added == pending.size() and completed == teams.size(), "players_added": added, "players_expected": pending.size(), "teams_completed": completed, "teams_expected": teams.size(), "errors": registry.last_errors.duplicate()}
