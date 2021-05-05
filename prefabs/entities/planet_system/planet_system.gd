extends Entity

class_name PlanetSystem

var neighbors = []
var tiles = []
var sites = {}
var bounds: Array = []

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSystem')

func get_coords() -> Vector2:
	var x = translation.x / (Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] * sqrt(3))
	var z = translation.z / Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] / 1.5 * sqrt(3)
	return Vector2(int(round(x)), int(round(z)))
	
func _generate_tiles():
	var radius_min = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].min
	var radius_max = Consts.PLANET_SYSTEM_RADIUS[WorldGenerator.world_size].max
	var radius = Random.randi_range(radius_min, radius_max)
		
	var width = Consts.TILE_SIZE * sqrt(3)
	var _height = Consts.TILE_SIZE * 2
	
	for i in range(3, radius + 3):
		for j in range(6):
			var angle_deg = 60 * j + 60
			var angle_rad = PI / 180 * angle_deg
			var position = Vector3(cos(angle_rad), 0, sin(angle_rad)) * width * i
			
			tiles.append(Instancer.tile(position, i == radius + 2))

			for k in range(1, i):
				var angle_deg_child = angle_deg + 120
				var angle_rad_child = PI / 180 * angle_deg_child
				var position_child = position + Vector3(width * k * cos(angle_rad_child), 0, width * k * sin(angle_rad_child))
				
				tiles.append(Instancer.tile(position_child, i == radius + 2))
	
	var tile_dict = {}
	for tile in tiles:
		tile_dict[tile.get_coords()] = tile
	
	for tile in tiles:
		var _neighbors = []
		for coord in Consts.TILE_DIR_ALL:
			coord += tile.get_coords()
			if tile_dict.has(coord):
				_neighbors.append(tile_dict[coord])
		tile.neighbors = _neighbors
		
	var tiles_positions = []
	for tile in tiles:
		tiles_positions.append(Vector2(tile.translation.x, tile.translation.z))
	bounds = Geometry.convex_hull_2d(tiles_positions)
	
#	var st = SurfaceTool.new()
#	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
#	for point in bounds:
#		st.add_vertex(Vector3(point.x, 0, point.y))
#	var mesh = MeshInstance.new()
#	mesh.mesh = st.commit()
#	add_child(mesh)

func _generate_sites():
	var planets_min = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].min
	var planets_max = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].max
	var planet_count = Random.randi_range(planets_min, planets_max)
	
	var curr_site = 0
	var unclaimed = tiles.duplicate()
	
	while unclaimed.size() > 0:
		
		if not sites.has(curr_site):
			sites[curr_site] = []
		
		if sites[curr_site].size() == 0:
			var i = Random.randi() % unclaimed.size()
			var tile = unclaimed[i]
			unclaimed.erase(tile)
			sites[curr_site].append(tile)
		else:
			var found = false
			for site_tile in sites[curr_site]:
				for neighbor in site_tile.neighbors:
					if not found and neighbor in unclaimed:
						sites[curr_site].append(neighbor)
						unclaimed.erase(neighbor)
						found = true
						break
		
		curr_site = (curr_site + 1) % planet_count

func get_neighbor_in_dir(coords: Vector2) -> PlanetSystem:
	for neighbor in neighbors:
		if (neighbor.get_coords() - get_coords()) == coords:
			return neighbor
	return null
