extends Entity

class_name PlanetSystem

var neighbors = []
var tiles = []
var sites = {}
var planet_sites = []
var bounds: Array = []

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSystem')
	
	modules.append({'class': PlanetSystemShipLineOfSight.new().init(self), 'state': null})

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
	
	var inner_limit = 3
	
	for i in range(inner_limit, radius + inner_limit):
		
		if i == 0:
			var tile = Instancer.tile(Vector3(0, 0, 0), i == radius + 2)
			tile.generate_polygon()
			tiles.append(tile)
		else:
			for j in range(6):
				var angle_deg = 60 * j + 60
				var angle_rad = PI / 180 * angle_deg
				var position = Vector3(cos(angle_rad), 0, sin(angle_rad)) * width * i
				
				var tile = Instancer.tile(position, i == radius + 2)
				tile.generate_polygon()
				tiles.append(tile)

				for k in range(1, i):
					var angle_deg_child = angle_deg + 120
					var angle_rad_child = PI / 180 * angle_deg_child
					var position_child = position + Vector3(width * k * cos(angle_rad_child), 0, width * k * sin(angle_rad_child))
					
					var tile_child = Instancer.tile(position_child, i == radius + 2)
					tile_child.generate_polygon()
					tiles.append(tile_child)
	
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
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
	for point in bounds:
		st.add_vertex(Vector3(point.x, 0, point.y))
	var mesh = MeshInstance.new()
	mesh.mesh = st.commit()
	add_child(mesh)

func _generate_sites():
	var planets_min = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].min
	var planets_max = Consts.PLANET_SYSTEM_PLANETS[WorldGenerator.world_size].max
	var planet_count = Random.randi_range(planets_min, planets_max)
	
	var curr_site = 0
	var unclaimed = tiles.duplicate()
	
	while unclaimed.size() > 0:
		
		if not sites.has(curr_site):
			sites[curr_site] = {
				'polygon': [],
				'tiles': []
			}
		
		if sites[curr_site].tiles.size() == 0:
			var i = Random.randi() % unclaimed.size()
			var tile = unclaimed[i]
			unclaimed.erase(tile)
			sites[curr_site].tiles.append(tile)
			var polygon = tile.get_global_polygon()
			polygon.remove(0)
			sites[curr_site].polygon = polygon
		else:
			var found = false
			for site_tile in sites[curr_site].tiles:
				for neighbor in site_tile.neighbors:
					if not found and neighbor in unclaimed:
						sites[curr_site].tiles.append(neighbor)
						
						var p = sites[curr_site].polygon
						var t = neighbor.get_global_polygon()
						t.remove(0)
						t.invert()
						
						var pi
						for _p in p:
							
							if not Utils.array_has(_p, t):
								pi = Utils.array_idx(_p, p)
								break
						
						var inserted = false
						for i in range(p.size()):
							var pii = (pi + i + p.size()) % p.size()
							
							if Utils.array_has(p[pii], t) and not inserted:
								inserted = true
								
#								print(p)
#								print(t)
#								print('start')
								var start = p[pii]
#								print(start)
								var ti = (Utils.array_idx(start, t) - 1 + t.size()) % t.size()
								
								
								# find end
								var end 
								for _te in range(ti, -6, -1):
									var te = (_te + t.size()) % t.size()
									if not end and Utils.array_has(t[te], p):
										end = t[te]
#								print('end')
#								print(end)
								
								# Remove inbetween start and end
								var rp = (pii + 1 + p.size()) % p.size()
								while not Utils.equals(p[rp], end):
									#print(Utils.equals(p[rp], end))
									#print(p[rp])
									p.remove(rp)
								
								# Insert inbetween start and end from t to p
								var start_i = Utils.array_idx(start, p)
								var j = 0
								while t[ti] != end:
									# print(t[ti])
									var insert_i = (start_i + 1 + j)# % p.size()
									# print(insert_i)
									p.insert(insert_i, t[ti])
									ti = (ti - 1 + t.size()) % t.size()
									j += 1
								
							if inserted:
								break
						
						sites[curr_site].polygon = p
						
						unclaimed.erase(neighbor)
						found = true
						break
		
		curr_site = (curr_site + 1) % planet_count

	return
	for site in sites:
		
		var p = sites[site].polygon
		
		print('find dups')
		print(p)
		var has_two = []
		var has_three = []
		for p1 in p:
			var i = 0
			for p2 in p:
				if Utils.equals(p1, p2):
					i += 1
			if i == 2 and not Utils.array_has(p1, has_two):
				has_two.append(p1)
			if i == 3 and not Utils.array_has(p1, has_three):
				has_three.append(p1)

		print('has_three')
		print(has_three)
		for three in has_three:
			var i = 0
			while i < p.size():
				if Utils.equals(three, p[i]):
					p.remove(i)
				else:
					i += 1

		print('has_two')
		print(has_two)
		for two in has_two:
			var i = 0
			var first = false
			while i < p.size():

				if not first and Utils.equals(two, p[i]):
					first = true
					i += 1
				elif first and Utils.equals(two, p[i]):
					p.remove(i)
				else:
					i += 1



		for p1 in p:
			var i = 0
			for p2 in p:
				if Utils.equals(p1, p2):
					i += 1
			if i > 1:
				print(i)

		print(123)
		print(p)
		sites[site].polygon = p
		
	

func get_neighbor_in_dir(coords: Vector2) -> PlanetSystem:
	for neighbor in neighbors:
		if (neighbor.get_coords() - get_coords()) == coords:
			return neighbor
	return null
