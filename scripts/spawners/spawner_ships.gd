extends Node

var prefab = preload('res://prefabs/ship_combat.tscn')

func create(target):
	for _i in range(10):
		var instance = prefab.instance()
		instance.set_star_system(State.get_star_system())
		instance.create()
		target.add_child(instance)
