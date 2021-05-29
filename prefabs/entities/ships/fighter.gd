extends Ship

const mesh = preload('res://prefabs/entities/ships/fighter.tres')

class_name Fighter

func _ready():
	add_to_group('Fighter')
	
	modules.append({'class': ModuleCorporationBorder.new().init(self, {'radius': 8 }), 'state': null})
	modules.append({'class': ModuleCombat.new().init(self, {'radius': 1 }), 'state': Enums.ship_states.idle})
	
	node_mesh.mesh = mesh
