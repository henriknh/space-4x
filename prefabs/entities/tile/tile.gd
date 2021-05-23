extends Entity

class_name Tile

onready var node_collision: CollisionPolygon = $Area/CollisionPolygon
onready var node_mesh: MeshInstance = $Mesh
onready var node_border: CSGCombiner = $Border
onready var node_polygon: CSGPolygon = $Border/CSGPolygon
onready var node_polygon_deflated: CSGPolygon = $Border/CSGPolygonDeflated

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
	
	var material_mesh = SpatialMaterial.new()
	material_mesh.flags_transparent = true
	material_mesh.flags_unshaded = true
	material_mesh.flags_do_not_receive_shadows = true
	material_mesh.flags_disable_ambient_light = true
	material_mesh.albedo_color = Color(1,1,1,0)
	
	node_mesh.material_override = material_mesh
	node_mesh.scale.x = Consts.TILE_SIZE * 0.96
	node_mesh.scale.z = Consts.TILE_SIZE * 0.96
	
	
	var material_border = SpatialMaterial.new()
	material_border.flags_transparent = true
	material_border.flags_unshaded = true
	material_border.flags_do_not_receive_shadows = true
	material_border.flags_disable_ambient_light = true
	material_border.albedo_color = Color(1,1,1,0)
	
	node_border.material_override = material_border
	node_polygon.polygon = polygon
	node_polygon_deflated.polygon = Geometry.offset_polygon_2d(polygon, -0.2)[0]

func generate_polygon():
	for i in range(6):
		polygon.append(pointy_hex_corner(Consts.TILE_SIZE, i))
	polygon.append(polygon[0])
	
func get_global_polygon():
	var _polygon = []
	for p in polygon:
		_polygon.append(Vector2(p.x + translation.x, -(p.y + translation.z)))
	return _polygon
	
func pointy_hex_corner(size, i) -> Vector2:
	var angle_deg = 60 * i - 30
	var angle_rad = PI / 180 * angle_deg
	return Vector2(size * cos(angle_rad), size * sin(angle_rad))

func get_coords() -> Vector2:
	var x = translation.x / (Consts.TILE_SIZE * sqrt(3)) * 2
	var z = translation.z / Consts.TILE_SIZE / 1.5
	return Vector2(int(round(x)), int(round(z)))

func _on_mouse_entered():
	if get_parent().get_parent() != GameState.curr_planet_system:
		return
	$AnimationPlayer.play("Hover")
	
func _on_mouse_exited():
	if get_parent().get_parent() != GameState.curr_planet_system:
		return
	$AnimationPlayer.play_backwards("Hover")
	
func are_neighbors(to_check: Tile) -> bool:
	return to_check in neighbors
	
func has_neighbors_in_dir(coords: Vector2) -> bool:
	for neighbor in neighbors:
		if (neighbor.get_coords() - get_coords()) == coords:
			return true
	return false

func _on_body_entered(body):
	if body is Ship and not body in ships:
		ships.append(body)
		body.set_parent(self)
		
	if body is Planet:
		Nav.update_weight(id, 10000)
	

func _on_body_exited(body):
	if body is Ship and body in ships:
		if body.parent == self:
			body.set_parent(null)
		ships.erase(body)

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if get_parent().get_parent() != GameState.curr_planet_system:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			GameState.set_selection(self)
		elif event.button_index == BUTTON_RIGHT:
			if GameState.get_selection():
				for ship in GameState.get_selection().ships:
					for module in ship.modules:
						if module.class is ModuleShipMovement:
							module.class.set_target(self)
