extends Node

var combat = load("res://scripts/ai/ship/combat.gd").new()
var explorer = load("res://scripts/ai/ship/explorer.gd").new()
var miner = load("res://scripts/ai/ship/miner.gd").new()

func process(entity: Entity, _delta: float):
	match entity.ship_type:
		Enums.ship_types.combat:
			combat.process(entity)
		Enums.ship_types.explorer:
			explorer.process(entity)
		Enums.ship_types.miner:
			miner.process(entity)
