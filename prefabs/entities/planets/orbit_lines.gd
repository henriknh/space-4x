extends Node2D

func _draw():
	var orbit_distances = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		var orbit_distance = planet.planet_orbit_distance
		if planet.planet_system == State.get_planet_system() and not orbit_distances.has(orbit_distance):
			orbit_distances.push_back(orbit_distance)
			draw_arc(Vector2.ZERO, orbit_distance, 0, 2 * PI, 200, Color(1, 1, 1, 0.05))
