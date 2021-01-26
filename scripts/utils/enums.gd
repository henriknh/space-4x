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

# World 1000 - 1999
const world_size = {
	'small': 1000,
	'medium': 1001,
	'large': 1002
}

const world_size_label = {
	world_size.small: 'Small',
	world_size.medium: 'Medium',
	world_size.large: 'Large'
}

# Entity 2000 - 2999
const entity_types = {
	'ship': 2000,
	'planet': 2001,
	'object': 2003
}

# Objects 3000 - 3999
const object_types = {
	'asteroid': 3000
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

# Ships 5000 - 5999
const ship_types = {
	'disabled': 5000,
	'combat': 5001,
	'explorer': 5002,
	'miner': 5003,
	'transport': 5004
}

const ship_colors = {
	ship_types.disabled: Color(0, 0, 0, 1),
	ship_types.combat: Color(1, 0, 0.4, 1),
	ship_types.explorer: Color(1, 1, 1, 1),
	ship_types.miner: Color(1, 0.8, 0.4, 1),
	ship_types.transport: Color(0.2, 0.5, 1, 1)
}

const ship_states = {
	'idle': 0,
	'rebase': 5101,
	'rebuild': 5102,
	'travel': 5103,
	'mine': 5104,
	'deliver': 5105,
	'combat': 5106,
	'explore': 5107,
	'colonize': 5108
}
