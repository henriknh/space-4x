extends Node

var _world_size: int = 1
var _seed: int = 0

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
		var planet_system_size = spawner_planets.create(gameScene, planet_system_idx)
		
		var planets = []
		for planet in get_tree().get_nodes_in_group('Planet'):
			if planet.planet_system == planet_system_idx:
				planets.append(planet)
				
		var voronoi = Voronoi.voronoi_registry.register_voronoi(planet_system_idx, planets)
		
		for planet in planets:
			planet.planet_convex_hull = voronoi.site_registry.get_convex_hull_of_node(planet)
			
		# Spawn objects
		spawner_objects.create(gameScene, planet_system_idx, planet_system_size)
		
	State.set_planet_system(0)
