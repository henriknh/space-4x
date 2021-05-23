extends Entity

class_name Planet

var tile: Entity

func create():
	.create()
	
func _ready():
	add_to_group('Persist')
	add_to_group('Planet')
	
	modules.append({'class': ModuleCorporationColor.new().init(self), 'state': null})
	._ready()

func save():
	var save = .save()
	return save
