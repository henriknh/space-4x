extends Node

onready var voronoi_registry = VoronoiRegistry.new()

const BOUND_SIZE = 20000

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
	var points: Array = []
	var convex_hull: Array = []
	
	func _init(node: Node2D, _points: Array) -> void:
		self.node = node
		for point in _points:
			if not point in self.points:
				self.points.append(point)
		
		self.convex_hull = Geometry.convex_hull_2d(self.points)
		
	func add_point(point: Vector2) -> void:
		if not point in self.points:
			self.points.append(point)
			self.convex_hull = Geometry.convex_hull_2d(self.points)
		
	func remove_point(point: Vector2) -> bool:
		if Utils.array_has(point, self.points):
			self.points.erase(point)
			self.convex_hull = Geometry.convex_hull_2d(self.points)
			return true
		
		return false
	
class SiteRegistry:
	
	var sites = []
	
	func register_site(node: Node2D, local_points: Array) -> void:
		if local_points.size() > 0:
			
			var site = Site.new(node, local_points)
			self.sites.append(site)
	
	func add_point(node: Node2D, point: Vector2) -> void:
		for site in sites:
			if site.node == node:
				site.add_point(point)
				
	func remove_point(node: Node2D, point: Vector2) -> bool:
		for site in sites:
			if site.node == node:
				return site.remove_point(point)
		
		return false
		
	func get_convex_hull_of_node(node: Node2D) -> Array:
		for site in self.sites:
			if site.node == node:
				return site.convex_hull
		return []
	
	func get_edge_node_by_points(points: Array) -> Node2D:
		var node = null
		var furthest_dist = 0
		
		for site in sites:
			var has_point = 0
			
			for point in points:
				if Utils.array_has(point - site.node.position, site.points):
					has_point = has_point + 1
			
			if has_point == points.size():
				var sum_x = 0
				var sum_y = 0
				
				for point in site.points:
					sum_x = sum_x + point.x
					sum_y = sum_y + point.y
				
				var avg_x = sum_x / site.points.size()
				var avg_y = sum_y / site.points.size()
				
				var curr_dist = Vector2(avg_x, avg_y).distance_squared_to(Vector2.ZERO)
				if curr_dist >= furthest_dist:
					node = site.node

		return node

class Voronoi:
	
	onready var edge_registry = EdgeRegistry.new()
	onready var site_registry = SiteRegistry.new()
	
	var index: int = 0
	var nodes: Array = []
	var events: Array = []
	var convex_hull = []
	
	var debug_edgepoints = []
	var debug_circles_line = []
	var debug_circles_origin = []
	
	func _init(index: int, nodes: Array) -> void:
		self.index = index
		self.nodes = nodes
		
		self.clear()
		self._calc_events()
		self._calc_sites()
		self._calc_convex_hull()
		self._extend_sites()
		
	func clear():
		self.edge_registry = EdgeRegistry.new()
		self.site_registry = SiteRegistry.new()
		self.events = []
		self.convex_hull = []
		self.debug_edgepoints = []
		self.debug_circles_line = []
		self.debug_circles_origin = []
	
	func _calc_events() -> void:
		
		self.events = []
		var convex_points = []
		
		for n1 in self.nodes.slice(0, self.nodes.size() - 2):
			for n2 in self.nodes.slice(1, self.nodes.size() - 1):
				if n2 != n1:
					for n3 in self.nodes.slice(2, self.nodes.size()):
						if n3 != n2 and n3 != n1:
							var circle = self._define_circle(n1.position, n2.position, n3.position)
							
							if circle:
								var has_point_in_circle = false
								for n4 in nodes:
									if n4 != n3 and n4 != n2 and n4 != n1:
										if self._point_in_circle(n4.position, circle):
											has_point_in_circle = true
								
								if not has_point_in_circle:
									
									self.events.append({
										"nodes": [n1, n2],
										"midpoint": Utils.get_midpoint(n1.position, n2.position)
									})
									self.events.append({
										"nodes": [n1, n3],
										"midpoint": Utils.get_midpoint(n1.position, n3.position)
									})
									self.events.append({
										"nodes": [n2, n3],
										"midpoint":  Utils.get_midpoint(n2.position, n3.position)
									})
									
									self.events.append({
										"nodes": [n1, n2, n3],
										"circle": circle
									})
									convex_points.append(circle.position)
		
		# Find midpoints outside of initial comvex hull and add them as edgepoints
		self.convex_hull = Geometry.convex_hull_2d(convex_points)
		var convex_points_w_edgepoints = []
		for event in self.events:
			if event.has('circle'):
				convex_points_w_edgepoints.append(event.circle.position)
			if event.has('midpoint'):
				if not Geometry.is_point_in_polygon(event.midpoint, convex_hull) and not self._point_on_polyline(event.midpoint, convex_hull):
					var edgepoint = event.midpoint
					self.events.append({
						"nodes": event.nodes,
						"edgepoint": edgepoint
					})
					convex_points_w_edgepoints.append(event.midpoint)
		
		# Remove edgepoints outside of initial convex hull but not part of the new convex hull
		self.convex_hull = Geometry.convex_hull_2d(convex_points_w_edgepoints)
		for event in self.events:
			if event.has('edgepoint') and Geometry.is_point_in_polygon(event.edgepoint, convex_hull) and not self._point_on_polyline(event.edgepoint, convex_hull):
				self.events.erase(event)
	
	func _calc_sites():
		
		for node in self.nodes:
			var local_points = []
			for event in self.events:
				if node in event.nodes:
					if event.has('edgepoint'):
						local_points.append(event.edgepoint - node.position)
					elif event.has('circle'):
						local_points.append(event.circle.position - node.position)
			
			self.site_registry.register_site(node, local_points)
	
	func _calc_convex_hull():
		var convex_points = []
		
		for node in self.nodes:
			for event in self.events:
				if node in event.nodes:
					if event.has('edgepoint'):
						convex_points.append(event.edgepoint)
					elif event.has('circle'):
						convex_points.append(event.circle.position)
		
		self.convex_hull = Geometry.convex_hull_2d(convex_points)
		self.convex_hull.remove(0)
		
	func _extend_sites():
		
		var idx = 0
		
		for convex_point in self.convex_hull:
			for event in self.events:
				if event.has('edgepoint') and event.edgepoint == convex_point:
					var closest_circle = null
					for event_circle in self.events:
						if event_circle.has('circle'):
							if not closest_circle:
								closest_circle = event_circle
							elif event_circle.circle.position.distance_squared_to(event.edgepoint) < closest_circle.circle.position.distance_squared_to(event.edgepoint):
								closest_circle = event_circle
					
					var opposite = (event.edgepoint + (event.edgepoint - closest_circle.circle.position) * BOUND_SIZE)
					
					self.debug_edgepoints.append([closest_circle.circle.position, convex_point, opposite])
					
					var n1 = event.nodes[0]
					var n2 = event.nodes[1]
					
					self.site_registry.add_point(n1, opposite - n1.position)
					self.site_registry.add_point(n2, opposite - n2.position)
					self.site_registry.remove_point(n1, event.edgepoint - n1.position)
					self.site_registry.remove_point(n2, event.edgepoint - n2.position)
					self.convex_hull[idx] = opposite
					event.edgepoint = opposite - n1.position
					
					break
					
				elif event.has('circle') and event.circle.position == convex_point:
					var prev_convex_idx = (idx - 1 + convex_hull.size()) % (convex_hull.size())
					var next_convex_idx = (idx + 1 + convex_hull.size()) % (convex_hull.size())
					
					var prev_convex_point = convex_hull[prev_convex_idx]
					var next_convex_point = convex_hull[next_convex_idx]
					
					var prev_node = self.site_registry.get_edge_node_by_points([prev_convex_point, convex_point])
					var next_node = self.site_registry.get_edge_node_by_points([next_convex_point, convex_point])
					
					var midpoint = Utils.get_midpoint(prev_node.position, next_node.position)
					var opposite = (event.circle.position + (event.circle.position - midpoint) * BOUND_SIZE)
					
					self.debug_circles_line.append([midpoint, convex_point, opposite])
					self.debug_circles_origin.append([prev_convex_point, midpoint, next_convex_point])
					
					var n1 = event.nodes[0]
					var n2 = event.nodes[1]
					var n3 = event.nodes[2]
					
					var d1 = (opposite as Vector2).distance_squared_to(n1.position)
					var d2 = (opposite as Vector2).distance_squared_to(n2.position)
					var d3 = (opposite as Vector2).distance_squared_to(n3.position)
					
					# Investigate if below uncommented code is needed
					if d1 <= d3 and d2 <= d3:
						self.site_registry.add_point(n1, opposite - n1.position)
						self.site_registry.add_point(n2, opposite - n2.position)
						#self.site_registry.remove_point(n1, event.circle.position - n1.position)
						#self.site_registry.remove_point(n2, event.circle.position - n2.position)
					elif d1 <= d2 and d3 <= d2:
						self.site_registry.add_point(n1, opposite - n1.position)
						self.site_registry.add_point(n3, opposite - n3.position)
						#self.site_registry.remove_point(n1, event.circle.position - n1.position)
						#self.site_registry.remove_point(n3, event.circle.position - n3.position)
					elif d2 <= d1 and d3 <= d1:
						self.site_registry.add_point(n2, opposite - n2.position)
						self.site_registry.add_point(n3, opposite - n3.position)
						#self.site_registry.remove_point(n2, event.circle.position - n2.position)
						#self.site_registry.remove_point(n3, event.circle.position - n3.position)
						
					#self.convex_hull[idx] = opposite
					#event.circle.position = opposite - n1.position
					
					break
			
			idx = idx + 1
	
	func _point_on_polyline(point: Vector2, polyline: Array) -> bool:
		var prev = polyline[0]
		for i in range(1, polyline.size()):
			var curr = polyline[i]
			
			var on_segment = _point_on_segment(point, prev, curr)
			if on_segment:
				return true
			
			prev = curr
		return false

	func _point_on_segment(point: Vector2, a: Vector2, b: Vector2) -> bool:
		var epsilon = 0.01
		return abs(a.distance_to(point) + point.distance_to(b) - a.distance_to(b)) < epsilon
		
	func _point_in_circle(p: Vector2, circle) -> bool:
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
		
class VoronoiRegistry:
	
	var voronois: Array = []
	
	func register_voronoi(index: int, nodes: Array) -> Object:
		for voronoi in voronois:
			if voronoi.index == index:
				return voronoi
		
		var voronoi = Voronoi.new(index, nodes)
		self.voronois.append(voronoi)
		return voronoi
		
	func get_by_index(index: int) -> Object:
		for voronoi in self.voronois:
			if voronoi.index == index:
				return voronoi
		return null
