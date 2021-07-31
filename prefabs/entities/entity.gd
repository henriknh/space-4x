extends Spatial

class_name Entity

# Temporary
var _corporation: Corporation

signal entity_changed

export var health: int = -1
export var icon: Texture

# General
var id: int = -1
var variant: int = -1
var corporation_id: int = 0 setget _set_corporation
var state: int = Enums.ship_states.idle setget set_state
var target: Entity

func _ready():
	set_process(false)
	
	id = WorldGenerator.unique_id
	variant = Random.randi()
	
	if not icon:
		breakpoint
		
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	yield(timer, "timeout")
	timer.queue_free()
	GameState.loading -= 1

func _set_corporation(_corporation_id):
	corporation_id = _corporation_id
	_corporation = Corporations.get_corporation(corporation_id)
	emit_signal("entity_changed")
	
	for child in get_children():
		if child.get('corporation_id') != null:
			child.corporation_id = _corporation_id
	
func get_corporation() -> Corporation:
	if corporation_id > 0 and _corporation == null:
		_corporation = Corporations.get_corporation(corporation_id)
	return _corporation

func set_state(_state):
	state = _state
	set_process(!!state)

func save():
	var data = {
		"filename": get_filename(),
		"script": get_script().get_path(),
		#"pos_x" : position.x,
		#"pos_y" : position.y,
		"rotation": rotation,
		
		# General
		"id": id,
		"variant": variant,
		"corporation_id": corporation_id
	}
	
	return data
