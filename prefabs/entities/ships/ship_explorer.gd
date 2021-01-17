extends ship

class_name ship_explorer

var is_colonizing = false
var explore_position: Vector2 = Vector2.INF 

func create():
	color = Color(1, 1, 1, 1)
	ship_type = Enums.ship_types.explorer
	ship_speed_max = 1000
	power_max = 40
	.create()
	
func ready():
	add_to_group('Explorer')
	.ready()

func process(delta: float):
	is_colonizing = true
	if ship_target_id == -1 and parent:
		if is_colonizing and parent.faction == -1:
			if not move(parent.position):
				parent.faction = faction
				parent.update()
				kill()
		else:
			if explore_position.distance_squared_to(position) < pow(ship_speed, 2):
				explore_position = Vector2.INF
			
			if explore_position == Vector2.INF:
				ship_speed_max = 500
				explore_position = get_random_point_in_site()
			else:
				ship_speed_max = 1000
				
			move(explore_position, false)
			
	.process(delta)

func clear():
	.clear()
