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

const resource_types = {
	'asteroid_rock': 0,
	'titanium': 1,
	'astral_dust': 2,
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

const asteroid_formation_types = {
	'none': 1100,
	'belt': 1101,
	'hilda': 1102,
	'dual': 1103
}

# AI 2000 - 2999
const ai_states = {
	'idle': 0,
	'delay': 2000
}

# Entity 3000 - 3999
const entity_types = {
	'ship': 3000,
	'planet': 3001,
	'object': 3003
}

# Objects 4000 - 4999
const object_types = {
	'asteroid': 4000
}

# Planets 5000 - 5999
const planet_types = {
	'lava': 5000,
	'iron': 5001,
	'earth': 5002,
	'ice': 5003
}

const planet_states = {
	'idle': 0,
	'produce': 5101,
	'convertion': 5102
}

const planet_scripts = {
	'earth': 'res://prefabs/entities/planets/planet_earth.gd',
	'ice': 'res://prefabs/entities/planets/planet_ice.gd',
	'iron': 'res://prefabs/entities/planets/planet_iron.gd',
	'lava': 'res://prefabs/entities/planets/planet_lava.gd'
}

# Ships 6000 - 6999
const ship_types = {
	'disabled': 6000,
	'combat': 6001,
	'explorer': 6002,
	'miner': 6003,
}

const ship_colors = {
	ship_types.disabled: Color(0, 0, 0, 1),
	ship_types.combat: Color(1, 0, 0.4, 1),
	ship_types.explorer: Color(1, 1, 1, 1),
	ship_types.miner: Color(1, 0.8, 0.4, 1),
}

const ship_states = {
	'idle': 0,
	'rebase': 6101,
	'rebuild': 6102,
	'travel': 6103,
	'mine': 6104,
	'deliver': 6105,
	'combat': 6106,
	'explore': 6107,
	'colonize': 6108
}

# Research 7000 - 7999
const research_types = {
	'dummy': 6000
}
