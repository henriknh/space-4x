extends Node

func process(entity: Entity):
	if entity.parent.faction != 0:
		var adjacent_sites = Nav.get_adjacent_sites(entity.parent)
		adjacent_sites.sort_custom(AIShipExplorerSort, "sort_explorer")
		entity.set_entity_process(Enums.ship_states.travel, adjacent_sites[0].id)
	else:
		entity.state = Enums.ship_states.colonize

class AIShipExplorerSort:
	static func sort_explorer(a: Entity, b: Entity):
		return a.id < b.id
