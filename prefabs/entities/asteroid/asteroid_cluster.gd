extends Spatial

var tiles = []
var path_follows = []
var path_follows_speed = []

func _ready():
	
	var curve = Curve3D.new()
	
	for i in range(10):
		for tile in tiles:
			var point = tile
			var x = (Random.randf() * 2) - 1
			var y = (Random.randf() * 2) - 1
			var z = (Random.randf() * 2) - 1
			point += Vector3(x, y, z)
			curve.add_point(point)
	curve.add_point(curve.get_point_position(0))
	
	$Path.curve = curve
	
	for i in range(tiles.size() * 8):
		var sphere = SphereMesh.new()
		sphere.radius = 0.1 + Random.randf() / 4
		sphere.height = sphere.radius * 2

		var mesh = MeshInstance.new()
		mesh.mesh = sphere
		
		var path_follow = PathFollow.new()
		path_follow.add_to_group("AsteroidChain")
		path_follow.add_child(mesh)
		$Path.add_child(path_follow)
		path_follow.unit_offset = Random.randf()
		
		path_follows.append(path_follow)
		path_follows_speed.append(Random.randf() * 0.5)

func _physics_process(delta):
	for i in range(path_follows.size()):
		path_follows[i].offset += delta * path_follows_speed[i]
