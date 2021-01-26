extends KinematicBody2D

class_name Entity

const ACTIVE_TIME_PERIOD: float = 0.0166
const INACTIVE_TIME_PERIOD: float = 0.05

# Temporary
var delta: float = 0
var queued_to_free: bool = false
signal entity_changed

# General
var id: int = -1
var variant: int = -1
var parent: Entity
var entity_type: int = -1
var label: String = ''
var hitpoints: int = 1
var hitpoints_max: int = -1
var indestructible: bool = false
var faction: int = -1
var planet_system: int = -1
var rotation_speed: float = 0
var state: int = 0
var process_target: int
var process_progress: float

# Resources
var metal: float = 0
var metal_max: int = -1
var power: float = 0
var power_max: int = -1
var food: float = 0
var food_max: int = -1
var water: float = 0
var water_max: int = -1

# Object specific variables
var object_type: int = -1

# Planet specific variables
var planet_type: int = -1
var planet_size: float = 1.0
var planet_convex_hull = []

# Ship specific variables
var ship_type: int = -1
var ship_speed: float = 0.0
var ship_speed_max: int = 500
var ship_cargo_size: int = 20

func _physics_process(_delta):
	
	if queued_to_free:
		return
	
	if entity_type != Enums.entity_types.planet:
		if not parent:
			return
	
	delta += _delta
	
	if visible and delta < ACTIVE_TIME_PERIOD or not visible and delta < INACTIVE_TIME_PERIOD:
		return
	else:
		if hitpoints <= 0:
			kill()
		else:
			process(delta)
		delta = 0
		
func queue_free():
	queued_to_free = true
	.queue_free()

func create():
	id = WorldGenerator.get_new_id()
	variant = WorldGenerator.rng.randi()
	if hitpoints_max == -1:
		hitpoints_max = 1
	hitpoints = hitpoints_max
	ready()
	
func ready():
	pass

func process(delta: float):
	pass

func kill():
	pass

func is_dead() -> bool:
	if indestructible:
		return false
	return hitpoints <= 0
	
func set_visible(in_data):
	if typeof(in_data) == TYPE_BOOL:
		visible = in_data
	else:
		visible = planet_system == in_data

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
		"label": label,
		"hitpoints": hitpoints,
		"hitpoints_max": hitpoints_max,
		"indestructible": indestructible,
		"faction": faction,
		"planet_system": planet_system,
		"rotation_speed": rotation_speed,
		"state": state,
		"process_target": process_target,
		"process_progress": process_progress,
		
		# Resources
		"metal": metal,
		"metal_max": metal_max,
		"power": power,
		"power_max": power_max,
		"food": food,
		"food_max": food_max,
		"water": water,
		"water_max": water_max,
		
		# Object
		"object_type": object_type,
		
		# Planet
		"planet_type": planet_type,
		"planet_size": planet_size,
		
		# Ship
		"ship_type": ship_type,
		"ship_speed": ship_speed,
		"ship_speed_max": ship_speed_max,
		"ship_cargo_size": ship_cargo_size
	}
	
	var i = 0
	for point in planet_convex_hull:
		data['planet_convex_hull_%d_x' % i] = point.x
		data['planet_convex_hull_%d_y' % i] = point.y
		i = i + 1
	
	return data

