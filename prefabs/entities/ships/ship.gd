extends Entity

const ship_texture_combat = preload("res://assets/ship_combat.png")
const ship_texture_explorer = preload("res://assets/ship_explorer.png")
const ship_texture_miner = preload("res://assets/ship_miner.png")

class_name Ship

var ship_type: int = -1
var ship_speed: int = 100
var hitpoints: int = 10

onready var node_sprite: Sprite = $Sprite
onready var node_trail: Node2D = $Trail
onready var node_obstacle_handler = $ObstacleHandler
onready var node_raycast = $RayCast
onready var node_animation: AnimationPlayer = $AnimationPlayer

var parent: Entity
var neighbors: Array
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
	if state == Enums.ship_states.disable:
		if move(parent.position):
			parent.planet_disabled_ships += 1
			return queue_free()
	
	elif state == Enums.ship_states.travel:
		if nav_route.size() == 0 and process_target >= 0:
			nav_route = Nav.get_route(self, process_target)
		
		#move()
		#_update_travel_route()
		
		if nav_route.size() == 0:
			process_target = -1
			state = Enums.ship_states.idle
	
	elif state == Enums.ship_states.rebuild and ((self.target and target_reached) or true):
			
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
	
	elif ship_type != Enums.ship_types.disabled:
		move(Boid.process(self))
	
	.process(delta)

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

func move(to: Vector2) -> bool:
	var speed = Consts.SHIP_SPEED_IDLE if state == Enums.ship_states.idle else ship_speed
	var diff: Vector2 = to - position
	
	acceleration += steer(diff.normalized())
	
	if node_obstacle_handler.is_obsticle_ahead():
		acceleration = steer(node_obstacle_handler.obsticle_avoidance()) * (speed / 4)
	
	var dist_to_target = diff.length()
	var near_target_dist = speed * 2
	var near_target = dist_to_target <= near_target_dist
	target_reached = state != Enums.ship_states.idle and approach_target and dist_to_target <= 1
	
	if target_reached:
		velocity = Vector2.ZERO
		acceleration = Vector2.ZERO
	else:
		velocity += acceleration * delta
		
	if approach_target and near_target:
		var nearness_factor = max(dist_to_target / near_target_dist, 0.1)
		velocity = velocity.clamped(speed * nearness_factor)
	else:
		velocity = velocity.clamped(speed)

	rotation = velocity.angle()
	translate(velocity * delta)
	
	_update_trail()
	
	return target_reached

func steer(var target: Vector2) -> Vector2:
	var speed = Consts.SHIP_SPEED_IDLE if state == Enums.ship_states.idle else ship_speed
	target *= ship_speed
	var steer = target - velocity
	return steer.normalized() * (speed / 10)

func set_visible(in_data) -> void:
	.set_visible(in_data)
	if not visible:
		node_trail.set_emitting(false)
		
func _update_trail() -> void:
	if not visible:
		if node_trail.is_emitting():
			node_trail.set_emitting(false)
		return
	
	if target_reached and node_trail.is_emitting():
		node_trail.set_emitting(false)
	elif not node_trail.is_emitting():
		node_trail.set_emitting(true)
		node_trail.set_speed(ship_speed)

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

func _on_ship_entered(ship: Ship):
	if ship != self and parent and ship.parent == parent and ship.corporation_id == corporation_id:
		if not ship in neighbors:
			neighbors.append(ship)

func _on_ship_exited(ship: Ship):
	if ship in neighbors:
		neighbors.erase(ship)

func save():
	var save = .save()
	save["ship_type"] = ship_type
	save["ship_speed"] = ship_speed
	save["hitpoints"] = hitpoints
	return save
