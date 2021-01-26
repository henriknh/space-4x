extends Entity

class_name Prop

func create():
	entity_type = Enums.entity_types.object
	.create()
	
func ready():
	.ready()
	
func process(delta: float):
	.process(delta)

func kill():
	hitpoints = 0
	queue_free()
