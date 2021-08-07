extends Control

var settings = preload('res://prefabs/ui/settings_menu/settings_menu.tscn')

onready var node_start: Button = $VBoxContainer/Start
onready var node_world_size: OptionButton = $VBoxContainer/WorldSize
onready var node_seed: SpinBox = $VBoxContainer/Seed
onready var node_load: Button = $VBoxContainer/Load
onready var node_delete: Button = $VBoxContainer/DeleteSave

func _ready():
	for world_size_value in Enums.world_size.values():
		node_world_size.add_item(Enums.world_size_label[world_size_value], world_size_value)

	node_world_size.selected = WorldGenerator.world_size
	node_seed.value = Random.get_seed()
	_on_world_size_selected(node_world_size.selected)
	_on_seed_changed(int(node_seed.value))
	
	_update_view_state()
	Scene.emit_signal("scene_loaded")
	MenuState.push(self)
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.05
	timer.autostart = true
	timer.connect("timeout", self, "_on_start")
	add_child(timer)
	
func _update_view_state():
	node_start.disabled = StateManager.has_save()
	node_load.disabled = not StateManager.has_save()
	node_delete.disabled = not StateManager.has_save()

func _on_start():
	Scene.call_deferred("goto_game")

func _on_world_size_selected(idx: int):
	WorldGenerator.world_size = node_world_size.get_item_id(idx)

func _on_seed_changed(seed_value: int):
	Random.set_seed(seed_value)

func _on_load():
	StateManager.save_file_path = "user://savegame.save"
	Scene.goto_game()

func _on_delete_save():
	if StateManager.delete_game_file():
		_update_view_state()

func _on_settings():
	get_parent().add_child(settings.instance())

func _on_exit():
	get_tree().quit()
