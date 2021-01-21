extends VBoxContainer

onready var selection: entity = GameState.get_selection()
onready var total_ui_width: int = $MarginContainer/Info/Distribution.rect_size[0]

var total_ships: float = 0
var distribution = {
	Enums.ship_types.disabled: {
		'current': 0,
		'change': 0
	},
	Enums.ship_types.combat: {
		'current': 0,
		'change': 0
	},
	Enums.ship_types.explorer: {
		'current': 0,
		'change': 0
	},
	Enums.ship_types.miner: {
		'current': 0,
		'change': 0
	},
	Enums.ship_types.transport: {
		'current': 0,
		'change': 0
	},
}

func _ready():
	MenuState.push(self)
	selection.connect("entity_changed", self, "_update_ui")
	
	_update_current_state()
	
	distribution[Enums.ship_types.disabled].change = distribution[Enums.ship_types.disabled].current
	distribution[Enums.ship_types.combat].change = distribution[Enums.ship_types.combat].current
	distribution[Enums.ship_types.explorer].change = distribution[Enums.ship_types.explorer].current
	distribution[Enums.ship_types.miner].change = distribution[Enums.ship_types.miner].current
	distribution[Enums.ship_types.transport].change = distribution[Enums.ship_types.transport].current

	$MarginContainer/Info/LabelsAndActions/Combat/Actions/Decrease.connect("pressed", self, "_on_change", [Enums.ship_types.combat, -1])
	$MarginContainer/Info/LabelsAndActions/Combat/Actions/Increase.connect("pressed", self, "_on_change", [Enums.ship_types.combat, 1])
	$MarginContainer/Info/LabelsAndActions/Explorer/Actions/Decrease.connect("pressed", self, "_on_change", [Enums.ship_types.explorer, -1])
	$MarginContainer/Info/LabelsAndActions/Explorer/Actions/Increase.connect("pressed", self, "_on_change", [Enums.ship_types.explorer, 1])
	$MarginContainer/Info/LabelsAndActions/Miner/Actions/Decrease.connect("pressed", self, "_on_change", [Enums.ship_types.miner, -1])
	$MarginContainer/Info/LabelsAndActions/Miner/Actions/Increase.connect("pressed", self, "_on_change", [Enums.ship_types.miner, 1])
	$MarginContainer/Info/LabelsAndActions/Transport/Actions/Decrease.connect("pressed", self, "_on_change", [Enums.ship_types.transport, -1])
	$MarginContainer/Info/LabelsAndActions/Transport/Actions/Increase.connect("pressed", self, "_on_change", [Enums.ship_types.transport, 1])

	_update_ui()
	
func _on_change(ship_type: int, change: int):
	print('on change')
	print(ship_type)
	print(change)
	
	distribution[ship_type].change += change
	
	if distribution[ship_type].change < 0:
		distribution[ship_type].change = 0
		
	var total_allocated = 0
	total_allocated += distribution[Enums.ship_types.combat].change
	total_allocated += distribution[Enums.ship_types.explorer].change
	total_allocated += distribution[Enums.ship_types.miner].change
	total_allocated += distribution[Enums.ship_types.transport].change
	distribution[Enums.ship_types.disabled].change = total_ships - total_allocated
	
	_update_ui()
	
func _update_current_state():
	
	for ship_type in Enums.ship_types.values():
		distribution[ship_type].current = 0
	
	for child in selection.children:
		if child.ship_type >= 0 and child.faction == 0:
			if child.state == Enums.ship_states.travel:
				continue
			
			match(child.ship_type):
				Enums.ship_types.disabled:
					distribution[Enums.ship_types.disabled].current += 1
				Enums.ship_types.combat:
					distribution[Enums.ship_types.combat].current += 1
				Enums.ship_types.explorer:
					distribution[Enums.ship_types.explorer].current += 1
				Enums.ship_types.miner:
					distribution[Enums.ship_types.miner].current += 1
				Enums.ship_types.transport:
					distribution[Enums.ship_types.transport].current += 1
	
	total_ships = 0
	total_ships += distribution[Enums.ship_types.disabled].current
	total_ships += distribution[Enums.ship_types.combat].current
	total_ships += distribution[Enums.ship_types.explorer].current
	total_ships += distribution[Enums.ship_types.miner].current
	total_ships += distribution[Enums.ship_types.transport].current
	

func _set_distribution(ui_elem: Control, values: Dictionary, total_ships: float, total_ui_width: int):
	ui_elem.visible = values.change > 0
	if total_ships > 0:
		ui_elem.rect_min_size[0] = (values.change / total_ships) * total_ui_width
	else:
		ui_elem.rect_min_size[0] = 0
	(ui_elem.get_node('Label') as Label).text = values.change as String

func _has_changes() -> bool:
	for ship_type in Enums.ship_types.values():
		if distribution[ship_type].change != distribution[ship_type].current:
			return true
	return false
	
func _update_ui():
	
	_update_current_state()
	
	$MarginContainer/Info/LabelsAndActions/Combat/Actions/Decrease.disabled = distribution[Enums.ship_types.combat].change == 0
	$MarginContainer/Info/LabelsAndActions/Explorer/Actions/Decrease.disabled = distribution[Enums.ship_types.explorer].change == 0
	$MarginContainer/Info/LabelsAndActions/Miner/Actions/Decrease.disabled = distribution[Enums.ship_types.miner].change == 0
	$MarginContainer/Info/LabelsAndActions/Transport/Actions/Decrease.disabled = distribution[Enums.ship_types.transport].change == 0
	
	var no_more_to_allocate = distribution[Enums.ship_types.disabled].change == 0
	$MarginContainer/Info/LabelsAndActions/Combat/Actions/Increase.disabled = no_more_to_allocate
	$MarginContainer/Info/LabelsAndActions/Explorer/Actions/Increase.disabled = no_more_to_allocate
	$MarginContainer/Info/LabelsAndActions/Miner/Actions/Increase.disabled = no_more_to_allocate
	$MarginContainer/Info/LabelsAndActions/Transport/Actions/Increase.disabled = no_more_to_allocate
	
	_set_distribution($MarginContainer/Info/Distribution/Combat, distribution[Enums.ship_types.combat], total_ships, total_ui_width)
	_set_distribution($MarginContainer/Info/Distribution/Explorer, distribution[Enums.ship_types.explorer], total_ships, total_ui_width)
	_set_distribution($MarginContainer/Info/Distribution/Miner, distribution[Enums.ship_types.miner], total_ships, total_ui_width)
	_set_distribution($MarginContainer/Info/Distribution/Transport, distribution[Enums.ship_types.transport], total_ships, total_ui_width)
	_set_distribution($MarginContainer/Info/Distribution/Unallocated, distribution[Enums.ship_types.disabled], total_ships, total_ui_width)
	
	$Actions/BtnConfirm.disabled = not _has_changes()
	print(distribution)
	
func _on_cancel():
	MenuState.pop()

func _on_confirm():
	print('confirm')
	
	selection.disconnect("entity_changed", self, "_update_ui")
	
	print(distribution)
	var unallocated_children = []

	# get to unallocate
	for child in selection.get_children_sorted_by_distance():
		if child.ship_type >= 0:
			if child.ship_type == Enums.ship_types.disabled:
				unallocated_children.append(child)
			else:
				for ship_type in Enums.ship_types.values():
					if child.ship_type == ship_type:
						if distribution[ship_type].change < distribution[ship_type].current:
							unallocated_children.append(child)
							distribution[ship_type].change += 1
							
	print(unallocated_children.size())
	
	# Queue up ships with target type
	for unallocated_child in unallocated_children:
		var ship_types = Enums.ship_types.values()
		ship_types.shuffle()
		for ship_type in ship_types:
			if distribution[ship_type].change > distribution[ship_type].current:
				unallocated_child.state = Enums.ship_states.rebuild
				unallocated_child.process_target = ship_type
				unallocated_child.process_progress = 10
				unallocated_children.erase(unallocated_child)
				break
	
	print(unallocated_children.size())
	
	# Set the rest to disabled type, if they are not already disabled type
	for unallocated_child in unallocated_children:
		if unallocated_child.ship_type != Enums.ship_types.disabled:
			unallocated_child.state = Enums.ship_states.rebuild
			unallocated_child.process_target = Enums.ship_types.disabled
			unallocated_child.process_progress = 10
			unallocated_children.erase(unallocated_child)
			
	print(unallocated_children.size())
	
	MenuState.pop()
