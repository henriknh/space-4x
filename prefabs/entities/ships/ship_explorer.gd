extends Ship

class_name ShipExplorer

var is_colonizing = false
var explore_position: Vector2 = Vector2.INF 

func create():
	ship_type = Enums.ship_types.explorer
	ship_speed_max = 150
	.create()
	
func _ready():
	add_to_group('Explorer')
	._ready()

func process(delta: float):
	
	if parent.corporation_id == 0:
		state = Enums.ship_states.colonize
	
	if state == Enums.ship_states.colonize:
		if parent.corporation_id != 0:
			state = Enums.ship_states.idle
		elif move(parent.position):
			pass
		else:
			parent.corporation_id = corporation_id
			parent.update()
			kill()
	
	.process(delta)
