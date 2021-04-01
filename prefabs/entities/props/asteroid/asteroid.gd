extends Prop

class_name Asteroid

var asteroid_rocks: float = 0

var sprite_size = 0

onready var node_sprite: Sprite = $Sprite
onready var node_collision: CollisionShape2D = $CollisionShape

func create():
	prop_type = Enums.prop_types.asteroid
	
	asteroid_rocks = Random.randi_range(4, 32)
	
	.create()
	
func _ready():
	
	connect("entity_changed", self, "_update_size")
	
	node_collision.shape = RectangleShape2D.new()
	#node_sprite.self_modulate = Color.from_hsv(0, 0, float((variant % 30) + 60) / 100)
	node_sprite.self_modulate = Color.white
	_update_size()
	
	._ready()
	
func process(delta: float):
	if asteroid_rocks <= 0:
		kill()
	
	.process(delta)

func _update_size():
	var texture_size = node_sprite.texture.get_size()
	var size = asteroid_rocks + 16
	node_collision.shape.extents = Vector2.ONE * size / 2
	node_sprite.scale = Vector2.ONE * size / texture_size
	
	if asteroid_rocks == 0:
		Instancer.asteroid_dust(self, true)

func save():
	var save = .save()
	save["asteroid_rocks"] = asteroid_rocks
	return save
