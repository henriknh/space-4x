extends Node

const corporation_colors = {
	0: Color(0.15, 0.15, 0.15),
	1: Color(1, 1, 1), # white
	2: Color(0.321, 0.517, 1), # blue
	3: Color(0.556, 1, 0.360), # green
	4: Color(1, 0.247, 0.219), # red
	5: Color(0.988, 0.372, 0.564), # pink
	6: Color(0.968, 0.988, 0.372), # yellow
	7: Color(0.552, 0.490, 0.831), # purple
	8: Color(0.992, 0.658, 0.247), # orange
	9: Color(0.247, 0.992, 0.976), # teal
	10: Color(0.694, 0.819, 0.501), # forest green
	11: Color(0.529, 0.721, 0.768), # aqua blue
	12: Color(0.831, 0.717, 0.490) # light brown
}

const resource_types = {
	'asteroid_rock': 0,
	'titanium': 1,
	'astral_dust': 2,
}

const resource_colors = {
	resource_types.asteroid_rock: Color(0.352, 0.301, 0.254, 1),
	resource_types.titanium: Color(0.752, 0.752, 0.752, 1),
	resource_types.astral_dust: Color(0.560, 0.819, 1, 1),
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
	'prop': 3003
}

# Objects 4000 - 4999
const prop_types = {
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
	'convertion': 5102,
	'colonize': 5103
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
	'moving': 6101,
}

# Research 7000 - 7999
const research_types = {
	'dummy': 7000
}
