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
		if Random.randi() % 2 == 0:
			resource_tile.add_child(Instancer.asteroid(resource_tile))
		else:
			resource_tile.add_child(Instancer.nebula(resource_tile))
	
	# Generate site mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for tile in tiles:
		var polygon = tile.get_global_polygon()
		
		var p0 = Vector3(tile.translation.x, 0, tile.translation.z)
		for i in range(0, polygon.size() - 1):
			var p1 = Vector3(polygon[i].x, 0, polygon[i].y)
			var p2 = Vector3(polygon[i + 1].x, 0, polygon[i + 1].y)
			
			var neighbor = tile.get_neighbor_in_dir(Consts.TILE_DIR_ALL[i])
			
			if not neighbor or not neighbor in tiles:

				# First triangle
				st.add_vertex(p2)
				st.add_vertex(p1 + Vector3.DOWN)
				st.add_vertex(p2 + Vector3.DOWN)
				
				# First triangle (inside)
#				st.add_vertex(p2)
#				st.add_vertex(p2 + Vector3.DOWN)
#				st.add_vertex(p1 + Vector3.DOWN)

				# Second triangle
				st.add_vertex(p1)
				st.add_vertex(p1 + Vector3.DOWN)
				st.add_vertex(p2)
				
				# Second triangle (inside)
#				st.add_vertex(p1)
#				st.add_vertex(p2)
#				st.add_vertex(p1 + Vector3.DOWN)

			# Bottom
			st.add_vertex(p0)
			st.add_vertex(p1)
			st.add_vertex(p2)
	
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
	for tile in tiles:
		if not tile.entity:
			return tile
	return null
