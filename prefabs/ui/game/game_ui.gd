extends Control

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')
var ship_movement_prefab = preload('res://prefabs/ui/game/ship_movement/ship_movement.tscn')

onready var node_asteroid_rocks: Label = $Control/TopLeft/Resources/AsteroidRocks/Value
onready var node_titanium: Label = $Control/TopLeft/Resources/Titanium/Value
onready var node_astral_dust: Label = $Control/TopLeft/Resources/AstralDust/Value
onready var node_debug: Control = $Control/Debug
onready var node_fps: Label = $Control/TopRight/MainMenu/LabelFPS
onready var node_btn_ship_movement: TextureButton = $Control/BottomLeft/Actions/BtnShipMovement
onready var node_distribution: Control = $Distribution

var _old_selection: Entity

func _ready():
	MenuState.push(self)

func init():
	var player_corporation = Corporations.get_corporation(Consts.PLAYER_CORPORATION)
	player_corporation.connect("corporation_changed", self, "_update_ui")
	GameState.connect("selection_changed", self, "_selection_changed")
	Settings.connect("settings_changed", self, "_update_ui")
	
	if node_debug:
		node_debug.init()
	
	_update_ui()
	
func _selection_changed():
	if _old_selection:
		_old_selection.disconnect("entity_changed", self, "_update_ui")
	
	var selection = GameState.get_selection()
	if selection:
		selection.connect("entity_changed", self, "_update_ui")
		
	_old_selection = selection
	_update_ui()
	
	
func _physics_process(delta):
	node_fps.text = Engine.get_frames_per_second() as String

func _ship_movement_disabled() -> bool:
	if GameState.get_selection() == null:
		return true
	elif GameState.get_selection().corporation_id == null:
		return true
	else:
		for ship in GameState.get_selection().ships:
			if ship.corporation_id == Consts.PLAYER_CORPORATION:
				return false
		return true

func _update_ui():
	node_fps.visible = Settings.get_show_fps()
	node_btn_ship_movement.disabled = _ship_movement_disabled()
	
	var corporation = Corporations.get_corporation(Consts.PLAYER_CORPORATION)
	if corporation:
		node_asteroid_rocks.text = Utils.format_number(corporation.asteroid_rocks)
		node_titanium.text = Utils.format_number(corporation.titanium)
		node_astral_dust.text = Utils.format_number(corporation.astral_dust)
	
	var selection = GameState.get_selection()
	var has_player_ships = false
	if selection:
		for ship in selection.ships:
			if ship.corporation_id == Consts.PLAYER_CORPORATION:
				has_player_ships = true
				break
	
	if has_player_ships:
		node_distribution.update_distribution_by_selection(GameState.get_selection())
	else:
		node_distribution.update_distribution_globally()

func _on_game_menu():
	get_parent().add_child(game_menu_prefab.instance())

func _on_ship_movement():
	get_parent().add_child(ship_movement_prefab.instance())

func _on_mouse_entered_ui():
	MenuState.set_over_ui(true)

func _on_mouse_exited_ui():
	MenuState.set_over_ui(false)
