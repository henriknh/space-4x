extends Node

onready var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	_rng.set_seed(0)

func get_seed() -> int:
	return _rng.get_seed()
	
func set_seed(seed_value: int) -> void:
	_rng.set_seed(seed_value)
	
func randi() -> int:
	return _rng.randi()
	
func randf() -> float:
	return _rng.randf()
	
func randi_range(from: int, to: int) -> int:
	return _rng.randi_range(from, to)
	
func randf_range(from: float, to: float) -> float:
	return _rng.randf_range(from, to)
