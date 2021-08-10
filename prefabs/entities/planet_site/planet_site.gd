extends Entity

class_name PlanetSite

onready var node_mesh: MeshInstance = $Mesh

var tiles = [] 
var planet: Planet

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSite')
	
	# Calulcate planet tile
	var neighbors_in_planet_site = -1
	var planet_tile = null
	
	for tile in tiles:
		var i = 0
		for neighbor1 in tile.neighbors:
			if neighbor1 in tiles:
				i += 1
				for neighbor2 in neighbor1.neighbors:
					if neighbor2 in tiles:
						i += 1
		if i > neighbors_in_planet_site:
			neighbors_in_planet_site = i
			planet_tile = tile
	
	planet = Instancer.planet(planet_tile)
	planet_tile.add_child(planet)
	
	# Generate resource entity
	var resource_tile = _get_empty_entity_tile()
	if resource_tile:
		resource_tile.add_child(Instancer.asteroid(resource_tile))
		
	resource_tile = _get_empty_entity_tile()
	if resource_tile:
		resource_tile.add_child(Instancer.nebula(resource_tile))
	
	# Generate site mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	var points = {}
	
	for tile in tiles:
		
		if not tile.is_edge:
			continue
		
		var polygon = tile.get_global_polygon()
		
		for i in range(polygon.size()):
			var p0 = polygon[((i - 1) + polygon.size()) % polygon.size()]
			var p1 = polygon[i]
			var p2 = polygon[((i + 1) + polygon.size()) % polygon.size()]
			var p0_dict_key = null
			var p1_dict_key = null
			var p2_dict_key = null
			for _point in points.keys():
				if is_equal_approx(p0.x, _point.x) and is_equal_approx(p0.y, _point.y):
					p0_dict_key = _point
				if is_equal_approx(p1.x, _point.x) and is_equal_approx(p1.y, _point.y):
					p1_dict_key = _point
				if is_equal_approx(p2.x, _point.x) and is_equal_approx(p2.y, _point.y):
					p2_dict_key = _point
			
			if p0_dict_key == null:
				p0_dict_key = p0
				points[p0_dict_key] = []
			if p1_dict_key == null:
				p1_dict_key = p1
				points[p1_dict_key] = []
			if p2_dict_key == null:
				p2_dict_key = p2
				points[p2_dict_key] = []
				
			# Check p0
			var p0_found = false
			for point in points[p1_dict_key]:
				if is_equal_approx(p0_dict_key.x, point.x) and is_equal_approx(p0_dict_key.y, point.y):
					p0_found = true
					break
			if not p0_found:
				points[p1_dict_key].append(p0_dict_key)
			
			# Check p2
			var p2_found = false
			for point in points[p1_dict_key]:
				if is_equal_approx(p2_dict_key.x, point.x) and is_equal_approx(p2_dict_key.y, point.y):
					p2_found = true
					break
			if not p2_found:
				points[p1_dict_key].append(p2_dict_key)
				

	
	for point in points:
		if point in points[point]:
			points[point].erase(point)
	
	# find start
	var line = []
	for _point in points:
		if points[_point].size() == 2:
			line = [_point]
			break
	
	var prev = 0
	while line.size() == 1 or line.front() != line.back():
		var fewest_points = null
		var fewest_points_count = INF
		for point in points[line.back()]:
			if point in line:
				continue
			if points[point].size() < fewest_points_count:
				fewest_points_count = points[point].size()
				fewest_points = point
				
		if not fewest_points:
			break
		else:
			line.append(fewest_points)
			prev = fewest_points_count
	
	print(line)
		
		
	
	for tile in tiles:
		var polygon = tile.get_global_polygon()
		
		var p0 = Vector3(tile.translation.x, 0, tile.translation.z)
		for i in range(0, polygon.size() - 1):
			var p1 = Vector3(polygon[i].x, 0, polygon[i].y)
			var p2 = Vector3(polygon[i + 1].x, 0, polygon[i + 1].y)
			
			var neighbor = tile.get_neighbor_in_dir(Consts.TILE_DIR_ALL[i])

			if not neighbor or not neighbor in tiles:
				pass

				# First triangle
#				st.add_vertex(p2)
#				st.add_vertex(p1 + Vector3.DOWN)
#				st.add_vertex(p2 + Vector3.DOWN)
				
				# First triangle (inside)
#				st.add_vertex(p2)
#				st.add_vertex(p2 + Vector3.DOWN)
#				st.add_vertex(p1 + Vector3.DOWN)

				# Second triangle
#				st.add_vertex(p1)
#				st.add_vertex(p1 + Vector3.DOWN)
#				st.add_vertex(p2)
				
				# Second triangle (inside)
#				st.add_vertex(p1)
#				st.add_vertex(p2)
#				st.add_vertex(p1 + Vector3.DOWN)

			# Bottom
#			st.add_vertex(p0)
#			st.add_vertex(p1)
#			st.add_vertex(p2)

	line = Geometry.offset_polygon_2d(line, -0.01)[0]
	for point in line:
		st.add_vertex(Vector3(point.x, 0, point.y))
	node_mesh.mesh = st.commit()
	node_mesh.material_override = MaterialLibrary.get_material(planet.corporation_id, false)
	
	planet.connect("entity_changed", self, "update_border_color")
	GameState.connect("planet_system_changed", self, "update_overview")
	update_border_color()

func update_border_color():
	node_mesh.material_override = MaterialLibrary.get_material(planet.corporation_id, false)
	
func update_overview():
	node_mesh.visible = not (GameState.planet_system == null and self.planet.corporation_id == 0)

func _get_empty_entity_tile() -> Tile:
	var _tiles = tiles
	_tiles.shuffle()
	for tile in _tiles:
		if not tile.entity:
			return tile
	return null

class MyCustomSorter:
	var center = Vector2.ZERO
	func sort_ascending(a, b):
		if center.angle_to_point(a) < center.angle_to_point(b):
			return true
		return false
