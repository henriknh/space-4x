extends Prop

class_name Asteroid

var sprite_size = 0

onready var node_sprite: Sprite = $Sprite
onready var node_collision: CollisionShape2D = $CollisionShape

func create():
	prop_type = Enums.prop_types.asteroid
	label = NameGenerator.get_name_asteroid()
	rotation_speed = Random.randf_range(-1, 1) * 10
	
	asteroid_rocks = Random.randf_range(4, 32)
	
	.create()
	
func _ready():
	var texture_size = node_sprite.texture.get_size()
	var scale = int(ceil(asteroid_rocks / 8))
	
	node_collision.shape = RectangleShape2D.new()
	node_collision.shape.extents = (texture_size / 2) * scale 
	node_sprite.scale = Vector2.ONE * scale
	node_sprite.self_modulate = Color.from_hsv(0, 0, float((variant % 30) + 60) / 100)
	
	._ready()
	
func process(delta: float):
	if asteroid_rocks <= 0:
		kill()
		
	if visible:
		node_sprite.rotation_degrees += rotation_speed * delta
	
	.process(delta)
