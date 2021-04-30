extends Entity

class_name Ship

var parent: Entity

var to: Vector3

func _ready():
	EventQueue.add_event(Random.randf() * 2 + 1, self, "patrol")

func patrol():
	return
	var neighbors = (parent as Tile).neighbors
	if neighbors:
		var next = neighbors[Random.randi() % neighbors.size()]
		to = next.translation

func _process(delta):
	var reached = handle_move_to_coords(to)

	if reached:
		to = Vector3.INF
		EventQueue.add_event(Random.randf() * 2 + 1, self, "patrol")

func handle_move_to_coords(coords: Vector3 = Vector3.INF):
	if not coords or coords == Vector3.INF:
		return false
	
	look_at(to, Vector3.UP)
	translation = lerp(translation, to, get_process_delta_time())
	
	return Utils.equals(translation, to)
func set_parent(node: Entity):
	parent = node
