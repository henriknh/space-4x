extends Node

var prefab = preload('res://prefabs/entities/planet_system/planet_system.tscn')

func create(gameScene: Node, planet_system_idx: int) -> void:
	var instance = prefab.instance()
	instance.position = Vector2(planet_system_idx * 250, 0)
	instance.create()
	instance.planet_system = planet_system_idx
	gameScene.add_child(instance)
