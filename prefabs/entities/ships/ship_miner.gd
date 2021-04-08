extends Ship

class_name ShipMiner

var asteroid_rocks: float = 0
var asteroid_rocks_max: int = 64

const ANIMATION_CHARGE_MINER = 'charge_miner'
var mining_power = 8

var get_target_timer: Timer
var miner_ready: bool = false
var miner_timer: Timer
var deliver_timer: Timer


func create():
	ship_type = Enums.ship_types.miner
	hitpoints = Consts.SHIP_HITPOINTS_MINER
	ship_speed = Consts.SHIP_SPEED_MINER
	.create()
	
func _ready():
	add_to_group('Miner')
	
	get_target_timer = Timer.new()
	get_target_timer.wait_time = 0.5
	get_target_timer.connect("timeout", self, "_get_mining_target")
	add_child(get_target_timer)
	
	miner_timer = Timer.new()
	miner_timer.wait_time = 3
	miner_timer.one_shot = true
	miner_timer.connect("timeout", self, "_on_miner_ready")
	add_child(miner_timer)
	
	deliver_timer = Timer.new()
	deliver_timer.wait_time = 3
	deliver_timer.one_shot = true
	deliver_timer.connect("timeout", self, "_do_deliver")
	add_child(deliver_timer)
	
	var animation = Animation.new()
	animation.length = 1.2
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Sprite:scale")
	animation.track_insert_key(track_index, 0.00, Vector2.ONE * 1.0)
	animation.track_insert_key(track_index, 1.00, Vector2.ONE * 1.4)
	animation.track_insert_key(track_index, 1.05, Vector2.ONE * 0.8)
	animation.track_insert_key(track_index, 1.2, Vector2.ONE * 1.0)
	track_index = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track_index, ".")
	animation.track_insert_key(track_index, 1.05, {"method": "_do_mine", "args": []})
	node_animation.add_animation(ANIMATION_CHARGE_MINER, animation)
	
	._ready()

func process(delta: float):
	
	if state == Enums.ship_states.mine and not target:
		state = Enums.ship_states.idle
	if state == Enums.ship_states.mine \
		and (target.is_dead() or target.asteroid_rocks <= 0):
		state = Enums.ship_states.idle
		self.target = null
		
	if state != Enums.ship_states.mine and not get_target_timer.is_stopped():
		get_target_timer.stop()
		
	if state == Enums.ship_states.idle and corporation_id == parent.corporation_id:
		_get_mining_target()
	
	if state == Enums.ship_states.mine and asteroid_rocks >= asteroid_rocks_max:
		state = Enums.ship_states.deliver
		self.target = parent
	
	elif state == Enums.ship_states.deliver:
		
		if deliver_timer.is_stopped():
			var collision
			if node_raycast.is_colliding() and node_raycast.get_collider() == target:
				collision = move_and_collide(Vector2.ZERO, true, true, true)
			
			if collision and collision.collider == self.target:
				look_at(position - target.position)
				deliver_timer.start()
			else:
				move(self.target.position)
	elif state == Enums.ship_states.mine and not target:
		_get_mining_target()
	
	elif state == Enums.ship_states.mine:
		if move(self.target.position):
			rotation_degrees = target.rotation_degrees
			if miner_ready:
				_begin_mine()
			elif miner_timer.is_stopped() and not node_animation.current_animation == ANIMATION_CHARGE_MINER:
				miner_timer.start()
	else:
		.process(delta)
	
func _on_miner_ready():
	miner_ready = true

func _begin_mine():
	miner_ready = false
	if node_animation.current_animation != ANIMATION_CHARGE_MINER:
		node_animation.play(ANIMATION_CHARGE_MINER)
	
func _do_mine():
	var can_mine = min(mining_power, asteroid_rocks_max - asteroid_rocks)
	var mine_amount = min(target.asteroid_rocks, can_mine)
	asteroid_rocks += mine_amount
	target.asteroid_rocks -= mine_amount
	Instancer.asteroid_dust(self, false)
	target.emit_signal("entity_changed")

func _do_deliver():
	self.get_corporation().resources.asteroid_rocks += asteroid_rocks
	asteroid_rocks = 0
	state = Enums.ship_states.idle
	self.target = null
	parent.emit_signal("entity_changed")
	
func _get_mining_target() -> void:
	var target: Asteroid = null
	var target_dist: float = INF
	print(parent.asteroids.size())
	for asteroid in parent.asteroids:
		if asteroid.is_dead():
			continue
			
		var neighbors_target = false
		var dist_asteroid = position.distance_squared_to(asteroid.position)
		
		for ship in parent.ships:
			if ship.ship_type == Enums.ship_types.miner and ship.target == asteroid:
				if dist_asteroid > ship.position.distance_squared_to(asteroid.position):
					neighbors_target = true
					break
		
		if not neighbors_target and dist_asteroid < target_dist:
			target = asteroid
			target_dist = dist_asteroid
	
	if target:
		self.target = target
		state = Enums.ship_states.mine
		get_target_timer.start()

func save():
	var save = .save()
	save["asteroid_rocks"] = asteroid_rocks
	save["asteroid_rocks_max"] = asteroid_rocks_max
	return save
