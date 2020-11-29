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
	print('generate world with seed: %d' % rng.get_seed())
	
	var spawner_planet_systems = load('res://scripts/spawners/spawner_planet_systems.gd').new()
	var spawner_planets = load('res://scripts/spawners/spawner_planets.gd').new()
	var spawner_objects = load('res://scripts/spawners/spawner_objects.gd').new()
	
	for planet_system_idx in range(2):
		spawner_planet_systems.create(get_node('/root'), planet_system_idx)
		var planet_system_size = spawner_planets.create(get_node('/root'), planet_system_idx)
		spawner_objects.create(get_node('/root'), planet_system_idx, planet_system_size)
	
	State.set_planet_system(0)
