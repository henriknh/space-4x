extends ship

class_name ship_utility

enum STATES {
	idle,
	moving
}

func create():
	ship_type = Enums.ship_types.utility
	.create()
