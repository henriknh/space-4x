extends Area2D

var points = 32
var radius: float = 0

onready var node_collision: CollisionPolygon2D = $CollisionShape

func _ready():
	radius += Consts.PLANET_SYSTEM_BASE_DISTANCE_TO_SUN
	radius += Consts.PLANET_SYSTEM_RADIUS
	radius += Consts.ASTEROIDS_EXTRA_DISTANCE * 2
	
	var polygon = PoolVector2Array()
	for i in range(points + 1):
		var angle_point = deg2rad(i * 360 / points)
		polygon.push_back(Vector2.ZERO + Vector2(cos(angle_point), sin(angle_point)) * radius)
	for i in range(points + 1):
		var angle_point = deg2rad((points - i) * 360 / points)
		polygon.push_back(Vector2.ZERO + Vector2(cos(angle_point), sin(angle_point)) * radius * 2)
	
	node_collision.polygon = polygon
