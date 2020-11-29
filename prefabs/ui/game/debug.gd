extends VBoxContainer


func _on_save():
	StateManager.save_game()

func _on_menu():
	Scene.goto_scene(Enums.scenes.main_menu)

func _on_exit():
	get_tree().quit()

func _on_create_ship():
	var spawner_ships = load('res://scripts/spawners/spawner_ships.gd').new()
	spawner_ships.create(get_node('/root'))
	pass # Replace with function body.
