extends VBoxContainer

const block_input = false

var selection: Entity = null
var move_selection = {}

func _ready():
	_update_ui()
	MenuState.push(self)
	
	GameState.connect("selection_changed", self, "_selection_changed")
	GameState.connect("state_changed", self, "_state_changed")

func _selection_changed():
	if selection:
		selection.disconnect("entity_changed", self, "_update_ui")
		
	selection = GameState.get_selection()
	
	if selection:
		selection.connect("entity_changed", self, "_update_ui")
	_update_ui()

func _is_confirm_disabled() -> bool:
	if selection == null:
		return true
	elif selection == move_selection.origin_planet:
		return true 
	else:
		return false

func _update_ui():
	$Actions/BtnToGalaxy.visible = GameState.get_planet_system() > -1
	$Actions/BtnConfirm.disabled = _is_confirm_disabled()

func _state_changed():
	_update_ui()

func _on_to_galaxy():
	GameState.set_planet_system(-1)
	
func _on_cancel():
	MenuState.pop()

func _on_confirm():
	var ships = {
		Enums.ship_types.combat: [],
		Enums.ship_types.miner: [],
		Enums.ship_types.explorer: [],
		Enums.ship_types.transport: [],
	}
	
	var sorted_children = (move_selection.origin_planet as Planet).get_children_sorted_by_distance()
	for ship in sorted_children:
		
		if ship.ship_type == -1:
			continue
		
		for ship_type in Enums.ship_types.values():
			if ship.ship_type == ship_type and ships[ship_type].size() < move_selection[ship_type].selected:
				ships[ship_type].append(ship)
	
	for ship_type in Enums.ship_types.values():
		if not ships.has(ship_type):
			continue
		for ship in ships[ship_type]:
			(ship as Ship).state = Enums.ship_states.travel
			(ship as Ship).process_target = selection.id
	
	MenuState.pop()
