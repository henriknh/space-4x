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

const planet_scripts = {
	'earth': 'res://prefabs/entities/planets/planet_earth.gd',
	'ice': 'res://prefabs/entities/planets/planet_ice.gd',
	'iron': 'res://prefabs/entities/planets/planet_iron.gd',
	'lava': 'res://prefabs/entities/planets/planet_lava.gd'
}

enum ship_types {
	combat,
	explorer,
	miner,
	transport
}

const ship_scripts = {
	'combat': 'res://prefabs/entities/ships/ship_combat.gd',
	'explorer': 'res://prefabs/entities/ships/ship_explorer.gd',
	'miner': 'res://prefabs/entities/ships/ship_miner.gd',
	'transport': 'res://prefabs/entities/ships/ship_transport.gd'
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