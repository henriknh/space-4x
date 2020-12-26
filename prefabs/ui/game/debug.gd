extends VBoxContainer

func _on_create_ship():
	var spawner_ships = load('res://scripts/spawners/spawner_ships.gd').new()
	spawner_ships.create(get_node('/root/GameScene'))
	pass # Replace with function body.

func _physics_process(delta):
	$LabelFps.text = 'FPS: %d' % Engine.get_frames_per_second()
