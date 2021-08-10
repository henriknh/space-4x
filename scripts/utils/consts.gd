extends Node

# https://www.redblobgames.com/grids/hexagons/
# https://github.com/romlok/godot-gdhexgrid

# Camera
const CAMERA_ZOOM_MIN = 2
const CAMERA_LERPTIME_POS = 50
const CAMERA_LERPTIME_ZOOM = 15
const CAMERA_ZOOM_STEP = 1.1

# General
const COMPUTER_COUNT = {
	Enums.world_size.small: {
		'min': 1, 
		'max': 1, 
	},
	Enums.world_size.medium: {
		'min': 4, 
		'max': 7, 
	},
	Enums.world_size.large: {
		'min': 6, 
		'max': 9, 
	}
}

# Resources
const RESOURCE_START_ASTEROID_ROCKS = 5
const RESOURCE_START_TITANIUM = 0
const RESOURCE_START_ASTRAL_DUST = 0
const RESOURCE_CONVERTION_COST = 2
const RESOURCE_CONVERTION_TIME = 5
const RESOURCE_CONVERTION_RATIO = 0.5

# Player
const PLAYER_CORPORATION = 1
# AI
const AI_DIFFICULTY_LEVELS = 3
const AI_DELAY_TIME = 1

# Galaxy
const GALAXY_SIZE = {
	Enums.world_size.small: {
		'min': 1, #6,
		'max': 1 #8
	},
	Enums.world_size.medium: {
		'min': 8,
		'max': 12
	},
	Enums.world_size.large: {
		'min': 12,
		'max': 16
	}
}
const GALAXY_GAP_PLANET_SYSTEMS = {
	Enums.world_size.small: 150,
	Enums.world_size.medium: 200,
	Enums.world_size.large: 250
}

# Planet system
const PLANET_SYSTEM_RADIUS = {
	Enums.world_size.small: {
		'gap': 3,
		'min': 10,
		'max': 12
	},
	Enums.world_size.medium: {
		'gap': 4,
		'min': 14, 
		'max': 16, 
	},
	Enums.world_size.large: {
		'gap': 5,
		'min': 18, 
		'max': 20, 
	}
}
const PLANET_SYSTEM_PLANETS = {
	Enums.world_size.small: {
		'min': 3, 
		'max': 3, 
	},
	Enums.world_size.medium: {
		'min': 8, 
		'max': 12, 
	},
	Enums.world_size.large: {
		'min': 12, 
		'max': 16, 
	}
}
const PLANET_SYSTEM_DIR_ALL = [
	Vector2(+1, +1), Vector2(0, +2), Vector2(-1, +1),
	Vector2(-1, -1), Vector2(0, -2), Vector2(+1, -1)
]

# Tile
const TILE_SIZE = 5
const TILE_DIR_ALL = [
	Vector2(+2,  0), Vector2(+1, +1), Vector2(-1, +1),
	Vector2(-2,  0), Vector2(-1, -1), Vector2(+1, -1)
]


# Planets
const PLANET_HITPOINTS = 250
const PLANET_PROCESS_INDICATION_SIZE = 20
const PLANET_COLONIZE_INITIAL_PROGRESS = 0.1
const PLANET_COLONIZE_PROGRESS_PER_TICK = 0.01

# Ships
const SHIP_PRODUCTION_TIME = 10
const SHIP_REBUILD_TIME = 10
const SHIP_COST_FIGHTER = 2
const SHIP_COST_CARRIER = 10
const SHIP_BOID_COHESION_FORCE: float = 0.01
const SHIP_BOID_ALIGNMENT_FORCE: float = 1.0
const SHIP_BOID_SEPARATION_FORCE: float = 0.5
const SHIP_BOID_AVOID_DISTANCE: int = 100
const SHIP_HITPOINTS_COMBAT = 50
const SHIP_HITPOINTS_EXPLORER = 40
const SHIP_HITPOINTS_MINER = 20
const SHIP_SPEED_COMBAT = 200
const SHIP_SPEED_EXPLORER = 150
const SHIP_SPEED_MINER = 100
const SHIP_SPEED_IDLE = 100
