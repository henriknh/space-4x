extends Area2D

class_name entity

var _name = ''
var _hitpoints = 1
var _is_indestructible = false
var _faction = 0
var _star_system = -1
var _rotation_speed = 0

# Resources
var _metal = 0
var _power = 0
var _food = 0
var _water = 0

# Planet specific variables
var _planet_type = -1
var _planet_size = 1
var _planet_orbit_distance = 0

# Ship specific variables
var _ship_speed = 0
var _ship_target = Vector2.ZERO
var _ship_forward_dir = Vector2.ZERO

func set_name(name: String) -> void:
	_name = name

func get_name() -> String:
	return _name

func set_hitpoints(hitpoints: int) -> void:
	_hitpoints = hitpoints

func get_hitpoints() -> int:
	return _hitpoints

func damage_entity(damage: int) -> int:
	_hitpoints -= damage
	return _hitpoints

func repair_entity(hitpoints: int) -> int:
	_hitpoints -= hitpoints
	return _hitpoints

func is_dead() -> bool:
	if _is_indestructible:
		return false
	return _hitpoints <= 0

func set_indestructible(is_indestructible: bool) -> void:
	_is_indestructible = is_indestructible

func set_faction(faction: int) -> void:
	_faction = faction

func get_factio() -> int:
	return _faction

func set_star_system(star_system: int) -> void:
	_star_system = star_system

func get_star_system() -> int:
	return _star_system
	
func set_rotation_speed(speed: float) -> void:
	_rotation_speed = speed
	
func set_visible(in_data):
	if typeof(in_data) == TYPE_BOOL:
		visible = in_data
	else:
		visible = _star_system == in_data
		
func get_metal() -> int:
	return _metal
	
func get_power() -> int:
	return _power
	
func get_food() -> int:
	return _food
	
func get_water() -> int:
	return _water

func save():
	return {
		"filename": get_filename(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
		"_name": _name,
		"_hitpoints": _hitpoints,
		"_is_indestructible": _is_indestructible,
		"_faction": _faction,
		"_star_system": _star_system,
		"_planet_type": _planet_type,
		"_planet_size": _planet_size,
		"_rotation_speed": _rotation_speed,
		"_planet_orbit_distance": _planet_orbit_distance,
		"_ship_speed": _ship_speed,
		"_ship_target_x": _ship_target.x if _ship_target else null,
		"_ship_target_y": _ship_target.y if _ship_target else null,
	}
