extends Node

var curr_planet_system = -1
var _selection = []
var is_over_ui = false

func set_planet_system(planet_system: int) -> void:
	curr_planet_system = planet_system
	_update_visible()
	
func get_planet_system() -> int:
	return curr_planet_system

func set_selection(objects = null):
	if objects == null:
		objects = []
	elif typeof(objects) == TYPE_OBJECT:
		objects = [objects]
		
	var old_selection = _selection
	_selection = objects
	
	for object in _selection + old_selection:
		object.update()
	
func get_selection():
	return _selection
	
func show_planet_systems():
	curr_planet_system = -1
	_update_visible()
	
func _update_visible():
	get_tree().call_group('Persist', 'set_visible', curr_planet_system)
	get_tree().call_group('StarSystem', 'set_visible', curr_planet_system == -1)
	(get_node('/root/GameScene') as game).redraw()
	

func set_over_ui(_is_over_ui: bool) -> void:
	is_over_ui = _is_over_ui
