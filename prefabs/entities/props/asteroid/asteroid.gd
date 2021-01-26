extends Prop

class_name Asteroid

var sprite_size = 0
var sprite_small = preload("res://assets/asteroid_small.png")
var sprite_medium = preload("res://assets/asteroid_medium.png")
var sprite_large = preload("res://assets/asteroid_large.png")

func create():
	object_type = Enums.object_types.asteroid
	label = NameGenerator.get_name_asteroid()
	rotation_speed = WorldGenerator.rng.randf_range(-1, 1) * 10
	
	metal = WorldGenerator.rng.randf_range(150, 150)
	.create()
	
func ready():
	if metal < 400:
		$Sprite.texture = sprite_small
		sprite_size = 4
	elif metal < 700:
		$Sprite.texture = sprite_medium
		sprite_size = 8
	else:
		$Sprite.texture = sprite_large
		sprite_size = 16
		
	#($CollisionShape2D.shape as CircleShape2D).radius = sprite_size
	$Sprite.self_modulate = Color.from_hsv(0, ((variant % 20) + 20) / 100, ((variant % 30) + 70) / 100)
	
	.ready()
	
func process(delta: float):
	if metal == 0:
		kill()
		
	if visible:
		$Sprite.rotation_degrees += rotation_speed * delta
	
	.process(delta)

#func get_target_point():
#	var angle = 2 * PI * randf()
#	var r = ($CollisionShape2D.shape as CircleShape2D).radius * randf()
#
#	var x = r * cos(angle) + global_transform.origin.x
#	var y = r * sin(angle) + global_transform.origin.y
#
#	return Vector2(x, y)
