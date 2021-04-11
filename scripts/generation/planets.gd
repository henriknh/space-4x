extends Node

const GenUtils = preload('res://scripts/generation/utils.gd')

func generate(count: int, planet_system_idx: int, tree: SceneTree) -> Array:
	
	var orbits_min = Consts.PLANET_SYSTEM_ORBITS[WorldGenerator.world_size].min
	var orbits_max = Consts.PLANET_SYSTEM_ORBITS[WorldGenerator.world_size].max
	var total_orbits = int(Random.randi_range(orbits_min, orbits_max))
		
	var orbit_diff = (Consts.PLANET_SYSTEM_RADIUS / total_orbits) * 0.2
	var quadrants = {
		0: 0,
		1: 0,
		2: 0,
		3: 0
	}
	
	var planet_system = []
	for orbit in range(total_orbits):
		var smallest_quadrant = GenUtils.get_least_dense_quadrant(quadrants)
		var angle = Random.randf() * PI / 2 + smallest_quadrant * PI / 2
		var orbit_distance = Consts.PLANET_SYSTEM_BASE_DISTANCE_TO_SUN + (Consts.PLANET_SYSTEM_RADIUS / total_orbits) * (orbit + 1) + Random.randi_range(-orbit_diff, orbit_diff)
	
		var position = Vector2(orbit_distance * sin(angle), orbit_distance * cos(angle))
		planet_system.append({
			'position': position,
			'orbit': orbit
		})
	
	var voronoi = VoronoiRegistry.register_voronoi(planet_system_idx, planet_system)
	
	var planets = []
	for planet in planet_system:
		var planet_type = GenUtils.calc_planet_type(planet.orbit, total_orbits)
		var convex_hull = voronoi.site_registry.get_convex_hull_of_node(planet)
		planets.append(Instancer.planet(planet_type, planet.position, convex_hull, planet_system_idx))
	return planets
