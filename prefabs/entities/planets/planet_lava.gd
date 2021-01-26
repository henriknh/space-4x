extends Planet

class_name PlanetLava

func create():
	planet_type = Enums.planet_types.lava
	add_to_group('Lava')
	.create()
