extends Node

var loading_scene = null
var current_scene = null
onready var thread = Thread.new()

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
	var loading_scene_resource = ResourceLoader.load(Enums.scenes.loading)
	loading_scene = loading_scene_resource.instance()
	
func goto_scene(path: String, saveFile: String = '') -> void:
	call_deferred("_deferred_goto_scene", path, saveFile)

func _deferred_goto_scene(path: String, saveFile: String = '') -> void:
	# Load the new scene.
	print('_deferred_goto_scene')
	MenuState.reset()
	
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instance()
	
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	
	if path == Enums.scenes.game:
		print('thread')
		#thread.start(self, "_handle_loading_entities", saveFile)
		_handle_loading_entities(saveFile)

func _handle_loading_entities(saveFile: String):
	print('_handle_loading_entities')
	GameState.set_loading(true)
	
	if saveFile.length() == 0:
		#thread.start(WorldGenerator, "generate_world")
		WorldGenerator.generate_world()
	else:
		#thread.start(StateManager, "load_game")
		StateManager.load_game()
	print('done loading')
	
	call_deferred("_handle_loading_entities_done")

func _handle_loading_entities_done():
	print('_handle_loading_entities_done')
	#var result = thread.wait_to_finish()
	#var current_scene = call_deferred("_deferred_goto_scene", Enums.scenes.game)
	#print(current_scene)
	print('init scene')
	get_tree().get_current_scene().init()
	GameState.set_loading(false)
	#current_scene.init()
