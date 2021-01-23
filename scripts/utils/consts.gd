extends Node

# Camera
const CAMERA_ZOOM_MIN = 2
const CAMERA_ZOOM_MAX = 200
const CAMERA_LERPTIME_POS = 50
const CAMERA_LERPTIME_ZOOM = 15
const CAMERA_ZOOM_STEP = 1.1

# Galaxy
const galaxy_size = {
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
const planet_system_base_distance_to_sun = 2500
const planet_system_radius = 30000
const planet_system_orbits = {
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
const asteroids_base_distance_to_sun = 2000
const asteroids_extra_distance = 800
const asteroids_per_planet_system = {
	Enums.world_size.small: {
		'min': 200, 
		'max': 400, 
	},
	Enums.world_size.medium: {
		'min': 400, 
		'max': 800, 
	},
	Enums.world_size.large: {
		'min': 800, 
		'max': 1600, 
	}
}

# Ships
const ship_acceleration_factor: float = 0.1 # Factor of max_speed
const ship_turn_speed: int = 4
