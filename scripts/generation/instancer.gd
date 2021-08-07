extends Spatial

var prefab_galaxy = preload("res://prefabs/entities/galaxy/galaxy.tscn")
var prefab_planet_system = preload('res://prefabs/entities/planet_system/planet_system.tscn')
var prefab_planet_site = preload('res://prefabs/entities/planet_site/planet_site.tscn')
var prefab_tile = preload('res://prefabs/entities/tile/tile.tscn')
var prefab_planet = preload('res://prefabs/entities/planets/planet.tscn')
var prefab_asteroid = preload('res://prefabs/entities/asteroid/asteroid.tscn')
var prefab_nebula= preload("res://prefabs/entities/nebula/nebula.tscn")

var prefab_ship_explorer = preload("res://prefabs/entities/ships/explorer.tscn")
var prefab_ship_fighter = preload("res://prefabs/entities/ships/fighter.tscn")
var prefab_ship_carrier = preload("res://prefabs/entities/ships/carrier.tscn")
var prefab_ship_miner = preload("res://prefabs/entities/ships/miner.tscn")

func galaxy() -> Galaxy:
	GameState.loading += 1
	
	return prefab_galaxy.instance()

func planet_system(position: Vector3 = Vector3.ZERO) -> PlanetSystem:
	GameState.loading += 1
	
	var instance: PlanetSystem = prefab_planet_system.instance()
	instance.translation = position
	return instance

func planet_site() -> PlanetSite:
	GameState.loading += 1
	
	return prefab_planet_site.instance()

func tile(position: Vector3, is_edge: bool) -> Tile:
	GameState.loading += 1
	
	var instance: Tile = prefab_tile.instance()
	instance.translation = position
	instance.is_edge = is_edge
	return instance

func planet(tile: Tile) -> Planet:
	GameState.loading += 1
	
	var instance: Planet = prefab_planet.instance()
	tile.entity = instance
	return instance

func asteroid(tile: Tile) -> Asteroid:
	GameState.loading += 1
	
	var instance: Asteroid = prefab_asteroid.instance()
	tile.entity = instance
	return instance

func nebula(tile: Tile) -> Nebula:
	GameState.loading += 1
	
	var instance: Nebula = prefab_nebula.instance()
	tile.entity = instance
	return instance

func ship(ship_type: int, inherit: Entity = null, override = {}) -> Ship:
	var instance: Ship
	match ship_type:
		Enums.ship_types.explorer:
			instance = prefab_ship_explorer.instance()
		Enums.ship_types.fighter:
			instance = prefab_ship_fighter.instance()
		Enums.ship_types.carrier:
			instance = prefab_ship_carrier.instance()
		Enums.ship_types.miner:
			instance = prefab_ship_miner.instance()
	
	if inherit and inherit is Ship:
		instance.corporation_id = inherit.corporation_id
		instance.ship_count = inherit.ship_count
		instance.health = inherit.health
		instance.translation = inherit.translation
		instance.parent = inherit.parent
	elif inherit and inherit is Planet:
		instance.corporation_id = inherit.corporation_id
		
		var spawn_tile = null
		for neighbor in inherit.get_parent().neighbors:
			if inherit.corporation_id == neighbor.corporation_id and not neighbor.entity:
				spawn_tile = neighbor
				break
		if not spawn_tile:
			for neighbor in inherit.get_parent().neighbors:
				if inherit.corporation_id == neighbor.corporation_id:
					spawn_tile = neighbor
					break
		if spawn_tile:
			instance.translation = spawn_tile.global_transform.origin
		
	
	for key in override.keys():
		instance.set(key, override[key])
		if key == "translation":
			instance.translation = override[key]
	
	return instance
