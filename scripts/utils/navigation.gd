extends Node

var maps = {}

var debug = []

func create_network():
	maps = {}
	
	var planet_systems = {}
	for planet in get_tree().get_nodes_in_group("Planet"):
		if not planet_systems.has(planet.planet_system):
			planet_systems[planet.planet_system] = []
		planet_systems[planet.planet_system].append(planet)
	
	for planet_system_idx in planet_systems.keys().slice(1,1):
		var segments = []
		
		for planet in planet_systems[planet_system_idx]:
			
			var prev_global_point = planet.planet_convex_hull[0] + planet.position
			
			for curr_point in planet.planet_convex_hull.slice(1, -1):
				
				var curr_global_point = curr_point + planet.position
				
				var found_segment = null
				for segment in segments:
					if Utils.array_has([prev_global_point, curr_global_point], segment['segment']):
						found_segment = segment
				if found_segment:
					found_segment['nodes'].append(planet)
				else:
					segments.append({
						"nodes": [planet],
						"segment": [prev_global_point, curr_global_point]
					})
				
				prev_global_point = curr_global_point
		
		var map = AStar2D.new()
		for segment in segments:
			if segment['nodes'].size() == 2:
				if planet_system_idx == 1:
					debug.append(segment['segment'])
				
				var point_id_1 = map.get_available_point_id()
				var point_id_2 = map.get_available_point_id()
				map.add_point(point_id_1, segment['nodes'][0].position)
				map.add_point(point_id_2, segment['nodes'][1].position)
				map.connect_points(point_id_1, point_id_2)
				
		maps[planet_system_idx] = map
