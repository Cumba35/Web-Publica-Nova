class_name ProceduralIKSolver
extends RefCounted

## Analytic two-bone IK utility for limbs. It returns a joint position; callers
## apply the result to their own skeleton/mesh and animation blend.
static func solve_two_bone(root: Vector3, target: Vector3, pole: Vector3, upper_length: float, lower_length: float) -> Vector3:
	var first := maxf(0.001, upper_length)
	var second := maxf(0.001, lower_length)
	var delta := target - root
	var distance := clampf(delta.length(), 0.001, first + second - 0.001)
	var axis := delta.normalized() if delta.length_squared() > 0.000001 else Vector3.DOWN
	var bend := pole - axis * pole.dot(axis)
	if bend.length_squared() < 0.0001:
		var fallback := Vector3.RIGHT if absf(axis.dot(Vector3.RIGHT)) < 0.9 else Vector3.UP
		bend = fallback - axis * fallback.dot(axis)
	bend = bend.normalized()
	var along := (first * first - second * second + distance * distance) / (2.0 * distance)
	var height := sqrt(maxf(0.0, first * first - along * along))
	return root + axis * along + bend * height
