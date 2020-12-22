extends ship

class_name ship_transport

enum STATES {
	idle,
	moving
}

func ready():
	add_to_group('Transport')
	.ready()
	
func create():
	color = Color(0.2, 0.5, 1, 1)
	ship_type = Enums.ship_types.transport
	ship_cargo_size = 400
	power_max = 20
	.create()
