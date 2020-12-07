extends Camera2D

onready var target_zoom = zoom.x
const SMOOTH_SPEED = 5
var is_dragging = false
var camera_pos_change = Vector2.ZERO
const CAMERA_SPEED = 0.6
var is_over_ui = false

const ZOOM_MIN = 2
const ZOOM_MAX = 30

func _input(event):
	if State.is_over_ui:
		return
	
	if event is InputEventKey and event.pressed and event.scancode == KEY_A:
		camera_pos_change.x = -1
	if event is InputEventKey and event.pressed and event.scancode == KEY_D:
		camera_pos_change.x = 1
	elif event is InputEventKey and not event.pressed and (event.scancode == KEY_A or event.scancode == KEY_D):
		camera_pos_change.x = 0
		
	if event is InputEventKey and event.pressed and event.scancode == KEY_W:
		camera_pos_change.y = -1
	elif event is InputEventKey and event.pressed and event.scancode == KEY_S:
		camera_pos_change.y = 1
	elif event is InputEventKey and not event.pressed and (event.scancode == KEY_W or event.scancode == KEY_S):
		camera_pos_change.y = 0
		
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP:
				target_zoom -= 1
				if target_zoom < ZOOM_MIN:
					target_zoom = ZOOM_MIN
			BUTTON_WHEEL_DOWN:
				target_zoom += 1
				if target_zoom > ZOOM_MAX:
					target_zoom = ZOOM_MAX
			BUTTON_MIDDLE:
				if event.pressed:
					is_dragging = true
				else:
					is_dragging = false
	elif event is InputEventMouseMotion:
		if is_dragging:
			position -= event.relative * zoom.x
			camera_pos_change = Vector2.ZERO
		

func _process(delta):
	var zoom_difference = target_zoom - zoom.x
	var smoothed_zoom = (zoom_difference * SMOOTH_SPEED * delta)
	zoom += Vector2(smoothed_zoom, smoothed_zoom)
	
	position += camera_pos_change * zoom.x * CAMERA_SPEED

func update_limit(distance: int):
	limit_left = -int(distance + get_viewport().size.x)
	limit_right = int(distance + get_viewport().size.x)
	limit_top = -int(distance + get_viewport().size.y)
	limit_bottom = int(distance + get_viewport().size.y)
