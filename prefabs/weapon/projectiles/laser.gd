extends Projectile

onready var node_mesh: MeshInstance = $Mesh
onready var node_material: SpatialMaterial = SpatialMaterial.new()

func _ready():
	node_material.flags_unshaded = true

func set_host(host: Entity) -> void:
	target = host.target
	node_material.albedo_color = Enums.corporation_colors[host.corporation_id]

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	
	st.add_vertex(Vector3.ZERO)
	st.add_vertex(target.global_transform.origin - global_transform.origin)
	
	st.generate_normals()
	st.index()
	
	node_mesh.mesh = st.commit()
	node_mesh.material_override = node_material
	
	inflict_damage()
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.5
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start()
