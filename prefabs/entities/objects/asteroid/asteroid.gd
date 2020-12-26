extends object

class_name asteroid

var sprite_small = preload("res://assets/asteroid_small.png")
var sprite_medium = preload("res://assets/asteroid_medium.png")
var sprite_large = preload("res://assets/asteroid_large.png")

func create():
	label = NameGenerator.get_name_asteroid()
	color = Color.from_hsv(0, WorldGenerator.rng.randf_range(20, 40) / 100, WorldGenerator.rng.randf_range(70, 100) / 100)
	rotation_speed = WorldGenerator.rng.randf_range(-1, 1) * 10
	
	metal = WorldGenerator.rng.randf_range(100, 1000)
	.create()
	
func ready():
	if metal < 400:
		$Sprite.texture = sprite_small
		($CollisionShape2D.shape as CircleShape2D).radius = 4
	elif metal < 700:
		$Sprite.texture = sprite_medium
		($CollisionShape2D.shape as CircleShape2D).radius = 8
	else:
		$Sprite.texture = sprite_large
		($CollisionShape2D.shape as CircleShape2D).radius = 16
	$Sprite.self_modulate = color
	.ready()
	
func _process(delta):
	if visible:
		$Sprite.rotation_degrees += rotation_speed * delta

func get_target_point():
	var angle = 2 * PI * randf()
	var r = ($CollisionShape2D.shape as CircleShape2D).radius * randf()
	
	var x = r * cos(angle) + global_transform.origin.x
	var y = r * sin(angle) + global_transform.origin.y
	
	return Vector2(x, y)
