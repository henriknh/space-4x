extends Node

var prefab_asteroid = preload('res://prefabs/entities/props/asteroid/asteroid.tscn')

func create(gameScene: Node, planet_system_idx: int) -> void:
	var asteroids_min = Consts.ASTEROIDS_PER_PLANET_SYSTEM[WorldGenerator.world_size].min
	var asteroids_max = Consts.ASTEROIDS_PER_PLANET_SYSTEM[WorldGenerator.world_size].max
	
	for idx in range(WorldGenerator.rng.randi_range(asteroids_min, asteroids_max)):
		var angle = WorldGenerator.rng.randf() * 2 * PI
		var distance = Consts.ASTEROIDS_BASE_DISTANCE_TO_SUN + WorldGenerator.rng.randf() * (Consts.PLANET_SYSTEM_RADIUS + Consts.ASTEROIDS_EXTRA_DISTANCE)
		var instance = prefab_asteroid.instance()
		instance.planet_system = planet_system_idx
		instance.position = Vector2(distance * cos(angle), distance * sin(angle))
		instance.create()
		gameScene.add_child(instance)
