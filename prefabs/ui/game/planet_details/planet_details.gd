extends Control

var ship_distribution_prefab = preload('res://prefabs/ui/game/planet_details/ship_distribution/ship_distribution.tscn')

var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_combat = load(Enums.ship_scripts.combat)
var script_explorer = load(Enums.ship_scripts.explorer)
var script_miner = load(Enums.ship_scripts.miner)
var script_transport = load(Enums.ship_scripts.transport)

onready var camera = get_node('/root/GameScene/Camera') as Camera2D
onready var selection: entity = GameState.get_selection()

var real_camera_position: Vector2
var real_camera_zoom: Vector2

func _ready():
	_update_ui()
	MenuState.push(self)
	
	selection.connect("entity_changed", self, "_update_ui")

	var viewport_size = get_viewport_rect().size
	var offset = Vector2(viewport_size[0] * 0.4, 0)
	
	real_camera_position = camera.target_position
	real_camera_zoom = camera.target_zoom
	camera.target_position = GameState.get_selection().position + offset
	camera.target_zoom = Vector2.ONE
	
func queue_free():
	camera.target_position = real_camera_position
	camera.target_zoom = real_camera_zoom
	.queue_free()
	
func _on_close():
	MenuState.pop()

func _update_ui():
	$VBoxContainer/Info/LabelSelection.text = selection.label
	
	$VBoxContainer/Resources1/LabelMetal.text = Utils.format_number(selection.metal)
	$VBoxContainer/Resources1/LabelPower.text = Utils.format_number(selection.power)
	$VBoxContainer/Resources2/LabelFood.text = Utils.format_number(selection.food)
	$VBoxContainer/Resources2/LabelWater.text = Utils.format_number(selection.water)
	
	var distribution_width = $VBoxContainer/DistributionSpectra.rect_size[0]
	
	var unallocated = 0
	var combat = 0
	var explorer = 0
	var miner = 0
	var transport = 0
	
	for child in selection.children:
		if child.ship_type >= 0 and child.faction == 0:
			if child.state == Enums.ship_states.travel:
				continue
			
			match(child.ship_type):
				Enums.ship_types.disabled:
					unallocated += 1
				Enums.ship_types.combat:
					combat += 1
				Enums.ship_types.explorer:
					explorer += 1
				Enums.ship_types.miner:
					miner += 1
				Enums.ship_types.transport:
					transport += 1
					
	var total: float = unallocated + combat + explorer + miner + transport
	
	$VBoxContainer/DistributionLabel/ShipCount.text = int(total) as String
	$VBoxContainer/DistributionSpectra.visible = total > 0
	
	var combat_size = $VBoxContainer/DistributionSpectra/ColorCombat.rect_min_size
	var explorer_size = $VBoxContainer/DistributionSpectra/ColorExplorer.rect_min_size
	var miner_size = $VBoxContainer/DistributionSpectra/ColorMiner.rect_min_size
	var transport_size = $VBoxContainer/DistributionSpectra/ColorTransport.rect_min_size
	
	if total > 0:
		combat_size[0] = (combat / total) * distribution_width
		explorer_size[0] = (explorer / total) * distribution_width
		miner_size[0] = (miner / total) * distribution_width
		transport_size[0] = (transport / total) * distribution_width
	else:
		combat_size[0] = 0
		explorer_size[0] = 0
		miner_size[0] = 0
		transport_size[0] = 0
		
	$VBoxContainer/DistributionSpectra/ColorCombat.rect_min_size = combat_size
	$VBoxContainer/DistributionSpectra/ColorExplorer.rect_min_size = explorer_size
	$VBoxContainer/DistributionSpectra/ColorMiner.rect_min_size = miner_size
	$VBoxContainer/DistributionSpectra/ColorTransport.rect_min_size = transport_size
	
func _create_ship(ship_type: int):

	var curr_selection = GameState.get_selection()
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
	instance.parent = curr_selection
	instance.create()

	get_node('/root/GameScene').add_child(instance)

func _on_production_ship():
	var menu = $VBoxContainer/Production/BtnShip.get_popup()
	menu.clear()
	menu.add_item('Combat', Enums.ship_types.combat)
	menu.add_item('Explorer', Enums.ship_types.explorer)
	menu.add_item('Miner', Enums.ship_types.miner)
	menu.add_item('Transpprt', Enums.ship_types.transport)
	menu.connect("id_pressed", self, "_create_ship")
	
	menu.popup()

func _on_ship_distribution_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_parent().add_child(ship_distribution_prefab.instance())
