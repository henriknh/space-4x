extends Entity

const ship_texture_combat = preload("res://assets/ship_combat.png")
const ship_texture_explorer = preload("res://assets/ship_explorer.png")
const ship_texture_miner = preload("res://assets/ship_miner.png")

class_name Ship

onready var collision_shape = $CollisionShape
onready var sprite: Sprite = $Sprite
onready var trail: Node2D = $Trail
onready var node_obstacle_handler = $ObstacleHandler
onready var node_raycast = $RayCast

onready var velocity: Vector2 = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * ship_speed_max
onready var acceleration: Vector2 = Vector2.ZERO
onready var ship_idle_speed: float = 500

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
	
func _ready():
	if faction == 0:
		sprite.self_modulate = Enums.ship_colors[ship_type]
		trail.set_color(Enums.ship_colors[ship_type])
	else:
		sprite.self_modulate = Enums.player_colors[faction]
		trail.set_color(Enums.player_colors[faction])
	
	
	match ship_type:
		Enums.ship_types.combat:
			sprite.texture = ship_texture_combat
		Enums.ship_types.explorer:
			sprite.texture = ship_texture_explorer
		Enums.ship_types.miner:
			sprite.texture = ship_texture_miner
	trail.set_texture(sprite.texture)
	if ship_type == Enums.ship_types.disabled:
		var timer = Timer.new()
		timer.connect("timeout", self, "_rotate_sprite_texture")
		timer.wait_time = 1
		timer.one_shot = false
		add_child(timer)
		timer.start()
	
	._ready()
	
func process(delta: float):

	if state != Enums.ship_states.idle:
		if idle_target != Vector2.INF:
			idle_target = Vector2.INF

	if state == Enums.ship_states.disable:
		if not move(parent.position):
			parent.planet_disabled_ships += 1
			return queue_free()
	
	elif state == Enums.ship_states.travel:
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
		move()
	else:
		.process(delta)
	
func kill():
	hitpoints = 0
	queue_free()
	
func clear():
	process_target = -1 
	nav_route = [Nav.get_route(self, process_target)]

func move(target: Vector2 = Vector2.INF, decrease_speed: bool = true) -> bool:
	if target == Vector2.INF:
		var boids_target = Boid.process(self)
		if boids_target != Vector2.ZERO:
			acceleration += steer(boids_target)
	else:
		acceleration += steer(_calc_acceleration_to_target(target))
		
	if node_obstacle_handler.is_obsticle_ahead():
		acceleration += steer(node_obstacle_handler.obsticle_avoidance()) * Consts.SHIP_AVOIDANCE_FORCE
	
	velocity += acceleration * delta
	velocity = velocity.clamped(ship_speed_max)
	rotation = velocity.angle()
	
	translate(velocity * delta)
	
	var moving = velocity != Vector2.ZERO
	
	if visible:
		if not moving and trail.is_emitting():
			trail.set_emitting(false)
		elif not trail.is_emitting():
			trail.set_emitting(true)
	
	return moving
	
func steer(var target):
	target *= ship_speed_max
	var steer = target - velocity
	steer = steer.normalized() * Consts.SHIP_STEER_FORCE
	return steer

func _calc_acceleration_to_target(target: Vector2) -> Vector2:
	var acceleration: Vector2 = Vector2.ZERO
	var distance_to_target: float = position.distance_squared_to(target)
	var break_threashold: float = pow(ship_speed_max, 2)
	var de_accelerate: float = 0
	if distance_to_target <= break_threashold:
		de_accelerate = distance_to_target / break_threashold
		return -(target - position).normalized()# * (1 - de_accelerate)
	else:
		return (target - position).normalized()

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
	if not visible:
		trail.set_emitting(false)

func get_random_point_in_site() -> Vector2:
	var parent_hull = parent.planet_convex_hull
	var hull = parent_hull.duplicate() if parent_hull[0] == parent_hull[parent_hull.size() - 1] else parent_hull
	
	var hull_shrinked: PoolVector2Array = []
	for point in hull:
		var point_shrinked = point * 0.8
		hull_shrinked.append(point_shrinked + parent.position)
	
	var distance = Consts.PLANET_SYSTEM_RADIUS * Random.randf()
	var angle = 2 * PI * Random.randf()
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

func _rotate_sprite_texture():
	print('_rotate_disabled_sprite')
	if sprite.texture == ship_texture_combat:
		sprite.texture = ship_texture_explorer
	elif sprite.texture == ship_texture_explorer:
		sprite.texture = ship_texture_miner
	elif sprite.texture == ship_texture_miner:
		sprite.texture = ship_texture_combat

func set_parent(planet: Entity) -> void:
	if parent:
		node_obstacle_handler.remove_exception(parent.node_planet_area)
	parent = planet
	node_obstacle_handler.add_exception(parent.node_planet_area)
