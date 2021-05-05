extends Node

const GenUtils = preload('res://scripts/generation/utils.gd')

var world_size: int = Enums.world_size.large
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
	print("Generate world:")
	print("seed: %d" % Random.get_seed())
	print("size: %d" % world_size)
	GameState.loading_progress = 0
	
	gameScene = get_node('/root/GameScene')
	
	load_progress = 0
	total_entities = 0
	
	# Calculate planet systems
	GameState.loading_label = 'Loading...'
	
	var galaxy: Galaxy = Instancer.galaxy()
	gameScene.add_child(galaxy)
	
	for planet_system in galaxy.planet_systems:
		galaxy.add_child(planet_system)
		
		for tile in planet_system.tiles:
			planet_system.add_child(tile)
		
		for site_tiles in planet_system.sites.values():
			var tile = site_tiles[Random.randi() % site_tiles.size()]
			var planet: Planet = Instancer.planet(tile)
			planet_system.add_child(planet)
			
	Nav.create_network()
	
	emit_signal("objects_loaded")
	
#	for node_array in nodes.values():
#		total_entities += node_array.size()
#		print(total_entities)
#
#	for key in nodes.keys():
#		for node in nodes[key]:
#			call_deferred("add_node_deffered", key, node)
			
	GameState.set_planet_system(galaxy.planet_systems[0])
	
#	var all_planets = get_tree().get_nodes_in_group('Planet')
	var player = Corporations.create(Consts.PLAYER_CORPORATION)
#	var player_planet = GenUtils.get_start_planet(all_planets, true)
#	player_planet.corporation_id = player.corporation_id
#
#	var camera = get_node('/root/GameScene/Camera') as Camera2D
#	camera.position = player_planet.position
#
	var computers_min = Consts.COMPUTER_COUNT[world_size].min
	var computers_max = Consts.COMPUTER_COUNT[world_size].max
	for idx in range(Random.randi_range(computers_min, computers_max)):
		var ai_corporation = Corporations.create(Consts.PLAYER_CORPORATION + 1 + idx)
#		var start_planet = GenUtils.get_start_planet(all_planets, ai_corporation.corporation_id == (Consts.PLAYER_CORPORATION + 1))
#		start_planet.corporation_id = ai_corporation.corporation_id
#
#
#
#
#
#
#
#	var ship_types = []
#	for i in range(50):
#		ship_types.append(Enums.ship_types.combat)
#	for i in range(0):
#		ship_types.append(Enums.ship_types.explorer)
#	for i in range(0):
#		ship_types.append(Enums.ship_types.miner)
#	player_planet.planet_disabled_ships = 3
#
#	var i = 0
#	for ship_type in ship_types:
#		var ship = Instancer.ship(ship_type, null, player_planet)
#		ship.corporation_id = i % 2 + 1
#		i += 1
#		get_node('/root/GameScene').add_child(ship)
	
func add_node_deffered(parent: Node, node: Object):
	parent.add_child(node)
	
	load_progress += 1
	GameState.loading_progress = load_progress / total_entities
	
	if load_progress == total_entities:
		emit_signal("objects_loaded")
