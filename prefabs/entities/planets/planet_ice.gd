extends Planet

class_name PlanetIce

func create():
	planet_type = Enums.planet_types.ice
	add_to_group('Ice')
	.create()

