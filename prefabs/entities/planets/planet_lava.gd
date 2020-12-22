extends planet

class_name planet_lava

func create():
	planet_type = Enums.planet_types.lava
	add_to_group('Lava')
	.create()
