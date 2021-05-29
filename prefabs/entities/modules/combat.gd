extends Module

class_name ModuleCombat


func init(_entity: Entity, params: Dictionary = {}) -> Spatial:
	.init(_entity, params)
	
	print(params.radius)
	
	return self
