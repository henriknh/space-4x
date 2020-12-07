extends entity

class_name planet

var prefab_lava = preload('res://assets/PixelPlanets/LavaWorld/LavaWorld.tscn')
var prefab_iron = preload('res://assets/PixelPlanets/GasPlanet/GasPlanet.tscn')
var prefab_earth_1 = preload('res://assets/PixelPlanets/LandMasses/LandMasses.tscn')
var prefab_earth_2 = preload('res://assets/PixelPlanets/Rivers/Rivers.tscn')
var prefab_ice = preload('res://assets/PixelPlanets/IceWorld/IceWorld.tscn')

func create():
	entity_type = Enums.entity_types.planet
	rotation_speed = WorldGenerator.rng.randf_range(-1, 1) * 10
	label = NameGenerator.get_name_planet()
	indestructible = true
	init()
	
func init():
	.get_node("InfoUI").set_label(label)
	
	var instance = null
	match planet_type:
		Enums.planet_types.lava:
			instance = prefab_lava.instance()
			.add_to_group('Lava')
		Enums.planet_types.iron:
			instance = prefab_iron.instance()
			.add_to_group('Iron')
		Enums.planet_types.earth:
			if WorldGenerator.rng.randi() % 2 == 0:
				instance = prefab_earth_1.instance()
			else:
				instance = prefab_earth_2.instance()
			.add_to_group('Earth')
		Enums.planet_types.ice:
			instance = prefab_ice.instance()
			.add_to_group('Ice')
			
	(instance as Control).rect_scale = Vector2(planet_size, planet_size)
	(instance as Control).set_position(Vector2(-100 * planet_size, -100 * planet_size))

	.add_child(instance)
	
func _ready():
	pass 
	
func _process(delta):
	if self.visible:
		.get_node("Sprite").rotation_degrees += rotation_speed * delta

func get_target_point():
	var angle = 2 * PI * randf()
	var r = (.get_node("CollisionShape2D").shape as CircleShape2D).radius * randf()
	
	var x = r * cos(angle) + self.global_transform.origin.x
	var y = r * sin(angle) + self.global_transform.origin.y
	
	return Vector2(x, y)

func _on_Area2D_body_entered(body):
	pass # Replace with function body.
	print(body)

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	pass # Replace with function body.
	print(body_id)
