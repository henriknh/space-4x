extends Control

onready var selection: Entity = GameState.get_selection()
onready var node_ship_distribution = $ShipDistribution
onready var node_combat_slider: HSlider = $Inputs/MarginContainer/VBoxContainer/CombatSlider
onready var node_explorer_slider: HSlider = $Inputs/MarginContainer/VBoxContainer/ExplorerSlider
onready var node_miner_slider: HSlider = $Inputs/MarginContainer/VBoxContainer/MinerSlider
onready var node_confirm = $Inputs/Actions/BtnConfirm

func _ready():
	MenuState.push(self)
	
	node_ship_distribution.update_distribution_by_selection(selection)
	selection.connect("entity_changed", node_ship_distribution, "update_distribution_by_selection", [selection])
	node_ship_distribution.connect("distribution_changed", self, "_update_ui")
	
	_update_ui()

func _update_ui():
	node_ship_distribution.rect_min_size = Vector2(rect_size.x, node_ship_distribution.rect_min_size.y)
	
	node_confirm.disabled = not node_ship_distribution.has_changes()
	
	var combat_current = node_ship_distribution.get_combat_current()
	var explorer_current = node_ship_distribution.get_explorer_current()
	var miner_current = node_ship_distribution.get_miner_current()
	
	var combat_change = node_ship_distribution.get_combat_change()
	var explorer_change = node_ship_distribution.get_explorer_change()
	var miner_change = node_ship_distribution.get_miner_change()
	
	var available_count = node_ship_distribution.get_available_count()
	
	node_combat_slider.min_value = -combat_current
	node_explorer_slider.min_value = -explorer_current
	node_miner_slider.min_value = -miner_current
	
	node_combat_slider.max_value = available_count + combat_change
	node_explorer_slider.max_value = available_count + explorer_change
	node_miner_slider.max_value = available_count + miner_change
	
	node_combat_slider.tick_count = combat_current + available_count + combat_change + 1
	node_explorer_slider.tick_count = explorer_current + available_count + explorer_change + 1
	node_miner_slider.tick_count = miner_current + available_count + miner_change + 1
	
func _on_cancel():
	MenuState.pop()

func _on_confirm():
	selection.disconnect("entity_changed", self, "_update_ui")
	
	var combat_change = node_ship_distribution.get_combat_change()
	var explorer_change = node_ship_distribution.get_explorer_change()
	var miner_change = node_ship_distribution.get_miner_change()
	
	# Fetch ships to unallocate
	var unallocated_children = []
	for ship in selection.get_ships_sorted_by_distance():
		if ship.ship_type == Enums.ship_types.disabled:
			continue
		for ship_type in Enums.ship_types.values():
			if ship.ship_type == ship_type:
				match ship.ship_type:
					Enums.ship_types.combat:
						if combat_change < 0:
							unallocated_children.append(ship)
							combat_change += 1
					Enums.ship_types.explorer:
						if explorer_change < 0:
							unallocated_children.append(ship)
							explorer_change += 1
					Enums.ship_types.miner:
						if miner_change < 0:
							unallocated_children.append(ship)
							miner_change += 1

	var gameScene = get_node('/root/GameScene')
	
	# Use planets disabled ships first
	while combat_change > 0:
		if selection.planet_disabled_ships == 0:
			break
		var ship = Instancer.ship(Enums.ship_types.disabled, null, selection)
		ship.set_entity_process(Enums.ship_states.rebuild, Enums.ship_types.combat, Consts.SHIP_REBUILD_TIME)
		gameScene.add_child(ship)
		selection.planet_disabled_ships -= 1
		combat_change -= 1
	while explorer_change > 0:
		if selection.planet_disabled_ships == 0:
			break
		var ship = Instancer.ship(Enums.ship_types.disabled, null, selection)
		ship.set_entity_process(Enums.ship_states.rebuild, Enums.ship_types.explorer, Consts.SHIP_REBUILD_TIME)
		gameScene.add_child(ship)
		selection.planet_disabled_ships -= 1
		explorer_change -= 1
	while miner_change > 0:
		if selection.planet_disabled_ships == 0:
			break
		var ship = Instancer.ship(Enums.ship_types.disabled, null, selection)
		ship.set_entity_process(Enums.ship_states.rebuild, Enums.ship_types.miner, Consts.SHIP_REBUILD_TIME)
		gameScene.add_child(ship)
		selection.planet_disabled_ships -= 1
		miner_change -= 1
	
	# Set existing ships
	var unhandled_unallocated = []
	for unallocated_child in unallocated_children:
		if combat_change > 0:
			unallocated_child.set_entity_process(Enums.ship_states.rebuild, Enums.ship_types.combat, Consts.SHIP_REBUILD_TIME)
			combat_change -= 1
		elif explorer_change > 0:
			unallocated_child.set_entity_process(Enums.ship_states.rebuild, Enums.ship_types.explorer, Consts.SHIP_REBUILD_TIME)
			explorer_change -= 1
		elif miner_change > 0:
			unallocated_child.set_entity_process(Enums.ship_states.rebuild, Enums.ship_types.miner, Consts.SHIP_REBUILD_TIME)
			miner_change -= 1
		else:
			unallocated_child.state = Enums.ship_states.disable

	MenuState.pop()


func _on_combat_slider_changed(change_value: int):
	node_ship_distribution.on_change(Enums.ship_types.combat, change_value)


func _on_explorer_slider_changed(change_value: int):
	node_ship_distribution.on_change(Enums.ship_types.explorer, change_value)

func _on_miner_slider_changed(change_value: int):
	node_ship_distribution.on_change(Enums.ship_types.miner, change_value)
