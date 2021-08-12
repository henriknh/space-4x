extends State

export(PackedScene) var packed_scene

func _ready():
	if not packed_scene:
		breakpoint

func update(delta):
	ui_progress += (delta / process_speed)
	
	if ui_progress >= 1:
		var instance = packed_scene.instance()
		host.add_child(instance)
		return true
	
	return
