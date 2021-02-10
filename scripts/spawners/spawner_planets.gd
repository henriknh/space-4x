extends Node2D

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

func create(gameScene: Node, planet_system_idx: int) -> void:
	
	var quadrants = {
		0: 0,
		1: 0,
		2: 0,
		3: 0
	}
	var orbits_min = Consts.PLANET_SYSTEM_ORBITS[WorldGenerator.world_size].min
	var orbits_max = Consts.PLANET_SYSTEM_ORBITS[WorldGenerator.world_size].max
	var total_orbits = int(WorldGenerator.rng.randi_range(orbits_min, orbits_max))
	var orbit_diff = (Consts.PLANET_SYSTEM_RADIUS / total_orbits) * 0.2

	for orbit in range(total_orbits):

		var smallest_quadrant = _get_least_dense_quadrant(quadrants)
		var angle = WorldGenerator.rng.randf() * PI / 2 + smallest_quadrant * PI / 2
		var orbit_distance = Consts.PLANET_SYSTEM_BASE_DISTANCE_TO_SUN + (Consts.PLANET_SYSTEM_RADIUS / total_orbits) * (orbit + 1) + WorldGenerator.rng.randi_range(-orbit_diff, orbit_diff)
		
		var position = Vector2(orbit_distance * sin(angle), orbit_distance * cos(angle))
		var planet_type = _calc_planet_type(orbit, total_orbits)
		

