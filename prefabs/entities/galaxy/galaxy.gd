extends Entity

class_name Galaxy

var planet_systems = []
var bounds = []

func create():
	.create()
	
func _ready():
	add_to_group('Persist')
	add_to_group('Galaxy')

func _generate_planet_systems():
	
	var planet_systems_dict = {}
	var planet_systems_min = Consts.GALAXY_SIZE[WorldGenerator.world_size].min
	var planet_systems_max = Consts.GALAXY_SIZE[WorldGenerator.world_size].max
	var planet_system_count = Random.randi_range(planet_systems_min, planet_systems_max)
	
	var width = Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] * sqrt(3)
	var height = Consts.GALAXY_GAP_PLANET_SYSTEMS[WorldGenerator.world_size] * 2
	
	for i in range(0, 20):
		
		if i == 0:
			planet_systems.append(Instancer.planet_system(Vector3.ZERO))
		else:
			for j in range(6):
				var angle_deg = 60 * j + 30
				var angle_rad = PI / 180 * angle_deg
				var position = Vector3(cos(angle_rad), 0, sin(angle_rad)) * width * i
				
				if planet_systems.size() < planet_system_count:
					planet_systems.append(Instancer.planet_system(position))

				for k in range(1, i):
					var angle_deg_child = angle_deg + 120
					var angle_rad_child = PI / 180 * angle_deg_child
					var position_child = position + Vector3(width * k * cos(angle_rad_child), 0, width * k * sin(angle_rad_child))
					
					if planet_systems.size() < planet_system_count:
						planet_systems.append(Instancer.planet_system(position_child))

	var tiles_positions = []
	for planet_system in planet_systems:
		for tile in planet_system.tiles:
			var position = planet_system.translation + tile.translation
			tiles_positions.append(Vector2(position.x, position.z))
			
	bounds = Geometry.convex_hull_2d(tiles_positions)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
	for point in bounds:
		st.add_vertex(Vector3(point.x, 0, point.y))
	var mesh = MeshInstance.new()
	mesh.mesh = st.commit()
	add_child(mesh)
