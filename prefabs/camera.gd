extends Camera2D

const SMOOTH_SPEED = 5
const CAMERA_SPEED = 500
const ZOOM_MIN = 2
const ZOOM_MAX = 200

var is_dragging = false
var camera_pos_change = Vector2.ZERO
onready var target_zoom = zoom.x
onready var target_position = Vector2.ZERO

var last_pos = position
var last_zoom = zoom

func _ready():
	GameState.connect("state_changed", self, "load_camera_state")
	
	var timer = Timer.new()
	timer.connect("timeout",self,"set_camera_state") 
	timer.wait_time = 5
	add_child(timer)
	timer.start()
	
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
		target_zoom = zoom.x
		last_pos = position
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

func _input(event):
	if MenuState.is_over_ui():
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
		
	target_position += camera_pos_change * zoom.x * 10

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
	
	position = lerp(position, target_position, 0.5)

func update_limit(distance: int):
	limit_left = -int(distance + get_viewport().size.x)
	limit_right = int(distance + get_viewport().size.x)
	limit_top = -int(distance + get_viewport().size.y)
	limit_bottom = int(distance + get_viewport().size.y)
