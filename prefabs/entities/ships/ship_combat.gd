extends Ship

class_name ShipCombat

var target_enemy: Entity
var weapon_damage: int = 10
var weapon_ready: bool = true
var weapon_timer: Timer
var weapon_retreat_direction = Vector2.INF

var patrolling_position: Vector2 = Vector2.INF

func create():
	ship_type = Enums.ship_types.combat
	ship_speed_max = 2000
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
	if state == Enums.ship_states.combat:
		if not target_enemy and _has_enemies_in_site():
			target_enemy = _get_closest_enemy()
			
		if not target_enemy:
			state = Enums.ship_states.idle
		else:
			if not weapon_ready:
				_wait_for_weapon()
			else:
				move(target_enemy.position, false, -1)
		
	.process(delta)

func clear():
	patrolling_position = Vector2.INF
	.clear()

func _on_entity_in_range(entity: Entity):
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
	
func _get_closest_enemy() -> Entity:
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

func sort_combat_type(a: Entity, b: Entity) -> bool:
	return b.ship_type != Enums.ship_types.combat
	
func sort_distance(a: Entity, b: Entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b
