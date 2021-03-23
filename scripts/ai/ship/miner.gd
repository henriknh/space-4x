extends Node

func process(entity: Entity):
	var has_asteroids = entity.parent.get_children_by_type(Enums.prop_types.asteroid, 'prop_type').size() > 0
	
	if not has_asteroids:
		print('ai miner has no asteroids')
		var adjecent_sites = Nav.get_adjacent_sites(entity.parent)
		
		if adjecent_sites.size() > 0:
			adjecent_sites.shuffle()
			adjecent_sites.sort_custom(AIShipMinerSort, "sort_miner")
			entity.set_entity_process(Enums.ship_states.travel, adjecent_sites[0].id)

class AIShipMinerSort:
	static func sort_miner(a: Entity, b: Entity):
		return a.id < b.id
