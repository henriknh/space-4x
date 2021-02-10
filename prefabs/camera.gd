extends Camera2D

var camera_pos_change = Vector2.ZERO
onready var target_zoom = Vector2(10, 10)
onready var target_position = Vector2.ZERO

var last_pos = position
var last_zoom = zoom

var keys = {
	KEY_A: false,
	KEY_D: false,
	KEY_W: false,
	KEY_S: false,
}
var touches = {}

func _ready():
	GameState.connect("state_changed", self, "load_camera_state")
	
	var timer = Timer.new()
	timer.connect("timeout",self,"set_camera_state") 
	timer.wait_time = 5
	add_child(timer)
	timer.start()
	
	position = target_position
	zoom = target_zoom
	
func load_camera_state():
	var camera_state = GameState.get_camera_state()
	var has_changed = false
	
	if camera_state.has('pos_x'):
		position = Vector2(camera_state['pos_x'], camera_state['pos_y'])
		has_changed = true
	
	if camera_state.has('zoom'):
		zoom = Vector2(camera_state['zoom'], camera_state['zoom'])
		has_changed = true
	
	if has_changed:
		camera_pos_change = Vector2.ZERO
		target_zoom = zoom
		last_zoom = zoom
		target_position = position
		last_pos = position

func set_camera_state() -> void:
	if last_pos != position or last_zoom != zoom:
		GameState.set_camera_setting({
			"pos_x": self.position.x,
			"pos_y": self.position.y,
			"zoom": self.zoom.x
		})
		last_pos = position
		last_zoom = zoom

func _input(event):
	
	if MenuState.is_over_ui():
		return
	
	if Utils.is_mobile:
		self._handle_touch(event)
	else:
		self._handle_mouse(event)

func _handle_touch(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
	elif event is InputEventScreenDrag:
		if touches.keys().size() == 1:
			target_position -= event.relative * zoom.x
		elif touches.keys().size() == 2:
			if touches.has(0) and touches.has(1):
				var prev_dist = (touches[0] as Vector2).distance_squared_to(touches[1])
				var curr_dist = prev_dist
				
				if event.index == 0:
					curr_dist = (event.position as Vector2).distance_squared_to(touches[1])
				elif event.index == 1:
					curr_dist = (event.position as Vector2).distance_squared_to(touches[0])

				var offset = clamp(prev_dist - curr_dist, -1, 1)
				target_zoom = target_zoom + Vector2(offset, offset)
				
		touches[event.index] = event.position
		
		get_tree().set_input_as_handled()
		
		self._clamp_targets()
		
func _handle_mouse(event: InputEvent):
	if event is InputEventKey:
		
		keys[event.scancode] = true if event.pressed else false
		
		if keys[KEY_A] and keys[KEY_D]:
			camera_pos_change.x = 0
		elif keys[KEY_A]:
			camera_pos_change.x = -1
		elif keys[KEY_D]:
			camera_pos_change.x = 1
		else:
			camera_pos_change.x = 0
		
		if keys[KEY_W] and keys[KEY_S]:
			camera_pos_change.y = 0
		elif keys[KEY_W]:
			camera_pos_change.y = -1
		elif keys[KEY_S]:
			camera_pos_change.y = 1
		else:
			camera_pos_change.y = 0
		
	target_position = position + camera_pos_change * zoom.x * 10

	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP:
				zoom_at_point(1 / Consts.CAMERA_ZOOM_STEP, event.position)
			BUTTON_WHEEL_DOWN:
				zoom_at_point(Consts.CAMERA_ZOOM_STEP, event.position)
	
	self._clamp_targets()

func zoom_at_point(zoom_change, point):
	# https://godotengine.org/qa/25983/camera2d-zoom-position-towards-the-mouse
	var c0 = global_position # camera position
	var v0 = get_viewport().size # vieport size
	var c1 # next camera position
	var z0 = zoom # current zoom value
	var z1 = z0 * zoom_change # next zoom value

	c1 = c0 + (-0.5*v0 + point)*(z0 - z1)
	target_zoom = z1
	target_position = c1

func _clamp_targets():
	
	if target_zoom.x < Consts.CAMERA_ZOOM_MIN:
		target_zoom = Vector2(Consts.CAMERA_ZOOM_MIN, Consts.CAMERA_ZOOM_MIN)
	elif target_zoom.x > Consts.CAMERA_ZOOM_MAX:
		target_zoom = Vector2(Consts.CAMERA_ZOOM_MAX, Consts.CAMERA_ZOOM_MAX)
	
	if target_position.x < -Consts.PLANET_SYSTEM_RADIUS:
		target_position.x = -Consts.PLANET_SYSTEM_RADIUS
	elif target_position.x > Consts.PLANET_SYSTEM_RADIUS:
		target_position.x = Consts.PLANET_SYSTEM_RADIUS
	if target_position.y < -Consts.PLANET_SYSTEM_RADIUS:
		target_position.y = -Consts.PLANET_SYSTEM_RADIUS
	elif target_position.y > Consts.PLANET_SYSTEM_RADIUS:
		target_position.y = Consts.PLANET_SYSTEM_RADIUS

func _process(delta):
	pass
	zoom = lerp(zoom, target_zoom, Consts.CAMERA_LERPTIME_POS * delta)
	position = lerp(position, target_position, 1 if Utils.is_mobile else Consts.CAMERA_LERPTIME_POS * delta)

func update_limit(distance: int):
	limit_left = -int(distance + get_viewport().size.x)
	limit_right = int(distance + get_viewport().size.x)
	limit_top = -int(distance + get_viewport().size.y)
	limit_bottom = int(distance + get_viewport().size.y)
