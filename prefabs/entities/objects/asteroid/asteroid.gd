extends object

class_name asteroid

func create():
	label = NameGenerator.get_name_asteroid()
	rotation_speed = WorldGenerator.rng.randf_range(-1, 1) * 10
	metal = WorldGenerator.rng.randf_range(100, 1000)
	
func _process(delta):
	if visible:
		$Sprite.rotation_degrees += rotation_speed * delta

func get_target_point():
	var angle = 2 * PI * randf()
	var r = ($CollisionShape2D.shape as CircleShape2D).radius * randf()
	
	var x = r * cos(angle) + global_transform.origin.x
	var y = r * sin(angle) + global_transform.origin.y
	
	return Vector2(x, y)
