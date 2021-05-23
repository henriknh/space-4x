extends Ship

const mesh = preload('res://prefabs/entities/ships/fighter.tres')

class_name Fighter

func _ready():
	add_to_group('Fighter')
	
	modules.append({'class': ModuleCorporationBorder.new().init(self, {'radius': 8 }), 'state': null})
	
	node_mesh.mesh = mesh
