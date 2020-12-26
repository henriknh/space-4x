extends Node2D

class_name game
	
func _ready():
	pass # Replace with function body.
	
func init():
	MenuState.reset()
	Nav.create_network()
	redraw()
	
func redraw():
	for planet in get_tree().get_nodes_in_group('Planet'):
		planet.update()
		if planet.planet_system == GameState.get_planet_system():
			planet.ready()
	$OrbitLines.update()
	$VoronoiCells.update()
	
	
