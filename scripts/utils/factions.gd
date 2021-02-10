extends Node

class Faction:
	
	var is_computer = true
	var faction = -1
	var difficulty = WorldGenerator.rng.randi() % Consts.DIFFICULTY_LEVELS
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

var factions = {}

func create(faction: int) -> Faction:
	var ai = Faction.new(faction)
	factions[faction] = ai
	return ai

func get_faction(faction: int) -> Faction:
	if factions.has(faction):
		return factions[faction]
	else:
		return null
