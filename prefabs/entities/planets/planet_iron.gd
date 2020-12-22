extends planet

class_name planet_iron

func create():
	planet_type = Enums.planet_types.iron
	add_to_group('Iron')
	.create()
