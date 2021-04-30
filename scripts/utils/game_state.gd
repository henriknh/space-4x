extends Node

# Temporary
var _selection: Entity
var loading: bool = false setget set_loading, is_loading
var loading_progress: float = 0 setget set_loading_progress, get_loading_progress
var loading_label: String = '' setget set_loading_label, get_loading_label

# Persistent
var curr_planet_system: PlanetSystem
signal state_changed
signal selection_changed
signal update_ui
signal loading_changed

func set_planet_system(planet_system: PlanetSystem) -> void:
	curr_planet_system = planet_system
	set_selection(null)
	emit_signal("state_changed")

func set_selection(new_selection: Entity = null):
	var old_selection = _selection
	_selection = new_selection
	
	if _selection:
		_selection.update()
	if old_selection:
		old_selection.update()
	
	emit_signal("selection_changed")
	
func get_selection() -> Entity:
	return _selection

func set_loaded_game_state(state: Dictionary) -> void:
	self.state = state
	emit_signal("state_changed")
	
func set_loading(is_loading: bool) -> void:
	loading = is_loading
	loading_progress = 0
	loading_label = ''
	emit_signal("loading_changed")
	if loading == false:
		get_node('/root/GameScene/CanvasLayer/GameUI').init()

func is_loading() -> bool:
	return loading

func set_loading_progress(_loading_progress: float) -> void:
	loading_progress = _loading_progress
	emit_signal("loading_changed")

func get_loading_progress() -> float:
	return loading_progress

func set_loading_label(_loading_label: String) -> void:
	loading_label = _loading_label
	emit_signal("state_changed")
	emit_signal("update_ui")

func get_loading_label() -> String:
	return loading_label
