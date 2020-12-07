extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var node_metal = $Metal/Value
onready var node_power = $Power/Value
onready var node_food = $Food/Value
onready var node_water = $Water/Value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_ui():
	pass
	var planets = get_tree().get_nodes_in_group('Planet')

	var metal = 0
	var power = 0
	var food = 0
	var water = 0
	
	for entity in planets:
		if entity.planet_system == State.get_planet_system():
			metal += entity.metal
			power += entity.power
			food += entity.food
			water += entity.water
		
	node_metal.text = Formatter.round_to_dec(metal, 2) as String
	node_power.text = Formatter.round_to_dec(power, 2) as String
	node_food.text = Formatter.round_to_dec(food, 2) as String
	node_water.text = Formatter.round_to_dec(water, 2) as String
	

	
func _on_back_to_galaxy():
	State.show_planet_systems()
