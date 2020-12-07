extends Node

var prefab = preload('res://prefabs/entities/planet_system/planet_system.tscn')

func create(target: Node, planet_system_idx: int) -> void:
	var instance = prefab.instance()
	instance.position = Vector2(planet_system_idx * 250, 0)
	instance.create()
	instance.planet_system = planet_system_idx
	target.add_child(instance)
