extends Control

func _ready():
	_update_view_state()
	
func _update_view_state():
	$VBoxContainer/ButtonCreate.disabled = StateManager.has_save()
	$VBoxContainer/ButtonLoad.disabled = not StateManager.has_save()
	$VBoxContainer/ButtonDeleteSave.disabled = not StateManager.has_save()
	_on_world_size_changed($VBoxContainer/SliderWorldSize.value)
	_on_seed_changed($VBoxContainer/SpinBoxSeed.value)

func _on_create():
	Scene.goto_scene(Enums.scenes.game, true)

func _on_world_size_changed(value: int):
	$VBoxContainer/LabelWorldSize.text = "World size: %s" % Enums.world_sizes[value]
	WorldGenerator.set_world_size(value)

func _on_seed_changed(seed_value: int):
	WorldGenerator.set_seed(seed_value)

func _on_load():
	Scene.goto_scene(Enums.scenes.game, false, StateManager.save_file_path)

func _on_delete_save():
	if StateManager.delete_game_file():
		_update_view_state()

func _on_exit():
	get_tree().quit()
