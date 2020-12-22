extends Node

onready var edge_registry = EdgeRegistry.new()
onready var site_registry = SiteRegistry.new()
var events = []

class Edge:
	var nodes = []
	var p1 = Vector2.ZERO
	var p2 = Vector2.ZERO
	
	func _init(n: Node2D, p1: Vector2, p2: Vector2):
		self.nodes.append(n)
		self.p1 = p1
		self.p2 = p2
	
	func has_points(p1, p2) -> bool:
		return self.p1 - p1 == Vector2.ZERO and self.p2 - p2 == Vector2.ZERO or self.p1 - p2 == Vector2.ZERO and self.p2 - p1 == Vector2.ZERO
		
	func add_node(n: Node2D) -> void:
		self.nodes.append(n)
	
class EdgeRegistry:
	
	var edges = []
	
	func register_edge(n: Node2D, p1: Vector2, p2: Vector2) -> void:
		for edge in edges:
			if edge.has_points(p1, p2):
				edge.add_node(n)
				return
		edges.append(Edge.new(n, p1, p2))
		
class Site:
	var node: Node2D = null
	var polygon: Array = []
	
	func _init(node: Node2D, polygon: Array) -> void:
		self.node = node
		for point in polygon:
			if not point in self.polygon:
				self.polygon.append(point)
		print(self.polygon.size())
	
class SiteRegistry:
	
	var sites = []
	
	func register_site(node: Node2D, local_points: Array) -> void:
		if local_points.size() > 0:
			var convex_hull = Geometry.convex_hull_2d(local_points)
			
			self.sites.append(Site.new(node, convex_hull))
			
			var last_point = convex_hull[0]
			for i in range(1, convex_hull.size()):
				var curr_point = convex_hull[i]
				Voronoi.register_edge_to_node(node, last_point, curr_point)
				last_point = curr_point
		
	func get_polygon_of_node(node: Node2D) -> Array:
		for site in self.sites:
			if site.node == node:
				return site.polygon
		return []

class MyCustomSorter:
	static func sort_ascending(a, b):
		var a1 = atan2(a[0], a[1]) * 180 / PI
		var a2 = atan2(b[0], b[1]) * 180 / PI
		if a1 < a2:
			return true
		return false

	
func register_edge_to_node(n, p1, p2):
	edge_registry.register_edge(n, p1, p2)
	
func calc():
	var planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == State.curr_planet_system:
			planets.append(planet)
			
	events = calc_voroni(planets)
	
	var i = 0
	for planet in planets:
		print(i)
		i = i + 1
		var local_points = []
		for event in events:
			if planet in event.nodes:
				if event.has('edgepoint'):
					local_points.append(event.edgepoint - planet.position)
				elif event.has('circle'):
					local_points.append(event.circle.position - planet.position)
		
		Voronoi.site_registry.register_site(planet, local_points)
		print(planet)

func calc_voroni(nodes: Array) -> Array:
	
	print('Voronoi nodes: %d' % nodes.size())
	
	var events = []
	var circle_points = []
	
	for n1 in nodes.slice(0, nodes.size() - 2):
		for n2 in nodes.slice(1, nodes.size() - 1):
			if n2 != n1:				
				for n3 in nodes.slice(2, nodes.size()):
					if n3 != n2 and n3 != n1:
						var circle = _define_circle(n1.position, n2.position, n3.position)
						
						if circle:
							var has_point_in_circle = false
							for n4 in nodes:
								if n4 != n3 and n4 != n2 and n4 != n1:
									if _point_in_circle(n4.position, circle):
										has_point_in_circle = true
							
							if not has_point_in_circle:
								
								var mpn2 = _get_midpoint(n1, n2)
								var mpn3 = _get_midpoint(n1, n3)
								var dn2 = (n1 as Node2D).position.distance_to(mpn2)
								var dn3 = (n1 as Node2D).position.distance_to(mpn3)
								
								if true:
									events.append({
										"nodes": [n1, n2],
										"midpoint": mpn2
									})
									events.append({
										"nodes": [n1, n3],
										"midpoint": mpn3
									})
									events.append({
										"nodes": [n2, n3],
										"midpoint":  _get_midpoint(n2, n3)
									})
								
								events.append({
									"nodes": [n1, n2, n3],
									"circle": circle
								})
								circle_points.append(circle.position)
								
	var convex_hull = Geometry.convex_hull_2d(circle_points)
	
	for event in events:
		if event.has('midpoint'):
			if not Geometry.is_point_in_polygon(event.midpoint, convex_hull):
				events.append({
					"nodes": event.nodes,
					"edgepoint": event.midpoint
				})
	
	return events
	
func _point_in_circle(p, circle):
	return pow(p[0] - circle.position[0], 2) + pow(p[1] - circle.position[1], 2) < pow(circle.radius, 2)
	
func _define_circle(p1, p2, p3):
	"""
	Returns the center and radius of the circle passing the given 3 points.
	In case the 3 points form a line, returns (None, infinity).
	"""
	var temp = p2[0] * p2[0] + p2[1] * p2[1]
	var bc = (p1[0] * p1[0] + p1[1] * p1[1] - temp) / 2
	var cd = (temp - p3[0] * p3[0] - p3[1] * p3[1]) / 2
	var det = (p1[0] - p2[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p2[1])

	if abs(det) < 1.0e-6:
		return null

	# Center of circle
	var cx = (bc*(p2[1] - p3[1]) - cd*(p1[1] - p2[1])) / det
	var cy = ((p1[0] - p2[0]) * cd - (p2[0] - p3[0]) * bc) / det

	var radius = sqrt(pow(cx - p1[0], 2) + pow(cy - p1[1], 2))
	
	return {
		"position": Vector2(cx, cy), 
		"radius": radius
	}
	
func _get_midpoint(n1: Node2D, n2: Node2D) -> Vector2:
	return Vector2((n1.position.x + n2.position.x) / 2, (n1.position.y + n2.position.y) / 2)
