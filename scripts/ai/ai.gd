extends Node

onready var planet = preload("res://scripts/ai/planet/planet.gd").new()
onready var ship = preload("res://scripts/ai/ship/ship.gd").new()

class Computer:
	
	var faction = -1
	var difficulty = WorldGenerator.rng.randi() % Consts.DIFFICULTY_LEVELS
	var friendliness = (WorldGenerator.rng.randf() * 2) - 1
	var explorer = WorldGenerator.rng.randf()
	var color = Color(0,0,0,0)
	
	func _init(faction: int) -> void:
		self.faction = faction
		self.color = Enums.player_colors[faction]

var computers = {}

func create(faction: int) -> Computer:
	var ai = Computer.new(faction)
	computers[faction] = ai
	return ai

func get_computer(faction: int) -> Computer:
	if computers.has(faction):
		return computers[faction]
	else:
		return null

func process_entity(entity: Entity, delta: float):
	match entity.entity_type:
		Enums.entity_types.planet:
			return planet.process(entity, delta)
		Enums.entity_types.ship:
			return ship.process(entity, delta)
		
