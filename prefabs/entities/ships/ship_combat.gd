extends Ship

class_name ShipCombat

var weapon_damage: int = 10
var weapon_ready: bool = true

var weapon_timer: Timer
var target_timer: Timer

func create():
	ship_type = Enums.ship_types.combat
	hitpoints = Consts.SHIP_HITPOINTS_COMBAT
	ship_speed = Consts.SHIP_SPEED_COMBAT
	.create()

func _ready():
	add_to_group('Combat')
	
	weapon_timer = Timer.new()
	weapon_timer.connect("timeout", self, "_weapon_ready")
	weapon_timer.wait_time = 1.2
	weapon_timer.one_shot = true
	add_child(weapon_timer)
	
	target_timer = Timer.new()
	target_timer.connect("timeout", self, "_update_target")
	target_timer.wait_time = 0.5
	add_child(target_timer)
	
	._ready()

func process(delta: float):
	var has_enemies = _has_enemies_in_site()
	
	if state == Enums.ship_states.combat and not target:
		state = Enums.ship_states.idle
		
	if state == Enums.ship_states.combat and target.corporation_id == 0:
		state = Enums.ship_states.idle
		target = null
		
	if state == Enums.ship_states.combat and not has_enemies:
		state = Enums.ship_states.idle
		target = null
	
	if state != Enums.ship_states.combat and has_enemies:
		state = Enums.ship_states.combat
		target = _get_closest_enemy()
		
	elif state == Enums.ship_states.combat and not weapon_ready:
		var retreat = position - (target.position - position)
		return move(retreat)
	
	elif state == Enums.ship_states.combat \
		and node_raycast.is_colliding() \
		and node_raycast.get_collider() == target:
			_shot()

	.process(delta)
	
func _shot():
	target.hitpoints -= weapon_damage
	weapon_ready = false
	weapon_timer.start()
	
	var color = Enums.ship_colors[ship_type] if corporation_id == Consts.PLAYER_CORPORATION else Enums.corporation_colors[corporation_id]
	Instancer.laser(position, node_raycast.get_collision_point(), color)
	
func _weapon_ready():
	target = _get_closest_enemy()
	weapon_ready = true
	
func _is_parent_enemy() -> bool:
	return parent.corporation_id != 0 and abs(int(ceil(parent.corporation_id))) != corporation_id
	
func _has_enemies_in_site() -> bool:
	if not parent:
		return false
	
	var has_enemies = false
	for child in parent.children:
		if child.entity_type != Enums.entity_types.ship or child.is_dead():
			continue
		if child.ship_type != 0 and abs(int(ceil(child.corporation_id))) != corporation_id:
			has_enemies = true
			break
	
	has_enemies = has_enemies or _is_parent_enemy()
	
	if has_enemies and target_timer.is_stopped():
		target_timer.start()
	else:
		target_timer.stop()
	return has_enemies
	
func _get_closest_enemy() -> Entity:
	
	var enemy: Entity = null
	var dist_enemy: float = INF
	
	var enemies = []
	for child in parent.children:
		if child.entity_type == Enums.entity_types.ship and not child.is_dead() and child != self:
			var _dist_enemy: float = position.distance_squared_to(child.position)
			if _dist_enemy < dist_enemy:
				if _dist_enemy / dist_enemy < 0.8:
					enemy = child
					dist_enemy = _dist_enemy
	
	if not enemy and _is_parent_enemy():
		enemy = parent
	
	return enemy

func sort_combat_type(a: Entity, b: Entity) -> bool:
	return b.ship_type != Enums.ship_types.combat
	
func sort_distance(a: Entity, b: Entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b

func _update_target():
	if _has_enemies_in_site():
		state = Enums.ship_states.combat
		target = _get_closest_enemy()
	else:
		state = Enums.ship_states.idle
