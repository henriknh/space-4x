extends entity

class_name planet

var prefab_lava = preload('res://assets/PixelPlanets/LavaWorld/LavaWorld.tscn')
var prefab_earth_1 = preload('res://assets/PixelPlanets/LandMasses/LandMasses.tscn')
var prefab_earth_2 = preload('res://assets/PixelPlanets/Rivers/Rivers.tscn')
var prefab_ice = preload('res://assets/PixelPlanets/IceWorld/IceWorld.tscn')

func create():
	set_rotation_speed(WorldGenerator.rng.randf_range(-1, 1) * 10)
	set_name(NameGenerator.get_name_planet())
	set_indestructible(true)
	init()
	
func init():
	#$EntityGUI/Label.text = get_name()
	var instance = null
	match int(_planet_type):
		Enums.planet_types.lava:
			instance = prefab_lava.instance()
			add_to_group('Lava')
		Enums.planet_types.iron:
			instance = prefab_lava.instance()
			add_to_group('Iron')
		Enums.planet_types.earth:
			if WorldGenerator.rng.randi() % 2 == 0:
				instance = prefab_earth_1.instance()
			else:
				instance = prefab_earth_2.instance()
			add_to_group('Earth')
		Enums.planet_types.ice:
			instance = prefab_ice.instance()
			add_to_group('Ice')
			
	(instance as Control).rect_scale = Vector2(get_planet_size(), get_planet_size())
	add_child(instance)
	
func _ready():
	pass 
	
func _process(delta):
	if visible:
		$Sprite.rotation_degrees += _rotation_speed * delta

func get_target_point():
	var angle = 2 * PI * randf()
	var r = ($CollisionShape2D.shape as CircleShape2D).radius * randf()
	
	var x = r * cos(angle) + global_transform.origin.x
	var y = r * sin(angle) + global_transform.origin.y
	
	return Vector2(x, y)

func set_planet_type(planet_type: int):
	_planet_type = planet_type

func set_planet_size(planet_size: float):
	_planet_size = planet_size

func get_planet_size() -> float:
	return _planet_size
	
func set_orbit_distance(distance: int) -> void:
	_planet_orbit_distance = distance
	
func get_orbit_distance() -> int:
	return _planet_orbit_distance

func _on_Area2D_body_entered(body):
	pass # Replace with function body.
	print(body)

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	pass # Replace with function body.
	print(body_id)
