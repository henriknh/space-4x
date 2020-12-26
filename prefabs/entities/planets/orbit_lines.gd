extends Node2D

func _ready():
	Settings.connect("settings_changed", self, "update")
	
func _draw():
	if Settings.get_show_orbit_circles():
		var orbit_distances = []
		for planet in get_tree().get_nodes_in_group('Planet'):
			var orbit_distance = planet.planet_orbit_distance
			if planet.planet_system == State.get_planet_system() and not orbit_distances.has(orbit_distance):
				orbit_distances.push_back(orbit_distance)
				draw_arc(Vector2.ZERO, orbit_distance, 0, 2 * PI, 90, Color(1, 1, 1, 0.025), 1, true)
