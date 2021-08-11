extends State

func _ready():
	state_ui_unique_id = 'split'
	host.connect("entity_changed", self, "ui_update")
	host.connect("parent_changed", self, "_parent_changed")
	
func update(delta):
	var ship_type = null
	match Utils.get_type(host):
		Explorer:
			ship_type = Enums.ship_types.explorer
		Fighter:
			ship_type = Enums.ship_types.fighter
		Miner:
			ship_type = Enums.ship_types.miner
	
	if not ship_type:
		breakpoint
	
	var split = Instancer.ship(ship_type, host)
	host.get_parent().add_child(split)
	
	var ship_count_per_ship = host.ship_count / 2
	var ship_count_rest = host.ship_count % 2
	host.ship_count = ship_count_per_ship + ship_count_rest
	split.ship_count = ship_count_per_ship
	
	var health_per_ship = host.health / 2
	var health_rest = host.health % 2
	host.health = health_per_ship + health_rest
	split.health = health_per_ship
	
	return true
	

func ui_disabled() -> bool:
	return host.ship_count < 2

func _parent_changed():
	if host.parent:
		host.parent.connect("ship_changed", self, "ui_update")
