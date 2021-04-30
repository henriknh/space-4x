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
var asteroid_rocks: int = Consts.RESOURCE_START_ASTEROID_ROCKS setget set_asteroid_rocks
var titanium: int = Consts.RESOURCE_START_TITANIUM setget set_titanium
var astral_dust: int = Consts.RESOURCE_START_ASTRAL_DUST setget set_astral_dust

func _init(_corporation_id: int) -> void:
	self.corporation_id = _corporation_id
	self.is_computer = corporation_id > Consts.PLAYER_CORPORATION
	self.color = Enums.corporation_colors[corporation_id]
	emit_signal("corporation_changed")

func set_asteroid_rocks(_asteroid_rocks):
	asteroid_rocks = _asteroid_rocks
	emit_signal("corporation_changed")

func set_titanium(_titanium):
	titanium = _titanium
	emit_signal("corporation_changed")

func set_astral_dust(_astral_dust):
	astral_dust = _astral_dust
	emit_signal("corporation_changed")
	
func save():
	return inst2dict(self)
