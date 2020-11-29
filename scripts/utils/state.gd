extends Node

var _star_system = -1
var _selection = []
var is_over_ui = false

func set_star_system(star_system: int) -> void:
	_star_system = star_system
	_update_visible()
	
func get_star_system() -> int:
	return _star_system

func set_selection(objects):
	_selection = objects
	
func get_selection():
	return _selection
	
func show_star_systems():
	_star_system = -1
	_update_visible()
	
func _update_visible():
	get_tree().call_group('Persist', 'set_visible', _star_system)
	get_tree().call_group('StarSystem', 'set_visible', _star_system == -1)
	(get_node('/root/GameScene/OrbitLines') as Node2D).update()

func set_over_ui(_is_over_ui: bool) -> void:
	is_over_ui = _is_over_ui
