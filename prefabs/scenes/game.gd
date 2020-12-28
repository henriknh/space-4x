extends Node2D

class_name game
	
func _ready():
	Settings.connect("settings_changed", self, "update")
	
func init():
	MenuState.reset()
	Nav.create_network()
	redraw()
	
func redraw():
	for planet in get_tree().get_nodes_in_group('Planet'):
		planet.update()
		if planet.planet_system == GameState.get_planet_system():
			planet.ready()
			
	self.update()
	$OrbitLines.update()
	$VoronoiCells.update()
		
func _draw():
	if Settings.get_is_debug():
		for segment in Nav.debug:
			draw_line(segment[0], segment[1], Color(1,0,0,1), 1, true)
	
