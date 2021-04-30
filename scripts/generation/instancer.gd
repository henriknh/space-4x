extends Spatial

var script_entity = preload('res://prefabs/entities/entity.gd')

var prefab_galaxy = preload("res://prefabs/entities/galaxy/galaxy.tscn")
var prefab_planet_system = preload('res://prefabs/entities/planet_system/planet_system.tscn')
var prefab_tile = preload('res://prefabs/entities/tile/tile.tscn')
var prefab_planet = preload('res://prefabs/entities/planets/planet.tscn')
var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')

func galaxy() -> Galaxy:
	var instance: Galaxy = prefab_galaxy.instance()
	
	instance._generate_planet_systems()
	
	return instance

func planet_system(position: Vector3 = Vector3.ZERO) -> PlanetSystem:
	var instance: PlanetSystem = prefab_planet_system.instance()
	
	instance.translation = position
	
	instance._generate_tiles()
	instance._generate_sites()
	
	return instance

func tile(position: Vector3) -> Tile:
	var instance: Tile = prefab_tile.instance()
	
	instance.translation = position
	
	instance.create()
	
	return instance

func planet(tile: Tile) -> Planet:
	var instance: Planet = prefab_planet.instance()
	
	instance.translation = tile.translation
	
	return instance

func ship(ship_type: int, corporation_id: int, tile: Tile = null) -> Ship:
	
	var position: Vector3 = Vector3.ZERO
	if tile:
		position = tile.translation
		position += Vector3((Random.randi() % 5) - 2.5,0,(Random.randi() % 5) - 2.5)
	else:
		var camera: Camera = get_node('/root/GameScene/CameraRoot/Camera')
		var space_state = get_world().direct_space_state
		var mpos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mpos)
		var to = from + camera.project_ray_normal(mpos) * 1000
		var result = space_state.intersect_ray(from, to, [], 4, true, true)
		if result:
			position = result.collider.get_parent().translation
	
	var instance: Ship = prefab_ship.instance()
	
	instance.translation = position
	
	return instance
