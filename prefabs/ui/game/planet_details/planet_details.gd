extends Control

var ship_distribution_prefab = preload('res://prefabs/ui/game/planet_details/ship_distribution/ship_distribution.tscn')
var ship_movement_prefab = preload('res://prefabs/ui/game/ship_movement/ship_movement.tscn')

onready var camera = get_node('/root/GameScene/Camera') as Camera2D
onready var selection: Entity = GameState.get_selection()

var real_camera_position: Vector2
var real_camera_zoom: Vector2

func _ready():
	_update_ui()
	MenuState.push(self)
	
	GameState.connect("update_ui", self, "_update_ui")
	selection.connect("entity_changed", self, "_update_ui")

	var viewport_size = get_viewport_rect().size
	var offset = Vector2(viewport_size[0] * 0.4, 0)
	
	real_camera_position = camera.target_position
	real_camera_zoom = camera.target_zoom
	camera.target_position = GameState.get_selection().position + offset
	camera.target_zoom = Vector2.ONE
	
	$VBoxContainer/DistributionSpectra/ColorCombat.color = Enums.ship_colors[Enums.ship_types.combat]
	$VBoxContainer/DistributionSpectra/ColorExplorer.color = Enums.ship_colors[Enums.ship_types.explorer]
	$VBoxContainer/DistributionSpectra/ColorMiner.color = Enums.ship_colors[Enums.ship_types.miner]
	$VBoxContainer/DistributionSpectra/ColorTransport.color = Enums.ship_colors[Enums.ship_types.transport]
	$VBoxContainer/DistributionSpectra/ColorRebuilding.color = Color(0.5, 0.5, 0.5, 1)
	$VBoxContainer/DistributionSpectra/ColorDisabled.color = Enums.ship_colors[Enums.ship_types.disabled]
	
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
	
	$VBoxContainer/ProgressBar.value = selection.get_process_progress()
	
	var distribution_width = $VBoxContainer/DistributionSpectra.rect_size[0]
	
	var combat = 0
	var explorer = 0
	var miner = 0
	var transport = 0
	var rebuilding = 0
	var disabled = 0
	
	for child in selection.children:
		if child.ship_type >= 0 and child.faction == 0:
			if child.state == Enums.ship_states.travel:
				continue
			
			if child.state == Enums.ship_states.rebuild:
				rebuilding += 1
				continue
			
			match(child.ship_type):
				Enums.ship_types.disabled:
					disabled += 1
				Enums.ship_types.combat:
					combat += 1
				Enums.ship_types.explorer:
					explorer += 1
				Enums.ship_types.miner:
					miner += 1
				Enums.ship_types.transport:
					transport += 1
					
	var total: float = combat + explorer + miner + transport + rebuilding + disabled
	
	$VBoxContainer/DistributionLabel/ShipCount.text = int(total) as String
	$VBoxContainer/DistributionSpectra.visible = total > 0
	
	if total == 0:
		return
	
	var combat_size = $VBoxContainer/DistributionSpectra/ColorCombat.rect_min_size
	var explorer_size = $VBoxContainer/DistributionSpectra/ColorExplorer.rect_min_size
	var miner_size = $VBoxContainer/DistributionSpectra/ColorMiner.rect_min_size
	var transport_size = $VBoxContainer/DistributionSpectra/ColorTransport.rect_min_size
	var rebuilding_size = $VBoxContainer/DistributionSpectra/ColorRebuilding.rect_min_size
	var disabled_size = $VBoxContainer/DistributionSpectra/ColorDisabled.rect_min_size
	
	combat_size[0] = (combat / total) * distribution_width
	explorer_size[0] = (explorer / total) * distribution_width
	miner_size[0] = (miner / total) * distribution_width
	transport_size[0] = (transport / total) * distribution_width
	rebuilding_size[0] = (rebuilding / total) * distribution_width
	disabled_size[0] = (disabled / total) * distribution_width
	
	$VBoxContainer/DistributionSpectra/ColorCombat.rect_min_size = combat_size
	$VBoxContainer/DistributionSpectra/ColorExplorer.rect_min_size = explorer_size
	$VBoxContainer/DistributionSpectra/ColorMiner.rect_min_size = miner_size
	$VBoxContainer/DistributionSpectra/ColorTransport.rect_min_size = transport_size
	$VBoxContainer/DistributionSpectra/ColorRebuilding.rect_min_size = rebuilding_size
	$VBoxContainer/DistributionSpectra/ColorDisabled.rect_min_size = disabled_size
	
func _create_ship(ship_type: int):
	var curr_selection = GameState.get_selection()
	selection.metal -= Consts.SHIP_COST_METAL
	curr_selection.set_entity_process(Enums.planet_states.produce, ship_type, 10)

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

func _on_ship_movement():
	get_parent().add_child(ship_movement_prefab.instance())

