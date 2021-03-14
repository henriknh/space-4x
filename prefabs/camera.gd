extends Camera2D

# Used to know if current camera state has changed. If it has, then it should be stored
var last_pos = position
var last_zoom = zoom

# Store state of current key presses
var keys = {
	'left': false,
	'right': false,
	'up': false,
	'down': false,
}

# Store state of current touches
var touches = {}

# Right mouse button was or is pressed.
var is_drag = false

# Zoom limit
export (int) var zoom_in_limit = 1
export (int) var zoom_out_limit = Consts.PLANET_SYSTEM_RADIUS / 200

# Limit bounds of camera 
const limit = Consts.PLANET_SYSTEM_RADIUS * 1.0

# Camera speed in px/s.
export (int) var camera_speed = 450

# Value meaning how near to the window edge (in px) the mouse must be,
# to move a view.
export (int) var camera_margin = 20

# Zoom speed factor that is used with current zoom to calculate next zoom value
const camera_zoom_speed = 25

# Vector of camera's movement / second.
var camera_movement = Vector2()

# Previous mouse position used to count delta of the mouse movement.
var _prev_mouse_pos = null

func _ready():
	
	GameState.connect("state_changed", self, "load_camera_state")
	
	var timer = Timer.new()
	timer.connect("timeout",self,"set_camera_state") 
	timer.wait_time = 1
	add_child(timer)
	timer.start()
	
	set_h_drag_enabled(false)
	set_v_drag_enabled(false)
	set_enable_follow_smoothing(true)
	set_follow_smoothing(4)
	
func load_camera_state():
	var camera_state = GameState.get_camera_state()
	
	if camera_state.has('pos_x'):
		position = Vector2(camera_state['pos_x'], camera_state['pos_y'])
		last_pos = position
	
	if camera_state.has('zoom'):
		zoom = Vector2(camera_state['zoom'], camera_state['zoom'])
		last_zoom = zoom

func set_camera_state() -> void:
	if last_pos != position or last_zoom != zoom:
		GameState.set_camera_setting({
			"pos_x": self.position.x,
			"pos_y": self.position.y,
			"zoom": self.zoom.x
		})
		last_pos = position
		last_zoom = zoom

func _unhandled_input(event):
	
	if MenuState.is_over_ui():
		return
	
	if Utils.is_mobile:
		_handle_touch_input(event)
	else:
		_handle_desktop_input(event)

func _handle_touch_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
	elif event is InputEventScreenDrag:
		if touches.keys().size() == 1:
			position -= event.relative * zoom.x
		elif touches.keys().size() == 2:
			if touches.has(0) and touches.has(1):
				var prev_dist = (touches[0] as Vector2).distance_squared_to(touches[1])
				var curr_dist = prev_dist
				
				if event.index == 0:
					curr_dist = (event.position as Vector2).distance_squared_to(touches[1])
				elif event.index == 1:
					curr_dist = (event.position as Vector2).distance_squared_to(touches[0])

				var offset = clamp(prev_dist - curr_dist, -1, 1)
				zoom = zoom + Vector2(offset, offset)
				
		touches[event.index] = event.position
		
		get_tree().set_input_as_handled()
		
func _handle_desktop_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			# Control by right mouse button.
			is_drag = event.pressed
		
		if event.button_index == BUTTON_WHEEL_UP:
			zoom -= (zoom / camera_zoom_speed).ceil()
			
			if zoom.x < zoom_in_limit:
				zoom = Vector2(zoom_in_limit, zoom_in_limit)
		
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom += (zoom / camera_zoom_speed).ceil()
			
			if zoom.x > zoom_out_limit:
				zoom = Vector2(zoom_out_limit, zoom_out_limit)
	
	# Control by keyboard handled by InpuMap.
	if event.is_action_pressed("ui_left"):
		keys.left = true
	if event.is_action_pressed("ui_right"):
		keys.right = true
	if event.is_action_pressed("ui_up"):
		keys.up = true
	if event.is_action_pressed("ui_down"):
		keys.down = true
	if event.is_action_released("ui_left"):
		keys.left = false
	if event.is_action_released("ui_right"):
		keys.right = false
	if event.is_action_released("ui_up"):
		keys.up = false
	if event.is_action_released("ui_down"):
		keys.down = false

func _physics_process(delta):
	
	if MenuState.is_over_ui():
		return
	
	if Utils.is_mobile:
		_handle_touch(delta)
	else:
		_handle_desktop(delta)
	
	# Update position of the camera.
	position += camera_movement * get_zoom()
	
	# Check outside of bounds
	var intersects = Geometry.segment_intersects_circle(Vector2.ZERO, position, Vector2.ZERO, limit)
	if intersects != -1:
		position = position * intersects
	
	# Set camera movement to zero, update old mouse position.
	camera_movement = Vector2(0,0)
	_prev_mouse_pos = get_local_mouse_position()

func _handle_touch(delta: float) -> void:
	pass
	
func _handle_desktop(delta: float) -> void:
	# Move camera by keys defined in InputMap (ui_left/right/up/down).
	if keys.left:
		camera_movement.x -= camera_speed * delta
	if keys.right:
		camera_movement.x += camera_speed * delta
	if keys.up:
		camera_movement.y -= camera_speed * delta
	if keys.down:
		camera_movement.y += camera_speed * delta
	
	# Move camera by mouse, when it's on the margin (defined by camera_margin).
	var viewport = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x <= camera_margin:
		camera_movement.x -= camera_speed * delta
	if viewport.x - mouse_pos.x <= camera_margin:
		camera_movement.x += camera_speed * delta
	if mouse_pos.y <= camera_margin:
		camera_movement.y -= camera_speed * delta
	if viewport.y - mouse_pos.y <= camera_margin:
		camera_movement.y += camera_speed * delta
	
	# When RMB is pressed, move camera by difference of mouse position
	if is_drag:
		camera_movement = _prev_mouse_pos - get_local_mouse_position()
	
