extends Control

var planet_change_distribution_prefab = preload('res://prefabs/ui/game/planet_details/planet_change_distribution/planet_change_distribution.tscn')
var ship_movement_prefab = preload('res://prefabs/ui/game/ship_movement/ship_movement.tscn')

onready var camera = get_node('/root/GameScene/Camera') as Camera2D
onready var selection: Entity = GameState.get_selection()
onready var corporation = Corporations.get_corporation(selection.corporation_id)

onready var node_ship_distribution: Control = $VBoxContainer/ShipDistribution
onready var node_convert_from_amount: Label = $VBoxContainer/Convertion/ConvertFromAmount
onready var node_convert_to_amount: Label = $VBoxContainer/Convertion/ConvertToAmount
onready var node_convert_to_titanium: TextureButton = $VBoxContainer/Convertion/ConvertToTitanium
onready var node_convert_to_astral_dust: TextureButton = $VBoxContainer/Convertion/ConvertToAstralDust

onready var node_debug_current_process: Label = $VBoxContainer/DebugCurrentProduction

var real_camera_position: Vector2
var real_camera_zoom: Vector2

func _ready():
	MenuState.push(self)
	
	GameState.connect("update_ui", self, "_update_ui")
	Settings.connect("settings_changed", self, "_update_ui")
	selection.connect("entity_changed", self, "_update_ui")

	var viewport_size = get_viewport_rect().size
	var offset = Vector2(viewport_size[0] * 0.4, 0)
	
	real_camera_position = camera.position
	real_camera_zoom = camera.zoom
	camera.position = GameState.get_selection().position + offset
	camera.zoom = Vector2.ONE
	
	node_convert_to_titanium.connect("pressed", self, "_convert_resource", [ Enums.resource_types.titanium])
	node_convert_to_astral_dust.connect("pressed", self, "_convert_resource", [ Enums.resource_types.astral_dust])

	node_ship_distribution.update_distribution_by_selection(selection)
	selection.connect("entity_changed", node_ship_distribution, "update_distribution_by_selection", [selection])
	
	_update_ui()
	
func queue_free():
	camera.position = real_camera_position
	camera.zoom = real_camera_zoom
	.queue_free()
	
func _on_close():
	MenuState.pop()

func _update_ui():
	
	# Enable/disable actions
	var busy = selection.state != Enums.planet_states.idle
	var cant_convert = true
	var cant_produce_ship = true
	var cant_produce_research = true

	if corporation:
		cant_convert = corporation.asteroid_rocks < Consts.RESOURCE_CONVERTION_COST
		cant_produce_ship = corporation.titanium < Consts.SHIP_COST_TITANIUM
		cant_produce_research = corporation.astral_dust < Consts.RESEARCH_COST_ASTRAL_DUST
	
	node_convert_to_titanium.disabled = busy or cant_convert
	node_convert_to_astral_dust.disabled = busy or cant_convert
	$VBoxContainer/Production/BtnShip.disabled = busy or cant_produce_ship
	$VBoxContainer/Production/BtnResearch.disabled = busy or cant_produce_research
	
	# Update progress bar
	$VBoxContainer/ProgressBar.value = selection.get_process_progress()
	
	# Set convertion values
	node_convert_from_amount.text = Consts.RESOURCE_CONVERTION_COST as String
	node_convert_to_amount.text = (Consts.RESOURCE_CONVERTION_COST * Consts.RESOURCE_CONVERTION_RATIO) as String
	
	# If debug, set current process number
	node_debug_current_process.visible = Settings.is_debug()
	node_debug_current_process.text = selection.process_target as String
	
	$VBoxContainer/DistributionLabel/ShipCount.text = int(0) as String
	
func _create_ship(ship_type: int):
	if corporation.titanium >= Consts.SHIP_COST_TITANIUM:
		corporation.titanium -= Consts.SHIP_COST_TITANIUM
		selection.set_entity_process(Enums.planet_states.produce, ship_type, Consts.SHIP_PRODUCTION_TIME)

func _on_production_ship():
	var menu = $VBoxContainer/Production/BtnShip.get_popup()
	menu.clear()
	menu.add_item('Combat', Enums.ship_types.combat)
	menu.add_item('Explorer', Enums.ship_types.explorer)
	menu.add_item('Miner', Enums.ship_types.miner)
	menu.connect("id_pressed", self, "_create_ship")
	
	menu.popup()

func _on_planet_change_distribution_input(event):
	if event is InputEventMouseButton and event.pressed:
		if selection.planet_disabled_ships > 0 or selection.ships.size() > 0:
			get_parent().add_child(planet_change_distribution_prefab.instance())

func _on_ship_movement():
	get_parent().add_child(ship_movement_prefab.instance())

func _convert_resource(convertion_resource: int):
	if corporation.asteroid_rocks >= Consts.RESOURCE_CONVERTION_COST:
		corporation.asteroid_rocks -= Consts.RESOURCE_CONVERTION_COST
		selection.set_entity_process(Enums.planet_states.convertion, convertion_resource, Consts.RESOURCE_CONVERTION_TIME)
