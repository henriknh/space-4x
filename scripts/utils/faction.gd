extends Node

class_name Faction
	
var is_computer = true
var faction = -1
var difficulty = Random.randi() % Consts.AI_DIFFICULTY_LEVELS
var friendliness = (Random.randf() * 2) - 1
var explorer = Random.randf()
var color = Color(0,0,0,0)
var resources = {
	'asteroid_rocks': Consts.RESOURCE_START_ASTEROID_ROCKS,
	'titanium': Consts.RESOURCE_START_TITANIUM,
	'astral_dust': Consts.RESOURCE_START_ASTRAL_DUST
}
	
func _init(faction: int) -> void:
	self.is_computer = faction != 0
	self.faction = faction
	self.color = Enums.player_colors[faction]
