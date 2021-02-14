extends Node

var loading_scene = null
var current_scene = null
onready var thread = Thread.new()

var main_menu_scene = preload('res://scenes/main_menu.tscn')
var game_scene = preload('res://scenes/game.tscn')

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
func goto_game(saveFile: String = '') -> void:
	MenuState.reset()
	
	_load_scene(game_scene)
	
	#thread.start(self, "_handle_loading_entities", saveFile)
	_handle_loading_entities(saveFile)
	
func goto_main_menu() -> void:
	MenuState.reset()
	
	_load_scene(main_menu_scene)
	#GameState.loading = false
	
func _load_scene(scene):
	current_scene.queue_free()
	current_scene = scene.instance()
	
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	
func _handle_loading_entities(saveFile: String):
	
	if saveFile.length() == 0:
		WorldGenerator.generate_world()
	else:
		StateManager.load_game()
	
	call_deferred("_handle_loading_entities_done")

func _handle_loading_entities_done():
	#thread.wait_to_finish()
	get_tree().get_current_scene().init()
	GameState.loading = false

