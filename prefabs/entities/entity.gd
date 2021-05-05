extends Spatial

class_name Entity

# Temporary
var _corporation: Corporation

signal entity_changed

# General
var id: int = -1
var variant: int = -1
var corporation_id: int = 0 setget _set_corporation

func create():
	id = WorldGenerator.unique_id
	variant = Random.randi()
	
func _ready():
	set_process(false)

func _set_corporation(_corporation_id):
	corporation_id = _corporation_id
	_corporation = Corporations.get_corporation(corporation_id)
	
func get_corporation() -> Corporation:
	if corporation_id > 0 and _corporation == null:
		_corporation = Corporations.get_corporation(corporation_id)
	return _corporation
	
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
