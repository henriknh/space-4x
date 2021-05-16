extends Module

class_name ModuleShipMovement

var velocity: Vector3 = Vector3.ZERO
var move_to_id: int = -1
var move_to_path: PoolVector3Array = []
var move_to: Vector3 = Vector3.INF

func init(_entity: Entity, params: Dictionary = {}) -> Spatial:
	return .init(_entity, params)
	
func process(delta):
	if self.entity.state == Enums.ship_states.moving:
		move_to_target()

func set_target(entity: Entity):
	move_to_id = entity.id
	move_to_path = Nav.get_nav_path(self.entity.parent.id, move_to_id)
	self.entity.state = Enums.ship_states.moving
	EventQueue.add_event(2, self, "set_next_move_to")
	
func move_to_target():
	if move_to == Vector3.INF:
		return
	
	if handle_move_to_coords(move_to):
		if move_to_path.size() > 0:
			move_to_path.remove(0)
		move_to = Vector3.INF
		EventQueue.add_event(2, self, "set_next_move_to")
		
func set_next_move_to():
	if move_to_path.size() > 0:
		move_to = move_to_path[0]
	else:
		self.entity.state = Enums.ship_states.idle
		move_to_id = -1

func handle_move_to_coords(coords: Vector3 = Vector3.INF):
	if not coords or coords == Vector3.INF:
		return false
	
	var offset = coords - self.entity.translation
	var speed = clamp(offset.length(), 1, 25)
	
	self.entity.look_at(coords, Vector3.UP)
	self.entity.translation += offset.normalized() * speed * self.entity.get_process_delta_time()
	
	return Utils.equals(self.entity.translation, coords, 0.1)
