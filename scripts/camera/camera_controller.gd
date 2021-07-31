extends Camera

onready var node_parent: Spatial = get_parent()

var curr_focus: Entity
var contraints = []

var velocity: Vector3 = Vector3.ZERO
var movement_speed: int = 1
var movement_damping: float = 0.95

var pivot_speed: int = 10
var zoom_speed: int = 5

signal camera_changed

func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	GameState.connect("planet_system_changed", self, "_update_bounds")

func _process(_delta):
	
	if node_parent.rotation_degrees != node_parent.pivot:
		node_parent.rotation_degrees = lerp(node_parent.rotation_degrees, node_parent.pivot, get_process_delta_time() * pivot_speed)
	
	var move_dir = node_parent.get_move_dir()
	if not Vector3.ZERO.is_equal_approx(move_dir) and not MenuState.is_over_ui():
		velocity = move_dir
		emit_signal("camera_changed")
	
	
	if contraints.size() == 0:
		pass
	elif not Geometry.is_point_in_polygon(Vector2(node_parent.translation.x, node_parent.translation.z), contraints):
		node_parent.translation = lerp(node_parent.translation, intersects_contraints(), get_process_delta_time() * movement_speed * 10)
	elif velocity != Vector3.ZERO:
		velocity.x = clamp(velocity.x * movement_damping,-1.0,1.0)
		velocity.z = clamp(velocity.z * movement_damping,-1.0,1.0)
		
		var next = node_parent.translation + velocity * movement_speed * translation.y * get_process_delta_time()
		var next_vec2 = Vector2(next.x, next.z)
		if Geometry.is_point_in_polygon(next_vec2, contraints):
			node_parent.translation = next
		else:
			node_parent.translation = lerp(node_parent.translation, intersects_contraints(), get_process_delta_time() * movement_speed)
	
	var zoom = node_parent.get_zoom()
	if not is_equal_approx(zoom, translation.y):
		var t = translation
		var speed = zoom_speed if not node_parent.is_overview() else 5
		t.y = lerp(t.y, zoom, get_process_delta_time() * speed)
		translation = t
		emit_signal("camera_changed")

func _update_bounds():
	curr_focus = get_node("/root/GameScene/Galaxy") if not GameState.planet_system else GameState.planet_system
	if curr_focus:
		contraints = curr_focus.bounds

func intersects_contraints() -> Vector3:
	var check_from = Vector2(node_parent.translation.x, node_parent.translation.z)
	var check_to = Vector2(curr_focus.translation.x, curr_focus.translation.z)

	for pair in Geometry.intersect_polyline_with_polygon_2d([check_from, check_to], contraints):
		for intersection in pair:
			if intersection != Vector2.ZERO:
				return Vector3(intersection.x, 0, intersection.y)
		
	return node_parent.translation
