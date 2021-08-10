extends Ship

class_name Miner

var titanium: int = 0
var dust: int = 0

func _ready():
	add_to_group('Miner')
