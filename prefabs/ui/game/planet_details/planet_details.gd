extends Control

var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_combat = load(Enums.ship_scripts.combat)
var script_explorer = load(Enums.ship_scripts.explorer)
var script_miner = load(Enums.ship_scripts.miner)
var script_transport = load(Enums.ship_scripts.transport)

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

var real_camera_position: Vector2
var real_camera_zoom: float

func _ready():
	update_ui()
	MenuState.push(self)

	var viewport_size = get_viewport_rect().size
	var offset = Vector2(viewport_size.x * 0.4, 0)
	
	real_camera_position = camera.target_position
	real_camera_zoom = camera.target_zoom
	camera.target_position = GameState.get_selection().position + offset
	camera.target_zoom = 1
	
func queue_free():
	camera.target_position = real_camera_position
	camera.target_zoom = real_camera_zoom
	.queue_free()
	
func _on_close():
	MenuState.pop()

func update_ui():
	var selection: entity = GameState.get_selection()
	$VBoxContainer/Info/LabelSelection.text = selection.label
	
	$VBoxContainer/Resources1/LabelMetal.text = selection.metal as String
	$VBoxContainer/Resources1/LabelPower.text = selection.power as String
	$VBoxContainer/Resources2/LabelFood.text = selection.food as String
	$VBoxContainer/Resources2/LabelWater.text = selection.water as String

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
	instance.create()

	get_node('/root/GameScene').add_child(instance)
