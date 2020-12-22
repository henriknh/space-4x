extends ship

class_name ship_combat

enum STATES {
	idle,
	moving,
	combat
}

func ready():
	add_to_group('Combat')
	.ready()

func create():
	color = Color(1, 0, 0.4, 1)
	ship_type = Enums.ship_types.combat
	ship_speed_max = 2000
	power_max = 20
	.create()
