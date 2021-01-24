extends Node

var loading_scene = null
var current_scene = null
onready var thread = Thread.new()

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
func goto_scene(path: String, saveFile: String = '') -> void:
	call_deferred("_deferred_goto_scene", path, saveFile)

func _deferred_goto_scene(path: String, saveFile: String = '') -> void:
	# Load the new scene.
	MenuState.reset()
	
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instance()
	
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	
	if path == Enums.scenes.game:
		thread.start(self, "_handle_loading_entities", saveFile)

func _handle_loading_entities(saveFile: String):
	GameState.loading = true
	
	if saveFile.length() == 0:
		WorldGenerator.generate_world()
	else:
		StateManager.load_game()
	
	call_deferred("_handle_loading_entities_done")

func _handle_loading_entities_done():
	var result = thread.wait_to_finish()
	get_tree().get_current_scene().init()
	GameState.loading = false
