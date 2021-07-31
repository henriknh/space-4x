extends Entity

class_name Galaxy

var bounds = []
	
func _ready():
	add_to_group('Persist')
	add_to_group('Galaxy')
	
	call_deferred("_generate_planet_systems")

func _generate_planet_systems():
	var planet_systems_min = Consts.GALAXY_SIZE[WorldGenerator.world_size].min
	var planet_systems_max = Consts.GALAXY_SIZE[WorldGenerator.world_size].max
	var planet_system_count = Random.randi_range(planet_systems_min, planet_systems_max)
	
	var width = Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] * sqrt(3)
	var _height = Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] * 2
	
	var planet_systems = {}
	for i in range(0, 100):
		if i == 0:
			var planet_system = Instancer.planet_system(Vector3.ZERO)
			planet_systems[planet_system.get_coords()] = planet_system
			add_child(planet_system)
		else:
			for j in range(6):
				var angle_deg = 60 * j + 30
				var angle_rad = PI / 180 * angle_deg
				var position = Vector3(cos(angle_rad), 0, sin(angle_rad)) * width * i
				
				if planet_systems.size() < planet_system_count:
					var planet_system = Instancer.planet_system(position)
					planet_systems[planet_system.get_coords()] = planet_system
					add_child(planet_system)

				for k in range(1, i):
					var angle_deg_child = angle_deg + 120
					var angle_rad_child = PI / 180 * angle_deg_child
					var position_child = position + Vector3(width * k * cos(angle_rad_child), 0, width * k * sin(angle_rad_child))
					
					if planet_systems.size() < planet_system_count:
						var planet_system = Instancer.planet_system(position_child)
						planet_systems[planet_system.get_coords()] = planet_system
						add_child(planet_system)
	
	yield(GameState, "loading_done")

	# Set neighbors 
	for planet_system in planet_systems.values():
		for coord in Consts.PLANET_SYSTEM_DIR_ALL:
			coord += planet_system.get_coords()
			var neighbor = planet_systems.get(coord)
			if neighbor:
				planet_system.neighbors.append(neighbor)
	
	# calculate bounds
	var tiles_positions = []
	for planet_system in planet_systems.values():
		tiles_positions.append_array(planet_system.bounds)
	bounds = Geometry.convex_hull_2d(tiles_positions)
	bounds = Geometry.offset_polygon_2d(bounds, 50)[0]
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
	for point in bounds:
		st.add_vertex(Vector3(point.x, 0, point.y))
	var mesh = MeshInstance.new()
	mesh.mesh = st.commit()
	add_child(mesh)
