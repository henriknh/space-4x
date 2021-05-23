extends Entity

class_name Ship

var parent: Entity
signal parent_changed

var ship_count: int = 1

onready var node_mesh: MeshInstance = $Mesh

func _ready():
	print('ship')
	add_to_group('Persist')
	add_to_group('Ship')
	
	modules.append({'class': ModuleShipMovement.new().init(self), 'state': Enums.ship_states.moving})
	modules.append({'class': ModuleCorporationColor.new().init(self), 'state': null})
	modules.append({'class': ModuleShipLineOfSight.new().init(self), 'state': null})

func _process(delta):
	for module in modules:
		if module.state == state and module.class.has_method('process'):
			module.class.process(delta)

func set_parent(entity: Entity):
	parent = entity
	emit_signal("parent_changed")
