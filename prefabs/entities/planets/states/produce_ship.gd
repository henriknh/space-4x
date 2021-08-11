extends State

var completed = false

func enter():
	ui_progress = 0
	completed = false
	get_owner().get_corporation().resource_titanium -= Enums.produce_types_cost[Enums.produce_types.SHIP]

func exit():
	if not completed:
		get_owner().get_corporation().resource_titanium += Enums.produce_types_cost[Enums.produce_types.SHIP]

func update(delta):
	ui_progress += (delta / process_speed)
	
	if ui_progress >= 1:
		var spawn_tile = null
		for neighbor in host.get_parent().neighbors:
			if host.corporation_id == neighbor.corporation_id:
				spawn_tile = neighbor
				break
			
		if spawn_tile:
			
			var override = {
				"translation": spawn_tile.global_transform.origin,
				"corporation_id": host.corporation_id
			}
			get_node('/root/GameScene').add_child(Instancer.ship(Enums.ship_types.explorer, null, override))
			
			completed = true
		
		return true
	
	return
