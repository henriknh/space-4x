extends Node

var prefab_asteroid = preload('res://prefabs/entities/objects/asteroid/asteroid.tscn')

func create(gameScene: Node, planet_system_idx: int) -> void:
	for idx in range(WorldGenerator.rng.randi_range(Consts.asteroids_min, Consts.asteroids_max)):
		var angle = WorldGenerator.rng.randf() * 2 * PI
		var distance = Consts.asteroids_base_distance_to_sun + WorldGenerator.rng.randf() * (Consts.planet_system_radius + Consts.asteroids_extra_distance)
		var instance = prefab_asteroid.instance()
		instance.planet_system = planet_system_idx
		instance.position = Vector2(distance * cos(angle), distance * sin(angle))
		instance.create()
		gameScene.add_child(instance)
