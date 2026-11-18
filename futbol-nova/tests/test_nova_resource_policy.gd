extends SceneTree

const PACKAGE_MANAGER = preload("res://scripts/data/content_package_manager.gd")
const OWNER_SERVICE = preload("res://scripts/data/nova_owner_access_service.gd")

func _initialize() -> void:
	var manager = PACKAGE_MANAGER.new()
	var valid_package := {
		"package_id": "test_package",
		"content_status": "published",
		"downloadable": true,
		"content_type": "league",
		"download_url": "https://raw.githubusercontent.com/Cumba35/Nova-Workspace/main/test.json",
		"download_size_bytes": 10,
		"checksum_sha256": "a".repeat(64),
		"version": "1.0.0"
	}
	assert(manager.validate_package(valid_package).get("ok", false), "A package from the canonical NOVA GitHub repository must pass URL policy")
	var external := valid_package.duplicate(true)
	external.download_url = "https://example.com/package.zip"
	assert(not manager.validate_package(external).get("ok", false), "Third-party package hosts must be rejected")
	var other_repo := valid_package.duplicate(true)
	other_repo.download_url = "https://raw.githubusercontent.com/another-owner/another-repo/main/test.json"
	assert(not manager.validate_package(other_repo).get("ok", false), "Other GitHub repositories must be rejected")
	var release := valid_package.duplicate(true)
	release.download_url = "https://github.com/Cumba35/Nova-Workspace/releases/download/v1/package.zip"
	assert(manager.validate_package(release).get("ok", false), "NOVA GitHub Releases must be allowed")
	var owner = OWNER_SERVICE.new()
	assert(not owner.is_owner_authenticated(), "No external authentication can unlock owner-only features")
	var login: Dictionary = await owner.sign_in_owner("owner@example.invalid", "unused")
	assert(not login.get("ok", false), "Owner authentication must fail closed until NOVA native identity is integrated")
	print("FUTBOL_NOVA_RESOURCE_POLICY_TESTS: PASS")
	quit(0)
