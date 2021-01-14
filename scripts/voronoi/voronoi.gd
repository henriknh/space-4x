extends Node

onready var voronoi_registry = VoronoiRegistry.new()

const BOUND_SIZE = 2

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
		
	func replace_global_point(old_global_point: Vector2, new_global_point: Vector2) -> bool:
		var old_local_point = old_global_point - self.node.position
		var index = Utils.array_idx(old_local_point, self.points)
		if index >= 0:
			self.points[index] = new_global_point - self.node.position
			self.convex_hull = Geometry.convex_hull_2d(self.points)
			return true
		return false
	
	func get_southern_most_point() -> Vector2:
		var southern_point = -Vector2.INF
		for point in self.convex_hull:
			if point.y > southern_point.y:
				southern_point = point
		return southern_point + self.node.position
	
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
		
	func replace_global_point(old_global_point: Vector2, new_global_point: Vector2) -> bool:
		var replaced = false
		for site in sites:
			replaced = site.replace_global_point(old_global_point, new_global_point) || replaced
		return replaced
	
	func get_sites_with_point(point: Vector2, excluding_site: Site = null) -> Site:
		var potential_sites = []
		for site in self.sites:
			if Utils.array_has(point - site.node.position, site.convex_hull) and site != excluding_site:
				potential_sites.append(site)
				
		return potential_sites
		if potential_sites.size() == 1:
			return potential_sites[0]
		else:
			var furthest_site = null
			var furthest_site_dist = 0
			for site in potential_sites:
				var dist = (site.node.position as Vector2).distance_squared_to(Vector2.ZERO)
				if dist > furthest_site_dist:
					furthest_site = site
					furthest_site_dist = dist
			return furthest_site
		
	func get_southern_most_site() -> Site:
		var southern_site = null
		var southern_site_position = -Vector2.INF
		for site in self.sites:
			if site.node.position.y > southern_site_position.y:
				southern_site = site
				southern_site_position = site.node.position
		return southern_site

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
		print(self.convex_hull.size())
		self._extend_non_convex_points()
		self._calc_convex_hull()
		print(self.convex_hull.size())
		self._extend_sites()
		self._calc_convex_hull()
		print(self.convex_hull.size())
		
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
		var convex_points_midpoints = []
		var convex_points_circles = []
		
		for n1 in self.nodes.slice(0, self.nodes.size() - 2):
			for n2 in self.nodes.slice(1, self.nodes.size() - 1):
				if n2 != n1:
					
					var midpoint = Utils.get_midpoint(n1.position, n2.position)
					self.events.append({
						"nodes": [n1, n2],
						"midpoint": midpoint
					})
					convex_points_midpoints.append(midpoint)
					
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
										"nodes": [n1, n2, n3],
										"circle": circle
									})
									convex_points_circles.append(circle.position)
		
		# Find midpoints outside of initial comvex hull and add them as edgepoints
		var convex_hull_circle = Geometry.convex_hull_2d(convex_points_circles)
		var convex_hull_midpoints = Geometry.convex_hull_2d(convex_points_midpoints)
		var convex_points_circle_w_edgepoints = convex_points_circles
		for midpoint in convex_hull_midpoints:
			if not Geometry.is_point_in_polygon(midpoint, convex_hull_circle) and not Utils.point_on_polyline(midpoint, convex_hull_circle):
				for event in self.events:
					if event.has('midpoint') and event.midpoint == midpoint:
						var edgepoint = event.midpoint
						self.events.append({
							"nodes": event.nodes,
							"edgepoint": edgepoint
						})
						convex_points_circle_w_edgepoints.append(edgepoint)
		
		# Remove edgepoints outside of initial convex hull but not part of the new convex hull
		self.convex_hull = Geometry.convex_hull_2d(convex_points_circle_w_edgepoints)
		#self.convex_hull.remove(0)
		for event in self.events:
			if event.has('edgepoint') and Geometry.is_point_in_polygon(event.edgepoint, convex_hull) and not Utils.point_on_polyline(event.edgepoint, convex_hull):
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
		
		for site in self.site_registry.sites:
			for point in site.points:
				var site_point = point + site.node.position
				if not Utils.array_has(site_point, convex_points):
					convex_points.append(site_point)

		self.convex_hull = Geometry.convex_hull_2d(convex_points)
		self.convex_hull.remove(0)
		
	func _extend_non_convex_points():
		
		var first_site = self.site_registry.get_southern_most_site()
		var first_point = first_site.get_southern_most_point()
		var prev_site = first_site
		var prev_point = first_point
		var next_site
		var next_point
		
		var visited_points = [prev_point]
		var visited_sites = [prev_site]
		
		var convex_hull = Utils.array_remove_duplicates(self.convex_hull)
		var first_idx = Utils.array_idx(first_point, convex_hull) % convex_hull.size()
		var curr_idx = first_idx
		var next_idx
		while next_idx != first_idx:
			next_idx = (curr_idx + 1) % convex_hull.size()
			var potential_sites = self.site_registry.get_sites_with_point(prev_point, prev_site)
			
			# Get site closest to convex hull point
			next_site = null
			var closest_point_dist = INF
			for curr_convex_hull_point in convex_hull:
				for site in potential_sites:
					if site in visited_sites:
						continue
					for _site_point in site.convex_hull:
						var site_point = _site_point + site.node.position
						if Utils.array_has(site_point, visited_points):
							continue
						
						var dist = site_point.distance_squared_to(curr_convex_hull_point)
						dist = Utils.min_distance_point_to_segment(site_point, convex_hull[curr_idx], convex_hull[next_idx])
						

						if dist < closest_point_dist and not Utils.array_has(site_point, visited_points):
							closest_point_dist = dist
							next_site = site
							next_point = site_point
			
			if closest_point_dist > 1:
				print('handle distance to convex hull')
				var point_to_extend_to = Utils.point_position_on_segment(next_point, convex_hull[curr_idx], convex_hull[next_idx])
				var potential_sites_to_extend = self.site_registry.get_sites_with_point(next_point)
				var sites_to_extend = []
				for site in potential_sites_to_extend:
					if Utils.array_has(convex_hull[curr_idx] - site.node.position, site.convex_hull) or Utils.array_has(convex_hull[next_idx] - site.node.position, site.convex_hull): 
						sites_to_extend.append(site)
				self.site_registry.add_point(sites_to_extend[0].node, point_to_extend_to - sites_to_extend[0].node.position)
				self.site_registry.add_point(sites_to_extend[1].node, point_to_extend_to - sites_to_extend[1].node.position)
				self.events.append({
					"nodes": [sites_to_extend[0].node, sites_to_extend[1].node],
					"edgepoint": point_to_extend_to
				})
			
			prev_site = next_site
			prev_point = next_point
			visited_points.append(prev_point)
			visited_sites.append(prev_site)
			curr_idx = (curr_idx + 1) % convex_hull.size()
			
	func _extend_sites():
		
		print('extend sites')
		
		var idx = 0
		
		for convex_point in self.convex_hull:
			for event in self.events:
				if event.has('edgepoint') and Utils.point_on_polyline(event.edgepoint, self.convex_hull) and true:
					var closest_circle = null
					for event_circle in self.events:
						if event_circle.has('circle'):
							if not closest_circle:
								closest_circle = event_circle
							elif event_circle.circle.position.distance_squared_to(event.edgepoint) < closest_circle.circle.position.distance_squared_to(event.edgepoint):
								closest_circle = event_circle
					var opposite = (event.edgepoint + (event.edgepoint - closest_circle.circle.position) * BOUND_SIZE)
					
					self.debug_edgepoints.append([closest_circle.circle.position, event.edgepoint, opposite])
					
					self.site_registry.replace_global_point(event.edgepoint, opposite)
					self.convex_hull[idx] = opposite
					
				elif event.has('circle') and event.circle.position == convex_point and false:
					print('- - -')
					var prev_convex_idx = (idx - 1 + convex_hull.size()) % (convex_hull.size())
					var next_convex_idx = (idx + 1 + convex_hull.size()) % (convex_hull.size())
					
					var prev_convex_point = convex_hull[prev_convex_idx]
					var next_convex_point = convex_hull[next_convex_idx]
					
					print('- a')
					var prev_node = self.site_registry.get_edge_node_by_points([prev_convex_point, convex_point])
					print('- b')
					var next_node = self.site_registry.get_edge_node_by_points([next_convex_point, convex_point])
					
					if not prev_node or not next_node:
						
						pass
					
					var midpoint = Utils.get_midpoint(prev_node.position, next_node.position)
					var opposite = (event.circle.position + (event.circle.position - midpoint) * BOUND_SIZE)
					
					self.debug_circles_line.append([midpoint, convex_point, opposite])
					self.debug_circles_origin.append([prev_convex_point, midpoint, next_convex_point])
					
					print(11111)
					print([event.circle.position, opposite])
					self.site_registry.replace_global_point(event.circle.position, opposite)
					self.convex_hull[idx] = opposite
					
					break
			
			idx = idx + 1
		
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
