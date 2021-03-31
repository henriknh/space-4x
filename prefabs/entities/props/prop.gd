extends Entity

class_name Prop

func create():
	entity_type = Enums.entity_types.prop
	.create()
	
func _ready():
	._ready()
	
func process(delta: float):
	.process(delta)

func kill():
	hitpoints = 0
	.kill()
