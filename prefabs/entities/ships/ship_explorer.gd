extends Ship

class_name ShipExplorer

var is_colonizing = false
var explore_position: Vector2 = Vector2.INF 

func create():
	ship_type = Enums.ship_types.explorer
	hitpoints = Consts.SHIP_HITPOINTS_EXPLORER
	ship_speed = Consts.SHIP_SPEED_EXPLORER
	.create()
	
func _ready():
	add_to_group('Explorer')
	._ready()

func process(delta: float):
	if state == Enums.ship_states.idle and parent and parent.corporation_id == 0:
		self.target = parent
		state = Enums.ship_states.colonize
	
	if state == Enums.ship_states.colonize and self.target.corporation_id != 0:
		state = Enums.ship_states.idle
		self.target = null
	
	if state == Enums.ship_states.colonize and self.target.state == Enums.planet_states.colonize and self.target.process_target != corporation_id:
		state = Enums.ship_states.idle
		self.target = null
		
	if state == Enums.ship_states.colonize:
		
		if node_raycast.is_colliding() and node_raycast.get_collider() == self.target:
			var collision = move_and_collide(Vector2.ZERO, true, true, true)
			
			if collision and collision.collider == self.target:
				if self.target.state != Enums.planet_states.colonize:
					self.target.set_entity_process(Enums.planet_states.colonize, corporation_id, 1, Consts.PLANET_COLONIZE_INITIAL_PROGRESS)
				
				var target_dir = position.direction_to(self.target.position)
				look_at(position - target_dir)
				
				self.target.planet_explorer_ships += 1
				state = Enums.ship_states.colonizing
				
			else:
				move(node_raycast.get_collision_point())
		else:
			move(self.target.position)
	
	elif state == Enums.ship_states.colonizing:
		if parent.state != Enums.planet_states.colonize:
			kill()
	else:
		.process(delta)

func queue_free():
	if self.target.planet_explorer_ships > 0:
		self.target.planet_explorer_ships -= 1
	.queue_free()
