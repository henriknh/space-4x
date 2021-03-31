extends Entity

const ship_texture_combat = preload("res://assets/ship_combat.png")
const ship_texture_explorer = preload("res://assets/ship_explorer.png")
const ship_texture_miner = preload("res://assets/ship_miner.png")

class_name Ship

onready var node_sprite: Sprite = $Sprite
onready var node_trail: Node2D = $Trail
onready var node_obstacle_handler = $ObstacleHandler
onready var node_raycast = $RayCast
onready var node_animation: AnimationPlayer = $AnimationPlayer

onready var velocity: Vector2 = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * ship_speed_max
onready var acceleration: Vector2 = Vector2.ZERO
onready var ship_idle_speed: float = 500
var target: Node2D = null setget set_target
var target_reached: bool = false
var approach_target: bool = false

# Temporary
var nav_route = []

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
	if faction == Consts.PLAYER_FACTION:
		node_sprite.self_modulate = Enums.ship_colors[ship_type]
		node_trail.set_color(Enums.ship_colors[ship_type])
	else:
		node_sprite.self_modulate = Enums.player_colors[faction]
		node_trail.set_color(Enums.player_colors[faction])
	
	
	match ship_type:
		Enums.ship_types.combat:
			node_sprite.texture = ship_texture_combat
		Enums.ship_types.explorer:
			node_sprite.texture = ship_texture_explorer
		Enums.ship_types.miner:
			node_sprite.texture = ship_texture_miner
	node_trail.set_texture(node_sprite.texture)
	if ship_type == Enums.ship_types.disabled:
		var timer = Timer.new()
		timer.connect("timeout", self, "_rotate_sprite_texture")
		timer.wait_time = 1
		timer.one_shot = false
		add_child(timer)
		timer.start()
	
	._ready()
	
func process(delta: float):

	if state == Enums.ship_states.disable and target_reached:
		parent.planet_disabled_ships += 1
		return kill()
	
	elif state == Enums.ship_states.travel:
		if nav_route.size() == 0 and process_target >= 0:
			nav_route = Nav.get_route(self, process_target)
		
		move()
		_update_travel_route()
		
		if nav_route.size() == 0:
			process_target = -1
			state = Enums.ship_states.idle
			
	elif state == Enums.ship_states.rebuild and target_reached:
			
			# Replace old ship instance with disabled
			if ship_type != Enums.ship_types.disabled:
				get_node('/root/GameScene').add_child(Instancer.ship(Enums.ship_types.disabled, self))
				return kill()
			process_time += delta
			
			if get_process_progress() > 1:
				process_time = 0
				ship_type = process_target
				state = Enums.ship_states.idle
				
				get_node('/root/GameScene').add_child(Instancer.ship(ship_type, self))
				return kill()
	
	elif ship_type != Enums.ship_types.disabled:
		move()
	
	.process(delta)
	
func kill():
	.kill()

func set_target(_target: Entity):
	if target:
		node_obstacle_handler.remove_exception(target)
	
	target = _target
	target_reached = false
	
	if target:
		approach_target = not target.entity_type == Enums.entity_types.ship
	
		if target.entity_type == Enums.entity_types.ship:
			node_obstacle_handler.add_exception(target)

func move(target_pos: Vector2 = Vector2.INF) -> void:
	
	var target_diff = Vector2.ZERO
	if target_pos != Vector2.INF:
		target_diff = target_pos - position
	elif target:
		target_diff = target.position - position
	
	if target_diff != Vector2.ZERO:
		acceleration += steer(target_diff.normalized())
	else:
		var boids_target = Boid.process(self)
		if boids_target != Vector2.ZERO:
			acceleration += steer(boids_target)
		
	if node_obstacle_handler.is_obsticle_ahead():
		acceleration += steer(node_obstacle_handler.obsticle_avoidance()) * Consts.SHIP_AVOIDANCE_FORCE
	
	
	var dist_to_target = target_diff.length_squared()
	var near_target = dist_to_target <= pow(ship_speed_max, 2)
	
	if approach_target and dist_to_target <= 1:
		velocity = Vector2.ZERO
	elif approach_target and near_target:
		velocity = target_diff * delta * 25
		if velocity.length() < 25:
			velocity = velocity.normalized() * 25
		pass
	else:
		velocity += acceleration * delta
	
	velocity = velocity.clamped(ship_speed_max)
	rotation = velocity.angle()
	translate(velocity * delta)
	
	target_reached = near_target and dist_to_target <= 1
	
	if visible:
		if not target_reached and node_trail.is_emitting():
			node_trail.set_emitting(false)
		elif not node_trail.is_emitting():
			node_trail.set_emitting(true)

func steer(var target):
	target *= ship_speed_max
	var steer = target - velocity
	steer = steer.normalized() * Consts.SHIP_STEER_FORCE
	return steer













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
		node_trail.set_emitting(false)

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
	if node_sprite.texture == ship_texture_combat:
		node_sprite.texture = ship_texture_explorer
	elif node_sprite.texture == ship_texture_explorer:
		node_sprite.texture = ship_texture_miner
	elif node_sprite.texture == ship_texture_miner:
		node_sprite.texture = ship_texture_combat

func set_parent(planet: Entity) -> void:
	if parent:
		node_obstacle_handler.remove_exception(parent.node_planet_area)
	parent = planet
	node_obstacle_handler.add_exception(parent.node_planet_area)
