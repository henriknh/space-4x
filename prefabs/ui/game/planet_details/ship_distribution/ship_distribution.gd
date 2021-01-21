extends VBoxContainer

onready var selection: entity = GameState.get_selection()
onready var total_ui_width: int = $MarginContainer/Info/Distribution.rect_size[0]

var total_ships: float = 0
var distribution = {
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
	}
}
var disabled = 0;
var rebuilding = 0;

func _ready():
	MenuState.push(self)
	
	GameState.connect("update_ui", self, "_update_ui")
	selection.connect("entity_changed", self, "_update_ui")
	
	_update_current_state()
	
	distribution[Enums.ship_types.combat].change = distribution[Enums.ship_types.combat].current
	distribution[Enums.ship_types.explorer].change = distribution[Enums.ship_types.explorer].current
	distribution[Enums.ship_types.miner].change = distribution[Enums.ship_types.miner].current
	distribution[Enums.ship_types.transport].change = distribution[Enums.ship_types.transport].current
	
	_update_disabled()

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
	
	_update_ui()
	
func _update_current_state():
	
	for ship_type in Enums.ship_types.values():
		if not distribution.has(ship_type):
			continue
		distribution[ship_type].current = 0
	rebuilding = 0
	disabled = 0
	total_ships = 0
	
	for child in selection.children:
		if child.ship_type >= 0 and child.faction == 0:
			if child.state == Enums.ship_states.travel:
				continue
			
			total_ships += 1
			
			if child.state == Enums.ship_states.rebuild:
				rebuilding += 1
				continue
			
			match(child.ship_type):
				Enums.ship_types.combat:
					distribution[Enums.ship_types.combat].current += 1
				Enums.ship_types.explorer:
					distribution[Enums.ship_types.explorer].current += 1
				Enums.ship_types.miner:
					distribution[Enums.ship_types.miner].current += 1
				Enums.ship_types.transport:
					distribution[Enums.ship_types.transport].current += 1

	_update_disabled()

func _update_disabled():
	disabled = total_ships
	disabled -= distribution[Enums.ship_types.combat].change
	disabled -= distribution[Enums.ship_types.explorer].change
	disabled -= distribution[Enums.ship_types.miner].change
	disabled -= distribution[Enums.ship_types.transport].change
	disabled -= rebuilding

func _set_distribution(ui_elem: Control, value: float):
	ui_elem.visible = value > 0
	if total_ships > 0:
		ui_elem.rect_min_size[0] = (value / total_ships) * total_ui_width
	else:
		ui_elem.rect_min_size[0] = 0
	(ui_elem.get_node('Label') as Label).text = value as String

func _has_changes() -> bool:
	for ship_type in Enums.ship_types.values():
		if not distribution.has(ship_type):
			continue
		if distribution[ship_type].change != distribution[ship_type].current:
			return true
	return false
	
func _update_ui():
	
	_update_current_state()
	
	$MarginContainer/Info/LabelsAndActions/Combat/Actions/Decrease.disabled = distribution[Enums.ship_types.combat].change == 0
	$MarginContainer/Info/LabelsAndActions/Explorer/Actions/Decrease.disabled = distribution[Enums.ship_types.explorer].change == 0
	$MarginContainer/Info/LabelsAndActions/Miner/Actions/Decrease.disabled = distribution[Enums.ship_types.miner].change == 0
	$MarginContainer/Info/LabelsAndActions/Transport/Actions/Decrease.disabled = distribution[Enums.ship_types.transport].change == 0
	
	$MarginContainer/Info/LabelsAndActions/Combat/Actions/Increase.disabled = disabled == 0
	$MarginContainer/Info/LabelsAndActions/Explorer/Actions/Increase.disabled = disabled == 0
	$MarginContainer/Info/LabelsAndActions/Miner/Actions/Increase.disabled = disabled == 0
	$MarginContainer/Info/LabelsAndActions/Transport/Actions/Increase.disabled = disabled == 0
	
	_set_distribution($MarginContainer/Info/Distribution/Combat, distribution[Enums.ship_types.combat].change)
	_set_distribution($MarginContainer/Info/Distribution/Explorer, distribution[Enums.ship_types.explorer].change)
	_set_distribution($MarginContainer/Info/Distribution/Miner, distribution[Enums.ship_types.miner].change)
	_set_distribution($MarginContainer/Info/Distribution/Transport, distribution[Enums.ship_types.transport].change)
	_set_distribution($MarginContainer/Info/Distribution/Rebuilding, rebuilding)
	_set_distribution($MarginContainer/Info/Distribution/Disabled, disabled)
	
	$Actions/BtnConfirm.disabled = not _has_changes()
	
func _on_cancel():
	MenuState.pop()

func _on_confirm():
	selection.disconnect("entity_changed", self, "_update_ui")
	
	# Fetch ships to unallocate
	var unallocated_children = []
	for child in selection.get_children_sorted_by_distance():
		if child.ship_type >= 0:
			if child.ship_type == Enums.ship_types.disabled:
				unallocated_children.append(child)
			else:
				for ship_type in Enums.ship_types.values():
					if not distribution.has(ship_type):
						continue
					if child.ship_type == ship_type:
						if distribution[ship_type].change < distribution[ship_type].current:
							unallocated_children.append(child)
							distribution[ship_type].change += 1
	
	# Queue up ships with target type
	var unhandled_unallocated = []
	for unallocated_child in unallocated_children:
		var handled = false
		var ship_types = Enums.ship_types.values()
		ship_types.shuffle()
		for ship_type in ship_types:
			if not distribution.has(ship_type):
				continue
			if distribution[ship_type].change > distribution[ship_type].current:
				unallocated_child.state = Enums.ship_states.rebuild
				unallocated_child.process_target = ship_type
				unallocated_child.process_progress = 10
				distribution[ship_type].change -= 1
				handled = true
				break
		if not handled:
			unhandled_unallocated.append(unallocated_child)
	
	# Set the rest to disabled type, if they are not already disabled type
	for unallocated_child in unhandled_unallocated:
		if unallocated_child.ship_type != Enums.ship_types.disabled:
			unallocated_child.state = Enums.ship_states.rebuild
			unallocated_child.process_target = Enums.ship_types.disabled
			unallocated_child.process_progress = 10
			unallocated_children.erase(unallocated_child)
	
	MenuState.pop()
