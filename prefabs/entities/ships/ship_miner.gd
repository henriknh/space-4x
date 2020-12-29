extends ship

class_name ship_miner

var mining_power = 200

var mining_target: entity
var mining_charging: bool = false
var mining_timer: Timer

func create():
	color = Color(1, 0.8, 0.4, 1)
	ship_type = Enums.ship_types.miner
	ship_speed_max = 1000
	metal_max = 500
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
	else:
		.process()

func charge_mine():
	print('Charging mine')
	mining_charging = true
	mining_timer.start()

func do_mine():
	mining_charging = false
	if mining_target.metal > 0:
		var can_mine = min(mining_power, metal_max - metal)
		var mine_amount = min(mining_target.metal, can_mine)
		metal += mine_amount
		mining_target.metal -= mine_amount
		print('Mined: %d' % metal)

func deliver():
	parent.metal += metal
	metal = 0

func _get_next_mining_target() -> void:
	var asteroids = (parent as planet).get_asteroids()
	var closest: entity = null
	var closest_dist = INF
	print("asteroids for planet: %d" % asteroids.size())
	for asteroid in asteroids:
		var _dist = self.position.distance_squared_to(asteroid.position)
		if _dist < closest_dist and not asteroid.is_dead():
			closest = asteroid
			closest_dist = _dist
	mining_target = closest
