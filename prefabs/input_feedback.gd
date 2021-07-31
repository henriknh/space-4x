extends Spatial

export var ray_length: float = 1000

onready var camera = get_node('/root/GameScene/CameraRoot/Camera') as Camera
onready var node_selection: MeshInstance = $Selection
onready var node_hover: MeshInstance = $Hover
onready var node_move_indicator: MeshInstance = $MoveIndicator

func _ready():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var polygon = Tile.generate_polygon()
	
	var p0 = Vector3.ZERO
	for i in range(0, polygon.size() - 1):
		var p1 = Vector3(polygon[i].x, 0, polygon[i].y)
		var p2 = Vector3(polygon[i + 1].x, 0, polygon[i + 1].y)
		# Top
		st.add_vertex(p0)
		st.add_vertex(p1)
		st.add_vertex(p2)
		
		# First side
		st.add_vertex(p2)
		st.add_vertex(p1 + Vector3.DOWN)
		st.add_vertex(p2 + Vector3.DOWN)

		# Second side
		st.add_vertex(p1)
		st.add_vertex(p1 + Vector3.DOWN)
		st.add_vertex(p2)

		# Bottom
		st.add_vertex(p0 + Vector3.DOWN)
		st.add_vertex(p1 + Vector3.DOWN)
		st.add_vertex(p2 + Vector3.DOWN)
		
	node_selection.mesh = st.commit()
	node_hover.mesh = st.commit()
	
	node_selection.visible = false
	node_hover.visible = false
	
	var material_selection = SpatialMaterial.new()
	material_selection.flags_transparent = true
	material_selection.flags_do_not_receive_shadows = true
	material_selection.flags_disable_ambient_light = true
	material_selection.flags_unshaded = true
	material_selection.albedo_color = Color(1,1,1,0.2)
	node_selection.material_override = material_selection
	
	var material_hover = SpatialMaterial.new()
	material_hover.flags_transparent = true
	material_hover.flags_do_not_receive_shadows = true
	material_hover.flags_disable_ambient_light = true
	material_hover.flags_unshaded = true
	material_hover.albedo_color = Color(1,1,1,0.1)
	node_hover.material_override = material_hover
	
	GameState.connect("selection_changed", self, "update_selection")
	GameState.connect("hover_changed", self, "update_hover")
	
func update_selection():
	if GameState.selection:
		node_selection.visible = true
		node_selection.translation = GameState.selection.global_transform.origin
	else:
		node_selection.visible = false

func update_hover():
	if GameState.hover:
		node_hover.visible = true
		node_hover.translation = GameState.hover.global_transform.origin
	else:
		node_hover.visible = false

func _input(event: InputEvent):
	if not event is InputEventMouseMotion:
		return
	
	var can_move = false
	var raycast_tile = null

	if is_instance_valid(GameState.selection) and GameState.selection.has_node("States"):
		var states_node = GameState.selection.get_node("States")
		for state in states_node.get_children():
			if state.name == "Move":
				can_move = true
				break

	if can_move:
		var camera_from = camera.project_ray_origin(event.position)
		var camera_to = camera_from + camera.project_ray_normal(event.position) * ray_length
		var space_state = get_world().direct_space_state
		var raycast_result = space_state.intersect_ray(camera_from, camera_to, [], 4, false, true)
		
		if raycast_result:
			raycast_tile = raycast_result.collider.get_parent() as Tile

			var st = SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_LINE_STRIP)
			for point in Nav.get_nav_path(GameState.selection, raycast_tile):
				st.add_vertex(point)
			node_move_indicator.mesh = st.commit()

	node_move_indicator.visible = can_move and raycast_tile

	var material = SpatialMaterial.new()
	material.albedo_color = Color(1,0,0,1)
	node_move_indicator.material_override = material
