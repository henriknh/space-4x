extends entity

class_name ship

var nav_route = []
var ship_target_obj = null
var model: Sprite = null
var trail: Node2D = null
var delta: float = 0
const ACTIVE_TIME_PERIOD: float = 0.0166
const INACTIVE_TIME_PERIOD: float = 0.5

export(int) var min_speed: int = 10
export(int) var acceleration: int = 50
export(int) var turn_speed: int = 4

func create():
	entity_type = Enums.entity_types.ship
	label = NameGenerator.get_name_ship()
	if metal_max < 0:
		metal_max = 0
	if power_max < 0:
		power_max = 10
	if food_max < 0:
		food_max = 5
	if water_max < 0:
		water_max = 5
	if ship_cargo_size < 0:
		ship_cargo_size = metal_max + power_max + food_max + water_max
	.create()
	
func ready():
	model = get_node("Sprite") as Sprite
	trail = get_node("Trail") as Node2D
	
	model.self_modulate = color
	trail.set_color(color)
	.ready()
	
func _physics_process(_delta):

	delta += _delta

	if visible and _delta < ACTIVE_TIME_PERIOD:
		return
	if not visible and _delta < INACTIVE_TIME_PERIOD:
		return
	else:
		process()

		delta = 0
func process():
	if ship_target_id and nav_route.size() == 0:
		nav_route = Nav.get_route(self, ship_target_id)
	elif ship_target_id and nav_route.size() > 0:
		var target_position: Vector2 = nav_route[0].position
		move(target_position)
		_calc_speed(target_position)
		_update_route()
	else:
		stop()

func set_target_id(id: int):
	self.ship_target_id = id
	self.nav_route = Nav.get_route(self, ship_target_id)
	if visible:
		trail.set_emitting(true)

func move(target_position: Vector2) -> void:
	rotation += get_angle_to(target_position) * turn_speed * delta

	var ship_forward_dir = Vector2(cos(rotation), sin(rotation)).normalized()

	position += ship_forward_dir * ship_speed * delta
	
	_calc_speed(target_position)

func _calc_speed(target_position: Vector2):
	var distance_to_target = global_transform.origin.distance_squared_to(target_position)
	if distance_to_target < pow(160, 2):
		if nav_route.size() == 1 and ship_speed > 0:
			ship_speed -= ship_speed_max / 10 * delta * 10
		if ship_speed == 0:
			trail.set_emitting(false)
	elif ship_speed < min_speed:
		ship_speed = min_speed
	elif ship_speed > ship_speed_max:
		ship_speed = ship_speed_max
	elif distance_to_target < pow(ship_speed, 2):
		ship_speed -= ship_speed_max / 10 * delta * 10
	elif ship_speed < ship_speed_max:
		ship_speed += ship_speed_max / 10 * delta
	else:
		ship_speed -= ship_speed_max / 10 * delta * 10

func stop():
	if ship_speed > 0:
		ship_speed -= ship_speed_max / 10 * delta * 10

func _update_route():
	var distance_to_target = global_transform.origin.distance_squared_to(nav_route[0].position)
	if distance_to_target < pow(160, 2):
		if nav_route.size() > 1:
			nav_route.pop_front()
		else:
			nav_route = []
			ship_target_id = -1
			trail.set_emitting(false)

func get_new_target():
	var planets = get_tree().get_nodes_in_group("Planet")
	var planets_in_planet_system = []
	for planet in planets:
		if planet.planet_system == GameState.get_planet_system():
			planets_in_planet_system.append(planet)

	if planets_in_planet_system.size() > 0:
		var target_planet = planets_in_planet_system[randi() % planets_in_planet_system.size()]
		ship_target_id = target_planet.id
		if visible:
			trail.set_emitting(true)

func set_visible(in_data) -> void:
	if typeof(in_data) == TYPE_BOOL:
		visible = in_data
	else:
		visible = planet_system == in_data
	trail.set_emitting(visible)
