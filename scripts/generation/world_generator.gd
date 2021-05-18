extends Node

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
			
		planet_system.planet_sites = []
		for site in planet_system.sites.values():
			
			var shuffled_tiles = site.tiles.duplicate()
			shuffled_tiles.shuffle()
			
			var planet_site = Instancer.planet_site(site)
			
			for tile in planet_system.tiles:
				planet_site.add_child(tile)
			
			var planet_tile = calculate_planet_tile(shuffled_tiles)
			var planet: Planet = Instancer.planet(planet_tile)
			planet_site.planet = planet
			planet_tile.add_child(planet)
			
			planet_system.planet_sites.append(planet_site)
			planet_system.add_child(planet_site)
			
		galaxy.add_child(planet_system)
	
	var player = Corporations.create(Consts.PLAYER_CORPORATION, false)
	var player_planet = get_start_planet()
	player_planet.corporation_id = player.corporation_id
	player_planet.emit_signal("entity_changed")

	var computers_min = Consts.COMPUTER_COUNT[world_size].min
	var computers_max = Consts.COMPUTER_COUNT[world_size].max
	for idx in range(Random.randi_range(computers_min, computers_max)):
		var ai_corporation = Corporations.create(Consts.PLAYER_CORPORATION + 1 + idx, true)
		var start_planet = get_start_planet()
		start_planet.corporation_id = ai_corporation.corporation_id
		start_planet.emit_signal("entity_changed")
	
	Nav.create_network()
	
	emit_signal("objects_loaded")
	GameState.set_planet_system(galaxy.planet_systems[0])
	
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	var ship_types = []
	for i in range(1):
		ship_types.append(Enums.ship_types.combat)
	for i in range(0):
		ship_types.append(Enums.ship_types.explorer)
	for i in range(0):
		ship_types.append(Enums.ship_types.miner)
#	player_planet.planet_disabled_ships = 3

	var i = 0
	for ship_type in ship_types:
		var planet = get_tree().get_nodes_in_group('Planet')[i]
		planet = player_planet
		var planet_tile = planet.get_parent()
		var tile = planet_tile.neighbors[Random.randi() % planet_tile.neighbors.size()]
		var ship = Instancer.ship(ship_type, planet, tile)
		i += 1
		gameScene.add_child(ship)
	
func add_node_deffered(parent: Node, node: Object):
	parent.add_child(node)
	
	load_progress += 1
	GameState.loading_progress = load_progress / total_entities
	
	if load_progress == total_entities:
		emit_signal("objects_loaded")

func get_start_planet() -> Entity:
	var possible_planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.corporation_id == 0:
			possible_planets.append(planet)
	
	return possible_planets[Random.randi() % possible_planets.size()]

func calculate_planet_tile(shuffled_tiles: Array) -> Tile:
	var planet_tile: Tile
	var largest_neighbor_count = -1
	
	for _tile in shuffled_tiles:
		var neighbors_in_site = 0
		var ns = []
		for neighbor in _tile.neighbors:
			if neighbor in shuffled_tiles:
				neighbors_in_site += 1
				ns.append(neighbor)
		
		if neighbors_in_site > largest_neighbor_count:
			planet_tile = _tile
			largest_neighbor_count = neighbors_in_site
	
	return planet_tile
