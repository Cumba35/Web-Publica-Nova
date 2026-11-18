extends RefCounted
class_name NovaPlayerProfile

const POSITION_CODES := ["POR", "DFC", "LI", "LD", "CAI", "CAD", "MCD", "MC", "INTERIOR_IZQUIERDO", "INTERIOR_DERECHO", "MCO", "MI", "MD", "EI", "ED", "SD", "DC"]
const FEET := ["left", "right", "both"]

static func validate(player: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for field in ["id", "display_name", "nationality_id", "primary_position", "attributes"]:
		if not player.has(field):
			errors.append("Falta el campo obligatorio: " + field)
	if not errors.is_empty():
		return errors
	if str(player.id).strip_edges().is_empty() or str(player.display_name).strip_edges().is_empty():
		errors.append("id y display_name no pueden estar vacíos")
	if not POSITION_CODES.has(str(player.primary_position)):
		errors.append("primary_position no pertenece al catálogo de posiciones")
	if player.has("preferred_foot") and not FEET.has(str(player.preferred_foot)):
		errors.append("preferred_foot debe ser left, right o both")
	if player.has("height_cm") and (int(player.height_cm) < 130 or int(player.height_cm) > 220):
		errors.append("height_cm fuera del rango de validación 130–220")
	if player.has("weight_kg") and (int(player.weight_kg) < 35 or int(player.weight_kg) > 150):
		errors.append("weight_kg fuera del rango de validación 35–150")
	if player.has("secondary_positions"):
		if not player.secondary_positions is Array:
			errors.append("secondary_positions debe ser un array")
		else:
			var seen := {}
			for position in player.secondary_positions:
				var code := str(position)
				if not POSITION_CODES.has(code):
					errors.append("Posición secundaria no reconocida: " + code)
				if seen.has(code):
					errors.append("Posición secundaria duplicada: " + code)
				seen[code] = true
	if not player.attributes is Dictionary:
		errors.append("attributes debe ser un objeto")
	else:
		_validate_attribute_tree(player.attributes, "attributes", errors)
	return errors

static func _validate_attribute_tree(value: Dictionary, prefix: String, errors: PackedStringArray) -> void:
	for key in value.keys():
		var item = value[key]
		var path := prefix + "." + str(key)
		if item is Dictionary:
			_validate_attribute_tree(item, path, errors)
		elif item is int or item is float:
			if float(item) < 1.0 or float(item) > 99.0:
				errors.append(path + " debe estar entre 1 y 99")
		else:
			errors.append(path + " debe ser numérico o un objeto")

static func is_valid(player: Dictionary) -> bool:
	return validate(player).is_empty()
