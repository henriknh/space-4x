extends Spatial

export var button_spread: int = 100
export var buttons: Array = []

onready var camera = get_node('/root/GameScene/CameraRoot/Camera') as Camera

onready var control_root: Control = $Quad/ViewportContainer/Viewport/Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#visible = false
	#set_process(false)
	
	#$Quad/Area.connect("input_event", self, "area_input")
	
	call_deferred("setup_buttons")
	
func _process(delta):
	$Quad.look_at(camera.global_transform.origin, Vector3.UP)
	$Quad.scale = $Quad.global_transform.origin.distance_to(camera.global_transform.origin) * Vector3.ONE / 2
	update_position()

func area_input(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int):
	print(event)
	print(click_normal)

func setup_buttons():
	for button in buttons:
		var button_node = get_node(button)
		button_node.get_parent().remove_child(button_node)
		control_root.add_child(button_node)
	
	var cancel_button = TextureButton.new()
	cancel_button.texture_normal = preload("res://assets/icons/close.png")
	cancel_button.connect("pressed", self, "on_cancel")
	cancel_button.connect("mouse_entered", self,"on_mouse_over")
	control_root.add_child(cancel_button)
	control_root.move_child(cancel_button, 0)
	
	GameState.connect("selection_changed", self, "on_selection")
	GameState.connect("planet_system_changed", self, "on_planet_system_change")
	#camera.connect("camera_changed", self, "on_camera_change")
	
	update_position()
	
func update_position():
	if control_root.get_child_count():
		var zoom = camera.translation.y
		var i = 0
		var angle_offset = (2 * PI) / control_root.get_child_count()
		for node in control_root.get_children():
			node.rect_position = Vector2(cos(angle_offset * i + PI / 2), sin(angle_offset * i + PI / 2)) * (150 - zoom) - node.rect_size / 2
			i += 1

func on_selection():
	if GameState.selection:
		visible = GameState.selection.name in get_path() as String
	else:
		visible = false
	set_process(visible)

func on_planet_system_change():
	if not GameState.planet_system:
		visible = false
		set_process(false)
		
func on_camera_change():
	update_position()
	#print('on_camera_change')
	pass
	
func on_cancel():
	GameState.selected_tile = null
	
func on_mouse_over():
	print('on_mouse_over')


func _on_ViewportContainer_gui_input(event):
	print(event)
	pass # Replace with function body.
