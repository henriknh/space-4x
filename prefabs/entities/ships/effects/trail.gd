extends Node2D

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_emitting(is_emitting: bool) -> void:
	pass
	$Line2D.set_emitting(is_emitting)
	
func is_emitting() -> bool:
	return $Line2D.is_emitting

func set_color(color: Color) -> void:
	var color1 = color
	var color2 = color
	color1.a = 0
	color2.a = 0.2
	$Line2D.gradient = Gradient.new()
	$Line2D.gradient.colors = [color1, color2]
