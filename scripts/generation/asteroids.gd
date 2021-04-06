extends Node

static func generate(planet_system_idx: int) -> Array:
	
	var asteroids_min = Consts.ASTEROIDS_PER_PLANET_SYSTEM[WorldGenerator.world_size].min
	var asteroids_max = Consts.ASTEROIDS_PER_PLANET_SYSTEM[WorldGenerator.world_size].max
	var total_asteroids = Random.randi_range(asteroids_min, asteroids_max)
	
	var asteroid_formations = Enums.asteroid_formation_types.values()
	asteroid_formations.shuffle()
	var asteroid_formation = asteroid_formations[0]
	var asteroid_formation_angle = 2 * PI * Random.randf()	
	
	var asteroids = []
	for asteroid_idx in range(total_asteroids):
		
		var angle = 2 * PI * Random.randf()
		var distance = Consts.ASTEROIDS_BASE_DISTANCE_TO_SUN + Random.randf() * (Consts.PLANET_SYSTEM_RADIUS + Consts.ASTEROIDS_EXTRA_DISTANCE)
		var position = Vector2(distance * cos(angle), distance * sin(angle))
		
		if asteroid_idx >= total_asteroids * 0.5 and asteroid_formation != Enums.asteroid_formation_types.none:
			var polygon = []
			match asteroid_formation:
				Enums.asteroid_formation_types.belt:
					distance = Consts.ASTEROIDS_FORMATION_BELT_DISTANCE + Random.randf() * Consts.ASTEROIDS_FORMATION_OFFSET
					for i in range(64):
						var angle_point = deg2rad(i * 360 / 64)
						polygon.push_back(Vector2(cos(angle_point), sin(angle_point)) * distance)
				Enums.asteroid_formation_types.hilda:
					
					var x = 0
					var y = 0
					
					x = Consts.ASTEROIDS_FORMATION_HILDA_SIZE * cos(asteroid_formation_angle)
					y = Consts.ASTEROIDS_FORMATION_HILDA_SIZE * sin(asteroid_formation_angle)
					polygon.append(Vector2(x, y))
					
					x = Consts.ASTEROIDS_FORMATION_HILDA_SIZE * cos(asteroid_formation_angle + 2 * PI / 3)
					y = Consts.ASTEROIDS_FORMATION_HILDA_SIZE * sin(asteroid_formation_angle + 2 * PI / 3)
					polygon.append(Vector2(x, y))
					
					x = Consts.ASTEROIDS_FORMATION_HILDA_SIZE * cos(asteroid_formation_angle - 2 * PI / 3)
					y = Consts.ASTEROIDS_FORMATION_HILDA_SIZE * sin(asteroid_formation_angle - 2 * PI / 3)
					polygon.append(Vector2(x, y))
					
					
				Enums.asteroid_formation_types.dual:
					
					var p1 = Vector2(Consts.ASTEROIDS_FORMATION_DUAL_LARGEST * cos(asteroid_formation_angle), Consts.ASTEROIDS_FORMATION_DUAL_LARGEST * sin(asteroid_formation_angle))
					var p2 = Vector2(Consts.ASTEROIDS_FORMATION_DUAL_SMALLEST * cos(asteroid_formation_angle - PI / 2), Consts.ASTEROIDS_FORMATION_DUAL_SMALLEST * sin(asteroid_formation_angle - PI / 2))
						
					for i in range(64):
						var t = 2 * PI / 64 * i + asteroid_formation_angle
						var x = p1.x * cos(t) + p2.x * sin(t)
						var y = p1.y * cos(t) + p2.y * sin(t)
						polygon.append(Vector2(x, y))
			
			if polygon.size():
				var prev = polygon[polygon.size() - 1]
				var curr
				var intersects = null
				var to = Vector2(Consts.PLANET_SYSTEM_RADIUS * 2 * cos(angle), Consts.PLANET_SYSTEM_RADIUS * 2 * sin(angle))
				for i in range(polygon.size()):
					curr = polygon[i]

					intersects = Geometry.segment_intersects_segment_2d(Vector2.ZERO, to, prev, curr)

					if intersects != null:
						break

					prev = curr

				position = intersects

			if asteroid_formation == Enums.asteroid_formation_types.hilda:
				var intersects_circle = Geometry.segment_intersects_circle(Vector2.ZERO, position, Vector2.ZERO, Consts.ASTEROIDS_FORMATION_HILDA_BREAK_POINT)
				if intersects_circle != -1:
					position = position * intersects_circle

			position += position.normalized() * Random.randf() * Consts.ASTEROIDS_FORMATION_OFFSET
			
		asteroids.append(Instancer.prop(Enums.prop_types.asteroid, planet_system_idx, position))
		
	return asteroids
