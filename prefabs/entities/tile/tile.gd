extends Entity

class_name Tile

onready var prefab_tile_overlay = preload("res://prefabs/entities/tile/tile_overlay/TileOverlay.tscn")
onready var node_collision: CollisionPolygon = $Area/CollisionPolygon

var neighbors: Array = []
var is_edge: bool = false
var polygon = generate_polygon()
var ships = []
signal ship_changed
var entity: Entity setget set_entity

const VERTEX_COLOR = Color(0, 0, 1, 0.1);

func _ready():
	add_to_group('Persist')
	add_to_group('Tile')
	
	node_collision.polygon = polygon

static func generate_polygon():
	var _polygon = []
	for i in range(6):
		var angle_deg = 60 * i - 30
		var angle_rad = PI / 180 * angle_deg
		_polygon.append(Vector2(Consts.TILE_SIZE * cos(angle_rad), Consts.TILE_SIZE * sin(angle_rad)))
	_polygon.append(_polygon[0])
	return _polygon
	
func get_global_polygon():
	var _polygon = []
	for point in polygon:
		_polygon.append(Vector2(point.x + translation.x, point.y + translation.z))
	return _polygon

func get_coords() -> Vector2:
	var x = translation.x / (Consts.TILE_SIZE * sqrt(3)) * 2
	var z = translation.z / Consts.TILE_SIZE / 1.5
	return Vector2(int(round(x)), int(round(z)))

func _on_mouse_entered():
	GameState.hover = self
	
func _on_mouse_exited():
	GameState.hover = null
	
func are_neighbors(to_check: Tile) -> bool:
	return to_check in neighbors
	
func get_neighbor_in_dir(coords: Vector2) -> Tile:
	for neighbor in neighbors:
		if coords.is_equal_approx(neighbor.get_coords() - get_coords()):
			return neighbor
	return null
	
func has_neighbor_in_dir(coords: Vector2) -> bool:
	return get_neighbor_in_dir(coords) != null

func _on_body_entered(body: Entity):
	if body is Ship and not body in ships:
		ships.append(body)
		body.parent = self
		emit_signal('ship_changed')
	
#	if ships.size() > 0 and $TileOverlayContainer.get_child_count() == 0:
#		$TileOverlayContainer.add_child(prefab_tile_overlay.instance())

func _on_body_exited(body):
	if body is Ship and body in ships:
		if body.parent == self:
			body.parent = null
		ships.erase(body)
		emit_signal('ship_changed')
	
	if ships.size() == 0 and $TileOverlayContainer.get_child_count() == 1:
		for child in $TileOverlayContainer.get_children():
			$TileOverlayContainer.remove_child(child)

func _on_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if get_parent().get_parent() != GameState.planet_system:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			GameState.selected_tile = self
		elif event.button_index == BUTTON_RIGHT and GameState.selection and GameState.selection.has_node("States"):
			var states_node = GameState.selection.get_node("States")
			for state in states_node.get_children():
				if state.name == "Move":
					GameState.selection.target = self
					states_node.set_state(states_node.get_node("Move" as NodePath))

func set_entity(_entity: Entity):
	entity = _entity
	emit_signal("entity_changed")
