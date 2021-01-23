extends Control

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')
var ship_movement_prefab = preload('res://prefabs/ui/game/ship_movement/ship_movement.tscn')
var planet_details_prefab = preload('res://prefabs/ui/game/planet_details/planet_details.tscn')

var total_metal: int = 0
var total_power: int = 0
var total_food: int = 0
var total_water: int = 0

func _ready():
	MenuState.push(self)
	
	GameState.connect("state_changed", self, "_update_ui")
	GameState.connect("selection_changed", self, "_update_ui")
	Settings.connect("settings_changed", self, "_update_ui")

	var timer = Timer.new()
	timer.connect("timeout",self,"_update_ui")
	timer.wait_time = 1
	add_child(timer)
	timer.start()

func _physics_process(delta):
	var mouse_pos = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport().get_mouse_position())
	$Debug/LabelMousePos.text = mouse_pos as String
	$MainMenu/LabelFPS.text = Engine.get_frames_per_second() as String

func _ship_movement_disabled() -> bool:
	if GameState.get_selection() == null:
		return true
	elif GameState.get_selection().get('faction') == null:
		return true
	else:
		for child in GameState.get_selection().children:
			if child.entity_type == Enums.entity_types.ship and child.faction == 0:
				return false
		return true
		
func _update_ui():
	
	$Debug/LabelMousePos.visible = Settings.is_debug()
	$MainMenu/LabelFPS.visible = Settings.get_show_fps()
	$Bottom/BtnShipMovement.disabled = _ship_movement_disabled()
	$Bottom/BtnPlanetDetails.disabled = GameState.get_selection() == null
	
	_update_resources()
	$Resources/LabelMetal.text = Utils.format_number(total_metal)
	$Resources/LabelPower.text = Utils.format_number(total_power)
	$Resources/LabelFood.text = Utils.format_number(total_food)
	$Resources/LabelWater.text = Utils.format_number(total_water)
		
func _update_resources():
	total_metal = 0
	total_power = 0
	total_food = 0
	total_water = 0
	
	var planets = get_tree().get_nodes_in_group("Planet")
	
	for planet in planets:
		if planet.faction == 0 and (GameState.get_planet_system() == -1 or GameState.get_planet_system() == planet.planet_system):
			total_metal += planet.metal
			total_power += planet.power
			total_food += planet.food
			total_water += planet.water

func _on_game_menu():
	get_parent().add_child(game_menu_prefab.instance())

func _on_go_to_galaxy():
	GameState.set_planet_system(-1)

func _on_overview():
	print('TODO: Implement planet system overview')

func _on_planet_details():
	get_parent().add_child(planet_details_prefab.instance())

func _on_ship_movement():
	pass # Replace with function body.
	get_parent().add_child(ship_movement_prefab.instance())
