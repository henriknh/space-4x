extends Spatial

var script_entity = preload('res://prefabs/entities/entity.gd')

var prefab_galaxy = preload("res://prefabs/entities/galaxy/galaxy.tscn")
var prefab_planet_system = preload('res://prefabs/entities/planet_system/planet_system.tscn')
var prefab_planet_site = preload('res://prefabs/entities/planet_site/planet_site.tscn')
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
	instance._generate_grid()
	
	return instance

func planet_site(site) -> PlanetSite:
	var instance: PlanetSite = prefab_planet_site.instance()
	
	instance.tiles = site.tiles
	instance.polygon = site.polygon
	
	return instance

func tile(position: Vector3, is_edge: bool) -> Tile:
	var instance: Tile = prefab_tile.instance()
	
	instance.translation = position
	instance.is_edge = is_edge
	
	instance.create()
	
	return instance

func planet(tile: Tile) -> Planet:
	var instance: Planet = prefab_planet.instance()
	
	tile.entity = instance
	
	return instance

func ship(ship_type: int, inherit: Entity, tile: Tile = null) -> Ship:
	
	var position: Vector3 = Vector3.ZERO
	if tile:
		position = tile.global_transform.origin
		position += Vector3((Random.randi() % 5) - 2.5,0,(Random.randi() % 5) - 2.5)
	else:
		var camera: Camera = get_node('/root/GameScene/CameraRoot/Camera')
		var space_state = get_world().direct_space_state
		var mpos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mpos)
		var to = from + camera.project_ray_normal(mpos) * 1000
		var result = space_state.intersect_ray(from, to, [], 4, true, true)
		if result:
			position = (result.collider.get_parent() as Spatial).global_transform.origin
	
	var instance: Ship = prefab_ship.instance()
	
	instance.translation = position
	
	instance.corporation_id = inherit.corporation_id
	
	return instance
