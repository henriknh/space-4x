extends Node

class_name Action

# Method variables
var caller: Entity = null
var on_method = null
var method_params = []

# Visual variables
var texture: Texture = preload("res://assets/icons/godot_icon.png")
var texture_hover: Texture
var texture_pressed: Texture
var label: String
var disabled = false
var active = false

func init(_caller: Entity, _on_method: String, _texture: Texture):
	caller = _caller
	on_method = _on_method
	texture = _texture
	
	return self

func run_deferred():
	call_deferred("run")
	
func run():
	caller.callv(on_method, method_params)
