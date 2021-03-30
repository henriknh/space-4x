extends Ship

class_name ShipCombat

var prefab_laser = preload('res://prefabs/entities/ships/effects/laser.tscn')

var weapon_damage: int = 10
var weapon_ready: bool = true

var weapon_timer: Timer
var target_timer: Timer

func create():
	ship_type = Enums.ship_types.combat
	ship_speed_max = 200
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
	
	.ready()

func process(delta: float):
	var has_enemies = _has_enemies_in_site()
	
	if state != Enums.ship_states.combat and has_enemies:
		state = Enums.ship_states.combat
		target = _get_closest_enemy()
		
	elif state == Enums.ship_states.combat and not has_enemies:
		state = Enums.ship_states.idle
	
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
	
	var laser = prefab_laser.instance()
	get_node('/root/GameScene').add_child(laser)
	var color = Enums.ship_colors[ship_type] if faction == 0 else Enums.player_colors[faction]
	laser.emit(position, node_raycast.get_collision_point(), color)
	
func _weapon_ready():
	target = _get_closest_enemy()
	weapon_ready = true
	
func _is_parent_enemy() -> bool:
	return parent.faction >= 0 and parent.faction != faction
	
func _has_enemies_in_site() -> bool:
	
	var has_enemies = false
	for child in parent.children:
		if child.ship_type >= 0 and child.faction != faction:
			has_enemies = true
			break
	
	has_enemies = has_enemies or _is_parent_enemy()
	
	if has_enemies and target_timer.is_stopped():
		target_timer.start()
	else:
		target_timer.stop()
	return has_enemies
	
func _get_closest_enemy() -> Entity:
	var enemies = []
	for child in parent.children:
		if child.is_dead():
			continue
		if child.ship_type >= 0 and child.faction != faction:
			enemies.append(child)
	
	enemies.sort_custom(self, "sort_combat_type")
	enemies.sort_custom(self, "sort_distance")
	
	if _is_parent_enemy():
		enemies.append(parent)
	
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

func _update_target():
	if _has_enemies_in_site():
		state = Enums.ship_states.combat
		target = _get_closest_enemy()
	else:
		state = Enums.ship_states.idle
