extends Node

func process(entity: Entity):
	var has_asteroids = entity.parent.get_children_by_type(Enums.object_types.asteroid, 'object_type').size() > 0
	
	if not has_asteroids:
		var potential_site_ids = Nav.get_adjacent_sites(entity.parent)
		var potential_planets = []
		print('potential_site_ids %d' % potential_site_ids.size())
		for planet in get_tree().get_nodes_in_group('Planet'):
			if planet.id in potential_site_ids and planet.faction == entity.faction:
				potential_planets.append(planet)
		
		print('potential planets %d' % potential_planets.size())
		
		if potential_planets.size() > 0:
			potential_planets.shuffle()
			print('travel to %d ' % potential_planets[0].id)
			entity.set_entity_process(Enums.ship_states.travel, potential_planets[0].id)
