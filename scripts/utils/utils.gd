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
		
func get_midpoint(p1: Vector2, p2: Vector2) -> Vector2:
	return Vector2((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)

func format_number(number: float) -> String:
	if number > 1000000000:
		return "%db" % int(number / 1000000000)
	elif number > 1000000:
		return "%dm" % int(number / 1000000)
	elif number > 1000:
		return "%dk" % int(number / 1000)
	else:
		return number as String
