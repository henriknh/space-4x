extends Control

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')
var ship_movement_prefab = preload('res://prefabs/ui/game/ship_movement/ship_movement.tscn')
var planet_details_prefab = preload('res://prefabs/ui/game/planet_details/planet_details.tscn')

onready var node_asteroid_rocks: Label = $Control/TopLeft/Resources/AsteroidRocks/Value
onready var node_titanium: Label = $Control/TopLeft/Resources/Titanium/Value
onready var node_astral_dust: Label = $Control/TopLeft/Resources/AstralDust/Value
onready var node_debug: Control = $Control/Debug
onready var node_fps: Label = $Control/TopRight/MainMenu/LabelFPS
onready var node_btn_ship_movement: TextureButton = $Control/BottomLeft/Actions/BtnShipMovement
onready var node_btn_planet_details: TextureButton = $Control/BottomRight/Info/BtnPlanetDetails
onready var node_ship_distribution: Control = $ShipDistribution

func _ready():
	MenuState.push(self)

func init():
	#GameState.connect("state_changed", self, "_update_ui")
	GameState.connect("selection_changed", self, "_update_ui")
	Settings.connect("settings_changed", self, "_update_ui")
	
	var timer = Timer.new()
	timer.connect("timeout",self,"_update_ui")
	add_child(timer)
	timer.wait_time = 0.1
	timer.start()
	
	node_debug.init()
	_update_ui()
	
func _physics_process(delta):
	node_fps.text = Engine.get_frames_per_second() as String

func _ship_movement_disabled() -> bool:
	if GameState.get_selection() == null:
		return true
	elif GameState.get_selection().corporation_id == null:
		return true
	else:
		for child in GameState.get_selection().children:
			if child.entity_type == Enums.entity_types.ship and child.corporation_id == Consts.PLAYER_CORPORATION:
				return false
		return true

func _update_ui():
	node_fps.visible = Settings.get_show_fps()
	node_btn_ship_movement.disabled = _ship_movement_disabled()
	node_btn_planet_details.disabled = GameState.get_selection() == null
	
	var corporation = Corporations.get_corporation(Consts.PLAYER_CORPORATION)
	if corporation:
		node_asteroid_rocks.text = Utils.format_number(corporation.resources.asteroid_rocks)
		node_titanium.text = Utils.format_number(corporation.resources.titanium)
		node_astral_dust.text = Utils.format_number(corporation.resources.astral_dust)
	
	node_ship_distribution.update_distribution_globally()

func _on_game_menu():
	get_parent().add_child(game_menu_prefab.instance())

func _on_go_to_galaxy():
	GameState.set_planet_system(-1)

func _on_planet_details():
	get_parent().add_child(planet_details_prefab.instance())

func _on_ship_movement():
	get_parent().add_child(ship_movement_prefab.instance())

func _on_mouse_entered_ui():
	MenuState.set_over_ui(true)

func _on_mouse_exited_ui():
	MenuState.set_over_ui(false)
