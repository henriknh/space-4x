extends Node2D

class_name game

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')

func init():
	Nav.create_network()
	redraw()
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		if MenuState.menus_size() == 1:
			$CanvasLayer.add_child(game_menu_prefab.instance())
		else:
			MenuState.pop()
	
func redraw():
	for planet in get_tree().get_nodes_in_group('Planet'):
		planet.update()
		if planet.planet_system == GameState.get_planet_system():
			planet.update()
	
	self.update()
	$OrbitLines.update()
	$VoronoiSites.update()
