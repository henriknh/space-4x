extends Node

var prefab = preload('res://prefabs/star_system.tscn')

func create(target: Node, star_system_idx: int) -> void:
	var instance = prefab.instance()
	instance.position = Vector2(star_system_idx * 250, 0)
	instance.create()
	instance.set_star_system(star_system_idx)
	target.add_child(instance)
