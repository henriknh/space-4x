extends VBoxContainer

const block_input = false

var selection: entity = null
var move_selection = {}
onready var camera = get_node('/root/GameScene/Camera') as Camera2D

var real_planet_system: int
var real_camera_position: Vector2
var real_camera_zoom: Vector2

func _ready():
	print(move_selection)
	_update_ui()
	MenuState.push(self)
	
	GameState.selection.connect("entity_changed", self, "_update_ui")

func _is_confirm_disabled() -> bool:
	if selection == null:
		return true
	elif selection.faction != 0:
		return true
	else:
		return false

func _update_ui():
	$Actions/BtnToGalaxy.visible = GameState.get_planet_system() > -1
	$Actions/BtnToPlanetSystem.visible = GameState.get_planet_system() == -1
	$Actions/BtnConfirm.disabled = _is_confirm_disabled()
	
func queue_free():
	print(real_planet_system)
	if real_planet_system >= 0:
		GameState.set_planet_system(real_planet_system)
		camera.target_position = real_camera_position
		camera.target_zoom = real_camera_zoom
	
	.queue_free()

func _on_to_galaxy():
	real_planet_system = GameState.get_planet_system()
	real_camera_position = camera.target_position
	real_camera_zoom = camera.target_zoom
	
	GameState.set_planet_system(-1)
	_update_ui()

func _on_to_planet_system(planet_system: int):
	GameState.set_planet_system(planet_system)
	_update_ui()

func _on_cancel():
	MenuState.pop()

func _on_confirm():
	print('_on_confirm')
