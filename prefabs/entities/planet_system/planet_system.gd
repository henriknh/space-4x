extends Entity

class_name PlanetSystem

var planet_sites = []
var neighbors = []
var tiles = []

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSystem')
	
	_generate_tiles()
	_generate_sites()
	_generate_asteroid_clusters()
	_generate_nebula_clusters()

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
	

func _generate_sites():
	var planets_min = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].min
	var planets_max = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].max
	var planet_count = Random.randi_range(planets_min, planets_max)
	
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

func _generate_asteroid_clusters():
	print(planet_sites.size())
	
	
	var planets = []
	for planet_site in planet_sites:
		planets.append(planet_site.planet)
	
	for i in range(int(planet_sites.size() / 4)):
		var compare_to = []
		for planet_site in planet_sites:
			compare_to.append(planet_site.planet)
		compare_to.append_array(get_tree().get_nodes_in_group("Asteroid"))

		var most_separated_planet = _get_most_separated_node(planets, compare_to)
		if most_separated_planet:
			planets.erase(most_separated_planet)
			Instancer.group_id_counter += 1
			
			var planet_tile = most_separated_planet.get_parent()
			var tile_positions = Utils.get_tile_positions_at_n_distance(2)
			
			for tile_position in tile_positions:
				for tile in tiles:
					if Utils.equals(tile.global_transform.origin, tile_position + planet_tile.global_transform.origin):
						tile.entity = Instancer.asteroid(tile)
						tile.add_child(tile.entity)
			
			var asteroid_group = preload("res://prefabs/entities/asteroid/asteroid_group.tscn").instance()
			add_child(asteroid_group)

func _generate_nebula_clusters():
	for i in range(int(planet_sites.size() / 4)):
		var compare_to = []
		var empty_tiles = []
		for tile in tiles:
			if tile.entity:
				compare_to.append(tile)
			else:
				empty_tiles.append(tile)
		
		
		var most_separated_tile = _get_most_separated_node(empty_tiles, compare_to)
		if most_separated_tile:
			Instancer.group_id_counter += 1
			
			most_separated_tile.add_child(Instancer.nebula(most_separated_tile))
			
			for neighbor in most_separated_tile.neighbors:
				if not neighbor.entity:
					neighbor.add_child(Instancer.nebula(neighbor))
	
func _get_most_separated_node(nodes: Array, compared_to: Array = []):
	if compared_to.size() == 0:
		compared_to = nodes
	
	var most_separated = {}
	
	for node in nodes:
		most_separated[node] = INF
		
	for node in most_separated.keys():
		for _node in most_separated.keys():
			if node == _node:
				continue
			
			var dist = node.global_transform.origin.distance_to(_node.global_transform.origin)
			if dist < most_separated[node]:
				most_separated[node] = dist
	
	var visited = []
	var dist = 0
	var most_spread_node = null
	for node in most_separated.keys():
		if most_separated[node] > dist:
			dist = most_separated[node]
			most_spread_node = node
	if most_spread_node:
		return most_spread_node
	else:
		return null
