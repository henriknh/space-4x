extends Spatial

onready var mesh_node: MeshInstance = $MeshInstance
onready var rotation_speed = 15 + Random.randf() * 10

func _ready():
	rotate_z(deg2rad(5 + Random.randf() * 10))

func _physics_process(delta):
	mesh_node.rotate_y(delta / rotation_speed)

func set_mesh_scale(scale: float):
	mesh_node.mesh.radius = scale
	mesh_node.mesh.height = scale * 2
