extends Node

func process(ship: Entity) -> Vector2:
	var neighbors = []
	
	if not ship.parent:
		return Vector2.ZERO
	
	for child in ship.parent.children:
		if child == ship:
			continue
		
		if child.entity_type == Enums.entity_types.ship and child.state == Enums.ship_states.idle:
			neighbors.append(child)
	
	var velocity = Vector2.ZERO
	velocity += process_cohesion(ship, neighbors) * Consts.SHIP_BOID_COHESION_FORCE
	velocity += process_alignments(ship, neighbors) * Consts.SHIP_BOID_ALIGNMENT_FORCE
	velocity += process_seperation(ship, neighbors) * Consts.SHIP_BOID_SEPARATION_FORCE
	return velocity.normalized()

func process_cohesion(ship: Entity, neighbors: Array):
	var vector = Vector2.ZERO
	if neighbors.empty():
		return vector
	for boid in neighbors:
		vector += boid.position
	vector /= neighbors.size()
	return ship.steer((vector - ship.position).normalized() * ship.ship_speed)

func process_alignments(ship: Entity, neighbors: Array):
	var vector = Vector2.ZERO
	if neighbors.empty():
		return vector

	for boid in neighbors:
		vector += boid.velocity
	vector /= neighbors.size()
	return ship.steer(vector.normalized() * ship.ship_speed)

func process_seperation(ship: Entity, neighbors: Array):
	var vector = Vector2.ZERO
	var close_neighbors = []
	for boid in neighbors:
		if ship.position.distance_to(boid.position) < 100:
			close_neighbors.append(boid)
	if close_neighbors.empty():
		return vector

	for boid in close_neighbors:
		var difference = ship.position - boid.position
		vector += difference.normalized() / difference.length()

	vector /= close_neighbors.size()
	return ship.steer(vector.normalized() * ship.ship_speed)
