extends Control

var movement_target_prefab = preload('res://prefabs/ui/game/ship_movement/movement_target.tscn')

onready var move_selection = {
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
	for child in GameState.selection['children']:
		match (child as entity).ship_type:
			Enums.ship_types.combat:
				move_selection[Enums.ship_types.combat].total += 1
			Enums.ship_types.explorer:
				move_selection[Enums.ship_types.explorer].total += 1
			Enums.ship_types.miner:
				move_selection[Enums.ship_types.miner].total += 1
			Enums.ship_types.transport:
				move_selection[Enums.ship_types.transport].total += 1
	
	_update_ui()
	MenuState.push(self)
	
	GameState.selection.connect("entity_changed", self, "_update_ui")

	var viewport_size = get_viewport_rect().size
	var offset = Vector2(-viewport_size.x / 2, -viewport_size.y / 2)
	
	real_camera_position = camera.target_position
	real_camera_zoom = camera.target_zoom
	camera.target_position = GameState.get_selection().position + offset
	camera.target_zoom = Vector2.ONE * 10
	
func queue_free():
	camera.target_position = real_camera_position
	camera.target_zoom = real_camera_zoom
	.queue_free()

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
	
	var sum_change = 0
	for key in move_selection.keys():
		sum_change += move_selection[key].selected

	$Actions/BtnConfirmMove.disabled = sum_change == 0

func _on_confirm_move():
	MenuState.pop()
	var movement_target = movement_target_prefab.instance()
	movement_target.move_selection = move_selection
	get_parent().add_child(movement_target)
	
	
func _on_close():
	MenuState.pop()
