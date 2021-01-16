extends Node

onready var is_mobile = OS.get_name() in ['Android']

func equals(a, b, elipse = 100) -> bool:
	if typeof(a) == TYPE_VECTOR2:
		if (a as Vector2).distance_squared_to(b) < pow(elipse, 2):
			return true
	
	return false

func array_remove_duplicates(array: Array) -> Array:
	var new_array = []
	for object in array:
		if not Utils.array_has(object, new_array):
			new_array.append(object)
	return new_array
	
func array_idx(obj, array: Array, elipse = 0.01) -> int:
	for i in range(array.size()):
		if Utils.equals(obj, array[i], elipse):
			return i
	return -1
		
func array_has(obj, array: Array, elipse = 0.01) -> bool:
	if typeof(obj) == TYPE_VECTOR2:
		for a in array:
			if Utils.equals(obj, a, elipse):
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
	if number >= 1000000000:
		return "%db" % int(number / 1000000000)
	elif number >= 1000000:
		return "%dm" % int(number / 1000000)
	elif number >= 1000:
		return "%dk" % int(number / 1000)
	else:
		return number as String
	
func point_on_segment(point: Vector2, a: Vector2, b: Vector2, epsilon: float = 0.01) -> bool:
	return abs(a.distance_to(point) + point.distance_to(b) - a.distance_to(b)) < epsilon
	
func point_on_polyline(point: Vector2, polyline: Array) -> bool:
	var prev = polyline[0]
	for i in range(1, polyline.size()):
		var curr = polyline[i]
		
		var on_segment = point_on_segment(point, prev, curr)
		if on_segment:
			return true
		
		prev = curr
	return false

func min_distance_point_to_segment(_E: Vector2, _A: Vector2, _B: Vector2) -> float:
	
	var A = [_A.x, _A.y]
	var B = [_B.x, _B.y]
	var E = [_E.x, _E.y]
  
	# vector AB  
	var AB = [null, null];
	AB[0] = B[0] - A[0];
	AB[1] = B[1] - A[1];
  
	# vector BP  
	var BE = [null, null];
	BE[0] = E[0] - B[0];
	BE[1] = E[1] - B[1];
  
	# vector AP  
	var AE = [null, null];
	AE[0] = E[0] - A[0];
	AE[1] = E[1] - A[1];
  
	# Variables to store dot product  
  
	# Calculating the dot product  
	var AB_BE = AB[0] * BE[0] + AB[1] * BE[1];
	var AB_AE = AB[0] * AE[0] + AB[1] * AE[1];
  
	# Minimum distance from  
	# point E to the line segment  
	var reqAns = 0;
  
	# Case 1  
	if (AB_BE > 0) :
  
		# Finding the magnitude  
		var y = E[1] - B[1];
		var x = E[0] - B[0];
		reqAns = sqrt(x * x + y * y);
  
	# Case 2  
	elif (AB_AE < 0) :
		var y = E[1] - A[1];
		var x = E[0] - A[0];
		reqAns = sqrt(x * x + y * y);
  
	# Case 3  
	else:
  
		# Finding the perpendicular distance  
		var x1 = AB[0];
		var y1 = AB[1];
		var x2 = AE[0];
		var y2 = AE[1];
		var mod = sqrt(x1 * x1 + y1 * y1);
		reqAns = abs(x1 * y2 - y1 * x2) / mod;
	  
	return reqAns;
	
func point_position_on_segment(P, A, B):

	var a_to_p = [P.x - A.x, P.y - A.y]     # Storing vector A->P
	var a_to_b = [B.x - A.x, B.y - A.y]     # Storing vector A->B

	var atb2 = pow(a_to_b[0], 2) + pow(a_to_b[1], 2)  # **2 means "squared"
									  #   Basically finding the squared magnitude
									  #   of a_to_b

	var atp_dot_atb = a_to_p[0]*a_to_b[0] + a_to_p[1]*a_to_b[1]
									  # The dot product of a_to_p and a_to_b

	var t = atp_dot_atb / atb2              # The normalized "distance" from a to
									  #   your closest point

	return Vector2(A.x + a_to_b[0]*t, A.y + a_to_b[1]*t )
									  # Add the distance to A, moving
									  #   towards B
