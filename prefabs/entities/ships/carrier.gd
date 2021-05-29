extends Ship

const mesh = preload('res://prefabs/entities/ships/carrier.tres')

class_name Carrier

func _ready():
	add_to_group('Carrier')
	
	modules.append({'class': ModuleCorporationBorder.new().init(self, {'radius': 20 }), 'state': null})
	modules.append({'class': ModuleCombat.new().init(self, {'radius': 2 }), 'state': Enums.ship_states.idle})
	
	node_mesh.mesh = mesh
