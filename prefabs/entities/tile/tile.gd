extends Entity

class_name Tile

onready var node_collision: CollisionPolygon = $Area/CollisionPolygon
onready var node_mesh: MeshInstance = $Mesh

var neighbors: Array = []
var is_edge: bool = false
var polygon = []
var ships = []
var entity: Entity

const VERTEX_COLOR = Color(0, 0, 1, 0.1);

func _ready():
	add_to_group('Persist')
	add_to_group('Tile')
	
	node_collision.polygon = polygon
	node_mesh.scale.x = Consts.TILE_SIZE
	node_mesh.scale.z = Consts.TILE_SIZE
	
	var timer: Timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "spawn")
	timer.wait_time = 0.5
	add_child(timer)
	timer.start()

func generate_polygon():
	for i in range(6):
		polygon.append(pointy_hex_corner(Consts.TILE_SIZE, i))
	polygon.append(polygon[0])
	
func spawn():
	for _i in range(Random.randi() % 2):
		pass
		for _j in range(4):
			var s = Instancer.ship(0,Random.randi() % 5,self)
			#EventQueue.add_event(Random.randf(), get_node('/root/GameScene'), "call_deferred", ["add_child", s])
			get_node('/root/GameScene').call_deferred("add_child", s)
	
func pointy_hex_corner(size, i) -> Vector2:
	var angle_deg = 60 * i - 30
	var angle_rad = PI / 180 * angle_deg
	return Vector2(size * cos(angle_rad), size * sin(angle_rad))

func get_coords() -> Vector2:
	var x = translation.x / (Consts.TILE_SIZE * sqrt(3)) * 2
	var z = translation.z / Consts.TILE_SIZE / 1.5
	return Vector2(int(round(x)), int(round(z)))

func _on_mouse_entered():
	print('hover tile')
	print(self)
	print(get_coords())
	print(neighbors)
	
	node_mesh.scale = Vector3.ONE * Consts.TILE_SIZE * 0.8

func _on_mouse_exited():
	pass # Replace with function body.
	
	node_mesh.scale = Vector3.ONE * Consts.TILE_SIZE
	
func are_neighbors(to_check: Tile) -> bool:
	return to_check in neighbors
	
func has_neighbors_in_dir(coords: Vector2) -> bool:
	for neighbor in neighbors:
		if (neighbor.get_coords() - get_coords()) == coords:
			return true
	return false

func _on_area_entered(area):
	var node = area.get_parent()
	if node is Ship and not node in ships:
		ships.append(node)
		print(ships.size())

func _on_area_exited(area):
	var node = area.get_parent()


func _on_body_entered(body):
	if body is Ship and not body in ships:
		ships.append(body)
		body.set_parent(self)

func _on_body_exited(body):
	if body is Ship and body in ships:
		if body.parent == self:
			body.set_parent(null)
		ships.erase(body)

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			GameState.set_selection(self)
		elif event.button_index == BUTTON_RIGHT:
			if GameState.get_selection():
				for ship in GameState.get_selection().ships:
					for module in ship.modules:
						if module.class is ModuleShipMovement:
							module.class.set_target(self)
