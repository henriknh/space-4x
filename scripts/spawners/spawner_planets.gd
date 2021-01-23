extends Node2D

var prefab_planet = preload('res://prefabs/entities/planets/planet.tscn')

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

func create(gameScene: Node, planet_system_idx: int) -> void:
	
	var quadrants = {
		0: 0,
		1: 0,
		2: 0,
		3: 0
	}
	var orbits_min = Consts.planet_system_orbits[WorldGenerator.get_world_size()].min
	var orbits_max = Consts.planet_system_orbits[WorldGenerator.get_world_size()].max
	var total_orbits = int(WorldGenerator.rng.randi_range(orbits_min, orbits_max))
	var orbit_diff = (Consts.planet_system_radius / total_orbits) * 0.2

	for orbit in range(total_orbits):

		var smallest_quadrant = _get_least_dense_quadrant(quadrants)
		var angle = WorldGenerator.rng.randf() * PI / 2 + smallest_quadrant * PI / 2
		var orbit_distance = Consts.planet_system_base_distance_to_sun + (Consts.planet_system_radius / total_orbits) * (orbit + 1) + WorldGenerator.rng.randi_range(-orbit_diff, orbit_diff)
		
		var position = Vector2(orbit_distance * sin(angle), orbit_distance * cos(angle))
		var planet_type = _calc_planet_type(orbit, total_orbits)
		var instance: KinematicBody2D = prefab_planet.instance()

		match planet_type:
			Enums.planet_types.earth:
				instance.set_script(load(Enums.planet_scripts.earth))
			Enums.planet_types.ice:
				instance.set_script(load(Enums.planet_scripts.ice))
			Enums.planet_types.iron:
				instance.set_script(load(Enums.planet_scripts.iron))
			Enums.planet_types.lava:
				instance.set_script(load(Enums.planet_scripts.lava))

		instance.position = position
		instance.planet_system = planet_system_idx
		instance.planet_orbit_distance = orbit_distance
		instance.visible = false
		instance.create()
		gameScene.add_child(instance)

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
