extends Entity

class_name Ship

var parent: Entity
signal parent_changed

var modules = []
var state: int = Enums.ship_states.idle setget set_state

func _ready():
	modules.append({'class': ModuleShipMovement.new().init(self), 'state': Enums.ship_states.moving})
	modules.append({'class': ModuleShipCorporation.new().init(self), 'state': null})
	modules.append({'class': ModuleShipLineOfSight.new().init(self), 'state': null})

func _process(delta):
	for module in modules:
		if module.state == state and module.class.has_method('process'):
			module.class.process(delta)

func set_state(_state):
	state = _state
	set_process(!!state)

func set_parent(entity: Entity):
	parent = entity
	emit_signal("parent_changed")
