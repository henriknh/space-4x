extends Node

func _connect_changed_signals():
	Settings.connect("settings_changed", self, "_on_changed")
	GameState.connect("state_changed", self, "_on_changed")

func _on_changed():
	for child in get_children():
		child.visible = false
		child.queue_free()
		
	if not Settings.get_show_planet_area():
		return
	
	var edges = []
	var planet_system = GameState.get_planet_system()
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == planet_system:
			for i in range(planet.planet_convex_hull.size() - 1):
				var j = 0 if i + 1 == planet.planet_convex_hull.size() - 1 else i + 1
				var p1 = planet.planet_convex_hull[i] + planet.position
				var p2 = planet.planet_convex_hull[j] + planet.position
				
				var has_edge = false
				for edge in edges:
					if Utils.array_has(p1, edge) and Utils.array_has(p2, edge):
						has_edge = true
				
				if not has_edge:
					edges.append([p1, p2])
					
	for edge in edges:
		var line = Line2D.new()
		line.points = edge
		line.width = 1
		line.default_color = Color(1,1,1,0.025)
		line.antialiased = true
		
		add_child(line)
