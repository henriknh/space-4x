extends Node

static func process(entity: Entity):
	var ai = AI.get_ai(entity.faction)
	
	if entity.metal == Consts.SHIP_COST_METAL:
		var miner_ships = entity.get_ships_by_type(Enums.ship_types.miner)
		if miner_ships.size() == 0:
			entity.metal -= Consts.SHIP_COST_METAL
			return entity.set_entity_process(Enums.planet_states.produce, Enums.ship_types.miner, 10)
		
	if entity.metal >= Consts.SHIP_COST_METAL:
		
		var potential_ships = [
			Enums.ship_types.combat,
			Enums.ship_types.miner,
			Enums.ship_types.explorer,
			Enums.ship_types.transport,
		]
		
		if ai.friendliness < 0:
			potential_ships.append(Enums.ship_types.combat)
		if ai.friendliness < -0.5:
			potential_ships.append(Enums.ship_types.combat)
			
		if entity.metal <= Consts.SHIP_COST_METAL * 2:
			potential_ships.append(Enums.ship_types.miner)
		if entity.metal <= Consts.SHIP_COST_METAL:
			potential_ships.append(Enums.ship_types.miner)
		
		if ai.explorer > 0.5:
			potential_ships.append(Enums.ship_types.explorer)
			
		potential_ships.shuffle()
		
		entity.metal -= Consts.SHIP_COST_METAL
		entity.set_entity_process(Enums.planet_states.produce, potential_ships[0], 10)
	else:
		entity.state = Enums.ai_states.idle
