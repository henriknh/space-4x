extends Node

export var initial_state: NodePath

var state: State

func _ready():
	set_process(false)

	if not initial_state:
		breakpoint
	
	call_deferred("start")

func start():
	set_state(get_node(initial_state))
	set_process(true)

func _physics_process(delta):
	if state:
		var next_state = state.update(delta)
		state.ui_update()
		
		if next_state != null and next_state != false:
			set_state(get_node(initial_state) if next_state == true else next_state)

func set_state(next_state: State) -> void:
	if state:
		state.exit()
		state.ui_update()
	
	if next_state:
		state = next_state
	else:
		state = get_node(initial_state) as State
	
	state.enter()
