extends Spatial

var group_id: int

var center_point: Vector3 = Vector3.ZERO
var path_follows = []
var path_follows_speed = []

func _ready():
	
	if not group_id:
		group_id = Instancer.group_id_counter
	
	var asteroids = []
	for asteroid in get_tree().get_nodes_in_group("Asteroid"):
		if asteroid.group_id == group_id:
			asteroids.append(asteroid)
			center_point += asteroid.global_transform.origin
	center_point /= asteroids.size()
	asteroids.sort_custom(self, "sort_clockwise")
	
	var curve = Curve3D.new()
	
	for i in range(3):
		for asteroid in asteroids:
			var point = -asteroid.global_transform.origin
			var x = (Random.randf() * 2) - 1
			var y = (Random.randf() * 2) - 1
			var z = (Random.randf() * 2) - 1
			point += Vector3(x, y, z)
			curve.add_point(point)
	curve.add_point(curve.get_point_position(0))
	
	$Path.curve = curve
	
	for i in range(asteroids.size() * 8):
		var asteroid_mesh = preload("res://prefabs/entities/asteroid/asteroid_mesh.tscn").instance()
		var path_follow = PathFollow.new()
		
		path_follow.add_child(asteroid_mesh)
		$Path.add_child(path_follow)
		
		asteroid_mesh.set_mesh_scale(0.1 + Random.randf() / 4)
		path_follow.unit_offset = Random.randf()
		
		path_follows.append(path_follow)
		path_follows_speed.append(Random.randf() * 0.5)

func _physics_process(delta):
	for i in range(path_follows.size()):
		path_follows[i].offset += delta * path_follows_speed[i]

func sort_clockwise(a, b):
	var p1 = a.global_transform.origin - center_point
	var p2 = b.global_transform.origin - center_point
	var _p1 = Vector2(p1.x, p1.z)
	var _p2 = Vector2(p2.x, p2.z)
	return _p1.angle() < _p2.angle()
