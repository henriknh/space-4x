extends Control

var settings = preload('res://prefabs/ui/settings/settings_menu.tscn')

onready var node_world_size: OptionButton = $VBox/CreateGame/VBoxContainer/OptionBtnWorldSize
onready var node_seed: SpinBox = $VBox/CreateGame/VBoxContainer/SpinBoxSeed
onready var node_create: Button = $VBox/CreateGame/ButtonCreate
onready var node_load: Button = $VBox/StoredGame/ButtonLoad
onready var node_delete: Button = $VBox/StoredGame/ButtonDeleteSave

func _ready():
	MenuState.push(self)
	
	for world_size_value in Enums.world_size.values():
		node_world_size.add_item(Enums.world_size_label[world_size_value], world_size_value)

	node_world_size.selected = WorldGenerator.world_size
	node_seed.value = Random.get_seed()
	_on_world_size_changed(node_world_size.selected)
	_on_seed_changed(int(node_seed.value))
	
	_update_view_state()
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.005
	timer.connect("timeout", self, "_on_create")
	add_child(timer)
	timer.start()
	
func _update_view_state():
	node_create.disabled = StateManager.has_save()
	node_load.disabled = not StateManager.has_save()
	node_delete.disabled = not StateManager.has_save()

func _on_create():
	Scene.goto_game()

func _on_world_size_changed(idx: int):
	WorldGenerator.world_size = node_world_size.get_item_id(idx)

func _on_seed_changed(seed_value: int):
	Random.set_seed(seed_value)

func _on_load():
	Scene.goto_game(StateManager.save_file_path)

func _on_delete_save():
	if StateManager.delete_game_file():
		_update_view_state()

func _on_settings():
	get_parent().add_child(settings.instance())

func _on_exit():
	get_tree().quit()
