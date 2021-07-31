extends Node

export var initial_state: NodePath

var state: State

func _ready():
	set_process(false)

	if not initial_state:
		breakpoint
	
	call_deferred("start")

func start():
	set_state(initial_state)
	set_process(true)

func _physics_process(delta):
	if state:
		var next_state = state.update(delta)
		state.ui_update()
		
		if next_state:
			set_state(next_state)

func set_state(next_state_path) -> void:
	if state:
		state.exit()
		state.ui_update()
	
	var next_state = null
	if next_state_path and next_state_path is NodePath:
		if state:
			next_state = state.get_node(next_state_path) as State
		if not next_state:
			next_state = get_node(next_state_path) as State
	
	if next_state:
		state = next_state
	else:
		state = get_node(initial_state) as State
	
	state.enter()
