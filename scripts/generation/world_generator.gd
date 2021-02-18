extends Node

const GenUtils = preload('res://scripts/generation/utils.gd')
const GenPlanets = preload('res://scripts/generation/planets.gd')
const GenAsteroids = preload('res://scripts/generation/asteroids.gd')

var world_size: int = 1
var unique_id = 0 setget ,get_unique_id

var load_progress: float = 0
var total_entities: float  = 0
	
func get_unique_id() -> int:
	unique_id += 1
	return unique_id

func generate_world():
	print('Generate world with seed: %d' % Random.get_seed())
	GameState.loading_progress = 0
	
	var gameScene = get_node('/root/GameScene')
	
	# Calculate planet systems
	GameState.loading_label = 'Loading...'
	var galaxies_min = Consts.GALAXY_SIZE[world_size].min
	var galaxies_max = Consts.GALAXY_SIZE[world_size].max
	var planet_systems = []

	var galaxies_count: float = Random.randi_range(galaxies_min, galaxies_max)
	for planet_system_idx in range(galaxies_count):
		
		gameScene.call_deferred("add_child", Instancer.planet_system(planet_system_idx))
		for planet in GenPlanets.generate(planet_system_idx):
			gameScene.call_deferred("add_child", planet)
		for asteroid in GenAsteroids.generate(planet_system_idx):
			gameScene.call_deferred("add_child", asteroid)
		
		GameState.loading_progress = (planet_system_idx + 1) / galaxies_count
	
	var all_planets = get_tree().get_nodes_in_group('Planet')
	var player = Factions.create(0)
	var player_planet = GenUtils.get_start_planet(all_planets, true)
	player_planet.faction = player.faction

	var camera = get_node('/root/GameScene/Camera') as Camera2D
	camera.target_position = player_planet.position
	camera.position = player_planet.position
	
	var computers_min = Consts.COMPUTER_COUNT[world_size].min
	var computers_max = Consts.COMPUTER_COUNT[world_size].max
	for idx in range(Random.randi_range(computers_min, computers_max)):
		var ai_faction = Factions.create(idx + 1)
		var start_planet = GenUtils.get_start_planet(all_planets, ai_faction.faction == 1)
		start_planet.faction = ai_faction.faction
	
	GameState.set_planet_system(0)

