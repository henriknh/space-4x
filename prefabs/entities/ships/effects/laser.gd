extends Line2D

onready var timer: Timer = $Timer

func emit(source: Vector2, target: Vector2, color: Color):
	points = [source, target]
	self_modulate = color
	timer.start()

func _on_destroy():
	queue_free()
