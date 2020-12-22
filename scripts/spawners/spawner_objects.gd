extends Node

var prefab_asteroid = preload('res://prefabs/entities/objects/asteroid/asteroid.tscn')

var asteroid_base_distance_to_sun = 200
var asteroid_extra_distance = 1000

func create(gameScene: Node, planet_system_idx: int, planet_system_size: int) -> void:
	for idx in range(WorldGenerator.rng.randi_range(25, 50)):
		var angle = WorldGenerator.rng.randf() * 2 * PI
		var distance = asteroid_base_distance_to_sun + WorldGenerator.rng.randf() * (planet_system_size + asteroid_extra_distance)
		var instance = prefab_asteroid.instance()
		instance.planet_system = planet_system_idx
		instance.position = Vector2(distance * cos(angle), distance * sin(angle))
		instance.create()
		gameScene.add_child(instance)
