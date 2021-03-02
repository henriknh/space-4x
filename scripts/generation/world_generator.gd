extends Node

const GenUtils = preload('res://scripts/generation/utils.gd')
const GenPlanets = preload('res://scripts/generation/planets.gd')
const GenAsteroids = preload('res://scripts/generation/asteroids.gd')

var world_size: int = Enums.world_size.small
var unique_id = 0 setget ,get_unique_id

var gameScene
var load_progress: float = 0
var total_entities: float  = 0

signal objects_loaded
	
func get_unique_id() -> int:
	unique_id += 1
	return unique_id

func generate_world():
	print('Generate world with seed: %d' % Random.get_seed())
	GameState.loading_progress = 0
	
	gameScene = get_node('/root/GameScene')
	
	load_progress = 0
	total_entities = 0
	
	# Calculate planet systems
	GameState.loading_label = 'Loading...'
	var galaxies_min = Consts.GALAXY_SIZE[world_size].min
	var galaxies_max = Consts.GALAXY_SIZE[world_size].max
	var planet_systems = []

	var galaxies_count: float = Random.randi_range(galaxies_min, galaxies_max)
	for planet_system_idx in range(galaxies_count):
		planet_systems.append({
			'planet_system': Instancer.planet_system(planet_system_idx),
			'planets': GenPlanets.generate(planet_system_idx),
			'asteroids': GenAsteroids.generate(planet_system_idx),
		})
	
	for planet_system in planet_systems:
		total_entities += planet_system.planets.size()
		total_entities += planet_system.asteroids.size()
		
		call_deferred("add_node_deffered", planet_system.planet_system)
		for planet in planet_system.planets:
			call_deferred("add_node_deffered", planet)
		for asteroid in planet_system.asteroids:
			call_deferred("add_node_deffered", asteroid)
	
	yield(self, "objects_loaded")
	
	GameState.set_planet_system(0)
	
	var all_planets = get_tree().get_nodes_in_group('Planet')
	var player = Factions.create(0)
	var player_planet = GenUtils.get_start_planet(all_planets, true)
	player_planet.faction = player.faction

	var camera = get_node('/root/GameScene/Camera') as Camera2D
	camera.target_position = player_planet.position
	camera.position = player_planet.position
	
	var computers_min = Consts.COMPUTER_COUNT[world_size].min
	var computers_max = Consts.COMPUTER_COUNT[world_size].max
#	for idx in range(Random.randi_range(computers_min, computers_max)):
#		var ai_faction = Factions.create(idx + 1)
#		var start_planet = GenUtils.get_start_planet(all_planets, ai_faction.faction == 1)
#		start_planet.faction = ai_faction.faction

func add_node_deffered(node: Object):
	gameScene.add_child(node)
	
	load_progress += 1
	GameState.loading_progress = load_progress / total_entities
	
	if load_progress == total_entities:
		emit_signal("objects_loaded")
