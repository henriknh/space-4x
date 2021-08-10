extends Node

const corporation_colors = {
	0: Color(0.25, 0.25, 0.25),
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

const ui_colors = {
	'science': Color(0, 0.7, 1),
	'ship': Color(1, 0.4, 0),
	'build': Color(0, 1, 0.5)
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
enum entity_types {
	NONE = 3000,
	SHIP = 3001,
	PLANET = 3002,
	ASTEROID = 3003,
	NEBULA = 3004,
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
enum ship_types {
	disabled = 6000,
	explorer = 6001,
	fighter = 6002,
	carrier = 6003,
	miner = 6004,
}

const ship_colors = {
	ship_types.disabled: Color(0, 0, 0, 1),
	ship_types.fighter: Color(1, 0, 0.4, 1),
	ship_types.carrier: Color(1, 0, 0.4, 1),
	ship_types.explorer: Color(1, 1, 1, 1),
	ship_types.miner: Color(1, 0.8, 0.4, 1),
}

const ship_states = {
	'idle': 0,
	'moving': 6101,
}

# Research
enum research_types {
	NONE = 			0
	SHIP_DMG_1 = 	int(pow(2, 0)),
	SHIP_DMG_2 = 	int(pow(2, 1)),
	SHIP_DMG_3 = 	int(pow(2, 2)),
	SHIP_HEALTH_1 = int(pow(2, 3)),
	SHIP_HEALTH_2 = int(pow(2, 4)),
	SHIP_HEALTH_3 = int(pow(2, 5)),
	TURRET = 		int(pow(2, 6)),
}

const research_types_cost = {
	research_types.SHIP_DMG_1: 5,
	research_types.SHIP_DMG_2: 20,
	research_types.SHIP_DMG_3: 50,
	research_types.SHIP_HEALTH_1: 5,
	research_types.SHIP_HEALTH_2: 20,
	research_types.SHIP_HEALTH_3: 50,
	research_types.TURRET: 25
}

# Cost
enum produce_types {
	NONE = 			0
	SHIP = 			int(pow(2, 0)),
	CONVERT_SHIP = 	int(pow(2, 1)),
	PLANET_TURRET = int(pow(2, 2)),
}

const produce_types_cost = {
	produce_types.SHIP: 5,
	produce_types.CONVERT_SHIP: 5,
	produce_types.PLANET_TURRET: 5,
}
