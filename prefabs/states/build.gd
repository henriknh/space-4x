extends State

export(PackedScene) var packed_scene
export(Texture) var texture
export var speed = 50

var ui_texture

func _ready():
	if not packed_scene:
		breakpoint
	if not texture:
		breakpoint

func update(delta):
	ui_progress += delta * speed
	
	if ui_progress >= 100:
		var instance = packed_scene.instance()
		host.add_child(instance)
		return true
	
	return

func ui_data():
	return {
		"texture": texture
	}
