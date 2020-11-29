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
var max_orbits = 6
var orbits_exp_factor = 0.3

var base_distance_to_sun = 800
var min_distance_orbits = 600
var max_distance_orbits = 1400
var distance_orbits_planet_count_factor = 7

func create(target: Node, planet_system_idx: int) -> int:
	
	planet_system_plant_odds = {}
	orbit_distances = []
	sum_orbit_weight = 0
	planet_system_size = 0
	planets_placed = 0
	
	var file = File.new()
	file.open("res://assets/planet_system_plant_odds.json", file.READ)
	var json_text = file.get_as_text()
	planet_system_plant_odds = JSON.parse(json_text).result
	planets = int(WorldGenerator.rng.randi_range(min_planets, max_planets))
	orbits = int(WorldGenerator.rng.randi_range(min_orbits, max_orbits))
	
	for orbit in range(orbits):
		sum_orbit_weight += _get_orbit_weight(orbit)
	
	for orbit in range(orbits):
		
		var planets_in_orbit = max(_get_planets_on_orbit(orbit), 1)

		planets_placed += planets_in_orbit
		
		var angle_span = (2 * PI) / planets_in_orbit
		var random_main_angle = WorldGenerator.rng.randf() * 2 * PI
		
		planet_system_size += WorldGenerator.rng.randi_range(min_distance_orbits, max_distance_orbits) + planets * orbits * distance_orbits_planet_count_factor
		orbit_distances.push_back(planet_system_size)
		
		for planet_in_orbit in range(planets_in_orbit):
			var angle = random_main_angle + angle_span * planet_in_orbit + angle_span * 0.2 + angle_span * WorldGenerator.rng.randf() * 0.6
			
			var position = Vector2((base_distance_to_sun + planet_system_size) * sin(angle), (base_distance_to_sun + planet_system_size) * cos(angle))
			
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
			instance.set_planet_system(planet_system_idx)
			instance.set_planet_type(planet_type)
			instance.set_planet_size(WorldGenerator.rng.randf_range(1.0, 2.0))
			instance.set_orbit_distance(base_distance_to_sun + planet_system_size)
			instance.visible = false
			instance.create()
			target.add_child(instance)
			
	return planet_system_size

func _get_planets_on_orbit(orbit):
	if orbit + 1 < orbits:
		return round(planets * (_get_orbit_weight(orbit) / sum_orbit_weight))
	else:
		return planets - planets_placed

func _get_orbit_weight(orbit):
	return 1 + exp(orbit * orbits_exp_factor)
	
func _calc_planet_type(orbit):
	var r = WorldGenerator.rng.randf()
	var odds_sum = 0

	odds_sum += planet_system_plant_odds[str(orbits)][str(orbit)]['lava']
	if r <= odds_sum:
		return Enums.planet_types.lava

	odds_sum += planet_system_plant_odds[str(orbits)][str(orbit)]['iron']
	if r <= odds_sum:
		return Enums.planet_types.iron

	odds_sum += planet_system_plant_odds[str(orbits)][str(orbit)]['earth']
	if r <= odds_sum:
		return Enums.planet_types.earth

	odds_sum += planet_system_plant_odds[str(orbits)][str(orbit)]['ice']
	if r <= odds_sum:
		return Enums.planet_types.ice
		
	return -1
