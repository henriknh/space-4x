extends Node

class_name Faction
	
var is_computer = true
var faction = -1
var difficulty = WorldGenerator.rng.randi() % Consts.AI_DIFFICULTY_LEVELS
var friendliness = (WorldGenerator.rng.randf() * 2) - 1
var explorer = WorldGenerator.rng.randf()
var color = Color(0,0,0,0)
var resources = {
	'asteroid_rocks': 5,
	'titanium': 0,
	'astral_dust': 0
}
	
func _init(faction: int) -> void:
	self.is_computer = faction != 0
	self.faction = faction
	self.color = Enums.player_colors[faction]
