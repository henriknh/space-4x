extends ship

class_name ship_miner

var mining_power = 10

var mining_target: entity
var mining_charging: bool = false
var mining_timer: Timer

func create():
	color = Color(1, 0.8, 0.4, 1)
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

func process():
	if ship_target_id == -1 and parent:
		if metal == metal_max:
			if not move(parent.position):
				deliver()
		elif not mining_target or mining_target and mining_target.is_dead():
			_get_next_mining_target()
		elif mining_target:
			if not move(mining_target.position) and not mining_charging:
				charge_mine()
	.process()

func clear():
	mining_target = null
	mining_charging = false
	mining_timer.stop()
	.clear()
	
func charge_mine():
	print('Charging mine')
	mining_charging = true
	mining_timer.start()

func do_mine():
	mining_charging = false
	if mining_target and not mining_target.is_dead() and mining_target.metal > 0:
		var can_mine = min(mining_power, metal_max - metal)
		var mine_amount = min(mining_target.metal, can_mine)
		metal += mine_amount
		mining_target.metal -= mine_amount
		print('Mined: %d' % metal)

func deliver():
	parent.metal += metal
	metal = 0
	
func _get_next_mining_target() -> void:
	var asteroids = []
	for child in parent.children:
		if (child as entity).object_type == Enums.object_types.asteroid:
			asteroids.append(child)
	
	asteroids.sort_custom(self, "sort_asteroids")
	
	var asteroid_idx = WorldGenerator.rng.randi_range(0, min(1, asteroids.size() - 1))
	mining_target = asteroids[asteroid_idx]
	
func sort_asteroids(a: entity, b: entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b
