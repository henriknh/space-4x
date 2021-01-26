extends Ship

class_name ShipExplorer

var is_colonizing = false
var explore_position: Vector2 = Vector2.INF 

func create():
	ship_type = Enums.ship_types.explorer
	ship_speed_max = 1000
	power_max = 40
	.create()
	
func ready():
	add_to_group('Explorer')
	.ready()

func process(delta: float):
	if state == Enums.ship_states.colonize:
		if parent.faction != -1:
			state = Enums.ship_states.idle
		elif move(parent.position):
			pass
		else:
			parent.faction = faction
			parent.update()
			kill()
	
	.process(delta)

func clear():
	.clear()
