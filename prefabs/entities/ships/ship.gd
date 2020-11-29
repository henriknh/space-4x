extends entity

class_name ship

onready var trail = .get_node("Trail") as Node2D
var _delta = 0
const ACTIVE_TIME_PERIOD = 0.0166
const INACTIVE_TIME_PERIOD = 0.5

export(int) var max_speed = 500
export(int) var min_speed = 10
export(int) var acceleration = 50
export(int) var turn_speed = 4

func create():
	.set_type(Enums.entity_types.ship)
	.set_name(NameGenerator.get_name_ship())

func _process(delta):
	
	_delta += delta
	
	if self.visible and _delta < ACTIVE_TIME_PERIOD:
		return
	if not self.visible and _delta < INACTIVE_TIME_PERIOD:
		return
	else:
		if self._ship_target:
			self.rotation += .get_angle_to(self._ship_target) * turn_speed * _delta
			
			self._ship_forward_dir = Vector2(cos(self.rotation), sin(self.rotation)).normalized()
		
			self.position += self._ship_forward_dir * self._ship_speed * _delta
			
			.call_deferred("_calc_speed", _delta)
		else:
			get_new_target()
			
		_delta = 0

func _calc_speed(delta):
	var distance_to_target = self.global_transform.origin.distance_squared_to(self._ship_target)
	if distance_to_target < pow(16, 2):
		if self._ship_speed > 0:
			self._ship_speed -= acceleration * delta * 10
		self._ship_target = null
		trail.set_emitting(false)
		
	elif self._ship_speed < min_speed:
		self._ship_speed = min_speed
	elif self._ship_speed > max_speed:
		self._ship_speed = max_speed
	elif distance_to_target < pow(self._ship_speed, 2):
		self._ship_speed -= acceleration * delta * 10
	elif self._ship_speed < max_speed:
		self._ship_speed += acceleration * delta
	else:
		self._ship_speed -= acceleration * delta * 10

func get_new_target():
	var planets = .get_tree().get_nodes_in_group("Planet")
	var planets_in_planet_system = []
	for planet in planets:
		if planet.get_planet_system() == State.get_planet_system():
			planets_in_planet_system.push_back(planet)
	
	if planets_in_planet_system.size() > 0:
		var target_planet = planets_in_planet_system[randi() % planets_in_planet_system.size()]
		self._ship_target = target_planet.get_target_point()
		if self.visible:
			trail.set_emitting(true)
	
func set_visible(in_data) -> void:
	if typeof(in_data) == TYPE_BOOL:
		self.visible = in_data
	else:
		self.visible = .get_planet_system() == in_data
	trail.set_emitting(self.visible)
