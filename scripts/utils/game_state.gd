extends Node

var state_file_path = "user://state.json"

# Temporary
var _selection = []

# Persistent
var state = {
	"curr_planet_system": -1,
	"camera_states": {}
}
signal state_changed

func _ready():
	if not _load():
		_save()

func _after_change():
	_save()
	emit_signal("state_changed")
	
func set_planet_system(planet_system: int) -> void:
	state['curr_planet_system'] = planet_system
	_after_change()
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
	
func get_selection():
	return _selection
	
func show_planet_systems():
	state['curr_planet_system'] = -1
	_after_change()
	_update_visible()
	
func _update_visible():
	get_tree().call_group('Persist', 'set_visible', state['curr_planet_system'])
	get_tree().call_group('StarSystem', 'set_visible', state['curr_planet_system'] == -1)
	(get_node('/root/GameScene') as game).redraw()
	
func set_camera_setting(camera_state: Dictionary) -> void:
	state["camera_states"][get_planet_system() as String] = camera_state
	_save()

func get_camera_state() -> Dictionary:
	if state["camera_states"].has(get_planet_system() as String):
		return state["camera_states"][get_planet_system() as String]
	else: 
		return {}

func _load() -> bool:
	var load_state = File.new()
	if not load_state.file_exists(state_file_path):
		return false# Error! We don't have a save to load.

	load_state.open(state_file_path, File.READ)
	state = parse_json(load_state.get_line())
	
	load_state.close()
	
	return true
	
func _save():
	var save_state = File.new()
	save_state.open(state_file_path, File.WRITE)
	save_state.store_line(to_json(state))
	save_state.close()

