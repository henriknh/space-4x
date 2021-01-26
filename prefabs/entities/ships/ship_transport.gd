extends Ship

class_name ShipTransport
	
func create():
	ship_type = Enums.ship_types.transport
	ship_cargo_size = 400
	power_max = 20
	.create()

func ready():
	add_to_group('Transport')
	.ready()

func process(delta: float):
	.process(delta)

func clear():
	.clear()
