extends Entity

const ship_texture_combat = preload("res://assets/ship_combat.png")
const ship_texture_explorer = preload("res://assets/ship_explorer.png")
const ship_texture_miner = preload("res://assets/ship_miner.png")

class_name Ship

var ship_type: int = -1
var ship_speed: int = 100
var hitpoints: int = 0

onready var node_sprite: Sprite = $Sprite
onready var node_trail: Node2D = $Trail
onready var node_obstacle_handler = $ObstacleHandler
onready var node_raycast = $RayCast
onready var node_animation: AnimationPlayer = $AnimationPlayer

var parent: Entity
onready var velocity: Vector2 = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * ship_speed
onready var acceleration: Vector2 = Vector2.ZERO
var target: Node2D = null setget set_target
var target_reached: bool = false
var approach_target: bool = false

# Temporary
var nav_route = []

func create():
	entity_type = Enums.entity_types.ship

	.create()
	
func _ready():
	if corporation_id == Consts.PLAYER_CORPORATION:
		node_sprite.self_modulate = Enums.ship_colors[ship_type]
		node_trail.set_color(Enums.ship_colors[ship_type])
	else:
		node_sprite.self_modulate = Enums.corporation_colors[corporation_id]
		node_trail.set_color(Enums.corporation_colors[corporation_id])
	
	
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
		#_update_travel_route()
		
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

func is_dead() -> bool:
	return hitpoints <= 0

func set_target(_target: Entity):
	if target:
		node_obstacle_handler.remove_exception(target)
	
	target = _target
	target_reached = false
	
	if target:
		approach_target = not target.entity_type == Enums.entity_types.ship
		node_obstacle_handler.add_exception(target)

func move(target_pos: Vector2 = Vector2.INF) -> bool:
	
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
	var near_target = dist_to_target <= pow(ship_speed, 2)
	
	if approach_target and dist_to_target <= 1:
		velocity = Vector2.ZERO
	elif approach_target and near_target:
		velocity = target_diff * delta * 25
		if velocity.length() < 25:
			velocity = velocity.normalized() * 25
		pass
	else:
		velocity += acceleration * delta
	
	if state == Enums.ship_states.idle:
		velocity = velocity.clamped(Consts.SHIP_SPEED_IDLE)
	else:
		velocity = velocity.clamped(ship_speed)
	rotation = velocity.angle()
	translate(velocity * delta)
	
	target_reached = near_target and dist_to_target <= 1
	
	if visible:
		if not target_reached and node_trail.is_emitting():
			node_trail.set_emitting(false)
		elif not node_trail.is_emitting():
			node_trail.set_emitting(true)
			
	return target_reached

func steer(var target):
	if state == Enums.ship_states.idle:
		target *= Consts.SHIP_SPEED_IDLE
	else:
		target *= ship_speed
	var steer = target - velocity
	steer = steer.normalized() * Consts.SHIP_STEER_FORCE
	return steer

func set_visible(in_data) -> void:
	.set_visible(in_data)
	if not visible:
		node_trail.set_emitting(false)

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


func save():
	var save = .save()
	save["ship_type"] = ship_type
	save["ship_speed"] = ship_speed
	save["hitpoints"] = hitpoints
	return save
