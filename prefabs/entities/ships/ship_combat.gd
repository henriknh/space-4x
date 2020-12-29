extends ship

class_name ship_combat

enum STATES {
	idle,
	moving,
	combat
}

var target_enemy: entity

var patrolling_position: Vector2 = Vector2.INF

func create():
	color = Color(1, 0, 0.4, 1)
	ship_type = Enums.ship_types.combat
	ship_speed_max = 2000
	power_max = 20
	.create()

func ready():
	add_to_group('Combat')
	.ready()

func process():
	if parent and _has_enemies_in_site():
		if not target_enemy:
			print('get enemy')
			target_enemy = _get_closest_enemy()
		else:
			move(target_enemy.position, false)
			print('Pursue enemy')
	elif ship_target_id == -1 and parent:
		
		if patrolling_position == Vector2.INF:
			_get_next_patrolling_position()
		else:
			if not move(patrolling_position, false):
				patrolling_position = Vector2.INF
	else:
		.process()

func clear():
	patrolling_position = Vector2.INF
	.clear()

func _has_enemies_in_site() -> bool:
	for child in parent.children:
		if child.ship_type >= 0 and child.faction != faction:
			return true
	return false

func _get_closest_enemy() -> entity:
	var enemies = []
	for child in parent.children:
		if child.ship_type >= 0 and child.faction != faction:
			enemies.append(child)
			
	enemies.sort_custom(Utils, "sort_entities")
	
	return enemies[0]

func _get_next_patrolling_position():
	var bound_left = INF
	var bound_right = -INF
	var bound_top = INF
	var bound_bottom = -INF
	
	for point in parent.planet_convex_hull:
		if point.x < bound_left:
			bound_left = point.x
		if point.x > bound_left:
			bound_right = point.x
		if point.y < bound_left:
			bound_top = point.y
		if point.y > bound_left:
			bound_bottom = point.y
	
	while patrolling_position == Vector2.INF:
		var x = WorldGenerator.rng.randf_range(bound_left, bound_right)
		var y = WorldGenerator.rng.randf_range(bound_top, bound_bottom)
		var point = Vector2(x, y)
		if Geometry.is_point_in_polygon(point, parent.planet_convex_hull):
			patrolling_position = point + parent.position
