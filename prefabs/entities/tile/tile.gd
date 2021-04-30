extends Entity

class_name Tile

onready var node_collision: CollisionPolygon = $Area/CollisionPolygon
onready var node_mesh: MeshInstance = $Mesh

var neighbors: Array = []
var polygon = []
var ships = []
var entity: Entity

const VERTEX_COLOR = Color(0, 0, 1, 0.1);

func _ready():
	add_to_group('Persist')
	add_to_group('Tile')
	
	for i in range(6):
		polygon.append(pointy_hex_corner(Consts.TILE_SIZE, i))
	polygon.append(polygon[0])
	
	node_collision.polygon = polygon
	node_mesh.scale.x = Consts.TILE_SIZE
	node_mesh.scale.z = Consts.TILE_SIZE
	
	var timer: Timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "spawn")
	timer.wait_time = 0.5
	add_child(timer)
	timer.start()
	
func spawn():
	for i in range(0):
		var s = Instancer.ship(0,0,self)
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


func _on_body_entered(body):
	if body.has_method('set_parent'):
		body.set_parent(self)
	
func are_neighbors(to_check: Tile) -> bool:
	return to_check in neighbors
