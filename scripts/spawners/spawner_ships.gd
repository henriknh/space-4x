extends Node

var prefab_combat = preload('res://prefabs/entities/ships/combat/ship_combat.tscn')
var prefab_transport = preload('res://prefabs/entities/ships/transport/ship_transport.tscn')
var prefab_miner = preload('res://prefabs/entities/ships/miner/ship_miner.tscn')

func create(target):
	for _i in range(100):
		var instance = null
		match WorldGenerator.rng.randi_range(0, 2):
			0:
				instance = prefab_combat.instance()
			1:
				instance = prefab_transport.instance()
			2:
				instance = prefab_miner.instance()
		instance.planet_system = State.get_planet_system()
		instance.create()
		target.add_child(instance)
