extends Node

var world_size: int = Enums.world_size.large
var unique_id = 0 setget ,get_unique_id

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
	
	var pending = []
	
	# Calculate planet systems
	get_node('/root/GameScene').add_child(Instancer.galaxy())
	
	yield(GameState, "loading_done")
	
	var player = Corporations.create(Consts.PLAYER_CORPORATION, false)
	var player_planet = get_start_planet()
	player_planet.get_parent().get_parent().corporation_id = player.corporation_id

	GameState.planet_system = player_planet.get_parent().get_parent().get_parent()
	var camera: Spatial = get_node('/root/GameScene/CameraRoot')
	camera.translation = player_planet.get_parent().global_transform.origin

	var computers_min = Consts.COMPUTER_COUNT[world_size].min
	var computers_max = Consts.COMPUTER_COUNT[world_size].max
	for idx in range(Random.randi_range(computers_min, computers_max)):
		var ai_corporation = Corporations.create(Consts.PLAYER_CORPORATION + 1 + idx, true)
		var start_planet = get_start_planet()
		start_planet.get_parent().get_parent().corporation_id = ai_corporation.corporation_id
	
	Nav.create_network()
	
	GameState.emit_signal("game_ready")

func get_start_planet() -> Planet:
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
