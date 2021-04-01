extends Entity

class_name Prop

var prop_type: int = -1

func create():
	entity_type = Enums.entity_types.prop
	.create()
	
func _ready():
	._ready()
	
func process(delta: float):
	.process(delta)

func kill():
	.kill()

func save():
	var save = .save()
	save["prop_type"] = prop_type
	return save
