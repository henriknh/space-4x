extends Control

var settings = preload('res://prefabs/ui/settings/settings_menu.tscn')

func _ready():
	MenuState.push(self)

	for world_size_value in Enums.world_size.values():
		$VBox/CreateGame/VBoxContainer/OptionBtnWorldSize.add_item(Enums.world_size_label[world_size_value], world_size_value)
	$VBox/CreateGame/VBoxContainer/OptionBtnWorldSize.selected = 0
	_on_world_size_changed($VBox/CreateGame/VBoxContainer/OptionBtnWorldSize.selected)
	$VBox/CreateGame/VBoxContainer/SpinBoxSeed.value = 0
	_on_seed_changed($VBox/CreateGame/VBoxContainer/SpinBoxSeed.value)
	
	_update_view_state()
	
func _update_view_state():
	$VBox/CreateGame/ButtonCreate.disabled = StateManager.has_save()
	$VBox/StoredGame/ButtonLoad.disabled = not StateManager.has_save()
	$VBox/StoredGame/ButtonDeleteSave.disabled = not StateManager.has_save()

func _on_create():
	Scene.goto_game()

func _on_world_size_changed(idx: int):
	var selected_world_size = $VBox/CreateGame/VBoxContainer/OptionBtnWorldSize.get_item_id(idx)
	print(idx)
	print(selected_world_size)
	WorldGenerator.set_world_size(selected_world_size)

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
