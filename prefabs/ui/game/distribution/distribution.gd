extends HBoxContainer

onready var total_ui_width: int = rect_size[0]

signal distribution_changed

enum color_types {
	rebuilding,
	current,
	change
}
const SHIP_TYPE_DISABLED = 'disabled'

var total_ships: float = 0
var distribution = {}

func _ready():
	for ship_type in Enums.ship_types.values():
		for color_type in color_types.values():
			_create_color_node(ship_type, color_type)
	
func _create_color_node(ship_type, color_type):
	var color = ColorRect.new()
	color.mouse_filter = Control.MOUSE_FILTER_PASS
	
	color.color = Enums.ship_colors[ship_type]
	
	color.rect_size = Vector2.ZERO
	color.rect_min_size = Vector2(0, rect_size.y)
	
	add_child(color)
	
	match color_type:
		color_types.current:
			color.margin_top = 0
		color_types.rebuilding:
			color.margin_top = 24
		color_types.change:
			color.margin_top = 48
	
	if not distribution.has(ship_type):
		distribution[ship_type] = {}
	
	if not distribution[ship_type].has(color_type):
		distribution[ship_type][color_type] = {
			'node': color,
			'value': 0
		}

func update_distribution_globally():
	total_ships = 0
	for key in distribution.keys():
		distribution[key][color_types.current].value = 0
		distribution[key][color_types.rebuilding].value = 0
	
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.corporation_id == Consts.PLAYER_CORPORATION:
			distribution[Enums.ship_types.disabled][color_types.current].value += planet.planet_disabled_ships
			total_ships += planet.planet_disabled_ships
	for ship in get_tree().get_nodes_in_group('Ship'):
		if ship.corporation_id == Consts.PLAYER_CORPORATION:
			if ship.state == Enums.ship_states.travel:
				continue
			
			total_ships += 1
			if ship.ship_type == Enums.ship_types.disabled or ship.state == Enums.ship_states.disable:
				distribution[Enums.ship_types.disabled][color_types.rebuilding].value += 1
			elif ship.state == Enums.ship_states.rebuild:
				distribution[ship.ship_type][color_types.rebuilding].value += 1
			else:
				distribution[ship.ship_type][color_types.current].value += 1
	
	_update_ui()

func update_distribution_by_selection(selection: Entity):
	for key in distribution.keys():
		distribution[key][color_types.current].value = 0
		distribution[key][color_types.rebuilding].value = 0
	
	var count_disabled_ships = selection.planet_disabled_ships
	distribution[Enums.ship_types.disabled][color_types.current].value = selection.planet_disabled_ships
	total_ships = selection.planet_disabled_ships
	
	for ship in selection.ships:
		if ship.ship_type >= 0 and ship.corporation_id == Consts.PLAYER_CORPORATION:
			if ship.state == Enums.ship_states.travel:
				continue
			
			total_ships += 1
			
			if ship.ship_type == Enums.ship_types.disabled or ship.state == Enums.ship_states.disable:
				distribution[Enums.ship_types.disabled][color_types.rebuilding].value += 1
			elif ship.state == Enums.ship_states.rebuild:
				distribution[ship.ship_type][color_types.rebuilding].value += 1
			else:
				distribution[ship.ship_type][color_types.current].value += 1
	
	_update_ui()

func _update_ui():
	
	if total_ships == 0:
		return
		
	total_ui_width = rect_size[0]
	
	for key in distribution.keys():
		
		var node = distribution[key]
		
		# Rebuilding
		var rebuilding_size = (node[color_types.rebuilding].value / total_ships) * total_ui_width
		node[color_types.rebuilding].node.rect_size[0] = rebuilding_size
		node[color_types.rebuilding].node.rect_min_size[0] = rebuilding_size
		
		if node[color_types.change].value > 0:
			var current_size = (node[color_types.current].value / total_ships) * total_ui_width
			node[color_types.current].node.rect_size[0] = current_size
			node[color_types.current].node.rect_min_size[0] = current_size
			
			var change_size = (node[color_types.change].value / total_ships) * total_ui_width
			node[color_types.change].node.rect_size[0] = change_size
			node[color_types.change].node.rect_min_size[0] = change_size
		else:
			var actual_value = node[color_types.current].value + node[color_types.change].value
			var current_size = (actual_value / total_ships) * total_ui_width
			node[color_types.current].node.rect_size[0] = current_size
			node[color_types.current].node.rect_min_size[0] = current_size
			
			node[color_types.change].node.rect_size[0] = 0
			node[color_types.change].node.rect_min_size[0] = 0
	
	emit_signal("distribution_changed")

func on_change(ship_type: int, change: int):
	var diff = change - distribution[ship_type][color_types.current].value
	
	distribution[ship_type][color_types.change].value = change
	
	var disabled_change = 0
	for key in distribution.keys():
		if key == Enums.ship_types.disabled:
			continue
		disabled_change -= distribution[key][color_types.change].value
		
	distribution[Enums.ship_types.disabled][color_types.change].value = disabled_change
	
	_update_ui()

func has_changes() -> bool:
	return distribution[Enums.ship_types.disabled][color_types.change].value != 0

func get_combat_current() -> int:
	return distribution[Enums.ship_types.combat][color_types.current].value

func get_explorer_current() -> int:
	return distribution[Enums.ship_types.explorer][color_types.current].value

func get_miner_current() -> int:
	return distribution[Enums.ship_types.miner][color_types.current].value

func get_combat_change() -> int:
	return distribution[Enums.ship_types.combat][color_types.change].value

func get_explorer_change() -> int:
	return distribution[Enums.ship_types.explorer][color_types.change].value

func get_miner_change() -> int:
	return distribution[Enums.ship_types.miner][color_types.change].value

func get_available_count() -> int:
	return distribution[Enums.ship_types.disabled][color_types.current].value + distribution[Enums.ship_types.disabled][color_types.change].value
