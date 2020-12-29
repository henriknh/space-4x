extends ship

class_name ship_explorer

enum STATES {
	idle,
	moving
}


func create():
	color = Color(1, 1, 1, 1)
	ship_type = Enums.ship_types.explorer
	ship_speed_max = 1000
	ship_cargo_size = 200
	power_max = 40
	.create()
	
func ready():
	add_to_group('Explorer')
	.ready()

func process():
	.process()
