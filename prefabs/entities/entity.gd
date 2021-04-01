extends KinematicBody2D

class_name Entity

const ACTIVE_TIME_PERIOD: float = 0.0166
const INACTIVE_TIME_PERIOD: float = 0.05

# Temporary
var delta: float = 0
var queued_to_free: bool = false
var _corporation: Corporation

signal entity_changed

# General
var id: int = -1
var variant: int = -1
var entity_type: int = -1
var planet_system: int = -1
var corporation_id: int = 0 setget _set_corporation

# Make into "label" module
var label: String = ''

# Make into "state" module
var state: int = 0
var process_target: int
var process_time: float = 0
var _process_time_total: float = 0

func _physics_process(_delta):
	if GameState.loading:
		return
		
	if queued_to_free:
		return
	
	delta += _delta
	
	if visible and delta < ACTIVE_TIME_PERIOD or not visible and delta < INACTIVE_TIME_PERIOD:
		return
	else:
		if is_dead():
			kill()
		else:
			var corporation = get_corporation()
			if corporation and corporation.is_computer:
				AI.process_entity(self, delta)
			process(delta)
			
		delta = 0

func create():
	id = WorldGenerator.unique_id
	variant = Random.randi()

func _ready():
	set_visible(planet_system == GameState.get_planet_system())

func process(delta: float):
	pass

func kill():
	queued_to_free = true
	queue_free()

func is_dead() -> bool:
	return false
	
func set_visible(in_data):
	if typeof(in_data) == TYPE_BOOL:
		visible = in_data
	else:
		visible = planet_system == in_data

func set_entity_process(state: int, target: int, total_time: int = 0) -> void:
	self.state = state
	process_target = target
	process_time = 0
	_process_time_total = total_time
	
func get_process_progress() -> float:
	if _process_time_total <= 0:
		return 0.0
	return process_time / _process_time_total

func _set_corporation(_corporation_id):
	corporation_id = _corporation_id
	_corporation = Corporations.get_corporation(corporation_id)
	if entity_type == Enums.entity_types.planet:
		Corporations.emit_signal("corporations_changed")
	
func get_corporation() -> Corporation:
	if corporation_id > 0 and _corporation == null:
		_corporation = Corporations.get_corporation(corporation_id)
	return _corporation
	
func save():
	var data = {
		"filename": get_filename(),
		"script": get_script().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
		
		# General
		"id": id,
		"variant": variant,
		"entity_type": entity_type,
		"planet_system": planet_system,
		"corporation_id": corporation_id,
		
		"label": label,
		
		"state": state,
		"process_target": process_target,
		"process_time": process_time,
		"_process_time_total": _process_time_total,
	}
	
	return data
