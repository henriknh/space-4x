extends Spatial

class_name Game

onready var node_game_ui: Control = $CanvasLayer/GameUI
var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')

func _ready():
	Scene.emit_signal("scene_loaded")
	
	visible = false
	node_game_ui.visible = false
	
	if StateManager.save_file_path.length() == 0:
		WorldGenerator.generate_world()
	else:
		StateManager.load_game()
	
	yield(GameState, "game_ready")
	
	visible = true
	node_game_ui.visible = true
	node_game_ui.init()
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		if GameState.selected_tile:
			GameState.selected_tile = null
		elif MenuState.menus_size() == 1:
			$CanvasLayer.add_child(game_menu_prefab.instance())
		else:
			MenuState.pop()
