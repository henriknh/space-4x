extends Spatial

class_name Module

var entity: Entity

func init(_entity: Entity, params: Dictionary = {}) -> Spatial:
	self.entity = _entity
	return self

func process(delta):
	pass
