extends Task

class_name ShipTypeCount

onready var host: Entity = get_owner()
export(int) var threashold: int = 0
export(Enums.ship_types) var ship_type: int = 0

func _ready():
	if not host:
		breakpoint
	
func run():
	var count = 0
	
	for ship in get_tree().get_nodes_in_group("Ship"):
		if (ship as Entity).corporation_id == host.corporation_id:
			var ships_type = Utils.get_ship_type(ship)
			if ships_type == ship_type:
				count += 1
	
	if count >= threashold:
		success()
	else:
		fail()
