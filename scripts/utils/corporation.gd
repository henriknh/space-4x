extends Node

class_name Corporation

var is_computer: bool = true
var corporation_id: int = 0
var difficulty: int = Random.randi() % Consts.AI_DIFFICULTY_LEVELS
var friendliness: float = (Random.randf() * 2) - 1
var explorer: float = Random.randf()
var color: Color = Color(0,0,0,0)
var resources = {
	'asteroid_rocks': Consts.RESOURCE_START_ASTEROID_ROCKS,
	'titanium': Consts.RESOURCE_START_TITANIUM,
	'astral_dust': Consts.RESOURCE_START_ASTRAL_DUST
}

func _init(corporation_id: int) -> void:
	self.is_computer = corporation_id > Consts.PLAYER_CORPORATION
	self.corporation_id = corporation_id
	self.color = Enums.corporation_colors[corporation_id]
