extends Ship

const mesh = preload('res://prefabs/entities/ships/carrier.tres')

class_name Carrier

func _ready():
	add_to_group('Carrier')
	
	modules.append({'class': ModuleCorporationBorder.new().init(self, {'radius': 20 }), 'state': null})
	
	node_mesh.mesh = mesh
