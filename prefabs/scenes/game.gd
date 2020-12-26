extends Node2D

var game_menu = preload('res://prefabs/ui/game_menu/game_menu.tscn')

class_name game

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		add_child(game_menu.instance())
	
func _ready():
	pass # Replace with function body.
	
func init():
	redraw()
	
func redraw():
	
	
	
	for planet in get_tree().get_nodes_in_group('Planet'):
		planet.update()
		if planet.planet_system == State.curr_planet_system:
			planet.ready()
	$OrbitLines.update()
	$VoronoiCells.update()
	
	
