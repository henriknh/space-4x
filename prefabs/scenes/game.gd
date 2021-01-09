extends Node2D

class_name game

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')
var font
onready var camera = get_node('/root/GameScene/Camera') as Camera2D
func _ready():
	font = DynamicFont.new()
	font.font_data = load("res://assets/fonts/kenny-rocket/Kenney Rocket Square.ttf")
	Settings.connect("settings_changed", self, "update")
	
func init():
	Nav.create_network()
	redraw()
	
	
func _input(event):
	if Settings.get_is_debug() and event is InputEventMouseMotion:
		update()
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		if MenuState.menus_size() == 1:
			$CanvasLayer.add_child(game_menu_prefab.instance())
		else:
			MenuState.pop()
	
func redraw():
	for planet in get_tree().get_nodes_in_group('Planet'):
		planet.update()
		if planet.planet_system == GameState.get_planet_system():
			planet.ready()
	
	self.update()
	$OrbitLines.update()
	$VoronoiSites.update()
		
func _draw():
	if Settings.get_is_debug():
		font.size = camera.zoom.x * 20
		draw_string(font, get_global_mouse_position(), get_global_mouse_position() as String)
		
		for segment in Nav.debug:
			draw_line(segment[0], segment[1], Color(1,0,0,1), 1, true)
	
