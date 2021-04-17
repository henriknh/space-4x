extends Node

func process(entity: Entity):
	if entity.parent.corporation_id != 0:
		var adjacent_sites = Nav.get_adjacent_sites(entity.parent)
		adjacent_sites.sort_custom(AIShipExplorerSort, "sort_explorer")
		
		var to_explore
		for adjacent_site in adjacent_sites:
			if adjacent_site.corporation_id == 0:
				to_explore = adjacent_site
				break
		
		if not to_explore:
			to_explore = adjacent_sites[0]
		
		entity.set_entity_process(Enums.ship_states.travel, to_explore.id)
	else:
		entity.state = Enums.ship_states.colonize

class AIShipExplorerSort:
	static func sort_explorer(a: Entity, b: Entity):
		return a.id < b.id
