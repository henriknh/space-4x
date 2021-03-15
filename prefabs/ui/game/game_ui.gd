extends Control

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')
var ship_movement_prefab = preload('res://prefabs/ui/game/ship_movement/ship_movement.tscn')
var planet_details_prefab = preload('res://prefabs/ui/game/planet_details/planet_details.tscn')

onready var node_asteroid_rocks = $TopLeft/Resources/AsteroidRocks/Value as Label
onready var node_titanium = $TopLeft/Resources/Titanium/Value as Label
onready var node_astral_dust = $TopLeft/Resources/AstralDust/Value as Label
onready var node_debug = $Debug as Control
onready var node_fps = $TopRight/MainMenu/LabelFPS as Label
onready var node_btn_ship_movement = $BottomLeft/Actions/BtnShipMovement as TextureButton
onready var node_btn_planet_details = $BottomRight/Info/BtnPlanetDetails as TextureButton

func _ready():
	MenuState.push(self)
	

func ready():
	#GameState.connect("state_changed", self, "_update_ui")
	GameState.connect("selection_changed", self, "_update_ui")
	Settings.connect("settings_changed", self, "_update_ui")
	
	var timer = Timer.new()
	timer.connect("timeout",self,"_update_ui")
	add_child(timer)
	timer.wait_time = 1
	timer.start()
	
	node_debug.ready()
	_update_ui()
	
func _physics_process(delta):
	node_fps.text = Engine.get_frames_per_second() as String

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
	node_debug.visible = Settings.is_debug()
	if Settings.is_debug():
		node_debug._update_ui()
	node_fps.visible = Settings.get_show_fps()
	node_btn_ship_movement.disabled = _ship_movement_disabled()
	node_btn_planet_details.disabled = GameState.get_selection() == null
	
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

func _on_mouse_entered_ui():
	MenuState.set_over_ui(true)

func _on_mouse_exited_ui():
	MenuState.set_over_ui(false)
