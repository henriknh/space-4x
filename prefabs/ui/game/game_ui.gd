extends Control

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')
var ship_movement_prefab = preload('res://prefabs/ui/game/ship_movement/ship_movement.tscn')
var planet_details_prefab = preload('res://prefabs/ui/game/planet_details/planet_details.tscn')

onready var node_asteroid_rocks = $Resources/ValueAsteroidRocks as Label
onready var node_titanium = $Resources/ValueTitanium as Label
onready var node_astral_dust = $Resources/ValueAstralDust as Label


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
	
	var faction = Factions.get_faction(0)
	if faction:
		node_asteroid_rocks.text = Utils.format_number(faction.resources.asteroid_rocks)
		node_titanium.text = Utils.format_number(faction.resources.titanium)
		node_astral_dust.text = Utils.format_number(faction.resources.astral_dust)

func _on_game_menu():
	get_parent().add_child(game_menu_prefab.instance())

func _on_go_to_galaxy():
	GameState.set_planet_system(-1)

func _on_planet_details():
	get_parent().add_child(planet_details_prefab.instance())

func _on_ship_movement():
	get_parent().add_child(ship_movement_prefab.instance())


func _on_mouse_entered_background():
	MenuState.set_over_ui(false)


func _on_mouse_exited_background():
	MenuState.set_over_ui(true)
