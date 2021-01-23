extends Node

const player_colors = {
	-1: Color(0.5, 0.5, 0.5),
	0: Color(1, 1, 1),
	1: Color(0, 0, 1),
	2: Color(0, 1, 0),
	3: Color(1, 0, 0),
	4: Color(0.5, 0, 0),
	5: Color(0, 0.5, 0),
	6: Color(0, 0, 0.5),
	7: Color(0.5, 0.5, 0),
	8: Color(0, 0.5, 0.5),
	9: Color(0.5, 0, 0.5)
}

enum entity_types {
	ship,
	planet,
	object
}

enum object_types {
	asteroid
}

enum planet_types {
	lava,
	iron,
	earth,
	ice
}

enum planet_states {
	idle,
	produce
}

const planet_scripts = {
	'earth': 'res://prefabs/entities/planets/planet_earth.gd',
	'ice': 'res://prefabs/entities/planets/planet_ice.gd',
	'iron': 'res://prefabs/entities/planets/planet_iron.gd',
	'lava': 'res://prefabs/entities/planets/planet_lava.gd'
}

enum ship_types {
	disabled,
	combat,
	explorer,
	miner,
	transport
}

const ship_colors = {
	ship_types.disabled: Color(0, 0, 0, 1),
	ship_types.combat: Color(1, 0, 0.4, 1),
	ship_types.explorer: Color(1, 1, 1, 1),
	ship_types.miner: Color(1, 0.8, 0.4, 1),
	ship_types.transport: Color(0.2, 0.5, 1, 1)
}

enum ship_states {
	idle,
	rebase,
	rebuild,
	travel,
	mine,
	deliver,
	combat,
	explore,
	colonize
}

const scenes = {
	'main_menu': 'res://prefabs/scenes/main_menu.tscn',
	'game': 'res://prefabs/scenes/game.tscn',
	'galaxy_system': 'res://prefabs/scenes/galaxy_system.tscn',
	'planet_system': 'res://prefabs/scenes/planet_system.tscn'
}

# World
enum world_size {
	small,
	medium,
	large
}

const world_size_label = {
	0: 'Small',
	1: 'Medium',
	2: 'Large'
}
