extends SceneTree

const OWNER_SERVICE = preload("res://scripts/data/nova_owner_access_service.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var service := OWNER_SERVICE.new()
	root.add_child(service)
	assert(OWNER_SERVICE.OWNER_USER_ID == "e2b76b60-09b4-4e01-a93f-00c9bd7e257e", "Only the canonical Nova owner identity may unlock Anier")
	assert(not service.is_owner_authenticated(), "Owner access must remain locked until NOVA native identity is integrated")
	var result: Dictionary = await service.sign_in_owner("owner@example.invalid", "not-used")
	assert(not bool(result.get("ok", false)), "External credentials must never unlock the owner-only player")
	assert(str(result.get("code", "")) == "NOVA_IDENTITY_NOT_INTEGRATED", "Owner access must fail closed pending NOVA native identity")
	service.clear_owner_session()
	assert(not service.is_owner_authenticated(), "Clearing the owner session must relock Anier")
	print("FUTBOL_NOVA_OWNER_ACCESS_TESTS: PASS")
	quit(0)
