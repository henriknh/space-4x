extends Entity

class_name Planet

func create():
	.create()
	
func _ready():
	modules.append({'class': ModuleCorporationColor.new().init(self), 'state': null})
	._ready()

func save():
	var save = .save()
	return save
