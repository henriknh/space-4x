extends Node

func process(entity: Entity):
	var corporation = entity.get_corporation()

	if corporation.friendliness < 0 and Random.randf() <= abs(corporation.friendliness):
		var adjacent_sites = Nav.get_adjacent_sites(entity.parent)
		adjacent_sites.sort_custom(AIShipCombatSort, "sort_combat")
		entity.set_entity_process(Enums.ship_states.travel, adjacent_sites[0].id)

class AIShipCombatSort:
	static func sort_combat(a: Entity, b: Entity):
		if a.corporation_id == 0 and b.corporation_id == 0:
			return a.id < b.id
		elif a.corporation_id > 0 and b.corporation_id == 0:
			return false
		elif a.corporation_id == 0 and b.corporation_id > 0:
			return true
