extends Planet

class_name PlanetEarth

func create():
	planet_type = Enums.planet_types.earth
	add_to_group('Earth')
	.create()
