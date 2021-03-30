extends Line2D

onready var timer: Timer = $Timer
onready var particles: Particles2D = $Particles

var from: Vector2
var to: Vector2
var color: Color

func _ready():
	points = [from, to]
	self_modulate = color
	particles.position = to
	particles.self_modulate = color
	timer.start()

func _on_destroy():
	queue_free()
