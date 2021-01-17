extends ship

class_name ship_combat

var target_enemy: entity
var weapon_damage: int = 10
var weapon_ready: bool = true
var weapon_timer: Timer
var weapon_retreat_direction = Vector2.INF

var patrolling_position: Vector2 = Vector2.INF

func create():
	color = Color(1, 0, 0.4, 1)
	ship_type = Enums.ship_types.combat
	ship_speed_max = 2000
	turn_speed = 8
	power_max = 20
	.create()

func ready():
	add_to_group('Combat')
	
	weapon_timer = Timer.new()
	weapon_timer.connect("timeout", self, "_weapon_ready")
	weapon_timer.wait_time = 1
	weapon_timer.one_shot = true
	add_child(weapon_timer)
	
	var area = Area2D.new()
	var weapon_range = CollisionPolygon2D.new()
	weapon_range.polygon = [
		Vector2(0,0),
		Vector2(400,-300),
		Vector2(600,0),
		Vector2(400,300)
	]
	area.add_child(weapon_range)
	area.connect("body_entered", self, "_on_entity_in_range")
	add_child(area)
	
	.ready()

func process(delta: float):
	if ship_target_id == -1 and parent:
		if not target_enemy and _has_enemies_in_site():
			target_enemy = _get_closest_enemy()
		
		if patrolling_position.distance_squared_to(position) < pow(ship_speed, 2):
			patrolling_position = Vector2.INF
			
		if patrolling_position == Vector2.INF:
			ship_speed_max = 500
			patrolling_position = get_random_point_in_site()
		else:
			ship_speed_max = 2000
			
		if target_enemy:
			if not weapon_ready:
				_wait_for_weapon()
			else:
				move(target_enemy.position, false, -1)
		elif ship_target_id == -1 and patrolling_position != Vector2.INF:
			ship_speed_max = 500
			move(patrolling_position, false)
			
	.process(delta)

func clear():
	patrolling_position = Vector2.INF
	.clear()

func _on_entity_in_range(entity: entity):
	if not target_enemy:
		return
	if weapon_ready and entity == target_enemy:
		_shot()
	
func _shot():
	target_enemy.hitpoints -= weapon_damage
	weapon_ready = false
	weapon_timer.start()
	
	if not target_enemy.get("target_enemy") == null and target_enemy.target_enemy == self:
		weapon_retreat_direction = target_enemy.position + (target_enemy.position - position) * 20000
	else:
		weapon_retreat_direction = Vector2.INF
		
func _weapon_ready():
	weapon_ready = true

func _wait_for_weapon():
	if weapon_retreat_direction != Vector2.INF:
		move(weapon_retreat_direction, false)
	else:
		move(target_enemy.position, false)

func _has_enemies_in_site() -> bool:
	for child in parent.children:
		if child.ship_type >= 0 and child.faction != faction:
			return true
	return parent.faction != faction
	
func _get_closest_enemy() -> entity:
	var enemies = []
	for child in parent.children:
		if child.ship_type >= 0 and child.faction != faction:
			enemies.append(child)
	
	enemies.sort_custom(self, "sort_combat_type")
	enemies.sort_custom(self, "sort_distance")
	
	if parent.faction != faction:
		enemies.append(parent)
	
	for enemy in enemies:
		if enemy.is_dead():
			enemies.erase(enemy)
	
	if enemies.size() > 0:
		return enemies[0]
	else:
		return null

func sort_combat_type(a: entity, b: entity) -> bool:
	return b.ship_type != Enums.ship_types.combat
	
func sort_distance(a: entity, b: entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b
