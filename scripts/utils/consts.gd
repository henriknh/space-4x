extends Node

# Camera
const CAMERA_ZOOM_MIN = 2
const CAMERA_LERPTIME_POS = 50
const CAMERA_LERPTIME_ZOOM = 15
const CAMERA_ZOOM_STEP = 1.1

# General
const COMPUTER_COUNT = {
	Enums.world_size.small: {
		'min': 2, 
		'max': 5, 
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

# AI
const AI_DIFFICULTY_LEVELS = 3
const AI_DELAY_TIME = 1

# Galaxy
const GALAXY_SIZE = {
	Enums.world_size.small: {
		'min': 4, 
		'max': 8, 
	},
	Enums.world_size.medium: {
		'min': 6, 
		'max': 12, 
	},
	Enums.world_size.large: {
		'min': 8, 
		'max': 18, 
	}
}

# Planet system
const PLANET_SYSTEM_BASE_DISTANCE_TO_SUN = 1000
const PLANET_SYSTEM_RADIUS = 4000
const PLANET_SYSTEM_ORBITS = {
	Enums.world_size.small: {
		'min': 6, 
		'max': 10, 
	},
	Enums.world_size.medium: {
		'min': 8, 
		'max': 15, 
	},
	Enums.world_size.large: {
		'min': 10, 
		'max': 30, 
	}
}

# Asteroids
const ASTEROIDS_BASE_DISTANCE_TO_SUN = PLANET_SYSTEM_BASE_DISTANCE_TO_SUN
const ASTEROIDS_EXTRA_DISTANCE = PLANET_SYSTEM_BASE_DISTANCE_TO_SUN / 2
const ASTEROIDS_PER_PLANET_SYSTEM = {
	Enums.world_size.small: {
		'min': 300, 
		'max': 600, 
	},
	Enums.world_size.medium: {
		'min': 600, 
		'max': 1100, 
	},
	Enums.world_size.large: {
		'min': 1100, 
		'max': 2000, 
	}
}

const ASTEROIDS_FORMATION_OFFSET = PLANET_SYSTEM_RADIUS * 0.05
const ASTEROIDS_FORMATION_BELT_DISTANCE = PLANET_SYSTEM_RADIUS * 0.66
const ASTEROIDS_FORMATION_HILDA_SIZE = PLANET_SYSTEM_RADIUS * 0.9
const ASTEROIDS_FORMATION_HILDA_BREAK_POINT = PLANET_SYSTEM_RADIUS * 0.8
const ASTEROIDS_FORMATION_DUAL_LARGEST = PLANET_SYSTEM_RADIUS * 0.8
const ASTEROIDS_FORMATION_DUAL_SMALLEST = PLANET_SYSTEM_RADIUS * 0.4

# Ships
const SHIP_PRODUCTION_TIME = 10
const SHIP_REBUILD_TIME = 10
const SHIP_COST_TITANIUM = 1
const SHIP_ACCELERATION_FACTOR: float = 0.1 # Factor of max_speed
const SHIP_TURN_SPEED: int = 4

# Research
const RESEARCH_COST_ASTRAL_DUST = 1
