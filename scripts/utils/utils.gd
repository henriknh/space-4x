extends Node

onready var is_mobile = OS.get_name() in ['Android']

func equals(a, b, elipse = 100) -> bool:
	if typeof(a) == TYPE_VECTOR2:
		if (a as Vector2).distance_squared_to(b) < pow(elipse, 2):
			return true
	
	return false
	
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

func merge_polygons_by_edge(p1: Array, p2: Array) -> Array:
		
	p1 = p1.duplicate()
	p2 = p2.duplicate()
	if equals(p1[0], p1[p1.size() - 1]):
		p1.remove(p1.size() - 1)
	if equals(p2[0], p2[p2.size() - 1]):
		p2.remove(p2.size() - 1)
	
	
	var common_idx: int = -1
	for i in range(p1.size()):
		if array_has(p1[i], p2):
			common_idx = array_idx(p1[i], p1)
	
	if common_idx == -1:
		return [p1, p2]
	
	var s = common_idx
	var e = common_idx
	
	while true:
		var s_test = (s - 1 + p1.size()) % p1.size()
		if array_has(p1[s_test], p2):
			s = s_test
		else:
			break
	
	while true:
		var e_test = (e + 1 + p1.size()) % p1.size()
		if array_has(p1[e_test], p2):
			e = e_test
		else:
			break
	
	# Make both polygons go the same direction
	var s_p2 = array_idx(p1[s], p2)
	var e_p2 = array_idx(p1[e], p2)
	if s > e and s_p2 < e_p2:
		p2.invert()
		var t = p2[p2.size() - 1]
		p2.remove(p2.size() - 1)
		p2.insert(0, t)
	
	var s_next = (s + 1 + p1.size()) % p1.size()
	var start = p1[s]
	var end = p1[e]
	var jump = (e - s - 1) if s < e else abs(s - (p1.size() - 1) - e)
	
	# Make start the first item in polygon2
	while not equals(p2[0], start):
		var t = p2[0]
		p2.remove(0)
		p2.append(t)
	
	# If end is not where it is expected in polygon2, it must be inverted
	if not equals(end, p2[jump % p2.size()]):
		p2.invert()
		p2.remove(p2.size() - 1)
		p2.insert(0, start)
	
	# Remove all inbetweeners from polygon2
	while not equals(p2[0], end):
		p2.remove(0)
	p2.remove(0)

	# Remove all inbetweeners from polygon1
	if (jump > 0):
		while not equals(p1[s_next % p1.size()], end):
			p1.remove(s_next)
			e =  (e - 1 + p1.size()) % p1.size()

	# Move remaining points in polygon2 to gap in polygon1
	while p2.size() > 0:
		var t = p2[0]
		p2.remove(0)
		p1.insert(s_next, t)
	
	# Make a looping polygon again
	p1.append(p1[0])
	
	return [p1]
	
func calculate_angle(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	# https://manivannan-ai.medium.com/find-the-angle-between-three-points-from-2d-using-python-348c513e2cd
	var ang = rad2deg(atan2(p3.y - p2.y, p3.x - p2.x) - atan2(p1.y - p2.y, p1.x - p2.x))
	return ang# + 360 if ang < 0 else ang
	# https://riptutorial.com/math/example/25158/calculate-angle-from-three-points
