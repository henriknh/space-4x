extends Node

var _world_size: int = 1
var _seed: int = 0
var _unique_id = 0

var load_progress: float = 0
var total_entities: float  = 0

onready var rng: RandomNumberGenerator = null

func _ready():
	rng = RandomNumberGenerator.new()
	rng.set_seed(_seed)

func set_world_size(world_size: int) -> void:
	_world_size = world_size

func get_world_size() -> int:
	return _world_size

func set_seed(seed_value: int) -> void:
	_seed = seed_value
	rng = RandomNumberGenerator.new()
	rng.set_seed(_seed)
	
func get_new_id() -> int:
	_unique_id += 1
	return _unique_id

func generate_world():
	print('Generate world with seed: %d' % rng.get_seed())
	GameState.loading_progress = 0
	
	# Calculate planet systems
	GameState.loading_label = 'Generate planet systems'
	var galaxies_min = Consts.galaxy_size[_world_size].min
	var galaxies_max = Consts.galaxy_size[_world_size].max
	var planet_systems = []
	for planet_system_idx in range(WorldGenerator.rng.randi_range(galaxies_min, galaxies_max)):
		planet_systems.append({
			'idx': planet_system_idx,
			'voronoi': null,
			'planets': [],
			'objects': []
		})
	print('Planet systems: %d' % planet_systems.size())
	
	# Calculate planets
	GameState.loading_label = 'Generate planets'
	for planet_system in planet_systems:
		var orbits_min = Consts.planet_system_orbits[WorldGenerator.get_world_size()].min
		var orbits_max = Consts.planet_system_orbits[WorldGenerator.get_world_size()].max
		var total_orbits = int(WorldGenerator.rng.randi_range(orbits_min, orbits_max))
		
		var orbit_diff = (Consts.planet_system_radius / total_orbits) * 0.2
		var quadrants = {
			0: 0,
			1: 0,
			2: 0,
			3: 0
		}
		
		for orbit in range(total_orbits):
			pass
			var smallest_quadrant = _get_least_dense_quadrant(quadrants)
			var angle = WorldGenerator.rng.randf() * PI / 2 + smallest_quadrant * PI / 2
			var orbit_distance = Consts.planet_system_base_distance_to_sun + (Consts.planet_system_radius / total_orbits) * (orbit + 1) + WorldGenerator.rng.randi_range(-orbit_diff, orbit_diff)
		
			var position = Vector2(orbit_distance * sin(angle), orbit_distance * cos(angle))
			
			planet_system.planets.append({
				'position': position,
				'orbit': orbit
			})
	
	# Calculate sites layout
	GameState.loading_label = 'Generate planet system layouts'
	for planet_system in planet_systems:
		planet_system.voronoi = Voronoi.voronoi_registry.register_voronoi(planet_system.idx, planet_system.planets)
	
	GameState.loading_label = 'Generate objects'
	for planet_system in planet_systems:
		pass
		var asteroids_min = Consts.asteroids_per_planet_system[WorldGenerator.get_world_size()].min
		var asteroids_max = Consts.asteroids_per_planet_system[WorldGenerator.get_world_size()].max
		var total_asteroids = WorldGenerator.rng.randi_range(asteroids_min, asteroids_max)
		
		for asteroid in range(total_asteroids):
			planet_system.objects.append({
				'object_type': Enums.object_types.asteroid
			})

	
	load_progress = 0
	total_entities = 0
	for planet_system in planet_systems:
		total_entities += 1
		total_entities += planet_system.planets.size()
		total_entities += planet_system.objects.size()
	print('Total entities to load: %d' % total_entities)
	
	var gameScene = get_node('/root/GameScene')
	
	
			
	# Instance planet systems
	GameState.loading_label = 'Instanciate planet systems'
	for planet_system in planet_systems:
		gameScene.add_child(Instancer.planet_system(planet_system.idx))
		_entity_loaded()
		
	# Instance planets
	GameState.loading_label = 'Instanciate planets'
	for planet_system in planet_systems:
		
		for planet in planet_system.planets:
			var planet_type = _calc_planet_type(planet.orbit, planet_system.planets.size())
			var convex_hull = planet_system.voronoi.site_registry.get_convex_hull_of_node(planet)
			gameScene.add_child(Instancer.planet(planet_type, planet.position, convex_hull, planet_system.idx))
			_entity_loaded()
	
	
	# Instance objects
	GameState.loading_label = 'Instanciate objects'
	for planet_system in planet_systems:
		for object in planet_system.objects:
			gameScene.add_child(Instancer.object(object.object_type, planet_system.idx))
			_entity_loaded()
			
	GameState.loading_label = 'Finishing up'
	
	for player in Enums.player_colors.keys():
		if player < 0:
			continue
		
		var is_human_player = player == 0
		var start_planet = _get_start_planet(is_human_player)
		start_planet.faction = player
		_set_start_resouces(start_planet)
		
		if is_human_player:
			var camera = get_node('/root/GameScene/Camera') as Camera2D
			camera.target_position = start_planet.position
			camera.position = start_planet.position
	
	GameState.set_planet_system(0)
	


func _entity_loaded():
	load_progress += 1
	GameState.loading_progress = load_progress / total_entities

func _get_start_planet(is_human: bool) -> Entity:
	var possible_planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if (is_human and planet.planet_system == 0 or not is_human) and planet.faction == -1:
			possible_planets.append(planet)
	
	return possible_planets[WorldGenerator.rng.randi() % possible_planets.size()]

func _set_start_resouces(planet: Entity):
	planet.metal = 1000
	planet.power = 1000
	planet.food = 1000
	planet.water = 1000
	
func _calc_planet_type(orbit: int, total_orbits: int) -> int:
	var r = WorldGenerator.rng.randf()
	var odds_sum = 0

	if float(orbit) / total_orbits < 0.25:
		if r < 0.8:
			return Enums.planet_types.lava
		else:
			return Enums.planet_types.iron
	elif float(orbit) / total_orbits < 0.5:
		if r < 0.2:
			return Enums.planet_types.lava
		elif r < 0.8:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.earth

	elif float(orbit) / total_orbits < 0.75:
		if r < 0.4:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.earth

	else:
		if r < 0.4:
			return Enums.planet_types.iron
		else:
			return Enums.planet_types.ice


	return -1

func _get_least_dense_quadrant(quadrants: Dictionary) -> int:
	var smallest_quadrant = 0
	var smallest_value = quadrants[smallest_quadrant]

	if quadrants[1] < smallest_value:
		smallest_quadrant = 1
		smallest_value = quadrants[smallest_quadrant]
	if quadrants[2] < smallest_value:
		smallest_quadrant = 2
		smallest_value = quadrants[smallest_quadrant]
	if quadrants[3] < smallest_value:
		smallest_quadrant = 3
		smallest_value = quadrants[smallest_quadrant]

	quadrants[smallest_quadrant] = quadrants[smallest_quadrant] + 1

	return smallest_quadrant
