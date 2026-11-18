extends SceneTree

const RosterService = preload("res://scripts/data/custom_player_roster_service.gd")
const ATTRIBUTE_KEYS := ["acc", "spd", "attp", "fin", "shot", "long", "vol", "pen", "vis", "cross", "fk", "short", "longp", "curve", "agi", "bal", "react", "ctrl", "drib", "comp", "int", "head", "aware", "tack", "slide", "jump", "sta", "str", "agr", "dive", "hand", "kick", "ref", "gkspd", "gkpos"]

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var service := RosterService.new()
	root.add_child(service)
	var attributes := {}
	for key in ATTRIBUTE_KEYS:
		attributes[key] = 60
	var player := {
		"id": "NOVA-USER-ROSTER-TEST",
		"origin": "user_created",
		"full_name": "Jugador Personalizado de Prueba",
		"display_name": "Jugador Personalizado de Prueba",
		"primary_position": "MCO",
		"nationality_id": "CUB",
		"overall": 60,
		"attributes": attributes
	}
	var added: Dictionary = service.add_created_player(player)
	assert(bool(added.get("ok", false)), "Debe guardar jugadores creados en el registro separado")
	assert(service.get_created_players().size() > 0, "El registro debe devolver jugadores personalizados")
	var rejected: Dictionary = service.add_created_player({
		"id": "NOVA-CATALOG-TEST",
		"origin": "nova_catalog",
		"display_name": "Jugador Oficial Nova",
		"attributes": attributes
	})
	assert(not bool(rejected.get("ok", false)), "El registro personalizado no debe aceptar jugadores del catálogo Nova")
	var selected: Dictionary = service.select_for_online("NOVA-USER-ROSTER-TEST")
	assert(bool(selected.get("ok", false)), "Debe permitir elegir un jugador creado para Online")
	assert(str(service.get_online_selected_player().get("id", "")) == "NOVA-USER-ROSTER-TEST", "Online debe conservar el ID del jugador elegido")
	assert(not bool(service.select_for_online("NOVA-CATALOG-TEST").get("ok", false)), "No debe permitir seleccionar como propio un jugador fuera del registro personalizado")
	service.clear_online_selection()
	assert(service.get_online_selected_player().is_empty(), "Debe poder quitar la selección para Online")
	service._players.erase(player)
	service._save_roster()
	print("FUTBOL_NOVA_CUSTOM_PLAYER_ROSTER_TESTS: PASS")
	quit(0)
