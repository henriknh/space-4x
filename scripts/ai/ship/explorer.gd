extends Node

func process(entity: Entity):
	if entity.parent.faction != -1:
		var adjacent_site_ids = Nav.get_adjacent_sites(entity.parent)
		var selected_site_id = adjacent_site_ids[WorldGenerator.rng.randi() % adjacent_site_ids.size()]
		entity.set_entity_process(Enums.ship_states.travel, selected_site_id)
	else:
		entity.state = Enums.ship_states.colonize
