extends Entity

class_name PlanetSystem

var neighbors = []
var tiles = []

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSystem')
	
	call_deferred("_generate_tiles")

func get_coords() -> Vector2:
	var x = translation.x / (Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] * sqrt(3))
	var z = translation.z / Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] / 1.5 * sqrt(3)
	return Vector2(int(round(x)), int(round(z)))
	
func _generate_tiles():
	var radius_min = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].min
	var radius_max = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].max
	var gap = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].gap
	var radius = Random.randi_range(radius_min, radius_max)
	
	for i in range(gap, gap + radius):
		var is_edge_node = (i + 1) == (gap + radius)
		for tile_positon in Utils.get_tile_positions_at_n_distance(i):
			tiles.append(Instancer.tile(tile_positon, is_edge_node))
	
	var tiles_dict = {}
	for tile in tiles:
		tiles_dict[tile.get_coords()] = tile
	
	for tile in tiles:
		for coord in Consts.TILE_DIR_ALL:
			coord += tile.get_coords()
			var neighbor = tiles_dict.get(coord)
			if neighbor:
				tile.neighbors.append(neighbor)
	
	_generate_sites()

func _generate_sites():
	var planets_min = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].min
	var planets_max = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].max
	var planet_count = Random.randi_range(planets_min, planets_max)
	
	var planet_sites = []
	for _i in range(planet_count):
		planet_sites.append(Instancer.planet_site())
	
	var curr_site = 0
	var unclaimed = tiles.duplicate()
	while unclaimed.size() > 0:
		if planet_sites[curr_site].tiles.size() == 0:
			var tile = unclaimed[Random.randi() % unclaimed.size()]
			unclaimed.erase(tile)
			planet_sites[curr_site].tiles.append(tile)
		else:
			var found = false
			for site_tile in planet_sites[curr_site].tiles:
				for neighbor in site_tile.neighbors:
					if not found and neighbor in unclaimed:
						planet_sites[curr_site].tiles.append(neighbor)

						unclaimed.erase(neighbor)
						found = true
						break
		
		curr_site = (curr_site + 1) % planet_count
	
	for planet_site in planet_sites:
		for tile in planet_site.tiles:
			planet_site.add_child(tile)
		add_child(planet_site)

func get_neighbor_in_dir(coords: Vector2) -> PlanetSystem:
	for neighbor in neighbors:
		if coords.is_equal_approx(neighbor.get_coords() - get_coords()):
			return neighbor
	return null
