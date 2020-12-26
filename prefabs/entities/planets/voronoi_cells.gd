extends Node2D

func _draw():
	for site in Voronoi.site_registry.sites:
		var global_polygon = []
		
		for point in site.convex_hull + [site.convex_hull[0]]:
			global_polygon.append(site.node.position + point)
		draw_polyline(global_polygon, Color(1, 1, 1, 0.01), 1, true)
		
	var planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == State.curr_planet_system:
			planets.append(planet)
	
	draw_polyline(Voronoi.convex_hull, Color(1,1,1,1), 1, true)
	
	for convex_point in Voronoi.convex_hull:
		for event in Voronoi.events:
			if event.has('edgepoint') and event.edgepoint == convex_point:
				draw_circle(event.edgepoint, 100, Color(1,0,0,1))
			if event.has('edgepoint'):
				draw_circle(event.edgepoint, 100, Color(1,0,0,0.5))
			if event.has('midpoint') and event.midpoint == convex_point:
				#draw_circle(event.midpoint, 100, Color(0,1,0,1))
				pass
			if event.has('circle') and event.circle.position == convex_point:
				#draw_circle(event.circle.position, 100, Color(0,0,1,1))
				pass
	
	return 
	for e in Voronoi.edges1:
		draw_polyline(e, Color(1,0,0,1), 50, true)
		draw_circle(e[0], 300, Color(1,1,0,1))
		draw_circle(e[1], 300, Color(1,0,0,1))
		draw_circle(e[2], 300, Color(1,0,0,1))
		
		
	for e in Voronoi.edges2:
		draw_polyline(e, Color(0,1,0,1), 50, true)
		draw_circle(e[0], 300, Color(0,1,1,1))
		draw_circle(e[1], 300, Color(0,1,0,1))
		draw_circle(e[2], 300, Color(0,1,0,1))
	for e in Voronoi.edges3:
		draw_polyline(e, Color(0,1,1,0.5), 50, true)
		draw_circle(e[0], 300, Color(1,1,0,0.5))
		draw_circle(e[1], 300, Color(0,1,0,0.5))
		draw_circle(e[2], 300, Color(0,1,1,0.5))
