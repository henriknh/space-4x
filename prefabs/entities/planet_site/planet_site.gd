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
	
	for neighbor in resource_tile.neighbors:
		if not neighbor.entity:
			neighbor.add_child(Instancer.nebula(resource_tile))
		
	
	planet.connect("entity_changed", self, "update_border_color")
	update_border_color()
	GameState.connect("planet_system_changed", self, "update_overview")
	update_border_color()
	
	call_deferred("_generate_border")

func _generate_border():
	
	
	
	
	# Calculate outer border
	var fewest_neighbors = null
	var fewest_neighbors_count = INF
	for tile in tiles:
		var neighbors_count = 0
		for neighbor in tile.neighbors:
			if neighbor.get_parent() != tile.get_parent():
				continue
			neighbors_count += 1
			
		if neighbors_count < fewest_neighbors_count:
			fewest_neighbors_count = neighbors_count
			fewest_neighbors = tile
	var curr_tile = fewest_neighbors
	
	var start_point = null
	for point in curr_tile.get_global_polygon():
		var found = false
		for neighbor in curr_tile.neighbors:
			if neighbor.get_parent() != curr_tile.get_parent():
				continue
			if Utils.array_has(point, neighbor.get_global_polygon()):
				found = true
				break
		if not found:
			start_point = point
	
	var line = [start_point]
	var curr_point = start_point
	var done = false
	while line.size() == 1 or not done:
		var polygon = curr_tile.get_global_polygon()
		polygon.remove(0)
		var idx = Utils.array_idx(curr_point, polygon)
		for i in range(6):
			var curr_idx = (idx + i) % 6
			curr_point = polygon[curr_idx]
			
			if line.size() > 1 and Utils.equals(curr_point, start_point):
				done = true
				break
			
			if Utils.array_has(curr_point, line):
				continue
			
			line.append(curr_point)
			
			var neighbor_has_point = false
			for neighbor in curr_tile.neighbors:
				if neighbor.get_parent() != curr_tile.get_parent():
					continue
				
				if Utils.array_has(curr_point, neighbor.get_global_polygon()):
					neighbor_has_point = neighbor
					break
			
			if neighbor_has_point:
				curr_tile = neighbor_has_point
				break
	var line_offset = Geometry.offset_polygon_2d(line, -1, Geometry.JOIN_MITER)[0]
	line = Geometry.offset_polygon_2d(line, 0, Geometry.JOIN_MITER)[0]
	
	
	var line_3d = []
	for point in line:
		line_3d.append(Vector3(point.x, 0, point.y))
	var line_offset_3d = []
	for point in line_offset:
		line_offset_3d.append(Vector3(point.x, 0, point.y))
	

	# Generate site mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(line_3d.size()):
		var j = (i + 1) % line_3d.size()
		# First triangle (CCW)
		# i1 - i2
		# |   /
		# |  /
		# j1
		st.add_vertex(line_3d[i])
		st.add_vertex(line_3d[j])
		st.add_vertex(line_offset_3d[i])
		
		# Second triangle  (CCW)
		#      i2
		#   /  |
		#  /   |
		# j1 - j2
		st.add_vertex(line_offset_3d[i])
		st.add_vertex(line_3d[j])
		st.add_vertex(line_offset_3d[j])
	
	$Mesh.mesh = st.commit()

func update_border_color():
	node_mesh.material_override = MaterialLibrary.get_material(planet.corporation_id, MaterialLibrary.MATERIAL_TYPES.UNSHADED)
	
func update_overview():
	node_mesh.visible = not (GameState.planet_system == null and self.planet.corporation_id == 0)

func _get_empty_entity_tile() -> Tile:
	var _tiles = tiles
	_tiles.shuffle()
	for tile in _tiles:
		if not tile.entity:
			return tile
	return null
