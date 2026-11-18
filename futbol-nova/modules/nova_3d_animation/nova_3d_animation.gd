extends Node
class_name Nova3DAnimation

## Shared, reusable animation-state contract for every 3D footballer.
## Clip playback binds to an AnimationTree when a rigged model is installed.
signal state_changed(state_name: String)

const STATES := ["idle","walk","run","sprint","turn_left","turn_right","dribble","pass_short","pass_long","shot","tackle","intercept","jump","header","fall","get_up","celebration"]
var active_state := "idle"
var animation_tree: AnimationTree

func bind_tree(tree: AnimationTree) -> void:
	animation_tree = tree

func play_state(state_name: String) -> void:
	if not STATES.has(state_name):
		push_warning("Unknown NOVA animation state: " + state_name)
		return
	if active_state == state_name:
		return
	active_state = state_name
	if animation_tree and animation_tree.active:
		animation_tree.set("parameters/conditions/" + state_name, true)
	state_changed.emit(state_name)

func supported_states() -> PackedStringArray:
	return PackedStringArray(STATES)
