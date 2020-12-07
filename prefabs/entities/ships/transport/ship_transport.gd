extends ship

class_name ship_transport

enum STATES {
	idle,
	moving,
	mining
}

func create():
	ship_type = Enums.ship_types.transport
	ship_cargo_size = 400
	power_max = 20
	.create()
