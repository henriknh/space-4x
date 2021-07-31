extends Projectile

onready var node_mesh: MeshInstance = $Mesh

func _ready():
	scale = Vector3.ONE * 0.1
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start()
	
func set_target(entity: Entity) -> void:
	target = entity.target
	node_mesh.material_override = entity.get_node('Mesh').material_override
	look_at(target.global_transform.origin, Vector3.UP)

func _process(delta):
	translate(Vector3.FORWARD * delta * 50)

func _on_Area_body_entered(collider: Entity):
	if collider == target:
		inflict_damage()
		
		queue_free()
