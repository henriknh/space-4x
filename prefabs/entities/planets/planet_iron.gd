extends Planet

class_name PlanetIron

func create():
	planet_type = Enums.planet_types.iron
	add_to_group('Iron')
	.create()
