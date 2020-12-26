extends Node

var loading_scene = null
var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
	var loading_scene_resource = ResourceLoader.load(Enums.scenes.loading)
	loading_scene = loading_scene_resource.instance()
	
func goto_scene(path: String, newGame: bool = false, saveFile: String = '') -> void:
	call_deferred("_deferred_goto_loading_scene", path, newGame, saveFile)

func _deferred_goto_loading_scene(path: String, newGame: bool = false, saveFile: String = '') -> void:
	get_tree().get_root().add_child(loading_scene)
	
	# It is now safe to remove the current scene
	current_scene.queue_free()
	
	call_deferred("_deferred_goto_scene", path, newGame, saveFile)

func _deferred_goto_scene(path: String, newGame: bool = false, saveFile: String = '') -> void:
	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	
	if current_scene.name == 'GameScene':
		if newGame:
			WorldGenerator.generate_world()
		elif not newGame and saveFile.length() > 0:
			if StateManager.load_game():
				State.set_planet_system(0)
		current_scene.init()
