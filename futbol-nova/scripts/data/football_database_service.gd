extends Node
class_name NovaFootballDatabaseService

signal database_opened(summary: Dictionary)
signal database_changed(summary: Dictionary)
signal database_error(message: String)

const SCHEMA_VERSION := "1.0.0"
const DATABASE_PATH := "user://football_database.json"
const TEMP_PATH := "user://football_database.json.tmp"
const BACKUP_PATH := "user://football_database.json.bak"
const MAX_AUDIT_EVENTS := 2000

var database: Dictionary = {}
var is_open := false
var last_error := ""

func _ready() -> void:
	open_database()

func _empty_database() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"created_at": Time.get_datetime_string_from_system(true),
		"updated_at": Time.get_datetime_string_from_system(true),
		"catalog": {"schema_version": SCHEMA_VERSION, "players": {}, "teams": {}, "competitions": {}},
		"master_catalog": {"associations": [], "countries": [], "clubs": [], "competitions": [], "seasons": [], "sources": [], "national_teams": [], "national_players": [], "league_directory": [], "club_memberships": [], "reference_roster_packages": []},
		"match_results": {},
		"competition_states": {},
		"season_states": {},
		"career_records": {},
		"audit_log": []
	}

func open_database() -> bool:
	is_open = false
	last_error = ""
	if not FileAccess.file_exists(DATABASE_PATH):
		var backup_only := _read_database_file(BACKUP_PATH)
		if not backup_only.is_empty():
			database = backup_only
			if not _migrate_database() or not _validate_database() or not _commit_database():
				return _fail("No se pudo recuperar la copia de seguridad de la base de datos.")
		else:
			database = _empty_database()
			if not _commit_database():
				return _fail("No se pudo crear la base de datos local.")
		is_open = true
		database_opened.emit(get_summary())
		return true
	var loaded := _read_database_file(DATABASE_PATH)
	if loaded.is_empty():
		var backup := _read_database_file(BACKUP_PATH)
		if backup.is_empty():
			return _fail("La base de datos y su copia de seguridad no se pueden leer.")
		database = backup
		if not _migrate_database() or not _validate_database():
			return _fail("La copia de seguridad no superó la migración o validación.")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(DATABASE_PATH))
		if not _commit_database():
			return _fail("Se recuperó la copia, pero no se pudo restaurar el archivo principal.")
		is_open = true
		database_opened.emit(get_summary())
		return true
	database = loaded
	if not _migrate_database():
		return false
	if not _validate_database():
		var backup := _read_database_file(BACKUP_PATH)
		if backup.is_empty():
			return _fail("La base de datos tiene referencias o estructura inválidas.")
		database = backup
		if not _migrate_database() or not _validate_database():
			return _fail("La base principal y la copia de seguridad no superaron la validación.")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(DATABASE_PATH))
		if not _commit_database():
			return _fail("No se pudo restaurar la base de datos desde la copia de seguridad.")
	is_open = true
	database_opened.emit(get_summary())
	return true

func _read_database_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _migrate_database() -> bool:
	var version := str(database.get("schema_version", ""))
	if version == SCHEMA_VERSION or version == "0.9.0":
		var defaults := _empty_database()
		for key in ["catalog", "master_catalog", "match_results", "competition_states", "season_states", "career_records", "audit_log"]:
			if not database.has(key):
				database[key] = defaults[key]
		if not database.master_catalog is Dictionary:
			database["master_catalog"] = defaults.master_catalog.duplicate(true)
		for table in ["associations", "countries", "clubs", "competitions", "seasons", "sources", "national_teams", "national_players", "league_directory", "club_memberships", "reference_roster_packages"]:
			if not database.master_catalog.has(table):
				database.master_catalog[table] = []
		if not database.catalog is Dictionary:
			database["catalog"] = defaults.catalog.duplicate(true)
		for table in ["players", "teams", "competitions"]:
			if not database.catalog.has(table):
				database.catalog[table] = {}
		if version != SCHEMA_VERSION:
			database["schema_version"] = SCHEMA_VERSION
			_append_audit("database_migrated", {"from": version, "to": SCHEMA_VERSION})
		return true
	return _fail("Versión de base de datos no compatible: " + version)

func _validate_database() -> bool:
	for key in ["catalog", "master_catalog", "match_results", "competition_states", "season_states", "career_records", "audit_log"]:
		if not database.has(key):
			return false
	if not database.catalog is Dictionary or not database.master_catalog is Dictionary:
		return false
	for table in ["players", "teams", "competitions"]:
		if not database.catalog.get(table, {}) is Dictionary:
			return false
	for table in ["associations", "countries", "clubs", "competitions", "seasons", "sources", "national_teams", "national_players", "league_directory", "club_memberships", "reference_roster_packages"]:
		if not database.master_catalog.get(table, []) is Array:
			return false
	for table in ["match_results", "competition_states", "season_states", "career_records"]:
		if not database.get(table, {}) is Dictionary:
			return false
	return database.get("audit_log", []) is Array

func save_catalog_snapshot(snapshot: Dictionary) -> bool:
	if not is_open and not open_database():
		return false
	for key in ["players", "teams", "competitions"]:
		if not snapshot.get(key, null) is Dictionary:
			return _fail("Snapshot deportivo sin tabla válida: " + key)
	var players: Dictionary = snapshot.players
	var teams: Dictionary = snapshot.teams
	var competitions: Dictionary = snapshot.competitions
	for team_id in teams:
		var team: Dictionary = teams[team_id]
		for player_id in team.get("player_ids", []):
			if not players.has(str(player_id)):
				return _fail("El club %s referencia al futbolista inexistente %s." % [str(team_id), str(player_id)])
	for competition_id in competitions:
		var competition: Dictionary = competitions[competition_id]
		for team_id in competition.get("team_ids", []):
			if not teams.has(str(team_id)):
				return _fail("La competición %s referencia al club inexistente %s." % [str(competition_id), str(team_id)])
	var previous: Dictionary = database.catalog.duplicate(true)
	var audit_before: Array = database.audit_log.duplicate(true)
	database["catalog"] = {
		"schema_version": SCHEMA_VERSION,
		"players": players.duplicate(true),
		"teams": teams.duplicate(true),
		"competitions": competitions.duplicate(true),
		"saved_at": Time.get_datetime_string_from_system(true)
	}
	_append_audit("catalog_snapshot_saved", {"players": players.size(), "clubs": teams.size(), "competitions": competitions.size()})
	if not _commit_database():
		database["catalog"] = previous
		database.audit_log = audit_before
		return false
	database_changed.emit(get_summary())
	return true

func save_master_catalog(catalog: Dictionary) -> bool:
	if not is_open and not open_database():
		return false
	for key in ["associations", "countries", "clubs", "competitions", "seasons", "sources", "national_teams", "national_players", "league_directory", "club_memberships", "reference_roster_packages"]:
		if not catalog.get(key, null) is Array:
			return _fail("Catálogo maestro sin tabla válida: " + key)
	var seen := {}
	for club in catalog.clubs:
		if not club is Dictionary or str(club.get("id", "")).is_empty():
			return _fail("Club sin identificador en el catálogo maestro.")
		var id := str(club.id)
		if seen.has(id):
			return _fail("ID de club duplicado en catálogo maestro: " + id)
		seen[id] = true
	var catalog_players: Dictionary = database.get("catalog", {}).get("players", {})
	for club in catalog.clubs:
		for player_id in club.get("player_ids", []):
			if not catalog_players.has(str(player_id)):
				return _fail("El club maestro %s referencia un futbolista ausente del catálogo jugable: %s" % [str(club.id), str(player_id)])
	var association_ids := {}
	for association in catalog.associations:
		if not association is Dictionary or str(association.get("id", "")).is_empty() or association_ids.has(str(association.get("id", ""))):
			return _fail("Asociación vacía o duplicada en catálogo maestro.")
		association_ids[str(association.id)] = true
	var country_ids := {}
	for country in catalog.countries:
		if not country is Dictionary or str(country.get("id", "")).is_empty() or country_ids.has(str(country.get("id", ""))):
			return _fail("País vacío o duplicado en catálogo maestro.")
		var association_id := str(country.get("association_id", ""))
		if association_id.is_empty() or not association_ids.has(association_id):
			return _fail("El país %s no referencia una asociación FIFA válida." % str(country.get("id", "")))
		country_ids[str(country.id)] = true
	var competition_ids := {}
	for competition in catalog.competitions:
		if not competition is Dictionary or str(competition.get("id", "")).is_empty() or competition_ids.has(str(competition.get("id", ""))):
			return _fail("Competición vacía o duplicada en catálogo maestro.")
		competition_ids[str(competition.id)] = true
		for club_id in competition.get("team_ids", []):
			if not seen.has(str(club_id)):
				return _fail("La competición %s referencia un club inexistente: %s" % [str(competition.id), str(club_id)])
	var season_ids := {}
	for season in catalog.seasons:
		if not season is Dictionary or str(season.get("id", "")).is_empty() or season_ids.has(str(season.get("id", ""))):
			return _fail("Temporada vacía o duplicada en catálogo maestro.")
		season_ids[str(season.id)] = true
	var source_ids := {}
	for source in catalog.sources:
		if not source is Dictionary or str(source.get("id", "")).is_empty() or source_ids.has(str(source.get("id", ""))):
			return _fail("Fuente vacía o duplicada en catálogo maestro.")
		source_ids[str(source.id)] = true
	for association in catalog.associations:
		for source_id in association.get("source_ids", []):
			if not source_ids.has(str(source_id)):
				return _fail("La asociación %s referencia una fuente inexistente: %s" % [str(association.id), str(source_id)])
	for country in catalog.countries:
		for source_id in country.get("source_ids", []):
			if not source_ids.has(str(source_id)):
				return _fail("El país %s referencia una fuente inexistente: %s" % [str(country.id), str(source_id)])
	var national_player_ids := {}
	for player in catalog.national_players:
		if not player is Dictionary or str(player.get("id", "")).is_empty() or national_player_ids.has(str(player.get("id", ""))):
			return _fail("Futbolista de selección vacío o duplicado.")
		national_player_ids[str(player.id)] = true
	var national_team_ids := {}
	for team in catalog.national_teams:
		if not team is Dictionary or str(team.get("id", "")).is_empty() or national_team_ids.has(str(team.get("id", ""))):
			return _fail("Selección nacional vacía o duplicada.")
		national_team_ids[str(team.id)] = true
		for player_id in team.get("player_ids", []):
			if not national_player_ids.has(str(player_id)):
				return _fail("La selección %s referencia a un futbolista no incluido: %s" % [str(team.id), str(player_id)])
	var membership_ids := {}
	for membership in catalog.club_memberships:
		if not membership is Dictionary or str(membership.get("id", "")).is_empty() or membership_ids.has(str(membership.get("id", ""))):
			return _fail("Membresía de club vacía o duplicada.")
		membership_ids[str(membership.id)] = true
		if not seen.has(str(membership.get("club_id", ""))):
			return _fail("Membresía referencia un club inexistente: " + str(membership.get("club_id", "")))
		if not competition_ids.has(str(membership.get("competition_id", ""))):
			return _fail("Membresía referencia una competición inexistente: " + str(membership.get("competition_id", "")))
		if not country_ids.has(str(membership.get("country_id", ""))):
			return _fail("Membresía referencia un país inexistente: " + str(membership.get("country_id", "")))
		if not season_ids.has(str(membership.get("season_id", ""))):
			return _fail("Membresía referencia una temporada inexistente: " + str(membership.get("season_id", "")))
		var membership_competition: Dictionary = {}
		for competition in catalog.competitions:
			if str(competition.get("id", "")) == str(membership.get("competition_id", "")):
				membership_competition = competition
				break
		if not membership_competition.is_empty() and str(membership_competition.get("country_id", "")) != str(membership.get("country_id", "")):
			return _fail("La membresía y su competición pertenecen a países distintos: " + str(membership.id))
		for source_id in membership.get("source_ids", []):
			if not source_ids.has(str(source_id)):
				return _fail("Membresía referencia una fuente inexistente: " + str(source_id))
	var roster_package_ids := {}
	for package in catalog.reference_roster_packages:
		if not package is Dictionary or str(package.get("package_id", "")).is_empty() or roster_package_ids.has(str(package.get("package_id", ""))):
			return _fail("Paquete de plantillas de referencia vacío o duplicado.")
		roster_package_ids[str(package.package_id)] = true
		if bool(package.get("playable", false)):
			return _fail("Un paquete de referencia sin derechos no puede ser jugable: " + str(package.package_id))
		if not package.get("clubs", null) is Array:
			return _fail("El paquete de referencia no contiene una lista de clubes: " + str(package.package_id))
		var nested_club_count: int = package.clubs.size()
		var nested_player_count := 0
		for reference_club in package.clubs:
			if not reference_club is Dictionary or not reference_club.get("players", []) is Array:
				return _fail("Club o lista de jugadores inválida en " + str(package.package_id))
			nested_player_count += reference_club.players.size()
		if nested_club_count != int(package.get("club_count", -1)) or nested_player_count != int(package.get("player_count", -1)):
			return _fail("Los recuentos de clubes o jugadores no coinciden en " + str(package.package_id))
		if not competition_ids.has(str(package.get("competition_id", ""))):
			return _fail("Paquete de plantillas referencia una competición inexistente: " + str(package.package_id))
		if not season_ids.has(str(package.get("season_id", ""))):
			return _fail("Paquete de plantillas referencia una temporada inexistente: " + str(package.package_id))
		for source_id in package.get("source_ids", []):
			if not source_ids.has(str(source_id)):
				return _fail("Paquete de plantillas referencia una fuente inexistente: " + str(source_id))
	var league_keys := {}
	for league in catalog.league_directory:
		if not league is Dictionary or int(league.get("source_rank", 0)) <= 0 or str(league.get("league", "")).is_empty() or str(league.get("country", "")).is_empty():
			return _fail("Entrada incompleta en el directorio de ligas.")
		var league_key := str(league.country) + "|" + str(league.league)
		if league_keys.has(league_key):
			return _fail("Liga duplicada en el directorio maestro: " + league_key)
		league_keys[league_key] = true
	for club in catalog.clubs:
		var club_country_id := str(club.get("country_id", ""))
		if club_country_id.begins_with("FIFA-MA-") and not country_ids.has(club_country_id):
			return _fail("El club %s referencia un país inexistente: %s" % [str(club.id), club_country_id])
		for source_id in club.get("source_ids", []):
			if not source_ids.has(str(source_id)):
				return _fail("El club %s referencia una fuente inexistente: %s" % [str(club.id), str(source_id)])
		var season_id := str(club.get("season_id", ""))
		if not season_id.is_empty() and not season_ids.has(season_id):
			return _fail("El club %s referencia una temporada inexistente: %s" % [str(club.id), season_id])
	for competition in catalog.competitions:
		var competition_country_id := str(competition.get("country_id", ""))
		if competition_country_id.begins_with("FIFA-MA-") and not country_ids.has(competition_country_id):
			return _fail("La competición %s referencia un país inexistente: %s" % [str(competition.id), competition_country_id])
		for source_id in competition.get("source_ids", []):
			if not source_ids.has(str(source_id)):
				return _fail("La competición %s referencia una fuente inexistente: %s" % [str(competition.id), str(source_id)])
		var season_id := str(competition.get("season_id", ""))
		if not season_id.is_empty() and not season_ids.has(season_id):
			return _fail("La competición %s referencia una temporada inexistente: %s" % [str(competition.id), season_id])
	var previous: Dictionary = database.master_catalog.duplicate(true)
	var audit_before: Array = database.audit_log.duplicate(true)
	database["master_catalog"] = catalog.duplicate(true)
	database["master_catalog"]["saved_at"] = Time.get_datetime_string_from_system(true)
	_append_audit("master_catalog_saved", {
		"associations": catalog.associations.size(),
		"countries": catalog.countries.size(),
		"clubs": catalog.clubs.size(),
		"competitions": catalog.competitions.size(),
		"seasons": catalog.seasons.size(),
		"sources": catalog.sources.size(),
		"club_memberships": catalog.club_memberships.size(),
		"reference_roster_packages": catalog.reference_roster_packages.size()
	})
	if not _commit_database():
		database["master_catalog"] = previous
		database.audit_log = audit_before
		return false
	database_changed.emit(get_summary())
	return true

func save_match_result(stage_id: String, result: Dictionary) -> bool:
	if not is_open and not open_database():
		return false
	var match_id := str(result.get("match_id", result.get("fixture_id", "")))
	if match_id.is_empty() or str(result.get("status", "")) != "finished":
		return _fail("Solo se guardan resultados finalizados con identificador.")
	var home_goals = result.get("home_goals", null)
	var away_goals = result.get("away_goals", null)
	if not (home_goals is int or home_goals is float) or not (away_goals is int or away_goals is float):
		return _fail("El marcador del partido no es válido.")
	if int(home_goals) < 0 or int(away_goals) < 0:
		return _fail("El marcador no puede ser negativo.")
	if database.match_results.has(match_id):
		return false
	var audit_before: Array = database.audit_log.duplicate(true)
	database.match_results[match_id] = {
		"stage_id": stage_id,
		"saved_at": Time.get_datetime_string_from_system(true),
		"result": result.duplicate(true)
	}
	_append_audit("match_result_saved", {"match_id": match_id, "stage_id": stage_id})
	if not _commit_database():
		database.match_results.erase(match_id)
		database.audit_log = audit_before
		return false
	database_changed.emit(get_summary())
	return true

func commit_match_and_competition_state(stage_id: String, season_id: String, result: Dictionary, fixtures: Array, standings: Dictionary) -> bool:
	if not is_open and not open_database():
		return false
	var match_id := str(result.get("match_id", result.get("fixture_id", "")))
	if match_id.is_empty() or stage_id.is_empty() or season_id.is_empty() or standings.is_empty():
		return _fail("No se puede confirmar un partido sin ID, fase, temporada y clasificación.")
	if has_match_result(match_id):
		return false
	var home_goals = result.get("home_goals", null)
	var away_goals = result.get("away_goals", null)
	if str(result.get("status", "")) != "finished" or not (home_goals is int or home_goals is float) or not (away_goals is int or away_goals is float) or int(home_goals) < 0 or int(away_goals) < 0:
		return _fail("El resultado del partido no está finalizado o tiene marcador inválido.")
	var previous_stage: Dictionary = database.competition_states.get(stage_id, {}).duplicate(true)
	var audit_before: Array = database.audit_log.duplicate(true)
	database.match_results[match_id] = {"stage_id": stage_id, "saved_at": Time.get_datetime_string_from_system(true), "result": result.duplicate(true)}
	database.competition_states[stage_id] = {
		"season_id": season_id,
		"fixtures": fixtures.duplicate(true),
		"standings": standings.duplicate(true),
		"saved_at": Time.get_datetime_string_from_system(true)
	}
	_append_audit("match_and_competition_committed", {"match_id": match_id, "stage_id": stage_id, "season_id": season_id})
	if not _commit_database():
		database.audit_log = audit_before
		database.match_results.erase(match_id)
		if previous_stage.is_empty():
			database.competition_states.erase(stage_id)
		else:
			database.competition_states[stage_id] = previous_stage
		return false
	database_changed.emit(get_summary())
	return true

func has_match_result(match_id: String) -> bool:
	return database.get("match_results", {}).has(match_id)

func get_match_result(match_id: String) -> Dictionary:
	var entry: Dictionary = database.get("match_results", {}).get(match_id, {})
	return entry.get("result", {}).duplicate(true) if entry.get("result", {}) is Dictionary else {}

func get_player(player_id: String) -> Dictionary:
	return database.get("catalog", {}).get("players", {}).get(player_id, {}).duplicate(true)

func get_team(team_id: String) -> Dictionary:
	return database.get("catalog", {}).get("teams", {}).get(team_id, {}).duplicate(true)

func get_competition(competition_id: String) -> Dictionary:
	return database.get("catalog", {}).get("competitions", {}).get(competition_id, {}).duplicate(true)

func get_club_memberships_by_club(club_id: String) -> Array:
	var result: Array = []
	for membership in database.get("master_catalog", {}).get("club_memberships", []):
		if str(membership.get("club_id", "")) == club_id:
			result.append(membership.duplicate(true))
	return result

func get_club_memberships_by_competition(competition_id: String) -> Array:
	var result: Array = []
	for membership in database.get("master_catalog", {}).get("club_memberships", []):
		if str(membership.get("competition_id", "")) == competition_id:
			result.append(membership.duplicate(true))
	return result

func get_reference_roster_packages() -> Array:
	return database.get("master_catalog", {}).get("reference_roster_packages", []).duplicate(true)

func get_league_directory() -> Array:
	var result: Array = database.get("master_catalog", {}).get("league_directory", []).duplicate(true)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("source_rank", 0)) < int(b.get("source_rank", 0)))
	return result

func get_national_team(team_id: String) -> Dictionary:
	for team in database.get("master_catalog", {}).get("national_teams", []):
		if str(team.get("id", "")) == team_id:
			return team.duplicate(true)
	return {}

func get_national_player(player_id: String) -> Dictionary:
	for player in database.get("master_catalog", {}).get("national_players", []):
		if str(player.get("id", "")) == player_id:
			return player.duplicate(true)
	return {}

func get_master_club(club_id: String) -> Dictionary:
	for club in database.get("master_catalog", {}).get("clubs", []):
		if str(club.get("id", "")) == club_id:
			return club.duplicate(true)
	return {}

func get_country(country_id: String) -> Dictionary:
	for country in database.get("master_catalog", {}).get("countries", []):
		if str(country.get("id", "")) == country_id:
			return country.duplicate(true)
	return {}

func get_association(association_id: String) -> Dictionary:
	for association in database.get("master_catalog", {}).get("associations", []):
		if str(association.get("id", "")) == association_id:
			return association.duplicate(true)
	return {}

func get_clubs_by_country(country_id: String) -> Array:
	var result: Array = []
	for club in database.get("master_catalog", {}).get("clubs", []):
		if str(club.get("country_id", "")) == country_id or str(club.get("country_code", "")) == country_id:
			result.append(club.duplicate(true))
	return result

func get_season_state(season_id: String) -> Dictionary:
	var entry: Dictionary = database.get("season_states", {}).get(season_id, {})
	return entry.get("state", {}).duplicate(true) if entry.get("state", {}) is Dictionary else {}

func get_career_record(career_id: String) -> Dictionary:
	var entry: Dictionary = database.get("career_records", {}).get(career_id, {})
	return entry.get("state", {}).duplicate(true) if entry.get("state", {}) is Dictionary else {}

func get_competition_state(stage_id: String) -> Dictionary:
	return database.get("competition_states", {}).get(stage_id, {}).duplicate(true)

func save_competition_state(stage_id: String, season_id: String, fixtures: Array, standings: Dictionary) -> bool:
	if not is_open and not open_database():
		return false
	if stage_id.is_empty() or season_id.is_empty() or standings.is_empty():
		return _fail("Estado de competición incompleto.")
	var previous: Dictionary = database.competition_states.get(stage_id, {}).duplicate(true)
	database.competition_states[stage_id] = {
		"season_id": season_id,
		"fixtures": fixtures.duplicate(true),
		"standings": standings.duplicate(true),
		"saved_at": Time.get_datetime_string_from_system(true)
	}
	_append_audit("competition_state_saved", {"stage_id": stage_id, "season_id": season_id})
	if not _commit_database():
		if previous.is_empty():
			database.competition_states.erase(stage_id)
		else:
			database.competition_states[stage_id] = previous
		return false
	database_changed.emit(get_summary())
	return true

func save_season_state(season_id: String, state: Dictionary) -> bool:
	if not is_open and not open_database():
		return false
	if season_id.is_empty() or state.is_empty():
		return _fail("No se puede guardar una temporada vacía.")
	var previous: Dictionary = database.season_states.get(season_id, {}).duplicate(true)
	var audit_before: Array = database.audit_log.duplicate(true)
	database.season_states[season_id] = {"state": state.duplicate(true), "saved_at": Time.get_datetime_string_from_system(true)}
	_append_audit("season_state_saved", {"season_id": season_id})
	if not _commit_database():
		database.audit_log = audit_before
		if previous.is_empty():
			database.season_states.erase(season_id)
		else:
			database.season_states[season_id] = previous
		return false
	return true

func save_career_record(career_id: String, state: Dictionary) -> bool:
	if not is_open and not open_database():
		return false
	if career_id.is_empty() or state.is_empty():
		return _fail("No se puede guardar una carrera sin ID o estado.")
	var previous: Dictionary = database.career_records.get(career_id, {}).duplicate(true)
	var audit_before: Array = database.audit_log.duplicate(true)
	database.career_records[career_id] = {"state": state.duplicate(true), "saved_at": Time.get_datetime_string_from_system(true)}
	_append_audit("career_record_saved", {"career_id": career_id})
	if not _commit_database():
		database.audit_log = audit_before
		if previous.is_empty():
			database.career_records.erase(career_id)
		else:
			database.career_records[career_id] = previous
		return false
	return true

func get_summary() -> Dictionary:
	var catalog: Dictionary = database.get("catalog", {})
	var master: Dictionary = database.get("master_catalog", {})
	return {
		"open": is_open,
		"schema_version": str(database.get("schema_version", "")),
		"players": catalog.get("players", {}).size(),
		"playable_clubs": catalog.get("teams", {}).size(),
		"playable_competitions": catalog.get("competitions", {}).size(),
		"associations": master.get("associations", []).size(),
		"countries": master.get("countries", []).size(),
		"master_clubs": master.get("clubs", []).size(),
		"master_competitions": master.get("competitions", []).size(),
		"master_seasons": master.get("seasons", []).size(),
		"master_sources": master.get("sources", []).size(),
		"national_teams": master.get("national_teams", []).size(),
		"national_players": master.get("national_players", []).size(),
		"league_directory_entries": master.get("league_directory", []).size(),
		"club_memberships": master.get("club_memberships", []).size(),
		"reference_roster_packages": master.get("reference_roster_packages", []).size(),
		"reference_roster_players": _count_reference_roster_players(master.get("reference_roster_packages", [])),
		"match_results": database.get("match_results", {}).size(),
		"competition_states": database.get("competition_states", {}).size(),
		"season_states": database.get("season_states", {}).size(),
		"career_records": database.get("career_records", {}).size(),
		"audit_events": database.get("audit_log", []).size(),
		"last_error": last_error
	}

func _count_reference_roster_players(packages: Array) -> int:
	var total := 0
	for package in packages:
		total += int(package.get("player_count", 0))
	return total

func _append_audit(event_type: String, payload: Dictionary) -> void:
	var events: Array = database.get("audit_log", [])
	events.append({"event": event_type, "at": Time.get_datetime_string_from_system(true), "payload": payload.duplicate(true)})
	if events.size() > MAX_AUDIT_EVENTS:
		events = events.slice(events.size() - MAX_AUDIT_EVENTS)
	database["audit_log"] = events

func _commit_database() -> bool:
	database["schema_version"] = SCHEMA_VERSION
	database["updated_at"] = Time.get_datetime_string_from_system(true)
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		return _fail("No se pudo abrir el archivo temporal de la base de datos.")
	file.store_string(JSON.stringify(database, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return _fail("Error al escribir la base de datos.")
	var main_absolute := ProjectSettings.globalize_path(DATABASE_PATH)
	var temp_absolute := ProjectSettings.globalize_path(TEMP_PATH)
	var backup_absolute := ProjectSettings.globalize_path(BACKUP_PATH)
	if FileAccess.file_exists(DATABASE_PATH):
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.remove_absolute(backup_absolute)
		var backup_error := DirAccess.rename_absolute(main_absolute, backup_absolute)
		if backup_error != OK:
			return _fail("No se pudo crear la copia de seguridad de la base de datos.")
	var commit_error := DirAccess.rename_absolute(temp_absolute, main_absolute)
	if commit_error != OK:
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.rename_absolute(backup_absolute, main_absolute)
		return _fail("No se pudo confirmar la escritura atómica de la base de datos.")
	last_error = ""
	return true

func _fail(message: String) -> bool:
	last_error = message
	database_error.emit(message)
	return false
