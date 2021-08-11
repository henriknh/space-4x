extends Node

class_name State


onready var state_machine = get_parent()
onready var host: Entity = state_machine.get_parent()

var is_background_state = false
var state_ui_unique_id = null
onready var state_ui: Control = preload("res://prefabs/ui/game/state_ui.tscn").instance()
var state_ui_button: TextureButton
var state_ui_progress: TextureProgress
export(Texture) var ui_icon
var ui_progress: float = 0
export var process_speed: float = 1

func _ready():
	state_ui_button = state_ui.get_node("TextureButton")
	state_ui_progress = state_ui.get_node("Viewport/TextureProgress")
	state_ui_button.connect("pressed", self, "ui_trigger")
	
	host.connect("entity_changed", self, "ui_update")
	
	ui_update()

func enter():
	ui_progress = 0
	return

func exit():
	ui_progress = 0
	return
	
func handle_input(_event):
	return
	
func update(_delta):
	return

func ui_visible() -> bool:
	return true

func ui_disabled() -> bool:
	return false

func ui_trigger():
	if state_machine.state == self:
		state_machine.set_state(null)
	else:
		state_machine.set_state(self)
	return null
	
func ui_update():
	var disabled = ui_disabled()
	state_ui.modulate.a = 0.5 if disabled else 1
	state_ui_button.disabled = disabled
	
	state_ui_progress.texture_under = ui_icon
	state_ui_progress.texture_progress = ui_icon
	
	state_ui_progress.value = ui_progress * 100
