extends Node

var _planet_system = -1
var _selection = []
var is_over_ui = false

func set_planet_system(planet_system: int) -> void:
	_planet_system = planet_system
	_update_visible()
	
func get_planet_system() -> int:
	return _planet_system

func set_selection(objects):
	_selection = objects
	
func get_selection():
	return _selection
	
func show_planet_systems():
	_planet_system = -1
	_update_visible()
	
func _update_visible():
	get_tree().call_group('Persist', 'set_visible', _planet_system)
	get_tree().call_group('StarSystem', 'set_visible', _planet_system == -1)
	(get_node('/root/GameScene/OrbitLines') as Node2D).update()

func set_over_ui(_is_over_ui: bool) -> void:
	is_over_ui = _is_over_ui
