extends Node

onready var planet = preload("res://scripts/ai/planet/planet.gd").new()
onready var ship = preload("res://scripts/ai/ship/ship.gd").new()

func process_entity(entity: Entity, delta: float):
	match entity.entity_type:
		Enums.entity_types.planet:
			return planet.process(entity, delta)
		Enums.entity_types.ship:
			return ship.process(entity, delta)
		
