extends Entity

class_name Nebula

var group_id: int

func _ready():
	add_to_group('Persist')
	add_to_group('Nebula')
	
	if not group_id:
		group_id = Instancer.group_id_counter
	
	if Random.randf() <= 0.33:
		$Particles.process_material = preload("res://prefabs/entities/nebula/particels_material_toxic.tres")
	else:
		$Particles.process_material = preload("res://prefabs/entities/nebula/particels_material_normal.tres")
