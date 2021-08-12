extends Entity

class_name Asteroid

var group_id: int
	
func _ready():
	add_to_group('Persist')
	add_to_group('Asteroid')
	
	if not group_id:
		group_id = Instancer.group_id_counter
