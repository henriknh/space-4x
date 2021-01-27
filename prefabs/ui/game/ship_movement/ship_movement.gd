extends Control

var movement_target_prefab = preload('res://prefabs/ui/game/ship_movement/movement_target.tscn')

onready var move_selection = {
	'origin_planet': null,
	Enums.ship_types.combat: {
		'selected': 0,
		'total': 0
	},
	Enums.ship_types.explorer: {
		'selected': 0,
		'total': 0
	},
	Enums.ship_types.miner: {
		'selected': 0,
		'total': 0
	},
	Enums.ship_types.transport: {
		'selected': 0,
		'total': 0
	},
}

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

var real_camera_position: Vector2
var real_camera_zoom: Vector2

func _ready():
	MenuState.push(self)
	
	GameState.get_selection().connect("entity_changed", self, "_update_ui")

	var viewport_size = get_viewport_rect().size
	var offset = Vector2(-viewport_size.x / 2, -viewport_size.y / 2)
	
	real_camera_position = camera.target_position
	real_camera_zoom = camera.target_zoom
	camera.target_position = GameState.get_selection().position + offset
	camera.target_zoom = Vector2.ONE * 10
	
	$Changes/Combat/BtnDecrease.connect("pressed", self, "_on_change", [ Enums.ship_types.combat, -1])
	$Changes/Combat/BtnIncrease.connect("pressed", self, "_on_change", [ Enums.ship_types.combat, 1])
	$Changes/Explorer/BtnDecrease.connect("pressed", self, "_on_change", [ Enums.ship_types.explorer, -1])
	$Changes/Explorer/BtnIncrease.connect("pressed", self, "_on_change", [ Enums.ship_types.explorer, 1])
	$Changes/Miner/BtnDecrease.connect("pressed", self, "_on_change", [ Enums.ship_types.miner, -1])
	$Changes/Miner/BtnIncrease.connect("pressed", self, "_on_change", [ Enums.ship_types.miner, 1])
	$Changes/Transport/BtnDecrease.connect("pressed", self, "_on_change", [ Enums.ship_types.transport, -1])
	$Changes/Transport/BtnIncrease.connect("pressed", self, "_on_change", [ Enums.ship_types.transport, 1])
	
	_update_ui()
	
func queue_free():
	camera.target_position = real_camera_position
	camera.target_zoom = real_camera_zoom
	.queue_free()
	
func _get_total_ships():
	var total_combat = 0
	var total_explorer = 0
	var total_miner = 0
	var total_transport = 0
	for child in GameState.get_selection()['children']:
		match child.ship_type:
			Enums.ship_types.combat:
				total_combat += 1
			Enums.ship_types.explorer:
				total_explorer += 1
			Enums.ship_types.miner:
				total_miner += 1
			Enums.ship_types.transport:
				total_transport += 1
	
	move_selection[Enums.ship_types.combat].total = total_combat
	move_selection[Enums.ship_types.explorer].total = total_explorer
	move_selection[Enums.ship_types.miner].total = total_miner
	move_selection[Enums.ship_types.transport].total = total_transport

func _on_change(ship_type: int, modification: int = 0):
	move_selection[ship_type].selected = move_selection[ship_type].selected + modification
	
	if move_selection[ship_type].selected < 0:
		move_selection[ship_type].selected = 0
	
	_update_ui()

func _get_label_values(ship_type: int) -> Array:
	return [
		move_selection[ship_type].selected, 
		move_selection[ship_type].total
	]
	
func _update_ui():
	_get_total_ships()
	
	$Changes/Combat/LblChanges.text = "%d / %d" % _get_label_values(Enums.ship_types.combat)
	$Changes/Combat/BtnDecrease.disabled = move_selection[Enums.ship_types.combat].selected == 0
	$Changes/Combat/BtnIncrease.disabled = move_selection[Enums.ship_types.combat].selected == move_selection[Enums.ship_types.combat].total
	
	$Changes/Explorer/LblChanges.text = "%d / %d" % _get_label_values(Enums.ship_types.explorer)
	$Changes/Explorer/BtnDecrease.disabled = move_selection[Enums.ship_types.explorer].selected == 0
	$Changes/Explorer/BtnIncrease.disabled = move_selection[Enums.ship_types.explorer].selected == move_selection[Enums.ship_types.explorer].total
	
	$Changes/Miner/LblChanges.text = "%d / %d" % _get_label_values(Enums.ship_types.miner)
	$Changes/Miner/BtnDecrease.disabled = move_selection[Enums.ship_types.miner].selected == 0
	$Changes/Miner/BtnIncrease.disabled = move_selection[Enums.ship_types.miner].selected == move_selection[Enums.ship_types.miner].total
	
	$Changes/Transport/LblChanges.text = "%d / %d" % _get_label_values(Enums.ship_types.transport)
	$Changes/Transport/BtnDecrease.disabled = move_selection[Enums.ship_types.transport].selected == 0 
	$Changes/Transport/BtnIncrease.disabled = move_selection[Enums.ship_types.transport].selected == move_selection[Enums.ship_types.transport].total
	
	var has_selection = false
	has_selection = has_selection || move_selection[Enums.ship_types.combat].selected > 0
	has_selection = has_selection || move_selection[Enums.ship_types.explorer].selected > 0
	has_selection = has_selection || move_selection[Enums.ship_types.miner].selected  > 0
	has_selection = has_selection || move_selection[Enums.ship_types.transport].selected  > 0
	
	var too_many = false
	too_many = too_many || move_selection[Enums.ship_types.combat].selected > move_selection[Enums.ship_types.combat].total
	too_many = too_many || move_selection[Enums.ship_types.explorer].selected > move_selection[Enums.ship_types.explorer].total
	too_many = too_many || move_selection[Enums.ship_types.miner].selected > move_selection[Enums.ship_types.miner].total
	too_many = too_many || move_selection[Enums.ship_types.transport].selected > move_selection[Enums.ship_types.transport].total
	
	$Actions/BtnConfirmMove.disabled = not has_selection || too_many

func _on_confirm_move():
	MenuState.pop()
	
	move_selection.origin_planet = GameState.get_selection()
	
	var movement_target = movement_target_prefab.instance()
	movement_target.move_selection = move_selection
	get_parent().add_child(movement_target)
	
	
func _on_close():
	MenuState.pop()
