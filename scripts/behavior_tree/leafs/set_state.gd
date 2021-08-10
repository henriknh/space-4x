extends Task

class_name SetState

onready var states: Node = get_owner().get_node("States")
export(NodePath) var state_path

func _ready():
	if not states:
		breakpoint
	if not state_path:
		breakpoint

func run():
	if status != RUNNING:
		states.set_state(get_node(state_path))
		running()
	else:
		if state_path != get_path_to(states.state):
			success()
