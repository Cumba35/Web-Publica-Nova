extends RefCounted
class_name NovaMasterCatalogImporter

const ASSOCIATIONS_PATH := "res://data/national_association_directory.json"
const SPAIN_CLUBS_PATH := "res://data/spain_clubs_2026_27.json"
const SPAIN_COMPETITIONS_PATH := "res://data/spain_leagues_2026_27.json"
const ADDITIONAL_LEAGUES_PATH := "res://data/imports/additional_league_club_membership_2026_27.json"
const LEAGUE_SELECTION_PATH := "res://data/global_league_selection_100.json"
const ENGLAND_MEMBERSHIP_PATH := "res://data/imports/verified_club_membership.csv"
const SPAIN_MEMBERSHIP_PATH := "res://data/imports/spain_2026_27_club_membership.csv"
const TURKEY_ROSTERS_PATH := "res://data/imports/turkey_super_lig_rosters_2026_27.json"
const BELGIUM_ROSTERS_PATH := "res://data/imports/belgium_jupiler_pro_league_rosters_2026_27_partial.json"
const BASE_LEAGUE_DATA_PATH := "res://data/base_league_clubs_2026.json"
const USA_LEAGUES_PATH := "res://data/usa_leagues_2026.json"

static func build_catalog(registry: NovaFootballDataRegistry) -> Dictionary:
	var errors := PackedStringArray()
	if registry == null:
		return {"ok": false, "errors": ["Registro deportivo no disponible"]}
	var associations_data := _read_json(ASSOCIATIONS_PATH, errors)
	var spain_clubs_data := _read_json(SPAIN_CLUBS_PATH, errors)
	var spain_competitions_data := _read_json(SPAIN_COMPETITIONS_PATH, errors)
	var additional_data := _read_json(ADDITIONAL_LEAGUES_PATH, errors)
	var selection_data := _read_json(LEAGUE_SELECTION_PATH, errors)
	var turkey_rosters := _read_json(TURKEY_ROSTERS_PATH, errors)
	var belgium_rosters := _read_json(BELGIUM_ROSTERS_PATH, errors)
	var base_league_data := _read_json(BASE_LEAGUE_DATA_PATH, errors)
	var usa_leagues_data := _read_json(USA_LEAGUES_PATH, errors)
	var england_memberships := _read_csv(ENGLAND_MEMBERSHIP_PATH, errors)
	var spain_memberships := _read_csv(SPAIN_MEMBERSHIP_PATH, errors)
	if not errors.is_empty():
		return {"ok": false, "errors": errors}
	var associations: Array = []
	for association in associations_data.get("associations", []):
		if not association is Dictionary:
			continue
		var confederation_value = association.get("confederation_code", "")
		if confederation_value == null:
			confederation_value = ""
		var confederation_code := str(confederation_value)
		associations.append({
			"id": str(association.get("association_id", "")),
			"name": str(association.get("fifa_name", "")),
			"confederation": confederation_code,
			"fifa_member": true,
			"confederation_status": str(association.get("confederation_status", "pending")),
			"national_roster_status": str(association.get("senior_mens_roster_status", "not_verified")),
			"source_rights_review": str(association.get("source_rights_review", "pending")),
			"source_ids": ["fifa_" + confederation_code.to_lower()],
			"confederation_verified_at": str(association.get("confederation_verified_at", ""))
		})
	var country_code_aliases := {
		"Cuba": "CUB", "England": "ENG", "Spain": "ESP", "Brazil": "BRA", "Italy": "ITA", "Germany": "GER", "France": "FRA", "Portugal": "POR", "Argentina": "ARG", "United States": "USA", "Türkiye": "TUR",
		"Belgium": "BEL", "Saudi Arabia": "KSA", "Ecuador": "ECU", "Greece": "GRE",
		"Egypt": "EGY", "Czechia": "CZE", "Japan": "JPN", "Paraguay": "PAR", "Cyprus": "CYP"
	}
	var countries_by_id: Dictionary = {}
	var country_id_by_code: Dictionary = {}
	for association in associations:
		var country_id := str(association.get("id", ""))
		var country_name := str(association.get("name", ""))
		var country_code := str(country_code_aliases.get(country_name, ""))
		countries_by_id[country_id] = {
			"id": country_id,
			"name": country_name,
			"association_id": country_id,
			"country_code": country_code,
			"confederation": str(association.get("confederation", "")),
			"source_ids": association.get("source_ids", []).duplicate(true)
		}
		if not country_code.is_empty():
			country_id_by_code[country_code] = country_id
	var countries: Array = []
	for country_id in countries_by_id:
		countries.append(countries_by_id[country_id])
	var league_directory: Array = []
	for selected_league in selection_data.get("leagues", []):
		if not selected_league is Dictionary:
			continue
		league_directory.append({
			"source_rank": int(selected_league.get("source_rank", 0)),
			"league": str(selected_league.get("league", "")),
			"country": str(selected_league.get("country", "")),
			"counts_as_existing_base": bool(selected_league.get("counts_as_existing_base", false)),
			"creation_status": str(selected_league.get("creation_status", "selected_pending_verification")),
			"playable": bool(selected_league.get("playable", false)),
			"season": str(selection_data.get("season", "")),
			"selection_source": str(selection_data.get("ranking_policy", {}).get("source_url", "")),
			"source_updated": str(selection_data.get("ranking_policy", {}).get("source_updated", ""))
		})
	var clubs_by_id: Dictionary = {}
	var competitions_by_id: Dictionary = {}
	var seasons_by_id: Dictionary = {}
	var sources_by_id: Dictionary = {}
	sources_by_id["global_league_selection_100"] = {
		"id": "global_league_selection_100",
		"url": str(selection_data.get("ranking_policy", {}).get("source_url", "")),
		"publisher": str(selection_data.get("ranking_policy", {}).get("source_name", "League ranking")),
		"retrieved_at": str(selection_data.get("ranking_policy", {}).get("source_updated", "")),
		"license_status": "unknown",
		"supports": ["100-league research priority only; not verified membership or playability"],
		"confidence": "low"
	}
	for confederation_code in ["AFC", "CAF", "CONCACAF", "CONMEBOL", "OFC", "UEFA"]:
		sources_by_id["fifa_" + confederation_code.to_lower()] = {
			"id": "fifa_" + confederation_code.to_lower(),
			"url": "https://inside.fifa.com/associations/" + confederation_code,
			"publisher": "FIFA",
			"retrieved_at": "2026-11-14",
			"license_status": "permission_required",
			"supports": ["member association confederation assignment"],
			"confidence": "high"
		}
	for row in england_memberships:
		var competition_id := str(row.get("competition_id", ""))
		var source_id := _membership_source_id("ENG", competition_id)
		if not source_id.is_empty() and not sources_by_id.has(source_id):
			sources_by_id[source_id] = {
				"id": source_id,
				"url": str(row.get("source_url", "")),
				"publisher": _membership_source_publisher(competition_id),
				"retrieved_at": "2026-11-14",
				"license_status": "permission_required",
				"supports": ["England 2026-27 club membership"],
				"confidence": "medium" if competition_id != "ENG-PL-2026-27" else "high"
			}
	sources_by_id["source_nova_cuba_original_membership"] = {
		"id": "source_nova_cuba_original_membership",
		"url": "https://github.com/Cumba35/Nova-Workspace/blob/main/proyectos/juegos/futbol-nova/data/cuba_leagues.json",
		"publisher": "Nova Apps — Fútbol Nova original game data",
		"retrieved_at": "2026-11-14",
		"license_status": "original_content",
		"supports": ["fictional Cuba league and club membership created for Fútbol Nova"],
		"confidence": "high"
	}
	sources_by_id["source_turkey_roster_reference_2026_27"] = {
		"id": "source_turkey_roster_reference_2026_27",
		"url": str(turkey_rosters.get("source_announcement_url", "")),
		"publisher": str(turkey_rosters.get("source_authority", "Türkiye Futbol Federasyonu")),
		"retrieved_at": str(turkey_rosters.get("source_announcement_date", "2026-09-16")),
		"license_status": str(turkey_rosters.get("rights_status", "reference_only_reuse_rights_not_cleared")),
		"supports": ["officially published registration-name reference only; not playable"],
		"confidence": "high"
	}
	sources_by_id["source_belgium_roster_reference_2026_27"] = {
		"id": "source_belgium_roster_reference_2026_27",
		"url": "https://www.proleague.be/jpl-clubs",
		"publisher": str(belgium_rosters.get("source_authority", "Belgian Pro League")),
		"retrieved_at": str(belgium_rosters.get("snapshot_date", "2026-11-14")),
		"license_status": str(belgium_rosters.get("rights_status", "reference_only_reuse_rights_not_cleared")),
		"supports": ["partial official club roster name references only; not playable"],
		"confidence": "medium"
	}
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		var country_code := str(team.get("country_id", ""))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var competition_id := str(team.get("competition_id", ""))
		var season_label := str(team.get("season", "2026-27"))
		var season_id := _season_id(country_id, season_label)
		var fictional := bool(team.get("fictional", true))
		var identity_ready := _team_identity_is_release_ready(team)
		clubs_by_id[str(team_id)] = {
			"id": str(team_id),
			"country_id": country_id,
			"country_code": country_code,
			"name": str(team.get("name", team_id)),
			"source_reference_id": str(team.get("source_reference_id", "")),
			"competition_id": competition_id,
			"season_id": season_id,
			"division_level": int(team.get("division_level", team.get("competition_level", 0))),
			"group_id": str(team.get("group_id", "")),
			"player_ids": team.get("player_ids", []).duplicate(true),
			"fictional": fictional,
			"identity_type": str(team.get("identity", {}).get("identity_type", "original_fictional_club")),
			"playable": team.get("player_ids", []).size() >= 11 and identity_ready,
			"status": "integrated" if identity_ready else "draft_identity_review_required",
			"source_ids": _source_ids_for_country(country_code, competition_id)
		}
		_add_season(seasons_by_id, country_id, season_label)
	for competition_id in registry.competitions_by_id:
		var competition: Dictionary = registry.competitions_by_id[competition_id]
		var country_code := str(competition.get("country_id", "CUB"))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var season_label := str(competition.get("season", "2026-27"))
		var season_id := _season_id(country_id, season_label)
		competitions_by_id[str(competition_id)] = {
			"id": str(competition_id),
			"country_id": country_id,
			"country_code": country_code,
			"season_id": season_id,
			"name": str(competition.get("name", competition_id)),
			"level": int(competition.get("level", 1)),
			"competition_type": str(competition.get("competition_type", "league")),
			"format": str(competition.get("format", "single_group_double_round_robin")),
			"team_ids": competition.get("team_ids", []).duplicate(true),
			"status": "integrated",
			"source_ids": []
		}
		_add_season(seasons_by_id, country_id, season_label)
	for club in spain_clubs_data.get("clubs", []):
		if not club is Dictionary:
			continue
		var id := str(club.get("id", ""))
		if id.is_empty():
			errors.append("ID español vacío")
			continue
		if clubs_by_id.has(id):
			clubs_by_id[id]["source_reference_id"] = str(club.get("source_reference_id", clubs_by_id[id].get("source_reference_id", "")))
			clubs_by_id[id]["source_provenance"] = str(club.get("source_provenance", clubs_by_id[id].get("source_provenance", "")))
			clubs_by_id[id]["source_ids"] = ["spain_laliga_2026_27", "spain_rfef_2026_27"]
			continue
		var country_code := str(club.get("country_code", "ESP"))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var season_label := str(club.get("season", "2026-27"))
		var season_id := _season_id(country_id, season_label)
		clubs_by_id[id] = {
			"id": id,
			"country_id": country_id,
			"country_code": country_code,
			"name": str(club.get("display_name", id)),
			"source_reference_id": str(club.get("source_reference_id", "")),
			"source_provenance": str(club.get("source_provenance", "")),
			"city": str(club.get("city", "")),
			"competition_id": str(club.get("competition_id", "")),
			"season_id": season_id,
			"division_level": int(club.get("division_level", 0)),
			"group_id": str(club.get("group_id", "")),
			"player_ids": [],
			"fictional": true,
			"identity_type": "original_fictional_club",
			"playable": false,
			"status": str(club.get("status", "draft_review_required")),
			"source_ids": ["spain_laliga_2026_27", "spain_rfef_2026_27"]
		}
		_add_season(seasons_by_id, country_id, season_label)
	sources_by_id["spain_laliga_2026_27"] = {
		"id": "spain_laliga_2026_27",
		"url": "https://www.laliga.com/",
		"publisher": "LALIGA",
		"retrieved_at": "2026-11-14",
		"license_status": "permission_required",
		"supports": ["Spain 2026-27 first-division membership"],
		"confidence": "high"
	}
	sources_by_id["spain_rfef_2026_27"] = {
		"id": "spain_rfef_2026_27",
		"url": "https://rfef.es/",
		"publisher": "Real Federación Española de Fútbol",
		"retrieved_at": "2026-11-14",
		"license_status": "permission_required",
		"supports": ["Spain 2026-27 second and third-division membership"],
		"confidence": "high"
	}
	for source_country in base_league_data.get("countries", []):
		var source_code := str(source_country.get("country_code", ""))
		var source_id := "source_base_" + source_code.to_lower()
		sources_by_id[source_id] = {
			"id": source_id,
			"url": str(source_country.get("source_url", "")),
			"publisher": str(source_country.get("country", "National league source")) + " league membership reference",
			"retrieved_at": "2026-11-15",
			"license_status": "reference_only_reuse_rights_not_cleared",
			"supports": [str(source_country.get("country", "")) + " season-specific club membership; fictional game players stored separately"],
			"confidence": "medium"
		}
	for usa_source in usa_leagues_data.get("sources", []):
		var organization := str(usa_source.get("organization", ""))
		var source_id := "source_usa_" + organization.to_lower().replace(" ", "_") + "_2026"
		sources_by_id[source_id] = {
			"id": source_id,
			"url": str(usa_source.get("url", "")),
			"publisher": organization,
			"retrieved_at": "2026-11-15",
			"license_status": "reference_only_reuse_rights_not_cleared",
			"supports": [str(usa_source.get("scope", "United States 2026 competition membership"))],
			"confidence": "high"
		}
	for competition in spain_competitions_data.get("competitions", []):
		if not competition is Dictionary:
			continue
		var id := str(competition.get("id", ""))
		if id.is_empty():
			continue
		var country_code := str(competition.get("country_id", "ESP"))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var season_label := str(competition.get("season", "2026-27"))
		competitions_by_id[id] = {
			"id": id,
			"country_id": country_id,
			"country_code": country_code,
			"season_id": _season_id(country_id, season_label),
			"name": str(competition.get("name", id)),
			"level": int(competition.get("level", 1)),
			"competition_type": "league",
			"format": str(competition.get("format", "single_group_double_round_robin")),
			"team_ids": competition.get("team_ids", []).duplicate(true),
			"status": "membership_catalogued_rosters_pending",
			"source_ids": ["spain_laliga_2026_27", "spain_rfef_2026_27"]
		}
		_add_season(seasons_by_id, country_id, season_label)
	for league in additional_data.get("leagues", []):
		if not league is Dictionary:
			continue
		var country_code := str(league.get("country_code", ""))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var season_label := str(league.get("season", "2026-27"))
		var season_id := _season_id(country_id, season_label)
		var competition_id := "FN-%s-L1-%s" % [country_id, season_label.replace("-", "_")]
		var club_ids: Array = []
		for club in league.get("clubs", []):
			if not club is Dictionary:
				continue
			var id := str(club.get("id", ""))
			if id.is_empty() or clubs_by_id.has(id):
				errors.append("ID de club adicional vacío o duplicado: " + id)
				continue
			club_ids.append(id)
			clubs_by_id[id] = {
				"id": id,
				"country_id": country_id,
				"country_code": country_code,
				"name": str(club.get("name", id)),
				"competition_id": competition_id,
				"season_id": season_id,
				"division_level": int(league.get("division_level", 1)),
				"group_id": "",
				"player_ids": [],
				"fictional": false,
				"identity_type": "reference_only_unlicensed",
				"playable": false,
				"status": str(league.get("membership_status", "pending_review")),
				"source_ids": ["source_" + country_id.to_lower() + "_2026_27"]
			}
		var source: Dictionary = league.get("source", {})
		var source_id := "source_" + country_id.to_lower() + "_2026_27"
		if not source.is_empty():
			sources_by_id[source_id] = {
				"id": source_id,
				"url": str(source.get("url", "")),
				"publisher": str(source.get("publisher", source.get("description", "League source"))),
				"retrieved_at": str(source.get("checked_at", "2026-11-14")),
				"license_status": "permission_required",
				"supports": ["club membership " + country_id + " " + season_label],
				"confidence": "medium" if str(league.get("membership_status", "")).contains("pending") else "high"
			}
		competitions_by_id[competition_id] = {
			"id": competition_id,
			"country_id": country_id,
			"country_code": country_code,
			"season_id": season_id,
			"name": str(league.get("competition_name", competition_id)),
			"level": int(league.get("division_level", 1)),
			"competition_type": "league",
			"format": "single_group_double_round_robin",
			"team_ids": club_ids,
			"status": str(league.get("membership_status", "pending_review")),
			"source_ids": [source_id]
		}
		_add_season(seasons_by_id, country_id, season_label)
	var source_reference_to_game_id := {}
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		var source_reference_id := str(team.get("source_reference_id", ""))
		if not source_reference_id.is_empty():
			source_reference_to_game_id[source_reference_id] = str(team_id)
	for club in spain_clubs_data.get("clubs", []):
		var source_reference_id := str(club.get("source_reference_id", ""))
		if not source_reference_id.is_empty():
			source_reference_to_game_id[source_reference_id] = str(club.get("id", ""))
	var memberships_by_id: Dictionary = {}
	for row in england_memberships + spain_memberships:
		var source_club_id := str(row.get("source_club_id", ""))
		var club_id := str(source_reference_to_game_id.get(source_club_id, ""))
		var competition_id := str(row.get("competition_id", ""))
		if club_id.is_empty() or not clubs_by_id.has(club_id):
			errors.append("Membresía sin club de juego vinculado: " + source_club_id)
			continue
		if not competitions_by_id.has(competition_id):
			errors.append("Membresía sin competición vinculada: " + competition_id)
			continue
		var country_code := str(row.get("country_code", ""))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var season_label := str(row.get("season", "2026-27"))
		var season_id := _season_id(country_id, season_label)
		var source_id := _membership_source_id(country_code, competition_id)
		if source_id.is_empty():
			errors.append("Membresía sin fuente configurada: " + competition_id)
			continue
		var membership_id := club_id + "|" + competition_id + "|" + season_id
		if memberships_by_id.has(membership_id):
			errors.append("Membresía duplicada: " + membership_id)
			continue
		var club_record: Dictionary = clubs_by_id[club_id]
		memberships_by_id[membership_id] = {
			"id": membership_id,
			"club_id": club_id,
			"country_id": country_id,
			"country_code": country_code,
			"competition_id": competition_id,
			"season_id": season_id,
			"division_level": int(row.get("division_level", 0)),
			"group_id": str(club_record.get("group_id", "")),
			"active": str(row.get("active", "true")).to_lower() == "true",
			"gender": str(row.get("gender", "men")),
			"team_type": str(row.get("team_type", "first_team")),
			"status": "source_verified_membership",
			"playable": bool(club_record.get("playable", false)),
			"reference_club_id": source_club_id,
			"source_url": str(row.get("source_url", "")),
			"source_ids": [source_id]
		}
		_add_season(seasons_by_id, country_id, season_label)
	for league in additional_data.get("leagues", []):
		var country_code := str(league.get("country_code", ""))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var season_label := str(league.get("season", "2026-27"))
		var season_id := _season_id(country_id, season_label)
		var competition_id := "FN-%s-L1-%s" % [country_id, season_label.replace("-", "_")]
		var source_id := "source_" + country_id.to_lower() + "_2026_27"
		for club in league.get("clubs", []):
			var club_id := str(club.get("id", ""))
			if not clubs_by_id.has(club_id):
				errors.append("Membresía adicional sin club: " + club_id)
				continue
			var membership_id := club_id + "|" + competition_id + "|" + season_id
			if memberships_by_id.has(membership_id):
				errors.append("Membresía adicional duplicada: " + membership_id)
				continue
			memberships_by_id[membership_id] = {
				"id": membership_id,
				"club_id": club_id,
				"country_id": country_id,
				"country_code": country_code,
				"competition_id": competition_id,
				"season_id": season_id,
				"division_level": int(league.get("division_level", 1)),
				"group_id": "",
				"active": true,
				"gender": "men",
				"team_type": "first_team",
				"status": str(league.get("membership_status", "pending_review")),
				"playable": false,
				"reference_club_id": club_id,
				"source_url": str(league.get("source", {}).get("url", "")),
				"source_ids": [source_id]
			}
		_add_season(seasons_by_id, country_id, season_label)
	for team_id in registry.teams_by_id:
		var team: Dictionary = registry.teams_by_id[team_id]
		var competition_id := str(team.get("competition_id", ""))
		if competition_id.is_empty() or not competitions_by_id.has(competition_id):
			continue
		var already_registered := false
		for membership in memberships_by_id.values():
			if str(membership.get("club_id", "")) == str(team_id):
				already_registered = true
				break
		if already_registered:
			continue
		var country_code := str(team.get("country_id", ""))
		var country_id := str(country_id_by_code.get(country_code, country_code))
		var season_label := str(team.get("season", "2026-27"))
		var season_id := _season_id(country_id, season_label)
		var source_ids: Array = _source_ids_for_country(country_code, competition_id)
		var membership_id := str(team_id) + "|" + competition_id + "|" + season_id
		memberships_by_id[membership_id] = {
			"id": membership_id,
			"club_id": str(team_id),
			"country_id": country_id,
			"country_code": country_code,
			"competition_id": competition_id,
			"season_id": season_id,
			"division_level": int(team.get("division_level", 0)),
			"group_id": str(team.get("group_id", "")),
			"active": true,
			"gender": "men",
			"team_type": "first_team",
			"status": "original_fictional_game_membership" if country_code == "CUB" else "base_game_membership_catalogued",
			"playable": team.get("player_ids", []).size() >= 11,
			"source_ids": source_ids
		}
		_add_season(seasons_by_id, country_id, season_label)
	var club_memberships: Array = []
	for membership_id in memberships_by_id:
		club_memberships.append(memberships_by_id[membership_id])
	var turkey_reference_players := 0
	for reference_club in turkey_rosters.get("clubs", []):
		turkey_reference_players += reference_club.get("players", []).size()
	var belgium_reference_players := int(belgium_rosters.get("players_transcribed", 0))
	var reference_roster_packages: Array = [
		{
			"package_id": "roster_reference.TUR.SUPER_LIG.2026-27",
			"country_code": "TUR",
			"country_id": str(country_id_by_code.get("TUR", "TUR")),
			"competition_id": "FN-%s-L1-2026_27" % str(country_id_by_code.get("TUR", "TUR")),
			"season_id": _season_id(str(country_id_by_code.get("TUR", "TUR")), "2026-27"),
			"competition": str(turkey_rosters.get("competition", "Süper Lig")),
			"source_authority": str(turkey_rosters.get("source_authority", "")),
			"rights_status": str(turkey_rosters.get("rights_status", "reference_only_reuse_rights_not_cleared")),
			"playable": false,
			"club_count": int(turkey_rosters.get("clubs", []).size()),
			"player_count": turkey_reference_players,
			"source_ids": ["source_turkey_roster_reference_2026_27"],
			"clubs": turkey_rosters.get("clubs", []).duplicate(true)
		},
		{
			"package_id": "roster_reference.BEL.JUPILER_PRO_LEAGUE.2026-27",
			"country_code": "BEL",
			"country_id": str(country_id_by_code.get("BEL", "BEL")),
			"competition_id": "FN-%s-L1-2026_27" % str(country_id_by_code.get("BEL", "BEL")),
			"season_id": _season_id(str(country_id_by_code.get("BEL", "BEL")), "2026-27"),
			"competition": str(belgium_rosters.get("competition", "Jupiler Pro League")),
			"source_authority": str(belgium_rosters.get("source_authority", "")),
			"rights_status": str(belgium_rosters.get("rights_status", "reference_only_reuse_rights_not_cleared")),
			"playable": false,
			"club_count": int(belgium_rosters.get("clubs", []).size()),
			"player_count": int(belgium_rosters.get("players_transcribed", 0)),
			"source_ids": ["source_belgium_roster_reference_2026_27"],
			"clubs": belgium_rosters.get("clubs", []).duplicate(true)
		}
	]
	if not errors.is_empty():
		return {"ok": false, "errors": errors}
	var sources: Array = []
	for source_id in sources_by_id:
		sources.append(sources_by_id[source_id])
	var clubs: Array = []
	for id in clubs_by_id:
		clubs.append(clubs_by_id[id])
	var competitions: Array = []
	for id in competitions_by_id:
		competitions.append(competitions_by_id[id])
	var seasons: Array = []
	for id in seasons_by_id:
		seasons.append(seasons_by_id[id])
	return {
		"ok": true,
		"catalog": {
			"schema_version": "1.0.0",
			"associations": associations,
			"countries": countries,
			"clubs": clubs,
			"competitions": competitions,
			"seasons": seasons,
			"sources": sources,
			"club_memberships": club_memberships,
			"reference_roster_packages": reference_roster_packages,
			"national_teams": [],
			"national_players": [],
			"league_directory": league_directory,
		},
		"counts": {
			"associations": associations.size(),
			"countries": countries.size(),
			"clubs": clubs.size(),
			"competitions": competitions.size(),
			"seasons": seasons.size(),
			"sources": sources.size(),
			"club_memberships": club_memberships.size(),
			"reference_roster_packages": reference_roster_packages.size(),
			"reference_roster_players": turkey_reference_players + belgium_reference_players,
			"players": registry.players_by_id.size(),
			"league_directory": league_directory.size()
		}
	}

static func _source_ids_for_country(country_code: String, competition_id: String = "") -> Array:
	match country_code:
		"BRA", "ITA", "GER", "FRA", "POR", "ARG":
			return ["source_base_" + country_code.to_lower()]
		"USA":
			if competition_id == "USA-MLS-2026":
				return ["source_usa_mls_2026"]
			if competition_id == "USA-USLC-2026":
				return ["source_usa_usl_championship_2026"]
			if competition_id == "USA-USL1-2026":
				return ["source_usa_usl_league_one_2026"]
			return []
		"CUB":
			return ["source_nova_cuba_original_membership"]
		"ESP":
			return ["spain_laliga_2026_27", "spain_rfef_2026_27"]
		_:
			return []

static func _membership_source_id(country_code: String, competition_id: String) -> String:
	if country_code == "ENG":
		if competition_id == "ENG-PL-2026-27":
			return "source_england_premier_2026_27"
		if competition_id == "ENG-CHAMP-2026-27":
			return "source_england_championship_2026_27"
		if competition_id == "ENG-L1-2026-27":
			return "source_england_league_one_2026_27"
	if country_code == "ESP":
		if competition_id == "ESP-LL-2026-27" or competition_id == "ESP-HY-2026-27":
			return "spain_laliga_2026_27"
		if competition_id == "ESP-PF-2026-27":
			return "spain_rfef_2026_27"
	return ""

static func _membership_source_publisher(competition_id: String) -> String:
	if competition_id == "ENG-PL-2026-27":
		return "Premier League"
	if competition_id == "ENG-CHAMP-2026-27":
		return "Paramount+"
	if competition_id == "ENG-L1-2026-27":
		return "Sky Sports"
	return "Competition membership source"

static func _read_csv(path: String, errors: PackedStringArray) -> Array:
	if not FileAccess.file_exists(path):
		errors.append("No existe el archivo CSV: " + path)
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir el CSV: " + path)
		return []
	var lines := file.get_as_text().split("\n", false)
	if lines.is_empty():
		errors.append("CSV vacío: " + path)
		return []
	var headers := _parse_csv_row(str(lines[0]).strip_edges())
	var rows: Array = []
	for line_index in range(1, lines.size()):
		var line := str(lines[line_index]).strip_edges()
		if line.is_empty():
			continue
		var values := _parse_csv_row(line)
		var row := {}
		for column_index in range(headers.size()):
			row[str(headers[column_index])] = str(values[column_index]) if column_index < values.size() else ""
		rows.append(row)
	return rows

static func _parse_csv_row(line: String) -> Array:
	var values: Array = []
	var current := ""
	var inside_quotes := false
	var index := 0
	while index < line.length():
		var character := line.substr(index, 1)
		if character == "\"":
			if inside_quotes and index + 1 < line.length() and line.substr(index + 1, 1) == "\"":
				current += "\""
				index += 1
			else:
				inside_quotes = not inside_quotes
		elif character == "," and not inside_quotes:
			values.append(current)
			current = ""
		else:
			current += character
		index += 1
	values.append(current)
	return values

static func _read_json(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("No existe el archivo de catálogo: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir el catálogo: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("JSON de catálogo inválido: " + path)
		return {}
	return parsed

static func _season_id(country_id: String, label: String) -> String:
	return country_id + "-" + label.replace("/", "_").replace("-", "_")

static func _add_season(target: Dictionary, country_id: String, label: String) -> void:
	var id := _season_id(country_id, label)
	if target.has(id):
		return
	target[id] = {
		"id": id,
		"country_id": country_id,
		"label": label,
		"calendar_type": "cross_year" if label.contains("-") or label.contains("/") else "calendar_year"
	}


static func _team_identity_is_release_ready(team: Dictionary) -> bool:
	var identity_value = team.get("identity", {})
	if not identity_value is Dictionary:
		return false
	var identity: Dictionary = identity_value
	# Legacy/base teams without an explicit review gate retain their existing behaviour.
	if not identity.has("review_status"):
		return true
	return str(identity.get("review_status", "")) == "approved" \
		and str(identity.get("trademark_review_status", "")) in ["reviewed_no_obvious_conflict", "licensed"] \
		and bool(identity.get("visual_assets_original", false))
