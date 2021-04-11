extends Node

class_name Voronoi

const bounds_factor = 200

onready var site_registry = SiteRegistry.new()

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
	self._extend_two_site_intersections()
	self._extend_three_site_intersections()
	
	self._calc_convex_hull()
	
func clear():
	self.site_registry = SiteRegistry.new()
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
	
func _look_for_edge_sites():
	for site in self.site_registry.sites:
		if site.points.size() == 2:
			
			var prev_point = site.points[0] + site.node.position
			var next_point = site.points[1] + site.node.position
			
			var prev_sites = self.site_registry.get_sites_with_point(prev_point, site)
			var next_sites = self.site_registry.get_sites_with_point(next_point, site)
			var prev_site = prev_sites[0] if not prev_sites[0] in next_sites else prev_sites[1]
			var next_site = next_sites[0] if not next_sites[0] in prev_sites else next_sites[1]
			
			var prev_midpoint = Utils.get_midpoint(prev_site.node.position, site.node.position)
			var prev_opposite = site.node.position
			if prev_point.distance_squared_to(Vector2.ZERO) > prev_midpoint.distance_squared_to(Vector2.ZERO):
				prev_opposite = (prev_point + (prev_point - prev_midpoint).normamlized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
			else:
				prev_opposite = (prev_midpoint + (prev_midpoint - prev_point).normamlized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
			site.add_point(prev_opposite - site.node.position)
			prev_site.add_point(prev_opposite - prev_site.node.position)
			self.events.append({
				"nodes": [prev_site, site],
				"edgepoint": prev_opposite
			})
			edge_points_handled.append(prev_opposite)
			self.debug_edgepoints.append([prev_midpoint, prev_point, prev_opposite])
			
			var next_midpoint = Utils.get_midpoint(next_site.node.position, site.node.position)
			var next_opposite = site.node.position
			if next_point.distance_squared_to(Vector2.ZERO) > next_midpoint.distance_squared_to(Vector2.ZERO):
				next_opposite = (next_point + (next_point - next_midpoint).normamlized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
			else:
				next_opposite = (next_midpoint + (next_midpoint - next_point).normamlized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
			site.add_point(next_opposite - site.node.position)
			next_site.add_point(next_opposite - next_site.node.position)
			self.events.append({
				"nodes": [next_site, site],
				"edgepoint": next_opposite
			})
			edge_points_handled.append(next_opposite)
			self.debug_edgepoints.append([next_midpoint, next_point, next_opposite])

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
		var opposite = point
		if point.distance_squared_to(Vector2.ZERO) > closest_circle.circle.position.distance_squared_to(Vector2.ZERO):
			opposite = (point + (point - closest_circle.circle.position).normalized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
		else:
			opposite = (point + (point - closest_circle.circle.position).normalized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
			
		self.debug_edgepoints.append([closest_circle.circle.position, point, opposite])
		
		self.site_registry.replace_global_point(point, opposite)
		self.edge_points_handled.append(opposite)
	
func _extend_three_site_intersections():
	
	var points = []
	for site in self.site_registry.sites:
		for point in site.points:
			var site_point = point + site.node.position
			if not Utils.array_has(site_point, points):
				points.append(site_point)
	
	var three_site_intersections = {}
	for point in points:
		if Utils.array_has(point, edge_points_handled):
			continue
		
		var sites = self.site_registry.get_sites_with_point(point)
		if sites.size() == 3:
			three_site_intersections[point] = sites
	
	for point in three_site_intersections.keys():
		var sites = three_site_intersections.get(point)
		var edge_sites = []
		if sites.size() == 3:
			for site in sites:
				
				var site_convex_hull = site.convex_hull.slice(0, site.convex_hull.size())
				site_convex_hull.remove(0)
				
				var point_idx = Utils.array_idx(point - site.node.position, site_convex_hull)
				var prev_idx = (point_idx - 1 + site_convex_hull.size()) % site_convex_hull.size()
				var next_idx = (point_idx + 1 + site_convex_hull.size()) % site_convex_hull.size()
				
				# Prev
				var prev_sites = self.site_registry.get_sites_with_point(site_convex_hull[prev_idx] + site.node.position, site)
				var prev_has_other_site = false
				for other_site in sites:
					if other_site == site:
						continue
					if other_site in prev_sites:
						prev_has_other_site = true
				if not prev_has_other_site and not Utils.array_has(site, edge_sites):
					edge_sites.append(site)
				
				# Next 
				var next_sites = self.site_registry.get_sites_with_point(site_convex_hull[next_idx] + site.node.position, site)
				var next_has_other_site = false
				for other_site in sites:
					if other_site == site:
						continue
					if other_site in next_sites:
						next_has_other_site = true
				if not next_has_other_site and not Utils.array_has(site, edge_sites):
					edge_sites.append(site)
		
		if edge_sites.size() == 2:
			var midpoint = Utils.get_midpoint(edge_sites[0].node.position, edge_sites[1].node.position)
			var opposite = point
			if point.distance_squared_to(Vector2.ZERO) > midpoint.distance_squared_to(Vector2.ZERO):
				opposite = (point + (point - midpoint).normalized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
			else:
				opposite = (midpoint + (midpoint - point).normalized() * Consts.PLANET_SYSTEM_RADIUS * bounds_factor)
			
			edge_sites[0].add_point(opposite - edge_sites[0].node.position)
			edge_sites[1].add_point(opposite - edge_sites[1].node.position)
			edge_points_handled.append(opposite)
			self.debug_edgepoints.append([midpoint, point, opposite])

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
