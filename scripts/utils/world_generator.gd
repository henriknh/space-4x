extends Node

var _world_size: int = 1
var _seed: int = 0
var _unique_id = 0

onready var rng: RandomNumberGenerator = null

func _ready():
	rng = RandomNumberGenerator.new()
	rng.set_seed(_seed)

func set_world_size(world_size: int) -> void:
	_world_size = world_size

func set_seed(seed_value: int) -> void:
	_seed = seed_value
	rng = RandomNumberGenerator.new()
	rng.set_seed(_seed)
	
func get_new_id() -> int:
	_unique_id += 1
	return _unique_id

func generate_world():
	print('Generate world with seed: %d' % rng.get_seed())
	
	var planet_system_count = 2 #WorldGenerator.rng.randi_range(2, 2)
	print('Planet systems: %d' % planet_system_count)
	
	var spawner_planet_systems = load('res://scripts/spawners/spawner_planet_systems.gd').new()
	var spawner_planets = load('res://scripts/spawners/spawner_planets.gd').new()
	var spawner_objects = load('res://scripts/spawners/spawner_objects.gd').new()
	var gameScene = get_node('/root/GameScene')
	for planet_system_idx in range(planet_system_count):
		# Spawn planet systems
		spawner_planet_systems.create(gameScene, planet_system_idx)
		
		# Spawn planets
		spawner_planets.create(gameScene, planet_system_idx)
		
		var planets = []
		for planet in get_tree().get_nodes_in_group('Planet'):
			if planet.planet_system == planet_system_idx:
				planets.append(planet)
				
		var voronoi = Voronoi.voronoi_registry.register_voronoi(planet_system_idx, planets)
		
		for planet in planets:
			planet.planet_convex_hull = voronoi.site_registry.get_convex_hull_of_node(planet)
			
		# Spawn objects
		spawner_objects.create(gameScene, planet_system_idx)
		
	var players = [1]
	for player in players:
		var start_planet = _get_start_planet()
		start_planet.faction = player
		_set_start_resouces(start_planet)
		
	var start_planet = _get_start_planet()
	start_planet.faction = 0
	_set_start_resouces(start_planet)
	
	GameState.set_planet_system(0)
	
	var camera = get_node('/root/GameScene/Camera') as Camera2D
	camera.target_position = start_planet.position
	camera.position = start_planet.position

func _get_start_planet() -> entity:
	var possible_planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == 0 and planet.faction == -1:
			possible_planets.append(planet)
	
	return possible_planets[WorldGenerator.rng.randi() % possible_planets.size()]

func _set_start_resouces(planet: entity):
	planet.metal = 1000
	planet.power = 1000
	planet.food = 1000
	planet.water = 1000
	
