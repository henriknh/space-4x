extends Ship

class_name ShipMiner

var asteroid_rocks: float = 0
var asteroid_rocks_max: int = 64

const ANIMATION_CHARGE_MINER = 'charge_miner'
var mining_power = 8

var miner_ready: bool = false
var miner_timer: Timer


func create():
	ship_type = Enums.ship_types.miner
	ship_speed = 100
	.create()
	
func _ready():
	add_to_group('Miner')
	
	miner_timer = Timer.new()
	miner_timer.wait_time = 3
	miner_timer.one_shot = true
	miner_timer.connect("timeout", self, "_on_miner_ready")
	add_child(miner_timer)
	
	
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
		
	if state == Enums.ship_states.idle and corporation_id == parent.corporation_id:
		self.target = _get_mining_target()
		if target:
			state = Enums.ship_states.mine
	
	if state == Enums.ship_states.mine and asteroid_rocks >= asteroid_rocks_max:
		state = Enums.ship_states.deliver
		self.target = parent
		
	if state == Enums.ship_states.deliver and target_reached:
		deliver()
		state = Enums.ship_states.idle
	
	elif state == Enums.ship_states.mine and target_reached:
		rotation_degrees = target.rotation_degrees
		if miner_ready:
			_begin_mine()
		elif miner_timer.is_stopped() and not node_animation.current_animation == ANIMATION_CHARGE_MINER:
			miner_timer.start()
		return 
	
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

func deliver():
	self.get_corporation().resources.asteroid_rocks += asteroid_rocks
	asteroid_rocks = 0
	parent.emit_signal("entity_changed")
	
func _get_mining_target() -> Entity:
	for asteroid in parent.asteroids:
		if not asteroid.is_dead() and asteroid.asteroid_rocks > 0:
			return asteroid
	return null

func save():
	var save = .save()
	save["asteroid_rocks"] = asteroid_rocks
	save["asteroid_rocks_max"] = asteroid_rocks_max
	return save
