extends Node

class_name Corporation

signal corporation_changed

# Constant variables
var is_computer: bool = true
var corporation_id: int = 0
var difficulty: int = (Random.randi() % Consts.AI_DIFFICULTY_LEVELS)
var friendliness: float = (Random.randf() * 2) - 1
var explorer: float = Random.randf()
var color: Color = Color(0,0,0,0)

# Dyanamic variables
var resource_titanium: int = 0 setget set_resource_titanium
var resource_dust: int = 0 setget set_resource_dust

func _init(_corporation_id: int, _is_computer: bool) -> void:
	corporation_id = _corporation_id
	is_computer = _is_computer
	color = Enums.corporation_colors[corporation_id]
	emit_signal("corporation_changed")

func set_resource_titanium(_resource_titanium):
	resource_titanium = _resource_titanium
	emit_signal("corporation_changed")
	
func set_resource_dust(_resource_dust):
	resource_dust = _resource_dust
	emit_signal("corporation_changed")
	
func save():
	return inst2dict(self)
