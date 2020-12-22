extends planet

class_name planet_ice

func create():
	planet_type = Enums.planet_types.ice
	add_to_group('Ice')
	.create()

