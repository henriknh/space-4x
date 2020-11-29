extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	#$Particles2D.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_emitting(is_emitting: bool) -> void:
	pass
	$Line2D.set_emitting(is_emitting)
