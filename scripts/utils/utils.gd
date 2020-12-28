extends Node

var elipse = 0.001

func array_has(obj, array: Array) -> bool:
	if typeof(obj) == TYPE_VECTOR2:
		for a in array:
			if (a as Vector2).distance_squared_to(obj) < pow(elipse, 2):
				return true
		return false
		
	if typeof(obj) == TYPE_ARRAY:
		var has_obj = 0
		for ao in obj:
			if self.array_has(ao, array):
				has_obj += 1
		return has_obj == obj.size()
		
	else:
		return obj in array
