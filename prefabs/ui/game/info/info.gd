extends Control

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

var real_camera_position: Vector2
var real_camera_zoom: float

func _ready():
	update_ui()
	MenuState.push(self)

	var viewport_size = get_viewport_rect().size
	var offset = Vector2(viewport_size.x * 0.4, 0)
	
	real_camera_position = camera.target_position
	real_camera_zoom = camera.target_zoom
	camera.target_position = GameState.get_selection().position + offset
	camera.target_zoom = 1
	
func queue_free():
	print('queue_free')
	camera.target_position = real_camera_position
	camera.target_zoom = real_camera_zoom
	.queue_free()
	
func _on_close():
	MenuState.pop()

func update_ui():
	var selection: entity = GameState.get_selection()
	$VBoxContainer/Info/LabelSelection.text = selection.label
	
	$VBoxContainer/Resources1/LabelMetal.text = selection.metal as String
	$VBoxContainer/Resources1/LabelPower.text = selection.power as String
	$VBoxContainer/Resources2/LabelFood.text = selection.food as String
	$VBoxContainer/Resources2/LabelWater.text = selection.water as String
