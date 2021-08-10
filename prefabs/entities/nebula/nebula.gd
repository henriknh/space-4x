extends Entity

class_name Nebula

func _ready():
	add_to_group('Persist')
	add_to_group('Nebula')
	
	#print(Random.randf() <= 0.33)
	if Random.randf() <= 0.33:
		$Particles.process_material = preload("res://prefabs/entities/nebula/particels_material_toxic.tres")
	else:
		$Particles.process_material = preload("res://prefabs/entities/nebula/particels_material_normal.tres")
