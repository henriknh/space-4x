extends Node

const CAMERA_ZOOM_MIN = 2
const CAMERA_ZOOM_MAX = 200
const CAMERA_LERPTIME_POS = 50
const CAMERA_LERPTIME_ZOOM = 15

# Galaxy
const galaxy_min = 2
const galaxy_max = 4

# Planet system
const planet_system_base_distance_to_sun = 2500
const planet_system_radius = 30000
const planet_system_min_orbits = 4 #4
const planet_system_max_orbits = 28 #16

# Asteroids
const asteroids_base_distance_to_sun = 2000
const asteroids_extra_distance = 800
const asteroids_min = 101
const asteroids_max = 500

# Ships
const ship_acceleration_factor: float = 0.1 # Factor of max_speed
const ship_turn_speed: int = 4
