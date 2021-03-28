extends Node2D

onready var node_line: Line2D = $Line2D
onready var node_particles: Particles2D = $Particles2D

func set_emitting(is_emitting: bool) -> void:
	node_line.set_emitting(false)#is_emitting)
	
func is_emitting() -> bool:
	return node_line.is_emitting

func set_color(color: Color) -> void:
	var color1 = color
	var color2 = color
	color1.a = 0
	color2.a = 0.2
	node_line.gradient = Gradient.new()
	node_line.gradient.colors = [color1, color2]
	node_particles.self_modulate = color

func set_texture(texture: Texture) -> void:
	node_particles.texture = texture
