extends State

func _ready():
	state_ui_unique_id = 'merge'
	host.connect("entity_changed", self, "ui_update")

func update(_delta):
	var ships = _get_adjacent_ships()
	var remaining: Ship = ships.pop_front()
	
	for ship in ships:
		remaining.health += ship.health
		remaining.ship_count += ship.ship_count
		ship.queue_free()
	
	return true

func ui_data():
	return {
		"disabled": _get_adjacent_ships().size() < 2,
		"texture": preload("res://assets/icons/merge.png")
	}

func _get_adjacent_ships() -> Array:
	var adjacent_ships = []
	if host.parent:
		for ship in host.parent.ships:
			if ship.get_script() == host.get_script():
				adjacent_ships.append(ship)
	return adjacent_ships
