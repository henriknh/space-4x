extends entity

class_name ship

# Temporary
var nav_route = []
var ship_target_obj = null
var model: Sprite = null
var trail: Node2D = null
var idle_target: Vector2

export(int) var min_speed: int = 10
export(int) var acceleration: int = 50
export(int) var turn_speed: int = 4

func create():
	entity_type = Enums.entity_types.ship
	label = NameGenerator.get_name_ship()
	faction = 0
	if hitpoints_max == -1:
		hitpoints_max = 50
	
	if metal_max < 0:
		metal_max = 0
	if power_max < 0:
		power_max = 10
	if food_max < 0:
		food_max = 5
	if water_max < 0:
		water_max = 5
	if ship_cargo_size < 0:
		ship_cargo_size = metal_max + power_max + food_max + water_max
	.create()
	
func ready():
	model = get_node("Sprite") as Sprite
	trail = get_node("Trail") as Node2D
	
	if faction == 0:
		model.self_modulate = color
		trail.set_color(color)
	else:
		var enemy_color = Color(0,0,0,1)
		model.self_modulate = enemy_color
		trail.set_color(enemy_color)
	.ready()
		
func process(delta: float):
	if state == Enums.ship_states.travel:
		if nav_route.size() == 0 and process_target_id >= 0:
			nav_route = Nav.get_route(self, process_target_id)
		
		move(nav_route[0].position)
		_update_travel_route()
		
		if nav_route.size() == 0:
			process_target_id = -1
			state = Enums.ship_states.idle
	
	elif state == Enums.ship_states.idle:
		if not idle_target or close_to_target(idle_target):
			idle_target = get_random_point_in_site()
			
		move(idle_target)
	else:
		.process(delta)
	
func kill():
	hitpoints = 0
	queue_free()
	
func clear():
	ship_target_id = -1
	nav_route = [Nav.get_route(self, ship_target_id)]

func move(target_position: Vector2, decrease_speed: bool = true, turn_direction: int = 0) -> bool:
	if turn_direction == 0:
		rotation += get_angle_to(target_position) * turn_speed * delta
	elif turn_direction < 0:
		rotation += get_angle_to(target_position) * turn_speed * delta

	var ship_forward_dir = Vector2(cos(rotation), sin(rotation)).normalized()

	position += ship_forward_dir * ship_speed * delta

	return _calc_speed(target_position, decrease_speed)

func _calc_speed(target_position: Vector2, decrease_speed: bool) -> bool:
	if decrease_speed and close_to_target(target_position):
		if nav_route.size() <= 1 and ship_speed >= 0:
			ship_speed -= ship_speed_max / 10 * delta * 10
		if ship_speed < 0:
			ship_speed = 0
	elif ship_speed < min_speed:
		ship_speed = min_speed
	elif ship_speed > ship_speed_max:
		ship_speed = ship_speed_max
	elif ship_speed < ship_speed_max:
		ship_speed += ship_speed_max / 10 * delta
	#else:
	#	ship_speed -= ship_speed_max / 10 * delta * 10
		
	if ship_speed == 0 and trail.is_emitting():
		trail.set_emitting(false)
	elif ship_speed != 0 and visible and not trail.is_emitting():
		trail.set_emitting(true)
		
	return ship_speed != 0

func _update_travel_route():
	if close_to_target(nav_route[0].position):
		if nav_route.size() > 1:
			nav_route.pop_front()
		else:
			nav_route = []
			ship_target_id = -1
			trail.set_emitting(false)

func close_to_target(target_position: Vector2) -> bool:
	if not target_position:
		return false
	
	var distance_to_target = global_transform.origin.distance_squared_to(target_position)
	return distance_to_target <= pow(max(160, ship_speed), 2)

func set_visible(in_data) -> void:
	if typeof(in_data) == TYPE_BOOL:
		visible = in_data
	else:
		visible = planet_system == in_data

func get_random_point_in_site() -> Vector2:
	
	var bound_left = INF
	var bound_right = -INF
	var bound_top = INF
	var bound_bottom = -INF
	
	var bound_limit = 30000
	
	var polygon_shrinked = []
	for point in parent.planet_convex_hull:
		var point_shrinked = Utils.get_midpoint(point, Vector2.ZERO)
		polygon_shrinked.append(point_shrinked + parent.position)
		
		bound_left = min(bound_left, point_shrinked.x)
		bound_right = max(bound_right, point_shrinked.x)
		bound_top = min(bound_top, point_shrinked.y)
		bound_bottom = max(bound_bottom, point_shrinked.y)
	
	var random_point: Vector2 = Vector2.INF
	while random_point == Vector2.INF:
		var x = WorldGenerator.rng.randf_range(max(bound_left, -bound_limit), min(bound_right, bound_limit))
		var y = WorldGenerator.rng.randf_range(max(bound_top, -bound_limit), min(bound_bottom, bound_limit))
		var _random_point: Vector2 = Vector2(x, y)
		if Geometry.is_point_in_polygon(_random_point, polygon_shrinked):
			random_point = _random_point
	return random_point
	
