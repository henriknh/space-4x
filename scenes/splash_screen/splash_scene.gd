extends Control

func _ready():
	print('spash screen')
	Scene.emit_signal("scene_loaded")
	
	var timer = Timer.new()
	timer.wait_time = 1
	timer.one_shot = true
	timer.autostart = true
	#timer.connect("timeout", Scene, "call_deferred", ["goto_game"])
	#timer.connect("timeout", Scene, "goto_game")
	timer.connect("timeout", Scene, "goto_main_menu")
	add_child(timer)
