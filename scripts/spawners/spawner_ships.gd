extends Node

var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_combat = load(Enums.ship_scripts.combat)
var script_explorer = load(Enums.ship_scripts.explorer)
var script_miner = load(Enums.ship_scripts.miner)
var script_transport = load(Enums.ship_scripts.transport)

func create(gameScene: Node):
	for _i in range(1):
		
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
				
		instance.set_script(script_combat)
		
		instance.planet_system = GameState.get_planet_system()
		instance.create()
		
		instance.faction = instance.id % 2
		print("faction %d" % instance.faction)
		instance.position = Vector2(0, (WorldGenerator.rng.randi() % 5) * 2000)
		gameScene.add_child(instance)
