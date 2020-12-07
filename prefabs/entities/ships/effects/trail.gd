extends Node2D

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_emitting(is_emitting: bool) -> void:
	pass
	$Line2D.set_emitting(is_emitting)
