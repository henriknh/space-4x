extends Node

enum planet_types {
	lava,
	iron,
	earth,
	ice
}

const scenes = {
	'loading': 'res://scenes/loading.tscn',
	'menu': 'res://scenes/menu.tscn',
	'game': 'res://scenes/game.tscn',
	'galaxy': 'res://scenes/galaxy_system.tscn',
	'star_system': 'res://scenes/star_system.tscn'
}

const world_sizes = {
	0: 'Small',
	1: 'Medium',
	2: 'Large'
}
