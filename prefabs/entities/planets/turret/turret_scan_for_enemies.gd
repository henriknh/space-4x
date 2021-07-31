extends ScanForEnemiesState

export var rotation_speed: float = 25
export var default_angle: float = 60

func update(delta):
	var rotation = host.rotation_degrees
	
	rotation.y += rotation_speed * delta
	
	if rotation.x != default_angle:
		var diff = clamp(default_angle - rotation.x, -1, 1)
		rotation.x += diff * rotation_speed / 10 * delta
	
	host.rotation_degrees = rotation
	
	return .update(delta)
