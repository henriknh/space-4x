extends VBoxContainer

var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_combat = load(Enums.ship_scripts.combat)
var script_explorer = load(Enums.ship_scripts.explorer)
var script_miner = load(Enums.ship_scripts.miner)
var script_transport = load(Enums.ship_scripts.transport)

onready var menu: PopupMenu = PopupMenu.new()

func _ready():
	_update_ui()
	
	GameState.connect("selection_changed", self, "_update_ui")
	
	menu.add_item("Combat", Enums.ship_types.combat)
	menu.add_item("Explorer", Enums.ship_types.explorer)
	menu.add_item("Miner", Enums.ship_types.miner)
	menu.add_item("Transport", Enums.ship_types.transport)
	menu.connect("id_pressed", self, "_create_ship")
	add_child(menu)

func _update_ui():
	$BtnCreateShip.disabled = GameState.get_selection().size() == 0
	
func _on_create_ship():
	menu.popup()

func _create_ship(ship_type: int):

	var curr_selection = GameState.get_selection()[0]
	var instance = prefab_ship.instance()
		
	match ship_type:
		Enums.ship_types.combat:
			instance.set_script(script_combat)
		Enums.ship_types.explorer:
			instance.set_script(script_explorer)
		Enums.ship_types.miner:
			instance.set_script(script_miner)
		Enums.ship_types.transport:
			instance.set_script(script_transport)
	
	instance.planet_system = curr_selection.planet_system
	instance.faction = curr_selection.faction
	instance.position = curr_selection.position
	instance.create()

	get_node('/root/GameScene').add_child(instance)

func _physics_process(delta):
	$LabelFps.text = 'FPS: %d' % Engine.get_frames_per_second()
