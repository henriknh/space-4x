extends Node

var script_entity = preload('res://prefabs/entities/entity.gd')

# Planet system
var prefab_planet_system = preload('res://prefabs/entities/planet_system/planet_system.tscn')

# Planet 
var prefab_planet = preload('res://prefabs/entities/planets/planet.tscn')
var script_earth = preload('res://prefabs/entities/planets/planet_earth.gd')
var script_ice = preload('res://prefabs/entities/planets/planet_ice.gd')
var script_iron = preload('res://prefabs/entities/planets/planet_iron.gd')
var script_lava = preload('res://prefabs/entities/planets/planet_lava.gd')

# Object
var prefab_asteroid = preload('res://prefabs/entities/objects/asteroid/asteroid.tscn')

# Ship
var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_ship = preload('res://prefabs/entities/ships/ship.gd')
var script_combat = preload('res://prefabs/entities/ships/ship_combat.gd')
var script_explorer = preload('res://prefabs/entities/ships/ship_explorer.gd')
var script_miner = preload('res://prefabs/entities/ships/ship_miner.gd')
var script_transport = preload('res://prefabs/entities/ships/ship_transport.gd')

func ship(ship_type: int, copy_from: entity = null, inherit: entity = null) -> entity:
	
	var instance: entity = prefab_ship.instance()
	
	match ship_type:
		Enums.ship_types.combat:
			instance.set_script(script_combat)
		Enums.ship_types.explorer:
			instance.set_script(script_explorer)
		Enums.ship_types.miner:
			instance.set_script(script_miner)
		Enums.ship_types.transport:
			instance.set_script(script_transport)

	if copy_from:
		for propery in script_ship.get_script_property_list():
			instance.set(propery.name, copy_from.get(propery.name))
		
		instance.position = copy_from.position
		instance.rotation_degrees = copy_from.rotation_degrees
	
	if inherit:
		instance.planet_system = inherit.planet_system
		instance.faction = inherit.faction
		instance.position = inherit.position
		instance.parent = inherit
	
	instance.ship_type = ship_type
	
	if copy_from == null:
		instance.create()
	else:
		instance.ready()
	
	return instance
	
func object(object_type: int, planet_system_idx: int) -> entity:
	var instance: entity

	match object_type:
		Enums.object_types.asteroid:
			instance = prefab_asteroid.instance()

	var angle = WorldGenerator.rng.randf() * 2 * PI
	var distance = Consts.asteroids_base_distance_to_sun + WorldGenerator.rng.randf() * (Consts.planet_system_radius + Consts.asteroids_extra_distance)
	instance.position = Vector2(distance * cos(angle), distance * sin(angle))
	instance.planet_system = planet_system_idx
	
	instance.create()
	
	return instance
	
func planet(planet_type: int, position: Vector2, planet_system_idx: int) -> entity:
	var instance: entity = prefab_planet.instance()

	match planet_type:
		Enums.planet_types.earth:
			instance.set_script(script_earth)
		Enums.planet_types.ice:
			instance.set_script(script_ice)
		Enums.planet_types.iron:
			instance.set_script(script_iron)
		Enums.planet_types.lava:
			instance.set_script(script_lava)

	instance.position = position
	instance.planet_system = planet_system_idx
	
	instance.create()
	
	return instance

func planet_system(planet_system_idx: int) -> entity:
	var instance: entity = prefab_planet_system.instance()
	instance.position = Vector2(planet_system_idx * 250, 0)
	instance.planet_system = planet_system_idx
	
	instance.create()
	
	return instance
