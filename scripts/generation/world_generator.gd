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
	
func test_unique_id(_id: int) -> void:
	if unique_id < _id:
		unique_id = _id

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
		
	for planet_system in planet_systems:
		call("add_node_deffered", planet_system.planet_system)
		for planet in planet_system.planets:
			call("add_node_deffered", planet)
		for asteroid in planet_system.asteroids:
			call("add_node_deffered", asteroid)
	
	#yield(self, "objects_loaded")
	
	GameState.set_planet_system(0)
	
	var all_planets = get_tree().get_nodes_in_group('Planet')
	var player = Corporations.create(Consts.PLAYER_CORPORATION)
	var player_planet = GenUtils.get_start_planet(all_planets, true)
	player_planet.corporation_id = player.corporation_id

	var camera = get_node('/root/GameScene/Camera') as Camera2D
	camera.position = player_planet.position
	
	var computers_min = Consts.COMPUTER_COUNT[world_size].min
	var computers_max = Consts.COMPUTER_COUNT[world_size].max
	for idx in range(Random.randi_range(computers_min, computers_max)):
		var ai_corporation = Corporations.create(Consts.PLAYER_CORPORATION + 1 + idx)
		var start_planet = GenUtils.get_start_planet(all_planets, ai_corporation.corporation_id == (Consts.PLAYER_CORPORATION + 1))
		start_planet.corporation_id = ai_corporation.corporation_id
		
		
	var debug_timer = Timer.new()
	debug_timer.one_shot = true
	debug_timer.wait_time = 0.25
	debug_timer.connect("timeout", self, "_after_generation_debug")
	gameScene.add_child(debug_timer)
	debug_timer.start()

func _after_generation_debug():
	
	var player_planet: Entity = null
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.corporation_id == Consts.PLAYER_CORPORATION:
			player_planet = planet
	
	var ship_types = []
	for i in range(50):
		ship_types.append(Enums.ship_types.combat)
	for i in range(0):
		ship_types.append(Enums.ship_types.explorer)
	for i in range(0):
		ship_types.append(Enums.ship_types.miner)
	player_planet.planet_disabled_ships = 3
	
	var i = 0
	for ship_type in ship_types:
		var ship = Instancer.ship(ship_type, null, player_planet)
		ship.corporation_id = i % 2 + 1
		i += 1
		get_node('/root/GameScene').add_child(ship)
	
func add_node_deffered(node: Object):
	gameScene.add_child(node)
	
	load_progress += 1
	GameState.loading_progress = load_progress / total_entities
	
	if load_progress == total_entities:
		emit_signal("objects_loaded")
