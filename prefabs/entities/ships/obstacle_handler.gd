extends Node2D

onready var detectors = $Detectors.get_children()
onready var sensors = $Sensors.get_children()
onready var node_middle_ray: RayCast2D = $RayCastForward
onready var parent: Node2D = get_owner()

func add_exception(exception: Entity) -> void:
	for ray in detectors:
		ray.add_exception(exception)

func add_exceptions(exceptions: Array) -> void:
	for ray in detectors:
		for exception in exceptions:
			ray.add_exception(exception)

func remove_exception(exception: Entity) -> void:
	for ray in detectors:
		ray.remove_exception(exception)

func is_obsticle_ahead(target: Vector2) -> bool:
	for ray in detectors:
		if ray.is_colliding() and ray.get_collider().position != target:
			return true
	return false
	
func collision_count () -> int:
	var count = 0
	for ray in detectors:
		if ray.is_colliding():
			count += 1
	return count
	
func collision_percentage() -> int:
	return collision_count() / detectors.size()

func obsticle_avoidance() -> Vector2:
	for ray in sensors:
		if not ray.is_colliding():
			return ray.cast_to.rotated(ray.rotation + parent.rotation).normalized()
	return Vector2(cos(parent.rotation - PI), sin(parent.rotation - PI)).normalized()

