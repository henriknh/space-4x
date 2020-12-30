extends Node

# Temporary
var _selection = []

# Persistent
var state = {
	"curr_planet_system": -1,
	"camera_states": {}
}
signal state_changed
signal selection_changed

func set_planet_system(planet_system: int) -> void:
	var camera = get_node('/root/GameScene/Camera') as Camera2D
	if camera:
		camera.set_camera_state()
	state['curr_planet_system'] = planet_system
	emit_signal("state_changed")
	_update_visible()
	
func get_planet_system() -> int:
	return state['curr_planet_system']

func set_selection(objects = null):
	if objects == null:
		objects = []
	elif typeof(objects) == TYPE_OBJECT:
		objects = [objects]
		
	var old_selection = _selection
	_selection = objects
	
	for object in _selection + old_selection:
		object.update()
	
	emit_signal("selection_changed")
	
func get_selection():
	return _selection

func _update_visible():
	get_tree().call_group('Persist', 'set_visible', state['curr_planet_system'])
	get_tree().call_group('StarSystem', 'set_visible', state['curr_planet_system'] == -1)
	(get_node('/root/GameScene') as game).redraw()
	
func set_camera_setting(camera_state: Dictionary) -> void:
	state["camera_states"][state['curr_planet_system'] as String] = camera_state

func get_camera_state() -> Dictionary:
	if state["camera_states"].has(get_planet_system() as String):
		return state["camera_states"][get_planet_system() as String]
	else: 
		return {}

func set_state(state: Dictionary) -> void:
	self.state = state
	
func get_state() -> Dictionary:
	var camera = get_node('/root/GameScene/Camera') as Camera2D
	if camera:
		camera.set_camera_state()
	return state

