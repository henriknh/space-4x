extends Ship

class_name ShipMiner

var mining_power = 10

var mining_target: Entity = null
var mining_charging: bool = false
var mining_timer: Timer

func create():
	ship_type = Enums.ship_types.miner
	ship_speed_max = 1000
	metal_max = 100
	.create()
	
func ready():
	add_to_group('Miner')
	mining_timer = Timer.new()
	mining_timer.wait_time = 1
	mining_timer.one_shot = true
	mining_timer.connect("timeout", self, "do_mine")
	add_child(mining_timer)
	
	.ready()

func process(delta: float):
	
	if state == Enums.ship_states.mine and not mining_target:
		state = Enums.ship_states.idle
	if state == Enums.ship_states.mine and mining_target.is_dead():
		state = Enums.ship_states.idle
		
	if state == Enums.ship_states.idle and faction == parent.faction:
		_get_next_mining_target()
		if mining_target:
			state = Enums.ship_states.mine
	
	if state == Enums.ship_states.mine and metal == metal_max:
		state = Enums.ship_states.deliver
		
	if state == Enums.ship_states.deliver:
		if not move(parent.position):
			deliver()
			state = Enums.ship_states.idle
	elif state == Enums.ship_states.mine:
		if not move(mining_target.position) and not mining_charging:
			charge_mine()
	else:
		.process(delta)

func clear():
	mining_target = null
	mining_charging = false
	mining_timer.stop()
	.clear()
	
func charge_mine():
	mining_charging = true
	mining_timer.start()

func do_mine():
	mining_charging = false
	if mining_target and not mining_target.is_dead() and mining_target.metal > 0:
		var can_mine = min(mining_power, metal_max - metal)
		var mine_amount = min(mining_target.metal, can_mine)
		metal += mine_amount
		mining_target.metal -= mine_amount

func deliver():
	parent.metal += metal
	parent.emit_signal("entity_changed")
	metal = 0
	
func _get_next_mining_target() -> void:
	
	#asteroids.sort_custom(self, "sort_asteroids")
	
	if parent.asteroids.size() > 0:
		var asteroid_idx = WorldGenerator.rng.randi() % parent.asteroids.size()
		mining_target = parent.asteroids[asteroid_idx]
	else:
		mining_target = null
	
func sort_asteroids(a: Entity, b: Entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b
