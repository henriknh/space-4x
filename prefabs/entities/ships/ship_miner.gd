extends ship

class_name ship_miner

enum STATES {
	idle,
	moving,
	mining
}

func ready():
	add_to_group('Miner')
	.ready()

func create():
	color = Color(1, 0.8, 0.4, 1)
	ship_type = Enums.ship_types.miner
	ship_speed_max = 1000
	metal_max = 100
	.create()
