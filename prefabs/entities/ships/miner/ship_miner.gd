extends ship

class_name ship_miner

enum STATES {
	idle,
	moving,
	mining
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	.set_metal(randf())
	.set_power(randf())
	.set_food(randf())
	.set_water(randf())
	
