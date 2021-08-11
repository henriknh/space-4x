extends State

var cooldown = 0

func _ready():
	is_background_state = true

func _physics_process(delta):
	cooldown -= delta
	if cooldown <= 0:
		cooldown = 0
		set_process(false)

func enter():
	host.is_over_drive = true

func exit():
	host.is_over_drive = false
	cooldown = 10
	set_process(true)

func update(delta):
	ui_progress += (delta / process_speed)
	
	if ui_progress >= 1:
		return true
	
	return
	
func ui_disabled() -> bool:
	return cooldown > 0
