class_name GoalkeeperReactionModel
extends RefCounted

## Lightweight deterministic decision layer; animation and collision remain
## the responsibility of the match/keeper controller.
var difficulty := "normal"
var elapsed := 0.0
var reaction_committed := false
var predicted_target := Vector3.ZERO
var reaction_profile: Dictionary = {}

func configure(level: String) -> void:
	difficulty = level.to_lower()
	reaction_profile = SetPieceDefensiveSetup.goalkeeper_profile(difficulty)
	reset()

func reset() -> void:
	elapsed = 0.0
	reaction_committed = false
	predicted_target = Vector3.ZERO

func observe(delta: float, predicted_ball_intercept: Vector3, current_keeper_position: Vector3) -> Dictionary:
	if reaction_profile.is_empty():
		configure(difficulty)
	if reaction_committed:
		return {"reacted": true, "target": predicted_target, "profile": reaction_profile.duplicate(true)}
	elapsed += maxf(0.0, delta)
	if elapsed < float(reaction_profile.get("reaction_delay", 0.23)):
		return {"reacted": false, "target": current_keeper_position, "profile": reaction_profile.duplicate(true)}
	reaction_committed = true
	predicted_target = predicted_ball_intercept
	return {"reacted": true, "target": predicted_target, "profile": reaction_profile.duplicate(true)}
