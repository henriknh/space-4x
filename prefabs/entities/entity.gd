extends KinematicBody2D

class_name entity

const ACTIVE_TIME_PERIOD: float = 0.0166
const INACTIVE_TIME_PERIOD: float = 0.5

# Temporary
var delta: float = 0

# General
var id: int = -1
var parent: entity
var entity_type: int = -1
var label: String = ''
var hitpoints: int = 1
var indestructible: bool = false
var faction: int = 0
var planet_system: int = -1
var rotation_speed: float = 0
var color: Color = Color(1,1,1,1)

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
var planet_orbit_distance = 0
var planet_convex_hull = []

# Ship specific variables
var ship_type: int = -1
var ship_speed: float = 0.0
var ship_speed_max: int = 500
var ship_target_id: int = -1
var ship_cargo_size: int = 20

func _physics_process(_delta):
	delta += _delta
	
	if visible and delta < ACTIVE_TIME_PERIOD or not visible and delta < INACTIVE_TIME_PERIOD:
		return
	else:
		process()
		delta = 0
		
func create():
	id = WorldGenerator.get_new_id()
	ready()
	
func ready():
	pass

func process():
	pass

func kill():
	hitpoints = 0
	queue_free()

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
		"entity_type": entity_type,
		"label": label,
		"hitpoints": hitpoints,
		"indestructible": indestructible,
		"faction": faction,
		"planet_system": planet_system,
		"rotation_speed": rotation_speed,
		"color": color.to_html(true),
		
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
		"planet_orbit_distance": planet_orbit_distance,
		
		# Ship
		"ship_type": ship_type,
		"ship_speed": ship_speed,
		"ship_speed_max": ship_speed_max,
		"ship_target_id": ship_target_id
	}
	
	var i = 0
	for point in planet_convex_hull:
		data['planet_convex_hull_%d_x' % i] = point.x
		data['planet_convex_hull_%d_y' % i] = point.y
		i = i + 1
	
	return data

