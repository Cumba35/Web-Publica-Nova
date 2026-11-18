extends SceneTree

const Database = preload("res://scripts/data/football_database_service.gd")
const MasterImporter = preload("res://scripts/data/master_catalog_importer.gd")
const Registry = preload("res://scripts/data/football_data_registry.gd")
const CubaImporter = preload("res://scripts/data/cuba_league_importer.gd")
const GlobalImporter = preload("res://scripts/data/global_league_importer.gd")
const CubaRosterImporter = preload("res://scripts/data/cuba_roster_importer.gd")
const USAImporter = preload("res://scripts/data/usa_league_importer.gd")
const BaseLeagueImporter = preload("res://scripts/data/base_league_importer.gd")
const BaseRosterImporter = preload("res://scripts/data/base_league_roster_importer.gd")

func _initialize() -> void:
	var failures := PackedStringArray()
	var draft_identity := {
		"identity": {
			"review_status": "draft_review_required",
			"trademark_review_status": "not_reviewed",
			"visual_assets_original": false
		}
	}
	if MasterImporter._team_identity_is_release_ready(draft_identity):
		failures.append("Identidad global en borrador no debe superar la revisión de publicación")
	var approved_identity := {
		"identity": {
			"review_status": "approved",
			"trademark_review_status": "reviewed_no_obvious_conflict",
			"visual_assets_original": true
		}
	}
	if not MasterImporter._team_identity_is_release_ready(approved_identity):
		failures.append("Identidad global aprobada no superó la revisión de publicación")
	var legacy_identity := {"identity": {"identity_type": "original_fictional_club"}}
	if not MasterImporter._team_identity_is_release_ready(legacy_identity):
		failures.append("La política de revisión alteró los clubes heredados sin gate explícito")
	var db = Database.new()
	root.add_child(db)
	if not db.is_open:
		failures.append("Database: no abrió o creó el archivo local")
	var original_database: Dictionary = db.database.duplicate(true)
	db.database = {"schema_version": "0.9.0"}
	if not db._migrate_database() or not db._validate_database():
		failures.append("Database: no migró la estructura 0.9.0 a la versión actual")
	db.database = original_database
	db.database["schema_version"] = "99.0.0"
	if db._migrate_database():
		failures.append("Database: aceptó una versión futura desconocida")
	db.database = original_database

	var registry = Registry.new()
	registry.players_by_id = {
		"p_test": {"id": "p_test", "display_name": "Jugador de prueba"}
	}
	registry.teams_by_id = {
		"t_test": {"id": "t_test", "name": "Club de prueba", "country_id": "CUB", "player_ids": ["p_test"]}
	}
	registry.competitions_by_id = {
		"c_test": {"id": "c_test", "name": "Liga de prueba", "team_ids": ["t_test"]}
	}
	if not db.save_catalog_snapshot(registry.export_catalog_snapshot()):
		failures.append("Database: rechazó snapshot deportivo válido")
	if db.get_player("p_test").is_empty() or db.get_team("t_test").is_empty() or db.get_competition("c_test").is_empty():
		failures.append("Database: las consultas por ID no recuperan registros")
	var master := {
		"associations": [{"id": "FIFA-TEST", "name": "Asociación de prueba"}],
		"countries": [],
		"clubs": [{"id": "t_test", "country_id": "CUB", "name": "Club de prueba"}],
		"competitions": [{"id": "c_test", "team_ids": ["t_test"]}],
		"seasons": [{"id": "CUB-2026", "label": "2026"}],
		"sources": [{"id": "source_test", "url": "https://example.org", "publisher": "Test"}],
		"national_teams": [],
		"national_players": [],
		"league_directory": [],
		"club_memberships": [],
		"reference_roster_packages": []
	}
	if not db.save_master_catalog(master):
		failures.append("Database: rechazó catálogo maestro válido: " + db.last_error)
	if db.get_association("FIFA-TEST").is_empty() or db.get_master_club("t_test").is_empty():
		failures.append("Database: no recupera asociaciones o clubes del catálogo maestro")
	var result := {
		"match_id": "match_test_001",
		"home_team_id": "t_test",
		"away_team_id": "t_opponent",
		"home_goals": 2,
		"away_goals": 1,
		"status": "finished"
	}
	var standings := {"t_test": {"points": 3}, "t_opponent": {"points": 0}}
	var fixtures := [{"fixture_id": "match_test_001", "status": "finished", "home_goals": 2, "away_goals": 1}]
	if not db.commit_match_and_competition_state("stage_test", "season_test", result, fixtures, standings):
		failures.append("Database: no guardó resultado y clasificación como transacción")
	if not db.has_match_result("match_test_001") or db.get_match_result("match_test_001").is_empty():
		failures.append("Database: no recupera resultados de partidos")
	if db.commit_match_and_competition_state("stage_test", "season_test", result, fixtures, standings):
		failures.append("Database: permitió duplicar el mismo resultado")
	var restored := db.get_competition_state("stage_test")
	if restored.is_empty() or restored.get("fixtures", []).size() != 1:
		failures.append("Database: no recupera el estado de competición")
	if not db.save_season_state("season_test", {"round": 3, "complete": false}) or db.get_season_state("season_test").is_empty():
		failures.append("Database: no guarda y consulta temporadas")
	if not db.save_career_record("career_test", {"mode": "legend", "player_id": "p_test"}) or db.get_career_record("career_test").is_empty():
		failures.append("Database: no guarda y consulta carreras")
	var summary := db.get_summary()
	if int(summary.get("match_results", 0)) < 1 or int(summary.get("audit_events", 0)) < 4:
		failures.append("Database: resumen o bitácora incompletos")
	var source_registry = Registry.new()
	var cuba_import: Dictionary = CubaImporter.import_into_registry(source_registry)
	var cuba_rosters: Dictionary = CubaRosterImporter.import_into_registry(source_registry)
	var global_import: Dictionary = GlobalImporter.import_into_registry(source_registry)
	var usa_import: Dictionary = USAImporter.import_into_registry(source_registry)
	var base_import: Dictionary = BaseLeagueImporter.import_into_registry(source_registry)
	var base_rosters: Dictionary = BaseRosterImporter.import_into_registry(source_registry)
	if not bool(cuba_import.get("ok", false)) or not bool(cuba_rosters.get("ok", false)) or not bool(global_import.get("ok", false)) or not bool(usa_import.get("ok", false)) or not bool(base_import.get("ok", false)) or not bool(base_rosters.get("ok", false)):
		failures.append("Master catalog: no se pudieron cargar los lotes de las diez ligas base")
	var imported: Dictionary = MasterImporter.build_catalog(source_registry)
	if not bool(imported.get("ok", false)):
		failures.append("Master catalog: " + str(imported.get("errors", [])))
	else:
		var counts: Dictionary = imported.get("counts", {})
		if not db.save_catalog_snapshot(source_registry.export_catalog_snapshot()):
			failures.append("Master catalog: no se pudo guardar el snapshot jugable de origen")
		if not db.save_master_catalog(imported.catalog):
			failures.append("Master catalog: la base rechazó las relaciones normalizadas: " + db.last_error)
		var confederation_counts := {}
		for association in imported.catalog.associations:
			var confederation_code := str(association.get("confederation", ""))
			confederation_counts[confederation_code] = int(confederation_counts.get(confederation_code, 0)) + 1
		if int(confederation_counts.get("AFC", 0)) != 46 or int(confederation_counts.get("CAF", 0)) != 54 or int(confederation_counts.get("CONCACAF", 0)) != 35 or int(confederation_counts.get("CONMEBOL", 0)) != 10 or int(confederation_counts.get("OFC", 0)) != 11 or int(confederation_counts.get("UEFA", 0)) != 55:
			failures.append("Master catalog: distribución de asociaciones por confederación incorrecta")
		for association in imported.catalog.associations:
			if str(association.get("confederation", "")).is_empty():
				failures.append("Master catalog: asociación sin confederación: " + str(association.get("name", "")))
			if str(association.get("confederation_status", "")) != "verified_official_confederation_member_list":
				failures.append("Master catalog: confederación no verificada para " + str(association.get("name", "")))
		if int(counts.get("countries", 0)) != 211:
			failures.append("Master catalog: se esperaban 211 países y territorios")
		if imported.catalog.countries.is_empty() or db.get_country(str(imported.catalog.countries[0].id)).is_empty():
			failures.append("Master catalog: no recupera países por ID")
		if int(counts.get("associations", 0)) != 211:
			failures.append("Master catalog: se esperaban 211 asociaciones, hay " + str(counts.get("associations", 0)))
		if int(counts.get("players", 0)) != 15950:
			failures.append("Master catalog: se esperaban 15.950 perfiles ficticios de las diez ligas base")
		var verified_membership_count := 0
		for membership in imported.catalog.club_memberships:
			if str(membership.get("status", "")) == "source_verified_membership":
				verified_membership_count += 1
		if verified_membership_count != 150:
			failures.append("Master catalog: las 68 membresías inglesas y 82 españolas deben vincularse con sus clubes de juego")
		if int(counts.get("club_memberships", 0)) != 891:
			failures.append("Master catalog: se esperaban 891 membresías entre las diez ligas base y las ligas de referencia adicionales")
		if int(counts.get("reference_roster_packages", 0)) != 2 or int(counts.get("reference_roster_players", 0)) != 777:
			failures.append("Master catalog: se esperaban 2 paquetes de referencia con 777 registros de jugadores no jugables")
		if int(counts.get("sources", 0)) != 34:
			failures.append("Master catalog: se esperaban 34 fuentes con procedencia registrada")
		if int(counts.get("seasons", 0)) != 20:
			failures.append("Master catalog: se esperaban 20 temporadas país")
		if int(counts.get("competitions", 0)) != 41:
			failures.append("Master catalog: se esperaban 41 competiciones catalogadas")
		if int(counts.get("league_directory", 0)) != 100:
			failures.append("Master catalog: se esperaban 100 ligas en el directorio de investigación")
		var expected_memberships_by_competition := {
			"ENG-PL-2026-27": 20,
			"ENG-CHAMP-2026-27": 24,
			"ENG-L1-2026-27": 24,
			"ESP-LL-2026-27": 20,
			"ESP-HY-2026-27": 22,
			"ESP-PF-2026-27": 40
		}
		for competition_id in expected_memberships_by_competition:
			if db.get_club_memberships_by_competition(str(competition_id)).size() != int(expected_memberships_by_competition[competition_id]):
				failures.append("Database: recuento de membresías incorrecto para " + str(competition_id))
		var reference_roster_playable := false
		for package in db.get_reference_roster_packages():
			if bool(package.get("playable", true)):
				reference_roster_playable = true
		if reference_roster_playable:
			failures.append("Database: un paquete de referencia con derechos pendientes quedó jugable")
		if db.get_club_memberships_by_competition("ENG-PL-2026-27").size() != 20:
			failures.append("Database: no recupera las 20 membresías de la Premier League inglesa")
		if db.get_clubs_by_country("CUB").size() != 52:
			failures.append("Database: no recupera los 52 clubes cubanos por código de país")
		if db.get_reference_roster_packages().size() != 2:
			failures.append("Database: no recupera los paquetes de plantillas de referencia")
		if int(counts.get("clubs", 0)) != 891:
			failures.append("Master catalog: se esperaban 891 clubes de referencia, hay " + str(counts.get("clubs", 0)))
	var reopened_database = Database.new()
	root.add_child(reopened_database)
	if not reopened_database.is_open:
		failures.append("Database: no pudo reabrir el archivo persistido")
	else:
		var reopened_summary: Dictionary = reopened_database.get_summary()
		if int(reopened_summary.get("players", 0)) != 15950 or int(reopened_summary.get("associations", 0)) != 211 or int(reopened_summary.get("master_clubs", 0)) != 891:
			failures.append("Database: los recuentos de 15.950 jugadores y 891 clubes no sobrevivieron al cierre y reapertura")
		if not reopened_database.has_match_result("match_test_001"):
			failures.append("Database: el resultado finalizado no sobrevivió a la reapertura")
		if reopened_database.get_career_record("career_test").is_empty():
			failures.append("Database: el registro de carrera no sobrevivió a la reapertura")

	if failures.is_empty():
		print("FUTBOL_NOVA_DATABASE_TESTS: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
