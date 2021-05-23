extends Entity

class_name Asteroid

var tile: Tile

func create():
	.create()
	
func _ready():
	add_to_group('Persist')
	add_to_group('Asteroid')
	
	._ready()

func save():
	var save = .save()
	return save
