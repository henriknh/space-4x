extends Node

func process(entity: Entity):
	var faction = Factions.get_faction(entity.faction)

	if faction.friendliness < 0 and Random.randf() <= abs(faction.friendliness):
		var adjacent_sites = Nav.get_adjacent_sites(entity.parent)
		adjacent_sites.sort_custom(AIShipCombatSort, "sort_combat")
		entity.set_entity_process(Enums.ship_states.travel, adjacent_sites[0].id)

class AIShipCombatSort:
	static func sort_combat(a: Entity, b: Entity):
		if a.faction == -1 and b.faction == -1:
			return a.id < b.id
		elif a.faction >= 0 and b.faction == -1:
			return false
		elif a.faction == -1 and b.faction >= 0:
			return true