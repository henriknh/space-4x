extends Entity

class_name PlanetSystem

var neighbors = []

var bounds: Array = []

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSystem')
	
	call_deferred("_generate_tiles")

func get_coords() -> Vector2:
	var x = translation.x / (Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] * sqrt(3))
	var z = translation.z / Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] / 1.5 * sqrt(3)
	return Vector2(int(round(x)), int(round(z)))
	
func _generate_tiles():
	var tiles = {}
	var radius_min = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].min
	var radius_max = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].max
	var gap = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].gap
	var radius = Random.randi_range(radius_min, radius_max)
	
	var width = Consts.TILE_SIZE * sqrt(3)
	var _height = Consts.TILE_SIZE * 2
	
	for i in range(gap, gap + radius):
		
		var is_edge_node = i == gap + radius
		
		if i == 0:
			var tile = Instancer.tile(Vector3(0, 0, 0), is_edge_node)
			tiles[tile.get_coords()] = tile
		else:
			for j in range(6):
				var angle_deg = 60 * j + 60
				var angle_rad = PI / 180 * angle_deg
				var position = Vector3(cos(angle_rad), 0, sin(angle_rad)) * width * i
				
				var tile = Instancer.tile(position, is_edge_node)
				tiles[tile.get_coords()] = tile

				for k in range(1, i):
					var angle_deg_child = angle_deg + 120
					var angle_rad_child = PI / 180 * angle_deg_child
					var position_child = position + Vector3(width * k * cos(angle_rad_child), 0, width * k * sin(angle_rad_child))

					var tile_child = Instancer.tile(position_child, is_edge_node)
					tiles[tile_child.get_coords()] = tile_child
	
	for tile in tiles.values():
		for coord in Consts.TILE_DIR_ALL:
			coord += tile.get_coords()
			var neighbor = tiles.get(coord)
			if neighbor:
				tile.neighbors.append(neighbor)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
	for point in bounds:
		st.add_vertex(Vector3(point.x, 0, point.y))
	var mesh = MeshInstance.new()
	mesh.mesh = st.commit()
	add_child(mesh)
	
	_generate_sites(tiles)

func _generate_sites(tiles):
	var planets_min = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].min
	var planets_max = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].max
	var planet_count = Random.randi_range(planets_min, planets_max)
	
	var planet_sites = []
	for _i in range(planet_count):
		planet_sites.append(Instancer.planet_site())
	
	var curr_site = 0
	var unclaimed = tiles.values().duplicate()
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
		add_child(planet_site)
		for tile in planet_site.tiles:
			planet_site.add_child(tile)
		
	var tiles_positions = []
	for tile in tiles.values():
		tiles_positions.append(Vector2(tile.global_transform.origin.x, tile.global_transform.origin.z))
	bounds = Geometry.convex_hull_2d(tiles_positions)
	bounds = Geometry.offset_polygon_2d(bounds, 25)[0]

func get_neighbor_in_dir(coords: Vector2) -> PlanetSystem:
	for neighbor in neighbors:
		if coords.is_equal_approx(neighbor.get_coords() - get_coords()):
			return neighbor
	return null
