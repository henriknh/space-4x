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
var prefab_asteroid = preload('res://prefabs/entities/props/asteroid/asteroid.tscn')

# Ship
var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_ship = preload('res://prefabs/entities/ships/ship.gd')
var script_combat = preload('res://prefabs/entities/ships/ship_combat.gd')
var script_explorer = preload('res://prefabs/entities/ships/ship_explorer.gd')
var script_miner = preload('res://prefabs/entities/ships/ship_miner.gd')

func ship(ship_type: int, copy_from: Entity = null, inherit: Entity = null, override: Dictionary = {}) -> Entity:
	
	var instance: Entity = prefab_ship.instance()
	
	match ship_type:
		Enums.ship_types.combat:
			instance.set_script(script_combat)
		Enums.ship_types.explorer:
			instance.set_script(script_explorer)
		Enums.ship_types.miner:
			instance.set_script(script_miner)

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
	
	for key in override:
		print(instance.get(key))
		instance.set(key, override[key])
		print(instance.get(key))
		
	instance.ship_type = ship_type
	
	if copy_from == null:
		instance.create()
	else:
		instance.ready()
	
	return instance
	
func object(object_type: int, planet_system_idx: int, position: Vector2 = Vector2.INF) -> Entity:
	var instance: Entity

	match object_type:
		Enums.object_types.asteroid:
			instance = prefab_asteroid.instance()

	if position == Vector2.INF:
		var angle = Random.randf() * 2 * PI
		var distance = Consts.ASTEROIDS_BASE_DISTANCE_TO_SUN + Random.randf() * (Consts.PLANET_SYSTEM_RADIUS + Consts.ASTEROIDS_EXTRA_DISTANCE)
		instance.position = Vector2(distance * cos(angle), distance * sin(angle))
	else:
		instance.position = position
	
	instance.planet_system = planet_system_idx
	
	instance.create()
	
	return instance
	
func planet(planet_type: int, position: Vector2, convex_hull: Array, planet_system_idx: int) -> Entity:
	var instance: Entity = prefab_planet.instance()

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
	instance.planet_convex_hull = convex_hull
	
	instance.create()
	
	return instance

func planet_system(planet_system_idx: int) -> Entity:
	var instance: Entity = prefab_planet_system.instance()
	instance.position = Vector2(planet_system_idx * 250, 0)
	instance.planet_system = planet_system_idx
	
	instance.create()
	
	return instance
