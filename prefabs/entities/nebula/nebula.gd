extends Entity

class_name Nebula

onready var mesh_node: MeshInstance = $Mesh
onready var is_toxic = Random.randf() <= 0.33

func _ready():
	add_to_group('Persist')
	add_to_group('Nebula')
	
	if is_toxic:
		mesh_node.material_override = preload("res://prefabs/entities/nebula/material_toxic.tres")
	else:
		mesh_node.material_override = preload("res://prefabs/entities/nebula/material_normal.tres")
