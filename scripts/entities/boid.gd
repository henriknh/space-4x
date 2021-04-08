extends Node

# https://github.com/codatproduction/Boids-simulation/blob/master/src/Boid.gd
# https://github.com/kyrick/godot-boids/blob/master/src/Actors/Chicken/Chicken.gd

func process(ship: Entity) -> Vector2:
	
	if not ship.parent or ship.neighbors.size() == 0:
		return Vector2.ZERO
	
	var vector_cohesion = Vector2.ZERO
	var vector_alignments = Vector2.ZERO
	var vector_seperation = Vector2.ZERO
	
	for neighbor in ship.neighbors:
		if not neighbor \
		or neighbor.state != Enums.ship_states.idle \
		or neighbor == ship \
		or neighbor.is_dead():
			continue
		
		vector_cohesion += neighbor.position
		vector_alignments += neighbor.velocity
		
		var distance = ship.position.distance_to(neighbor.position)
		if 0 < distance and distance < Consts.SHIP_BOID_AVOID_DISTANCE:
			vector_seperation -= (neighbor.position - ship.position).normalized() * (Consts.SHIP_BOID_AVOID_DISTANCE / distance * ship.ship_speed)
	
	vector_cohesion /= ship.neighbors.size()
	vector_alignments /= ship.neighbors.size()
	
	var velocity = Vector2.ZERO
	velocity += vector_cohesion.normalized() * Consts.SHIP_BOID_COHESION_FORCE
	velocity += vector_alignments.normalized() * Consts.SHIP_BOID_ALIGNMENT_FORCE
	velocity += vector_seperation.normalized() * Consts.SHIP_BOID_SEPARATION_FORCE
	
	return velocity.normalized()
