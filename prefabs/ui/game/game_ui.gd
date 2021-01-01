extends Control

var planet_details_prefab = preload('res://prefabs/ui/game/planet_details/planet_details.tscn')
var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')

var total_metal: int = 0
var total_power: int = 0
var total_food: int = 0
var total_water: int = 0

func _ready():
	MenuState.push(self)
	
	GameState.connect("selection_changed", self, "_update_ui")
	Settings.connect("settings_changed", self, "_update_ui")

	var timer = Timer.new()
	timer.connect("timeout",self,"_update_ui")
	timer.wait_time = 1
	add_child(timer)
	timer.start()

func _physics_process(delta):
	$MainMenu/LabelFPS.text = '%d' % Engine.get_frames_per_second()
	
func _update_ui():
	
	$MainMenu/LabelFPS.visible = Settings.get_show_fps()
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
		if planet.planet_system == GameState.get_planet_system():
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
