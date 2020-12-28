extends Node2D

func _ready():
	Settings.connect("settings_changed", self, "update")
	
func _draw():
	if not Settings.get_is_debug():
		return
	
	# Voronoi
	var curr_vononoi = Voronoi.voronoi_registry.get_by_index(GameState.get_planet_system())
	if not curr_vononoi:
		return
	
	draw_polyline(curr_vononoi.convex_hull, Color(1,1,1,1), 1, true)
	
	for convex_point in curr_vononoi.convex_hull:
		for event in curr_vononoi.events:
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
	
	for e in curr_vononoi.debug_edgepoints:
		draw_polyline(e, Color(1,0,0,1), 50, true)
		draw_circle(e[0], 300, Color(1,1,0,1))
		draw_circle(e[1], 300, Color(1,0,0,1))
		draw_circle(e[2], 300, Color(1,0,0,1))
	for e in curr_vononoi.debug_circles_line:
		draw_polyline(e, Color(0,1,0,1), 50, true)
		draw_circle(e[0], 300, Color(0,1,1,1))
		draw_circle(e[1], 300, Color(0,1,0,1))
		draw_circle(e[2], 300, Color(0,1,0,1))
	for e in curr_vononoi.debug_circles_origin:
		draw_polyline(e, Color(0,1,1,0.5), 50, true)
		draw_circle(e[0], 300, Color(1,1,0,0.5))
		draw_circle(e[1], 300, Color(0,1,0,0.5))
		draw_circle(e[2], 300, Color(0,1,1,0.5))
