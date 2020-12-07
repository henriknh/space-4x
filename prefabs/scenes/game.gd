extends Node2D

func _ready():
	pass # Replace with function body.

func _draw():
	var planets = get_tree().get_nodes_in_group("Planet")
	var planet = planets[0]
	draw_circle(planet.position, 200, Color(0, 1,0))
	for planet_ in planets.slice(1, planets.size()):
		if planet_.planet_system == State.get_planet_system() and planet != planet_:
			var pos = planet.position + (planet_.position - planet.position) / 2
			draw_circle(pos, 2, Color(1, 0,0))
