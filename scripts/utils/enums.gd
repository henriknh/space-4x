extends Node

enum entity_types {
	ship,
	planet,
	object
}

enum planet_types {
	lava,
	iron,
	earth,
	ice
}

enum ship_types {
	combat,
	miner,
	transport,
	utility
}

const scenes = {
	'loading': 'res://prefabs/scenes/loading.tscn',
	'main_menu': 'res://prefabs/scenes/main_menu.tscn',
	'game': 'res://prefabs/scenes/game.tscn',
	'galaxy_system': 'res://prefabs/scenes/galaxy_system.tscn',
	'planet_system': 'res://prefabs/scenes/planet_system.tscn'
}

const world_sizes = {
	0: 'Small',
	1: 'Medium',
	2: 'Large'
}
