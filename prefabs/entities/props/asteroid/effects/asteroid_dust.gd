extends Node2D

onready var particles_large: Particles2D = $ParticlesLarge
onready var particles_small: Particles2D = $ParticlesSmall
onready var timer: Timer = $Timer

var is_large: bool = false
var color

func _ready():
	if color:
		particles_large.self_modulate = color
		particles_small.self_modulate = color
	
	particles_large.visible = is_large
	particles_small.visible = not is_large
	
	particles_large.emitting = is_large
	particles_small.emitting = not is_large

	timer.wait_time = particles_large.lifetime if is_large else particles_small.lifetime
	timer.start()

func _on_destroy():
	queue_free()
