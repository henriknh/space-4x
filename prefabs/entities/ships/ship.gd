extends Entity

class_name Ship

# Temporary
var nav_route = []
var idle_target: Vector2

func create():
	entity_type = Enums.entity_types.ship
	label = NameGenerator.get_name_ship()
	
	if hitpoints_max == -1:
		hitpoints_max = 50
	
	if asteroid_rocks_max < 0:
		asteroid_rocks_max = 0
	if titanium_max < 0:
		titanium_max = 0
	if titanium_max < 0:
		titanium_max = 10
	if ship_cargo_size < 0:
		ship_cargo_size = asteroid_rocks_max + titanium_max
	
	.create()
	
func ready():
	var model = get_node("Sprite") as Sprite
	var trail = get_node("Trail") as Node2D
	
	if faction == 0:
		model.self_modulate = Enums.ship_colors[ship_type]
		trail.set_color(Enums.ship_colors[ship_type])
	else:
		model.self_modulate = Enums.player_colors[faction]
		trail.set_color(Enums.player_colors[faction])
	.ready()
		
func process(delta: float):
	if state == Enums.ship_states.travel:
		if nav_route.size() == 0 and process_target >= 0:
			nav_route = Nav.get_route(self, process_target)
		
		move(nav_route[0].position)
		_update_travel_route()
		
		if nav_route.size() == 0:
			process_target = -1
			state = Enums.ship_states.idle
			
	elif state == Enums.ship_states.rebuild:
		if not move(parent.position):
			
			# Replace old ship instance with disabled
			if ship_type != Enums.ship_types.disabled:
				get_node('/root/GameScene').add_child(Instancer.ship(Enums.ship_types.disabled, self))
				return queue_free()
			process_time += delta
			
			if get_process_progress() > 1:
				process_time = 0
				ship_type = process_target
				state = Enums.ship_states.idle
				
				get_node('/root/GameScene').add_child(Instancer.ship(ship_type, self))
				return queue_free()
	
	elif state == Enums.ship_states.idle and ship_type != Enums.ship_types.disabled:
		if not idle_target or close_to_target(idle_target):
			idle_target = get_random_point_in_site()
		
		move(idle_target)
	else:
		.process(delta)
	
func kill():
	hitpoints = 0
	queue_free()
	
func clear():
	process_target = -1 
	nav_route = [Nav.get_route(self, process_target)]

func move(target_position: Vector2, decrease_speed: bool = true, turn_direction: int = 0) -> bool:
	if turn_direction == 0:
		rotation += get_angle_to(target_position) * Consts.SHIP_TURN_SPEED * delta
	elif turn_direction < 0:
		rotation += get_angle_to(target_position) * Consts.SHIP_TURN_SPEED * delta

	var ship_forward_dir = Vector2(cos(rotation), sin(rotation)).normalized()

	position += ship_forward_dir * ship_speed * delta

	return _calc_speed(target_position, decrease_speed)

func _calc_speed(target_position: Vector2, decrease_speed: bool) -> bool:
	if decrease_speed and close_to_target(target_position):
		if nav_route.size() <= 1 and ship_speed >= 0:
			ship_speed -= ship_speed_max * delta
		if ship_speed < 0:
			ship_speed = 0
	elif ship_speed > ship_speed_max:
		ship_speed = ship_speed_max
	elif ship_speed < ship_speed_max:
		ship_speed += ship_speed_max * Consts.SHIP_ACCELERATION_FACTOR * delta
	
	var trail = get_node("Trail") as Node2D
	if ship_speed == 0 and trail.is_emitting():
		trail.set_emitting(false)
	elif ship_speed != 0 and visible and not trail.is_emitting() and planet_system == GameState.get_planet_system():
		trail.set_emitting(true)
	
	return ship_speed != 0

func _update_travel_route():
	if close_to_target(nav_route[0].position):
		if nav_route.size() > 1:
			nav_route.pop_front()
		else:
			nav_route = []
			process_target = -1

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
	var parent_hull = parent.planet_convex_hull
	var hull = parent_hull.duplicate() if parent_hull[0] == parent_hull[parent_hull.size() - 1] else parent_hull
	
	var hull_shrinked: PoolVector2Array = []
	for point in hull:
		var point_shrinked = point * 0.8
		hull_shrinked.append(point_shrinked + parent.position)
	
	var distance = Consts.PLANET_SYSTEM_RADIUS * WorldGenerator.rng.randf()
	var angle = 2 * PI * WorldGenerator.rng.randf()
	var target = Vector2(distance * cos(angle), distance * sin(angle)) + parent.position
	
	
	# Check convex hull segments
	var prev = hull_shrinked[0]
	var curr = null
	for i in range(1, hull_shrinked.size()):
		curr = hull_shrinked[i]
		var intersects = Geometry.segment_intersects_segment_2d(parent.position, target, prev, curr)
		if intersects != null:
			target = intersects
		prev = curr
	
	# Check planet system bounds
	var intersects_circle = Geometry.segment_intersects_circle(parent.position, target, Vector2.ZERO, Consts.PLANET_SYSTEM_RADIUS)
	if intersects_circle != -1:
		target = (target - parent.position) * intersects_circle + parent.position

	return target
