extends VBoxContainer

const block_input = false

var selection: entity = null
var move_selection = {}

func _ready():
	_update_ui()
	MenuState.push(self)
	
	GameState.connect("selection_changed", self, "_selection_changed")
	GameState.connect("state_changed", self, "_state_changed")

func _selection_changed():
	selection = GameState.get_selection()
	GameState.get_selection().connect("entity_changed", self, "_update_ui")
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
	print('_on_confirm')
