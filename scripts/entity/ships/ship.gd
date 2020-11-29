extends entity

class_name ship

onready var trail = $Trail as Line2D
var _delta = 0
const ACTIVE_TIME_PERIOD = 0.033
const INACTIVE_TIME_PERIOD = 0.2

export(int) var max_speed = 500
export(int) var min_speed = 10
export(int) var acceleration = 50
export(int) var turn_speed = 4

func create():
	set_name(NameGenerator.get_name_ship())

func _process(delta):
	
	_delta += delta
	
	if visible and _delta < ACTIVE_TIME_PERIOD:
		return
	if not visible and _delta < INACTIVE_TIME_PERIOD:
		return
	else:
		if _ship_target:
			rotation += get_angle_to(_ship_target) * turn_speed * _delta
			
			_ship_forward_dir = Vector2(cos(rotation), sin(rotation)).normalized()
		
			position += _ship_forward_dir * _ship_speed * _delta
			
			call_deferred("_calc_speed", _delta)
		else:
			get_new_target()
			
		_delta = 0

func _calc_speed(delta):
	var distance_to_target = global_transform.origin.distance_squared_to(_ship_target)
	if distance_to_target < pow(16, 2):
		if _ship_speed > 0:
			_ship_speed -= acceleration * delta * 10
		_ship_target = null
		trail.set_emitting(false)
		
	elif _ship_speed < min_speed:
		_ship_speed = min_speed
	elif _ship_speed > max_speed:
		_ship_speed = max_speed
	elif distance_to_target < pow(_ship_speed, 2):
		_ship_speed -= acceleration * delta * 10
	elif _ship_speed < max_speed:
		_ship_speed += acceleration * delta
	else:
		_ship_speed -= acceleration * delta * 10

func get_new_target():
	var planets = get_tree().get_nodes_in_group("Planet")
	var planets_in_star_system = []
	for planet in planets:
		if planet.get_star_system() == State.get_star_system():
			planets_in_star_system.push_back(planet)
	
	if planets_in_star_system.size() > 0:
		var target_planet = planets_in_star_system[randi() % planets_in_star_system.size()]
		_ship_target = target_planet.get_target_point()
		if visible:
			trail.set_emitting(true)
	
func set_visible(in_data) -> void:
	if typeof(in_data) == TYPE_BOOL:
		visible = in_data
	else:
		visible = _star_system == in_data
	trail.set_emitting(visible)
