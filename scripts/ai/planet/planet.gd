extends Node

static func process(entity: Planet, delta: float):
	var corporation = entity.get_corporation()
	
	if entity.state == Enums.ai_states.delay:
		entity.process_time += delta
		
		if entity.get_process_progress() > 1:
			if (corporation.titanium == 0 or corporation.astral_dust == 0) and corporation.asteroid_rocks >= Consts.RESOURCE_CONVERTION_COST:
				convertion(entity, corporation)
			elif corporation.titanium >= Consts.SHIP_COST_TITANIUM:
				produce(entity, corporation)
			elif corporation.asteroid_rocks >= Consts.RESOURCE_CONVERTION_COST:
				convertion(entity, corporation)
			else:
				entity.state = Enums.planet_states.idle
			
	if entity.state == Enums.ai_states.idle:
		var delay_time = (Consts.AI_DIFFICULTY_LEVELS - corporation.difficulty) * Consts.AI_DELAY_TIME
		entity.set_entity_process(Enums.ai_states.delay, -1, delay_time)

static func produce(entity: Planet, corporation: Corporation):
	if corporation.titanium < Consts.SHIP_COST_TITANIUM:
		return
	
	var ship_to_produce
	if corporation.titanium == Consts.SHIP_COST_TITANIUM:
		var has_miner_ships = false
		for ship in entity.ships:
			if ship.ship_type == Enums.ship_types.miner:
				has_miner_ships = true
				break
		if not has_miner_ships:
			ship_to_produce = Enums.ship_types.miner
	
	if not ship_to_produce:
		
		var potential_ships = [
			Enums.ship_types.combat,
			Enums.ship_types.miner,
			Enums.ship_types.explorer,
		]
		
		if corporation.friendliness < 0:
			potential_ships.append(Enums.ship_types.combat)
		if corporation.friendliness < -0.5:
			potential_ships.append(Enums.ship_types.combat)
			
		if corporation.titanium <= Consts.SHIP_COST_TITANIUM * 2:
			potential_ships.append(Enums.ship_types.miner)
		if corporation.titanium <= Consts.SHIP_COST_TITANIUM:
			potential_ships.append(Enums.ship_types.miner)
		
		if corporation.explorer > 0.5:
			potential_ships.append(Enums.ship_types.explorer)
			
		potential_ships.shuffle()
		ship_to_produce = potential_ships[0]
	
	if ship_to_produce:
		corporation.titanium -= Consts.SHIP_COST_TITANIUM
		entity.set_entity_process(Enums.planet_states.produce, ship_to_produce, Consts.SHIP_PRODUCTION_TIME)

static func convertion(entity: Planet, corporation: Corporation):
	corporation.asteroid_rocks -= Consts.RESOURCE_CONVERTION_COST
	if corporation.titanium == 0:
		entity.set_entity_process(Enums.planet_states.convertion, Enums.resource_types.titanium, Consts.RESOURCE_CONVERTION_TIME)
	elif corporation.astral_dust == 0:
		entity.set_entity_process(Enums.planet_states.convertion, Enums.resource_types.astral_dust, Consts.RESOURCE_CONVERTION_TIME)
	else:
		if Random.randi() % 2 == 0:
			entity.set_entity_process(Enums.planet_states.convertion, Enums.resource_types.titanium, Consts.RESOURCE_CONVERTION_TIME)
		else:
			entity.set_entity_process(Enums.planet_states.convertion, Enums.resource_types.titanium, Consts.RESOURCE_CONVERTION_TIME)
			#entity.set_entity_process(Enums.planet_states.convertion, Enums.resource_types.astral_dust, Consts.RESOURCE_CONVERTION_TIME)
