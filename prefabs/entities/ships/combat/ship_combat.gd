extends ship

class_name ship_combat

enum STATES {
	idle,
	moving,
	combat
}

func create():
	ship_type = Enums.ship_types.combat
	ship_speed_max = 2000
	power_max = 20
	.create()
