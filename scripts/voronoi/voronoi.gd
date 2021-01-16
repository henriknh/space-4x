extends Node

const Site = preload("res://scripts/voronoi/site.gd")

onready var voronoi_registry = VoronoiRegistry.new()

const BOUND_SIZE = 1

class Voronoi:
	
	onready var site_registry = Site.SiteRegistry.new()
	
	var index: int = 0
	var nodes: Array = []
	var events: Array = []
	var convex_hull = []
	
	var edge_points_handled = []
	
	var debug_edgepoints = []
	var debug_circles_line = []
	var debug_circles_origin = []
	
	func _init(index: int, nodes: Array) -> void:
		self.index = index
		self.nodes = nodes
		
		self.clear()
		self._calc_events()
		self._calc_sites()
		self._look_for_edge_sites()
		self._calc_convex_hull()
		print(self.edge_points_handled)
		
		self._extend_two_site_intersections()
		print(self.edge_points_handled)
		#self._extend_non_convex_points()
		#self._calc_convex_hull()
		#self._extend_sites()
		#self._calc_convex_hull()
	
	func _extend_two_site_intersections():
		
		var points = []
		for site in self.site_registry.sites:
			for point in site.points:
				var site_point = point + site.node.position
				if not Utils.array_has(site_point, points):
					points.append(site_point)
		
		var two_site_intersections = {}
		for point in points:
			if Utils.array_has(point, edge_points_handled):
				continue
			
			var sites = self.site_registry.get_sites_with_point(point)
			if sites.size() == 2:
				two_site_intersections[point] = sites
		
		for point in two_site_intersections.keys():
			var closest_circle = null
			for event_circle in self.events:
				if event_circle.has('circle'):
					if not closest_circle:
						closest_circle = event_circle
					elif event_circle.circle.position.distance_squared_to(point) < closest_circle.circle.position.distance_squared_to(point):
						closest_circle = event_circle
			var opposite = (point + (point - closest_circle.circle.position) * BOUND_SIZE)
				
			self.debug_edgepoints.append([closest_circle.circle.position, point, opposite])
				
			self.site_registry.replace_global_point(point, opposite)
			self.edge_points_handled.append(opposite)
		
	func _look_for_edge_sites():
		for site in self.site_registry.sites:
			if site.points.size() == 2:
				print(site.points.size())
				
				var prev_point = site.points[0] + site.node.position
				var next_point = site.points[1] + site.node.position
				
				var prev_sites = self.site_registry.get_sites_with_point(prev_point, site)
				var next_sites = self.site_registry.get_sites_with_point(next_point, site)
				var prev_site = prev_sites[0] if not prev_sites[0] in next_sites else prev_sites[1]
				var next_site = next_sites[0] if not next_sites[0] in prev_sites else next_sites[1]
				print(prev_site)
				print(next_site)
				
				var prev_midpoint = Utils.get_midpoint(prev_site.node.position, site.node.position)
				var prev_opposite = (prev_point + (prev_point - prev_midpoint)) * BOUND_SIZE
				site.add_point(prev_opposite - site.node.position)
				prev_site.add_point(prev_opposite - prev_site.node.position)
				self.events.append({
					"nodes": [prev_site, site],
					"edgepoint": prev_opposite
				})
				edge_points_handled.append(prev_opposite)
				self.debug_edgepoints.append([prev_midpoint, prev_point, prev_opposite])
				
				var next_midpoint = Utils.get_midpoint(next_site.node.position, site.node.position)
				var next_opposite = (next_point + (next_point - next_midpoint)) * BOUND_SIZE
				site.add_point(next_opposite - site.node.position)
				next_site.add_point(next_opposite - next_site.node.position)
				self.events.append({
					"nodes": [next_site, site],
					"edgepoint": next_opposite
				})
				edge_points_handled.append(next_opposite)
				self.debug_edgepoints.append([next_midpoint, next_point, next_opposite])
		
	func clear():
		self.site_registry = Site.SiteRegistry.new()
		self.events = []
		self.convex_hull = []
		self.edge_points_handled = []
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
		print('calc convex hull: %d' % self.convex_hull.size())
		#self.convex_hull.remove(0)
		
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
		var iter = 0
		
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
		self._calc_convex_hull()

		
		var visited_points = []
		for event in self.events:
			if event.has('circle') and Utils.point_on_polyline(event.circle.position, self.convex_hull) and true:
				
				if Utils.array_has(event.circle.position, visited_points):
					continue
				
				visited_points.append(event.circle.position)
				
				print('extent circle point')
				print(event.circle.position)
				
				var idx = Utils.array_idx(event.circle.position, self.convex_hull)
				var prev_convex_idx = idx
				var prev_convex_point = event.circle.position
				while Utils.equals(prev_convex_point, event.circle.position):
					prev_convex_idx = (prev_convex_idx - 1 + self.convex_hull.size()) % (self.convex_hull.size())
					prev_convex_point = self.convex_hull[prev_convex_idx]
				var next_convex_idx = idx
				var next_convex_point = event.circle.position
				while Utils.equals(next_convex_point, event.circle.position):
					next_convex_idx = (next_convex_idx + 1 + self.convex_hull.size()) % (self.convex_hull.size())
					next_convex_point = self.convex_hull[next_convex_idx]
				#var prev_convex_idx = (idx - 1 + self.convex_hull.size()) % (self.convex_hull.size())
				#var next_convex_idx = (idx + 1 + self.convex_hull.size()) % (self.convex_hull.size())
				
				#var prev_convex_point = self.convex_hull[prev_convex_idx]
				#var next_convex_point = self.convex_hull[next_convex_idx]
				
				print(prev_convex_point)
				print(next_convex_point)
				
				var potential_sites = self.site_registry.get_sites_with_point(event.circle.position)
				print(potential_sites)
				
				var prev_site = null
				var prev_node_dist = INF
				for site in potential_sites:
					for point in site.points:
						var site_point = point + site.node.position
						if Utils.array_has(site_point, visited_points):
							continue
						var dist = Utils.min_distance_point_to_segment(site_point, event.circle.position, prev_convex_point)
						if dist < prev_node_dist:
							prev_node_dist = dist
							prev_site = site
						
				var next_site = null
				var next_node_dist = INF
				for site in potential_sites:
					for point in site.points:
						var site_point = point + site.node.position
						if Utils.array_has(site_point, visited_points):
							continue
						var dist = Utils.min_distance_point_to_segment(site_point, event.circle.position, next_convex_point)
						if dist < next_node_dist:
							next_node_dist = dist
							next_site = site
				
				print(prev_site.node.position)
				print(next_site.node.position)
				
				
				
				#var prev_node = self.site_registry.get_edge_node_by_points([prev_convex_point, event.circle.position])
				#var next_node = self.site_registry.get_edge_node_by_points([next_convex_point, event.circle.position])
				
				if not prev_site or not next_site:
					
					pass
				
				var midpoint = Utils.get_midpoint(prev_site.node.position, next_site.node.position)
				var opposite = (event.circle.position + (event.circle.position - midpoint) * BOUND_SIZE)
				
				self.debug_circles_line.append([midpoint, event.circle.position, opposite])
				self.debug_circles_origin.append([prev_convex_point, midpoint, next_convex_point])
				
				if iter == 3:
					print(11111)
					print([event.circle.position, opposite])
				#self.site_registry.replace_global_point(event.circle.position, opposite)
				next_site.add_point(opposite - next_site.node.position)
				prev_site.add_point(opposite - prev_site.node.position)
				self._calc_convex_hull()
				
				#self.convex_hull[idx] = opposite

		
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
