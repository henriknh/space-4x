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
	Scene.goto_scene(Enums.scenes.game)
	WorldGenerator.generate_world()

func _on_world_size_changed(value: int):
	$VBoxContainer/LabelWorldSize.text = "World size: %s" % Enums.world_sizes[value]
	WorldGenerator.set_world_size(value)

func _on_seed_changed(seed_value: int):
	WorldGenerator.set_seed(seed_value)

func _on_load():
	Scene.goto_scene(Enums.scenes.game)
	if StateManager.load_game(get_node("/root/GameScene")):
		State.set_planet_system(0)

func _on_delete_save():
	if StateManager.delete_game_file():
		_update_view_state()

func _on_exit():
	get_tree().quit()
