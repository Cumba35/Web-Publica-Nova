extends RefCounted
class_name ClubCommercialService
## Fútbol Nova commercial unlocks and economic estimates.
## Values are fictional game estimates; never presented as Transfermarkt quotations.

const THIRD_KIT_LEVEL := 1

static func can_use_third_kit(club: Dictionary, season: int) -> bool:
	if int(club.get("division_level", 999)) != THIRD_KIT_LEVEL:
		return false
	var deal: Dictionary = club.get("commercial_contracts", {}).get("third_kit", {})
	if deal.is_empty():
		return false
	if str(deal.get("status", "")) != "active":
		return false
	if season < int(deal.get("start_season", 0)) or season > int(deal.get("end_season", -1)):
		return false
	return bool(deal.get("design_rights", false)) and bool(deal.get("sponsor_mark_rights", false)) and bool(deal.get("approved_original_design", false))

static func get_available_kits(club: Dictionary, season: int) -> Array[String]:
	var result: Array[String] = ["home", "away", "goalkeeper"]
	if can_use_third_kit(club, season):
		result.append("third")
	return result

static func estimate_player_market_value_eur(player: Dictionary, division_level: int = 1) -> int:
	var overall := clampi(int(player.get("estimated_overall", 40)), 1, 99)
	var potential := clampi(int(player.get("potential", overall)), overall, 99)
	var age := clampi(int(player.get("age", 26)), 15, 45)
	var position := str(player.get("position", "MC"))
	var age_multiplier := 0.42
	if age <= 20:
		age_multiplier = 1.22
	elif age <= 23:
		age_multiplier = 1.15
	elif age <= 27:
		age_multiplier = 1.0
	elif age <= 30:
		age_multiplier = 0.88
	elif age <= 33:
		age_multiplier = 0.68
	var position_multiplier := 1.0
	match position:
		"POR": position_multiplier = 0.92
		"DFC": position_multiplier = 0.96
		"LI", "LD": position_multiplier = 0.94
		"EI", "ED": position_multiplier = 1.08
		"DC": position_multiplier = 1.10
		"MCO": position_multiplier = 1.06
	var division_multiplier := 1.0
	match division_level:
		2: division_multiplier = 0.42
		3: division_multiplier = 0.18
	var potential_multiplier := 1.0 + float(potential - overall) * 0.012
	var base := 1200.0 * pow(float(overall), 2.75)
	var estimate := base * age_multiplier * position_multiplier * division_multiplier * potential_multiplier
	return clampi(int(round(estimate / 100.0) * 100.0), 500, 200000000)

static func estimate_transfer_fee_eur(market_value_eur: int, negotiation_factor: float = 1.0) -> int:
	var factor := clampf(negotiation_factor, 0.65, 1.65)
	return maxi(0, int(round(float(market_value_eur) * factor / 1000.0) * 1000.0))

static func estimate_annual_wage_eur(player_market_value_eur: int, division_level: int = 1) -> int:
	var wage_ratio := 0.045
	if division_level == 2:
		wage_ratio = 0.032
	elif division_level >= 3:
		wage_ratio = 0.020
	return maxi(600, int(round(float(player_market_value_eur) * wage_ratio / 52.0 / 10.0) * 10.0))

static func estimate_club_value_eur(finances: Dictionary, division_level: int = 1) -> int:
	var revenue := maxi(0, int(finances.get("annual_revenue_eur", 0)))
	var assets := maxi(0, int(finances.get("assets_eur", 0)))
	var debt := maxi(0, int(finances.get("debt_eur", 0)))
	var multiplier := 2.2 if division_level == 1 else (1.25 if division_level == 2 else 0.75)
	return maxi(0, int(round((assets + revenue * multiplier - debt) / 1000.0) * 1000.0))

static func estimate_ticket_price_eur(division_level: int, demand_index: float, match_importance: float) -> int:
	var base := 18.0 if division_level == 1 else (9.0 if division_level == 2 else 5.0)
	return clampi(int(round(base * clampf(demand_index, 0.5, 2.0) * clampf(match_importance, 0.75, 1.6))), 2, 150)

static func estimate_sponsorship_value_eur(annual_audience: int, division_level: int, performance_factor: float = 1.0) -> int:
	var audience := maxi(0, annual_audience)
	var tier_multiplier := 1.0 if division_level == 1 else (0.35 if division_level == 2 else 0.12)
	return maxi(0, int(round(float(audience) * 0.18 * tier_multiplier * clampf(performance_factor, 0.5, 1.8) / 1000.0) * 1000.0))

static func estimate_kit_retail_price_eur(competition_level: int, premium_contract: bool = false) -> int:
	var base := 65 if competition_level == 1 else (45 if competition_level == 2 else 30)
	return base + (15 if premium_contract else 0)

static func estimate_stadium_value_eur(capacity: int, condition_index: float = 1.0) -> int:
	var seats := maxi(0, capacity)
	return maxi(0, int(round(float(seats) * 1800.0 * clampf(condition_index, 0.25, 1.25) / 100000.0) * 100000.0))

static func estimate_facility_upgrade_cost_eur(level: int, facility_type: String = "training") -> int:
	var base := 250000.0
	match facility_type:
		"academy": base = 400000.0
		"medical": base = 350000.0
		"stadium": base = 800000.0
	var safe_level := clampi(level, 1, 10)
	return int(round(base * pow(float(safe_level), 1.65) / 10000.0) * 10000.0)
