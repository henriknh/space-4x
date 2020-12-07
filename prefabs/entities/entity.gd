extends KinematicBody2D

class_name entity

# Gernal
var entity_type = -1
var label = ''
var hitpoints = 1
var indestructible = false
var faction = 0
var planet_system = -1
var rotation_speed = 0
var temperature = 0

# Resources
var metal: float = 0
var metal_max: int = -1
var power: float = 0
var power_max: int = -1
var food: float = 0
var food_max: int = -1
var water: float = 0
var water_max: int = -1

# Planet specific variables
var planet_type: int = -1
var planet_size: float = 1.0
var planet_orbit_distance = 0

# Ship specific variables
var ship_type: int = -1
var ship_speed: float = 0.0
var ship_speed_max: int = 500
var ship_target = Vector2.ZERO
var ship_cargo_size: int = 20

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
	return {
		"filename": get_filename(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
		
		# General
		"entity_type": entity_type,
		"label": label,
		"hitpoints": hitpoints,
		"indestructible": indestructible,
		"faction": faction,
		"planet_system": planet_system,
		"rotation_speed": rotation_speed,
		
		# Resources
		"metal": metal,
		"metal_max": metal_max,
		"power": power,
		"power_max": power_max,
		"food": food,
		"food_max": food_max,
		"water": water,
		"water_max": water_max,
		
		# Planet
		"planet_type": planet_type,
		"planet_size": planet_size,
		"planet_orbit_distance": planet_orbit_distance,
		
		# Ship
		"ship_type": ship_type,
		"ship_speed": ship_speed,
		"ship_speed_max": ship_speed_max,
		"ship_target_x": ship_target.x if ship_target else null,
		"ship_target_y": ship_target.y if ship_target else null,
	}
