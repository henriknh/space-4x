extends State

export var speed = 50

func update(delta):
	ui_progress += delta * speed
	
	if ui_progress >= 100:
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
		
		return true
	
	return

func ui_data():
	return {
		"texture": preload("res://assets/icons/ship.png")
	}
