extends Node

func array_has(obj, array: Array, elipse = 100) -> bool:
	if typeof(obj) == TYPE_VECTOR2:
		for a in array:
			if (a as Vector2).distance_squared_to(obj) < pow(elipse, 2):
				return true
		return false
		
	if typeof(obj) == TYPE_ARRAY:
		var has_obj = 0
		for ao in obj:
			if self.array_has(ao, array, elipse):
				has_obj += 1
		return has_obj == obj.size()
		
	else:
		return obj in array
		
func sort_entities(a: entity, b: entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b
