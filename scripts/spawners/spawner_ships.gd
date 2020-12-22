extends Node

var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_combat = load(Enums.ship_scripts.combat)
var script_explorer = load(Enums.ship_scripts.explorer)
var script_miner = load(Enums.ship_scripts.miner)
var script_transport = load(Enums.ship_scripts.transport)

func create(gameScene: Node):
	for _i in range(100):
		
		var instance = prefab_ship.instance()
		
		match WorldGenerator.rng.randi_range(0, Enums.ship_types.size() - 1):
			Enums.ship_types.combat:
				instance.set_script(script_combat)
			Enums.ship_types.explorer:
				instance.set_script(script_explorer)
			Enums.ship_types.miner:
				instance.set_script(script_miner)
			Enums.ship_types.transport:
				instance.set_script(script_transport)
				
		
		instance.planet_system = State.get_planet_system()
		instance.create()
		gameScene.add_child(instance)
