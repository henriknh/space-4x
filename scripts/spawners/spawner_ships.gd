extends Node

func create(gameScene: Node):
	for _i in range(1):
		
		
		
		var instance = Instancer.ship(WorldGenerator.rng.randi_range(0, Enums.ship_types.size() - 1))
		
		instance.planet_system = GameState.get_planet_system()
		
		instance.faction = instance.id % 2
		instance.position = Vector2(0, (WorldGenerator.rng.randi() % 5) * 2000)
		gameScene.add_child(instance)
