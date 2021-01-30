extends Node

onready var planet = load("res://scripts/ai/planet.gd")

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

func get_ai(faction: int) -> Computer:
	if computers.has(faction):
		return computers[faction]
	else:
		return null

func process_entity(entity: Entity, delta: float):
	var ai = get_ai(entity.faction)
	
	if entity.state == Enums.ai_states.delay:
		entity.process_time += delta
		
		if entity.get_process_progress() > 1:
			match entity.entity_type:
				Enums.entity_types.planet:
					return planet.process(entity)
			
			entity.state = Enums.ai_states.idle
		
	if entity.state == Enums.ai_states.idle:
		var delay_time = (Consts.DIFFICULTY_LEVELS - ai.difficulty) * 5
		entity.set_entity_process(Enums.ai_states.delay, -1, delay_time)
