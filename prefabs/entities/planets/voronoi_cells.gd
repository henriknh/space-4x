extends Node2D

func _draw():
	for site in Voronoi.site_registry.sites:
		var global_polygon = []
		for point in site.polygon + [site.polygon[0]]:
			global_polygon.append(site.node.position + point)
		draw_polyline(global_polygon, Color(1, 1, 1, 0.01), 1, true)
		
	var planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == State.curr_planet_system:
			planets.append(planet)
	
	var convex_points = []
	for planet in planets:
		for event in Voronoi.events:
			if planet in event.nodes:
				if event.has('edgepoint'):
					draw_circle(event.edgepoint, 200, Color(0,0,1,1))
					convex_points.append(event.edgepoint)
					pass
				if event.has('midpoint'):
					#draw_circle(event.midpoint, 100, Color(1,0,0,1))
					convex_points.append(event.midpoint)
					pass
				if event.has('circle'):
					#draw_circle(event.circle.position, 100, Color(0,1,0,1))
					convex_points.append(event.circle.position)
				
	var convex_hull = Geometry.convex_hull_2d(convex_points)
	
	for p in convex_hull:
		draw_circle(p, 100, Color(1,1,1,1))
		

				
	draw_polyline(convex_hull, Color(1,1,1,1), 50)
