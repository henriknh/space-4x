extends CanvasLayer

func _ready():
	$HBoxContainer/Panel.connect("mouse_entered", State, "set_over_ui", [true])
	$HBoxContainer/Panel.connect("mouse_exited", State, "set_over_ui", [false])
	
func _on_back_to_galaxy():
	State.show_star_systems()

func _on_save():
	StateManager.save_game()

func _on_back_to_menu():
	Scene.goto_scene(Enums.scenes.menu)

func _on_exit():
	get_tree().quit()

func _on_create_ship():
	var spawner_ships = load('res://scripts/spawners/spawner_ships.gd').new()
	spawner_ships.create(get_node('/root'))
	pass # Replace with function body.
