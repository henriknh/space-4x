extends Node2D

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

var planet_system_plant_odds = {}
var orbit_distances = []
var sum_orbit_weight = 0
var planet_system_size = 0
var planets_placed = 0

var prefab_earth = preload('res://prefabs/entities/planets/earth/planet_earth.tscn')
var prefab_ice = preload('res://prefabs/entities/planets/ice/planet_ice.tscn')
var prefab_iron = preload('res://prefabs/entities/planets/iron/planet_iron.tscn')
var prefab_lava = preload('res://prefabs/entities/planets/lava/planet_lava.tscn')

var planets = 0
var min_planets = 10
var max_planets = 30

onready var orbits = 0
var min_orbits = 4
var max_orbits = 16
# 4-8 small
# 9-12 medium
# 13-16 large
var orbits_exp_factor = 0.3

var base_distance_to_sun = 600
var min_distance_orbits = 600
var max_distance_orbits = 1200
var distance_orbits_planet_count_factor = 7

var quadrants = {
	0: 0,
	1: 0,
	2: 0,
	3: 0
}

func create(target: Node, planet_system_idx: int) -> int:
	
	planet_system_plant_odds = {}
	orbit_distances = []
	sum_orbit_weight = 0
	planet_system_size = 0
	planets_placed = 0
	var orbit_distance = WorldGenerator.rng.randi_range(min_distance_orbits, max_distance_orbits)
	
	quadrants = {
		0: 0,
		1: 0,
		2: 0,
		3: 0
	}
	
	var file = File.new()
	file.open("res://assets/planet_system_plant_odds.json", file.READ)
	var json_text = file.get_as_text()
	planet_system_plant_odds = JSON.parse(json_text).result
	orbits = int(WorldGenerator.rng.randi_range(min_orbits, max_orbits))
	
	var orbit_diff = (30000 / orbits) * 0.2
	print(orbit_diff)
	print(orbit_diff)
	print(orbit_diff)
	print(orbit_diff)
	
	var planet_types = []
	
	for orbit in range(orbits):
		
		var smallest_quadrant = _get_least_dense_quadrant()
		var angle = WorldGenerator.rng.randf() * PI / 2 + smallest_quadrant * PI / 2
		orbit_distance = (30000 / orbits) * (orbit + 1) + WorldGenerator.rng.randi_range(-orbit_diff, orbit_diff)
		
		var position = Vector2(orbit_distance * sin(angle), orbit_distance * cos(angle))
		var planet_type = _calc_planet_type(orbit)
		var instance = null
		
		match planet_type:
			Enums.planet_types.earth:
				instance = prefab_earth.instance()
			Enums.planet_types.ice:
				instance = prefab_ice.instance()
			Enums.planet_types.iron:
				instance = prefab_iron.instance()
			Enums.planet_types.lava:
				instance = prefab_lava.instance()
				
		instance.position = position
		instance.planet_system = planet_system_idx
		instance.planet_orbit_distance = orbit_distance
		instance.visible = false
		instance.create()
		target.add_child(instance)
		
		planet_types.append(planet_type)
		print('orbit %d, orbits %d, distance %d' % [orbit, orbits, orbit_distance])
			
	print(planet_types)
	
	return planet_system_size

	
func _calc_planet_type(orbit):
	var r = WorldGenerator.rng.randf()
	var odds_sum = 0
	
	if float(orbit) / orbits < 0.25:
		if r < 0.8:
			return Enums.planet_types.lava
		else:
			return Enums.planet_types.iron
	elif float(orbit) / orbits < 0.5:
		if r < 0.2:
			return Enums.planet_types.lava
		elif r < 0.8:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.earth
		
	elif float(orbit) / orbits < 0.75:
		if r < 0.4:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.earth
		
	else:
		if r < 0.4:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.ice
		
		
	return -1
	
func _get_least_dense_quadrant():
	var smallest_quadrant = 0
	var smallest_value = quadrants[smallest_quadrant]
	
	if quadrants[1] < smallest_value:
		smallest_quadrant = 1
		smallest_value = quadrants[smallest_quadrant]
	if quadrants[2] < smallest_value:
		smallest_quadrant = 2
		smallest_value = quadrants[smallest_quadrant]
	if quadrants[3] < smallest_value:
		smallest_quadrant = 3
		smallest_value = quadrants[smallest_quadrant]
		
	quadrants[smallest_quadrant] = quadrants[smallest_quadrant] + 1
	
	return smallest_quadrant
