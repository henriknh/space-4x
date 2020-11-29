extends Node2D

var Voronoi = load("res://scripts/voronoi.gd").new();
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var planets = get_tree().get_nodes_in_group("Planet")
	var planet = planets[0]
	draw_circle(planet.position, 200, Color(0, 1,0))
	for planet_ in planets.slice(1, planets.size()):
		if planet_.get_star_system() == State.get_star_system() and planet != planet_:
			var pos = planet.position + (planet_.position - planet.position) / 2
			draw_circle(pos, 2, Color(1, 0,0))
