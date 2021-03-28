extends KinematicBody2D

class_name Entity

const ACTIVE_TIME_PERIOD: float = 0.0166
const INACTIVE_TIME_PERIOD: float = 0.05

# Temporary
var delta: float = 0
var queued_to_free: bool = false
var _faction_object
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
var faction: int = -1 setget _set_faction
var planet_system: int = -1
var rotation_speed: float = 0
var state: int = 0
var process_target: int
var process_time: float = 0
var _process_time_total: float = 0

# Resources
var asteroid_rocks: float = 0
var asteroid_rocks_max: int = 0
var titanium: float = 0
var titanium_max: int = 0
var astral_dust: float = 0
var astral_dust_max: int = 0

# Object specific variables
var prop_type: int = -1

# Planet specific variables
var planet_type: int = -1
var planet_size: float = 1.0
var planet_convex_hull = []
var planet_disabled_ships = 0

# Ship specific variables
var ship_type: int = -1
var ship_speed: float = 0.0
var ship_speed_max: int = 500
var ship_cargo_size: int = 20

func _physics_process(_delta):
	if GameState.loading:
		return
		
	if queued_to_free:
		return
	
	if planet_system != GameState.get_planet_system() and entity_type == Enums.entity_types.prop:
		return
	
	delta += _delta
	
	if visible and delta < ACTIVE_TIME_PERIOD or not visible and delta < INACTIVE_TIME_PERIOD:
		return
	else:
		if entity_type != Enums.entity_types.planet:
			if not parent:
				return
		
		if hitpoints <= 0:
			kill()
		else:
			var faction = get_faction()
			if faction and faction.is_computer:
				AI.process_entity(self, delta)
			process(delta)
			
		delta = 0
		
func queue_free():
	queued_to_free = true
	.queue_free()

func create():
	id = WorldGenerator.unique_id
	variant = Random.randi()
	if hitpoints_max == -1:
		hitpoints_max = 1
	hitpoints = hitpoints_max

func _ready():
	pass

func ready():
	set_visible(planet_system == GameState.get_planet_system())

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

func set_entity_process(state: int, target: int, total_time: int = 0) -> void:
	self.state = state
	process_target = target
	process_time = 0
	_process_time_total = total_time
	
func get_process_progress() -> float:
	if _process_time_total <= 0:
		return 0.0
	return process_time / _process_time_total

func _set_faction(faction_value):
	faction = faction_value
	_faction_object = Factions.get_faction(faction)
	if entity_type == Enums.entity_types.planet:
		Factions.emit_signal("factions_changed")
	
func get_faction() -> Faction:
	if faction >= 0 and _faction_object == null:
		_faction_object = Factions.get_faction(faction)
	return _faction_object
	
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
		"process_time": process_time,
		"_process_time_total": _process_time_total,
		
		# Resources
		"asteroid_rocks": asteroid_rocks,
		"asteroid_rocks_max": asteroid_rocks_max,
		"titanium": titanium,
		"titanium_max": titanium_max,
		"astral_dust": astral_dust,
		"astral_dust_max": astral_dust_max,
		
		# Object
		"prop_type": prop_type,
		
		# Planet
		"planet_type": planet_type,
		"planet_size": planet_size,
		"planet_disabled_ships": planet_disabled_ships,
		
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
