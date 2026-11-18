extends RefCounted
class_name NovaClubAcademyService

const RULES_PATH := "res://data/youth_academy_rules.json"

static func load_rules(path: String = RULES_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

static func initial_state(division_level: int, rules: Dictionary = {}) -> Dictionary:
	var active_level := int((rules if not rules.is_empty() else load_rules()).get("automatic_academy_through_division", 1))
	if division_level <= active_level:
		return {"status": "active", "operational": true, "youth_generation_enabled": true, "reason": "Academia inicial de Primera División"}
	return {"status": "none", "operational": false, "youth_generation_enabled": false, "reason": "El club debe solicitar y financiar su academia"}

static func can_create_academy(finances: Dictionary, compliance: Dictionary, rules: Dictionary = {}) -> Dictionary:
	var policy := rules if not rules.is_empty() else load_rules()
	var required_months := int(policy.get("minimum_operating_months_covered", 6))
	var reserve_months := float(policy.get("minimum_reserve_months", 2.0))
	var monthly_cost := maxf(0.0, float(finances.get("monthly_operating_cost", 0.0)))
	var startup_cost := maxf(0.0, float(finances.get("startup_cost", 0.0)))
	var cash := float(finances.get("available_cash", 0.0))
	var reserve := maxf(float(finances.get("required_reserve", 0.0)), monthly_cost * reserve_months)
	var runway := int(floor(maxf(0.0, cash - startup_cost - reserve) / monthly_cost)) if monthly_cost > 0.0 else required_months
	var checks := {
		"association_license": bool(compliance.get("association_license", false)),
		"facilities": bool(compliance.get("facilities_or_contract", false)),
		"qualified_staff": bool(compliance.get("qualified_staff", false)),
		"safeguarding": bool(compliance.get("safeguarding_approved", false)),
		"youth_plan": bool(compliance.get("youth_development_plan", false)),
		"startup_funds": cash >= startup_cost + reserve,
		"operating_runway": runway >= required_months
	}
	var failed: Array[String] = []
	for key in checks:
		if not checks[key]:
			failed.append(str(key))
	return {"eligible": failed.is_empty(), "checks": checks, "failed_requirements": failed, "available_runway_months": runway, "required_runway_months": required_months, "required_reserve": reserve}

static func activate_academy(division_level: int, finances: Dictionary, compliance: Dictionary, rules: Dictionary = {}) -> Dictionary:
	var initial := initial_state(division_level, rules)
	if bool(initial.operational):
		return {"ok": true, "academy": initial, "audit": {"eligible": true, "failed_requirements": []}}
	var audit := can_create_academy(finances, compliance, rules)
	if not bool(audit.eligible):
		return {"ok": false, "academy": initial, "audit": audit}
	var finance_after := finances.duplicate(true)
	finance_after["available_cash"] = float(finances.get("available_cash", 0.0)) - float(finances.get("startup_cost", 0.0))
	var academy := {
		"status": "active",
		"operational": true,
		"youth_generation_enabled": true,
		"created_by_club": true,
		"monthly_operating_cost": float(finances.get("monthly_operating_cost", 0.0)),
		"required_reserve": float(audit.get("required_reserve", 0.0)),
		"funded_runway_months": int(audit.get("available_runway_months", 0))
	}
	var ledger_entry := {
		"type": "academy_activation",
		"amount": float(finances.get("startup_cost", 0.0)),
		"currency": str(finances.get("currency", "")),
		"status": "committed"
	}
	return {"ok": true, "academy": academy, "audit": audit, "finance_after": finance_after, "ledger_entry": ledger_entry}
