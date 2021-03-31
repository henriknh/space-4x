extends Node

static func get_start_planet(planets: Array, is_human: bool) -> Entity:
	var possible_planets = []
	for planet in planets:
		if (is_human and planet.planet_system == 0 or not is_human) and planet.corporation_id == 0:
			possible_planets.append(planet)
	
	return possible_planets[Random.randi() % possible_planets.size()]
	
static func calc_planet_type(orbit: int, total_orbits: int) -> int:
	var r = Random.randf()
	var odds_sum = 0

	if float(orbit) / total_orbits < 0.25:
		if r < 0.8:
			return Enums.planet_types.lava
		else:
			return Enums.planet_types.iron
	elif float(orbit) / total_orbits < 0.5:
		if r < 0.2:
			return Enums.planet_types.lava
		elif r < 0.8:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.earth

	elif float(orbit) / total_orbits < 0.75:
		if r < 0.4:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.earth

	else:
		if r < 0.4:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.ice


	return -1

static func get_least_dense_quadrant(quadrants: Dictionary) -> int:
	var smallest_quadrant = 0
	var smallest_value = quadrants[smallest_quadrant]

	if quadrants[1] < smallest_value:
		smallest_quadrant = 1
		smallest_value = quadrants[smallest_quadrant]
	if quadrants[2] < smallest_value:
		smallest_quadrant = 2
		smallest_value = quadrants[smallest_quadrant]
	if quadrants[3] < smallest_value:
		smallest_quadrant = 3
		smallest_value = quadrants[smallest_quadrant]

	quadrants[smallest_quadrant] = quadrants[smallest_quadrant] + 1

	return smallest_quadrant
