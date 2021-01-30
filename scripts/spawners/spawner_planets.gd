extends Node2D

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

func create(gameScene: Node, planet_system_idx: int) -> void:
	
	var quadrants = {
		0: 0,
		1: 0,
		2: 0,
		3: 0
	}
	var orbits_min = Consts.planet_system_orbits[WorldGenerator.world_size].min
	var orbits_max = Consts.planet_system_orbits[WorldGenerator.world_size].max
	var total_orbits = int(WorldGenerator.rng.randi_range(orbits_min, orbits_max))
	var orbit_diff = (Consts.planet_system_radius / total_orbits) * 0.2

	for orbit in range(total_orbits):

		var smallest_quadrant = _get_least_dense_quadrant(quadrants)
		var angle = WorldGenerator.rng.randf() * PI / 2 + smallest_quadrant * PI / 2
		var orbit_distance = Consts.planet_system_base_distance_to_sun + (Consts.planet_system_radius / total_orbits) * (orbit + 1) + WorldGenerator.rng.randi_range(-orbit_diff, orbit_diff)
		
		var position = Vector2(orbit_distance * sin(angle), orbit_distance * cos(angle))
		var planet_type = _calc_planet_type(orbit, total_orbits)
		

