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

# World 0 - 999
const world_size = {
	'small': 0,
	'medium': 1,
	'large': 2
}

const world_size_label = {
	world_size.small: 'Small',
	world_size.medium: 'Medium',
	world_size.large: 'Large'
}

# Entity 1000 - 1999
const entity_types = {
	'ship': 1000,
	'planet': 1001,
	'object': 1003
}

# Objects 2000 - 2999
const object_types = {
	'asteroid': 2000
}

# Planets 3000 - 3999
const planet_types = {
	'lava': 3000,
	'iron': 3001,
	'earth': 3002,
	'ice': 3003
}

const planet_states = {
	'idle': 3100,
	'produce': 3101
}

const planet_scripts = {
	'earth': 'res://prefabs/entities/planets/planet_earth.gd',
	'ice': 'res://prefabs/entities/planets/planet_ice.gd',
	'iron': 'res://prefabs/entities/planets/planet_iron.gd',
	'lava': 'res://prefabs/entities/planets/planet_lava.gd'
}

# Ships 4000 - 4999
const ship_types = {
	'disabled': 4000,
	'combat': 4001,
	'explorer': 4002,
	'miner': 4003,
	'transport': 4004
}

const ship_colors = {
	ship_types.disabled: Color(0, 0, 0, 1),
	ship_types.combat: Color(1, 0, 0.4, 1),
	ship_types.explorer: Color(1, 1, 1, 1),
	ship_types.miner: Color(1, 0.8, 0.4, 1),
	ship_types.transport: Color(0.2, 0.5, 1, 1)
}

const ship_states = {
	'idle': 4100,
	'rebase': 4101,
	'rebuild': 4102,
	'travel': 4103,
	'mine': 4104,
	'deliver': 4105,
	'combat': 4106,
	'explore': 4107,
	'colonize': 4108
}
