extends Node

static func process(entity: Entity, delta: float):
	var faction = Factions.get_faction(entity.faction)
	
	if entity.state == Enums.ai_states.delay:
		entity.process_time += delta
		
		if entity.get_process_progress() > 1:
			if (faction.resources.titanium == 0 or faction.resources.astral_dust == 0) and faction.resources.asteroid_rocks >= Consts.RESOURCE_CONVERTION_COST:
				convertion(entity, faction)
			elif faction.resources.titanium >= Consts.SHIP_COST_TITANIUM:
				produce(entity, faction)
			else:
				entity.state = Enums.ai_states.idle
				
			
	if entity.state == Enums.ai_states.idle:
		var delay_time = (Consts.AI_DIFFICULTY_LEVELS - faction.difficulty) * Consts.AI_DELAY_TIME
		entity.set_entity_process(Enums.ai_states.delay, -1, delay_time)

static func produce(entity: Entity, faction: Faction):
	
	if faction.resources.titanium == Consts.SHIP_COST_TITANIUM:
		var miner_ships = entity.get_children_by_type(Enums.ship_types.miner, 'ship_type')
		if miner_ships.size() == 0:
			faction.resources.titanium -= Consts.SHIP_COST_TITANIUM
			return entity.set_entity_process(Enums.planet_states.produce, Enums.ship_types.miner, Consts.SHIP_PRODUCTION_TIME)
		
	if faction.resources.titanium >= Consts.SHIP_COST_TITANIUM:
		
		var potential_ships = [
			Enums.ship_types.combat,
			Enums.ship_types.miner,
			Enums.ship_types.explorer,
		]
		
		if faction.friendliness < 0:
			potential_ships.append(Enums.ship_types.combat)
		if faction.friendliness < -0.5:
			potential_ships.append(Enums.ship_types.combat)
			
		if faction.resources.titanium <= Consts.SHIP_COST_TITANIUM * 2:
			potential_ships.append(Enums.ship_types.miner)
		if faction.resources.titanium <= Consts.SHIP_COST_TITANIUM:
			potential_ships.append(Enums.ship_types.miner)
		
		if faction.explorer > 0.5:
			potential_ships.append(Enums.ship_types.explorer)
			
		potential_ships.shuffle()
		
		faction.resources.titanium -= Consts.SHIP_COST_TITANIUM
		
		entity.set_entity_process(Enums.planet_states.produce, potential_ships[0], Consts.SHIP_PRODUCTION_TIME)

static func convertion(entity: Entity, faction: Faction):
	if faction.resources.titanium == 0:
		entity.set_entity_process(Enums.planet_states.convertion, Enums.resource_types.titanium, Consts.RESOURCE_CONVERTION_TIME)
	elif faction.resources.astral_dust == 0:
		entity.set_entity_process(Enums.planet_states.convertion, Enums.resource_types.astral_dust, Consts.RESOURCE_CONVERTION_TIME)
