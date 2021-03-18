extends Node2D

var orbit_distances = []

func _connect_changed_signals():
	Settings.connect("settings_changed", self, "_on_changed")
	GameState.connect("state_changed", self, "_on_changed")

func _on_changed():
	orbit_distances = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		var orbit_distance = planet.position.distance_to(Vector2.ZERO)
		if planet.planet_system == GameState.get_planet_system() and not orbit_distances.has(orbit_distance):
			orbit_distances.append(orbit_distance)
	update()

func _draw():
	if Settings.get_show_orbit_circles():
		for orbit_distance in orbit_distances:
			draw_arc(Vector2.ZERO, orbit_distance, 0, 2 * PI, 90, Color(1, 1, 1, 0.025), 1, true)
