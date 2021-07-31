extends Node

var packed_scene_loading: PackedScene = preload("res://scenes/loading/loading.tscn")
var packed_scene_main_menu: PackedScene = preload("res://scenes/main_menu/main_menu.tscn")
var packed_scene_game: PackedScene = preload("res://scenes/game/game.tscn")

signal scene_loaded
	
func goto_game() -> void:
	
	_show_loading_scene()
	
	MenuState.reset()
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.autostart = true
	timer.connect("timeout", self, "_load_game")
	add_child(timer)
	yield(timer, "timeout")
	timer.queue_free()
	
func _show_loading_scene():
	get_tree().change_scene_to(packed_scene_loading)
	yield(self, "scene_loaded")
	
func _load_game():
	var game_scene = packed_scene_game.instance()
	get_tree().get_root().add_child(game_scene)
	
	yield(GameState, "loading_done")
	
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game_scene

func goto_main_menu() -> void:
	MenuState.reset()
	
	get_tree().change_scene_to(packed_scene_main_menu)
