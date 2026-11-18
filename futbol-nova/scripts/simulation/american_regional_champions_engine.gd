extends RefCounted
class_name NovaAmericanRegionalChampionsEngine

const GROUP_IDS := ["A", "B", "C", "D"]
const ASSOCIATION_COUNT := 10
const CLUBS_PER_ASSOCIATION := 4
const TOTAL_CLUBS := 40
const GROUP_SIZE := 10
const SCHEDULER = preload("res://scripts/simulation/round_robin_scheduler.gd")
const STANDINGS = preload("res://scripts/simulation/league_standings.gd")

static func validate_participants(participants: Array, expected_associations: Array) -> Dictionary:
	var errors: Array[String] = []
	var expected := {}
	for association in expected_associations:
		expected[str(association)] = true
	if expected.size() != ASSOCIATION_COUNT:
		errors.append("La competición debe definir exactamente diez asociaciones.")
	var counts := {}
	var seen := {}
	for item in participants:
		if not item is Dictionary:
			errors.append("Participante con formato inválido.")
			continue
		var team_id := str(item.get("team_id", item.get("id", "")))
		var association_id := str(item.get("association_id", ""))
		if team_id.is_empty() or association_id.is_empty():
			errors.append("Cada club necesita ID y asociación.")
			continue
		if seen.has(team_id):
			errors.append("Club duplicado: " + team_id)
		seen[team_id] = true
		if not expected.has(association_id):
			errors.append("Asociación no elegible: " + association_id)
		counts[association_id] = int(counts.get(association_id, 0)) + 1
		if int(item.get("division_level", 0)) != 1:
			errors.append("El club %s no pertenece a Primera División." % team_id)
	if participants.size() != TOTAL_CLUBS:
		errors.append("Se requieren exactamente 40 clubes.")
	for association_id in expected:
		if int(counts.get(association_id, 0)) != CLUBS_PER_ASSOCIATION:
			errors.append("La asociación %s debe aportar exactamente cuatro clubes." % association_id)
	return {"ok": errors.is_empty(), "errors": errors, "club_count": seen.size(), "association_counts": counts}

static func create_edition(competition_id: String, season_id: String, participants: Array, expected_associations: Array, matchday_windows: Array, seed: int = 1) -> Dictionary:
	if competition_id.is_empty() or season_id.is_empty():
		return {"ok": false, "errors": ["Faltan el ID de competición o temporada."]}
	var validation := validate_participants(participants, expected_associations)
	if not bool(validation.ok):
		return {"ok": false, "errors": validation.errors}
	if matchday_windows.size() != 9:
		return {"ok": false, "errors": ["La fase de grupos necesita nueve ventanas de jornada."]}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var by_association := {}
	for participant in participants:
		var association_id := str(participant.association_id)
		if not by_association.has(association_id):
			by_association[association_id] = []
		by_association[association_id].append(str(participant.team_id))
	for association_id in by_association:
		var ids: Array = by_association[association_id]
		for i in range(ids.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var temp = ids[i]
			ids[i] = ids[j]
			ids[j] = temp
		by_association[association_id] = ids
	var groups := {"A": [], "B": [], "C": [], "D": []}
	var associations: Array = expected_associations.duplicate()
	associations.sort()
	for association_id in associations:
		var ids: Array = by_association[str(association_id)]
		for index in range(GROUP_IDS.size()):
			groups[GROUP_IDS[index]].append(str(ids[index]))
	var draw_presentation: Array = []
	for group_id in GROUP_IDS:
		for team_id in groups[group_id]:
			for participant in participants:
				if str(participant.get("team_id", "")) == str(team_id):
					draw_presentation.append({"team_id": str(team_id), "group": str(group_id), "association": str(participant.get("association_id", ""))})
					break
	var fixtures_by_group := {}
	var standings_by_group := {}
	for group_id in GROUP_IDS:
		var stage_id: String = competition_id + "_" + str(group_id)
		var fixtures: Array = SCHEDULER.create_fixtures(groups[group_id], stage_id, season_id, false)
		if fixtures.size() != 45:
			return {"ok": false, "errors": ["Calendario incompleto en el grupo " + group_id + "."]}
		for fixture in fixtures:
			var round_index := int(fixture.get("round", 0)) - 1
			var window: Dictionary = matchday_windows[round_index]
			var round_fixtures := []
			for candidate in fixtures:
				if int(candidate.get("round", 0)) == round_index + 1:
					round_fixtures.append(candidate)
			var fixture_index := round_fixtures.find(fixture)
			var available_dates := _available_window_dates(window)
			if available_dates.is_empty():
				return {"ok": false, "errors": ["La ventana de la jornada %d no contiene fechas disponibles." % (round_index + 1)]}
			var date_index := mini(available_dates.size() - 1, int(fixture_index * available_dates.size() / round_fixtures.size()))
			fixture["matchday"] = round_index + 1
			fixture["scheduled_date"] = str(available_dates[date_index])
			fixture["calendar_status"] = "planning_date_not_federation_verified"
			fixture["official_calendar_verified"] = false
		fixtures_by_group[group_id] = fixtures
		standings_by_group[group_id] = STANDINGS.create_table(groups[group_id])
	return {"ok": true, "competition_id": competition_id, "season_id": season_id, "status": "group_stage", "participants": participants.duplicate(true), "groups": groups, "draw_presentation": draw_presentation, "fixtures_by_group": fixtures_by_group, "standings_by_group": standings_by_group, "playoff_fixtures": [], "knockout_fixtures": {}, "seed": seed, "errors": []}

static func get_group_qualification(state: Dictionary) -> Dictionary:
	var direct := []
	var playoff := {}
	for group_id in GROUP_IDS:
		var fixtures: Array = state.get("fixtures_by_group", {}).get(group_id, [])
		for fixture in fixtures:
			if str(fixture.get("status", "scheduled")) != "finished":
				return {"ok": false, "errors": ["La fase de grupos del grupo %s no ha terminado." % group_id]}
		var table: Dictionary = state.get("standings_by_group", {}).get(group_id, {})
		var ordered: Array = STANDINGS.get_ordered_table(table, true)
		if ordered.size() != GROUP_SIZE:
			return {"ok": false, "errors": ["Tabla incompleta en el grupo " + group_id]}
		for index in range(4):
			if int(ordered[index].get("points", 0)) == int(ordered[index + 1].get("points", 0)):
				return {"ok": false, "errors": ["Empate pendiente de criterio aprobado en los puestos de clasificación del grupo " + group_id]}
		for index in range(3):
			direct.append(str(ordered[index].get("team_id", "")))
		playoff[group_id] = {"fourth": str(ordered[3].get("team_id", "")), "fifth": str(ordered[4].get("team_id", ""))}
	return {"ok": true, "direct_qualifiers": direct, "playoff_seeds": playoff}

static func _available_window_dates(window: Dictionary) -> Array:
	var start_date := str(window.get("date", ""))
	var end_date := str(window.get("window_end", start_date))
	if start_date.is_empty() or end_date.is_empty():
		return []
	var start_unix := Time.get_unix_time_from_datetime_string(start_date + "T00:00:00")
	var end_unix := Time.get_unix_time_from_datetime_string(end_date + "T00:00:00")
	if end_unix < start_unix:
		return []
	var blocked := {}
	for raw_date in window.get("blocked_dates", []):
		blocked[str(raw_date)] = true
	var available: Array = []
	var cursor := start_unix
	while cursor <= end_unix:
		var date_string := Time.get_datetime_string_from_unix_time(cursor, true).substr(0, 10)
		if not blocked.has(date_string):
			available.append(date_string)
		cursor += 86400
	return available
