extends planet

func create():
	planet_type = Enums.planet_types.earth
	planet_size = WorldGenerator.rng.randf_range(1.0, 2.0)
	.create()
