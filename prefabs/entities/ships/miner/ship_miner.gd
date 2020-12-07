extends ship

class_name ship_miner

enum STATES {
	idle,
	moving,
	mining
}

func create():
	ship_type = Enums.ship_types.miner
	metal_max = 100
	.create()
