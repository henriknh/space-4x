extends Control

var settings = preload('res://prefabs/ui/settings/settings_menu.tscn')

func _ready():
	MenuState.push(self)
	$VBox/CreateGame/VBoxContainer/SliderWorldSize.max_value = Enums.world_size.keys().size() - 1
	_update_view_state()
	
func _update_view_state():
	$VBox/CreateGame/ButtonCreate.disabled = StateManager.has_save()
	$VBox/StoredGame/ButtonLoad.disabled = not StateManager.has_save()
	$VBox/StoredGame/ButtonDeleteSave.disabled = not StateManager.has_save()
	_on_world_size_changed($VBox/CreateGame/VBoxContainer/SliderWorldSize.value)
	_on_seed_changed($VBox/CreateGame/VBoxContainer/SpinBoxSeed.value)

func _on_create():
	Scene.goto_game()

func _on_world_size_changed(value: int):
	$VBox/CreateGame/VBoxContainer/LabelWorldSize.text = "World size: %s" % Enums.world_size_label[value]
	WorldGenerator.set_world_size(value)

func _on_seed_changed(seed_value: int):
	WorldGenerator.set_seed(seed_value)

func _on_load():
	Scene.goto_game(StateManager.save_file_path)

func _on_delete_save():
	if StateManager.delete_game_file():
		_update_view_state()

func _on_settings():
	get_parent().add_child(settings.instance())

func _on_exit():
	get_tree().quit()
