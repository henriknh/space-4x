extends Node

class_name SiteRegistry

var sites = []

func register_site(node: Dictionary, local_points: Array) -> Site:
	if local_points.size() > 0:
		
		var site = Site.new(node, local_points)
		self.sites.append(site)
		return site
	return null
func add_point(node: Dictionary, point: Vector2) -> void:
	for site in sites:
		if site.node.position == node.position:
			site.add_point(point)
			
func remove_point(node: Dictionary, point: Vector2) -> bool:
	for site in sites:
		if site.node.position == node.position:
			return site.remove_point(point)
	
	return false
	
func get_convex_hull_of_node(node: Dictionary) -> Array:
	for site in self.sites:
		if site.node.position == node.position:
			return site.convex_hull
	return []

func get_edge_node_by_points(points: Array) -> Dictionary:
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
