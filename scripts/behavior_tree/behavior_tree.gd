extends Sequence

class_name BehaviorTree

# Called when the node enters the scene tree for the first time.
func _ready():
	control = null
	get_parent().connect("entity_changed", self, "check_start")
	check_start()

func check_start():
	if get_parent().corporation_id > Consts.PLAYER_CORPORATION:
		running()
		set_process(true)
	else:
		set_process(false)
		reset()

func _physics_process(_delta):
	run()
	
func child_fail():
	current_child += 1
	if current_child >= get_child_count():
		current_child = 0
		fail()
	
func child_success():
	current_child += 1
	if current_child >= get_child_count():
		current_child = 0
		success()
